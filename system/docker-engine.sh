#!/bin/sh
# Docker Engine nativo (sem VM) no lugar do Docker Desktop: sudo sh system/docker-engine.sh
# Fica fora do install.sh porque precisa do repositório da Docker, que o Mint não traz
set -e
cd "$(dirname "$0")"

if [ ! -f /etc/apt/sources.list.d/docker.list ]; then
    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    . /etc/os-release
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $UBUNTU_CODENAME stable" \
        > /etc/apt/sources.list.d/docker.list
    apt update
fi
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

# Logs com rotação e limpeza automática do cache de build
install -m 644 docker-daemon.json /etc/docker/daemon.json
dockerd --validate --config-file /etc/docker/daemon.json

# Não sobe no boot: o docker.socket acorda o daemon no primeiro comando docker (0 MB até lá)
systemctl disable --now docker.service containerd.service
systemctl enable --now docker.socket

usermod -aG docker "${SUDO_USER:-$USER}"
echo "==> Pronto. Saia e entre de novo na sessão pra usar docker sem sudo (ou use: sg docker -c '...')"
