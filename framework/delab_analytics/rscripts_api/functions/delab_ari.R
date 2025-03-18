source_python("./functions/ari.py")

library("foreach")
library("reticulate")


delab_ari <- function(texts) {
  # Stop if only 1 post is provided
  if (length(texts) <= 1) {    
    stop("number of observations too low: at least two posts need to be provided!")
  }

  texts <- tail(texts, 2)
  
  ari <- argument_relation_identification(texts)
  

  df <- data.frame(texts = texts)
  df[, c("no_relation", "inference", "conflict", "rephrase")] <- rbind(NA, ari[1:4])


  return(df)  
}