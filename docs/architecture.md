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

## Ciclul de Progresie & Prestige
Diagrama de stări descrie bucla principală a jocului idle, de la acumularea de resurse până la resetarea prin Prestige.

```mermaid
stateDiagram-v2
    [*] --> JocNou : Start / Load Save

    state JocNou {
        [*] --> BuclaIdle
        BuclaIdle : Bucla Idle Activă
        BuclaIdle --> AutoCooking : Chefs angajați produc pizze\n(cook_rate * delta)
        AutoCooking --> StocPizze : pizzas_ready++
        StocPizze --> AutoSelling : Cashiers vând automat\n(sell_rate * delta)
        AutoSelling --> Venituri : money += preț_pizza
        Venituri --> BuclaIdle : Loop continuu

        BuclaIdle --> ManualCook : Jucătorul apasă\n„Cook Pizza"
        ManualCook --> StocPizze

        BuclaIdle --> ManualSell : Jucătorul apasă\n„Sell Pizza"
        ManualSell --> Venituri
    }

    JocNou --> Upgrade : money >= cost_upgrade
    state Upgrade {
        [*] --> CumparaBucatar : Angajează Chef\n(crește cook_rate)
        [*] --> CumparaCasier : Angajează Cashier\n(crește sell_rate)
        [*] --> DeblochezaReteta : Cumpără Rețetă Nouă\n(crește pizza_value)
        CumparaBucatar --> [*]
        CumparaCasier --> [*]
        DeblochezaReteta --> [*]
    }
    Upgrade --> JocNou : Continuă bucla cu rate mai mari

    JocNou --> VerificarePrestige : money >= 100,000
    state VerificarePrestige {
        [*] --> CalculPuncte : prestige_pts = floor(sqrt(money / 100k))
        CalculPuncte --> ConfirmareJucator : Jucătorul confirmă Prestige
    }

    VerificarePrestige --> PrestigeReset : Confirmat
    state PrestigeReset {
        [*] --> ResetProgres : money, chefs,\ncashiers → 0
        ResetProgres --> AdaugaPuncte : prestige_points += gained
        AdaugaPuncte --> DeblochereUpgradePrestige : Prestige Shop\n(golden_crust, kitchen_rush,\nsales_pitch, master_baker)
        DeblochereUpgradePrestige --> SalvareJoc : save_game()
    }

    PrestigeReset --> JocNou : Relua de la început\ncu bonusuri permanente
    JocNou --> [*] : Ieșire / Salvare automată
```
