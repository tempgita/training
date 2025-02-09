library(haven)
library(dplyr)
library(tseries)
library(ggplot2)

df <- read_dta('data/012-pwt1001.dta')

#keeping real GDP of Nepal from 1960 onwards
npl <- df %>% 
  filter(countrycode == 'NPL' & year >= 1960) %>% 
  select(year, rgdpe) %>% 
  rename(rgdpe_npl = rgdpe)

#keeping real GDP of USA from 1960 onwards
usa <- df %>% 
  filter(countrycode == 'USA' & year >= 1960) %>% 
  select(year, rgdpe) %>% 
  rename(rgdpe_usa = rgdpe)

#joining Nepal and USA data into one dataframe
df_npl_usa <- full_join(npl, usa, by = 'year')

#Visual inspection of stationarity
ggplot() + 
  geom_line(data = df_npl_usa, aes(x=year, y=rgdpe_npl), size = 1) +
  labs(title = 'Nepal GDP') +
  theme_bw()

ggplot() + 
  geom_line(data = df_npl_usa, aes(x=year, y=rgdpe_usa), size = 1) +
  labs(title = 'USA GDP') +
  theme_bw()

#Hypothesis testing of stationarity
adf.test(df_npl_usa$rgdpe_npl)
adf.test(df_npl_usa$rgdpe_usa)

#Running a regression (Spurious regression observed)
fit <- lm(formula = rgdpe_usa ~ rgdpe_npl ,data = df_npl_usa)
summary(fit)

#-------------------------------------------------------------
# Making series stationary and repeating the above steps
#-------------------------------------------------------------
df_npl_usa <- df_npl_usa %>% 
  mutate(dlrgdpe_npl = c(NA,diff(log(rgdpe_npl))),                                    
         dlrgdpe_usa = c(NA,diff(log(rgdpe_usa)))) %>% 
  na.omit()

#Visual inspection of stationarity
ggplot() + 
  geom_line(data = df_npl_usa, aes(x=year, y=dlrgdpe_npl), size = 1) +
  labs(title = 'Nepal GDP growth') +
  theme_bw()

ggplot() + 
  geom_line(data = df_npl_usa, aes(x=year, y=dlrgdpe_usa), size = 1) +
  labs(title = 'USA GDP growth') +
  theme_bw()

#Hypothesis testing of stationarity
adf.test(df_npl_usa$dlrgdpe_npl)
adf.test(df_npl_usa$dlrgdpe_usa)

#Running a regression (no spurious regression observed)
fit <- lm(formula = dlrgdpe_usa ~ dlrgdpe_npl ,data = df_npl_usa)
summary(fit)
