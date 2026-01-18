#-------------------------------------
# DAY 01 
#-------------------------------------

# Where is your working directory?
getwd()

# set working directory
setwd('C:/Users/HP/Desktop/RTraining')


# Some begining examples 

# 1. Create variables (using the <- assignment operator)
x <- 8  
y <- 4

z <- x+y

z
print(x+y) #value display of objects


# check calculation

z <- x+y

# print z

z

print(paste("sum=",z))

print(paste("The sum is:", z))
print(paste("The average is:", mean(z)))


# create vector
v1 <- c(4,5,3,2,0,6,7,5,4,1,0)
v2 <- c(6,7,2,3,4,2,6,5,8,7,9,2,10,21)

age <- c(21,32,12,34,23,10,23,17,14,25,23,54,16)

height <- c(143.0, 157.6, 118.2, 167.9, 142.8, 111.4, 151.0, 127.3, 119.8, 144.3, 142.2, 210.1, 125.1)
weight <- c(62.1, 75.4, 38.5, 82.0, 60.5, 32.2, 65.8, 52.1, 44.0, 68.3, 63.7, 95.2, 49.6)

# lets do some in-built functions in R

m_age <- mean(age)   # print this ouput in console ???
sd_age <- sd(age)



# plot these in chart plot(x-value,y-value)

plot(age,height)
plot(age,weight)

#-----------------------------------------

# HELP in R 

?mean()
?max()


#-----------------------------------------

# installing the package
# What are packages and library ? (See ppt slides..)

# Install a single package
install.packages("tidyverse")
install.packages("ggplot2")


# Install multiple packages at once
install.packages(c("dplyr", "tidyr", "readxl"))


#-------------------------------------
# Load the Library
#--------------------------------------
library(ggplot2)
library(dplyr)

# Use a function without loading the whole library
# Format: package_name::function_name
dplyr::filter(my_data, age > 20)


#------------------------------------
# Using pipe
#------------------------------------


#exercise: find mean of the age and get the round value
round(mean(age))
#
m <- mean(age)
rm <- round(m)

# version1: Native Pipe (|>)

mean_age_pipe <- age  |>      
                 mean() |>  
                 round()

print(mean_age_pipe)



# version2 : Magrittr Pipe (%>%)

mean_height_pipe <- height %>% 
  mean() %>% 
  round()

print(mean_height_pipe)



#----------------------------------------------
# Session 02
#----------------------------------------------

# Creating a numeric vector
ages <- c(21, 32, 12, 34) 

#Creating a character vector
students <- c("Alice", "Bob", "Charlie", "Diana") 

# Accessing the 2nd element 
ages[2] 


# Creating a list with mixed types

my_list <- list(  name = "Alice",
                  age = 25,  
                  scores = c(90, 85, 88))

# Accessing an item by name 
my_list$name

#------------------------
#  MATRIX
#------------------------

x <- c(1,5,3,0,5,9,7,2)

m1 <- matrix(x, nrow = 2, ncol = 4)  # by row =false
m1

m2 <- matrix(x, nrow = 2, ncol = 4, byrow = TRUE)  # by row =True
m2

# Creating a data frame from vectors
my_df <- data.frame(
  Item  = c("Laptop", "Mouse", "Keyboard"),
  Price = c(1200, 25, 45),
  InStock = c(TRUE, TRUE, FALSE)
)
View(my_df)
# View the structure of the data frame
str(my_df)

print(my_df)
View(my_df)


head(my_df)

# load built-in data frame
head(mtcars)

df <- mtcars$wt

df

mtcars[,2]

# create a dummy survey dataset
#-------------------------------------------

# Set seed so the random numbers are the same every time you run this
set.seed(123)

# 1. Create 100 Names (using built-in letters/sequences for simplicity)
names_list <- paste0("Person_", 1:100)

# 2. Generate 100 Ages (Random integers between 18 and 80)
age <- sample(18:80, 100, replace = TRUE)

# 3. Generate Sex (Categorical)
sex <- sample(c("Male", "Female", "Other"), 100, replace = TRUE, prob = c(0.48, 0.48, 0.04))

# 4. Generate Height in cm (Mean 170, SD 10)
height <- round(rnorm(100, mean = 170, sd = 10), 1)

# 5. Generate Weight in kg (Correlated slightly with height)
weight <- round((height - 100) + rnorm(100, mean = 5, sd = 8), 1)

# 6. Generate Income (Using a log-normal distribution for realism - most people earn average, few earn high)
income <- round(rlnorm(100, meanlog = 10.5, sdlog = 0.5), 0)

# 7. Combine into a Data Frame
survey_data <- data.frame(
  Name = names_list,
  Age = age,
  Sex = sex,
  Height_cm = height,
  Weight_kg = weight,
  Income_USD = income
)

# View the first 10 records
head(survey_data, 10)

#------------------------------------

# Exercise 
# 1. FIND mean of age
# 2. FIND mean of age of Male and Female
# 3. Extract weight  and asign to wt_ext
# 4. make age group of  0-10, 21-30, … using cut()  and case_when()
#---------------------------------------



# Get a summary of all variables (Mean, Median, Max, etc.)
summary(mtcars)



#-------------------------------------
# value labels
#-------------------------------------

# Create a numeric vector
gender_raw <- c(1, 2, 1, 1, 2)

# Convert to factor with labels
gender_factor <- factor(gender_raw, 
                        levels = c(1, 2), 
                        labels = c("Male", "Female"))

print(gender_factor)


# recode labels
gender_recode <- recode(gender_raw, 
                        '1'="Male",
                        '2'="Female")
print(gender_recode)



# Category groups

# Your age vector
age <- c(21, 32, 12, 34, 23, 10, 23, 17, 14, 25, 23, 54, 16)

# Create groups
# breaks: where the slices happen (0-12, 13-19, 20-59, 60+)
# labels: what to call those slices
age_group <- cut(age, 
                 breaks = c(0, 12, 19, 60, Inf), 
                 labels = c("Child", "Teen", "Adult", "Senior"))

print(age_group)

# CASE II USING case_when()

library(dplyr)

df <- data.frame(age = c(21, 32, 12, 34, 23, 10, 23, 17, 14, 25, 23, 54, 16))

df <- df %>%
  mutate(group = case_when(
    age < 13 ~ "Child",
    age >= 13 & age <= 19 ~ "Teen",
    age > 19 & age < 65 ~ "Adult",
    TRUE ~ "Senior" # Everything else
  ))

print(df)


# CASE 3: Evenly Sized Groups

df <- df %>%
  mutate(equal_groups = ntile(age, 3)) # Splits into 3 groups based on rank

df

#---------------------------------------
# xtile group
#----------------------------------------
# Age Vector
age <- c(21, 32, 12, 34, 23, 10, 23, 17, 14, 25, 23, 54, 16)

# Divide into 4 equal groups (Quartiles)
quartiles <- ntile(age, 4)

# Put it into a table to see the result
df <- data.frame(age, quartiles) %>% arrange(age)
print(df)
