#!/bin/bash
set -e

echo "🐍 Setting up FastAPI backend..."

cd backend

# Virtual environment
python3 -m venv venv
source venv/bin/activate

# Dependencies
pip install fastapi uvicorn python-dotenv
pip freeze > requirements.txt

# Folder structure
mkdir -p app/{api/v1/{auth,users,notes,problems,lld,hld,ai},core,models,schemas,services,db,utils}
mkdir tests

# main.py
cat <<EOF > app/main.py
from fastapi import FastAPI
from app.core.config import settings

app = FastAPI(
    title=settings.PROJECT_NAME,
    version="1.0.0"
)

@app.get("/health")
def health_check():
    return {"status": "ok"}
EOF

# config.py
cat <<EOF > app/core/config.py
from dotenv import load_dotenv
import os

load_dotenv()

class Settings:
    PROJECT_NAME: str = "Interview Prep Platform"
    DATABASE_URL: str = os.getenv("DATABASE_URL", "")
    JWT_SECRET: str = os.getenv("JWT_SECRET", "change_me")

settings = Settings()
EOF

# .env
cat <<EOF > .env
DATABASE_URL=postgresql://user:password@localhost:5432/interview_prep
JWT_SECRET=supersecret
EOF

echo "✅ Backend setup complete"
echo "➡️  Run: cd backend && source venv/bin/activate && uvicorn app.main:app --reload"
