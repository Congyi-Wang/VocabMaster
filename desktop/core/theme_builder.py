"""
Theme builder: create themed zip files containing vocabulary data + theme config + assets.
"""
import json
import os
import shutil
import zipfile


BUILT_IN_THEMES = {
    "p5r": {
        "name": "Persona 5 Royal",
        "description": "Bold red and black theme inspired by P5R",
        "colors": {
            "primary": "#FF0000",
            "secondary": "#000000",
            "background": "#1A1A2E",
            "surface": "#16213E",
            "text": "#FFFFFF",
            "accent": "#E94560",
            "word_color": "#FF0000",
            "meaning_color": "#FFFFFF",
            "sentence_color": "#E94560",
            "button_color": "#FF0000",
            "button_text": "#FFFFFF",
        },
        "fonts": {
            "title": "bold",
            "word": "bold",
            "meaning": "normal",
            "sentence": "italic",
        },
        "style": "dark",
    },
    "simple": {
        "name": "Simple & Clean",
        "description": "Minimal clean design for focused study",
        "colors": {
            "primary": "#2196F3",
            "secondary": "#757575",
            "background": "#FFFFFF",
            "surface": "#F5F5F5",
            "text": "#212121",
            "accent": "#FF9800",
            "word_color": "#1565C0",
            "meaning_color": "#212121",
            "sentence_color": "#455A64",
            "button_color": "#2196F3",
            "button_text": "#FFFFFF",
        },
        "fonts": {
            "title": "bold",
            "word": "bold",
            "meaning": "normal",
            "sentence": "italic",
        },
        "style": "light",
    },
    "planet_universe": {
        "name": "Planet Universe",
        "description": "Cosmic space theme with deep purple and starry vibes",
        "colors": {
            "primary": "#BB86FC",
            "secondary": "#03DAC6",
            "background": "#0B0B2B",
            "surface": "#1B1B4B",
            "text": "#E0E0FF",
            "accent": "#CF6679",
            "word_color": "#BB86FC",
            "meaning_color": "#E0E0FF",
            "sentence_color": "#03DAC6",
            "button_color": "#6200EA",
            "button_text": "#FFFFFF",
        },
        "fonts": {
            "title": "bold",
            "word": "bold",
            "meaning": "normal",
            "sentence": "italic",
        },
        "style": "dark",
    },
}


def build_theme_zip(theme_name, vocabulary_data, output_path, custom_theme=None):
    """
    Build a themed zip file.

    Args:
        theme_name: key from BUILT_IN_THEMES or 'custom'
        vocabulary_data: list of vocabulary entry dicts
        output_path: where to save the .zip file
        custom_theme: dict with theme config (if theme_name is 'custom')
    """
    if custom_theme:
        theme_config = custom_theme
    elif theme_name in BUILT_IN_THEMES:
        theme_config = BUILT_IN_THEMES[theme_name]
    else:
        raise ValueError(f"Unknown theme: {theme_name}. Available: {list(BUILT_IN_THEMES.keys())}")

    with zipfile.ZipFile(output_path, "w", zipfile.ZIP_DEFLATED) as zf:
        # Write theme config
        zf.writestr("theme.json", json.dumps(theme_config, ensure_ascii=False, indent=2))

        # Write vocabulary data
        vocab_data = {"vocabulary": vocabulary_data}
        zf.writestr("vocabulary.json", json.dumps(vocab_data, ensure_ascii=False, indent=2))

        # Write a manifest
        manifest = {
            "version": "1.0",
            "theme": theme_name,
            "word_count": len(vocabulary_data),
        }
        zf.writestr("manifest.json", json.dumps(manifest, ensure_ascii=False, indent=2))

        # Add theme-specific assets directory if exists
        theme_assets_dir = os.path.join(os.path.dirname(__file__), "..", "themes", theme_name)
        if os.path.isdir(theme_assets_dir):
            for root, dirs, files in os.walk(theme_assets_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.join("assets", os.path.relpath(file_path, theme_assets_dir))
                    zf.write(file_path, arcname)

    return output_path


def list_themes():
    """Return list of available theme names and descriptions."""
    return {k: v["name"] + " - " + v["description"] for k, v in BUILT_IN_THEMES.items()}
