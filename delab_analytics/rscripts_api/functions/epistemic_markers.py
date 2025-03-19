# Counts the total number of epistemic markers per essay
import re

def find_epistemic_markers(text):
    epistemic_markers_count = []
    epistemic_markers_count.extend(re.findall(r'(?:I|We|we|One|one)(?:\s\w+)?(?:\s\w+)?\s(?:believes?|think|thinks|means?|worry|worries|know|guesse?s?|assumes?|wonders?|feels?)\b(?:that)?', text))
    epistemic_markers_count.extend(re.findall(r'(?:I|We|we|One|one)\s(?:don\'t|\sdoesn\'t\sdo\snot|\sdoes\snot)\s(?:believe|think|mean|worry|know|guess|assume|wonder|feel)\b(?:that)?', text))
    epistemic_markers_count.extend(re.findall(r'(?:It|it)\sis\s(?:believed|known|assumed|thought)\b(?:that)?', text))
    epistemic_markers_count.extend(re.findall(r'(?:I|We|we)\s(?:am|are|was|were)(?:\sjust)?\s(?:thinking|guessing|wondering)\b(?:that)?', text))
    epistemic_markers_count.extend(re.findall(r'(?:I\'m|[Ww]e\'re)(?:\sjust)?\s(?:thinking|guessing|wondering)\b(?:that)?', text)) 
    epistemic_markers_count.extend(re.findall(r'(?:I|We|we|One|one)(?:\s\w+)?\s(?:do|does)\snot\s(?:believe?|think|know)\b(?:that)?', text)) 
    epistemic_markers_count.extend(re.findall(r'(?:I|We|we|One|one)\swould(?:\s\w+)?(?:\snot)?\ssay\b(?:that)?', text)) 
    epistemic_markers_count.extend(re.findall(r'(?:I\sam|I\'m)(?:\s\w+)?\s(?:afraid|sure|confident)\b(?:that)?', text)) 
    epistemic_markers_count.extend(re.findall(r'(?:My|my|Our|our)\s(?:personal\s)?(?:experience|opinion|belief|view|knowledge|worry|worries|concerns?|guesse?s?|position|perception)(?:\son\s\w+)?\s(?:is|are)\b(?:that)?', text)) 
    epistemic_markers_count.extend(re.findall(r'[Ii]n\s(?:my|our)(?:\s\w+)?\s(?:view|opinion)\b',text))
    epistemic_markers_count.extend(re.findall(r'[Fr]rom\s(?:my|our)\s(?:point\sof\sview|perspective)\b', text)) 
    epistemic_markers_count.extend(re.findall(r'As\sfar\sas\s(?:I|We|we)\s(?:am|are)\sconcerned', text))
    epistemic_markers_count.extend(re.findall(r'(?:I|We|we|One|one)\s(?:can|could|may|might)(?:\s\w+)?\sconclude\b(?:that)?', text)) 
    epistemic_markers_count.extend(re.findall(r'I\s(?:am\swilling\sto|must)\ssay\b(?:that)?', text)) 
    epistemic_markers_count.extend(re.findall(r'"One\s(?:can|could|may|might)\ssay\b(?:that)?', text)) 
    epistemic_markers_count.extend(re.findall(r'[Oo]ne\s(?:can|could|may|might)\ssay\b(?:that)?',text)) 
    epistemic_markers_count.extend(re.findall(r'[Ii]t\sis\s(?:obvious|(?:un)?clear)\b', text)) 
    epistemic_markers_count.extend(re.findall(r'[Ii]t(?:\sjust)?\s(?:seems|feels|looks)', text)) 
    epistemic_markers_count.extend(re.findall(r'[Pp]ersonally\s(?:for\sme|speaking)', text))
    epistemic_markers_count.extend(re.findall(r'(?:[Ff]rankly|[Hh]onestly|[Cc]learly)', text))
    return len(epistemic_markers_count)/len(text)
