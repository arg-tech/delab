source_python("./functions/sentence_complexity.py")



######################### main function
delab_sentence_complexity <- function(texts){
    # Stop if only 1 post is provided
  if (length(texts) <= 1) {    
    stop("number of observations too low: at least two posts need to be provided!")
  }
  
  # Keep only last two posts
  texts <- tail(texts, 2)

  # Apply count_discourse_markers directly
  dependency_depth <- unname(sapply(texts, calculate_dep_length))
  dependency_score <- unname(sapply(texts, calculate_dep_score))

  # Create a data frame with results
  df <- data.frame(
    texts = texts,
    dependency_depth = dependency_depth,
    dependency_score = dependency_score
  )

  return(df)    
}