from app.db.session import SessionLocal
from app.models.problem import Problem

db = SessionLocal()

problems = [
    {"title": "Two Sum", "difficulty": "Easy", "category": "Array"},
    {"title": "Best Time to Buy and Sell Stock", "difficulty": "Easy", "category": "Array"},
    {"title": "Contains Duplicate", "difficulty": "Easy", "category": "Array"},
    {"title": "Product of Array Except Self", "difficulty": "Medium", "category": "Array"},
    {"title": "Maximum Subarray", "difficulty": "Medium", "category": "Dynamic Programming"},
    {"title": "Maximum Product Subarray", "difficulty": "Medium", "category": "Dynamic Programming"},
    {"title": "Find Minimum in Rotated Sorted Array", "difficulty": "Medium", "category": "Binary Search"},
    {"title": "Search in Rotated Sorted Array", "difficulty": "Medium", "category": "Binary Search"},
    {"title": "3Sum", "difficulty": "Medium", "category": "Two Pointer"},
    {"title": "Container With Most Water", "difficulty": "Medium", "category": "Two Pointer"}
]

for p in problems:
    problem = Problem(**p)
    db.add(problem)

db.commit()

print("Seeded problems successfully")
