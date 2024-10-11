# this is an example to perform the survival decision tree (SDT), Cox model, and random survival forest (RSF)
# the file is licensed under the GNU General Public License v2.0 (GPL-2.0)

# please set your own working directory
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
library(knitr)

# import several R functions (note: please save them from the folder 'functions' to your working directory)
source("cp.select_fun")
source("pecRpart_fun")





#------------------------------------------------------------------------------#
# Survival Decision Tree (SDT) 
#------------------------------------------------------------------------------#
# grow a tree
fit_SDT = rpart(Surv(survtimes, status) ~ ., # or specify the formula
                data = train.dat,
                method = "exp",
                control = rpart.control(minsplit = 15))

# cross-validation results
plotcp(fit_SDT)

# visualize the tree
rpart.plot(fit_SDT, 
           uniform = TRUE, 
           branch = 0.8, 
           compress = TRUE, 
           main = "Survival Decision Tree")

# prune the tree by 1-standard error rule
fit_pSDT = prune(fit_SDT, cp = cp.select(fit_SDT))

# visualize the pruned tree
rpart.plot(fit_pSDT)

# KM curves on terminal nodes
kmdat = train.dat
t.nodes = predict(fit_pSDT, newdata = kmdat)
kmdat$riskgroup = factor(t.nodes, labels = 1:length(unique(t.nodes)))
kmfit = survfit(Surv(survtimes, status) ~ riskgroup, data = kmdat)
ggsurvplot(kmfit,
           pval = TRUE, 
           conf.int = FALSE,
           risk.table = T,
           risk.table.col = "strata",
           surv.median.line = "hv", 
           linetype = "strata",
           ggtheme = theme_bw())

# pairwise log-rank test.dat
pairwise_survdiff(Surv(survtimes, status) ~ riskgroup,
                  data = kmdat)

# estimated 3-year survival (95% CI)
kmfit %>% 
  tbl_survfit(
    times = 36,
    estimate_fun = function(x) style_number(x, digits = 1, scale = 100),
    label_header = "**3-year Survival (95% CI)**",
    label = list(riskgroup ~ "Risk Group"))


#------------------------------------------------------------------------------#
# Cox model 
#------------------------------------------------------------------------------#
# fit a multivariable Cox model
fit_Cox = coxph(Surv(survtimes, status) ~ ., # or specify the formula
                data = train.dat,
                x = T, y = T)

# hazard ratios
fit_Cox %>%
  tbl_regression(exponentiate = T,
                 estimate_fun = function(x) style_number(x, digits = 2),
                 pvalue_fun   = function(x) style_pvalue(x, digits = 3)) %>%
  add_global_p(keep = T, test.dat = "Wald")



#------------------------------------------------------------------------------#
# Random Survival Forest (RSF)
#------------------------------------------------------------------------------#
fit_RSF = rfsrc(Surv(survtimes, status) ~ ., # or specify the formula
                data = train.dat,
                ntree = 500,
                nodesize = 15,
                importance = TRUE)

# visualize one tree as an illustrative purpose out of 500 trees
plot(get.tree(fit_RSF, tree.id=1))

# variable importance
fit_RSF$importance %>% 
  data.frame() %>%
  rownames_to_column(var = "Feature") %>%
  rename(Overall = '.') %>%
  ggplot(aes(x = fct_reorder(Feature, Overall), y = Overall)) +
  geom_pointrange(aes(ymin = 0, ymax = Overall), color = "cadetblue", size = .3) +
  theme_minimal() +
  coord_flip() +
  labs(x = "", y = "", title = "Variable Importance")











#------------------------------------------------------------------------------#
# Calculate c-index
#------------------------------------------------------------------------------#
surv_obj = Surv(time = test.dat$survtimes, event = test.dat$status)

cindex = c(1-rcorr.cens(x = predict(fit_SDT, test.dat), S = surv_obj)[1],
           1-rcorr.cens(x = predict(fit_pSDT, test.dat), S = surv_obj)[1],
           1-rcorr.cens(x = predict(fit_Cox, test.dat), S = surv_obj)[1],
           1-rcorr.cens(x = predict(fit_RSF, test.dat)$predicted, S = surv_obj)[1])



#------------------------------------------------------------------------------#
# Calculate calibration intercept & slope at year 3
#------------------------------------------------------------------------------#
fit_SDT_pec = pecRpart(robj = fit_SDT,
                       formula = Surv(survtimes, status) ~ ., # or specify the formula
                       data = test.dat)

fit_pSDT_pec = pecRpart(robj = fit_pSDT,
                        formula = Surv(survtimes, status) ~ ., # or specify the formula
                        data = test.dat)

calobj = calPlot(
  list(pam1 = fit_SDT_pec,
       pam2 = fit_pSDT_pec,
       pam3 = fit_Cox,
       pam4 = fit_RSF),
  Surv(survtimes, status) ~ ., # or specify the formula
  time = 36,
  type = "survival",
  legend = F,
  data = test.dat,
  plot = FALSE,
  bandwidth = 0.1)

calmeasures = cbind(lm(calobj$plotFrames$pam1[,1] ~ calobj$plotFrames$pam1[,2])$coef,
                    lm(calobj$plotFrames$pam2[,1] ~ calobj$plotFrames$pam2[,2])$coef,
                    lm(calobj$plotFrames$pam3[,1] ~ calobj$plotFrames$pam3[,2])$coef,
                    lm(calobj$plotFrames$pam4[,1] ~ calobj$plotFrames$pam4[,2])$coef)



#------------------------------------------------------------------------------#
# Calculate integrated Brier score
#------------------------------------------------------------------------------#
pec = pec(
  list(SDT = fit_SDT_pec, pSDT = fit_pSDT_pec, Cox = fit_Cox, RSF = fit_RSF),
  Surv(survtimes, status) ~ X.1 + X.2 + X.3 + X.4 + X.5 + X.6 + X.7 + X.8 + X.9 + X.10 + 
    X.11 + X.12 + X.13 + X.14 + X.15 + X.16 + X.17 + X.18, # specify the formula
  data = test.dat,
  exact = FALSE
)

ibs = t(as.matrix(crps(pec, times = c(12, 24, 36))))
ibs = ibs[,-1] # remove Reference



#------------------------------------------------------------------------------#
# combine all performance metrics into a table
#------------------------------------------------------------------------------#
tab = rbind(cindex, calmeasures, ibs)
rownames(tab) = c("c-index", "CIN", "CSL", "IBS[0,12)", "IBS[0,24)","IBS[0,36)")
colnames(tab) = c("SDT", "pSDT", "Cox", "RSF")
kable(tab)


