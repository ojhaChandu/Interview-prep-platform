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
