#!/bin/bash
GODOT_VERSION=$(godot --version)
VERSION_NUM=$(echo $GODOT_VERSION | cut -d'.' -f1,2,3)
STATUS=$(echo $GODOT_VERSION | cut -d'.' -f4)
echo "URL: https://github.com/godotengine/godot/releases/download/${VERSION_NUM}-${STATUS}/Godot_v${VERSION_NUM}-${STATUS}_export_templates.tpz"
