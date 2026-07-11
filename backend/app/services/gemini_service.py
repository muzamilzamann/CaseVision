import json
import re

import requests

from app.core.config import settings

GEMINI_URL = (
    "https://generativelanguage.googleapis.com/v1beta/models/"
    "gemini-2.5-flash:generateContent"
)

ANALYSIS_PROMPT = """You are a legal assistant specializing in Pakistani criminal law (Pakistan Penal Code / PPC).
You will be given the extracted text of an FIR (First Information Report), which may be in English, Urdu, or a mix of both.

Analyze the FIR text and respond with ONLY a valid JSON object (no markdown, no code fences, no extra text) in exactly this structure:

{
  "summary": "A concise 2-4 sentence English summary of the incident described in the FIR.",
  "predicted_laws": ["PPC XXX - Short Title", "PPC YYY - Short Title"],
  "urdu_explanation": [
    {"title": "سیکشن XXX - عنوان", "text": "Simple Urdu explanation of what this section means and why it applies."}
  ],
  "related_cases": [
    {"title": "Illustrative case name vs State", "court": "Relevant Pakistani court", "year": "Approximate year"}
  ]
}

Rules:
- predicted_laws must list the most relevant actual Pakistan Penal Code sections based on the facts (e.g. theft -> PPC 379, cheating -> PPC 420, criminal intimidation -> PPC 506, hurt -> PPC 337, murder -> PPC 302, etc.). Include 1-4 sections, only the ones that clearly apply.
- urdu_explanation must have one entry per predicted law, written in simple, everyday Urdu (not legal jargon).
- related_cases are illustrative examples of the kind of case that could be relevant (clearly plausible Pakistani case names/courts), since no case-law database is connected yet.
- Output must be valid JSON only. Do not wrap it in ```json or any other text.

FIR TEXT:
\"\"\"
{fir_text}
\"\"\"
"""


def analyze_fir_text(fir_text: str) -> dict:
    prompt = ANALYSIS_PROMPT.replace("{fir_text}", fir_text[:8000])  # guard against very long input

    payload = {
        "contents": [
            {"parts": [{"text": prompt}]}
        ]
    }

    response = requests.post(
        GEMINI_URL,
        params={"key": settings.gemini_api_key},
        json=payload,
        timeout=60,
    )

    if response.status_code != 200:
        raise RuntimeError(f"Gemini API error: {response.status_code} {response.text}")

    data = response.json()
    try:
        raw_text = data["candidates"][0]["content"]["parts"][0]["text"]
    except (KeyError, IndexError):
        raise RuntimeError(f"Unexpected Gemini response format: {data}")

    cleaned = _strip_code_fences(raw_text)

    try:
        result = json.loads(cleaned)
    except json.JSONDecodeError:
        raise RuntimeError(f"Gemini did not return valid JSON: {cleaned}")

    return {
        "summary": result.get("summary", ""),
        "predicted_laws": result.get("predicted_laws", []),
        "urdu_explanation": result.get("urdu_explanation", []),
        "related_cases": result.get("related_cases", []),
    }


def _strip_code_fences(text: str) -> str:
    text = text.strip()
    text = re.sub(r"^```(?:json)?\s*", "", text)
    text = re.sub(r"\s*```$", "", text)
    return text.strip()