# meus-dotfiles

bspwm com visual estilo macOS (polybar como menubar, Plank como dock, rofi como lançador), paleta Catppuccin Mocha.

## Instalar

```sh
git clone <este repo> ~/meus-dotfiles
~/meus-dotfiles/install.sh
```

No Ubuntu com GNOME (Wayland): rode o script, saia da sessão e na tela de login clique na engrenagem e escolha **bspwm**. O GNOME continua disponível como reserva.

Configurações só de uma máquina (trabalho, tokens, PATHs extras) vão em `~/.zshrc.local`, que o `.zshrc` carrega se existir e que não fica no git.

O script instala os pacotes de `packages.txt`, instala zsh + oh-my-zsh + spaceship + plugins (e troca o shell padrão), baixa o greenclip e a Symbols Nerd Font, gera o wallpaper (`extras/wallgen.py`) e cria os links com `stow`.

## Atalhos principais

| Tecla | Ação |
|---|---|
| Super + Enter | Terminal |
| Super + D / Super + Espaço | Menu de apps (tema adi1090x) |
| Alt + Tab | Alternar janelas |
| Super + E / 4 dedos pra cima | Visão geral das janelas (Mission Control) |
| Super + Shift + E / 4 dedos pra baixo | Visão geral dos desktops |
| 4 dedos pros lados | Trocar de desktop |
| Super + V | Histórico do clipboard |
| Super + ' | Terminal suspenso |
| Print / Super + Shift + S | Print de área |
| Shift + Print | Print da tela inteira |
| Super + Ctrl + Q | Bloquear tela |
| Super + N | Luz noturna (liga/desliga) |
| Super + F9 / tecla de projetor | Menu de telas |
| Super + Esc | Recarregar bspwm e atalhos |
| Super + 1…0 | Desktops (1-5 notebook, 6-10 HDMI) |

Sair do bspwm: menu do logo na barra → "Sair do bspwm".
