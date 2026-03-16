from app.models.problem import Problem


def problem_to_dto(problem: Problem):

    return {
        "id": problem.id,
        "title": problem.title,
        "difficulty": problem.difficulty,
        "leetcode_url": getattr(problem, "leetcode_url", None)
    }
