#!/bin/bash
set -e

echo "⚙️ Installing Production Problem System..."

cd backend
source venv/bin/activate

mkdir -p app/models
mkdir -p app/schemas
mkdir -p app/services
mkdir -p app/api/v1/problems
mkdir -p scripts

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

    leetcode_url = Column(String, nullable=True)
    description = Column(Text, nullable=True)
EOF


########################################
# CATEGORY MODEL
########################################

cat <<'EOF' > app/models/category.py
from sqlalchemy import Column, String
from sqlalchemy.dialects.postgresql import UUID
import uuid

from app.db.base import Base


class Category(Base):
    __tablename__ = "categories"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    name = Column(String, unique=True, nullable=False)
EOF


########################################
# PROBLEM CATEGORY MAPPING
########################################

cat <<'EOF' > app/models/problem_category.py
from sqlalchemy import Column, ForeignKey
from sqlalchemy.dialects.postgresql import UUID

from app.db.base import Base


class ProblemCategory(Base):
    __tablename__ = "problem_categories"

    problem_id = Column(UUID(as_uuid=True), ForeignKey("problems.id"), primary_key=True)
    category_id = Column(UUID(as_uuid=True), ForeignKey("categories.id"), primary_key=True)
EOF


########################################
# PROBLEM SET MODEL
########################################

cat <<'EOF' > app/models/problem_set.py
from sqlalchemy import Column, String, Text
from sqlalchemy.dialects.postgresql import UUID
import uuid

from app.db.base import Base


class ProblemSet(Base):
    __tablename__ = "problem_sets"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)

    name = Column(String, unique=True, nullable=False)
    description = Column(Text, nullable=True)
EOF


########################################
# PROBLEM SET ITEMS
########################################

cat <<'EOF' > app/models/problem_set_item.py
from sqlalchemy import Column, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID

from app.db.base import Base


class ProblemSetItem(Base):
    __tablename__ = "problem_set_items"

    problem_set_id = Column(UUID(as_uuid=True), ForeignKey("problem_sets.id"), primary_key=True)
    problem_id = Column(UUID(as_uuid=True), ForeignKey("problems.id"), primary_key=True)

    order_index = Column(Integer, nullable=False)
EOF


########################################
# SCHEMA
########################################

cat <<'EOF' > app/schemas/problem.py
from pydantic import BaseModel
from uuid import UUID
from typing import Optional


class ProblemResponse(BaseModel):
    id: UUID
    title: str
    difficulty: str
    leetcode_url: Optional[str]

    class Config:
        from_attributes = True
EOF


########################################
# SERVICE
########################################

cat <<'EOF' > app/services/problem_service.py
from sqlalchemy.orm import Session
from app.models.problem import Problem


def get_all_problems(db: Session):
    return db.query(Problem).all()


def get_problem(db: Session, problem_id):
    return db.query(Problem).filter(Problem.id == problem_id).first()
EOF


########################################
# ROUTES
########################################

cat <<'EOF' > app/api/v1/problems/routes.py
from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from typing import List

from app.db.session import get_db
from app.schemas.problem import ProblemResponse
from app.services.problem_service import get_all_problems, get_problem

router = APIRouter(prefix="/problems", tags=["problems"])


@router.get("/", response_model=List[ProblemResponse])
def get_problems(db: Session = Depends(get_db)):
    return get_all_problems(db)


@router.get("/{problem_id}", response_model=ProblemResponse)
def get_problem_by_id(problem_id: str, db: Session = Depends(get_db)):
    return get_problem(db, problem_id)
EOF


########################################
# SEED DATA
########################################

cat <<'EOF' > scripts/seed_problem_system.py
import sys
import os

sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from app.db.session import SessionLocal
from app.models.problem import Problem
from app.models.category import Category
from app.models.problem_category import ProblemCategory
from app.models.problem_set import ProblemSet
from app.models.problem_set_item import ProblemSetItem

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
EOF

echo "✅ Problem System Installed"
