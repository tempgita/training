mtcars <- datasets::mtcars

#generating a new interaction term hp * wt
mtcars$hp_wt <- mtcars$hp * mtcars$wt

fit <- lm(mpg ~ hp + wt + hp_wt, data=mtcars)
summary(fit)

#OR

fit <- lm(mpg ~ hp + wt + hp:wt, data=mtcars)
summary(fit)

# Coefficients:
#               Estimate    Std. Error  t value Pr(>|t|)    
# (Intercept)   49.80842    3.60516     13.816  5.01e-14 ***
#   hp          -0.12010    0.02470     -4.863  4.04e-05 ***
#   wt          -8.21662    1.26971     -6.471  5.20e-07 ***
#   hp:wt        0.02785    0.00742     3.753   0.000811 ***

# mpg = 49.80842 - 0.12010 * hp - 8.21662 * wt + 0.02785 * hp * wt

#* -------------------------------------------------------------
#* A significant coefficient of interaction term indicates that
#* the relationship between mpg and hp varies by wt. Similarly,
#* the relationship between mpg and wt varies by hp.
#* -------------------------------------------------------------

# d(mpg)/d(hp) = - 0.12010 + 0.02785 * wt 
wt = 1
print(- 0.12010 + 0.02785 * wt) #-0.09225

wt = 2
print(- 0.12010 + 0.02785 * wt) #-0.0644

wt = 3
print(- 0.12010 + 0.02785 * wt) #-0.03655


# d(mpg)/d(wt) = - 8.21662 + 0.02785 * hp
hp = 100
print(- 8.21662 + 0.02785 * hp) #-5.43162

hp = 150
print(- 8.21662 + 0.02785 * hp) #-4.03912

hp = 200
print(- 8.21662 + 0.02785 * hp) #-2.64662


