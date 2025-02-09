x <- c(1,2,3,4,5,6,7,8)

#creating a matrix (by default byrow == FALSE)
m1 <- matrix(x, nrow = 2, ncol = 4)
m1

#creating a matrix with byrow = TRUE
m2 <- matrix(x, nrow = 2, ncol = 4, byrow = TRUE)
m2
#--------------------------
#accessing elements of a matrix
#--------------------------
m2[1,] #selecting the first row
m2[,3] #selecting the third column
m2[2,c(3,4)] #selecting the 3rd and 4th element of the 2nd row

#--------------------------
#basic matrix operations
#--------------------------
m1 + m2 #addition
m1 - m2 #subtraction

t(m1) #transpose
t(m1) %*% m2 #matrix dot product

mm <- matrix(c(1,2,3,4), nrow = 2)
mm
det(mm) #determinant of a matrix
solve(mm) #inverse of a matrix
