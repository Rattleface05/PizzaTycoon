# Raport Bug: MissingAuthError pe Agenții AI

## Descrierea Problemei
Inițial, pentru implementarea agenților AI din meniul principal (Splash) și din magazin (Customers), s-a folosit librăria Python `g4f` pentru a contacta un API public gratuit de text generation (GPT-3.5 via OpenRouter/PuterJS).

**Eroarea întâmpinată:**
La execuția scriptului `server.py`, consola arunca următoarea eroare, blocând generarea de replici:
```
AI Error: RetryProvider failed:
OpenRouter: MissingAuthError: Add a "api_key"
PuterJS: MissingAuthError: API key is required for Puter.js API
```

## Impact
Jocul Godot încerca să extragă prin HTTPRequest (în `_ready`) un string de pe `/api/agent/customer`. Deoarece endpoint-ul returna eroarea API-ului, jucătorii nu mai puteau interacționa fluid cu sistemul de vânzare.

## Soluția implementată
1. **Identificarea cauzei:** Librăria `g4f` făcea fallback pe provideri care recent și-au modificat politica de acces și cer acum API Keys (ceea ce strică principiul de soluție gratuită pentru testare). Testarea cu alți provideri gratuiți a scos la iveală limitări de Rate Limit (429) și blocări DNS locale.
2. **Abordarea arhitecturală (Refactor):** 
   S-a decis eliminarea completă a dependenței de rețea. Am implementat un model AI 100% local, bazat pe *Markov Chains*, în fișierul `markov_ai.py`.
3. **Rezolvare (Pull Request fix):**
   - S-a creat branch-ul `aitudor`.
   - S-a scris codul Python `markov_ai.py` (antrenează pe un corpus de texte de pizza).
   - `server.py` a fost refactorizat pentru a importa noul modul, renunțând la un queue async stufos (deoarece generarea este instantanee).
   - Aceste modificări au fost incluse în Pull Request-ul de pe branch-ul `aitudor` spre `main`.
