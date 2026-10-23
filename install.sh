#!/bin/sh
# Instala tudo numa máquina nova (Linux Mint 22 / Ubuntu 24.04). Pode rodar de novo sem problema.
set -e
cd "$(dirname "$0")"

echo "==> Pacotes do apt"
sudo apt update
grep -v '^\s*\(#\|$\)' packages.txt | xargs sudo apt install -y

mkdir -p ~/.local/bin ~/.local/share/fonts

# Histórico do clipboard (não tem no apt)
if [ ! -x ~/.local/bin/greenclip ]; then
    echo "==> greenclip"
    curl -fL -o ~/.local/bin/greenclip https://github.com/erebe/greenclip/releases/download/v4.2/greenclip
    chmod +x ~/.local/bin/greenclip
fi

# Ícones da polybar/rofi
if ! fc-list | grep -q 'Symbols Nerd Font'; then
    echo "==> Symbols Nerd Font"
    tmp=$(mktemp -d)
    curl -fL -o "$tmp/s.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip
    unzip -oq "$tmp/s.zip" -d ~/.local/share/fonts/NerdSymbols
    rm -r "$tmp"
    fc-cache -f
fi

# Wallpaper e tela de bloqueio (gerados, não ficam no git)
wall=wallpaper/.local/share/wallpapers/silk.png
if [ ! -f "$wall" ]; then
    echo "==> Gerando wallpaper"
    python3 extras/wallgen.py "$wall"
fi

echo "==> zram, earlyoom e sysctl"
sudo sh system/aplicar.sh

echo "==> Links (stow)"
stow --restow -t ~ bspwm dunst kitty picom polybar rofi scripts sxhkd wallpaper zsh

echo "==> Pronto. Entre numa sessão bspwm (ou Super+Esc se já estiver nela)."
