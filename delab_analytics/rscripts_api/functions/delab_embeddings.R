################################################
# get embeddings                               #
################################################

######################### packages
library("text")
library("stringr")
library("reticulate")
library("dplyr")

######################### function
delab_embeddings <- function(texts){
  
  ######################### make df
  df <- as.data.frame(texts)
  
  #stop if only 1 post is provided
  if (nrow(df) <= 1){
    
    stop("number of observations too low: at least two posts need to be provided!")
    
  }
  
  #add row_id
  df$row_id <- 1:nrow(df)
  
  #keep only last two posts
  df <- df[(nrow(df)-1):(nrow(df)), ]
  
  ######################### check length
  switch_length <- 0
  
  #split input if text is longer than 100 words
  df$length <- str_count(df$text, "\\S+")
  
  #split in sentences if any text is longer than 200 words
  if(any(df$length >= 100)){
    
    #split
    df <- with(df, setNames(stack(setNames(str_split(texts, "(?<=[.!?])"), row_id))[1:2], names(df[1:2])))
    df <- df[df$texts!="",]
    
    #switch check to 1
    switch_length <- 1
  }
  
  ######################### get embeddings
  df_embeddings <- textEmbed(texts = df$texts, 
                             model = "./../models/twitter-xlm-roberta-base/", 
                             aggregation_from_tokens_to_texts = "mean",
                             aggregation_from_tokens_to_word_types = "mean",
                             keep_token_embeddings = FALSE)
  
  #make df
  df_embeddings <- data.frame(df_embeddings[["texts"]][["texts"]])
  
  #rename vars
  df_embeddings <- rename_with(df_embeddings, ~str_c("emb_", .x), ends_with("_texts"))
  df_embeddings <- rename_with(df_embeddings, ~str_remove(.x, "_texts"))
  
  #bind texts
  df_embeddings <- cbind(df, df_embeddings)
  
  
  ######################### aggregate
  if (switch_length == 1){
    
    values <- aggregate(df_embeddings[,-c(1,2)], by = list(df_embeddings$row_id), FUN = mean, na.rm = TRUE)
    texts <- aggregate(df_embeddings[,1], by = list(df_embeddings$row_id), FUN = str_c, collapse = "")
    df_embeddings <- merge(texts, values, by = "Group.1")
    names(df_embeddings)[names(df_embeddings)=="Group.1"] <- "row_id"
    names(df_embeddings)[names(df_embeddings)=="x"] <- "texts"
    
  } else {
    
    #NULL
    
  }
  
  return(df_embeddings)
}