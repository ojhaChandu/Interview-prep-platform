from app.ai.indexing.knowledge_indexer import index_knowledge

def index_problem(db, problem):

```
content = f"{problem.title} {getattr(problem, 'description', '')}"

index_knowledge(
    db,
    "problem",
    str(problem.id),
    content
)
```

def index_note(db, note):

```
content = f"{note.title} {note.content}"

index_knowledge(
    db,
    "note",
    str(note.id),
    content
)
```

def index_solution(db, attempt):

```
content = f"{attempt.language} {attempt.code}"

index_knowledge(
    db,
    "solution",
    str(attempt.id),
    content
)
```

