#---------------------------------------------------------------------
# Importing data from a delimited text file (e.g. csv)
#---------------------------------------------------------------------
df1 <- read.table('data/001-Arthritis.csv', header = T, sep = ',')
# OR
df2 <- read.csv('data/001-Arthritis.csv')

# Checking data structure (variable types)
str(df1)

#---------------------------------------------------------------------
# Importing data from excel file
#---------------------------------------------------------------------
library(readxl) #install the package if not installed
df3 <- read_xlsx('data/002-excel_data.xlsx', sheet = 'Orange')
df4 <- read_xlsx('data/002-excel_data.xlsx', sheet = 'infert')

#---------------------------------------------------------------------
# Importing data from SPSS and Stata
#---------------------------------------------------------------------
library(haven)
df5 <- read_spss('data/003-mn.sav')
df6 <- read_stata('data/004-campus.dta')

#---------------------------------------------------------------------
# Importing files directly from the web
#---------------------------------------------------------------------
df7 <- read.csv('https://people.sc.fsu.edu/~jburkardt/data/csv/biostats.csv')

