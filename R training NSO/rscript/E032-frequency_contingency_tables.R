Arthritis <- vcd::Arthritis

#simple frequency table
mytable <- table(Arthritis$Improved)
mytable

#proportion table
prop.table(mytable)
prop.table(mytable)*100 #in percentage

#-------------------------------------
# Two-way table
#-------------------------------------
mytable <- xtabs(~ Treatment + Improved, data=Arthritis)
mytable

#calculating sub-total horizontally
margin.table(mytable, 1) # 1 here refers 1st variable i.e. Treatment

#proportion table based on horizontal sub-total
prop.table(mytable, 1) * 100

# ***********************************************

#calculating sub-total vertically
margin.table(mytable, 2) # 2 here refers 2nd variable i.e. Improved

#proportion table based on vertical sub-total
prop.table(mytable, 2) * 100

#------------------------------------------------
# Two-way table (add sub-totals and grand totals)
#------------------------------------------------
addmargins(mytable)
addmargins(prop.table(mytable)) * 100

#proportion addmargins horizontally
addmargins(prop.table(mytable, 1), 2) * 100

#proportion addmargins vertically
addmargins(prop.table(mytable, 2), 1) * 100

#------------------------------------------------
# Multidimensional table
#------------------------------------------------
mytable <- xtabs(~ Treatment + Sex + Improved, data=Arthritis)
mytable

#frequency table
ftable(mytable)

#frequency table defining column variables
ftable(mytable, col.vars = c('Sex','Improved'))

#proportion table
prop.table(ftable(mytable, col.vars = c('Sex','Improved'))) * 100
