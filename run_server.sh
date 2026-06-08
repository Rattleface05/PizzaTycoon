#!/bin/bash
set -e

# Asigura-te ca folderul de export exista
mkdir -p export/web

# Exporta proiectul pentru Web (comenteaza linia daca vrei sa exporti manual din editor)
# godot --headless --export-release "Web" export/web/index.html

# Porneste serverul Python
python3 server.py
