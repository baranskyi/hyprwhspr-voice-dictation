#!/bin/bash
# Hyprwhspr toggle with Spotify pause/resume

STATUS_FILE=~/.config/hyprwhspr/recording_status
CONTROL_FILE=~/.config/hyprwhspr/recording_control
PLAYER_STATE_FILE=/tmp/hyprwhspr_player_state

if [ "$(cat $STATUS_FILE 2>/dev/null)" = "true" ]; then
    # Stop recording
    echo stop > $CONTROL_FILE
    # Resume Spotify if it was playing
    if [ -f "$PLAYER_STATE_FILE" ] && [ "$(cat $PLAYER_STATE_FILE)" = "Playing" ]; then
        sleep 0.5
        playerctl -p spotify play 2>/dev/null
    fi
    rm -f $PLAYER_STATE_FILE
else
    # Start recording
    # Ensure mic volume is 100% (PipeWire sometimes resets it)
    pactl set-source-volume @DEFAULT_SOURCE@ 100%
    # Save Spotify status
    playerctl -p spotify status > $PLAYER_STATE_FILE 2>/dev/null || echo "Stopped" > $PLAYER_STATE_FILE
    # Pause Spotify if playing
    playerctl -p spotify pause 2>/dev/null
    echo start > $CONTROL_FILE
fi
