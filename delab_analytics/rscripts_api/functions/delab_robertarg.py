################################################
# Training implicit arguments                  #
################################################

######################### packages
import os
#import numpy as np
#import pandas as pd
import torch
#from transformers import TrainingArguments, Trainer
from transformers import AutoTokenizer, AutoModelForSequenceClassification

######################### tokenizer
#tokenizer path
dirname = os.getcwd()
parentDirectory = os.path.dirname(dirname)
pathTokenizer_topics = os.path.join(parentDirectory, "models/twitter-xlm-roberta-base")

######################### model
#model path
pathFinetuned_topics = os.path.join(parentDirectory, "models/ -justification")

if os.path.exists(pathFinetuned_topics):
  pathModel_topics = pathFinetuned_topics
else:
  pathModel_topics = os.path.join(parentDirectory, "models/twitter-xlm-roberta-base")

#modelPath = os.path.join(parentDirectory, "models/roberta-argument")
model_topics = AutoModelForSequenceClassification.from_pretrained(pathModel_topics)

######################### function
def arg_prediction(text):
  device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

  tokenizer_topics = AutoTokenizer.from_pretrained(pathTokenizer_topics)

  arg = tokenizer_topics(text, return_tensors="pt", padding=True, truncation=True, max_length=512)
  arg.to(device)


  model = AutoModelForSequenceClassification.from_pretrained(pathFinetuned_topics)
    
  model.to(device) # load model to device
  model.eval() # set model to eval mode

  arg_classification_logits = model(**arg).logits
  arg_results = torch.softmax(arg_classification_logits, dim=1).tolist()[0]
  return arg_results
