################################################
# get embeddings                               #
################################################

######################### packages
library("reticulate")
library("stringr")
library("dplyr")
#library("text")


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
  if(any(df$length >= 30)){
    
    #split
    df <- with(df, setNames(stack(setNames(str_split(texts, "(?<=[.!?])"), row_id))[1:2], names(df[1:2])))
    df <- df[df$texts!="",]
    
    #switch check to 1
    switch_length <- 1
  }
  
  ######################### get embeddings
  #path to local model
  path_to_model <- "./../models/twitter-xlm-roberta-base/"
  
  #call Python transformers pipeline
  transformers <- reticulate::import("transformers")

  torch <- reticulate::import("torch")
  device <- if (torch$cuda$is_available()) torch$device("cuda:0") else torch$device("cpu")
  
  #use pipeline
  pipe_embd <- transformers$pipeline(
    'feature-extraction', 
    framework="pt",
    device = device,
    model = path_to_model
  )
  
  #loop through all texts
  df_embeddings <- NULL
  
  r <- 1
  for (r in 1:nrow(df)){
    #get embeddings
    temp <- pipe_embd(df$texts[r])
    
    #get dims
    temp_cols = 768 #fixed to embd size
    temp_rows = length(temp[[1]])
    
    #reformat
    temp <- unlist(temp)
    temp <- matrix(temp, nrow = temp_rows, ncol = temp_cols, byrow = FALSE)
    temp <- as.data.frame(temp)
    
    #aggregate
    temp <- colMeans(temp, na.rm = TRUE)
    temp <- t(as.data.frame(temp))
    
    #bind data
    temp_df <- cbind(df[r,], temp)
    
    df_embeddings <- rbind(df_embeddings, temp_df)
  }
  
  #rename vars
  df_embeddings <- rename_with(df_embeddings, ~str_c("emb_", .x), starts_with("V"))
  
  
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