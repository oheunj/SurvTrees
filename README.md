# Risk Stratification Using Tree-Based Models for Recurrence-Free Survival in Breast Cancer
This is the work for developing tree-based machine learning models for survival outcomes. The paper is currently under review at JCO OA.
```{r}
Oh, E. J., Alfano, C. M., Esteva, F. J., Baron, P. L., Xiong, W., Brooke, T. E., Chen, E. I.,
and Chiuzan, C. (2024+). Risk stratification using tree-based models for recurrence-free survival in
breast cancer.
```

# Files in this repository
The source code for fitting tree-based models is currently provided at "github_example.R'. Additional files and sample data will be uploaded soon. We recommend loading the sample data provided in the same folder to quickly test the source code before tailoring it to your own data.

# Installation
R is a statistical software program, and RStudio is a user interface for R. We recommend that users install both R and R Studio. Both R and RStudio are free and open source.

## Requirements
You may need to install the following dependencies first:
```{r}
library(dplyr)
library(survival)
library(survminer)
library(purrr)
library(lubridate)
library(janitor)
library(lubridate)
library(rpart)
library(rpart.plot)
library(Rcpp)
library(tidyverse)
library(partykit)
library(pec)
library(Matrix)
library(rms)
library(randomForestSRC)
library(pec)
```

# License
```{r}
Licensed under the GNU General Public License v2.0 (GPL-2.0);
you may not use this file except in compliance with the License.
```
