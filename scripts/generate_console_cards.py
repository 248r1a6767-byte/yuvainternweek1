# -*- coding: utf-8 -*-
"""
Script: generate_console_cards.py
Purpose: Render publication-grade dark-slate terminal screenshot cards (PNG)
         from actual R console output logs for embedding in Week 1 report.
"""

import os
from PIL import Image, ImageDraw, ImageFont

def render_terminal_card(txt_path, out_png_path, title="R Interactive Terminal - Superstore Analysis"):
    if not os.path.exists(txt_path):
        print(f"File not found: {txt_path}")
        return

    with open(txt_path, 'r', encoding='utf-8', errors='replace') as f:
        lines = [line.rstrip('\r\n') for line in f.readlines()]

    # Limit to reasonable display lines
    max_lines = 32
    if len(lines) > max_lines:
        lines = lines[:max_lines]
        lines.append("... [Output truncated for terminal card display; full log in console_outputs/]")

    # Geometry
    padding_x = 28
    padding_y = 20
    header_height = 42
    line_spacing = 6
    font_size = 14

    # Load monospace font
    font = None
    font_bold = None
    try:
        font = ImageFont.truetype("consola.ttf", font_size)
        font_bold = ImageFont.truetype("consolab.ttf", font_size)
    except IOError:
        try:
            font = ImageFont.truetype("cour.ttf", font_size)
            font_bold = ImageFont.truetype("courbd.ttf", font_size)
        except IOError:
            font = ImageFont.load_default()
            font_bold = font

    # Calculate dimensions
    max_len = max([len(l) for l in lines] + [len(title) + 10, 60])
    char_width = 8.5
    img_width = int(max(850, min(1100, max_len * char_width + padding_x * 2)))
    line_height = font_size + line_spacing
    img_height = header_height + padding_y * 2 + len(lines) * line_height

    # Colors
    bg_color = (15, 23, 42)        # Dark slate #0f172a
    header_bg = (30, 41, 59)      # Slate #1e293b
    text_color = (241, 245, 249)    # Light gray #f1f5f9
    muted_color = (148, 163, 184)  # Muted slate #94a3b8
    accent_color = (56, 189, 248)  # Cyan #38bdf8
    red_dot = (239, 68, 68)
    yellow_dot = (245, 158, 11)
    green_dot = (34, 197, 94)

    # Create image
    img = Image.new('RGB', (img_width, img_height), bg_color)
    draw = ImageDraw.Draw(img)

    # Draw header bar
    draw.rectangle([(0, 0), (img_width, header_height)], fill=header_bg)

    # Draw macOS/Linux style window dots
    draw.ellipse([(16, 15), (28, 27)], fill=red_dot)
    draw.ellipse([(36, 15), (48, 27)], fill=yellow_dot)
    draw.ellipse([(56, 15), (68, 27)], fill=green_dot)

    # Draw title
    title_font = font_bold if font_bold else font
    draw.text((85, 13), f"R Console -- {title}", fill=muted_color, font=title_font)

    # Draw body lines
    y = header_height + padding_y
    for line in lines:
        col = text_color
        if line.startswith("===") or line.startswith("---"):
            col = muted_color
        elif line.startswith(">>>") or line.startswith("Inspection Timestamp") or line.startswith("Audit Timestamp") or line.startswith("Execution Timestamp"):
            col = accent_color
        elif "Error" in line or "FAIL" in line:
            col = (248, 113, 113)
        elif "PASS" in line or "SUCCESS" in line or "100% complete" in line.lower():
            col = (74, 222, 128)
        
        draw.text((padding_x, y), line, fill=col, font=font)
        y += line_height

    os.makedirs(os.path.dirname(out_png_path), exist_ok=True)
    img.save(out_png_path, "PNG", dpi=(300, 300))
    print(f"Generated terminal card: {out_png_path}")

def generate_all_cards():
    cards = [
        ("outputs/console_outputs/initial_inspection.txt", "screenshots/card01_initial_inspection.png", "01_initial_inspection.R: Raw Schema & Dims"),
        ("outputs/console_outputs/missing_imputation_demo.txt", "screenshots/card02_missingness_imputation.png", "03_missing_values.R: Completeness & Sandbox"),
        ("outputs/console_outputs/outlier_detection_output.txt", "screenshots/card03_outlier_detection.png", "05_outlier_analysis.R: Tukey IQR Fencing"),
        ("outputs/console_outputs/normalization_output.txt", "screenshots/card04_normalization_scaling.png", "06_transformation.R: Min-Max & Z-Score"),
        ("outputs/console_outputs/categorical_encoding_output.txt", "screenshots/card05_categorical_encoding.png", "07_categorical_encoding.R: model.matrix"),
        ("outputs/console_outputs/correlation_output.txt", "screenshots/card06_correlations.png", "11_correlation_analysis.R: cor.test Inferences"),
        ("outputs/diagnostics/qa_validation_log.txt", "screenshots/card07_qa_validation.png", "14_quality_control.R: Automated QA Audit")
    ]
    for txt, png, title in cards:
        render_terminal_card(txt, png, title)

if __name__ == '__main__':
    generate_all_cards()
