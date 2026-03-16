from sqlalchemy import Column, ForeignKey, Integer
from sqlalchemy.dialects.postgresql import UUID

from app.db.base import Base


class ProblemSetItem(Base):
    __tablename__ = "problem_set_items"

    problem_set_id = Column(UUID(as_uuid=True), ForeignKey("problem_sets.id"), primary_key=True)
    problem_id = Column(UUID(as_uuid=True), ForeignKey("problems.id"), primary_key=True)

    order_index = Column(Integer, nullable=False)
