#!/usr/bin/env bash
# Uma menubar por monitor; a bandeja (wifi, som, flameshot) só no principal
polybar-msg cmd quit >/dev/null 2>&1
killall -q polybar
# Espera até 2s; se alguma travar, força
for _ in $(seq 10); do pgrep -u $UID -x polybar >/dev/null || break; sleep 0.2; done
killall -q -9 polybar

primary=$(xrandr --query | awk '/ primary/{print $1}')
for m in $(polybar --list-monitors | cut -d: -f1); do
    if [ "$m" = "$primary" ]; then tray=tray; else tray=; fi
    MONITOR=$m TRAY=$tray polybar --reload minhabarra >/dev/null 2>&1 &
done
