#!/bin/bash

echo "🚀 Upgrading AI RAG system..."

BASE_DIR="$(pwd)"

# ----------------------------

# 1. Update vector_search.py

# ----------------------------

cat > app/ai/retrieval/vector_search.py << 'EOF'
from sentence_transformers import SentenceTransformer
from sqlalchemy import text

_model = None

def get_model():
global _model
if _model is None:
_model = SentenceTransformer("sentence-transformers/all-MiniLM-L6-v2")
return _model

def search_similar_knowledge(db, query: str, limit: int = 5):

```
model = get_model()

embedding = model.encode(query).tolist()

sql = text("""
    SELECT source_type, content
    FROM knowledge_base
    ORDER BY embedding <-> :embedding
    LIMIT :limit
""")

results = db.execute(
    sql,
    {
        "embedding": embedding,
        "limit": limit
    }
).fetchall()

contexts = []

for r in results:
    contexts.append(f"[{r.source_type.upper()}]\n{r.content}")

return contexts
```

EOF

# ----------------------------

# 2. Update AI router prompt

# ----------------------------

sed -i '' 's/return ask_groq(query)/
context_chunks = search_similar_knowledge(db, query)\n
context = "\n".join(context_chunks)\n
prompt = f"""
You are an expert coding interview assistant.\n
Use the following knowledge if relevant.\n
If the knowledge is insufficient, use your reasoning.\n
\n
Knowledge Context:\n
{context}\n
\n
Question:\n
{query}\n
\n
Provide the best explanation possible.\n
"""\n
return ask_groq(prompt)/' app/ai/router.py

# ----------------------------

# 3. Update indexing script

# ----------------------------

sed -i '' 's/content = f"{problem.title} {problem.description}"/
content = f"""Problem: {problem.title}\nDifficulty: {problem.difficulty}\nDescription: {problem.description or ""}"""/' scripts/index_knowledge.py

echo "✅ RAG upgrade complete!"
echo "Now run:"
echo "python -m scripts.index_knowledge"
