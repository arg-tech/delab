################################################
# Defining DeLab Analytics API Services        #
################################################


######################### description
#this script uses plumber to set up the services
#services are categorized as
# A. test service
# B. analytics services
#    a. sentiment
#    b. justification
#    c. topic cosine
# C. ml prediction inference
# D. llm services


######################### header
#* @apiTitle DeLab Services
#* @apiDescription Deliberation Laboratory Services, funded by VolkswagenStiftung
#* @apiTOS https://delab.uni-goettingen.de/
#* @apiLicense list(name = "Apache 2.0", url = "https://www.apache.org/licenses/LICENSE-2.0.html")
#* @apiVersion 0.1


######################### packages
#libraries are loaded at functions


############################ functions
#functions only become active when called


######################### A. TEST SERVICE
#* Return status of API
#* @tag status
#* @get /alive
#* @serializer json
function(){
  "Hello world! I am alive."
}


#* Return input texts as-is
#* @post /input
#* @serializer json
function(texts = ""){
  return(texts)
}


######################### B. ANALYTICS
#* Return analytics values
#* @tag analytics
#* @post /analytics
#* @params analytics The specific analytics, either sentiment, justification, cosine, all (default)
#* @serializer json
function(texts = "", analytics = "all"){

  texts_with_ids <- texts
  texts <- unname(sapply(texts, function(x) strsplit(x, ";;")[[1]][2]))

  #store order of texts
  texts_df <- data.frame(texts)
  texts_df$row_id <- seq(1, length(texts))

  print("Starting analysis...")
  

  #------------------get sentiments
  if (analytics == "sentiment" || analytics == "all"){
    
    source_python("./functions/sentiment.py")
    sent <- delab_sentiment_py(texts)

    #sequence of rows
    out_sent <- merge(sent, texts_df, by = c("texts"))
    out_sent <- out_sent[order(out_sent$row_id),]
    
    out_analytics <- out_sent

    print("Finished analysis of sentiment.")
  }

  #------------------get justification
  if (analytics == "justification" || analytics == "all"){
    
    source("./functions/delab_udpipe.R")
    out_udpipe <- delab_udpipe(texts)

    source("./functions/delab_justification.R")
    just <- delab_justification(out_udpipe)
    
    #sequence of rows
    out_just <- merge(just, texts_df, by = c("texts"))
    out_just <- out_just[order(out_just$row_id),]

    out_analytics = out_just

    print("Finished analysis of justification.")
  }

  #------------------get cosine
  if (analytics == "cosine" || analytics == "all"){
    
    source_python("./functions/embeddings.py")
    out_embeddings <- delab_embeddings_py(texts)

    source("./functions/delab_cosine.R")
    cosine <- delab_cosine(out_embeddings)
    
    #sequence of rows
    out_cosine <- merge(cosine, texts_df, by = c("texts"))
    out_cosine <- out_cosine[order(out_cosine$row_id),]

    out_analytics = out_cosine

    print("Finished analysis of cosine.")
  }

  #get discourse markers
  if (analytics == "discourse_markers" || analytics == "all"){
    source("./functions/delab_discourse_markers.R")
    discourse <- delab_discourse_markers(texts)
    
    out_discourse <- merge(discourse, texts_df, by = c("texts"))
    out_discourse <- out_discourse[order(out_discourse$row_id),]
    
    out_analytics = out_discourse

    print("Finished analysis of discourse markers.")
  }

  if (analytics == "epistemic_markers" || analytics == "all"){
    source("./functions/delab_epistemic_markers.R")
    epistemic <- delab_epistemic_markers(texts)
    
    out_epistemic <- merge(epistemic, texts_df, by = c("texts"))
    out_epistemic <- out_epistemic[order(out_epistemic$row_id),]
    
    out_analytics = out_epistemic

    print("Finished analysis of epistemic markers.")
  }

  if (analytics == "lexical_richness" || analytics == "all"){
    source("./functions/delab_lexical_richness.R")
    lexical <- delab_lexical_richness(texts)
    
    out_lexical <- merge(lexical, texts_df, by = c("texts"))
    out_lexical <- out_lexical[order(out_lexical$row_id),]
    
    out_analytics = out_lexical

    print("Finished analysis of lexical richness.")
  }

  if (analytics == "sentence_complexity" || analytics == "all"){
    source("./functions/delab_sentence_complexity.R")
    sentence_complexity <- delab_sentence_complexity(texts)
    
    out_sentence_complexity <- merge(sentence_complexity, texts_df, by = c("texts"))
    out_sentence_complexity <- out_sentence_complexity[order(out_sentence_complexity$row_id),]
    
    out_analytics = out_sentence_complexity

    print("Finished analysis of sentence complexity.")
  }

  if (analytics == "self_contradiction" || analytics == "all"){
    source("./functions/delab_self_contradiction.R")
    self_contradiction <- delab_self_contradiction(texts_with_ids)
    
    out_self_contradiction <- merge(self_contradiction, texts_df, by = c("texts"))
    out_self_contradiction <- out_self_contradiction[order(out_self_contradiction$row_id),]
    
    out_analytics = out_self_contradiction

    print("Finished analysis of self-contradiction.")
  }

  if (analytics == "ari" || analytics == "all"){
    source("./functions/delab_ari.R")
    ari <- delab_ari(texts)

    out_ari <- merge(ari, texts_df, by = c("texts"))
    out_ari <- out_ari[order(out_ari$row_id),]

    out_analytics = out_ari

    print("Finished analysis of argument relation identification.")
  }

  #------------------all
  if (analytics == "all"){
    df_list <- list(sent, just, cosine, discourse, epistemic, lexical, sentence_complexity, self_contradiction, ari, texts_df)
    # print(df_list)

    out_analytics <- Reduce(function(x, y) merge(x, y, by = "texts"), df_list)
    
    out_analytics <- out_analytics[order(out_analytics$row_id),]
  }

  library(reticulate)
  torch <- import("torch")

  if (torch$cuda$is_available()){
    torch$cuda$empty_cache()
    torch$cuda$ipc_collect()
  }


  #response
  list(df = out_analytics)
}


######################### C. INFERENCE
#* Return intervention probability
#* @tag inference
#* @post /inference
#* @serializer json
function(texts = ""){

  #store order of texts
  texts_df <- data.frame(texts)
  texts_df$row_id <- seq(1, length(texts))
  
  #get sentiment
  source("./functions/delab_sentiment.R")
  out_sent <- delab_sentiment(texts)
  print("Finished analysis of sentiment.")

  #get justification
  source("./functions/delab_udpipe.R")
  out_udpipe <- delab_udpipe(texts)

  source("./functions/delab_justification.R")
  out_just <- delab_justification(out_udpipe)
  print("Finished analysis of justification.")

  #get cosine
  source("./functions/delab_embeddings_tf.R")
  out_embeddings <- delab_embeddings(texts)

  source("./functions/delab_cosine.R")
  out_cosine <- delab_cosine(out_embeddings)
  print("Finished analysis of cosine.")

  #merge
  out_one <- merge(out_sent, out_just, by = c("texts"))
  out_two <- merge(out_one, out_cosine, by = c("texts"))
  
  #sequence of rows
  out_two <- merge(out_two, texts_df, by = c("texts"))
  out_two <- out_two[order(out_two$row_id),]
  
  #inference
  source("./functions/delab_inference.R")
  out_inference <- delab_inference(out_two)

  library(reticulate)
  torch <- import("torch")

  if (torch$cuda$is_available()){
    torch$cuda$empty_cache()
    torch$cuda$ipc_collect()
  }
  

  #response
  list(df = out_inference)
}


######################### D. LLM
#* Return llm intervention
#* @tag llm
#* @post /llm
#* @serializer json
function(texts = ""){

  #store order of texts
  texts_df <- data.frame(texts)
  texts_df$row_id <- seq(1, length(texts))
  
  #get sentiment
  source("./functions/delab_sentiment.R")
  out_sent <- delab_sentiment(texts)
  print("Finished analysis of sentiment.")

  #get justification
  source("./functions/delab_udpipe.R")
  out_udpipe <- delab_udpipe(texts)

  source("./functions/delab_justification.R")
  out_just <- delab_justification(out_udpipe)
  print("Finished analysis of justification.")

  #get cosine
  source("./functions/delab_embeddings_tf.R")
  out_embeddings <- delab_embeddings(texts)

  source("./functions/delab_cosine.R")
  out_cosine <- delab_cosine(out_embeddings)
  print("Finished analysis of cosine.")

  #merge
  out_one <- merge(out_sent, out_just, by = c("texts"))
  out_two <- merge(out_one, out_cosine, by = c("texts"))
  
  #sequence of rows
  out_two <- merge(out_two, texts_df, by = c("texts"))
  out_two <- out_two[order(out_two$row_id),]
  
  #inference
  # source("./functions/delab_inference.R")
  # out_inference <- delab_inference(out_two)
  # print("Finished prediction inference.")

  print("Inference prediction dummy is used. LLM response is always generated.")
  prob_intervention <- 0.9

  #check if user provides intervention threshold
  if (Sys.getenv("INTERVENTION_THRESHOLD") == ""){
    intervention_thresh <- .5
    intervention_thresh <- as.numeric(intervention_thresh)
  } else {
    intervention_thresh <- Sys.getenv("INTERVENTION_THRESHOLD")
    intervention_thresh <- as.numeric(intervention_thresh)
  }

  #stop if intervention threshold is larger than intervention probability
  if (intervention_thresh > prob_intervention){

    if(Sys.getenv("INTERVENTION_THRESHOLD") == ""){
      out_llm <- str_c("The inferred intervention probability ", prob_intervention,
                       "\nis smaller than the pre-defined threshold of .5",
                       ".\nHence, no intervention is generated by the LLM.")
      print("No llm response is generated.")
    } else {
      out_llm <- str_c("The inferred intervention probability ", prob_intervention, 
                       "\nis smaller than the user given threshold of ", intervention_thresh,
                       ".\nHence, no intervention is generated by the LLM.")
      print("No llm response is generated.")
    }
  } else {

    #run llm service
    source("./functions/delab_llm.R")
    out_llm <- delab_llm(texts)
    print(str_c("Finished llm response generation. The inferred intervention probability is ", prob_intervention, "."))
  }

  library(reticulate)
  torch <- import("torch")

  if (torch$cuda$is_available()){
    torch$cuda$empty_cache()
    torch$cuda$ipc_collect()
  }

  #response
  list(df = data.frame(out_llm), intervention_prob = prob_intervention, features = out_two)
}