import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.problem import Problem
from app.models.category import Category
from app.models.problem_category import ProblemCategory
from app.models.problem_set import ProblemSet
from app.models.problem_set_item import ProblemSetItem
from app.ai.indexer.knowledge_indexer import index_content

db = SessionLocal()

categories = [
    "Array",
    "Dynamic Programming",
    "Graph",
    "Tree",
    "Binary Search",
    "Sliding Window",
    "Backtracking"
]

category_map = {}

for c in categories:
    cat = Category(name=c)
    db.add(cat)
    db.flush()
    category_map[c] = cat.id

leetcode150 = ProblemSet(
    name="leetcode_150",
    description="Top Leetcode interview questions"
)

db.add(leetcode150)
db.flush()

problems = [
    ("Two Sum", "Easy", "Array"),
    ("Maximum Subarray", "Medium", "Dynamic Programming"),
    ("Binary Tree Level Order Traversal", "Medium", "Tree"),
    ("Number of Islands", "Medium", "Graph"),
]

order = 1

for title, diff, cat in problems:

    p = Problem(
        title=title,
        difficulty=diff
    )

    db.add(p)
    db.flush()

    index_content(
        db,
        "problem",
        problem.id,
        f"{problem.title}. Difficulty: {problem.difficulty}. {problem.description or ''}"
    )


    db.add(
        ProblemCategory(
            problem_id=p.id,
            category_id=category_map[cat]
        )
    )

    db.add(
        ProblemSetItem(
            problem_set_id=leetcode150.id,
            problem_id=p.id,
            order_index=order
        )
    )

    order += 1

db.commit()

print("Problem system seeded successfully")
