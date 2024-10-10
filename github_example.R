# this is an example to run the survival decision tree (SDT), Cox model, and random survival forest (RSF)
# you need to set your own working directory
setwd("Specify-Your-Working-Directory")
set.seed(1)

# load packages
library(rpart)
library(survival)
library(rpart.plot)
library(survminer)
library(gtsummary)
library(randomForestSRC)
library(dplyr)
library(tidyverse)
library(Hmisc)
library(pec)

# import all those source files from the 'functions' folder 
source("fit_models_fun.R")
source("eval_models_fun.R")
