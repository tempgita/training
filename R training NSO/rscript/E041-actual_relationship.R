library(haven)
library(dplyr)
library(tseries)
library(ggplot2)

df <- read_dta('data/012-pwt1001.dta')

df <- filter(df, countrycode == 'NPL' &  year >= 1960) %>% select(year, rgdpe, ccon)

#Visual inspection of stationarity
ggplot() + 
  geom_line(data = df, aes(x=year, y=rgdpe), size = 1) +
  labs(title = 'Nepal GDP') +
  theme_bw()

ggplot() + 
  geom_line(data = df, aes(x=year, y=ccon), size = 1) +
  labs(title = 'Nepal Consumption (Private + Govt)') +
  theme_bw()

#Hypothesis testing of stationarity
adf.test(df$rgdpe)
adf.test(df$ccon)

#Running a regression
fit <- lm(formula = rgdpe ~ ccon ,data = df)
summary(fit)

#-------------------------------------------------------------
# Making series stationary and repeating the above steps
#-------------------------------------------------------------
df <- df %>% 
  mutate(dlrgdpe = c(NA,diff(log(rgdpe))),                                    
         dlccon = c(NA,diff(log(ccon)))) %>%
  na.omit()

#Visual inspection of stationarity
ggplot() + 
  geom_line(data = df, aes(x=year, y=dlrgdpe), size = 1) +
  labs(title = 'Nepal GDP growth') +
  theme_bw()

ggplot() + 
  geom_line(data = df, aes(x=year, y=dlccon), size = 1) +
  labs(title = 'Nepal Consumption (Private + Govt) growth') +
  theme_bw()

#Hypothesis testing of stationarity
adf.test(df_npl_usa$dlrgdpe_npl)
adf.test(df_npl_usa$dlrgdpe_usa)

#Running a regression
fit <- lm(formula = dlrgdpe ~ dlccon ,data = df)
summary(fit)
