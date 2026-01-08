# Hyprwhspr Voice Dictation Setup

Voice dictation system for Hyprland using OpenAI Whisper API.

## Features
- **Hotkey**: `Ctrl+Space` to toggle recording
- **Visual indicator**: Centered OSD with audio level and recording dot
- **Fast transcription**: OpenAI gpt-4o-mini-transcribe model
- **Auto-paste**: Text automatically inserted via ydotool
- **Spotify integration**: Auto-pause on record, auto-resume on stop

## Requirements
- hyprwhspr (AUR package)
- ydotool
- wl-clipboard (wl-copy, wl-paste)
- PipeWire/PulseAudio
- playerctl (for Spotify integration)

## Installation

### 1. Install packages
```bash
yay -S hyprwhspr ydotool wl-clipboard playerctl
```

### 2. Add user to input group
```bash
sudo usermod -aG input $USER
# REBOOT REQUIRED after this!
```

### 3. Copy config files
```bash
# Hyprwhspr config
cp configs/config.json ~/.config/hyprwhspr/

# Credentials (API key)
mkdir -p ~/.local/share/hyprwhspr
cp configs/credentials.json ~/.local/share/hyprwhspr/credentials
chmod 600 ~/.local/share/hyprwhspr/credentials

# Systemd service
cp configs/hyprwhspr.service ~/.config/systemd/user/
```

### 4. Install toggle script (with Spotify integration)
```bash
cp configs/hyprwhspr-toggle.sh ~/.local/bin/
chmod +x ~/.local/bin/hyprwhspr-toggle.sh
```

### 5. Add Hyprland binding
Add to `~/.config/hypr/hyprland.conf`:
```bash
bindd = CTRL, space, Voice dictation toggle, exec, ~/.local/bin/hyprwhspr-toggle.sh
```

### 6. Enable and start services
```bash
systemctl --user daemon-reload
systemctl --user enable --now hyprwhspr ydotool
```

### 7. Reload Hyprland
```bash
hyprctl reload
```

## Configuration

### API Key
OpenAI API key stored in `~/.local/share/hyprwhspr/credentials`:
```json
{
  "openai": "sk-proj-YOUR-API-KEY"
}
```

### Model
Using `gpt-4o-mini-transcribe` for fast transcription.
Can be changed in `config.json` → `rest_body.model`

## Customization

### Smaller OSD (200x50 instead of 400x68)
```bash
sudo sed -i "s/sys.argv = \['mic-osd', '--daemon'\]/sys.argv = ['mic-osd', '--daemon', '-w', '200', '-H', '50']/" /usr/lib/hyprwhspr/lib/mic_osd/runner.py
pkill -9 -f mic_osd; systemctl --user restart hyprwhspr
```
Note: Height must be at least 50 (padding is 16*2=32, leaving room for bars).

## Troubleshooting

### OSD bars not moving
```bash
# Check mic volume - should be 100%
pactl get-source-volume @DEFAULT_SOURCE@

# Set to 100% if low
pactl set-source-volume @DEFAULT_SOURCE@ 100%
```

### ERR in waybar - ydotoold
```bash
# Check if user in input group
groups  # should show 'input'

# If not, add and REBOOT
sudo usermod -aG input $USER
```

### wl-copy fails in service
Add to systemd service `[Service]` section:
```ini
PassEnvironment=WAYLAND_DISPLAY XDG_RUNTIME_DIR DISPLAY
```

### Service not starting
```bash
systemctl --user status hyprwhspr
journalctl --user -u hyprwhspr -f
```

## Files

| File | Purpose |
|------|---------|
| `~/.config/hyprwhspr/config.json` | Main configuration |
| `~/.local/share/hyprwhspr/credentials` | API key storage |
| `~/.config/systemd/user/hyprwhspr.service` | Systemd service |
| `~/.local/bin/hyprwhspr-toggle.sh` | Toggle script with Spotify control |
| `~/.config/hypr/hyprland.conf` | Hyprland keybinding |

## Services

Both services must be enabled:
```bash
systemctl --user enable hyprwhspr ydotool
```

## Credits
- hyprwhspr: https://github.com/goodroot/hyprwhspr
- OpenAI Whisper API
