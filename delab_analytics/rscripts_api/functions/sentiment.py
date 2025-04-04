import re
import torch
import pandas as pd
from transformers import pipeline
from typing import List

def r_style_sentence_split(text: str):
    return [s.strip() for s in re.split(r'(?<=[.!?])', text) if s.strip()]

def get_sentiments(text: str, pipe_sent) -> pd.Series:
    # Apply sentiment pipeline with top_k=3
    out = pipe_sent(text)[0]
    
    # Flatten and reformat
    label_score = {item['label'].lower(): item['score'] for item in out}
    
    return pd.Series({
        'sent_positive': label_score.get('positive', 0.0),
        'sent_neutral': label_score.get('neutral', 0.0),
        'sent_negative': label_score.get('negative', 0.0),
    })

def delab_sentiment_py(texts: List[str]) -> pd.DataFrame:
    if len(texts) <= 1:
        raise ValueError("Number of observations too low: at least two posts need to be provided!")

    df = pd.DataFrame({'text': texts})
    df['row_id'] = range(1, len(df) + 1)
    df = df.tail(2).copy()

    # Check length
    df['length'] = df['text'].apply(lambda x: len(re.findall(r'\S+', x)))
    switch_length = 0

    # Split long texts into sentences
    if any(df['length'] >= 200):
        switch_length = 1
        new_rows = []
        for _, row in df.iterrows():
            for sentence in r_style_sentence_split(row['text']):
                new_rows.append({'text': sentence, 'row_id': row['row_id']})
        df = pd.DataFrame(new_rows)

    # Load model
    path_to_model = "./../models/twitter-roberta-base-sentiment-latest"
    device = 0 if torch.cuda.is_available() else -1
    pipe_sent = pipeline("sentiment-analysis", model=path_to_model, device=device, top_k=3)

    # Apply sentiment scoring
    sentiment_rows = []
    for _, row in df.iterrows():
        sentiment = get_sentiments(row['text'], pipe_sent)
        sentiment_rows.append({**row.to_dict(), **sentiment.to_dict()})

    df_sentiments = pd.DataFrame(sentiment_rows)

    # Aggregate if needed
    if switch_length == 1:
        mean_vals = df_sentiments.groupby("row_id")[['sent_positive', 'sent_neutral', 'sent_negative']].mean().reset_index()
        texts = df_sentiments.groupby("row_id")['text'].apply(' '.join).reset_index()
        df_sentiments = pd.merge(mean_vals, texts, on='row_id')
    else:
        df_sentiments = df_sentiments.drop(columns=['row_id', 'length'])

    # Compute deviations
    df_sentiments['sent_negative_dev'] = df_sentiments['sent_negative'].diff()
    df_sentiments['sent_neutral_dev'] = df_sentiments['sent_neutral'].diff()
    df_sentiments['sent_positive_dev'] = df_sentiments['sent_positive'].diff()
    df_sentiments.rename(columns={"text": "texts"}, inplace=True)

    return df_sentiments.reset_index(drop=True)
