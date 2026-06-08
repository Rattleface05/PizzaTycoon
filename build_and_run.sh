#!/bin/bash

echo "Checking for Web Export Templates..."
TEMPLATE_DIR=~/.local/share/godot/export_templates
if ! ls ${TEMPLATE_DIR}/*/web_release.zip 1> /dev/null 2>&1; then
    echo "Godot Web export templates not found. Attempting to install them automatically..."
    
    GODOT_VERSION=$(godot --version)
    VERSION_NUM=$(echo $GODOT_VERSION | cut -d'.' -f1,2,3)
    STATUS=$(echo $GODOT_VERSION | cut -d'.' -f4)
    
    DOWNLOAD_URL="https://github.com/godotengine/godot/releases/download/${VERSION_NUM}-${STATUS}/Godot_v${VERSION_NUM}-${STATUS}_export_templates.tpz"
    TMP_TPZ="/tmp/godot_templates.tpz"
    
    echo "Downloading from: $DOWNLOAD_URL"
    wget -q --show-progress -O "$TMP_TPZ" "$DOWNLOAD_URL"
    
    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to download templates automatically."
        echo "Please install them via the Godot Editor -> Editor -> Manage Export Templates."
        exit 1
    fi
    
    echo "Installing templates..."
    mkdir -p "${TEMPLATE_DIR}/${VERSION_NUM}.${STATUS}"
    unzip -q "$TMP_TPZ" -d /tmp/godot_templates_extracted
    mv /tmp/godot_templates_extracted/templates/* "${TEMPLATE_DIR}/${VERSION_NUM}.${STATUS}/"
    rm -rf "$TMP_TPZ" /tmp/godot_templates_extracted
    echo "Templates installed successfully!"
fi

echo "Exporting Godot project to Web..."
# Create export dir if it doesn't exist
mkdir -p export/web

# Export via Godot headless CLI
godot --headless --export-release "Web" export/web/index.html

if [ $? -ne 0 ]; then
    echo "ERROR: Export failed. Check the Godot logs above."
    exit 1
fi

echo "Export complete!"
echo "Starting local server..."
./run_server.sh
