#!/bin/bash
# Hyprwhspr Voice Dictation - Installation Script
# Run: chmod +x install.sh && ./install.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$SCRIPT_DIR/configs"

echo "=== Hyprwhspr Voice Dictation Setup ==="

# Check if running as root
if [ "$EUID" -eq 0 ]; then
    echo "ERROR: Do not run as root!"
    exit 1
fi

# 1. Check user in input group
if ! groups | grep -q '\binput\b'; then
    echo ""
    echo "WARNING: User not in 'input' group!"
    echo "Run: sudo usermod -aG input $USER"
    echo "Then REBOOT and run this script again."
    echo ""
    read -p "Add to input group now? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        sudo usermod -aG input "$USER"
        echo "Added to input group. Please REBOOT and run this script again."
        exit 0
    fi
fi

# 2. Create directories
echo "[1/6] Creating directories..."
mkdir -p ~/.config/hyprwhspr
mkdir -p ~/.local/share/hyprwhspr
mkdir -p ~/.config/systemd/user

# 3. Copy config files
echo "[2/6] Copying configuration files..."
cp "$CONFIG_DIR/config.json" ~/.config/hyprwhspr/
cp "$CONFIG_DIR/credentials.json" ~/.local/share/hyprwhspr/credentials
chmod 600 ~/.local/share/hyprwhspr/credentials
cp "$CONFIG_DIR/hyprwhspr.service" ~/.config/systemd/user/

# 4. Add Hyprland binding if not exists
echo "[3/6] Checking Hyprland binding..."
if ! grep -q "hyprwhspr/recording_control" ~/.config/hypr/hyprland.conf 2>/dev/null; then
    echo "" >> ~/.config/hypr/hyprland.conf
    echo "# Voice dictation (Ctrl+Space)" >> ~/.config/hypr/hyprland.conf
    cat "$CONFIG_DIR/hyprland-binding.conf" >> ~/.config/hypr/hyprland.conf
    echo "Added Ctrl+Space binding to hyprland.conf"
else
    echo "Hyprland binding already exists"
fi

# 5. Enable services
echo "[4/6] Enabling systemd services..."
systemctl --user daemon-reload
systemctl --user enable hyprwhspr ydotool

# 6. Start services
echo "[5/6] Starting services..."
systemctl --user restart hyprwhspr ydotool

# 7. Reload Hyprland
echo "[6/6] Reloading Hyprland..."
hyprctl reload 2>/dev/null || echo "Hyprctl not available (not in Hyprland session?)"

# Check status
echo ""
echo "=== Status ==="
echo "hyprwhspr: $(systemctl --user is-active hyprwhspr)"
echo "ydotool:   $(systemctl --user is-active ydotool)"
echo ""
echo "=== Done! ==="
echo "Press Ctrl+Space to start voice dictation"
