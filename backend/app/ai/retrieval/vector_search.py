from sentence_transformers import SentenceTransformer
from sqlalchemy import text

_model = None


def get_model():
    global _model

    if _model is None:
        _model = SentenceTransformer("all-MiniLM-L6-v2")

    return _model


def search_similar_knowledge(db, query: str):

    model = get_model()

    embedding = model.encode(query).tolist()
    embedding_str = "[" + ",".join(map(str, embedding)) + "]"

    results = db.execute(
        text("""
        SELECT content
        FROM knowledge_base
        ORDER BY embedding <=> :embedding
        LIMIT 5
        """),
        {"embedding": embedding_str}
    )
    rows = results.fetchall()

    return "\n".join([r[0] for r in rows])
