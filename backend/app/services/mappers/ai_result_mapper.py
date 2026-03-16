
def ai_result_to_dto(result):
    return {
        "id": getattr(result, "id", None),
        "query": getattr(result, "query", None),
        "response": getattr(result, "response", None),
        "created_at": getattr(result, "created_at", None)
    }

