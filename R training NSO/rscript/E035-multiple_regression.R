# Set seed for reproducibility
set.seed(12345)

# Generate 200 observations
n <- 200

# Generate age variable (cycles from 18 to 69)
age <- (1:n %% 52) + 18

# Generate educ_year variable (cycles from 0 to 17)
educ_year <- (1:n %% 18)

# Generate income variable with a linear relationship to age and educ_year, plus noise
income <- 20000 + 800 * age + 3000 * educ_year + rnorm(n, mean = 0, sd = 2000)

# Combine into a data frame
df <- data.frame(age, educ_year, income)

# Regression with omitted variable
model_omitted <- lm(income ~ age, data = df)
summary(model_omitted)

# Residual diagnostics for omitted variable model
plot(model_omitted, which = 1)  # Residual vs Fitted plot
resid_omitted <- residuals(model_omitted)
hist(resid_omitted)
shapiro.test(resid_omitted)  # Shapiro-Wilk test for normality [H0: normally distributed]

#----------------------------------------------------------------------------------------
# Multiple regression with correct specification
model_correct <- lm(income ~ age + educ_year, data = df)
summary(model_correct)

# Residual diagnostics for correctly specified model
plot(model_correct, which = 1)  # Residual vs Fitted plot
resid_correct <- residuals(model_correct)
hist(resid_correct)
shapiro.test(resid_correct)  # Shapiro-Wilk test for normality
