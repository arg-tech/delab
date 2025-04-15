################################################
# Training implicit arguments                  #
################################################

######################### packages
import os
import numpy as np
import torch
#from transformers import TrainingArguments, Trainer
from transformers import AutoTokenizer, BertForSequenceClassification, pipeline, AutoModelForSequenceClassification

######################### tokenizer
#tokenizer path
dirname = os.getcwd()
parentDirectory = os.path.dirname(dirname)
pathTokenizer_topics = os.path.join(parentDirectory, "models/hateBERT")

######################### model
#model path
pathModel_topics = os.path.join(parentDirectory, "models/hateBERT")

def hate_speech_detection(classifier, tokenizer, model, device, text):
  # arg = tokenizer(text, return_tensors="pt", padding=True, truncation=True, max_length=512)
  # arg.to(device)

  # logits = model(**arg).logits.detach().cpu()

  # flat_logits = np.argmax(logits, axis=1)
  # print(flat_logits.shape)
  # print(flat_logits)
  # prediction = torch.argmax(logits, dim=1).item()
  # print(flat_logits)

  res = classifier(text)

  print(res)

  return res

def hate_speech(texts):
  device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

  # tokenizer = AutoTokenizer.from_pretrained(pathTokenizer_topics)
  # model = BertForSequenceClassification.from_pretrained(pathModel_topics, output_hidden_states=False, output_attentions=False)


  # tokenizer = AutoTokenizer.from_pretrained("GroNLP/hateBERT")
  # model = AutoModelForSequenceClassification.from_pretrained("GroNLP/hateBERT")
  classifier = pipeline("text-classification", model="GroNLP/hateBERT", device=device)

  # model.to(device) 
  # model.eval()

  return [hate_speech_detection(classifier, None, None, device, text) for text in texts]