age_classify <- function(age) {
  if (age <= 20) {
    age_type <- 'Teen'
  } else if (age <=60) {
    age_type <- 'Adult'
  } else {
    age_type <- 'Old'
  }
  return(age_type)
}


age_classify(15)
age_classify(35)
age_classify(85)
