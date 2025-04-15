import pickle
import numpy as np
import pandas as pd
import shap
import torch
import torch.nn as nn
from sklearn.preprocessing import StandardScaler

class MLP(nn.Module):
    def __init__(self, input_dim):
        super(MLP, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(input_dim, 64),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(64, 32),
            nn.ReLU(),
            nn.Dropout(0.3),
            nn.Linear(32, 1),
            nn.Sigmoid()
        )

    def forward(self, x):
        return self.model(x)

def merge_dicts(dicts, keys_to_include):
    merged_dict = {}
    
    for i, d in enumerate(dicts, start=1):
        for key, value in d.items():
            new_key = key
            if key in merged_dict:  
                new_key = f"{i}_{key}"

            if new_key in keys_to_include:
                merged_dict[new_key] = value
            
    return merged_dict

keys_to_include = ['sent_negative', 'sent_neutral', 'sent_positive',
       'argpred_0', 'argpred_1', 'discourse_markers_count',
       'epistemic_markers_count', 'lexical_reachness', 'dependency_depth',
       'dependency_score', 'self_contradiction', '2_sent_negative',
       '2_sent_neutral', '2_sent_positive', 'sent_negative_dev',
       'sent_neutral_dev', 'sent_positive_dev', '2_argpred_0', '2_argpred_1',
       'argpred_0_dev', 'argpred_1_dev', 'cosine_prev',
       '2_discourse_markers_count', '2_epistemic_markers_count',
       '2_lexical_reachness', '2_dependency_depth', '2_dependency_score',
       '2_self_contradiction', 'no_relation', 'inference', 'conflict',
       'rephrase']

model_path = './../models/MLP/mlp.pth'
input_dim = 32

def feature_importance(df):
    with open('./../models/MLP/scaler.pkl', 'rb') as f:
        scaler = pickle.load(f)

    df = pd.DataFrame(merge_dicts(df.apply(lambda row: row.dropna().to_dict(), axis=1).tolist(), keys_to_include), index=[0])[keys_to_include]

    X = scaler.transform(df)

    model = MLP(input_dim)
    model.load_state_dict(torch.load(model_path, map_location='cpu', weights_only=True))
    model.eval()



    def model_predict_wrapper(x_numpy):
        x_tensor = torch.tensor(x_numpy, dtype=torch.float32)
        with torch.no_grad():
            probs = model(x_tensor).numpy()
        return probs

    train_df = pd.read_csv('./../models/MLP/train.csv').set_index('subthread')

    explainer = shap.KernelExplainer(model_predict_wrapper, train_df.iloc[:, 1:].values)

    shap_values = explainer.shap_values(X[0:1])
    shap_values = shap_values[0, :, 0]

    feature_names = train_df.columns[1:]

    shap_importance_df = pd.DataFrame({
        'feature': feature_names,
        'importance': shap_values
    }).sort_values(by='importance', ascending=False).set_index('feature').T

    return shap_importance_df