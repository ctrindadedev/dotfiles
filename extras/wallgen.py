# Wallpaper abstrato estilo macOS (ondas suaves) na paleta Catppuccin Mocha
import sys
import numpy as np
from PIL import Image, ImageFilter

W, H = 3840, 2160
out = sys.argv[1]
rng = np.random.default_rng(7)

y, x = np.mgrid[0:H, 0:W].astype(np.float32)
u, v = x / W, y / H

def hexc(h):
    return np.array([int(h[i:i + 2], 16) for i in (1, 3, 5)], np.float32) / 255

base = hexc("#11111B")
img = np.ones((H, W, 3), np.float32) * base

# Faixas onduladas sobrepostas, como as camadas de seda dos wallpapers do Sonoma
bands = [
    ("#1E1E2E", 0.78, 0.10, 2.1, 0.0, 0.30, 0.9),
    ("#45275F", 0.66, 0.09, 1.6, 1.2, 0.22, 0.9),
    ("#CBA6F7", 0.56, 0.07, 1.9, 2.4, 0.14, 0.75),
    ("#89B4FA", 0.47, 0.06, 1.4, 0.7, 0.12, 0.65),
    ("#F5C2E7", 0.40, 0.05, 2.3, 3.1, 0.08, 0.45),
    ("#74C7EC", 0.33, 0.05, 1.7, 4.0, 0.07, 0.35),
]
for color, center, amp, freq, phase, width, alpha in bands:
    c = hexc(color)
    curve = center + amp * np.sin(2 * np.pi * freq * u + phase) + 0.05 * np.sin(2 * np.pi * 3.3 * u + phase * 2)
    d = v - (1 - curve)  # positivo abaixo da curva
    # borda superior suave com brilho, preenchimento escurecendo pra baixo
    edge = np.exp(-(d / 0.012) ** 2) * 0.35
    fill = np.clip(d / width, 0, 1)
    body = (d > 0) * np.exp(-fill * 1.8)
    a = np.clip(body * alpha + edge * alpha, 0, 1)[..., None]
    shade = (0.55 + 0.45 * np.exp(-np.clip(d, 0, None) / 0.08))[..., None]
    img = img * (1 - a) + (c * shade) * a

# Vinheta para as bordas não brigarem com a barra e a dock
vig = 1 - 0.45 * (((u - 0.5) * 1.3) ** 2 + ((v - 0.45) * 1.6) ** 2)
img *= np.clip(vig, 0.5, 1)[..., None]

# Granulado leve contra banding
img += rng.normal(0, 1.2 / 255, img.shape).astype(np.float32)

im = Image.fromarray((np.clip(img, 0, 1) * 255).astype(np.uint8))
im = im.filter(ImageFilter.GaussianBlur(1.2))
im.save(out)
# Versão 1920x1080 para a tela de bloqueio (i3lock precisa do tamanho exato da tela)
im.resize((1920, 1080), Image.LANCZOS).save(out.replace(".png", "-lock.png"))
print("ok")
