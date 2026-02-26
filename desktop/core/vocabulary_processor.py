"""
Vocabulary processor: import txt files, parse, divide into batches.
"""
import json
import os
import re


def parse_vocabulary_file(filepath):
    """
    Parse a vocabulary txt file. Supports formats:
      - One word per line
      - word | meaning
      - word \t meaning
    Returns list of dicts: [{"word": ..., "meaning": ...}, ...]
    """
    entries = []
    with open(filepath, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"):
                continue

            # Try pipe-separated
            if "|" in line:
                parts = [p.strip() for p in line.split("|", 1)]
                entries.append({"word": parts[0], "meaning": parts[1] if len(parts) > 1 else ""})
            # Try tab-separated
            elif "\t" in line:
                parts = [p.strip() for p in line.split("\t", 1)]
                entries.append({"word": parts[0], "meaning": parts[1] if len(parts) > 1 else ""})
            # Just a word
            else:
                entries.append({"word": line, "meaning": ""})
    return entries


def divide_into_batches(entries, batch_size=15):
    """Divide vocabulary entries into smaller batches for Claude processing."""
    return [entries[i:i + batch_size] for i in range(0, len(entries), batch_size)]


def save_vocabulary_json(entries, filepath):
    """Save vocabulary entries to a JSON file."""
    data = {"vocabulary": entries}
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)


def load_vocabulary_json(filepath):
    """Load vocabulary from a JSON file."""
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)
    return data.get("vocabulary", [])


def merge_batches(batch_results):
    """Merge multiple batch results into a single vocabulary list."""
    merged = []
    for batch in batch_results:
        merged.extend(batch)
    return merged
