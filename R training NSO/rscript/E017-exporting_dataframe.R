#----------------------------------------------------------------------
# Exporting dataframe to a csv file
#----------------------------------------------------------------------
write.csv(fsize, file = 'fsize.csv', row.names = F)

#----------------------------------------------------------------------
# Exporting dataframe to a excel file
#----------------------------------------------------------------------
library(openxlsx)
write.xlsx(fsize, file = "fsize.xlsx")

#----------------------------------------------------------------------
# Exporting dataframe to a RData file
#----------------------------------------------------------------------
save(fsize, file = 'fsize.RData')
load('fsize.RData')

#----------------------------------------------------------------------
# Exporting dataframe to a dta (Stata) file
#----------------------------------------------------------------------
library(haven)
write_dta(fsize, path = 'fsize.dta')
