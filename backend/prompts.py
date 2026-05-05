def build_simplify_prompt(text: str, include_bangla: bool = False) -> str:

    # ── Input analysis ─────────────────────────────────────────────────────
    word_count = len(text.split())

    math_keywords = [
        "=", "∫", "∑", "∂", "√", "theorem", "proof", "equation",
        "formula", "calculate", "derivative", "integral", "matrix",
        "vector", "probability", "distribution", "hypothesis", "regression",
        "coefficient", "variance", "correlation", "ratio", "rate",
        "differentiate", "integrate", "solve", "x²", "f(x)", "dy/dx",
    ]
    has_math = any(kw in text for kw in math_keywords)

    # ── Scale by length ────────────────────────────────────────────────────
    if word_count < 150:
        explanation_guide = "Write 2-4 sentences."
        summary_guide     = "Extract 3-4 distinct key points."
        tasks_guide       = "List 2-4 specific tasks."
        max_summary       = 4
        max_tasks         = 4
    elif word_count < 500:
        explanation_guide = "Write 5-7 sentences."
        summary_guide     = "Extract 4-6 distinct key points."
        tasks_guide       = "List 3-5 specific tasks."
        max_summary       = 6
        max_tasks         = 5
    elif word_count < 1500:
        explanation_guide = "Write 7-10 sentences. Cover every major section or argument."
        summary_guide     = "Extract 5-8 distinct key points, one per major idea."
        tasks_guide       = "List 4-7 specific tasks."
        max_summary       = 8
        max_tasks         = 7
    else:
        explanation_guide = (
            "Write 10-15 sentences. You MUST cover every section of the document. "
            "Do not compress or skip later sections just because the text is long."
        )
        summary_guide     = "Extract 7-10 distinct key points. Each point must cover a different idea — no merging."
        tasks_guide       = "List 5-8 specific tasks."
        max_summary       = 10
        max_tasks         = 8

    # ── Math-specific instructions ─────────────────────────────────────────
    if has_math:
        math_block = """
MATHEMATICAL CONTENT RULES (apply these strictly):
- For every formula or equation, explain in one plain-English sentence what it calculates or represents.
  Example: "This formula finds how fast something is changing at a specific point."
- In summary_points, include the purpose of key formulas as separate bullet points.
- In tasks, break numerical steps into fine-grained actions:
  Bad:  "Solve the integral"
  Good: "Identify the function to integrate, apply the power rule, evaluate between the given limits, then simplify"
- Never write a formula in symbol form inside the JSON strings — spell it out in words to avoid
  JSON encoding issues. Example: write "x squared plus 2x" not "x² + 2x".
"""
    else:
        math_block = ""

    # ── Bangla ─────────────────────────────────────────────────────────────
    if include_bangla:
        bangla_field       = ',\n  "bangla_translation": "..."'
        bangla_instruction = (
            '"bangla_translation": Translate the simple_explanation into natural, '
            "conversational Bangla. Match the same length and depth — do not shorten it. "
            "Use everyday Bangla, not formal literary style.\n"
        )
    else:
        bangla_field       = ""
        bangla_instruction = ""

    # ── Full prompt ────────────────────────────────────────────────────────
    prompt = f"""
You are an expert academic tutor helping a university student who is seeing this topic for the first time.
Your job is to make complex academic content genuinely understandable — not just shorter.

Before writing your JSON response, silently do the following:
1. Identify every distinct section, concept, or argument in the text.
2. Note any formulas, numbers, or technical terms that need plain-English unpacking.
3. Identify what the student actually needs to DO as a result of this content.
Then produce the JSON using those notes.

Academic Text:
\"\"\"
{text}
\"\"\"

Respond with ONLY this JSON structure — no markdown, no preamble, no explanation outside the JSON:
{{
  "simple_explanation": "Your explanation here. {explanation_guide} Use analogies where helpful. Define every technical term the first time it appears. Write as if talking to a smart friend who has never studied this subject.",
  "summary_points": [
    "Key point 1 — specific and self-contained, not vague",
    "Key point 2",
    "Key point 3"
  ],
  "tasks": [
    "Task 1 — start with an action verb, be specific about what to produce or do",
    "Task 2"
  ]{bangla_field}
}}

STRICT RULES:
- simple_explanation: Must reflect the ENTIRE text. If the document has multiple sections, all must appear in the explanation. Do not stop early.
- summary_points: {summary_guide} Max {max_summary} points. Every point must be self-contained — a student should understand it without reading the others.
- tasks: {tasks_guide} Max {max_tasks} tasks. Every task must start with an action verb (Read, Write, Calculate, Submit, Compare, List, Draw, Solve...). No vague tasks like "understand the topic" or "review the material."
- If there are no actionable tasks in the text, return: "tasks": []
- All string values must use only standard ASCII-safe characters. Replace symbols: percent sign as "percent", greater-than as "greater than", equals sign within prose as "equals".
- Your entire response must be valid, parseable JSON. Do not truncate mid-sentence.
{math_block}{bangla_instruction}""".strip()

    return prompt