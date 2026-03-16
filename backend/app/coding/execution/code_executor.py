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

