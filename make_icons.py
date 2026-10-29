# -*- coding: utf-8 -*-
"""生成手势花朵 PWA 图标：暗色底 + 粉色五瓣花 + 金色花蕊"""
from PIL import Image, ImageDraw, ImageFilter
import math
import os

OUT = os.path.join(os.path.dirname(__file__), 'icons')
os.makedirs(OUT, exist_ok=True)

S = 1024  # 超采样


def radial_bg(size):
    """中心微亮的暗色背景"""
    img = Image.new('RGB', (size, size), (7, 6, 11))
    glow = Image.new('L', (size, size), 0)
    d = ImageDraw.Draw(glow)
    cx = cy = size // 2
    r = int(size * 0.52)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=90)
    glow = glow.filter(ImageFilter.GaussianBlur(size * 0.18))
    tint = Image.new('RGB', (size, size), (48, 26, 62))
    img = Image.composite(tint, img, glow)
    return img


def flower_layer(size, scale=1.0):
    """返回 RGBA 花图层（花瓣 + 花蕊）"""
    layer = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    cx = cy = size // 2

    petals = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    pd = ImageDraw.Draw(petals)

    petal_w = 228 * scale
    petal_h = 250 * scale
    dist = 150 * scale      # 花瓣中心到花心的距离（重叠形成花型）
    tip_y = cy - dist

    # 单枚花瓣（竖直朝上）
    pd.ellipse(
        [cx - petal_w / 2, tip_y - petal_h / 2, cx + petal_w / 2, tip_y + petal_h / 2],
        fill=(255, 107, 157, 240),
        outline=(120, 36, 74, 255),
        width=max(2, int(3 * scale)),
    )

    # 叠加一点浅色高光
    hi = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    hd = ImageDraw.Draw(hi)
    hd.ellipse(
        [cx - petal_w * 0.30, tip_y - petal_h * 0.42,
         cx + petal_w * 0.30, tip_y + petal_h * 0.05],
        fill=(255, 196, 219, 120),
    )

    for i in range(5):
        ang = i * 72
        p = petals.rotate(ang, center=(cx, cy), resample=Image.BICUBIC)
        h = hi.rotate(ang, center=(cx, cy), resample=Image.BICUBIC)
        layer = Image.alpha_composite(layer, p)
        layer = Image.alpha_composite(layer, h)

    # 花瓣外发光
    glow = layer.filter(ImageFilter.GaussianBlur(26 * scale))
    glow = Image.eval(glow, lambda v: v)  # keep alpha
    layer = Image.alpha_composite(glow, layer)

    # 花蕊：金色光核
    pistil = Image.new('RGBA', (size, size), (0, 0, 0, 0))
    d2 = ImageDraw.Draw(pistil)
    r1 = 92 * scale
    d2.ellipse([cx - r1, cy - r1, cx + r1, cy + r1], fill=(255, 214, 74, 255))
    r2 = 52 * scale
    d2.ellipse([cx - r2, cy - r2, cx + r2, cy + r2], fill=(255, 246, 200, 255))

    g2 = pistil.filter(ImageFilter.GaussianBlur(30 * scale))
    layer = Image.alpha_composite(layer, g2)
    layer = Image.alpha_composite(layer, pistil)
    return layer


def build(size, scale=1.0, pad_ratio=0.0):
    img = radial_bg(S).convert('RGBA')
    fl = flower_layer(S, scale)
    if pad_ratio > 0:
        # maskable：缩小主体，保证在安全区内
        inner = Image.new('RGBA', (S, S), (0, 0, 0, 0))
        small = fl.resize((int(S * (1 - pad_ratio * 2)), int(S * (1 - pad_ratio * 2))), Image.LANCZOS)
        off = int(S * pad_ratio)
        inner.paste(small, (off, off), small)
        fl = inner
    img = Image.alpha_composite(img, fl)
    return img.convert('RGB').resize((size, size), Image.LANCZOS)


build(192).save(os.path.join(OUT, 'icon-192.png'))
build(512).save(os.path.join(OUT, 'icon-512.png'))
build(512, pad_ratio=0.10).save(os.path.join(OUT, 'icon-512-maskable.png'))
build(180).save(os.path.join(OUT, 'icon-180.png'))
print('icons done:', os.listdir(OUT))
