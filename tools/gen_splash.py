import math
import random
from PIL import Image, ImageDraw, ImageFont

SONG = "/System/Library/Fonts/Supplemental/Songti.ttc"
SONG_IDX = 1
W, H = 1080, 1920

from PIL import ImageFilter as _IF
from collections import deque

def load_beast():
    # 用原始神兽图（含蓝云）。仅去掉最外圈金环，保留神兽本体与蓝云。
    src = "android/app/src/main/assets/text/icon_beast.png"
    im = Image.open(src).convert("RGBA")
    px = im.load()
    bw, bh = im.size
    cx, cy = bw / 2, bh / 2
    def is_gold(r, g, b):
        return r > 150 and g > 110 and b < 150 and (g - b) > 35 and (r - g) > -45
    # outermost gold radius per 5deg bucket -> the ring
    buckets = {}
    golds = []
    for y in range(bh):
        for x in range(bw):
            r, g, b, a = px[x, y]
            if a == 0:
                continue
            d = math.hypot(x - cx, y - cy)
            ang = int(math.degrees(math.atan2(y - cy, x - cx)) // 5) * 5
            if is_gold(r, g, b):
                golds.append((x, y, d, ang))
                buckets[ang] = max(buckets.get(ang, 0), d)
    if buckets:
        for x, y, d, ang in golds:
            if d >= buckets[ang] - 7:  # 仅最外圈金环
                px[x, y] = (px[x, y][0], px[x, y][1], px[x, y][2], 0)
    return im.filter(_IF.GaussianBlur(0.3))

def bold(d, xy, text, font, fill, anchor="mm", sw=4):
    d.text(xy, text, font=font, fill=fill, anchor=anchor,
           stroke_width=sw, stroke_fill=fill)

def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))

def paper_bg(base):
    # 纯色底板，保证框外框内色一致，无边框无暗角
    return Image.new("RGBA", (W, H), base + (255,))

def make_splash(beast, dark):
    if dark:
        base = (0, 0, 0)
        cinnabar = (224, 90, 48); ink = (200, 185, 160)
    else:
        base = (236, 226, 198)
        cinnabar = (199, 60, 30); ink = (92, 66, 42)
    img = paper_bg(base)
    d = ImageDraw.Draw(img)
    # 神兽（保留蓝云，仅去金环，尺寸 626）
    bs = 626
    b = beast.resize((bs, bs))
    img.alpha_composite(b, (W // 2 - bs // 2, 20))
    f1 = ImageFont.truetype(SONG, 144, index=SONG_IDX)
    f_py = ImageFont.truetype(SONG, 60, index=SONG_IDX)
    f_tag = ImageFont.truetype(SONG, 38, index=SONG_IDX)
    # 两端对齐：首字左端=100，末字右端=980，字间均匀留白
    L, R = 100, 980
    def draw_justify(text, y, font, fill, bold_flag=False):
        ws = [font.getlength(c) for c in text]
        total = sum(ws)
        n = len(text)
        gap = (R - L - total) / (n - 1) if n > 1 else 0
        x = L
        centers = []
        for i, c in enumerate(text):
            cx = x + ws[i] / 2
            if bold_flag:
                bold(d, (cx, y), c, font=font, fill=fill)
            else:
                d.text((cx, y), c, font=font, fill=fill, anchor="mm")
            centers.append(cx)
            x += ws[i] + gap
        return centers
    # line1: 文绉绉（朱砂红）
    draw_justify("文绉绉", 850, f1, cinnabar + (255,), bold_flag=True)
    # line2: 甪端字游（拼音逐字对齐在其上方，墨色）
    line2 = "甪端字游"
    syll = ["lù", "duān", "zì", "yóu"]
    centers2 = draw_justify(line2, 1120, f1, cinnabar + (255,), bold_flag=True)
    for s, cx in zip(syll, centers2):
        d.text((cx, 1005), s, font=f_py, fill=ink + (255,), anchor="mm")
    # 标语（墨色，左右两端与甪端字游对齐）
    draw_justify("骑神兽 · 游典籍 · 通古今 · 破万关", 1310, f_tag, ink + (255,))
    draw_justify("日行万里 · 通解百家 · 专守书案", 1380, f_tag, ink + (255,))
    return img

beast = load_beast()
beast.save("android/app/src/main/res/drawable/splash_beast.png")

light = make_splash(beast, False)
light.save("android/app/src/main/res/drawable-nodpi/launch_bg.png")
light.save("android/app/src/main/assets/text/launch_bg_light.png")

dark = make_splash(beast, True)
dark.save("android/app/src/main/assets/text/launch_bg_dark.png")
print("生成完成")
