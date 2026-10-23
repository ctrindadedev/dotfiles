#!/bin/sh
# Aplica as configs de sistema (precisa de root): sudo sh system/aplicar.sh
set -e
cd "$(dirname "$0")"
apt install -y zram-tools earlyoom
install -m 644 zramswap /etc/default/zramswap
install -m 644 earlyoom /etc/default/earlyoom
install -m 644 99-zram.conf /etc/sysctl.d/99-zram.conf
sysctl -q --system
systemctl restart zramswap
systemctl enable --now earlyoom
systemctl restart earlyoom
echo "==> zram:"; zramctl
echo "==> earlyoom: $(systemctl is-active earlyoom)"
