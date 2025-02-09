#-------------------------------
#creating a dataframe
#-------------------------------
id <- c(1,2,3,4)
age <- c(25,34,28,52)
sex <- c(0,1,1,0) #0 - female, 1 - male
diabetes <- c("Type1", "Type2", "Type2", "Type1")
status <- c("Poor", "Improved", "Excellent", "Poor")

df <- data.frame(id, age, sex, diabetes, status)
df

#-------------------------------
#accessing a column
#-------------------------------
df[,2] #accessing the column values by index
df$age #accessing the column values by name
df["age"] #accessing the column by name

#-------------------------------
#accessing a multiple columns
#-------------------------------
df[,c(1,3,4)] #accessing the columns by index
df[c("id","status")] #accessing the columns by name

#-------------------------------
#creating a frequency twoway table
#-------------------------------
table(df$diabetes, df$status)

#-------------------------------
#Converting sex column to a factor (categorical) type
#-------------------------------
df$sex <- factor(df$sex, levels = c(1,0), labels = c("Male", "Female"))
df$diabetes <- factor(df$diabetes)

df
df$sex
df$diabetes

#-------------------------------
# Variable labeling
#-------------------------------
attr(df$id, "label") <- "Patient ID"
attr(df$age, "label") <- "Patient Age in years"
attr(df$sex, "label") <- "Patient sex"
View(df)

#removing a label
attr(df$sex, "label") <- NULL
View(df)
