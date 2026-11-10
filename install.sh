#!/bin/sh
# Instala tudo numa máquina nova (Linux Mint 22 / Ubuntu 24.04). Pode rodar de novo sem problema.
# No Ubuntu com GNOME: depois de rodar, saia e escolha "bspwm" na engrenagem da tela de login (o GNOME continua lá).
#
# Cada etapa roda isolada: se uma falhar, o script segue pras próximas (o stow, que liga as configs,
# sempre roda) e no fim lista o que falhou. Corrija e rode de novo.
cd "$(dirname "$0")" || exit 1
DIR=$PWD
FALHAS=""

# etapa "nome" funcao  -> roda a função num subshell com set -e e anota se falhar
etapa() {
    echo
    echo "==> $1"
    ( set -e; $2 )
    rc=$?
    if [ $rc -ne 0 ]; then
        echo "!!! FALHOU: $1 (código $rc)"
        FALHAS="$FALHAS
  - $1"
    fi
}

pacotes() {
    sudo apt update
    lista=$(grep -v '^\s*\(#\|$\)' packages.txt)
    # Tudo de uma vez; se algum pacote não existir nesta distro, instala um por um e lista os que faltaram
    # shellcheck disable=SC2086
    if ! sudo apt install -y $lista; then
        faltou=""
        for p in $lista; do
            sudo apt install -y "$p" >/dev/null 2>&1 || faltou="$faltou $p"
        done
        [ -z "$faltou" ] || { echo "Pacotes que não instalaram:$faltou"; return 1; }
    fi
}

greenclip() {
    mkdir -p ~/.local/bin
    [ -x ~/.local/bin/greenclip ] && return 0
    curl -fL -o ~/.local/bin/greenclip https://github.com/erebe/greenclip/releases/download/v4.2/greenclip
    chmod +x ~/.local/bin/greenclip
}

fonte() {
    fc-list | grep -q 'Symbols Nerd Font' && return 0
    mkdir -p ~/.local/share/fonts
    tmp=$(mktemp -d)
    curl -fL -o "$tmp/s.zip" https://github.com/ryanoasis/nerd-fonts/releases/latest/download/NerdFontsSymbolsOnly.zip
    unzip -oq "$tmp/s.zip" -d ~/.local/share/fonts/NerdSymbols
    rm -r "$tmp"
    fc-cache -f
}

# Wallpaper e tela de bloqueio (gerados, não ficam no git)
wallpaper() {
    wall=wallpaper/.local/share/wallpapers/silk.png
    mkdir -p "$(dirname "$wall")"
    [ -f "$wall" ] || python3 extras/wallgen.py "$wall"
}

# oh-my-zsh + spaceship + plugins (o .zshrc do repo depende deles)
shell_zsh() {
    if [ ! -d ~/.oh-my-zsh ]; then
        RUNZSH=no CHSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    fi
    custom=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}
    for repo in zsh-users/zsh-autosuggestions zsh-users/zsh-syntax-highlighting; do
        d="$custom/plugins/${repo#*/}"
        [ -d "$d" ] || git clone -q --depth 1 "https://github.com/$repo.git" "$d"
    done
    if [ ! -d "$custom/themes/spaceship-prompt" ]; then
        git clone -q --depth 1 https://github.com/spaceship-prompt/spaceship-prompt.git "$custom/themes/spaceship-prompt"
    fi
    ln -sf "$custom/themes/spaceship-prompt/spaceship.zsh-theme" "$custom/themes/spaceship.zsh-theme"
    if [ "$(getent passwd "$USER" | cut -d: -f7)" != "$(command -v zsh)" ]; then
        echo "Trocando o shell padrão pra zsh (pede sua senha; vale depois de sair e entrar na sessão)"
        chsh -s "$(command -v zsh)"
    fi
}

# A polybar usa locale pt_BR (data em português). Ubuntu instalado em inglês não tem esse locale
# gerado, e aí os módulos de RAM, bateria e data/hora somem da barra
locale_ptbr() {
    locale -a | grep -qi '^pt_BR\.utf-\?8$' && return 0
    sudo locale-gen pt_BR.UTF-8
}

sistema()     { sudo sh system/aplicar.sh; }
visao_geral() { sh system/visao-geral.sh; }

# Liga as configs. Arquivo comum que já exista no lugar (ex: ~/.zshrc do oh-my-zsh,
# configs padrão do Ubuntu) vai pra ~/.dotfiles-backup-DATA em vez de travar o stow
links() {
    pkgs="bspwm dunst gestures kitty picom polybar rofi scripts skippy sxhkd wallpaper zsh"
    mkdir -p ~/.local/bin ~/.local/share ~/.config
    backup=~/.dotfiles-backup-$(date +%Y%m%d-%H%M%S)
    # shellcheck disable=SC2086
    stow -n -t ~ $pkgs 2>&1 | sed -n 's/.*existing target \(is neither a link nor a directory\|is not owned by stow\): //p' \
        | while read -r alvo; do
            [ -n "$alvo" ] || continue
            mkdir -p "$backup/$(dirname "$alvo")"
            mv ~/"$alvo" "$backup/$alvo"
            echo "backup: ~/$alvo -> $backup/$alvo"
        done
    # shellcheck disable=SC2086
    stow --restow -t ~ $pkgs
}

etapa "Pacotes do apt"                         pacotes
etapa "greenclip"                              greenclip
etapa "Symbols Nerd Font"                      fonte
etapa "Wallpaper"                              wallpaper
etapa "zsh + oh-my-zsh + spaceship"            shell_zsh
etapa "Locale pt_BR (polybar)"                  locale_ptbr
etapa "Links das configs (stow)"               links
etapa "zram, earlyoom e sysctl"                sistema
etapa "Visão geral das janelas (skippy-xd)"    visao_geral

echo
if [ -z "$FALHAS" ]; then
    echo "==> Pronto. Saia da sessão e escolha bspwm na engrenagem (ou Super+Esc se já estiver nele)."
else
    echo "==> Terminou, mas estas etapas falharam (o erro está acima de cada '!!! FALHOU'):$FALHAS"
    echo "    Rode ./install.sh de novo depois de corrigir; o que já deu certo é pulado."
    exit 1
fi
