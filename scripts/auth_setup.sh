#!/bin/bash
set -e

echo "🔐 Setting up production-safe authentication..."

cd backend
source venv/bin/activate

echo "📦 Installing auth dependencies..."
pip install passlib[bcrypt] python-jose fastapi
pip freeze > requirements.txt

# ------------------------------------
# Ensure directory structure
# ------------------------------------
mkdir -p app/core app/services app/schemas app/api/v1/auth

# ------------------------------------
# core/security.py
# ------------------------------------
cat <<'EOF' > app/core/security.py
from datetime import datetime, timedelta, timezone
from jose import jwt, JWTError
from passlib.context import CryptContext
from app.core.config import settings

pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

ALGORITHM = "HS256"
ACCESS_TOKEN_EXPIRE_MINUTES = 60


def hash_password(password: str) -> str:
    return pwd_context.hash(password)


def verify_password(password: str, hashed: str) -> bool:
    return pwd_context.verify(password, hashed)


def create_access_token(user_id: str) -> str:
    now = datetime.now(tz=timezone.utc)
    payload = {
        "sub": user_id,
        "iat": now,
        "exp": now + timedelta(minutes=ACCESS_TOKEN_EXPIRE_MINUTES),
        "type": "access",
    }
    return jwt.encode(payload, settings.JWT_SECRET, algorithm=ALGORITHM)


def decode_access_token(token: str) -> str | None:
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[ALGORITHM])
        if payload.get("type") != "access":
            raise JWTError("Invalid token type")
        return payload.get("sub")
    except JWTError:
        return None
EOF

# ------------------------------------
# schemas/auth.py
# ------------------------------------
cat <<'EOF' > app/schemas/auth.py
from pydantic import BaseModel, EmailStr, Field

class SignupRequest(BaseModel):
    email: EmailStr
    password: str = Field(min_length=8)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
EOF

# ------------------------------------
# services/auth_service.py
# ------------------------------------
cat <<'EOF' > app/services/auth_service.py
from sqlalchemy.orm import Session
from app.models.user import User
from app.core.security import hash_password, verify_password, create_access_token


def signup(db: Session, email: str, password: str) -> User:
    existing = db.query(User).filter(User.email == email).first()
    if existing:
        raise ValueError("User already exists")

    user = User(
        email=email,
        password_hash=hash_password(password),
    )
    db.add(user)
    db.commit()
    db.refresh(user)
    return user


def login(db: Session, email: str, password: str) -> str:
    user = db.query(User).filter(User.email == email).first()
    if not user:
        raise ValueError("Invalid credentials")

    if not verify_password(password, user.password_hash):
        raise ValueError("Invalid credentials")

    return create_access_token(str(user.id))
EOF

# ------------------------------------
# api/v1/auth/routes.py
# ------------------------------------
cat <<'EOF' > app/api/v1/auth/routes.py
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session

from app.db.session import get_db
from app.schemas.auth import SignupRequest, LoginRequest, TokenResponse
from app.services.auth_service import signup, login

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/signup", status_code=status.HTTP_201_CREATED)
def signup_user(payload: SignupRequest, db: Session = Depends(get_db)):
    try:
        user = signup(db, payload.email, payload.password)
        return {"id": str(user.id), "email": user.email}
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@router.post("/login", response_model=TokenResponse)
def login_user(payload: LoginRequest, db: Session = Depends(get_db)):
    try:
        token = login(db, payload.email, payload.password)
        return TokenResponse(access_token=token)
    except ValueError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )
EOF

echo "✅ Production-safe authentication code generated"
