#!/bin/bash
set -e

echo "🔗 Setting up Note Sharing system..."

cd backend
source venv/bin/activate

########################################
# NOTE SHARE MODEL
########################################

cat <<'EOF' > app/models/note_share.py
from sqlalchemy import Column, ForeignKey, String, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func

from app.db.base import Base


class NoteShare(Base):
    __tablename__ = "note_shares"

    note_id = Column(UUID(as_uuid=True), ForeignKey("notes.id"), primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), primary_key=True)

    permission = Column(String, nullable=False)
    shared_at = Column(DateTime(timezone=True), server_default=func.now())
EOF


########################################
# SHARE SERVICE
########################################

cat <<'EOF' >> app/services/note_service.py

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
EOF


########################################
# SHARE ROUTES
########################################

cat <<'EOF' >> app/api/v1/notes/routes.py

from app.schemas.note import NoteShare
from app.services.note_service import share_note, get_shared_notes


@router.post("/{note_id}/share")
def share_note_api(
    note_id: str,
    payload: NoteShare,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    share_note(db, note_id, current_user.id, payload.email, payload.permission)

    return {"message": "Note shared successfully"}


@router.get("/shared")
def get_shared_notes_api(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    return get_shared_notes(db, current_user.id)
EOF


echo "✅ Note Sharing system installed"
