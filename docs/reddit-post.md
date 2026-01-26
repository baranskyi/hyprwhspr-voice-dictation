# Reddit Post: Voice Dictation for Hyprland

## Title (for r/hyprland)
```
Ctrl+Space voice dictation on Hyprland — 100+ languages, works anywhere
```

## Title (for r/archlinux)
```
[Guide] Voice dictation on Arch/Hyprland with OpenAI Whisper — Ctrl+Space to speak
```

---

## Post Body

I set up voice dictation on my Hyprland setup and wanted to share — it's been a game changer for quick notes, messages, and even coding comments.

### What it does
- **Ctrl+Space** — start/stop recording
- Speak in any language (Whisper auto-detects)
- Text appears where your cursor is
- Works in any app — terminals, browsers, editors

### The setup

Uses [hyprwhspr](https://github.com/goodroot/hyprwhspr) (AUR) + OpenAI Whisper API.

**Quick start:**
```bash
yay -S hyprwhspr ydotool wl-clipboard playerctl
sudo usermod -aG input $USER
# REBOOT after this
```

Then grab the configs from my repo: https://github.com/baranskyi/hyprwhspr-voice-dictation

### Cost
OpenAI charges $0.003/minute. A typical voice command is 5-10 seconds = ~$0.001.
I use it ~50 times/day and pay less than $2/month.

### Languages tested
English, Russian, Spanish, German, French, Japanese, Chinese — all work perfectly. Whisper supports 100+ languages with auto-detection.

### Bonus features in my setup
- **Spotify auto-pause** — music pauses when recording starts
- **Visual OSD** — shows audio level so you know it's working
- **Mic volume fix** — PipeWire sometimes resets volume, script handles it

### Screenshot
[Add your screenshot here]

---

If anyone's interested in the systemd service setup or the Spotify integration script, it's all in the repo.

---

## Suggested subreddits

1. **r/hyprland** — most relevant audience
2. **r/archlinux** — for Arch-specific guide
3. **r/unixporn** — if you have a nice screenshot/GIF

## Tags to add
`hyprland`, `voice`, `dictation`, `whisper`, `openai`, `arch`
