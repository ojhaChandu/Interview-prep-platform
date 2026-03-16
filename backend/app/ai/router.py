from app.ai.rag.pipeline import rag_answer
from app.ai.providers.groq_provider import ask_groq
from app.ai.retrieval.vector_search import search_similar_knowledge
from app.services.note_service import get_user_notes


class AIRouter:

    def route(self, db, query: str, user_id: str = None):
        context_chunks = search_similar_knowledge(db, query)
        
        # Add user-specific context if user_id is provided
        user_context = ""
        if user_id:
            # Get user's notes
            user_notes = get_user_notes(db, user_id)
            if user_notes:
                notes_content = f"\nUser's Notes ({len(user_notes)} total):\n"
                for note in user_notes:
                    notes_content += f"- {note.title}: {note.content[:100]}...\n"
                user_context = notes_content

        context = "\n".join(context_chunks) + user_context

        prompt = f"""
    You are a helpful AI assistant that can answer questions on any topic.
    You have access to the user's personal data and can provide specific information about their account.

    Context information (use if relevant):
    {context}

    User question:
    {query}

    Provide a clear and helpful answer. If the question is about the user's data (like notes, problems solved, etc.), use the context information to give specific details.
    """
        return ask_groq(prompt)
