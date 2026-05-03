from dotenv import load_dotenv
load_dotenv()

from fastapi import FastAPI, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from typing import Optional
import uvicorn

from ocr import extract_text_from_image_via_vision, extract_text_from_pdf
from ai_processor import simplify_text

app = FastAPI(
    title="Explaniarmus API",
    description="Powered by Groq + LLaMA",
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"status": "Explaniarmus backend is running ✅"}


@app.post("/simplify-text")
async def simplify_plain_text(
    text: str = Form(...),
    bangla: Optional[bool] = Form(False)
):
    """Accept raw pasted text and return AI simplification."""
    result = await simplify_text(text, include_bangla=bangla)
    return result


@app.post("/simplify-image")
async def simplify_image(
    file: UploadFile = File(...),
    bangla: Optional[bool] = Form(False)
):
    """Accept an uploaded image, use Groq vision to read it, then simplify."""
    contents = await file.read()

    content_type = file.content_type or "image/jpeg"
    extracted_text = extract_text_from_image_via_vision(contents, content_type)

    if not extracted_text.strip():
        return {"error": "Could not extract text from image."}

    result = await simplify_text(extracted_text, include_bangla=bangla)
    result["extracted_text"] = extracted_text
    return result


@app.post("/simplify-pdf")
async def simplify_pdf(
    file: UploadFile = File(...),
    bangla: Optional[bool] = Form(False)
):
    """Accept a PDF, extract text, then simplify."""
    contents = await file.read()
    extracted_text = extract_text_from_pdf(contents)

    if not extracted_text.strip():
        return {"error": "Could not extract text from PDF."}

    result = await simplify_text(extracted_text, include_bangla=bangla)
    result["extracted_text"] = extracted_text
    return result


if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)