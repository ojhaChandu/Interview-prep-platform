from fastapi import APIRouter
from pydantic import BaseModel

router = APIRouter(prefix="/ai-tools")


class TestRequest(BaseModel):
    message: str


@router.post("/test")
def test_ai(req: TestRequest):
    return {
        "message": req.message,
        "status": "AI tools working"
    }
