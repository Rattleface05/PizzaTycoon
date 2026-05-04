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

## How to Run
1. Clone the repository.
2. Open the project folder in Godot 4.
3. Import and run the game (default main scene is `Kitchen.tscn`).
