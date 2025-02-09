#-----------------------------------------------------------------
# importing csv data directly from the web
#-----------------------------------------------------------------
df <- read.csv("http://s.anilz.net/wb_energy")
head(df)

dx <- read.csv("https://data.ny.gov/api/views/d6yy-54nr/rows.csv")
head(dx)

#-----------------------------------------------------------------
# Using rvest package for static website scraping
#-----------------------------------------------------------------
#loading necessary packages
library(rvest) #see https://rvest.tidyverse.org/articles/harvesting-the-web.html for details
library(dplyr)

#loading webpage content
webpage <- read_html("https://www.sharesansar.com/today-share-price")

#extracting table from the webpage
tables <- html_table(webpage)

#checking the number of tables available in the webpage
length(tables)

df1 <- tables[[1]]
head(df1)

#filtering upper and lower circuit stock
filtered_df1 <- df1 %>% filter(`Diff %` > 9 | `Diff %`< -9) %>% arrange(`Diff %`)
filtered_df1

#*************************************
#*Obtaining Forex information from NRB
#*************************************
#loading webpage content
webpage <- read_html("https://www.nrb.org.np")

#extracting table from the webpage
tables <- html_table(webpage)

#checking the number of tables available in the webpage
length(tables)


df1 <- tables[[1]]
df2 <- tables[[2]]

df1
df2

#keeping USD and JPY only
filtered_df1 <- df1 %>% filter(Currency=='USD' | Currency =='JPY')
filtered_df1