import spacy
nlp = spacy.load('en_core_web_sm')
import numpy as np

# Return the number of specified dependency labels found
def sent_complexity_structure(doc):
    return len([token for token in doc if (token.dep_ == "acl" or token.dep_ == "conj" or token.dep_ == "advcl"or token.dep_ == "ccomp"
    or token.dep_ == "csubj" or token.dep_ == "discourse" or token.dep_ == "parataxis")])

# Calcualtes the number of specified dependency label within a sentence
def calculate_dep_score(text):
    temp = []
    for sentence in nlp(text).sents:
        temp.append(sent_complexity_structure(sentence))
    return np.mean(temp) 

# Walks the dependency tree and returns the depth
def walk_tree(node, depth):
    if node.n_lefts + node.n_rights > 0:
        return max(walk_tree(child, depth + 1) for child in node.children)
    else:
        return depth
    
# Calculates the dependency depth 
def calculate_dep_length(text):
    temp = []
    for sentence in nlp(text).sents:
        temp.append(walk_tree(sentence.root, 0))
    return np.mean(temp)  