# Load necessary libraries
library(haven)  # For reading SPSS files
library(dplyr)    # For data manipulation
library(margins)  # For calculating marginal effects

# Import SPSS file from the URL
data <- read_spss('data/010-hh.sav')

# Dropping missing values in HHSEX
data <- data %>% filter(!is.na(HHSEX))

# Creating new variables
data <- data %>%
  mutate(
    hh_size = HH48,  # HH member size variable
    urb_rur = factor(HH6),  # 1=Urban 2=Rural
    province = factor(HH7),  # Province number
    hhsex = factor(HHSEX) # 1=Male 2=Female
  )

#setting 1=Urban as reference/base
data$urb_rur <- relevel(data$urb_rur, ref = '1') 

#setting 2=Female as reference/base
data$hhsex <- relevel(data$hhsex, ref = '2') 

#setting province 3 as base category/reference level
data$province <- relevel(data$province, ref = '3') 

#-----------------------------------------------
# Running logistic regression
#-----------------------------------------------
logit_model <- glm(hhsex ~ hh_size + urb_rur + province, 
                   data = data, family = binomial(link = "logit"))
summary(logit_model)

# Calculating marginal effects for logistic regression
logit_margins <- margins(logit_model)
summary(logit_margins)

#-----------------------------------------------
# Running probit regression
#-----------------------------------------------
probit_model <- glm(hhsex ~ hh_size + urb_rur + province, 
                    data = data, family = binomial(link = "probit"))
summary(probit_model)

# Calculating marginal effects for probit regression
probit_margins <- margins(probit_model)
summary(probit_margins)
