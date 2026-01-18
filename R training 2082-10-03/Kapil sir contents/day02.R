
#-------------------------------------
# DAY 02
#-------------------------------------

# Where is your working directory?
getwd()

# set working directory
setwd('C:/Users/HP/Desktop/RTraining')


# load data csv

data_csv <- read.csv("sample.csv")


#load  stata datafile

install.packages("haven")  
library(haven)

data_dta <- read_dta("sample.dta")

# Convert ALL labelled columns to R factors at once
df_labelled <- as_factor(data_dta)

#count by district

df_labelled %>%
  count(dist, sort = TRUE) %>% 
  print(n=77)


# 01. table function : two-way table

table(df_labelled$q13,df_labelled$q09)

# Contingency table with margins (totals)
tab <- table(df_labelled$q13, df_labelled$q09)

# adding total
addmargins(tab)

#---------------------------

# proportion tables

prop.table(tab)
round(prop.table(tab),3)   # round value by 3 digits
round(prop.table(tab),3)*100

# row prop

prop.table(tab)
round(prop.table(tab,1),3)   # round value by 3 digits
round(prop.table(tab,1),3)*100


# col prop

prop.table(tab)
round(prop.table(tab,2),3)   # round value by 3 digits
round(prop.table(tab,2),3)*100

#---------------------------

# table function : three-way table

tab3 <- table(df_labelled$q13,df_labelled$q09,df_labelled$ecobelt )
ftable(tab3)



#Alternative
#---------------------

library(dplyr)
library(tidyr)

ctab_df <- as.data.frame(table(df_labelled$q09, df_labelled$q17))
names(ctab_df) <- c("Gender", "Response", "Freq")

# Convert to wide format
ctab_wide <- ctab_df %>%
  pivot_wider(names_from = Response, values_from = Freq)

ctab_wide
#---------------------------------------


#----------------------------
# 3. using xtabs
#----------------------------

tab2 <- xtabs(~q09+q17, data = df_labelled)  # two variables 
tab2 
ftable(tab2)

# Row percentages
tab2_row <- round(prop.table(tab2, margin = 1) * 100, 1)
ftable(tab2_row)

# col percentages
tab2_col <- round(prop.table(tab2, margin = 2) * 100, 1)
ftable(tab2_col)

# three-way table

tab3 <- xtabs(~ urbrur + q09 + q17 , data = df_labelled) # three-way table
ftable(tab3)

tab3 <- xtabs(~ q17 + urbrur + q09, data = df_labelled)
ftable(tab3)

tab3_pop <- prop.table(tab3, margin = c(1, 3)) # keep 1 and 3 fixed , Percentages are calculated within Urban and Rural)
ftable(tab3_pop)

tab3_pop_r <- round(prop.table(tab3, margin = c(1, 3))*100,2)
ftable(tab3_pop_r)


# conditional tables
#---------------------------

# table for only Male

#filter data for male
data_filter <- df_labelled %>%
  filter(q13 == "married")

# make table
tab_filter <- xtabs(~ q17 + urbrur + q09, data = data_filter)
ftable(tab_filter)

# piped
tabl <- df_labelled %>%
  filter(q13 == "married") %>%
  xtabs(~ q17 + urbrur + q09, data = .) %>%
  ftable()
print(tabl)






# Export to xlsx

install.packages("openxlsx")  
library(openxlsx)


tabl_df <- as.data.frame.matrix(tabl)

write.xlsx(tabl_df, "married_crosstab.xlsx", rowNames = TRUE)

## Differently

df_labelled <- df_labelled %>%
  mutate(
    q17 = as_factor(q17),
    urbrur = as_factor(urbrur),
    q09 = as_factor(q09)
  )

# Create table
tabl <- df_labelled %>%
  filter(q13 == "married") %>%
  xtabs(~ q17 + urbrur + q09, data = .) %>%
  ftable() %>% 
  as.data.frame()

# Export to Excel
write.xlsx(tabl, "table_export.xlsx", rowNames = FALSE)


# Create table 
tabl_df <- df_labelled %>%
  xtabs(~ q17 + urbrur, data = .) %>%
  ftable() %>%
  as.data.frame()

# Optional: add row percentages
tabl_df <- tabl_df %>%
  group_by(q17) %>%
  mutate(row_prc = Freq / sum(Freq) * 100)

# Export to CSV
write.csv(tabl_df, "table_export.csv", row.names = FALSE)




# Additional tables

install.packages("sjPlot")
library(sjPlot)


#tab_xtab(RowVar, ColumVar,  title,   show.row.prc = TRUE/FALSE

tab <- tab_xtab(
  df_labelled$q17,      # row variable
  df_labelled$urbrur,   # column variable
  title = "Table Name", # table title
  show.row.prc = TRUE   # show row percentages
)


#Using janitor
#----------------------------------

install.packages("janitor")
install.packages("openxlsx")   # run once
library(janitor)
library(dplyr)
library(openxlsx) 


tab_jan <- df_labelled %>%
  tabyl(q17, urbrur) %>%
  adorn_totals("row") %>%
  adorn_percentages("row") %>%
  adorn_pct_formatting(digits = 1) %>%
  adorn_ns() %>%
  as.data.frame()   # ← parentheses added

write.xlsx(tab_jan, "q17_by_urbrur.xlsx", rowNames = FALSE)

# for three or column add variable
