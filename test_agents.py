import unittest
import markov_ai
import cfg_ai

class TestAIAgents(unittest.TestCase):
    def setUp(self):
        # Asigurăm că modelele sunt antrenate (se face automat la import)
        self.customer_ai = markov_ai.customer_ai
        self.splash_ai = cfg_ai.splash_agent

    def test_customer_ai_returns_string(self):
        """Evalueaza daca agentul clientului returneaza mereu text valid."""
        response = self.customer_ai.generate(max_length=15)
        self.assertIsInstance(response, str)
        self.assertTrue(len(response) > 0)

    def test_splash_cfg_ai_returns_valid_grammar(self):
        """Evalueaza daca agentul CFG de splash returneaza text generat fara etichete sparte."""
        response = cfg_ai.get_splash_text()
        self.assertIsInstance(response, str)
        self.assertTrue(len(response) > 0)
        self.assertNotIn("<", response) # Asigura-te ca tag-urile au fost complet inlocuite
        self.assertNotIn(">", response)

    def test_uninitialized_model_fallback(self):
        """Evalueaza raspunsul cand modelul Markov primeste un corpus gol."""
        empty_ai = markov_ai.MarkovLanguageModel()
        empty_ai.train([]) # Corpus gol
        response = empty_ai.generate()
        self.assertEqual(response, "Error: Model neantrenat!")

if __name__ == '__main__':
    unittest.main()
