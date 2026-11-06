#!/bin/sh
# Instala tudo numa máquina nova (Linux Mint 22 / Ubuntu 24.04). Pode rodar de novo sem problema.
# No Ubuntu com GNOME: depois de rodar, saia e escolha "bspwm" na engrenagem da tela de login (o GNOME continua lá).
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

# Shell: oh-my-zsh + spaceship + plugins (o .zshrc do repo depende deles)
if [ ! -d ~/.oh-my-zsh ]; then
    echo "==> oh-my-zsh"
    RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi
custom=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
for repo in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
    d="$custom/plugins/${repo#*/}"
    [ -d "$d" ] || git clone -q --depth 1 "https://github.com/$repo.git" "$d"
done
if [ ! -d "$custom/themes/spaceship-prompt" ]; then
    git clone -q --depth 1 https://github.com/spaceship-prompt/spaceship-prompt.git "$custom/themes/spaceship-prompt"
    ln -sf "$custom/themes/spaceship-prompt/spaceship.zsh-theme" "$custom/themes/spaceship.zsh-theme"
fi
# O instalador do oh-my-zsh cria um ~/.zshrc próprio; tira do caminho pro stow
if [ -f ~/.zshrc ] && [ ! -L ~/.zshrc ]; then
    mv ~/.zshrc ~/.zshrc.pre-dotfiles
fi
if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
    echo "==> zsh como shell padrão"
    chsh -s "$(command -v zsh)"
fi

echo "==> zram, earlyoom e sysctl"
sudo sh system/aplicar.sh

echo "==> Visão geral das janelas e gestos do touchpad"
sh system/visao-geral.sh

echo "==> Links (stow)"
stow --restow -t ~ bspwm dunst gestures kitty picom polybar rofi scripts skippy sxhkd wallpaper zsh

echo "==> Pronto. Entre numa sessão bspwm (ou Super+Esc se já estiver nela)."
