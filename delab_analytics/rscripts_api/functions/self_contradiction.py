import os
os.environ["TF_ENABLE_ONEDNN_OPTS"]="0"

import sys
import torch
from transformers import (AutoTokenizer,
                         DataCollatorWithPadding,
                         AutoModelForSequenceClassification,
                         get_linear_schedule_with_warmup)


dirname = os.getcwd()
parentDirectory = os.path.dirname(dirname)

tokenizer_path = os.path.join(parentDirectory, "models/self-contradiction/SelfContra-tokenizer")
model_checkpoint = os.path.join(parentDirectory, "models/self-contradiction/SelfContra-safetensors")

"""
Self-Contradiction Prediction Function
    -input: list of 2 input post strings (must be from the same speaker)
    -output: integer 1 for Self-Contradiction, 0 for no Self-Contradiction

    The function takes the two input post strings, loads the tokenizer and model
    from the respective checkpoints, tokenizese the input posts and runs the
    prediction model.
"""
def predict_self_contra(input_posts):

    #input_posts = input_posts[-2:] # make sure only two posts enter the tokenizer

    # tokenize the input posts
    tokenizer = AutoTokenizer.from_pretrained(tokenizer_path) # load tokenizer
    tokenized_input = tokenizer(input_posts[0], input_posts[1],
                        padding="longest", truncation=True,
                        return_token_type_ids=True,
                        return_tensors="pt") # IMPORTANT make sure to have pt tensors

    model = AutoModelForSequenceClassification.from_pretrained(
                                                                model_checkpoint, # Load model from checkpoint
                                                                num_labels = 2, # The number of output labels--2 for binary classification.  
                                                                output_attentions = False, # Whether the model returns attentions weights.
                                                                output_hidden_states = False, # Whether the model returns all hidden-states.
                                                                )

    if torch.cuda.is_available():
        print("Using GPU")
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    
    model.to(device) # load model to device
    model.eval() # set model to eval mode

    with torch.no_grad():
        tokenized_input.to(device) # make sure that input is loaded to the same device as the model
        input_ids = tokenized_input["input_ids"] # extract tokenized ids
        attention_mask = tokenized_input["attention_mask"] # extract attention mask

        # run prediction
        output = model(input_ids, 
                    token_type_ids=None, 
                    attention_mask=attention_mask)
        
        logits = output.logits # extract logits
        predictions =logits.argmax(-1)[0] # transform logits to integer output

        return predictions # return obtained integer output 1 self-contra
                            # 0 no self-contra
    


"""
Self-Contradiction Analysis for the Conversation
    -input: 
            input_posts - list of input post strings with speaker information
            sep - separator token separating speaker and text defaults to ";;"
    -output: integer 1 for Self-Contradiction anywhere 
             in the history of the speaker, 0 for no 
             Self-Contradiction in the history

    The function takes a history of posts with speaker information
"""
def analyse_conversation(input_posts, sep=";;"):
    # make sure that there are at least two posts in the history
    if len(input_posts) < 2:
        return 0
    else:
        # separate posts and speakers using the separator token
        posts = [inpt.split(sep)[1] for inpt in input_posts]
        speakers = [inpt.split(sep)[0] for inpt in input_posts]

        # identify the target speaker of the analysis
        target_speaker = speakers[-1] # we only analyse self-contradictions for the 
                                        # last speaker in the history

        # find the indices of posts associated with the target speaker
        target_indices = [idx for idx, val in enumerate(speakers[:-1]) if val==target_speaker]

        # if there are no other posts of the target speaker return 0 
        # as there can't be self-contradictions
        if len(target_indices) == 0:
            return 0

        else: # iterate over all posts of the target speaker
            for idx in target_indices:
                post1 = posts[idx]
                post2 = posts[-1] # the last post in the history is always the second post to analyse
                #print(post1, post2)
                prediction = predict_self_contra([post1, post2]) # predict whether there is a self-contradiction
                #print(prediction)

                # since only one self-contradiction may make a moderation necessary 
                # we return as soon as there is one self-contradiction between the 
                # target post and another post by the same author
                if prediction == 1: # as soon as there is one self-contradiction return 1
                    return 1
            return 0 # if no self-contradiction was found in the history return 0
        
def self_contradiction(input_posts):
    return [analyse_conversation(input_posts[:-1]), analyse_conversation(input_posts)]