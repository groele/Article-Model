from PIL import Image, ImageDraw, ImageFont
import math
import os


ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), ".."))
OUT = os.path.join(ROOT, "output", "Fig12_deep_physical_mechanism.png")


def font(size, bold=False):
    names = ["arialbd.ttf" if bold else "arial.ttf", "calibri.ttf"]
    for name in names:
        try:
            return ImageFont.truetype(name, size)
        except OSError:
            pass
    return ImageFont.load_default()


W, H = 2200, 1500
img = Image.new("RGB", (W, H), "white")
d = ImageDraw.Draw(img)

F_TITLE = font(42, True)
F_HEAD = font(32, True)
F_TEXT = font(25)
F_SMALL = font(21)

INK = (32, 35, 38)
MUTED = (90, 96, 104)
BLUE = (54, 104, 196)
RED = (206, 72, 55)
ORANGE = (230, 146, 48)
GREEN = (54, 145, 105)
PURPLE = (117, 83, 177)
FILL = (246, 248, 252)


def text_center(box, txt, fnt, fill=INK):
    lines = txt.split("\n")
    heights = [d.textbbox((0, 0), line, font=fnt)[3] for line in lines]
    total = sum(heights) + (len(lines) - 1) * 8
    y = (box[1] + box[3] - total) / 2
    for line, hh in zip(lines, heights):
        bb = d.textbbox((0, 0), line, font=fnt)
        x = (box[0] + box[2] - (bb[2] - bb[0])) / 2
        d.text((x, y), line, font=fnt, fill=fill)
        y += hh + 8


def wrap_text(txt, fnt, max_width):
    words = txt.split()
    lines = []
    current = ""
    for word in words:
        test = word if not current else current + " " + word
        bb = d.textbbox((0, 0), test, font=fnt)
        if bb[2] - bb[0] <= max_width:
            current = test
        else:
            if current:
                lines.append(current)
            current = word
    if current:
        lines.append(current)
    return lines


def wrapped_text(x, y, txt, fnt, max_width, fill=MUTED, line_gap=8):
    for line in wrap_text(txt, fnt, max_width):
        d.text((x, y), line, font=fnt, fill=fill)
        bb = d.textbbox((0, 0), line, font=fnt)
        y += (bb[3] - bb[1]) + line_gap
    return y


def panel(x0, y0, x1, y1, label, title):
    d.rounded_rectangle((x0, y0, x1, y1), radius=14, outline=(205, 210, 218), width=3, fill=(252, 253, 255))
    d.text((x0 + 24, y0 + 18), label, font=F_HEAD, fill=INK)
    d.text((x0 + 76, y0 + 22), title, font=F_HEAD, fill=INK)


def arrow(a, b, color=INK, width=4):
    d.line((a, b), fill=color, width=width)
    ang = math.atan2(b[1] - a[1], b[0] - a[0])
    L = 18
    th = 0.48
    pts = [
        b,
        (b[0] - L * math.cos(ang - th), b[1] - L * math.sin(ang - th)),
        (b[0] - L * math.cos(ang + th), b[1] - L * math.sin(ang + th)),
    ]
    d.polygon(pts, fill=color)


def draw_atom(x, y, r, color, outline=(70, 70, 70)):
    d.ellipse((x - r, y - r, x + r, y + r), fill=color, outline=outline, width=2)


d.text((55, 35), "Bilayer ReS2 sliding-ferroelectric modulation: deeper physical picture", font=F_TITLE, fill=INK)
d.text((58, 92), "Electric field selects a polar stacking; the same sliding coordinate controls charge transfer, symmetry breaking, and anisotropic optical readouts.", font=F_TEXT, fill=MUTED)

panel(55, 155, 1055, 675, "A", "Low-symmetry bilayer sliding coordinate")
panel(1145, 155, 2145, 675, "B", "Anisotropic two-dimensional stacking landscape")
panel(55, 755, 1055, 1375, "C", "Interlayer charge transfer and vertical dipole")
panel(1145, 755, 2145, 1375, "D", "One order parameter, multiple experimental readouts")

# A. Top-view low-symmetry chains
base_x, base_y = 230, 325
dx, dy = 105, 70
shift = 58
for layer, off, color, alpha_label in [(0, 0, (110, 158, 222), "bottom layer"), (1, shift, (230, 132, 100), "top layer shifted by q")]:
    yoff = base_y + layer * 92
    for i in range(5):
        x = base_x + i * dx + off
        y = yoff + (i % 2) * 18
        draw_atom(x, y, 25, color)
        if i > 0:
            x0 = base_x + (i - 1) * dx + off
            y0 = yoff + ((i - 1) % 2) * 18
            d.line((x0, y0, x, y), fill=(80, 80, 80), width=5)
    d.text((740, yoff - 20), alpha_label, font=F_SMALL, fill=MUTED)

arrow((base_x + 4 * dx + 55, base_y + 110), (base_x + 4 * dx + 145, base_y + 110), RED, 5)
d.text((base_x + 4 * dx + 45, base_y + 135), "q along Re-chain / b-axis", font=F_SMALL, fill=RED)
d.line((base_x - 45, base_y + 65, base_x + 650, base_y + 65), fill=(210, 210, 210), width=2)
wrapped_text(120, 555, "Low symmetry confines the easy sliding path and makes Raman/PL strongly orientation-sensitive.", F_SMALL, 860)

# B. Heatmap stacking landscape
gx0, gy0, gw, gh = 1265, 270, 680, 330
for ix in range(gw):
    ua = -1.4 + 2.8 * ix / (gw - 1)
    for iy in range(gh):
        ub = -1.2 + 2.4 * iy / (gh - 1)
        U = 0.55 * (ua * ua - 0.85) ** 2 + 0.18 * ub * ub + 0.20 * math.sin(3.2 * ua + 0.8) * math.cos(2.1 * ub)
        U = max(0, min(1.4, U))
        t = U / 1.4
        col = (int(245 - 125 * t), int(246 - 115 * t), int(255 - 35 * t))
        d.point((gx0 + ix, gy0 + iy), fill=col)
d.rectangle((gx0, gy0, gx0 + gw, gy0 + gh), outline=INK, width=3)
d.text((gx0 + 280, gy0 + gh + 25), "u_a", font=F_SMALL, fill=INK)
d.text((gx0 - 48, gy0 + 140), "u_b", font=F_SMALL, fill=INK)
for ua, ub, col, lab in [(-0.8, 0.1, BLUE, "-Pz"), (0.88, -0.08, RED, "+Pz")]:
    x = gx0 + int((ua + 1.4) / 2.8 * gw)
    y = gy0 + int((ub + 1.2) / 2.4 * gh)
    d.ellipse((x - 18, y - 18, x + 18, y + 18), fill=col, outline="white", width=3)
    d.text((x + 24, y - 18), lab, font=F_SMALL, fill=col)
arrow((gx0 + 250, gy0 + 170), (gx0 + 420, gy0 + 150), ORANGE, 5)
wrapped_text(1220, 608, "Ez tilts this landscape by -Ez Pz(u). Switching occurs when a metastable well or domain wall releases.", F_SMALL, 850)

# C. Side view charge redistribution
xL, xR = 220, 860
yTop, yBot = 930, 1160
d.rounded_rectangle((xL, yTop - 28, xR, yTop + 28), radius=18, fill=(235, 238, 245), outline=INK, width=3)
d.rounded_rectangle((xL + 70, yBot - 28, xR + 70, yBot + 28), radius=18, fill=(235, 238, 245), outline=INK, width=3)
d.text((xL + 20, yTop - 80), "top ReS2 layer", font=F_SMALL, fill=MUTED)
d.text((xL + 90, yBot + 45), "bottom ReS2 layer", font=F_SMALL, fill=MUTED)
for i in range(9):
    draw_atom(xL + 45 + i * 70, yTop, 13, (122, 166, 220))
    draw_atom(xL + 115 + i * 70, yBot, 13, (230, 151, 116))
for x, y, sign, col in [(330, 1025, "e- depletion", RED), (690, 1065, "e- accumulation", BLUE)]:
    d.ellipse((x - 50, y - 26, x + 50, y + 26), fill=(255, 255, 255), outline=col, width=3)
    text_center((x - 50, y - 26, x + 50, y + 26), sign, F_SMALL, col)
arrow((520, 1120), (520, 980), GREEN, 6)
d.text((545, 1030), "Pz", font=F_HEAD, fill=GREEN)
wrapped_text(150, 1260, "The polar state is electronic plus structural: sliding changes registry, then charge density in the vdW gap becomes asymmetric.", F_SMALL, 830)

# D. Response map
cx, cy = 1605, 1000
d.ellipse((cx - 92, cy - 92, cx + 92, cy + 92), fill=(255, 250, 238), outline=ORANGE, width=5)
text_center((cx - 92, cy - 92, cx + 92, cy + 92), "q\nsliding\norder", F_TEXT, ORANGE)
readouts = [
    ((1285, 850, 1510, 930), "SHG\nchi(2), phase", PURPLE),
    ((1720, 850, 1995, 930), "Raman tensor\nR(q)", BLUE),
    ((1285, 1115, 1530, 1205), "Exciton H_X(q)\nenergy, axis", RED),
    ((1720, 1115, 1995, 1205), "Photocurrent\nbarrier, built-in field", GREEN),
]
for box, txt, col in readouts:
    d.rounded_rectangle(box, radius=10, fill=FILL, outline=col, width=4)
    text_center(box, txt, F_SMALL, INK)
    bx = (box[0] + box[2]) // 2
    by = (box[1] + box[3]) // 2
    start_x = cx + int(85 * (bx - cx) / max(1, abs(bx - cx) + abs(by - cy)))
    start_y = cy + int(85 * (by - cy) / max(1, abs(bx - cx) + abs(by - cy)))
    arrow((start_x, start_y), (bx, by), col, 4)
wrapped_text(1220, 1280, "Correlated hysteresis across these channels is key evidence for sliding-ferroelectric switching rather than simple electrostatic gating.", F_SMALL, 850)

os.makedirs(os.path.dirname(OUT), exist_ok=True)
img.save(OUT)
print(OUT)
