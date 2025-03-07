# calculates MTLD score for the whole essay
from lexicalrichness import LexicalRichness

def calculate_lex_richness_MTLD2(text):
    lex = LexicalRichness(text) 
    lex_rich_score = lex.mtld()
    return(lex_rich_score)