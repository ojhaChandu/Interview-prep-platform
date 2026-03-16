from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.schemas.problem import ProblemResponse, ProblemDetailResponse
from app.services.problem_service import get_all_problems, get_problem, get_problem_with_test_cases

router = APIRouter(prefix="/problems", tags=["problems"])


@router.get("/", response_model=List[ProblemResponse])
def get_problems(db: Session = Depends(get_db)):
    return get_all_problems(db)


@router.get("/{problem_id}", response_model=ProblemResponse)
def get_problem_by_id(problem_id: str, db: Session = Depends(get_db)):
    return get_problem(db, problem_id)


@router.get("/{problem_id}/detail", response_model=ProblemDetailResponse)
def get_problem_detail(problem_id: str, db: Session = Depends(get_db)):
    problem = get_problem_with_test_cases(db, problem_id)
    if not problem:
        raise HTTPException(status_code=404, detail="Problem not found")
    return problem


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
