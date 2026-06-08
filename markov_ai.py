import random

class MarkovLanguageModel:
    """Un model de limbaj local foarte mic, bazat pe lanturi Markov."""
    def __init__(self):
        self.chain = {}

    def train(self, corpus):
        for sentence in corpus:
            words = sentence.split()
            if len(words) < 2: continue
            
            # Start token
            self._add_to_chain("START", words[0])
            
            for i in range(len(words) - 1):
                self._add_to_chain(words[i], words[i+1])
            
            # End token
            self._add_to_chain(words[-1], "END")

    def _add_to_chain(self, word1, word2):
        if word1 not in self.chain:
            self.chain[word1] = []
        self.chain[word1].append(word2)

    def generate(self, max_length=15):
        if "START" not in self.chain:
            return "Error: Model neantrenat!"
            
        current_word = random.choice(self.chain["START"])
        sentence = [current_word]
        
        for _ in range(max_length - 1):
            if current_word not in self.chain:
                break
            
            next_words = self.chain[current_word]
            next_word = random.choice(next_words)
            
            if next_word == "END":
                break
                
            sentence.append(next_word)
            current_word = next_word
            
        return " ".join(sentence)

# "Baza de date" pentru antrenare (Corpus)
CUSTOMER_CORPUS = [
    "I want a pizza with extra cheese please!",
    "Give me the biggest pizza you have.",
    "Do you sell pineapple pizza?",
    "I want a spicy pizza.",
    "Make it fast, I am so hungry!",
    "One slice of heaven, please.",
    "Can I get a hot pepperoni?",
    "A pizza so good it breaks the matrix!",
    "Just a normal pizza for a normal guy.",
    "Extra olives, extra cheese, extra fast!",
    "I need pizza to survive the day.",
    "Give me a cheesy masterpiece.",
    "I am here for the best pizza in town.",
    "One Margherita, no tomatoes, only cheese.",
    "Pizza is my religion, give me one.",
    "Hot and spicy, just like me!",
    "Can you put fries on the pizza?",
    "A huge pizza with absolutely everything.",
    "I would like a pizza that tastes like victory.",
    "Bake me a pizza with extra matrix!",
    "Give me the hottest slice you sell."
]

SPLASH_CORPUS = [
    "Contains 100% virtual cheese!",
    "Mamma mia!",
    "Better than real life!",
    "Powered by Local AI!",
    "Also try Terraria!",
    "Now with extra pepperoni!",
    "Pizza Tycoon is watching you.",
    "Hotter than the oven!",
    "Cheesy graphics!",
    "Bake it until you make it!",
    "Knead the dough!",
    "A slice of the action!",
    "10/10 would bake again.",
    "Now with 0% real calories!",
    "Don't tell the Italians!",
    "Contains 100% real action!",
    "Bake the graphics!",
    "Powered by cheesy dough!"
]

# Antrenam modelele instant
customer_ai = MarkovLanguageModel()
customer_ai.train(CUSTOMER_CORPUS)

splash_ai = MarkovLanguageModel()
splash_ai.train(SPLASH_CORPUS)

def get_customer_reply():
    return customer_ai.generate(max_length=12)

def get_splash_text():
    return splash_ai.generate(max_length=8)

if __name__ == "__main__":
    # Test
    print("Customer:", get_customer_reply())
    print("Splash:", get_splash_text())
