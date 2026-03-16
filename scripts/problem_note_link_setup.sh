#!/bin/bash
set -e

echo "🔗 Installing Problem ↔ Notes linking system..."

cd backend
source venv/bin/activate

########################################
# SERVICE
########################################

cat <<'EOF' >> app/services/problem_service.py

from app.models.note_problem import NoteProblem
from app.models.note import Note


def attach_note_to_problem(db, problem_id, note_id, user_id):

    note = db.query(Note).filter(Note.id == note_id).first()

    if not note or str(note.owner_id) != str(user_id):
        raise Exception("Not authorized")

    link = NoteProblem(
        problem_id=problem_id,
        note_id=note_id
    )

    db.add(link)
    db.commit()

    return link


def get_notes_for_problem(db, problem_id):

    return (
        db.query(Note)
        .join(NoteProblem, NoteProblem.note_id == Note.id)
        .filter(NoteProblem.problem_id == problem_id)
        .all()
    )


def detach_note_from_problem(db, problem_id, note_id):

    link = (
        db.query(NoteProblem)
        .filter(
            NoteProblem.problem_id == problem_id,
            NoteProblem.note_id == note_id
        )
        .first()
    )

    if link:
        db.delete(link)
        db.commit()
EOF

########################################
# ROUTES
########################################

cat <<'EOF' >> app/api/v1/problems/routes.py

from app.services.problem_service import (
    attach_note_to_problem,
    get_notes_for_problem,
    detach_note_from_problem
)

from app.core.auth_dependency import get_current_user
from app.models.user import User
from app.models.note import Note


@router.post("/{problem_id}/notes/{note_id}")
def attach_note(
    problem_id: str,
    note_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    attach_note_to_problem(db, problem_id, note_id, current_user.id)

    return {"message": "Note attached to problem"}


@router.get("/{problem_id}/notes")
def get_problem_notes(problem_id: str, db: Session = Depends(get_db)):

    return get_notes_for_problem(db, problem_id)


@router.delete("/{problem_id}/notes/{note_id}")
def detach_note(
    problem_id: str,
    note_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
):

    detach_note_from_problem(db, problem_id, note_id)

    return {"message": "Note detached"}
EOF

echo "✅ Problem ↔ Notes linking installed"
