## Code for: Striatal habit system drives behavioral rigidity in PTSD (under review)
Krystian B. Loetscher, D.T. Nguyen, Sanghoon Kang, John H. Krystal, Stephanie M. Groman & Elizabeth V. Goldfarb*
* corresponding author: Elizabeth Goldfarb

## 1. Repo contents
```
 data/ 
   |-- behavioral/                         : processed behavioral data used in analyses (.csv)
   |-- betas/                              : mean beta values derived from first-level GLMs for select ROIs (.csv)
   |-- modeling/     
         |-- fit_outputs/         
               |-- model_fits/             : model fit outputs for winning RL model on behavioral data derived from stan (.rds)
               |-- recovery_fits/          : model fit outputs for winning RL model on simulated data derived from stan  (.rds)
         |-- model_comparison/             : model comparison of winning and other candidate models (e.g. elpd score) (.rds)
         |-- sim_input_data/               : simulated behavioral data used for model recovery (.rds)
   |-- self_report/                        : processed self report data (.csv)
 'bandit2arm_delta_State_persev_Awin.stan' : winning RL model 
 'behavioral_analysis.Rmd'                 : main behavioral analysis script
 'model_analysis.Rmd'                      : main modeling output analysis script
 'behavioral_analysis.html'                : knitted file containing statistics reported for behavioral analyses
 'model_analysis.html'                     : knitted file containing statistics reported for modeling analyses
```
## 2. System requirements, software versions, and dependencies
 - MacOS (13.1 Ventura)
 - Stan (2.21.7)          : Install time < 5 minutes
 - R (4.2.1)              : Install time < 10 minutes, including dependencies
 - lme4 (1.1.30)
 - lmerTest (3.1.3)
 - emmeans (1.8.2)
 - tidyverse (1.3.2)
 - ggplot2 (3.3.6)
 - scales (1.2.1)
 - nlme (3.1.157)
 - psych (2.2.9)
 - emmeans (1.8.2)
 - lme4 (1.1.30)
 - lmerTest (3.1.3)
 - zoo (1.8.11)
 - sjstats (0.18.1)
 - pwr (1.3.0)
 - gridExtra (2.3)
 - patchwork (1.1.2)
 - Hmisc (4.7.1)
 - reshape (0.8.9)
 - hBayesDM (1.2.1)
 - rstan (2.21.7)
 - dplyr (1.0.10)

## 3. Special hardware requirements
 none

## 4. Installation guide
 Install R (4.2.1) from The Comprehensive R Archive Network (CRAN)
 Install R pacakges using install.packages() : (e.g. install.packages("lme4")
 Install rstan from CRAN (install.packages("rstan"))
 Clone this repository

# 5. DEMO
 To replicate analyses, run 'behavioral_analysis.Rmd' or 'model_analysis.Rmd' from the project root.
 Analysis outputs will appear inline in the R script
 Expected run time: No more than 5 minutes for each of the analyses scripts


