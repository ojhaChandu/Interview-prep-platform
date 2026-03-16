from app.ai.providers.groq_provider import ask_groq

def analyze_complexity(code):

```
prompt = f"""
```

Analyze the following code and determine:

1. Time Complexity
2. Space Complexity
3. Explain reasoning.

Code:
{code}
"""

```
return ask_groq(prompt)
```

