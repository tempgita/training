g <- "My First List"
h <- c(25, 26, 18, 39)
j <- matrix(1:10, nrow=5)
k <- c("one", "two", "three")

mylist <- list(title=g, ages=h, j, k)
mylist

#-------------------------------
#accessing an object
#-------------------------------
mylist$title #by object name in the list
mylist[['ages']] #by object name in the list
mylist[[1]] #by index number
