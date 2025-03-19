source_python("./functions/discourse_markers.py")

library("foreach")
library("reticulate")


delab_discourse_markers <- function(texts) {
  # Stop if only 1 post is provided
  if (length(texts) <= 1) {    
    stop("number of observations too low: at least two posts need to be provided!")
  }
  
  # Keep only last two posts
  texts <- tail(texts, 2)

  # Apply count_discourse_markers directly
  discourse_counts <- sapply(texts, count_discourse_markers)

  # Create a data frame with results
  df_discourse <- data.frame(
    texts = texts,
    discourse_markers_count = discourse_counts
  )

  return(df_discourse)  
}