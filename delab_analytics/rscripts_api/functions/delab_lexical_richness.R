source_python("./functions/lexical_richness.py")



######################### main function
delab_lexical_richness <- function(texts){
    # Stop if only 1 post is provided
  if (length(texts) <= 1) {    
    stop("number of observations too low: at least two posts need to be provided!")
  }
  
  # Keep only last two posts
  texts <- tail(texts, 2)

  # Apply count_discourse_markers directly
  lexical_reachness <- sapply(texts, calculate_lex_richness_MTLD2)

  # Create a data frame with results
  df <- data.frame(
    texts = texts,
    lexical_reachness = lexical_reachness
  )

  return(df)    
}