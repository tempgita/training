energy_np_in <- energy %>% 
  select(year, country, ren_ele, tot_ele) %>% # Select columns year, country, ren_ele, tot_ele
  filter(country == 'Nepal' | country =='India') %>% # Keep data of Nepal and India only
  arrange(country, year) %>% # Sort the dataframe according to country and year columns
  mutate(ren_ele_share = ren_ele/tot_ele*100) # Create a new column ren_ele_share 
View(energy_np_in)
