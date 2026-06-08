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

# Antrenam modelul instant
customer_ai = MarkovLanguageModel()
customer_ai.train(CUSTOMER_CORPUS)

def get_customer_reply():
    return customer_ai.generate(max_length=12)

if __name__ == "__main__":
    # Test
    for _ in range(5):
        print("Customer:", get_customer_reply())
