#!/bin/bash
if pgrep -x qs >/dev/null; then
    pkill -x qs
else
    nohup qs >/dev/null 2>&1 &
    sleep 0.3
    hyprctl dispatch focuswindow 'quickshell' 2>/dev/null
fi
