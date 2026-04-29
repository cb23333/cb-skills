"""
Photo Doodle Annotator - 手绘涂鸦标注脚本
给下午茶照片添加手绘风格的中文注释
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import random
import math
import os
import sys

# Fix Windows font path encoding
import locale
locale.setlocale(locale.LC_ALL, 'en_US.UTF-8')


def get_font(size=20):
    """按优先级尝试加载手写风格中文字体"""
    font_candidates = [
        "ZCOOLKuaiLe-Regular.ttf",
        "ZCOOLKuaiLe.ttf",
        "ZCOOLXiaoWei-Regular.ttf",
        "MaShanZheng-Regular.ttf",
        "STKAITI.TTF",
        "LiuJianMaoCao-Regular.ttf",
        "simhei.ttf",
        "SimHei.ttf",
        "msyh.ttc",
        "MSYH.TTC",
    ]

    font_dirs = [
        "C:/Windows/Fonts",
        "/usr/share/fonts",
        "/usr/local/share/fonts",
    ]

    for font_name in font_candidates:
        for font_dir in font_dirs:
            if os.path.isdir(font_dir):
                font_path = os.path.join(font_dir, font_name)
                if os.path.exists(font_path):
                    try:
                        return ImageFont.truetype(font_path, size), font_name
                    except Exception:
                        continue

    return ImageFont.load_default(), "default"


def get_avg_brightness(img, x, y, radius=20):
    """获取图片某位置周围的平均亮度"""
    w, h = img.size
    x0, y0 = max(0, x - radius), max(0, y - radius)
    x1, y1 = min(w, x + radius), min(h, y + radius)
    region = img.crop((x0, y0, x1, y1)).convert("L")
    pixels = list(region.getdata())
    return sum(pixels) / len(pixels) if pixels else 128


def choose_color(base_img, x, y):
    """根据背景亮度选择注释颜色"""
    brightness = get_avg_brightness(base_img, x, y, radius=25)
    if brightness > 140:
        return (60, 60, 60)        # 亮背景用深色
    else:
        return (255, 255, 255)     # 暗背景用白色


def draw_wobbly_line(draw, start, end, color, width=2, wobble=2):
    """画一条带抖动的手绘风格线条"""
    points = []
    dist = math.dist(start, end)
    steps = max(int(dist / 3), 4)
    for i in range(steps + 1):
        t = i / steps
        x = start[0] + (end[0] - start[0]) * t + random.uniform(-wobble, wobble)
        y = start[1] + (end[1] - start[1]) * t + random.uniform(-wobble, wobble)
        points.append((x, y))
    for i in range(len(points) - 1):
        w = max(1, width + random.randint(-1, 1))
        draw.line([points[i], points[i + 1]], fill=color, width=w)


def draw_wobbly_ellipse(draw, bbox, color, width=2, wobble=3):
    """画一个带抖动的手绘风格椭圆"""
    cx = (bbox[0] + bbox[2]) / 2
    cy = (bbox[1] + bbox[3]) / 2
    rx = (bbox[2] - bbox[0]) / 2
    ry = (bbox[3] - bbox[1]) / 2

    points = []
    steps = max(int((rx + ry) / 3), 24)
    for i in range(steps + 1):
        angle = 2 * math.pi * i / steps
        x = cx + rx * math.cos(angle) + random.uniform(-wobble, wobble)
        y = cy + ry * math.sin(angle) + random.uniform(-wobble, wobble)
        points.append((x, y))

    for i in range(len(points) - 1):
        if random.random() < 0.12:
            continue
        w = max(1, width + random.randint(-1, 1))
        draw.line([points[i], points[i + 1]], fill=color, width=w)


def draw_dashed_line(draw, start, end, color, width=1, dash_len=8, gap_len=6):
    """画手绘风格虚线"""
    dist = math.dist(start, end)
    if dist < 1:
        return
    dx = (end[0] - start[0]) / dist
    dy = (end[1] - start[1]) / dist
    pos = 0
    while pos < dist:
        seg = dash_len + random.uniform(-3, 3)
        p1 = (start[0] + dx * pos, start[1] + dy * pos)
        p2_pos = min(pos + seg, dist)
        p2 = (start[0] + dx * p2_pos, start[1] + dy * p2_pos)
        draw_wobbly_line(draw, p1, p2, color, width, wobble=1)
        pos += dash_len + gap_len + random.uniform(-2, 2)


def draw_arrow(draw, start, end, color, width=2):
    """画手绘箭头"""
    draw_dashed_line(draw, start, end, color, width)
    angle = math.atan2(end[1] - start[1], end[0] - start[0])
    arrow_len = 10
    for a_offset in [0.75, -0.75]:
        a = angle + math.pi + a_offset
        ax = end[0] + arrow_len * math.cos(a) + random.uniform(-2, 2)
        ay = end[1] + arrow_len * math.sin(a) + random.uniform(-2, 2)
        draw_wobbly_line(draw, end, (ax, ay), color, width, wobble=1)


def draw_star(draw, center, size, color):
    """画一个小星星"""
    cx, cy = center
    points = []
    for i in range(10):
        angle = math.pi / 2 + i * math.pi / 5
        r = size if i % 2 == 0 else size * 0.4
        x = cx + r * math.cos(angle) + random.uniform(-1, 1)
        y = cy - r * math.sin(angle) + random.uniform(-1, 1)
        points.append((x, y))
    points.append(points[0])
    for i in range(len(points) - 1):
        draw.line([points[i], points[i + 1]], fill=color, width=1)


def draw_heart(draw, center, size, color):
    """画一个小爱心"""
    cx, cy = center
    points = []
    for i in range(40):
        t = i / 39 * 2 * math.pi
        x = size * 0.5 * (16 * math.sin(t) ** 3)
        y = -size * 0.5 * (13 * math.cos(t) - 5 * math.cos(2*t) - 2 * math.cos(3*t) - math.cos(4*t))
        points.append((cx + x/17 + random.uniform(-0.5, 0.5), cy + y/17 + random.uniform(-0.5, 0.5)))
    points.append(points[0])
    for i in range(len(points) - 1):
        draw.line([points[i], points[i + 1]], fill=color, width=1)


def draw_steam(draw, x, y, color):
    """画热气"""
    for i in range(3):
        sx = x + random.randint(-12, 12)
        pts = []
        for j in range(10):
            px = sx + math.sin(j * 0.7 + i) * 5 + random.uniform(-1, 1)
            py = y - j * 3
            pts.append((px, py))
        for k in range(len(pts) - 1):
            draw.line([pts[k], pts[k+1]], fill=color, width=1)


def draw_text_rotated(base_img, position, text, font, fill_color, angle=0):
    """在图片上画带旋转和描边的文字"""
    x, y = position
    is_dark = sum(fill_color) > 400
    outline_color = (0, 0, 0) if is_dark else (255, 255, 255)

    # 计算文字大小
    bbox = font.getbbox(text)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    pad = 6

    # 创建文字图层
    txt_img = Image.new("RGBA", (tw + pad * 2, th + pad * 2), (0, 0, 0, 0))
    txt_draw = ImageDraw.Draw(txt_img)

    # 描边
    for ox, oy in [(-1,0),(1,0),(0,-1),(0,1),(-1,-1),(1,1),(-1,1),(1,-1)]:
        txt_draw.text((pad + ox, pad + oy), text, font=font, fill=outline_color)
    # 文字
    txt_draw.text((pad, pad), text, font=font, fill=fill_color)

    # 旋转
    if abs(angle) > 0.5:
        txt_img = txt_img.rotate(angle, resample=Image.BICUBIC, expand=True)

    # 粘贴到主图
    base_img.paste(txt_img, (x - pad, y - pad), txt_img)
    return base_img


def annotate_photo(input_path, output_path):
    """给照片添加手绘标注"""
    random.seed(42)  # 可重复性，去掉就是每次随机

    img = Image.open(input_path).convert("RGBA")
    base = img.copy()
    w, h = img.size
    rgb_img = img.convert("RGB")

    font_size = max(20, min(w, h) // 25)
    font, font_name = get_font(font_size)
    print(f"Using font: {font_name}, size: {font_size}")

    # === 定义标注 ===
    # 图片尺寸 1278x962
    # 饮品大约在左中区域, 甜点在中间, 玫瑰在右侧, 窗户在上方

    annotations = [
        {
            "label": "今天的续命水",
            "text_pos": (100, 180),
            "target_pos": (340, 420),
            "outline_bbox": (270, 310, 430, 530),
            "decor": "steam",
            "decor_pos": (350, 300),
        },
        {
            "label": "软软的，好好吃",
            "text_pos": (520, 600),
            "target_pos": (580, 480),
            "outline_bbox": (470, 380, 700, 550),
            "decor": "heart",
            "decor_pos": (505, 630),
        },
        {
            "label": "花好美啊",
            "text_pos": (920, 280),
            "target_pos": (880, 430),
            "outline_bbox": (810, 370, 960, 520),
            "decor": "star",
            "decor_pos": (970, 260),
        },
        {
            "label": "阳光刚好 :)",
            "text_pos": (950, 50),
            "target_pos": None,
            "outline_bbox": None,
            "decor": "star",
            "decor_pos": (935, 55),
        },
        {
            "label": "被治愈的一个下午",
            "text_pos": (50, 870),
            "target_pos": None,
            "outline_bbox": None,
            "decor": "heart",
            "decor_pos": (340, 878),
        },
    ]

    # 创建 overlay 用于画线
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    for ann in annotations:
        label = ann["label"]
        tx, ty = ann["text_pos"]
        color = choose_color(rgb_img, tx, ty)

        # 画描边轮廓
        if ann.get("outline_bbox"):
            draw_wobbly_ellipse(draw, ann["outline_bbox"], color, width=2)

        # 画指引箭头
        if ann.get("target_pos"):
            # 从文字底部中点到目标
            font_bbox = font.getbbox(label)
            text_w = font_bbox[2] - font_bbox[0]
            anchor = (tx + text_w // 2, ty + font_size)
            draw_arrow(draw, anchor, ann["target_pos"], color, width=1)

        # 画小装饰
        decor = ann.get("decor")
        dpos = ann.get("decor_pos", (tx - 20, ty))
        if decor == "star":
            draw_star(draw, dpos, 8, color)
        elif decor == "heart":
            draw_heart(draw, dpos, 6, color)
        elif decor == "steam":
            draw_steam(draw, dpos[0], dpos[1], color)

    # 合成 overlay 到 base
    base = Image.alpha_composite(base, overlay)

    # 画文字（直接画到 base 上，支持旋转）
    for ann in annotations:
        tx, ty = ann["text_pos"]
        color = choose_color(rgb_img, tx, ty)
        angle = random.uniform(-3, 3)
        draw_text_rotated(base, (tx, ty), ann["label"], font, color, angle)

    # 保存
    output_ext = os.path.splitext(output_path)[1].lower()
    if output_ext in [".jpg", ".jpeg"]:
        base = base.convert("RGB")

    base.save(output_path, quality=95)
    print(f"Done! Saved to: {output_path}")
    return output_path


if __name__ == "__main__":
    input_file = r"C:\Users\12875\xwechat_files\wxid_kssosc1up9z322_4b45\temp\RWTemp\2026-04\d0a6ff35520a3132490d3efb0e7aee33.jpg"
    output_file = os.path.join(os.path.dirname(__file__), "output_annotated.png")

    annotate_photo(input_file, output_file)
