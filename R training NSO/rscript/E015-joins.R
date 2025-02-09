df1 <- data.frame(id = c(1, 2, 3), colA = c("A", "B", "C")) 
df2 <- data.frame(id = c(1, 3, 5), colB = c("X", "Y", "Z"))
print(df1)
print(df2)

inner_join(df1, df2, by = 'id') #Return rows with matching keys in both data frames
left_join(df1, df2, by = 'id') #Return all rows from first data frame, matching rows from second
right_join(df1, df2, by = 'id') #Return all rows from second data frame, matching rows from first
full_join(df1, df2, by = 'id') #Return all rows from both data frames, matching by keys
