from app.ai.providers.groq_provider import ask_groq

def review_solution(problem, code, test_results):

```
prompt = f"""
```

You are a senior engineer reviewing a coding interview solution.

Problem:
{problem}

Candidate Code:
{code}

Testcase Results:
{test_results}

Provide:

1. correctness review
2. complexity analysis
3. improvements
4. interview feedback
   """

   return ask_groq(prompt)
   EOF

# -----------------------------

# Coding API

# -----------------------------

cat > app/api/v1/coding/routes.py << 'EOF'
from fastapi import APIRouter
from pydantic import BaseModel
from app.coding.execution.test_runner import run_testcases
from app.coding.evaluation.ai_review import review_solution

router = APIRouter(prefix="/coding")

class RunCodeRequest(BaseModel):
problem: str
code: str
testcases: list

@router.post("/run")
def run_code(req: RunCodeRequest):

```
results = run_testcases(req.code, req.testcases)

ai_feedback = review_solution(
    req.problem,
    req.code,
    results
)

return {
    "test_results": results,
    "ai_feedback": ai_feedback
}
```

