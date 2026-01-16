library(haven)

get_url <- function(x) {
  return(paste0("https://github.com/tempgita/training/raw/refs/heads/master/R%20training%202082-10-03/data/",x))
}

read_stata(get_url('008-nlfs2.dta'))