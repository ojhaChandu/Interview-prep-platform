from app.ai.providers.groq_provider import ask_groq

def evaluate_code(problem, code):

```
prompt = f"""
```

You are a senior software engineer conducting a coding interview.

Problem:
{problem}

Candidate Solution:
{code}

Evaluate the solution:

1. Correctness
2. Time complexity
3. Space complexity
4. Possible improvements
5. Interview feedback

Return structured feedback.
"""

```
return ask_groq(prompt)
```

