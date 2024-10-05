# install packages
library(readr)
library(tidyr)
library(stringr)
library(data.table)
library(dplyr)
library(purrr)
library(gtsummary)
library(lubridate)
library(janitor)
library(lubridate)
library(rpart)
library(rpart.plot)
library(survival)
library(survminer)
library(Rcpp)
library(tidyverse)
library(partykit)
library(pec)
library(Matrix)
library(rms)
library(randomForestSRC)
library(pec)


#------------------------------------------------------------------------------#
# Survival decision tree
#------------------------------------------------------------------------------#
# grow a tree
fit_SDT = rpart(Surv(survmonths, status) ~ x1 + x2 + x3 + x4 + x5, 
                data = dat,
                method = "exp",
                control = rpart.control(minsplit=15))

plotcp(fit_train) # cross-validation results 
rpart.plot(fit_train, uniform=TRUE, 
           branch=0.8, compress=TRUE, 
           main="Decision Tree for Survival")

# prune the tree by 1-standard error rule
cp.select = function(big.tree) {
  min.x = which.min(big.tree$cptable[, 4]) #column 4 is xerror
  for(i in 1:nrow(big.tree$cptable)) {
    if(big.tree$cptable[i, 4] < big.tree$cptable[min.x, 4] + big.tree$cptable[min.x, 5]) 
      return(big.tree$cptable[i, 1]) #column 5: xstd, column 1: cp
  }
}

pfit_train = prune(fit_train, cp = cp.select(fit_train))

rpart.plot(pfit_train)
