from sqlalchemy import text
from app.ai.rag.embeddings import generate_embedding

def retrieve_context(db, query: str, k: int = 5):

    embedding = generate_embedding(query)
    # convert list → pgvector format
    embedding_str = "[" + ",".join(map(str, embedding)) + "]"

    result = db.execute(
        text("""
        SELECT content
        FROM knowledge_base
        ORDER BY embedding <=> :embedding
        LIMIT :k
        """),
        {"embedding": embedding_str, "k": k}
    )

    return [row[0] for row in result]
