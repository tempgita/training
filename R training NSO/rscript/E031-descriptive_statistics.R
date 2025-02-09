data(mtcars) #from datasets package

vars <- c('mpg','cyl','disp')

#basic descriptive statistics from base package
summary(mtcars[vars])

#descriptive statistics from other packages
Hmisc::describe(mtcars[vars])
pastecs::stat.desc(mtcars[vars])
psych::describe(mtcars[vars])

#----------------------------------
# Descriptive statistics by group
#----------------------------------
#grouping by one variable
by(mtcars[vars], #dataset
   list(Transmission = mtcars$am), #grouping variable: Transmission (0 = automatic, 1 = manual)
   summary) #function

#grouping by multiple variables
by(mtcars[vars],
   list(Transmission = mtcars$am, Engine = mtcars$vs), # Transmission (0 = automatic, 1 = manual), Engine (0 = V-shaped, 1 = straight)
   summary)
