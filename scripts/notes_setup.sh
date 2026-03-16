#!/bin/bash
set -e

echo "📒 Setting up Notes system..."

cd backend
source venv/bin/activate

mkdir -p app/api/v1/notes
mkdir -p app/services
mkdir -p app/schemas

############################################
# NOTE SCHEMAS
############################################

cat <<'EOF' > app/schemas/note.py
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime


class NoteBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    content: Optional[str] = None


class NoteCreate(NoteBase):
    pass


class NoteUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    content: Optional[str] = None


class NoteResponse(NoteBase):
    id: str
    owner_id: str
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class NoteShare(BaseModel):
    email: str
    permission: str = "read"
EOF


############################################
# NOTE SERVICE
############################################

cat <<'EOF' > app/services/note_service.py
from sqlalchemy.orm import Session
from datetime import datetime
import uuid

from app.models.note import Note
from app.models.user import User


def create_note(db: Session, owner_id: str, title: str, content: str | None):

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

    return note


def get_user_notes(db: Session, user_id: str):

    return db.query(Note).filter(Note.owner_id == user_id).all()


def get_note(db: Session, note_id: str):

    return db.query(Note).filter(Note.id == note_id).first()


def update_note(db: Session, note: Note, title: str | None, content: str | None):

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
EOF


############################################
# NOTES ROUTES
############################################

cat <<'EOF' > app/api/v1/notes/routes.py
from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.schemas.note import NoteCreate, NoteUpdate, NoteResponse
from app.services.note_service import (
    create_note,
    get_user_notes,
    get_note,
    update_note,
    delete_note
)

from app.core.auth_dependency import get_current_user
from app.models.user import User

router = APIRouter(prefix="/notes", tags=["notes"])


@router.post("/", response_model=NoteResponse)
def create_note_api(
    payload: NoteCreate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    note = create_note(db, current_user.id, payload.title, payload.content)
    return note


@router.get("/", response_model=List[NoteResponse])
def get_notes_api(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):
    return get_user_notes(db, current_user.id)


@router.get("/{note_id}", response_model=NoteResponse)
def get_note_api(
    note_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    note = get_note(db, note_id)

    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    if note.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    return note


@router.put("/{note_id}", response_model=NoteResponse)
def update_note_api(
    note_id: str,
    payload: NoteUpdate,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    note = get_note(db, note_id)

    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    if note.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    return update_note(db, note, payload.title, payload.content)


@router.delete("/{note_id}")
def delete_note_api(
    note_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    note = get_note(db, note_id)

    if not note:
        raise HTTPException(status_code=404, detail="Note not found")

    if note.owner_id != current_user.id:
        raise HTTPException(status_code=403, detail="Not authorized")

    delete_note(db, note)

    return {"message": "Note deleted"}
EOF


echo "✅ Notes system files created successfully"
