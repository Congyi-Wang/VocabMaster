"""
Claude CLI integration: send vocabulary batches to Claude for checking and enrichment.
Uses the `claude` CLI (Claude Code) as a subprocess.
"""
import json
import subprocess
import re


PROMPT_TEMPLATE = """You are a vocabulary checker and enricher. I will give you a list of vocabulary entries in JSON format. For each entry, please:

1. Check the word for spelling mistakes and correct them
2. Check the meaning for accuracy and grammar, correct if needed
3. If the meaning is empty, provide a clear, concise definition
4. Add a natural example sentence that demonstrates the word's usage
5. Add pronunciation in IPA format if possible

Return ONLY a valid JSON array (no markdown, no explanation) with the corrected entries in this exact format:
[
  {{
    "word": "corrected_word",
    "pronunciation": "/IPA/",
    "meaning": "corrected or added meaning",
    "example_sentence": "A natural example sentence."
  }}
]

Here are the vocabulary entries to process:
{vocabulary_json}"""


def process_batch_with_claude(batch):
    """
    Send a batch of vocabulary entries to Claude CLI for checking.
    Returns the corrected/enriched entries.
    """
    vocab_json = json.dumps(batch, ensure_ascii=False, indent=2)
    prompt = PROMPT_TEMPLATE.format(vocabulary_json=vocab_json)

    try:
        result = subprocess.run(
            ["claude", "--no-input", "-p", prompt],
            capture_output=True,
            text=True,
            timeout=120,
            encoding="utf-8",
        )

        if result.returncode != 0:
            raise RuntimeError(f"Claude CLI error: {result.stderr}")

        response_text = result.stdout.strip()

        # Try to extract JSON from the response
        # Claude might wrap it in markdown code blocks
        json_match = re.search(r'\[.*\]', response_text, re.DOTALL)
        if json_match:
            corrected = json.loads(json_match.group())
            return corrected
        else:
            raise ValueError("Could not find JSON array in Claude's response")

    except subprocess.TimeoutExpired:
        raise RuntimeError("Claude CLI timed out (120s). Try a smaller batch size.")
    except json.JSONDecodeError as e:
        raise RuntimeError(f"Failed to parse Claude's response as JSON: {e}\nResponse: {response_text[:500]}")


def process_all_batches(batches, progress_callback=None):
    """
    Process all vocabulary batches through Claude.
    progress_callback(current, total) is called after each batch.
    Returns list of all corrected entries.
    """
    all_results = []
    total = len(batches)

    for i, batch in enumerate(batches):
        corrected = process_batch_with_claude(batch)
        all_results.extend(corrected)
        if progress_callback:
            progress_callback(i + 1, total)

    return all_results
