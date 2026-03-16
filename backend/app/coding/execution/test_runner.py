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

