from sqlalchemy.orm import Session, joinedload
from app.models.problem import Problem
from app.services.mappers.problem_mapper import problem_to_dto

def get_all_problems(db: Session):
    problems = db.query(Problem).all()

    return [problem_to_dto(p) for p in problems]


def get_problem(db: Session, problem_id):
    problem = db.query(Problem).filter(Problem.id == problem_id).first()

    if not problem:
        return None

    return problem_to_dto(problem)


def get_problem_with_test_cases(db: Session, problem_id):
    problem = db.query(Problem).options(joinedload(Problem.test_cases)).filter(Problem.id == problem_id).first()
    
    if not problem:
        return None
    
    return problem


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
