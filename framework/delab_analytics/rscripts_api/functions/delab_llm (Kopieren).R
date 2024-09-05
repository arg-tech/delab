################################################
# Precict llm intervention probability         #
################################################


######################### packages
library("reticulate")


######################### function prediction sentiments
get_llmprob <- function(text){
  
  #path to local model
  path_to_model <- "./models/ggml_llava-v1.5-7b/ggml-model-f16.gguf"
  
  #call Python transformers pipeline
  llama <- reticulate::import("llama_cpp")
  
  possibleError <- tryCatch(
    llm_model <- llama$Llama(model_path = path_to_model,
                             n_gpu_layers = 1L,
                             chat_format = "chatml"),
    error = function(e) e
  )
  if (inherits(possibleError, "error")){
    
    llm_model <- llama$Llama$from_pretrained(
      repo_id="Qwen/Qwen1.5-0.5B-Chat-GGUF",
      filename="*q8_0.gguf",
      verbose=False
    )
    
  }
  
  #JSON scheme format
  llm_model$create_chat_completion(
    messages = list(dict(role = "system", 
                         content = "You are a helpful assistant."), 
                    dict(role = "user", 
                         content = "Who won the world series in 2019?")), 
    response_format = dict(type = "json_object"), 
    temperature = 0.7
  )
  
}