library(ggplot2)

mtcars <- datasets::mtcars

#--------------------------------------
#simple regression
#--------------------------------------
fit <- lm(data = mtcars, formula = mpg ~ hp) # mpg: Miles/(US) gallon, hp: Gross horsepower
summary(fit) #R-squared : 0.6024, Residual standard error: 3.863

ggplot(mtcars, aes(x = hp, y = mpg)) +
  geom_point() + 
  stat_smooth(method = 'lm', formula = y ~ x, color = 'red', se = FALSE) +  
  theme_bw()


#--------------------------------------
#Polynomial regression regression
#--------------------------------------
fit <- lm(data = mtcars, formula = mpg ~ hp + I(hp^2))
summary(fit) #R-squared : 0.7561, Residual standard error: 3.077

ggplot(mtcars, aes(x = hp, y = mpg)) +
  geom_point() + 
  stat_smooth(method = 'lm', formula = y ~ x + I(x^2), color = 'red', se = FALSE) + 
  theme_bw()
