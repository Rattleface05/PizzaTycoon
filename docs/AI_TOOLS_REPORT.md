# Raport de Utilizare a Tool-urilor AI în Dezvoltare

Proiectul Pizza Tycoon a fost dezvoltat cu asistența extinsă a inteligenței artificiale (Modelul Google Gemini via asistentul Antigravity), implicând o metodologie completă de "AI-Assisted Software Engineering".

## 1. Generarea de Cod și Logica Jocului (Godot 4)
* Tool folosit: **Gemini AI (Antigravity)**
* Detalii: AI-ul a fost folosit extensiv pentru a refactoriza codul GDScript existent. A implementat logica de prestige, unde a scris un custom shader (`vortex.gdshader`) direct din prompt pentru a crea un efect vizual avansat de distorsiune la resetarea jocului. De asemenea, a scris complet structura de gestionare a butoanelor și navigarea între UI.

## 2. Server de Găzduire și Configurarea Porturilor (Python)
* Tool folosit: **Gemini AI**
* Detalii: Pentru a putea rula build-urile de Godot Web (care necesită headere HTTP specifice pentru a accepta `SharedArrayBuffer` folosit de multithreading-ul Godot 4), am delegat AI-ului sarcina de a scrie un mic server web în Python (`server.py`).

## 3. Scrierea unui Model de Limbaj Custom (Markov Chains)
* Tool folosit: **Gemini AI**
* Detalii: Când API-urile externe gratuite s-au dovedit nesigure și picau cu eroarea `MissingAuthError`, am folosit AI-ul pentru a programa... un alt AI! I-am cerut să scrie de la zero un "Language Model" super-ușor, pe bază de Lanțuri Markov, direct în Python (`markov_ai.py`). Astfel, Gemini a construit logica matematică a agenților noștri de text care acum rulează nativ, local.

## 4. Documentație și Planificare
* Tool folosit: **Gemini AI (Mermaid Generator)**
* Detalii: Diagramele de arhitectură, raportul de bug, scrierea fișierelor YAML pentru acțiunile de pe GitHub (CI/CD) și chiar acest raport au fost structurate folosind modulele de asistență ale agentului. AI-ul a propus un "Implementation Plan" iterativ înainte de a acționa asupra fiecărei baze de cod, asigurând un proces de dezvoltare predictibil.
