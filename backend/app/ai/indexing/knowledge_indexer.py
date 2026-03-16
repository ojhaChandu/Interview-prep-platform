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

