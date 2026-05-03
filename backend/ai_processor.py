import os
import json
from groq import Groq
from dotenv import load_dotenv
from prompts import build_simplify_prompt

load_dotenv()

client = Groq(api_key=os.getenv("GROQ_API_KEY"))


async def simplify_text(text: str, include_bangla: bool = False) -> dict:
    """
    Sends extracted text to Groq and returns structured JSON response.
    """
    prompt = build_simplify_prompt(text, include_bangla=include_bangla)

    try:
        response = client.chat.completions.create(
            model="llama-3.3-70b-versatile",
            messages=[{"role": "user", "content": prompt}],
            temperature=0.3,
            max_tokens=1500,
        )

        raw_content = response.choices[0].message.content.strip()

        # Remove markdown code fences if model adds them
        if raw_content.startswith("```"):
            parts = raw_content.split("```")
            raw_content = parts[1]
            if raw_content.startswith("json"):
                raw_content = raw_content[4:]

        result = json.loads(raw_content.strip())
        return result

    except json.JSONDecodeError as e:
        return {
            "error": "AI returned invalid JSON",
            "raw": raw_content,
            "detail": str(e)
        }
    except Exception as e:
        return {"error": str(e)}