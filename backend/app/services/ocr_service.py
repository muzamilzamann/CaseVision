import os

import pytesseract
from PIL import Image
from pdf2image import convert_from_path
from PyPDF2 import PdfReader

from app.core.config import settings

pytesseract.pytesseract.tesseract_cmd = settings.tesseract_path


def extract_text_from_file(file_path: str) -> str:
    """
    Extracts text from a PDF, image, or plain text file.
    - For text-based PDFs, uses PyPDF2 directly.
    - If that yields little/no text (scanned PDF), falls back to OCR.
    - For images, uses OCR directly.
    """
    ext = os.path.splitext(file_path)[1].lower()

    if ext == ".txt":
        with open(file_path, "r", encoding="utf-8", errors="ignore") as f:
            return f.read()

    if ext == ".pdf":
        text = _extract_pdf_text(file_path)
        if len(text.strip()) > 30:
            return text
        # Likely a scanned PDF with no embedded text layer; use OCR.
        return _ocr_pdf(file_path)

    if ext in (".jpg", ".jpeg", ".png"):
        return _ocr_image(file_path)

    raise ValueError(f"Unsupported file type for OCR: {ext}")


def _extract_pdf_text(file_path: str) -> str:
    reader = PdfReader(file_path)
    text_parts = [page.extract_text() or "" for page in reader.pages]
    return "\n".join(text_parts)


def _ocr_pdf(file_path: str) -> str:
    images = convert_from_path(file_path, poppler_path=settings.poppler_path)
    text_parts = [pytesseract.image_to_string(img, lang="eng+urd") for img in images]
    return "\n".join(text_parts)


def _ocr_image(file_path: str) -> str:
    image = Image.open(file_path)
    return pytesseract.image_to_string(image, lang="eng+urd")