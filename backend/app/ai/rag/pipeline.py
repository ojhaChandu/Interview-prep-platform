from app.ai.rag.retriever import retrieve_context
from app.ai.providers.groq_provider import ask_groq

def rag_answer(db, question: str):

    docs = retrieve_context(db, question)

    context = "\n".join(docs)

    prompt = f"""
You are a helpful AI assistant that can answer questions on any topic.

Context information (use if relevant):
{context}

User question:
{question}

Provide a clear and helpful answer. If the question is about coding, algorithms, or technical topics, use your programming knowledge. For other topics, provide general helpful information.
"""

    return ask_groq(prompt)
