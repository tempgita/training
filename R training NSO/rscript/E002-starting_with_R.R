#creating dummy dataset
age <- c(1,3,5,2,11,9,3,9,12,3)
weight <- c(4.4,5.3,7.2,5.2,8.5,7.3,6.0,10.4,10.2,6.1)

#calculating mean weight
mean(weight)

#calculating standard deviation of weight
sd(weight)

#calculating correlation between age and weight
cor(age, weight)

#plotting age and weight
plot(age, weight)