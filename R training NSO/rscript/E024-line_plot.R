library(ggplot2)
library(dplyr)

wb_energy <- read.csv('data/006-wb_energy.csv')

df <- wb_energy %>% filter(country %in% c('Nepal', 'India', 'Bangladesh', 'Pakistan'))

ggplot(data = df, mapping = aes(x = year, y = ele_total, color = country, linetype = country )) +
  geom_line(size = 1.3) +
  labs(y = '% of population with access to electricity') +
  theme_bw() +
  theme(legend.position = 'bottom') +
  scale_x_continuous(breaks = seq(1990,2020,2)) +
  scale_y_continuous(breaks = seq(0,100,10))
