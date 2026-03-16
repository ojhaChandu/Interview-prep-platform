#!/bin/bash

echo "🚀 Installing AI Coding Playground..."

mkdir -p app/coding
mkdir -p app/coding/execution
mkdir -p app/coding/evaluation
mkdir -p app/api/v1/coding

# -----------------------------

# Code Executor

# -----------------------------

cat > app/coding/execution/code_executor.py << 'EOF'
import subprocess
import tempfile
import uuid

def run_python_code(code: str, input_data: str = ""):

```
file_id = str(uuid.uuid4())
path = f"/tmp/{file_id}.py"

with open(path, "w") as f:
    f.write(code)

try:
    result = subprocess.run(
        ["python3", path],
        input=input_data,
        text=True,
        capture_output=True,
        timeout=5
    )

    return {
        "stdout": result.stdout,
        "stderr": result.stderr
    }

except Exception as e:
    return {"error": str(e)}
```

EOF

# -----------------------------

# Testcase Runner

# -----------------------------

cat > app/coding/execution/test_runner.py << 'EOF'
from .code_executor import run_python_code

def run_testcases(code, testcases):

```
results = []

for tc in testcases:

    result = run_python_code(code, tc["input"])

    passed = result.get("stdout", "").strip() == tc["output"].strip()

    results.append({
        "input": tc["input"],
        "expected": tc["output"],
        "actual": result.get("stdout"),
        "passed": passed
    })

return results
```

EOF

# -----------------------------

# AI Code Review

# -----------------------------

cat > app/coding/evaluation/ai_review.py << 'EOF'
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

EOF

# -----------------------------

# Auto register router

# -----------------------------

sed -i '' '/app.include_router/a
from app.api.v1.coding.routes import router as coding_router
app.include_router(coding_router)
' app/main.py

echo "✅ Coding Playground Installed!"
echo ""
echo "New API:"
echo "POST /coding/run"
echo ""
echo "Example testcases:"
echo '[{"input":"2 7 11 15\n9","output":"0 1"}]'
