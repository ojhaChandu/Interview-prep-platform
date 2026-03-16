#!/bin/bash
set -e

echo "🤖 Installing AI Router System..."

cd backend
source venv/bin/activate

mkdir -p app/ai/providers
mkdir -p app/api/v1/ai

########################################
# INSTALL DEPENDENCIES
########################################

pip install groq python-dotenv boto3

########################################
# GROQ PROVIDER (FREE MODEL)
########################################

cat <<'EOF' > app/ai/providers/groq_provider.py
import os
from groq import Groq

client = Groq(api_key=os.getenv("GROQ_API_KEY"))

def ask_groq(prompt: str):

    response = client.chat.completions.create(
        model="llama3-8b-8192",
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
EOF

########################################
# BEDROCK PROVIDER (FUTURE)
########################################

cat <<'EOF' > app/ai/providers/bedrock_provider.py
import boto3
import json

def ask_bedrock(prompt):

    bedrock = boto3.client("bedrock-runtime", region_name="us-east-1")

    body = json.dumps({
        "prompt": prompt,
        "max_tokens_to_sample": 500
    })

    response = bedrock.invoke_model(
        modelId="anthropic.claude-3-sonnet",
        body=body
    )

    result = json.loads(response["body"].read())

    return result["completion"]
EOF

########################################
# QUERY CLASSIFIER
########################################

cat <<'EOF' > app/ai/classifier.py
def classify_query(query: str):

    query = query.lower()

    if "design" in query:
        return "system_design"

    if "algorithm" in query or "leetcode" in query:
        return "coding"

    return "coding"
EOF

########################################
# AI ROUTER
########################################

cat <<'EOF' > app/ai/router.py
import os

from .classifier import classify_query
from .providers.groq_provider import ask_groq
from .providers.bedrock_provider import ask_bedrock

DEFAULT_MODEL = os.getenv("AI_MODEL", "groq")

class AIRouter:

    def route(self, query: str):

        query_type = classify_query(query)

        if DEFAULT_MODEL == "groq":
            return ask_groq(query)

        if DEFAULT_MODEL == "bedrock":
            return ask_bedrock(query)

        return ask_groq(query)
EOF

########################################
# FASTAPI AI ROUTES
########################################

cat <<'EOF' > app/api/v1/ai/routes.py
from fastapi import APIRouter
from pydantic import BaseModel

from app.ai.router import AIRouter

router = APIRouter(prefix="/ai", tags=["ai"])

ai_router = AIRouter()

class AIRequest(BaseModel):
    query: str

@router.post("/chat")
def chat(req: AIRequest):

    answer = ai_router.route(req.query)

    return {
        "answer": answer
    }
EOF

echo "✅ AI Router Installed"
