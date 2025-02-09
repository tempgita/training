#----------------------------------------------------------------------------
# ggplot2 basics
#----------------------------------------------------------------------------
library(ggplot2)
library(mosaicData)

#simple scatter plot
ggplot(data = CPS85, mapping = aes(x = exper, y = wage)) + 
  geom_point()

#scatter plot with various attributes
ggplot(data = CPS85, mapping = aes(x = exper, y = wage)) + 
  geom_point(color = 'blue', shape = 16, alpha = 0.3, size = 2)

#applying ggplot2 themes
ggplot(data = CPS85, mapping = aes(x = exper, y = wage)) + 
  geom_point(color = 'blue', shape = 16, alpha = 0.3, size = 2) +
  theme_bw()

#scatter plot and best fit line
ggplot(data = CPS85, mapping = aes(x = exper, y = wage)) + 
  geom_point(color = 'blue', shape = 16, alpha = 0.3, size = 2) +
  geom_smooth(method = 'lm') +
  theme_bw()
  
# grouping category variable attribute color
ggplot(data = CPS85, mapping = aes(x = exper, y = wage, color = sex)) + 
  geom_point(alpha = 0.3, size = 2) +
  geom_smooth(method = 'lm', se = FALSE, size = 1.3, linetype = 'longdash') +
  theme_bw()

# x-axis and y-axis setting scales
ggplot(data = CPS85, mapping = aes(x = exper, y = wage, color = sex)) + 
  geom_point(alpha = 0.3, size = 2) +
  geom_smooth(method = 'lm', se = FALSE, size = 1.3, linetype = 'longdash') +
  scale_x_continuous(breaks = seq(0,70,10)) +
  scale_y_continuous(breaks = seq(0,60,5)) +
  theme_bw()

# color manual of grouped category variable
ggplot(data = CPS85, mapping = aes(x = exper, y = wage, color = sex)) + 
  geom_point(alpha = 0.3, size = 2) +
  geom_smooth(method = 'lm', se = FALSE, size = 1.3, linetype = 'longdash') +
  scale_x_continuous(breaks = seq(0,70,10)) +
  scale_y_continuous(breaks = seq(0,60,5)) +
  scale_color_manual(values = c('darkgreen','red')) +
  theme_bw()

# subplots according to a categorical variable (facet_wrap)
ggplot(data = CPS85, mapping = aes(x = exper, y = wage, color = sex)) + 
  geom_point(alpha = 0.3, size = 2) +
  geom_smooth(method = 'lm', se = FALSE, size = 1.3, linetype = 'longdash') +
  scale_x_continuous(breaks = seq(0,70,10)) +
  scale_y_continuous(breaks = seq(0,60,5)) +
  scale_color_manual(values = c('darkgreen','red')) +
  facet_wrap(~sector) +
  theme_bw()
  
# subplots according to a categorical variable (facet_grid)
ggplot(data = CPS85, mapping = aes(x = exper, y = wage, color = sex)) + 
  geom_point(alpha = 0.3, size = 2) +
  geom_smooth(method = 'lm', se = FALSE, size = 1.3, linetype = 'longdash') +
  scale_x_continuous(breaks = seq(0,70,10)) +
  scale_y_continuous(breaks = seq(0,60,5)) +
  scale_color_manual(values = c('darkgreen','red')) +
  facet_grid(union ~ married) +
  theme_bw()

# labels
ggplot(data = CPS85, mapping = aes(x = exper, y = wage, color = sex)) + 
  geom_point(alpha = 0.3, size = 2) +
  geom_smooth(method = 'lm', se = FALSE, size = 1.3, linetype = 'longdash') +
  scale_x_continuous(breaks = seq(0,70,10)) +
  scale_y_continuous(breaks = seq(0,60,5)) +
  scale_color_manual(values = c('darkgreen','red'), labels = c('Male', 'Female')) +
  facet_grid(union ~ married) +
  labs(title = 'Relationship between wages and experiences',
       subtitle = 'Current Population Survey',
       caption = "Source: http://mosaic-web.org",
       x = "Years of Experience",
       y = "Hourly Wage",
       color = 'Gender') +
  theme_bw()
