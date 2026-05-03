import fitz  # PyMuPDF
import base64
from groq import Groq
import os
from dotenv import load_dotenv

load_dotenv()

groq_client = Groq(api_key=os.getenv("GROQ_API_KEY"))


def extract_text_from_image_via_vision(image_bytes: bytes, content_type: str = "image/jpeg") -> str:
    """
    Send image directly to LLaMA vision — reads and extracts text.
    No local OCR needed. Fast and accurate.
    """
    base64_image = base64.b64encode(image_bytes).decode('utf-8')

    response = groq_client.chat.completions.create(
        model="meta-llama/llama-4-scout-17b-16e-instruct",
        messages=[
            {
                "role": "user",
                "content": [
                    {
                        "type": "image_url",
                        "image_url": {
                            "url": f"data:{content_type};base64,{base64_image}"
                        }
                    },
                    {
                        "type": "text",
                        "text": "Extract ALL text from this image exactly as written. Return only the extracted text, nothing else. No explanations."
                    }
                ]
            }
        ],
        max_tokens=2000,
    )

    return response.choices[0].message.content.strip()


def extract_text_from_pdf(pdf_bytes: bytes, max_pages: int = 10) -> str:
    """
    Extract text from PDF.
    - First tries direct text extraction (fast, works for normal PDFs)
    - Limits to first 5 pages to avoid timeout
    - For scanned pages, uses Groq vision instead of local OCR
    """
    text_parts = []

    doc = fitz.open(stream=pdf_bytes, filetype="pdf")
    total_pages = len(doc)

    pages_to_process = min(total_pages, max_pages)

    for page_num in range(pages_to_process):
        page = doc[page_num]
        page_text = page.get_text().strip()

        if page_text:
            text_parts.append(f"[Page {page_num + 1}]\n{page_text}")
        else:
            # Scanned page — use Groq vision
            pix = page.get_pixmap(dpi=150)
            img_bytes = pix.tobytes("jpeg")
            extracted = extract_text_from_image_via_vision(img_bytes, "image/jpeg")
            text_parts.append(f"[Page {page_num + 1}]\n{extracted}")

    doc.close()

    if total_pages > max_pages:
        text_parts.append(
            f"\n[Note: Document has {total_pages} pages. Only first {max_pages} processed.]"
        )

    return "\n\n".join(text_parts)