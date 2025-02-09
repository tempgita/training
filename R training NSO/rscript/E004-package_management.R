#installing a package
install.packages('plotly')

#loading a package
library(plotly)

#printing package information
packageDescription('plotly')
help(package = 'plotly')

#using the loaded package
plot_ly(x = 2001:2020, y = (1:20)^2, type = 'bar')

#removing a package
remove.packages('plotly')
