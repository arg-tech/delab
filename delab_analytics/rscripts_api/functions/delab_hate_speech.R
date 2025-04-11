source_python("./functions/hate_speech.py")

library("foreach")
library("reticulate")


delab_hate_speech <- function(texts) {
  # Stop if only 1 post is provided
  if (length(texts) <= 1) {    
    stop("number of observations too low: at least two posts need to be provided!")
  }
  texts <- tail(texts, 2)
  
  hate_speech_values <- hate_speech(texts)


  # Create a data frame with results
  df <- data.frame(
    texts = texts,
    hate_speech = hate_speech_values
  )

  return(df)  
}