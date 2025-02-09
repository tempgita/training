energy_summary <- energy_np_in %>% 
  na.omit() %>% 
  group_by(country) %>% 
  summarize(max = max(ren_ele_share), 
            min = min(ren_ele_share), 
            mean = mean(ren_ele_share))

View(energy_summary)
