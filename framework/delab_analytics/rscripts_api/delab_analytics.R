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
  
  #------------------get sentiments
  if (analytics == "sentiment"){
    
    source("./functions/delab_sentiment.R")
    out_sent <- delab_sentiment(texts)
    
    out_analytics <- out_sent
    
    print("Finished analysis of sentiment.")
  }
  
  #------------------get justification
  if (analytics == "justification"){
    
    source("./functions/delab_udpipe.R")
    out_udpipe <- delab_udpipe(texts)
    
    source("./functions/delab_justification.R")
    out_just <- delab_justification(out_udpipe)
    
    out_analytics = out_just
    
    print("Finished analysis of justification.")
  }
  
  #------------------get cosine
  if (analytics == "cosine"){
    
    source("./functions/delab_embeddings.R")
    out_embeddings <- delab_embeddings(texts)
    
    source("./functions/delab_cosine.R")
    out_cosine <- delab_cosine(out_embeddings)
    
    out_analytics = out_cosine
    
    print("Finished analysis of cosine.")
  }
  
  #------------------all
  if (analytics == "all"){
    
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
    source("./functions/delab_embeddings.R")
    out_embeddings <- delab_embeddings(texts)
    
    source("./functions/delab_cosine.R")
    out_cosine <- delab_cosine(out_embeddings)
    print("Finished analysis of cosine.")
    
    #merge
    out_one <- merge(out_sent, out_just, by = c("texts"))
    out_two <- merge(out_one, out_cosine, by = c("texts"))
    
    out_analytics <- out_two
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
  source("./functions/delab_embeddings.R")
  out_embeddings <- delab_embeddings(texts)
  
  source("./functions/delab_cosine.R")
  out_cosine <- delab_cosine(out_embeddings)
  print("Finished analysis of cosine.")
  
  #merge
  out_one <- merge(out_sent, out_just, by = c("texts"))
  out_two <- merge(out_one, out_cosine, by = c("texts"))
  
  #inference
  source("./functions/delab_inference.R")
  out_inference <- delab_inference(out_two)
  
  #response
  list(df = out_inference)
  
}


######################### D. LLM
#* Return llm intervention
#* @tag llm
#* @post /llm
#* @serializer json
function(texts = ""){
  
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
  source("./functions/delab_embeddings.R")
  out_embeddings <- delab_embeddings(texts)
  
  source("./functions/delab_cosine.R")
  out_cosine <- delab_cosine(out_embeddings)
  print("Finished analysis of cosine.")
  
  #merge
  out_one <- merge(out_sent, out_just, by = c("texts"))
  out_two <- merge(out_one, out_cosine, by = c("texts"))
  
  #inference
  source("./functions/delab_inference.R")
  out_inference <- delab_inference(out_two)
  print("Finished prediction inference.")

  #check if user provides intervention threshold
  if (Sys.getenv("INTERVENTION_THRESHOLD") == ""){
    intervention_thresh <- .5
  } else {
    intervention_thresh <- Sys.getenv("INTERVENTION_THRESHOLD")
  }
  
  #stop if intervention threshold is larger than intervention probability
  if (intervention_thresh > out_inference$prob_intervention){

    if(Sys.getenv("INTERVENTION_THRESHOLD") == ""){
      out_llm <- str_c("The inferred intervention probability\nis smaller than ",
                       "the user given threshold of ", intervention_thresh,
                       ".\nHence, no intervention is generated by the LLM.")
    } else {
      out_llm <- str_c("The inferred intervention probability\nis smaller than ",
                       "the pre-defined threshold of .5",
                       ".\nHence, no intervention is generated by the LLM.")
    }
  } else {
    
    #run llm service
    source("./functions/delab_llm.R")
    out_llm <- delab_llm(texts)
    
  }
  
  #response
  list(df = data.frame(out_llm))
  
}
