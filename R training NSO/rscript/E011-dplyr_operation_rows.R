#---------------------------------------------------------------------
# Import datasets
#---------------------------------------------------------------------
classf <- read.csv('data/005-wb_class.csv')
energy <- read.csv('data/006-wb_energy.csv')
var_def <- read.csv('data/007-wb_energy_var_def.csv') #variable definition

#---------------------------------------------------------------------
# Rows operation
#---------------------------------------------------------------------
# *** filter ***
library(dplyr)
data_nepal <- filter(energy, country == 'Nepal')
data_nepal

filter(energy, country == 'Nepal' & year > 1999)

# *** arrange ***
arrange(energy, desc(country), tot_ele)

# *** na.omit ***
na.omit(energy)

# *** slice *** : used to choose rows using their position
slice(energy,3:7)

slice_head(energy, n = 3)
#OR
head(energy, n = 3)

slice_tail(energy, n = 3)
#OR
tail(energy, n = 3)

slice_sample(energy, n = 5) #randomly selects 5 observations (rows)
slice_sample(energy, prop = 0.01) #selects 1% sample randomly
slice_sample(energy, prop = 0.01, replace = T) #selects 1% sample randomly with replacement

