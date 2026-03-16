from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from uuid import UUID

class NoteBase(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    content: Optional[str] = None


class NoteCreate(NoteBase):
    pass


class NoteUpdate(BaseModel):
    title: Optional[str] = Field(None, min_length=1, max_length=255)
    content: Optional[str] = None


class NoteResponse(NoteBase):
    id: UUID
    owner_id: UUID
    created_at: datetime
    updated_at: datetime

    class Config:
        from_attributes = True


class NoteShare(BaseModel):
    email: str
    permission: str = "read"
