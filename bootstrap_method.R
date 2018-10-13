#simulate points
require(MASS)
require(wordspace)
Sigma = matrix(c(4,3,3,3,  3,4,3,3, 3,3,4,3, 3,3,3,4), 4,4)
n = 100
#true_coef = .3
#noise_sd = 1.4
n_bootstraps = 1000
n_per_bootstrap = 1000

#mask to compare only the upper triangle
m <-  matrix(0, n, n)
for (i in 1:n){
  for (j in 1:n){
    if (i < j){
      m[i,j] <- 1
    }
  }
}
m <- m > 0


m2 <- matrix(0, 100, 100)
for (i in 1:100){
  for (j in 1:100){
    if (i < j){
      m2[i,j] <- 1
    }
  }
}
m2 <- m2 > 0
#approximate true answer using big sample
population = mvrnorm(200000, mu = c(0,0,0,0), Sigma)
d1 = rep(NA, 100000)
d2 = rep(NA, 100000)
for(i in 1:100000){
    d1[i] = (sqrt(sum((population[2*i -1 , 1:2] - population[2*i, 1:2])^2)))
    d2[i] = (sqrt(sum((population[2*i -1 , 3:4] - population[2*i, 3:4])^2)))
}
true_coef = cor(d1, d2)

lower_bounds = rep(NA, n_bootstraps) 
upper_bounds = rep(NA, n_bootstraps) 
values = rep(NA, n_bootstraps) 
for (rep in 1:n_bootstraps){
  locs = mvrnorm(n, mu = c(0,0,0,0), Sigma)
  print(rep)
  xmat = dist.matrix(locs[, 1:2], method = "euclidean")
  ymat = dist.matrix(locs[, 3:4], method = "euclidean")
  x = xmat[m]
  y = ymat[m]
  values[rep] = cor(x,y)
  sim_coefs = rep(NA, n_per_bootstrap)
  for (i in 1:n_per_bootstrap){
    samples = sample(1:n, replace = T)
    x_smp = xmat[samples, samples][m]
    y_smp = ymat[samples, samples][m]
    sim_coefs[i] <- cor(x_smp[x_smp > 0], y_smp[x_smp > 0])
    #mod = lm(y_smp[x_smp > 0] ~ x_smp[x_smp > 0]) #ignore when resampled points are compared to themselves
    #sim_coefs[i] <- mod$coefficients[2]
  }
  lower_bounds[rep] = quantile(sim_coefs, .025)
  upper_bounds[rep] = quantile(sim_coefs, .975)
}
mean(lower_bounds < true_coef & upper_bounds > true_coef)
mean(values)
