#!/bin/bash
# Fix OSD audio verification in daemon mode
# Run with: sudo bash apply-osd-fix.sh

FILE="/usr/lib/hyprwhspr/lib/mic_osd/main.py"

if [ ! -f "$FILE" ]; then
    echo "Error: $FILE not found"
    exit 1
fi

# Backup
cp "$FILE" "${FILE}.bak"

# The fix: wrap audio verification in "if not self.daemon:" block
# Find the line with "# Verify that audio stream" and add condition

python3 << 'PYTHON'
import re

with open("/usr/lib/hyprwhspr/lib/mic_osd/main.py", "r") as f:
    content = f.read()

# Pattern to find the audio verification block
old_block = '''        # Verify that audio stream is actually receiving audio (not just zeros)
        # This prevents showing window when mic is unplugged but stream opens successfully
        import time
        verification_start = time.monotonic()
        verification_duration = 0.25  # 250ms verification period
        max_zero_level = 1e-6  # Threshold for considering audio as zero (very small)
        audio_detected = False

        while time.monotonic() - verification_start < verification_duration:
            level = self.audio_monitor.get_level()
            if level > max_zero_level:
                audio_detected = True
                break
            time.sleep(0.01)  # Check every 10ms

        if not audio_detected:
            # Stream is returning zeros - mic likely unavailable
            print("[MIC-OSD] Audio stream returning zeros - hiding window", flush=True)
            self.audio_monitor.stop()
            self.visible = False
            self.window.set_visible(False)
            return  # Exit early - don't start timers'''

new_block = '''        # Verify that audio stream is actually receiving audio (not just zeros)
        # This prevents showing window when mic is unplugged but stream opens successfully
        # Skip in daemon mode - user may not have started speaking yet
        if not self.daemon:
            import time
            verification_start = time.monotonic()
            verification_duration = 0.25  # 250ms verification period
            max_zero_level = 1e-6  # Threshold for considering audio as zero (very small)
            audio_detected = False

            while time.monotonic() - verification_start < verification_duration:
                level = self.audio_monitor.get_level()
                if level > max_zero_level:
                    audio_detected = True
                    break
                time.sleep(0.01)  # Check every 10ms

            if not audio_detected:
                # Stream is returning zeros - mic likely unavailable
                print("[MIC-OSD] Audio stream returning zeros - hiding window", flush=True)
                self.audio_monitor.stop()
                self.visible = False
                self.window.set_visible(False)
                return  # Exit early - don't start timers'''

if old_block in content:
    content = content.replace(old_block, new_block)
    with open("/usr/lib/hyprwhspr/lib/mic_osd/main.py", "w") as f:
        f.write(content)
    print("Fix applied successfully!")
else:
    print("Warning: Could not find exact block to patch. File may have been modified already.")
    exit(1)
PYTHON

echo ""
echo "Fix applied! Now restart the service:"
echo "  systemctl --user restart hyprwhspr"
echo ""
echo "Then test with Ctrl+Space"
