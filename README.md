# Risk Stratification Using Tree-Based Models for Recurrence-Free Survival in Breast Cancer
This is the work for developing tree-based machine learning models for survival outcomes. The paper is currently under review.
```{r}
Oh, E. J., Alfano, C. M., Esteva, F. J., Baron, P. L., Xiong, W., Brooke, T. E., Chen, E. I.,
and Chiuzan, C. (2024+). Risk stratification using tree-based models for recurrence-free survival in
breast cancer.
```

# Files in this repository
The source code is currently provided in 'main_sourecode.R' which starts from loading R packages and reads several R functions in the 'functions' folder.

# Installation
R is a statistical software program, and RStudio is a user interface for R. We recommend that users install both R and R Studio. Both R and RStudio are free and open source.

## Requirements
You may need to install the following dependencies first:
```{r}
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
```

# License
```{r}
Licensed under the GNU General Public License v2.0 (GPL-2.0);
you may not use this file except in compliance with the License.
```
