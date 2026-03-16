from sqlalchemy import Column, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base

class NoteProblem(Base):
    __tablename__ = "note_problems"

    note_id = Column(UUID(as_uuid=True), ForeignKey("notes.id"), primary_key=True)
    problem_id = Column(UUID(as_uuid=True), ForeignKey("problems.id"), primary_key=True)
