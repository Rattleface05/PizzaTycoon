#!/bin/bash
echo "Exporting Godot project to Web..."
# Create export dir if it doesn't exist
mkdir -p export/web

# Export via Godot headless CLI
godot --headless --export-release "Web" export/web/index.html

echo "Export complete!"
echo "Starting local server..."
./run_server.sh
