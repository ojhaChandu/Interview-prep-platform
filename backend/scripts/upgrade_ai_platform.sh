#!/bin/bash

echo "🚀 Upgrading Interview Platform AI Features..."

mkdir -p app/ai/evaluator
mkdir -p app/ai/interview
mkdir -p app/ai/system_design

# ------------------------------

# 1. Coding Solution Evaluator

# ------------------------------

cat > app/ai/evaluator/code_evaluator.py << 'EOF'
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

EOF

# ------------------------------

# 2. Complexity Analyzer

# ------------------------------

cat > app/ai/evaluator/complexity_analyzer.py << 'EOF'
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

EOF

# ------------------------------

# 3. Interview Simulation

# ------------------------------

cat > app/ai/interview/interview_engine.py << 'EOF'
from app.ai.providers.groq_provider import ask_groq

def run_interview(question, answer):

```
prompt = f"""
```

You are conducting a technical interview.

Question:
{question}

Candidate Answer:
{answer}

Provide interview-style feedback:

* strengths
* weaknesses
* follow-up questions
  """

  return ask_groq(prompt)
  EOF

# ------------------------------

# 4. System Design Assistant

# ------------------------------

cat > app/ai/system_design/design_assistant.py << 'EOF'
from app.ai.providers.groq_provider import ask_groq

def system_design(question):

```
prompt = f"""
```

You are a senior architect helping design scalable systems.

Question:
{question}

Explain:

1. High-level architecture
2. Components
3. Data flow
4. Scaling strategy
5. Tradeoffs
   """

   return ask_groq(prompt)
   EOF

# ------------------------------

# 5. Add AI routes

# ------------------------------

mkdir -p app/api/v1/ai_tools

cat > app/api/v1/ai_tools/routes.py << 'EOF'
from fastapi import APIRouter
from pydantic import BaseModel

from app.ai.evaluator.code_evaluator import evaluate_code
from app.ai.evaluator.complexity_analyzer import analyze_complexity
from app.ai.interview.interview_engine import run_interview
from app.ai.system_design.design_assistant import system_design

router = APIRouter(prefix="/ai-tools")

class CodeRequest(BaseModel):
problem: str
code: str

class CodeOnly(BaseModel):
code: str

class InterviewRequest(BaseModel):
question: str
answer: str

class DesignRequest(BaseModel):
question: str

@router.post("/evaluate-code")
def evaluate(req: CodeRequest):
return {"result": evaluate_code(req.problem, req.code)}

@router.post("/complexity")
def complexity(req: CodeOnly):
return {"result": analyze_complexity(req.code)}

@router.post("/interview-feedback")
def interview(req: InterviewRequest):
return {"result": run_interview(req.question, req.answer)}

@router.post("/system-design")
def design(req: DesignRequest):
return {"result": system_design(req.question)}
EOF

echo "✅ AI Platform upgrade complete!"
echo "Add the new router in app/main.py:"
echo "from app.api.v1.ai_tools.routes import router as ai_tools_router"
echo "app.include_router(ai_tools_router)"
