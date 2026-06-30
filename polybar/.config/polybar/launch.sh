#!/usr/bin/env bash
# Encerra qualquer polybar que já esteja rodando
killall -q polybar
# Aguarda o processo fechar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
# Inicia a nova barra
polybar minhabarra &
