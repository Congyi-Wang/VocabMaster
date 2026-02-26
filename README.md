# VocabMaster

Cross-platform vocabulary review system with AI-powered checking and themed packages.

## Components

### Desktop App (Windows - Python + PyQt6)
- Import vocabulary from TXT or JSON files
- Send vocabulary to Claude for spell-checking, correction, and example sentence generation
- Build themed ZIP packages (P5R, Simple, Planet Universe)
- Export corrected vocabulary as JSON or TXT

### Mobile App (Android - Flutter)
- Load vocabulary from TXT, JSON, or themed ZIP files
- Flashcard-style review mode with swipe navigation
- Text-to-Speech: separate buttons for word pronunciation and example sentence
- Load themed ZIP files to change the entire app appearance

## Setup

### Desktop App
```bash
cd desktop
pip install -r requirements.txt
python main.py
```
Requires: Python 3.10+, Claude CLI (`claude` command) for vocabulary checking.

### Mobile App
```bash
cd mobile
flutter pub get
flutter run
```
Requires: Flutter SDK 3.2+, Android SDK.

## Vocabulary File Format

### TXT (pipe-separated)
```
word | meaning
abandon | to give up completely
```

### JSON
```json
{
  "vocabulary": [
    {
      "word": "abandon",
      "pronunciation": "/əˈbændən/",
      "meaning": "to give up completely",
      "example_sentence": "She had to abandon her plans."
    }
  ]
}
```

## Theme ZIP Structure
```
theme.zip/
├── theme.json        # Colors, fonts, layout config
├── vocabulary.json   # Vocabulary data
├── manifest.json     # Package metadata
└── assets/           # Optional images, backgrounds
```

## Built-in Themes
- **P5R** - Bold red/black (Persona 5 Royal style)
- **Simple** - Clean minimal blue/white
- **Planet Universe** - Cosmic purple/teal space theme
