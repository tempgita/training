#---------------------------------------------------------------------
# Columns operation
#---------------------------------------------------------------------
# *** select ***
select(energy, year, ccode, tot_ele) #selects year, ccode, and tot_ele
select(energy, year:ccode) #selects columns from year to ccode
select(energy, !(year:ccode)) #selects columns other than from year to ccode

head(select(energy, contains('tot'))) #selects columns with names that contains tot
head(select(energy, starts_with('ele'))) #selects columns with names that starts with ele
head(select(energy, ends_with('ele'))) #selects columns with names that ends with ele

# *** rename ***
head(rename(energy, year_AD = year))

# *** mutate ***
head(mutate(energy, ren_ele_share = ren_ele/tot_ele * 100))
