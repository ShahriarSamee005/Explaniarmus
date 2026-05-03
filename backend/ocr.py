import easyocr
import fitz  # PyMuPDF
import numpy as np
from PIL import Image
import io

# Initialize EasyOCR reader once (downloads model on first run)
# We support English + Bengali
reader = easyocr.Reader(['en', 'bn'], gpu=False)


def extract_text_from_image(image_bytes: bytes) -> str:
    """
    Takes raw image bytes (jpg, png, etc.)
    Returns extracted text as a single string.
    """
    # Convert bytes to numpy array for EasyOCR
    image = Image.open(io.BytesIO(image_bytes)).convert("RGB")
    image_np = np.array(image)

    results = reader.readtext(image_np, detail=0, paragraph=True)
    return "\n".join(results)


def extract_text_from_pdf(pdf_bytes: bytes) -> str:
    """
    Takes raw PDF bytes.
    First tries direct text extraction (fast).
    If empty, converts pages to images and runs OCR (for scanned PDFs).
    Returns all extracted text as a single string.
    """
    text_parts = []

    # Open PDF from bytes
    doc = fitz.open(stream=pdf_bytes, filetype="pdf")

    for page_num in range(len(doc)):
        page = doc[page_num]

        # Try direct text extraction first
        page_text = page.get_text().strip()

        if page_text:
            text_parts.append(page_text)
        else:
            # Scanned PDF — render page as image and OCR it
            pix = page.get_pixmap(dpi=200)
            img_bytes = pix.tobytes("png")

            image = Image.open(io.BytesIO(img_bytes)).convert("RGB")
            image_np = np.array(image)

            results = reader.readtext(image_np, detail=0, paragraph=True)
            text_parts.append("\n".join(results))

    doc.close()
    return "\n\n".join(text_parts)