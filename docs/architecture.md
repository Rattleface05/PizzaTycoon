# Arhitectura Proiectului: Pizza Tycoon

Acest document descrie arhitectura aplicației și modul în care comunică diferitele componente.

## Arhitectura Componentelor
Diagrama de mai jos prezintă structura de bază a sistemului, inclusiv motorul de joc, serverul local de proxy, și logica agenților AI.

```mermaid
graph TD
    subgraph Godot Engine Client
        A[Joc Web / Local] -->|HTTP Request| B(Meniul Principal)
        A -->|HTTP Request| C(Sistemul de Clienți)
    end
    
    subgraph Python Backend Server
        D[server.py pe port 8000]
        B -->|GET /api/agent/splash| D
        C -->|GET /api/agent/customer| D
        
        D -->|Apelează Generarea| E[markov_ai.py]
    end
    
    subgraph Local Language Model
        E -->|Antrenament| F[(Corpus Intern de Texte)]
        F --> E
    end
```

## Workflow: Servirea Clienților
Workflow-ul standard de joc, implicând atât interacțiunea jucătorului cât și generarea replicilor.

```mermaid
sequenceDiagram
    participant Jucator
    participant Joc (Godot)
    participant Python Backend
    participant Model AI

    Jucator->>Joc: Vinde o Pizza
    Joc->>Joc: Distruge instanța veche client
    Joc->>Joc: Instanțiază Client Nou
    Joc->>Python Backend: GET /api/agent/customer
    Python Backend->>Model AI: Cere replică
    Model AI->>Model AI: Prezice următoarele cuvinte (Markov)
    Model AI-->>Python Backend: "I want a spicy pizza"
    Python Backend-->>Joc: JSON Răspuns
    Joc->>Jucator: Afișează dialogul pe ecran
```
