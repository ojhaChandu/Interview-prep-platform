from app.models.note_problem import NoteProblem

def note_problem_to_dto(link: NoteProblem):
    return {
        "note_id": getattr(link, "note_id", None),
        "problem_id": getattr(link, "problem_id", None)
    }

