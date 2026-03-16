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
