import unittest
import markov_ai

class TestMarkovAgents(unittest.TestCase):
    def setUp(self):
        # Asigurăm că modelele sunt antrenate (se face automat la import in markov_ai, dar e bine sa fim siguri)
        self.customer_ai = markov_ai.customer_ai
        self.splash_ai = markov_ai.splash_ai

    def test_customer_ai_returns_string(self):
        """Evalueaza daca agentul clientului returneaza mereu text valid."""
        response = self.customer_ai.generate(max_length=15)
        self.assertIsInstance(response, str)
        self.assertTrue(len(response) > 0)

    def test_splash_ai_length_limit(self):
        """Evalueaza daca agentul de splash respecta limita de generare pentru a nu depasi interfata (max 10 cuvinte)."""
        response = self.splash_ai.generate(max_length=10)
        word_count = len(response.split())
        self.assertTrue(word_count <= 10, f"Generat {word_count} cuvinte, asteptam max 10.")

    def test_uninitialized_model_fallback(self):
        """Evalueaza raspunsul cand modelul primeste un corpus gol."""
        empty_ai = markov_ai.MarkovLanguageModel()
        empty_ai.train([]) # Corpus gol
        response = empty_ai.generate()
        self.assertEqual(response, "Error: Model neantrenat!")

if __name__ == '__main__':
    unittest.main()
