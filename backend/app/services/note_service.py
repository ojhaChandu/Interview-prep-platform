from sqlalchemy.orm import Session
from datetime import datetime
import uuid
from typing import Optional

from app.models.note import Note
from app.models.user import User
from app.ai.indexer.knowledge_indexer import index_content

def create_note(db: Session, owner_id: str, title: str, content: Optional[str]) -> Note:

    note = Note(
        id=str(uuid.uuid4()),
        owner_id=owner_id,
        title=title,
        content=content,
        created_at=datetime.utcnow(),
        updated_at=datetime.utcnow(),
    )

    db.add(note)
    db.commit()
    db.refresh(note)

    # automatic AI indexing
    index_content(
        db,
        "note",
        note.id,
        f"{title} {content}"
    )

    return note


def get_user_notes(db: Session, user_id: str):

    return db.query(Note).filter(Note.owner_id == user_id).all()


def get_note(db: Session, note_id: str):

    return db.query(Note).filter(Note.id == note_id).first()


def update_note(db: Session, note: Note, title: Optional[str], content: Optional[str]):

    if title is not None:
        note.title = title

    if content is not None:
        note.content = content

    note.updated_at = datetime.utcnow()

    db.commit()
    db.refresh(note)

    return note


def delete_note(db: Session, note: Note):

    db.delete(note)
    db.commit()

from app.models.note_share import NoteShare
from app.models.user import User


def share_note(db, note_id, owner_id, email, permission):

    note = db.query(Note).filter(Note.id == note_id).first()

    if not note or note.owner_id != owner_id:
        raise Exception("Not authorized")

    user = db.query(User).filter(User.email == email).first()

    if not user:
        raise Exception("User not found")

    share = NoteShare(
        note_id=note_id,
        user_id=user.id,
        permission=permission
    )

    db.add(share)
    db.commit()

    return share


def get_shared_notes(db, user_id):

    return (
        db.query(Note)
        .join(NoteShare, NoteShare.note_id == Note.id)
        .filter(NoteShare.user_id == user_id)
        .all()
    )
