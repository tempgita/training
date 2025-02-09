#----------------------------------------------------------
# Log-Log Regression
#----------------------------------------------------------
# Load data
mtcars <- datasets::mtcars

# Log-log regression
model_loglog <- lm(log(mpg) ~ log(disp), data = mtcars)
summary(model_loglog)

# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)  5.38097    0.20803   25.87  < 2e-16 ***
#   log(disp)   -0.45857    0.03913  -11.72 1.01e-12 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# A 1% increase in Displacement (cu.in.) reduces Miles/(US) gallon by ~0.46%.

#----------------------------------------------------------
# Log-Linear Regression
#----------------------------------------------------------
# Log-linear regression
model_loglin <- lm(log(mpg) ~ hp, data = mtcars)
summary(model_loglin)

# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept)  3.4604669  0.0785838  44.035  < 2e-16 ***
#   hp          -0.0034287  0.0004867  -7.045 7.85e-08 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1 
# A 1-unit increase in horsepower reduces MPG by ~0.34% (exp(-0.0034287) - 1 ≈ -0.003422829).

#----------------------------------------------------------
# Linear-Log Regression
#----------------------------------------------------------
# Load data
trees <- datasets::trees

# Linear-log regression
model_linlog <- lm(Volume ~ log(Girth), data = trees)
summary(model_linlog)

# Coefficients:
#   Estimate Std. Error t value Pr(>|t|)    
# (Intercept) -138.973     11.439  -12.15 6.71e-13 ***
#   log(Girth)    66.141      4.455   14.85 4.38e-15 ***
#   ---
#   Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1

# A 1% increase in girth increases volume by ~ 0.66 units (66.141 / 100).