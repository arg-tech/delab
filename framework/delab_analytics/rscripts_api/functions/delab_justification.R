################################################
# split sentences using udpipe                 #
################################################

######################### packages
library("foreach")
library("reticulate")


######################### Python functions
source_python("./functions/delab_robertarg.py")


######################### function prediction arguments
get_arguments <- function(text){
  
  #call python function
  out <- arg_prediction(text)
  
  #return
  return(out)
  
}


######################### main function
delab_justification <- function(df){
  
  ######################### aggregate input text to sentences
  #aggregate sentences
  df_sentences <- aggregate(df, list(df$row_id, df$doc_id, df$paragraph_id, df$sentence_id), FUN=head, 1)
  df_sentences <- df_sentences[, c("row_id", "doc_id", "paragraph_id", "sentence_id", "sentence", "texts")]
  
  ######################### make predictions
  #use finetuned model
  df_arguments <- foreach(
    i = 1:nrow(df_sentences),
    .combine = 'rbind'
  ) %do% {
    c(df_sentences$row_id[i], df_sentences$doc_id[i], df_sentences$paragraph_id[i], df_sentences$sentence_id[i], arg_prediction(text = df_sentences$sentence[i]))
  }
  
  #make df
  df_arguments <- data.frame(df_arguments)
  row.names(df_arguments) <- NULL
  names(df_arguments) <- c("row_id", "doc_id", "paragraph_id", "sentence_id", "argpred_0", "argpred_1")
  
  #bind to sentences
  df_sentences <- merge(df_sentences, df_arguments, 
                        by = c("row_id", "doc_id", "paragraph_id", "sentence_id"))
  
  ######################### aggregation
  #documents
  df_docs <- aggregate(df_sentences,
                       list(df_sentences$row_id, df_sentences$doc_id),
                       FUN=head, 1)
  df_docs <- df_docs[, c("row_id", "doc_id", "texts")]
  
  #values
  df_values <- aggregate(cbind(df_sentences$argpred_0, df_sentences$argpred_1),
                         list(df_sentences$row_id, df_sentences$doc_id),
                         FUN=function(x) mean(x, na.rm = TRUE))
  names(df_values) <- c("row_id", "doc_id", "argpred_0", "argpred_1")
  
  #merge
  df_docs <- merge(df_docs, df_values, by = c("row_id", "doc_id"))
  
  ######################### aggregate to fit input format
  df_agg <- aggregate(df, list(df$row_id), FUN=head, 1)
  df_agg <- merge(df_agg, df_docs,
                  by = c("row_id", "doc_id", "texts"),
                  all.x = TRUE)
  
  df_agg <- df_agg[, c("texts",
                       "argpred_0", "argpred_1")]
  
  ######################### deviations
  df_agg$argpred_0_dev <- c(NA, diff(df_agg$argpred_0))
  df_agg$argpred_1_dev <- c(NA, diff(df_agg$argpred_1))
  
  ######################### response
  return(df_agg)
  
}
