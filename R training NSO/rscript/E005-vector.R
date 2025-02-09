a <- c(11,22,33,44,55)
b <- c('one','two','three')
c <- c(TRUE, FALSE, FALSE)

#accessing vector elements
a[4]
b[c(1,3)]
a[3:5]

#modifying an element
a[1] <- 99
a

#removing an object
rm(a)
