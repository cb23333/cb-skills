"""
Photo Doodle Annotator - 照片手绘涂鸦标注脚本模板

这个脚本负责读取照片、添加手绘风格的注释和装饰，然后输出标注后的图片。
根据实际分析到的画面元素，修改 annotations 列表中的内容。
"""

from PIL import Image, ImageDraw, ImageFont, ImageFilter
import random
import math
import os
import sys


def get_font(size=20):
    """按优先级尝试加载手写风格中文字体"""
    font_candidates = [
        "ZCOOLKuaiLe-Regular.ttf",       # 站酷快乐体
        "ZCOOLKuaiLe.ttf",
        "ZCOOLXiaoWei-Regular.ttf",      # 站酷小薇体
        "MaShanZheng-Regular.ttf",       # 马善政毛笔体
        "STKAITI.TTF",                   # 华文楷体
        "LiuJianMaoCao-Regular.ttf",     # 刘建毛草
        "simhei.ttf",                    # 黑体 fallback
        "SimHei.ttf",
    ]

    # 尝试常见字体路径
    font_dirs = [
        "C:/Windows/Fonts",
        "/usr/share/fonts",
        "/usr/local/share/fonts",
        os.path.expanduser("~/.fonts"),
        os.path.expanduser("~/Library/Fonts"),
        "/Library/Fonts",
        "/System/Library/Fonts",
    ]

    for font_name in font_candidates:
        for font_dir in font_dirs:
            if os.path.isdir(font_dir):
                font_path = os.path.join(font_dir, font_name)
                if os.path.exists(font_path):
                    try:
                        return ImageFont.truetype(font_path, size)
                    except Exception:
                        continue

    # 最终 fallback: 默认字体
    try:
        return ImageFont.truetype("arial.ttf", size)
    except Exception:
        return ImageFont.load_default()


def get_avg_brightness(img, x, y, radius=15):
    """获取图片某位置周围的平均亮度"""
    w, h = img.size
    x0, y0 = max(0, x - radius), max(0, y - radius)
    x1, y1 = min(w, x + radius), min(h, y + radius)
    region = img.crop((x0, y0, x1, y1)).convert("L")
    pixels = list(region.getdata())
    return sum(pixels) / len(pixels) if pixels else 128


def choose_color(img, x, y):
    """根据背景亮度选择注释颜色"""
    brightness = get_avg_brightness(img, x, y)
    if brightness > 160:
        return (50, 50, 50)       # 亮背景用深色
    else:
        return (255, 255, 255)    # 暗背景用白色


def draw_wobbly_line(draw, start, end, color, width=2, wobble=2):
    """画一条带抖动的手绘风格线条"""
    points = []
    steps = max(int(math.dist(start, end) / 3), 4)
    for i in range(steps + 1):
        t = i / steps
        x = start[0] + (end[0] - start[0]) * t + random.uniform(-wobble, wobble)
        y = start[1] + (end[1] - start[1]) * t + random.uniform(-wobble, wobble)
        points.append((x, y))
    for i in range(len(points) - 1):
        w = max(1, width + random.randint(-1, 1))
        draw.line([points[i], points[i + 1]], fill=color, width=w)


def draw_wobbly_ellipse(draw, bbox, color, width=2, wobble=3):
    """画一个带抖动的手绘风格椭圆（用于圈出物体）"""
    cx = (bbox[0] + bbox[2]) / 2
    cy = (bbox[1] + bbox[3]) / 2
    rx = (bbox[2] - bbox[0]) / 2
    ry = (bbox[3] - bbox[1]) / 2

    points = []
    steps = max(int((rx + ry) / 4), 20)
    for i in range(steps + 1):
        angle = 2 * math.pi * i / steps
        x = cx + rx * math.cos(angle) + random.uniform(-wobble, wobble)
        y = cy + ry * math.sin(angle) + random.uniform(-wobble, wobble)
        points.append((x, y))

    # 断续感：随机跳过一些线段
    for i in range(len(points) - 1):
        if random.random() < 0.15:  # 15% 概率断开
            continue
        w = max(1, width + random.randint(-1, 1))
        draw.line([points[i], points[i + 1]], fill=color, width=w)


def draw_dashed_line(draw, start, end, color, width=1, dash_len=8, gap_len=6):
    """画虚线（手绘风格，间距不均匀）"""
    dist = math.dist(start, end)
    if dist < 1:
        return
    dx, dy = (end[0] - start[0]) / dist, (end[1] - start[1]) / dist
    pos = 0
    while pos < dist:
        seg = dash_len + random.uniform(-3, 3)  # 间距不均匀
        p1 = (start[0] + dx * pos, start[1] + dy * pos)
        p2_pos = min(pos + seg, dist)
        p2 = (start[0] + dx * p2_pos, start[1] + dy * p2_pos)
        draw_wobbly_line(draw, p1, p2, color, width, wobble=1)
        pos += dash_len + gap_len + random.uniform(-2, 2)


def draw_arrow(draw, start, end, color, width=2):
    """画手绘箭头"""
    draw_dashed_line(draw, start, end, color, width)
    # 箭头头部
    angle = math.atan2(end[1] - start[1], end[0] - start[0])
    arrow_len = 10
    a1 = angle + math.pi * 0.8
    a2 = angle - math.pi * 0.8
    for a in [a1, a2]:
        ax = end[0] + arrow_len * math.cos(a) + random.uniform(-2, 2)
        ay = end[1] + arrow_len * math.sin(a) + random.uniform(-2, 2)
        draw_wobbly_line(draw, end, (ax, ay), color, width, wobble=1)


def draw_text_with_outline(draw, position, text, font, fill_color, angle=0):
    """画带描边的文字（保证可读性），支持微小旋转"""
    # 简化实现：先画描边再画文字
    x, y = position
    outline_color = (0, 0, 0) if sum(fill_color) > 400 else (255, 255, 255)

    # 如果需要旋转，用临时图片
    if abs(angle) > 0.5:
        bbox = font.getbbox(text)
        tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
        pad = 4
        txt_img = Image.new("RGBA", (tw + pad * 2, th + pad * 2), (0, 0, 0, 0))
        txt_draw = ImageDraw.Draw(txt_img)
        # 描边
        for ox, oy in [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, 1), (-1, 1), (1, -1)]:
            txt_draw.text((pad + ox, pad + oy), text, font=font, fill=outline_color)
        txt_draw.text((pad, pad), text, font=font, fill=fill_color)
        txt_img = txt_img.rotate(angle, resample=Image.BICUBIC, expand=True)
        return txt_img, (x - pad, y - pad)

    # 无旋转：直接画描边
    for ox, oy in [(-1, 0), (1, 0), (0, -1), (0, 1), (-1, -1), (1, 1), (-1, 1), (1, -1)]:
        draw.text((x + ox, y + oy), text, font=font, fill=outline_color)
    draw.text((x, y), text, font=font, fill=fill_color)
    return None, None


def draw_star(draw, center, size, color):
    """画一个小星星"""
    cx, cy = center
    for angle in [0, 72, 144, 216, 288]:
        rad = math.radians(angle)
        ex = cx + size * math.cos(rad) + random.uniform(-1, 1)
        ey = cy + size * math.sin(rad) + random.uniform(-1, 1)
        draw_wobbly_line(draw, (cx, cy), (ex, ey), color, width=1, wobble=1)


def draw_heart(draw, center, size, color):
    """画一个小爱心"""
    cx, cy = center
    # 简单用两个弧线拼成心形
    points = []
    for i in range(30):
        t = i / 29 * 2 * math.pi
        x = size * 0.5 * (16 * math.sin(t) ** 3)
        y = -size * 0.5 * (13 * math.cos(t) - 5 * math.cos(2 * t) - 2 * math.cos(3 * t) - math.cos(4 * t))
        points.append((cx + x / 16 + random.uniform(-1, 1), cy + y / 16 + random.uniform(-1, 1)))
    for i in range(len(points) - 1):
        draw.line([points[i], points[i + 1]], fill=color, width=1)


def draw_steam(draw, x, y, color):
    """画热气（饮品上方）"""
    for _ in range(3):
        sx = x + random.randint(-15, 15)
        points = []
        for j in range(8):
            px = sx + math.sin(j * 0.8) * 4 + random.uniform(-1, 1)
            py = y - j * 3
            points.append((px, py))
        for i in range(len(points) - 1):
            draw.line([points[i], points[i + 1]], fill=color, width=1)


def annotate_photo(input_path, output_path, annotations):
    """
    给照片添加手绘标注

    Args:
        input_path: 输入图片路径
        output_path: 输出图片路径
        annotations: 标注列表，每个元素是字典:
            {
                "label": "注释文字",
                "text_pos": (x, y),        # 文字位置
                "target_pos": (x, y),       # 指向的目标位置（可选）
                "outline_bbox": (x1, y1, x2, y2),  # 描边区域（可选）
                "decor": "star" | "heart" | "steam" | None,  # 小装饰（可选）
            }
    """
    img = Image.open(input_path).convert("RGBA")
    overlay = Image.new("RGBA", img.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(overlay)

    font_size = max(16, min(img.size) // 30)
    font = get_font(font_size)

    for ann in annotations:
        label = ann["label"]
        tx, ty = ann["text_pos"]

        # 选择合适颜色
        color = choose_color(img.convert("RGB"), tx, ty)

        # 画描边轮廓（如果指定）
        if "outline_bbox" in ann and ann["outline_bbox"]:
            draw_wobbly_ellipse(draw, ann["outline_bbox"], color, width=2)

        # 画指引线/箭头（如果指定了目标位置）
        if "target_pos" in ann and ann["target_pos"]:
            target = ann["target_pos"]
            # 文字到目标的连线
            text_anchor = (tx, ty + font_size // 2)
            draw_arrow(draw, text_anchor, target, color, width=1)

        # 画文字（带微小旋转）
        angle = random.uniform(-3, 3)
        txt_img, txt_pos = draw_text_with_outline(draw, (tx, ty), label, font, color, angle)
        if txt_img:
            overlay.paste(txt_img, txt_pos, txt_img)

        # 画小装饰
        decor = ann.get("decor")
        if decor == "star":
            draw_star(draw, (tx - 15, ty - 5), 6, color)
        elif decor == "heart":
            draw_heart(draw, (tx - 12, ty + font_size // 2), 5, color)
        elif decor == "steam":
            draw_steam(draw, tx, ty - 5, color)

    # 合成
    result = Image.alpha_composite(img, overlay)

    # 保存
    output_ext = os.path.splitext(output_path)[1].lower()
    if output_ext in [".jpg", ".jpeg"]:
        result = result.convert("RGB")
    result.save(output_path, quality=95)
    print(f"Annotated photo saved to: {output_path}")


# ============================================================
# 使用示例 - 根据实际图片内容修改以下部分
# ============================================================

if __name__ == "__main__":
    input_file = sys.argv[1] if len(sys.argv) > 1 else "input.jpg"
    output_file = sys.argv[2] if len(sys.argv) > 2 else "output_annotated.png"

    # TODO: 根据图片实际内容修改 annotations
    annotations = [
        {
            "label": "今天的续命水",
            "text_pos": (100, 50),
            "target_pos": (200, 250),
            "outline_bbox": (170, 180, 260, 320),
            "decor": "steam",
        },
        {
            "label": "阳光刚刚好",
            "text_pos": (350, 30),
            "target_pos": None,
            "outline_bbox": None,
            "decor": "star",
        },
        {
            "label": "被治愈了 :)",
            "text_pos": (50, 400),
            "target_pos": None,
            "outline_bbox": None,
            "decor": "heart",
        },
    ]

    annotate_photo(input_file, output_file, annotations)
