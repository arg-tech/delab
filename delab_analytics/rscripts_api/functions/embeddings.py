import re
import torch
import pandas as pd
from transformers import AutoModel, AutoTokenizer
from typing import List

def r_style_sentence_split(text: str) -> List[str]:
    return [s.strip() for s in re.split(r'(?<=[.!?])', text) if s.strip()]

def get_embedding(text, model, tokenizer, device):
    inputs = tokenizer(text, return_tensors="pt", truncation=True, padding=True)
    inputs = {k: v.to(device) for k, v in inputs.items()}
    with torch.no_grad():
        outputs = model(**inputs)
    hidden_states = outputs.last_hidden_state  # shape: (1, seq_len, hidden_size)
    mean_emb = hidden_states.mean(dim=1).squeeze().cpu().numpy()  # shape: (hidden_size,)
    return mean_emb

def delab_embeddings_py(texts: List[str]) -> pd.DataFrame:
    if len(texts) <= 1:
        raise ValueError("Number of observations too low: at least two posts need to be provided!")

    # Keep only last two posts
    df = pd.DataFrame({'texts': texts})
    df['row_id'] = range(1, len(df) + 1)
    df = df.tail(2).copy()
    
    df_process = df.copy()
    # Count words
    df_process['length'] = df['texts'].apply(lambda x: len(re.findall(r'\S+', x)))
    switch_length = 0

    # Sentence split if any text is long
    if any(df_process['length'] >= 30):
        switch_length = 1
        split_rows = []
        for _, row in df_process.iterrows():
            for sentence in r_style_sentence_split(row['texts']):
                split_rows.append({'texts': sentence, 'row_id': row['row_id']})
        df_process = pd.DataFrame(split_rows)

    # Load model/tokenizer
    path_to_model = "./../models/twitter-xlm-roberta-base/"
    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
    tokenizer = AutoTokenizer.from_pretrained(path_to_model)
    model = AutoModel.from_pretrained(path_to_model).to(device)
    model.eval()

    # Generate embeddings
    embeddings = []
    for _, row in df_process.iterrows():
        emb = get_embedding(row['texts'], model, tokenizer, device)
        emb_dict = {f'emb_{i}': val for i, val in enumerate(emb)}
        embeddings.append({**row.to_dict(), **emb_dict})

    df_embeddings = pd.DataFrame(embeddings)

    # Aggregate if needed
    if switch_length == 1:
        embed_cols = [col for col in df_embeddings.columns if col.startswith("emb_")]
        agg_embeds = df_embeddings.groupby("row_id")[embed_cols].mean().reset_index()
        df_embeddings = pd.merge(df[['row_id', 'texts']], agg_embeds, on='row_id', how='left')

    return df_embeddings
