from sqlalchemy import Column, ForeignKey, String, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db.base import Base

class NoteShare(Base):
    __tablename__ = "note_shares"

    note_id = Column(UUID(as_uuid=True), ForeignKey("notes.id"), primary_key=True)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), primary_key=True)
    permission = Column(String, nullable=False)
    shared_at = Column(DateTime(timezone=True), server_default=func.now())
