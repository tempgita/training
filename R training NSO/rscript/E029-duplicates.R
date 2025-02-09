library(dplyr)

# Creating a sample data frame
df <- data.frame(
  ID = c(1, 2, 3, 3, 4, 5, 4, 3),
  Name = c("John", "Jane", "Mark", "Mark", "Luke", "Kate", "Luke", "Mark"),
  Age = c(25, 30, 35, 35, 40, 45, 40, 35)
)

df

#showing the duplicated observations
df %>% filter(duplicated(.) == T)

#removing the duplicated observations
df %>% filter(!duplicated(.) == T)

#counting the duplicate observations
df %>% group_by_all() %>% 
  summarise(count = n()) %>%
  filter(count > 1)


#identifying duplicate values based on some variables
library(haven)
df <- read_dta('data/008-nlfs2.dta')

#checking whether there is any duplicate based on selected variables
df %>% count(psu, hhid) %>% filter(n > 1)

#selecting observations that does not have duplicate based on selected variables
df %>% filter(duplicated(psu, hhid) == F) %>% count(psu, hhid)
