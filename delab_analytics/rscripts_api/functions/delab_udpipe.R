################################################
# split sentences using udpipe                 #
################################################

######################### packages
library("udpipe")
library("plyr")
library("cld2")

######################### function
#uses udpipe nlp pipeline
delab_udpipe <- function(texts){
  
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
  
  ######################### guess language (if missing)
  df$language <- detect_language(df$text)
  
  ######################### separate languages
  df_en <- df[df$language == "en" & !is.na(df$language),]
  df_de <- df[df$language == "de" & !is.na(df$language),]
  df_other <- df[(df$language != "en" & df$language != "de") | is.na(df$language), ]
  df_other$sentence <- df_other$texts
  
  ######################### annotate ENGLISH 
  if (nrow(df_en) >= 1){
    
    #load udpipe model
    udmodel_en <- udpipe_load_model(file = "./../models/udpipe/english-ewt-ud-2.5-191206.udpipe")
    
    #annotate
    df_en_anno <- udpipe_annotate(udmodel_en, x = df_en$text)
    df_en_anno <- as.data.frame(df_en_anno)
    
    #join with original data
    df_en_anno$doc_id <- gsub("doc", "", df_en_anno$doc_id)
    df_en_anno$doc_id <- as.numeric(df_en_anno$doc_id)
    
    df_en$doc_id <- seq_len(nrow(df_en))
    
    df_en_anno <- merge(df_en_anno, df_en, by = "doc_id")
    
    #some annotated instances are combined, e.g. "in dem" -> "im"
    df_en_anno <- df_en_anno[!grepl("-", df_en_anno$token_id),]
    
    #order
    df_en_anno$paragraph_id <- as.numeric(df_en_anno$paragraph_id)
    df_en_anno$sentence_id <- as.numeric(df_en_anno$sentence_id)
    df_en_anno$token_id <- as.numeric(df_en_anno$token_id)
    
    df_en_anno <- df_en_anno[order(df_en_anno$doc_id, df_en_anno$paragraph_id, df_en_anno$sentence_id, df_en_anno$token_id),]
    
  }
  
  ######################### annotate GERMAN 
  if (nrow(df_de) >= 1){
    
    #load udpipe model
    udmodel_de <- udpipe_load_model(file = "./../models/udpipe/german-gsd-ud-2.5-191206.udpipe")
    
    #annotate
    df_de_anno <- udpipe_annotate(udmodel_de, x = df_de$text)
    df_de_anno <- as.data.frame(df_de_anno)
    
    #join with original data
    df_de_anno$doc_id <- gsub("doc", "", df_de_anno$doc_id)
    df_de_anno$doc_id <- as.numeric(df_de_anno$doc_id)
    
    df_de$doc_id <- seq_len(nrow(df_de))
    
    df_de_anno <- merge(df_de_anno, df_de, by = "doc_id")
    
    #some annotated instances are combined, e.g. "in dem" -> "im"
    df_de_anno <- df_de_anno[!grepl("-", df_de_anno$token_id),]
    
    #order
    df_de_anno$paragraph_id <- as.numeric(df_de_anno$paragraph_id)
    df_de_anno$sentence_id <- as.numeric(df_de_anno$sentence_id)
    df_de_anno$token_id <- as.numeric(df_de_anno$token_id)
    
    df_de_anno <- df_de_anno[order(df_de_anno$doc_id, df_de_anno$paragraph_id, df_de_anno$sentence_id, df_de_anno$token_id),]
    
  }
  
  ######################### create missing datasets
  #de
  if (!exists("df_de_anno")){
    df_de_anno <- data.frame(
      doc_id = 1,
      paragraph_id = 1,
      sentence_id = 1,
      token_id = 1
    )
  }
  
  #en
  if (!exists("df_en_anno")){
    df_en_anno <- data.frame(
      doc_id = 1,
      paragraph_id = 1,
      sentence_id = 1,
      token_id = 1
    )
  }
  
  #other
  if (!exists("df_other")){
    df_other <- ata.frame(
      doc_id = 1,
      paragraph_id = 1,
      sentence_id = 1,
      token_id = 1
    )
  }
  
  ######################### bind data
  df_anno <- plyr::rbind.fill(df_de_anno, df_en_anno)
  df_anno <- df_anno[!is.na(df_anno$row_id),]
  df_anno <- plyr::rbind.fill(df_anno, df_other)
  df_anno <- df_anno[!is.na(df_anno$row_id),]
  
  ########################## fill missing values
  #missing values come from non-processed languages
  df_anno$doc_id[is.na(df_anno$doc_id)] <- 1
  df_anno$paragraph_id[is.na(df_anno$paragraph_id)] <- 1
  df_anno$sentence_id[is.na(df_anno$sentence_id)] <- 1
  df_anno$token_id[is.na(df_anno$token_id)] <- 1
  
  ########################## move row_id and order data
  df_anno <- df_anno[,c(which(colnames(df_anno)=="row_id"),which(colnames(df_anno)!="row_id"))]
  df_anno <- df_anno[order(df_anno$row_id, df_anno$doc_id, df_anno$paragraph_id, df_anno$sentence_id, df_anno$token_id), ]
  
  ########################## return (non)processed data
  return(df_anno)
  
}
