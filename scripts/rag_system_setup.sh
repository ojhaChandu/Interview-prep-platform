#!/bin/bash

set -e

echo "🚀 Setting up RAG system..."

cd backend

source venv/bin/activate

mkdir -p app/ai/rag

echo "🧠 Creating embedding generator..."

cat <<'EOF' > app/ai/rag/embeddings.py
from sentence_transformers import SentenceTransformer

model = SentenceTransformer("all-MiniLM-L6-v2")

def generate_embedding(text: str):
    return model.encode(text).tolist()
EOF


echo "🔎 Creating retriever..."

cat <<'EOF' > app/ai/rag/retriever.py
from sqlalchemy import text
from app.ai.rag.embeddings import generate_embedding

def retrieve_context(db, query: str, k: int = 5):

    embedding = generate_embedding(query)

    result = db.execute(
        text("""
        SELECT content
        FROM knowledge_base
        ORDER BY embedding <-> :embedding
        LIMIT :k
        """),
        {"embedding": embedding, "k": k}
    )

    return [row[0] for row in result]
EOF


echo "⚙️ Creating RAG pipeline..."

cat <<'EOF' > app/ai/rag/pipeline.py
from app.ai.rag.retriever import retrieve_context
from app.ai.providers.groq_provider import ask_groq

def rag_answer(db, question: str):

    docs = retrieve_context(db, question)

    context = "\n".join(docs)

    prompt = f"""
You are a senior software engineer helping with interview preparation.

Context information:
{context}

User question:
{question}

Provide the best possible explanation.
Use the context if useful, but rely on your knowledge as well.
"""

    return ask_groq(prompt)
EOF


echo "🧠 Updating AI Router..."

cat <<'EOF' > app/ai/router.py
from app.ai.rag.pipeline import rag_answer

class AIRouter:

    def route(self, db, query: str):

        return rag_answer(db, query)
EOF


echo "🌐 Updating AI API routes..."

mkdir -p app/api/v1/ai

cat <<'EOF' > app/api/v1/ai/routes.py
from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.ai.router import AIRouter
from app.db.session import get_db

router = APIRouter(prefix="/ai", tags=["ai"])

ai_router = AIRouter()

class AIRequest(BaseModel):
    query: str

@router.post("/chat")
def chat(req: AIRequest, db: Session = Depends(get_db)):

    answer = ai_router.route(db, req.query)

    return {"answer": answer}
EOF


echo "📚 Creating indexing script..."

mkdir -p scripts

cat <<'EOF' > scripts/index_knowledge.py
import uuid
from sqlalchemy import text

from app.db.session import SessionLocal
from app.models.problem import Problem
from app.models.note import Note
from app.ai.rag.embeddings import generate_embedding

db = SessionLocal()

def index_problem(problem):

    content = f"{problem.title} {problem.description}"

    embedding = generate_embedding(content)

    db.execute(
        text("""
        INSERT INTO knowledge_base (id, source_type, source_id, content, embedding)
        VALUES (:id, :type, :sid, :content, :embedding)
        """),
        {
            "id": str(uuid.uuid4()),
            "type": "problem",
            "sid": str(problem.id),
            "content": content,
            "embedding": embedding
        }
    )

def index_note(note):

    content = f"{note.title} {note.content}"

    embedding = generate_embedding(content)

    db.execute(
        text("""
        INSERT INTO knowledge_base (id, source_type, source_id, content, embedding)
        VALUES (:id, :type, :sid, :content, :embedding)
        """),
        {
            "id": str(uuid.uuid4()),
            "type": "note",
            "sid": str(note.id),
            "content": content,
            "embedding": embedding
        }
    )

for problem in db.query(Problem).all():
    index_problem(problem)

for note in db.query(Note).all():
    index_note(note)

db.commit()

print("✅ Knowledge indexed successfully")
EOF


echo "✅ RAG system installed successfully!"
echo ""
echo "Next steps:"
echo "1️⃣ Create knowledge_base table in PostgreSQL"
echo "2️⃣ Run: python scripts/index_knowledge.py"
echo "3️⃣ Restart server"
