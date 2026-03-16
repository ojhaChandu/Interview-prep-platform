from app.models.note import Note

def note_to_dto(note: Note):
    return {
        "id": note.id,
        "title": getattr(note, "title", None),
        "content": getattr(note, "content", None),
        "owner_id": getattr(note, "owner_id", None),
        "created_at": getattr(note, "created_at", None)
    }

