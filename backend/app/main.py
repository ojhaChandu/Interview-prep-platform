from fastapi import FastAPI, Depends
from app.core.config import settings
from app.api.v1.auth.routes import router as auth_router
from app.core.auth_dependency import get_current_user
from app.models.user import User
from app.api.v1.notes.routes import router as notes_router
from app.api.v1.problems.routes import router as problem_router
from app.api.v1.ai.routes import router as ai_router
from app.api.v1.ai_tools.routes import router as ai_tools_router
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

load_dotenv()

app = FastAPI(
    title=settings.PROJECT_NAME,
    version="1.0.0"
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(notes_router, prefix="/api/v1")
app.include_router(auth_router, prefix="/api/v1")
app.include_router(problem_router, prefix="/api/v1")
app.include_router(ai_router, prefix="/api/v1")
app.include_router(ai_tools_router)

@app.get("/health")
def health_check():
    return {"status": "ok"}


@app.get("/api/v1/me")
def read_current_user(current_user: User = Depends(get_current_user)):
    return {
        "id": current_user.id,
        "email": current_user.email
    }
