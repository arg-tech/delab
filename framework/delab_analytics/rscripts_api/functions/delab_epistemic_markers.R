source_python("./functions/epistemic_markers.py")



######################### main function
delab_epistemic_markers <- function(texts){
    # Stop if only 1 post is provided
  if (length(texts) <= 1) {    
    stop("number of observations too low: at least two posts need to be provided!")
  }
  
  # Keep only last two posts
  texts <- tail(texts, 2)

  # Apply count_discourse_markers directly
  epistemic_counts <- sapply(texts, find_epistemic_markers)

  # Create a data frame with results
  df <- data.frame(
    texts = texts,
    epistemic_markers_count = epistemic_counts
  )

  return(df)  
}