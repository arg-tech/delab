################################################
# Precict sentiment values                     #
################################################


######################### packages
library("reticulate")
library("foreach")
library("stringr")


######################### function prediction sentiments
get_sentiments <- function(text) {

  #path to local model
  path_to_model <- "./../models/twitter-roberta-base-sentiment-latest"
  

  #call Python transformers pipeline
  transformers <- reticulate::import("transformers")

  # torch <- reticulate::import("torch")
  # device <- if (torch$cuda$is_available()) torch$device("cuda:0") else torch$device("cpu")

  pipe_sent <- transformers$pipeline("sentiment-analysis",
                                      model = path_to_model,
                                      # device = device,
                                      top_k = 3L)
  
  #apply pipeline
  out <- pipe_sent(text)
  
  #reformat output
  out <- unlist(out)
  out <- matrix(out, nrow = 2, ncol = 3, byrow = FALSE)
  out <- as.data.frame(out)
  names(out) <- paste0("sent_", out[1,])
  out <- out[2,]
  
  #make numeric
  out$sent_positive <- as.numeric(out$sent_positive)
  out$sent_neutral <- as.numeric(out$sent_neutral)
  out$sent_negative <- as.numeric(out$sent_negative)
  
  #return
  return(out)
}


#########################
delab_sentiment <- function(texts){
  
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
  
  #check length of text
  df$length <- str_count(df$text, "\\S+")
  
  #split in sentences if any text is longer than 200 words
  if(any(df$length >= 200)){
    
    #split
    df <- with(df, setNames(stack(setNames(str_split(texts, "(?<=[.!?])"), row_id))[1:2], names(df[1:2])))
    df <- df[df$texts!="",]
    
    #switch check to 1
    switch_length <- 1
  }
  
  ######################### get sentiment values
  #run specified function in parallel
  df_sentiments <- foreach(
    i = seq_len(nrow(df)),
    .combine = 'rbind'
  ) %do% {
    cbind(df[i,],
          get_sentiments(text = df$texts[i]))
  }
  
  ######################### aggregate
  if (switch_length == 1){
    
    values <- aggregate(df_sentiments[,-c(1,2)], by = list(df_sentiments$row_id), FUN = mean, na.rm = TRUE)
    texts <- aggregate(df_sentiments[,1], by = list(df_sentiments$row_id), FUN = str_c, collapse = "")
    df_sentiments <- merge(values, texts, by = "Group.1")
    names(df_sentiments)[names(df_sentiments)=="Group.1"] <- "row_id"
    names(df_sentiments)[names(df_sentiments)=="x"] <- "text"
    
    df_sentiments$row_id <- NULL
    
  } else {
    
    df_sentiments$row_id <- NULL
    df_sentiments$length <- NULL
    
  }
  
  ######################### deviations
  df_sentiments$sent_negative_dev <- c(NA, diff(df_sentiments$sent_negative))
  df_sentiments$sent_neutral_dev <- c(NA, diff(df_sentiments$sent_neutral))
  df_sentiments$sent_positive_dev <- c(NA, diff(df_sentiments$sent_positive))
  
  ######################### response
  return(df_sentiments)

}
