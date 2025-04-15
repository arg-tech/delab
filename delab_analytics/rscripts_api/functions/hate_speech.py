################################################
# Training implicit arguments                  #
################################################

######################### packages
import os
import numpy as np
import torch
from transformers import AutoTokenizer, BertForSequenceClassification, pipeline, AutoModelForSequenceClassification
from transformers import AutoTokenizer, AutoModelForSequenceClassification

######################### tokenizer
#tokenizer path
dirname = os.getcwd()
parentDirectory = os.path.dirname(dirname)
path_model = os.path.join(parentDirectory, "models/roberta-hate-speech")
# path_model = os.path.join(parentDirectory, "models/hateBERT")

def hate_speech_detection(tokenizer, model, device, text):
  arg = tokenizer(text, return_tensors="pt", padding=True, truncation=True, max_length=512)
  arg.to(device)

  logits = model(**arg).logits.detach().cpu()
  prediction = torch.argmax(logits, dim=1).item()

  return prediction 

def hate_speech(texts):
  device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

  tokenizer = AutoTokenizer.from_pretrained(path_model)
  model = AutoModelForSequenceClassification.from_pretrained(path_model)
  model.to(device) 
  model.eval()

  return [hate_speech_detection(tokenizer, model, device, text) for text in texts]