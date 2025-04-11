################################################
# Training implicit arguments                  #
################################################

######################### packages
import os
import torch
#from transformers import TrainingArguments, Trainer
from transformers import AutoTokenizer, AutoModelForSequenceClassification

######################### tokenizer
#tokenizer path
dirname = os.getcwd()
parentDirectory = os.path.dirname(dirname)
pathTokenizer_topics = os.path.join(parentDirectory, "models/hateBERT")

######################### model
#model path
pathModel_topics = os.path.join(parentDirectory, "models/hateBERT")

def hate_speech_detection(tokenizer, model, device, text):
  arg = tokenizer(text, return_tensors="pt", padding=True, truncation=True, max_length=512)
  arg.to(device)

  logits = model(**arg).logits.detach().cpu()
  prediction = torch.argmax(logits, dim=1).item()

  return prediction

def hate_speech(texts):
  device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

  tokenizer = AutoTokenizer.from_pretrained(pathTokenizer_topics)
  model = AutoModelForSequenceClassification.from_pretrained(pathModel_topics, num_labels=2, output_hidden_states=False, output_attentions=False)
    
  model.to(device) 
  model.eval()

  return [hate_speech_detection(tokenizer, model, device, text) for text in texts]