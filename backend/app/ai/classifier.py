def classify_query(query: str):

    query = query.lower()

    if "design" in query:
        return "system_design"

    if "algorithm" in query or "leetcode" in query:
        return "coding"

    return "coding"
