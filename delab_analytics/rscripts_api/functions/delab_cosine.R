################################################
# calculate cosine similarity                  #
################################################

######################### packages
library("lsa")
library("stringr")

######################### function
delab_cosine <- function(df){
  
  #keep only topic features
  df_topics <- df[str_detect(names(df), "emb_")]

  #topic vector 2
  topic_vector_2 <- unlist(df_topics[2,], use.names = FALSE)
  
  #topic vector previous
  topic_vector_prev <- unlist(df_topics[1,], use.names = FALSE)
  
  #cosine values
  cosine_prev <- lsa::cosine(topic_vector_2, topic_vector_prev)
  
  #bind data
  df_cosine <- data.frame(df[, c("texts")])
  df_cosine$cosine_prev <- c(NA, cosine_prev)
  names(df_cosine) <- c("texts", "cosine_prev")
  df_cosine <- data.frame(df_cosine)
  
  return(df_cosine)
  
}