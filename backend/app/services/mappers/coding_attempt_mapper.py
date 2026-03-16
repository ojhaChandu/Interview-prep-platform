
def coding_attempt_to_dto(attempt):
    return {
        "id": getattr(attempt, "id", None),
        "problem_id": getattr(attempt, "problem_id", None),
        "user_id": getattr(attempt, "user_id", None),
        "code": getattr(attempt, "code", None),
        "language": getattr(attempt, "language", None),
        "created_at": getattr(attempt, "created_at", None)
    }


