source_python("./functions/self_contradiction.py")

library("foreach")
library("reticulate")


delab_self_contradiction <- function(texts) {
  # Stop if only 1 post is provided
  if (length(texts) <= 1) {    
    stop("number of observations too low: at least two posts need to be provided!")
  }
  
  self_contradiction <- self_contradiction(texts)

  texts <- tail(texts, 2)

  # Create a data frame with results
  df <- data.frame(
    texts = unname(sapply(texts, function(x) strsplit(x, ";;")[[1]][2])),
    self_contradiction = self_contradiction
  )

  return(df)  
}