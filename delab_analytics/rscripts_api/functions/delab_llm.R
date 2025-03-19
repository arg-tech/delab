################################################
# Precict llm intervention probability         #
################################################


######################### packages
library("reticulate")
library("httr2")
library("jsonlite")
library("stringr")
library("purrr")


######################### function
delab_llm <- function(texts){
  
  ######################### prompt
  #build prompt
  system_content <- "Your are a social media moderator. Your role is to help participants in fostering a constructive and inclusive discussions." 
  user_content <- "Given the provided conversation, formulate a helpful response. Do not address users directly. Keep your moderation intervention as brief as possible."
  user_content <- str_c(user_content, "\n\nThe conversation is:\n", 
                        str_c(texts, collapse = "\n"), 
                        "\n</conversation>")
  #cat(user_content)
  
  model <- "gpt-3.5-turbo"
  prompt_1 <- list(role = "system", 
                   content = system_content)
  prompt_2 <- list(role = "user", 
                   content = user_content)
  prompt <- list(model = model, 
                 messages = list(prompt_1, prompt_2))
  
  ######################### API request
  #make request
  url <- request('http://delab_llm:8000/')
  
  req <- url |>
    req_url_path_append("v1/chat/completions") |>
    req_body_json(list(model = model, 
                       messages = list(prompt_1, prompt_2)))
  
  #test request, if required
  # req |>
  #   req_dry_run()
  
  #actual request
  current_request <- req |>
    req_perform()
  
  #extract data
  current_raw <- current_request |>
    resp_body_json() |> 
    pluck("choices") |>
    pluck(1) |> 
    pluck("message") |> 
    pluck("content")
  
  return(current_raw)
  
}
