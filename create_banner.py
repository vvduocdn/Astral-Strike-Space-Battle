#!/usr/bin/env python3
from PIL import Image, ImageDraw, ImageFont, ImageFilter
import random
import math
import os

# Create a 1024x500 image
width, height = 1024, 500
image = Image.new('RGB', (width, height), color='black')
draw = ImageDraw.Draw(image)

# Create starfield background
random.seed(42)
for _ in range(300):
    x = random.randint(0, width)
    y = random.randint(0, height)
    size = random.randint(1, 3)
    brightness = random.randint(150, 255)
    draw.ellipse([x, y, x+size, y+size], fill=(brightness, brightness, brightness))

# Add some colored nebula-like effects
for _ in range(8):
    x = random.randint(-100, width)
    y = random.randint(-100, height)
    colors = [(100, 0, 150), (0, 100, 150), (150, 0, 100), (100, 0, 200)]
    color = random.choice(colors)
    for i in range(5):
        radius = random.randint(50, 150)
        alpha_overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
        alpha_draw = ImageDraw.Draw(alpha_overlay)
        alpha_draw.ellipse([x-radius, y-radius, x+radius, y+radius],
                          fill=(*color, 20))
        image = Image.alpha_composite(image.convert('RGBA'), alpha_overlay).convert('RGB')

# Draw gradient overlay for depth
overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
overlay_draw = ImageDraw.Draw(overlay)

# Top to bottom gradient
for i in range(height):
    alpha = int(30 * (1 - i/height))
    overlay_draw.rectangle([0, i, width, i+1], fill=(10, 0, 30, alpha))

image = Image.alpha_composite(image.convert('RGBA'), overlay).convert('RGB')

# Load and add app icon if available
try:
    icon_path = 'assets/icon/app_512.png'
    if os.path.exists(icon_path):
        app_icon = Image.open(icon_path).convert('RGBA')
        # Resize icon for left side
        icon_size = 180
        app_icon = app_icon.resize((icon_size, icon_size), Image.Resampling.LANCZOS)

        # Add glow effect to icon
        glow = app_icon.copy()
        glow = glow.filter(ImageFilter.GaussianBlur(15))

        # Position on left side
        icon_x = 80
        icon_y = 320

        # Paste glow
        image.paste(glow, (icon_x-10, icon_y-10), glow)
        # Paste icon
        image.paste(app_icon, (icon_x, icon_y), app_icon)

        # Also add smaller icon on right side
        icon_size2 = 140
        app_icon2 = Image.open(icon_path).convert('RGBA')
        app_icon2 = app_icon2.resize((icon_size2, icon_size2), Image.Resampling.LANCZOS)
        glow2 = app_icon2.copy()
        glow2 = glow2.filter(ImageFilter.GaussianBlur(12))

        icon_x2 = 800
        icon_y2 = 320
        image.paste(glow2, (icon_x2-8, icon_y2-8), glow2)
        image.paste(app_icon2, (icon_x2, icon_y2), app_icon2)

except Exception as e:
    print(f"Could not load icon: {e}")
    # Fallback to simple shapes
    ship_x, ship_y = 150, 380
    ship_points = [
        (ship_x, ship_y - 50),
        (ship_x + 40, ship_y + 30),
        (ship_x + 25, ship_y + 50),
        (ship_x - 25, ship_y + 50),
        (ship_x - 40, ship_y + 30)
    ]
    draw.polygon(ship_points, fill=(70, 140, 220), outline=(0, 200, 255))
    draw.ellipse([ship_x-10, ship_y-15, ship_x+10, ship_y+5], fill=(0, 255, 255))

# Draw laser beam effect
laser_overlay = Image.new('RGBA', (width, height), (0, 0, 0, 0))
laser_draw = ImageDraw.Draw(laser_overlay)

# Multiple laser beams for effect
for i in range(3):
    offset = (i - 1) * 30
    laser_draw.line([200, 380+offset, 750, 200+offset], fill=(0, 255, 255, 150), width=3)
    laser_draw.line([200, 380+offset, 750, 200+offset], fill=(0, 255, 255, 50), width=8)

image = Image.alpha_composite(image.convert('RGBA'), laser_overlay).convert('RGB')

# Try to use system fonts, fallback to default
try:
    # Try different font paths for macOS
    title_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Black.ttf", 90)
    subtitle_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial Black.ttf", 38)
    tagline_font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Arial.ttf", 24)
except:
    try:
        title_font = ImageFont.truetype("/Library/Fonts/Arial Black.ttf", 90)
        subtitle_font = ImageFont.truetype("/Library/Fonts/Arial Black.ttf", 38)
        tagline_font = ImageFont.truetype("/Library/Fonts/Arial.ttf", 24)
    except:
        # Fallback to default font with larger size
        title_font = ImageFont.load_default()
        subtitle_font = ImageFont.load_default()
        tagline_font = ImageFont.load_default()

# Draw title with glow effect
title_text = "ASTRAL STRIKE"
subtitle_text = "SPACE BATTLE"
tagline_text = "DEFEND THE GALAXY"

# Get text bounding boxes for centering
title_bbox = draw.textbbox((0, 0), title_text, font=title_font)
title_width = title_bbox[2] - title_bbox[0]
title_x = (width - title_width) // 2

subtitle_bbox = draw.textbbox((0, 0), subtitle_text, font=subtitle_font)
subtitle_width = subtitle_bbox[2] - subtitle_bbox[0]
subtitle_x = (width - subtitle_width) // 2

tagline_bbox = draw.textbbox((0, 0), tagline_text, font=tagline_font)
tagline_width = tagline_bbox[2] - tagline_bbox[0]
tagline_x = (width - tagline_width) // 2

# Title glow
for offset in range(8, 0, -2):
    draw.text((title_x, 90), title_text, font=title_font,
              fill=(0, int(255*(offset/8)), 255, int(100*(offset/8))))

# Title main
draw.text((title_x, 90), title_text, font=title_font, fill=(255, 255, 255))
draw.text((title_x, 90), title_text, font=title_font, fill=(0, 255, 255))

# Subtitle glow
for offset in range(6, 0, -2):
    draw.text((subtitle_x, 185), subtitle_text, font=subtitle_font,
              fill=(255, 0, int(255*(offset/6)), int(80*(offset/6))))

# Subtitle main
draw.text((subtitle_x, 185), subtitle_text, font=subtitle_font, fill=(255, 255, 0))

# Tagline
draw.text((tagline_x, 450), tagline_text, font=tagline_font, fill=(200, 200, 255))

# Add corner decorations
corner_color = (0, 255, 255)
corner_size = 40

# Top-left
draw.line([20, 20, 20+corner_size, 20], fill=corner_color, width=3)
draw.line([20, 20, 20, 20+corner_size], fill=corner_color, width=3)

# Top-right
draw.line([width-20, 20, width-20-corner_size, 20], fill=corner_color, width=3)
draw.line([width-20, 20, width-20, 20+corner_size], fill=corner_color, width=3)

# Bottom-left
draw.line([20, height-20, 20+corner_size, height-20], fill=corner_color, width=3)
draw.line([20, height-20, 20, height-20-corner_size], fill=corner_color, width=3)

# Bottom-right
draw.line([width-20, height-20, width-20-corner_size, height-20], fill=corner_color, width=3)
draw.line([width-20, height-20, width-20, height-20-corner_size], fill=corner_color, width=3)

# Save the image
output_path = 'assets/icon/banner.png'
image.save(output_path, 'PNG')
print(f"Banner created successfully: {output_path}")
print(f"Size: {width}x{height}")
