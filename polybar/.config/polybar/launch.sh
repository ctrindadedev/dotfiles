#!/usr/bin/env bash
# Uma menubar por monitor; a bandeja (wifi, som, flameshot) só no principal
polybar-msg cmd quit >/dev/null 2>&1
killall -q polybar
# Espera até 2s; se alguma travar, força
for _ in $(seq 10); do pgrep -u $UID -x polybar >/dev/null || break; sleep 0.2; done
killall -q -9 polybar

primary=$(xrandr --query | awk '/ primary/{print $1}')
# No espelhamento os monitores ficam na mesma posição: uma barra só, a do principal
monitors=$(polybar --list-monitors | sort -t'(' -k2r |
    awk -F': ' '{ pos = $2; sub(/^[0-9]+x[0-9]+/, "", pos); sub(/ .*/, "", pos); if (!seen[pos]++) print $1 }')
for m in $monitors; do
    if [ "$m" = "$primary" ]; then tray=tray; else tray=; fi
    MONITOR=$m TRAY=$tray polybar --reload minhabarra >/dev/null 2>&1 &
done
