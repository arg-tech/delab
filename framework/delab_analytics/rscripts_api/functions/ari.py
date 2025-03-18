import os
os.environ["TF_ENABLE_ONEDNN_OPTS"]="0"

import sys
import torch
from transformers import AutoTokenizer, AutoModelForSequenceClassification


dirname = os.getcwd()
parentDirectory = os.path.dirname(dirname)

path = os.path.join(parentDirectory, "models/ArgumentMining-EN-ARI-AIF-RoBERTa_L")


def classify_post(input):
    tokenizer = AutoTokenizer.from_pretrained(path)
    tokenized_input = tokenizer(input[0], input[1],
                        padding="longest", truncation=True,
                        return_token_type_ids=True,
                        return_tensors="pt") 

    model = AutoModelForSequenceClassification.from_pretrained(
                                                                path, 
                                                                output_attentions = False,
                                                                output_hidden_states = False, 
                                                                )

    # try:
    #     device = torch.device("cuda") # try to load model to GPU
    # except:
    device = torch.device("cpu") # for stable running loading to CPU
                                    # in case of issues with cuda / no GPU
    
    model.to(device)
    model.eval()

    with torch.no_grad():
        tokenized_input.to(device) # make sure that input is loaded to the same device as the model
        input_ids = tokenized_input["input_ids"] # extract tokenized ids
        attention_mask = tokenized_input["attention_mask"] # extract attention mask

        # run prediction
        output = model(input_ids, 
                    token_type_ids=None, 
                    attention_mask=attention_mask)
        
        return output.logits.softmax(dim=1)[0].tolist()
        
def argument_relation_identification(input_posts):
    return classify_post(input_posts)
