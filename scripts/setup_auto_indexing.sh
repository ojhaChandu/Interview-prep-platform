#!/bin/bash

echo "🤖 Setting up Automatic AI Knowledge Indexing..."

BASE="backend/app"
AI_DIR="$BASE/ai"
INDEX_DIR="$AI_DIR/indexing"

mkdir -p $INDEX_DIR

touch $INDEX_DIR/**init**.py

echo "📦 Creating embedder..."

cat > $INDEX_DIR/embedder.py << 'EOF'
from sentence_transformers import SentenceTransformer

_model = None

def get_model():
global _model

```
if _model is None:
    _model = SentenceTransformer("all-MiniLM-L6-v2")

return _model
```

def generate_embedding(text: str):

```
model = get_model()

return model.encode(text).tolist()
```

EOF

echo "📦 Creating knowledge indexer..."

cat > $INDEX_DIR/knowledge_indexer.py << 'EOF'
from uuid import uuid4
from sqlalchemy import text
from app.ai.indexing.embedder import generate_embedding

def index_knowledge(db, source_type: str, source_id: str, content: str):

```
embedding = generate_embedding(content)

db.execute(
    text("""
    INSERT INTO knowledge_base
    (id, source_type, source_id, content, embedding)
    VALUES
    (:id, :type, :sid, :content, :embedding)
    """),
    {
        "id": str(uuid4()),
        "type": source_type,
        "sid": str(source_id),
        "content": content,
        "embedding": embedding
    }
)

db.commit()
```

EOF

echo "📦 Creating auto indexing hooks..."

cat > $INDEX_DIR/auto_index_hooks.py << 'EOF'
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

EOF

echo "📦 Installing dependencies..."

pip install sentence-transformers

echo "✅ Automatic indexing setup complete!"
echo ""
echo "Created:"
echo "app/ai/indexing/embedder.py"
echo "app/ai/indexing/knowledge_indexer.py"
echo "app/ai/indexing/auto_index_hooks.py"
echo ""
echo "Next step:"
echo "Call index_problem / index_note / index_solution in services after insert."
