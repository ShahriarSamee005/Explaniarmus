def build_simplify_prompt(text: str, include_bangla: bool = False) -> str:
    if include_bangla:
        bangla_field = ',\n  "bangla_translation": "..."'
        bangla_instruction = '6. "bangla_translation": A Bangla translation of the simple_explanation field only.'
    else:
        bangla_field = ""
        bangla_instruction = ""

    prompt = f"""
You are an academic assistant helping a university student understand their assignment or academic text.
Read the following academic text carefully and respond ONLY with a valid JSON object — no extra text, no markdown, no explanation outside the JSON.

Academic Text:
\"\"\"
{text}
\"\"\"

Respond with this exact JSON structure:
{{
  "simple_explanation": "Explain the text in very simple language, as if explaining to a first-year student who has no background knowledge. 3-5 sentences.",
  "summary_points": [
    "Key point 1",
    "Key point 2",
    "Key point 3"
  ],
  "tasks": [
    "Task or action item 1",
    "Task or action item 2"
  ]{bangla_field}
}}

Rules:
- summary_points: 3 to 6 bullet points of the most important ideas
- tasks: concrete things the student needs to DO (submit, read, write, etc.)
- If there are no clear tasks, return an empty array []
- Your entire response must be valid JSON only
{bangla_instruction}
"""
    return prompt.strip()