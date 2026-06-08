# Pizza Tycoon

A Godot 4 clicker/tycoon game where you prepare pizzas in the kitchen, sell them in the pizzeria storefront, and purchase upgrades to visually improve your restaurant.

## Project Architecture

The game is structured using Godot 4's scene and node system, with a clear separation between the two main areas of the game and a global state manager.

### 1. Global Autoload (`Global.gd`)
This is the heart of the game's data. It is registered as an Autoload singleton in `project.godot`.
- **Purpose**: Persists data across scene changes (Kitchen <-> Pizzeria).
- **State**: Tracks `money` (float), `pizzas_ready` (int), and `upgrade_level` (int).
- **Signals**: Emits signals (`money_changed`, `pizzas_ready_changed`, `level_changed`) whenever a variable is updated so that UI elements in the current scene can react instantly.

### 2. Kitchen Scene (`Kitchen.tscn` / `Kitchen.gd`)
The initial scene and core gameplay loop for production.
- **Minigame**: Players click a button to fill a progress bar. Once filled, `Global.pizzas_ready` is incremented.
- **UI**: Displays current pizzas ready and provides a navigation button to switch to the Pizzeria scene.

### 3. Pizzeria Scene (`Pizzeria.tscn` / `Pizzeria.gd`)
The storefront where products are sold and upgrades are purchased.
- **Selling**: Converts `pizzas_ready` into `money` by pressing the Sell button.
- **Upgrades**: Players can spend their accumulated money to purchase higher levels. As the `upgrade_level` increases, the visual background of the Pizzeria changes colors (simulating an upgraded venue).
- **HUD**: Constantly updates to reflect global money and pizza count via `Global` signals.

### 4. Visual Feedback (`FloatingText.tscn` / `FloatingText.gd`)
A juiciness/feedback system.
- Whenever a pizza is sold in the Pizzeria, a floating text node is instantiated, animating upwards and fading out to provide visual confirmation of the money earned.

## How to Run & Test

Pentru a beneficia de funcționalitățile complete (inclusiv agenții AI), jocul trebuie rulat folosind serverul Python inclus, care acționează ca un backend AI local:

### Varianta Web (Recomandată)
1. Clonează acest repository.
2. Ai două variante pentru a rula jocul în terminal:
   - **Varianta Automată (Recomandat):** Exporți jocul direct din terminal și pornești serverul dintr-o singură comandă:
     ```bash
     ./build_and_run.sh
     ```
   - **Varianta Manuală:** Dacă ai exportat deja jocul manual din engine, poți doar porni serverul:
     ```bash
     ./run_server.sh
     ```
3. Deschide un browser și accesează `http://localhost:8000`.
4. Jocul va rula nativ în browser, iar serverul din fundal va oferi replici AI instanțelor de clienți!

### Varianta Godot Editor (Pentru Dezvoltare)
1. Clonează repository-ul.
2. Pornește serverul AI (pentru a avea clienți funcționali): `./run_server.sh`
3. Deschide proiectul în **Godot 4**.
4. Apasă butonul de Play (sau F5) pentru a rula scena principală. Jocul va interoga automat `localhost:8000` pentru AI.
## Evaluare: Procesul de dezvoltare software cu AI (MDS - Partea B)

Această secțiune documentează îndeplinirea cerințelor de la Partea B din `barem.txt`:

1. **User stories, backlog creation:** (A fost implementat anterior în structura proiectului, pe repo-ul principal/feedback.txt)
2. **Diagrame:** Arhitectura proiectului și workflow-ul AI (Mermaid format) pot fi vizualizate aici: [docs/architecture.md](docs/architecture.md)
3. **Source control cu git:** S-a utilizat Git extensiv pe parcursul dezvoltării (branch-uri precum `aitudor`, push-uri, pull requests, multiple commit-uri). Istoricul se regăsește în tab-ul *Commits* din repository-ul de GitHub.
4. **Teste automate (inclusiv evals pentru agenți):** Script de testare Python (folosind `unittest`) pentru evaluarea modelului de AI local: [test_agents.py](test_agents.py)
5. **Pipeline CI/CD:** Configurarea GitHub Actions rulând testele la fiecare push pe `main`: [.github/workflows/ci.yml](.github/workflows/ci.yml)
6. **Raportare bug si rezolvare cu pull request:** O problemă de la API-urile externe a dus la decizia de a crea modelul Markov intern. Detalii aici: [docs/bug_report.md](docs/bug_report.md)
7. **Raport folosire tooluri AI:** Un rezumat detaliat al intervenției asistentului AI: [docs/AI_TOOLS_REPORT.md](docs/AI_TOOLS_REPORT.md)
