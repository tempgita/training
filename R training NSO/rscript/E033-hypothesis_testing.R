library(dplyr)

# Set seed for reproducibility
set.seed(12345)

# Create a dummy dataset
n <- 1000
group <- rep(0:1, length.out = n)
score <- 50 + group * 10 + rnorm(n, mean = 0, sd = 10)

# Combine into a data frame
data <- data.frame(group = group, score = score)

# Conducting hypothesis testing (one-sample t-tests)
t.test(data$score, mu = 50)  # H0: pop_mean = 50
t.test(data$score, mu = 55)  # H0: pop_mean = 55
t.test(data$score, mu = 60)  # H0: pop_mean = 60


# --------------------------------------
# Conducting two-sample t-test
# --------------------------------------
data0 <- filter(data, group == 0)
data1 <- filter(data, group == 1)
t.test(data0$score, data1$score)

#OR

t.test(score ~ group, data = data)  # H0: pop_mean_group1 = pop_mean_group2

