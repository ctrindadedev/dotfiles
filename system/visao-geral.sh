#!/bin/sh
# Visão geral das janelas estilo Mission Control: skippy-xd (compilado) + gestos do touchpad (libinput-gestures).
# Rodar como usuário (pede sudo só pros pacotes e pro grupo input): sh system/visao-geral.sh
# O .deb do skippy-xd é feito pro Debian (libpng/libjpeg diferentes do Mint), por isso compila.
set -e
[ "$(id -u)" = 0 ] && { echo "Rode como usuário normal, não com sudo"; exit 1; }

sudo apt install -y meson ninja-build cmake pkg-config git \
    libx11-dev libxcomposite-dev libxdamage-dev libxext-dev libxfixes-dev libxft-dev libxrender-dev \
    libxinerama-dev libxi-dev libgif-dev libjpeg-dev libpng-dev libchipmunk-dev \
    libinput-tools wmctrl
# Ler os eventos do touchpad exige o grupo input (vale depois de sair e entrar na sessão)
sudo usermod -aG input "$USER"

src=$(mktemp -d)
trap 'rm -rf "$src"' EXIT

echo "==> skippy-xd"
git clone -q --depth 1 https://github.com/felixfung/skippy-xd.git "$src/skippy-xd"
cd "$src/skippy-xd"
meson setup build --prefix="$HOME/.local"
meson compile -C build
meson install -C build --quiet

echo "==> libinput-gestures"
git clone -q --depth 1 https://github.com/bulletmark/libinput-gestures.git "$src/libinput-gestures"
install -m 755 "$src/libinput-gestures/libinput-gestures" "$HOME/.local/bin/libinput-gestures"

echo "==> Pronto. Saia e entre de novo na sessão (grupo input) e aperte Super+Esc."
