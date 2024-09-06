################################################
# calculate cosine similarity                  #
################################################

######################### packages
library("dplyr")
library("reticulate")
library("keras3")

######################### function
delab_inference <- function(df){
  
  #gen lagged df
  df <- df |> 
    mutate(#lag 2
           sent_negative_lag2 = lag(sent_negative, 1), 
           sent_positive_lag2 = lag(sent_positive, 1), 
           argpred_1_lag2 = lag(argpred_1, 1), 
           
           #lag 1
           sent_negative_lag1 = sent_negative, 
           sent_positive_lag1 = sent_positive, 
           argpred_1_lag1 = argpred_1, 
           cosine_prev_lag1 = cosine_prev, 
           
           sent_negative_dev_lag1 = sent_negative_dev, 
           sent_positive_dev_lag1 = sent_positive_dev, 
           argpred_1_dev_lag1 = argpred_1_dev, 
           cosine_prev_lag1 = cosine_prev) |> 
    slice(2) |> 
    ungroup() |> 
    select(ends_with("lag2"), 
           ends_with("lag1"))
  
  #convert df to dict
  input_dict <- lapply(df, \(x) op_convert_to_tensor(array(x)))
  
  #load model
  model_numfeats <- load_model("./../models/modpred/model_numfeats.keras")
  
  #make inference
  predictions <- model_numfeats |> predict(input_dict)
  
  #make df
  predictions <- as.data.frame(predictions)
  names(predictions) <- "prob_intervention"
  
  return(predictions)
}
