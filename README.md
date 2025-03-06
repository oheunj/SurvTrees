# Risk Stratification Using Tree-Based Models for Recurrence-Free Survival in Breast Cancer
The goal of this project is to develop tree-based machine learning models for survival outcomes in breast cancer. The full manuscript is available in:

\texttt{Oh, E. J., Alfano, C. M., Esteva, F. J., Baron, P. L., Xiong, W., Brooke, T. E., Chen, E. I., and Chiuzan, C. (2025). Risk stratification using tree-based models for recurrence-free survival in breast cancer. JCO Oncology Advances, 2, e2400011.}

```{r}
Oh, E. J., Alfano, C. M., Esteva, F. J., Baron, P. L., Xiong, W., Brooke, T. E., Chen, E. I., and Chiuzan, C. (2025). Risk stratification using tree-based models for recurrence-free survival in breast cancer. JCO Oncology Advances, 2, e2400011.
```

# Files in this repository
The source code is currently provided in 'main_sourecode.R'

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
library(knitr)
```

Additionally, you need to save the following R codes from the 'functions' folder to your working directory and import these files:
```{r}
source("prune_1se_fun")
source("pecRpart_fun")
```

# License
```{r}
Licensed under the GNU General Public License v2.0 (GPL-2.0);
you may not use this file except in compliance with the License.
```
