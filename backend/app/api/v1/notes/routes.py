from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.schemas.note import (
    NoteCreate,
    NoteUpdate,
    NoteResponse,
    NoteShare
)
from app.services.note_service import (
    create_note,
    get_user_notes,
    get_note,
    update_note,
    delete_note,
    share_note,
    get_shared_notes
)
from app.core.auth_dependency import get_current_user
from app.models.user import User

router = APIRouter(prefix="/notes", tags=["notes"])

@router.get("/shared")
def get_shared_notes_api(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    return get_shared_notes(db, current_user.id)

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


@router.post("/{note_id}/share")
def share_note_api(
    note_id: str,
    payload: NoteShare,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    share_note(db, note_id, current_user.id, payload.email, payload.permission)

    return {"message": "Note shared successfully"}
