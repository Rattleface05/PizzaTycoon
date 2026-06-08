import random
import re

class ContextFreeGrammarModel:
    """Un agent AI bazat pe gramatici independente de context (Symbolic NLP) pentru Splash Texts."""
    
    def __init__(self, rules, start_symbol="<ROOT>"):
        self.rules = rules
        self.start_symbol = start_symbol
        # Regex pentru a detecta etichetele (ex: <NOUN>)
        self.tag_pattern = re.compile(r"(<[^>]+>)")

    def generate(self, symbol=None):
        if symbol is None:
            symbol = self.start_symbol
            
        if symbol not in self.rules:
            # Daca e un cuvant normal, il returnam simplu
            return symbol
            
        # Alegem o regula aleatorie pentru simbolul curent
        chosen_rule = random.choice(self.rules[symbol])
        
        # Despartim regula in tag-uri si alte string-uri
        parts = self.tag_pattern.split(chosen_rule)
        
        result = []
        for part in parts:
            if not part: continue
            
            if self.tag_pattern.match(part):
                # Este un tag, o generam recursiv
                result.append(self.generate(part))
            else:
                # Este text normal
                result.append(part)
                
        return "".join(result).strip()

# Definim "cunostintele" algoritmului (Regulile gramaticale)
SPLASH_GRAMMAR = {
    "<ROOT>": [
        "<ADJECTIVE> <NOUN> <VERB> <OBJECT>!",
        "Powered by <ADJECTIVE> <NOUN>!",
        "Contains 100% <ADJECTIVE> <NOUN>!",
        "<VERB_IMP> <OBJECT> until you make it!",
        "Don't tell <OBJECT>!",
        "Also try <GAME>!",
        "10/10 would <VERB_IMP> again!"
    ],
    "<ADJECTIVE>": ["cheesy", "virtual", "spicy", "hot", "real", "AI-driven"],
    "<NOUN>": ["cheese", "pizza", "dough", "graphics", "action", "matrix"],
    "<VERB>": ["breaks", "needs", "loves", "watches", "destroys"],
    "<VERB_IMP>": ["Bake", "Knead", "Eat", "Destroy", "Simulate"],
    "<OBJECT>": ["the matrix", "the oven", "the dough", "the Italians", "extra pepperoni"],
    "<GAME>": ["Terraria", "Minecraft", "Cyberpunk", "Godot"]
}

# Instantiem algoritmul AI
splash_agent = ContextFreeGrammarModel(SPLASH_GRAMMAR)

def get_splash_text():
    # Capitalizam prima litera din propozitie
    text = splash_agent.generate()
    return text[0].upper() + text[1:] if text else ""

if __name__ == "__main__":
    for _ in range(5):
        print(get_splash_text())
