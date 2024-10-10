# this is an example to run the survival decision tree, Cox model, and random survival forest
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



#------------------------------------------------------------------------------#
# Survival Decision Tree (SDT)
#------------------------------------------------------------------------------#
train.dat = read.csv("mockdat_train.csv")

# grow a tree
fit_SDT = rpart(Surv(survtimes, status) ~ ., 
                data = train.dat,
                method = "exp",
                control = rpart.control(minsplit=15))

# cross-validation results
plotcp(fit_SDT)

# visualize the tree
rpart.plot(fit_SDT, 
           uniform = TRUE, 
           branch = 0.8, 
           compress = TRUE, 
           main = "Survival Decision Tree")

# prune the tree by 1-standard error rule
cp.select = function(big.tree) {
  min.x = which.min(big.tree$cptable[, 4])
  for(i in 1:nrow(big.tree$cptable)) {
    if(big.tree$cptable[i, 4] < big.tree$cptable[min.x, 4] + big.tree$cptable[min.x, 5]) 
      return(big.tree$cptable[i, 1])
  }
}
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
fit_Cox = coxph(Surv(survtimes, status) ~ ., 
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
# fit a RSF
fit_RSF = rfsrc(Surv(survtimes, status) ~ ., 
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
# Performance metrics
#------------------------------------------------------------------------------#
test.dat = read.csv("mockdat_test.csv")

# c-index
surv_obj = Surv(time = test.dat$survtimes, event = test.dat$status)

cindex = c(1-rcorr.cens(x = predict(fit_SDT, test.dat), S = surv_obj)[1],
           1-rcorr.cens(x = predict(fit_pSDT, test.dat), S = surv_obj)[1],
           1-rcorr.cens(x = predict(fit_Cox, test.dat), S = surv_obj)[1],
           1-rcorr.cens(x = predict(fit_RSF, test.dat)$predicted, S = surv_obj)[1])

# calibration intercept & slope at year 3
# define the object for calPlot
pecRpart = function(robj, formula, data){
  data$rpartFactor = factor(predict(robj, newdata = data))
  form = update(formula, paste(".~", "rpartFactor", sep=""))
  survfit = prodlim::prodlim(form, data = data)
  out = list(rpart = robj, survfit = survfit, levels = levels(data$rpartFactor))
  class(out) = "pecRpart"
  return(out)
}

fit_SDT_pec = pecRpart(robj = fit_SDT,
                       formula = Surv(survtimes, status) ~ .,
                       data = test.dat)

fit_pSDT_pec = pecRpart(robj = fit_pSDT,
                        formula = Surv(survtimes, status) ~ .,
                        data = test.dat)

calobj = calPlot(
  list(pam1 = fit_SDT_pec,
       pam2 = fit_pSDT_pec,
       pam3 = fit_Cox,
       pam4 = fit_RSF),
  Surv(survtimes, status) ~ .,
  col = c("red", "darkmagenta", "blue", "forestgreen"),
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

# integrated Brier score
# calculate prediction error curves
pec = pec(
  list(SDT = fit_SDT_pec, pSDT = fit_pSDT_pec, Cox = fit_Cox, RSF = fit_RSF),
  Surv(survtimes, status) ~ X.1 + X.2 + X.3 + X.4 + X.5 + X.6 + X.7 + X.8 + X.9 + X.10 + 
    X.11 + X.12 + X.13 + X.14 + X.15 + X.16 + X.17 + X.18,
  data = test.dat,
  exact = FALSE
)

ibs = t(as.matrix(crps(pec, times = c(12, 24, 36))))
ibs = ibs[,-1] # remove Reference




# combine all performance metrics
tab = rbind(cindex, calmeasures, ibs)
rownames(tab) = c("c-index", "CIN", "CSL", "IBS[0,12)", "IBS[0,24)","IBS[0,36)")
colnames(tab) = c("SDT", "pSDT", "Cox", "RSF")
tab
