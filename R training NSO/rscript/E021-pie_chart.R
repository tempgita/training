if(!require(remotes)) install.packages("remotes")
remotes::install_github("rkabacoff/ggpie")

library(ggplot2)
library(ggpie)

#simple pie chart
ggpie(mpg, class)

# no legend and offset of labels from the pie chart
ggpie(mpg, class, legend=FALSE, offset=1.3,
      title="Automobiles by Car Class")

# group wise pie charts
ggpie(mpg, class, year,
      legend=FALSE, offset=1.3, title="Car Class by Year")
