#!/bin/bash
set -e

echo "📚 Setting up Problem Library..."

cd backend
source venv/bin/activate

########################################
# PROBLEM MODEL
########################################

cat <<'EOF' > app/models/problem.py
from sqlalchemy import Column, String, Text
from sqlalchemy.dialects.postgresql import UUID
import uuid

from app.db.base import Base


class Problem(Base):
    __tablename__ = "problems"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    title = Column(String, nullable=False)
    difficulty = Column(String, nullable=False)
    category = Column(String, nullable=False)

    description = Column(Text, nullable=True)
EOF


########################################
# PROBLEM SCHEMA
########################################

cat <<'EOF' > app/schemas/problem.py
from pydantic import BaseModel
from uuid import UUID
from typing import Optional


class ProblemResponse(BaseModel):
    id: UUID
    title: str
    difficulty: str
    category: str
    description: Optional[str]

    class Config:
        from_attributes = True
EOF


########################################
# PROBLEM SERVICE
########################################

cat <<'EOF' > app/services/problem_service.py
from sqlalchemy.orm import Session
from app.models.problem import Problem


def get_problems(db: Session):
    return db.query(Problem).all()


def get_problem(db: Session, problem_id):
    return db.query(Problem).filter(Problem.id == problem_id).first()


def get_problems_by_category(db: Session, category):
    return db.query(Problem).filter(Problem.category == category).all()
EOF


########################################
# PROBLEM ROUTES
########################################

mkdir -p app/api/v1/problems

cat <<'EOF' > app/api/v1/problems/routes.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.schemas.problem import ProblemResponse
from app.services.problem_service import (
    get_problems,
    get_problem,
    get_problems_by_category
)

router = APIRouter(prefix="/problems", tags=["problems"])


@router.get("/", response_model=List[ProblemResponse])
def get_all_problems(db: Session = Depends(get_db)):
    return get_problems(db)


@router.get("/{problem_id}", response_model=ProblemResponse)
def get_problem_by_id(problem_id: str, db: Session = Depends(get_db)):
    return get_problem(db, problem_id)


@router.get("/category/{category}", response_model=List[ProblemResponse])
def get_problem_category(category: str, db: Session = Depends(get_db)):
    return get_problems_by_category(db, category)
EOF


########################################
# REGISTER ROUTES
########################################

echo "Register problem routes in main.py"

########################################
# LEETCODE 150 DATA SEED
########################################

cat <<'EOF' > scripts/seed_problems.py
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
EOF


echo "✅ Problem Library Setup Complete"
