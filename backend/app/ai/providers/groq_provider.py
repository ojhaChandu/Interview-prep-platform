import os
from groq import Groq

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def ask_groq(prompt: str):

    response = client.chat.completions.create(
        model="llama-3.1-8b-instant",
        # model="llama-3.1-70b-versatile"
        messages=[
            {
                "role": "system",
                "content": """
You are a technical interview assistant.

Answer only questions related to:
- Algorithms
- Data structures
- System design
- Distributed systems
"""
            },
            {"role": "user", "content": prompt}
        ],
    )

    return response.choices[0].message.content
