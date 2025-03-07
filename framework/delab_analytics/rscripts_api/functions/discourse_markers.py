import pandas as pd
import os
# Counts the number of discourse markers using PDTB list

dirname = os.getcwd()
parent_directory = os.path.dirname(dirname)
path = os.path.join(parent_directory, "models/connectives_discourse_markers_PDTB.txt")

discourse = pd.read_csv(path, sep="\'", encoding="UTF-8", header=None, usecols = [1,3])

discourse[3] = discourse[3].apply(lambda x: x.replace("t_conn_", ""))
discourse[1] = discourse[1].apply(lambda x: " " + x + " ")
discourse.sort_values(3, inplace=True, ascending=False)

# Countes the total numbers of discourse markers per essay
def count_discourse_markers(text):
    i = 0
    for marker in discourse.itertuples():
        if marker[1] in text:
            i += text.count(marker[1])
    return i