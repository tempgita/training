nlfs2 <- nlfs2 %>% 
  mutate(family_size_group = case_when(family_size <= 2 ~ 'Small',
                                       family_size <= 4 ~ 'Medium',
                                       family_size >= 5 ~ 'Large')) %>%
  mutate(age_group = case_when(age <= 20 ~ 'Teen',
                               age <= 60 ~ 'Adult',
                               TRUE ~ 'Old')) %>%
  mutate(male = case_when(gender == 2 ~ 0,
                          gender == 1 ~ 1)) %>%
  mutate(male = factor(male, levels = c(1,0), labels = c('Male', 'Female')))