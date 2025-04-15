import random
import re
import pandas as pd
import json
import requests
from django.conf import settings
from pathlib import Path


def generate_answer(user_input, context=None):
    base_url = "http://delab_analytics:8840/"
    headers = {"Content-Type": "application/json"}

    texts = []
    # format context like the api requests
    for entry in context.values():
        formatted = ';;'.join([list(entry.keys())[0], list(entry.values())[0]])
        texts.append(formatted)
    texts.append("3;;" + user_input)
    payload = {"texts": texts}

    try:
        response_llm = requests.post(f"{base_url}llm", headers=headers, json=payload).json()
        bot_answer = response_llm
    except requests.exceptions.RequestException as e:
        bot_answer = f"Error connecting to Docker service: {e}"

    answer = bot_answer
    return answer


def get_context(conv_df=None):
    json_used = False
    if conv_df is None:
        folder_path = settings.MEDIA_ROOT
        json_file = folder_path / 'conv_delab.json'  # Check for JSON file first
        pickle_file = folder_path / 'conv_delab.pickle'  # Original pickle file
        if json_file.exists():
            with open(json_file, 'r', encoding='utf-8') as f:
                data = json.load(f)
            conv_df = pd.DataFrame(data)  # Convert JSON to Pandas DataFrame
            conv_df['checked'] = False
            json_used = True
        elif pickle_file.exists():
            conv_df = pd.read_pickle(pickle_file)
            conv_df['checked'] = False

        else:
            return None  # No data available

    if conv_df['checked'].all():
        return None

    if json_used:
        context_sequence = conv_df
    else:
        index_list = conv_df[conv_df['checked']==False].index.tolist()
        rndm = random.choice(index_list)
        context_row = conv_df.iloc[rndm].to_frame().T
        conv_id = context_row['conv_id'].iloc[0]
        conv_path = context_row['conv_path'].iloc[0]
        conv_seqid = context_row['conv_seqid'].iloc[0]
        context_sequence = conv_df[(conv_df['conv_id']==conv_id) & (conv_df['conv_path']==conv_path)]
        if len(context_sequence)<3:
            id = context_row.index[0]
            conv_df.loc[id, 'checked']=True
            return get_context(conv_df)
        if len(context_sequence)>=5:
            if (int(conv_seqid) > 3) & (int(conv_seqid)<=len(context_sequence)-2):
                context_sequence = context_sequence[(context_sequence['conv_seqid'].astype(int)>=int(conv_seqid) - 2) &
                                                    (context_sequence['conv_seqid'].astype(int)<=int(conv_seqid) + 2)]
            else:
                # der Einfachkeit halber den context ab dem ersten post
                context_sequence = context_sequence.head(5)
    context_dict = {}
    authors = context_sequence['author_id'].unique().tolist()
    for index, row in context_sequence.iterrows():
        author_id = row['author_id']
        author = authors.index(author_id)
        text = row['text']
        cleaned_text = re.sub(r'@\w+', '', text)
        # Remove extra spaces that might be left
        post_dict = {}
        post_dict[author] = cleaned_text
        cleaned_text = re.sub(r'\s+', ' ', cleaned_text).strip()
        context_dict[index] = post_dict

    return context_dict
