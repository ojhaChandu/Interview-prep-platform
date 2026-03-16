from fastapi import APIRouter, Depends
from pydantic import BaseModel
from sqlalchemy.orm import Session

from app.ai.router import AIRouter
from app.db.session import get_db
from app.core.auth_dependency import get_current_user
from app.models.user import User

router = APIRouter(prefix="/ai", tags=["ai"])

ai_router = AIRouter()

class AIRequest(BaseModel):
    query: str

@router.post("/chat")
def chat(req: AIRequest, db: Session = Depends(get_db), current_user: User = Depends(get_current_user)):

    answer = ai_router.route(db, req.query, current_user.id)

    return {"answer": answer}
