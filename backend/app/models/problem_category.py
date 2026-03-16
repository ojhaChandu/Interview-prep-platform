from sqlalchemy import Column, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base

class ProblemCategory(Base):
    __tablename__ = "problem_categories"

    problem_id = Column(UUID(as_uuid=True), ForeignKey("problems.id"), primary_key=True)
    category_id = Column(UUID(as_uuid=True), ForeignKey("categories.id"), primary_key=True)
