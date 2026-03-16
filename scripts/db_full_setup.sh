#!/bin/bash
set -e

echo "🗄️ Full database setup (robust version)..."

cd backend
source venv/bin/activate

echo "📦 Installing DB dependencies..."
pip install sqlalchemy alembic psycopg2-binary
pip freeze > requirements.txt

# -----------------------------
# Initialize Alembic if needed
# -----------------------------
if [ ! -d "alembic" ]; then
  alembic init alembic
fi

# -----------------------------
# Ensure DB core files exist
# -----------------------------
mkdir -p app/db app/models

# db/base.py
cat <<'EOF' > app/db/base.py
from sqlalchemy.orm import declarative_base

Base = declarative_base()
EOF

# db/session.py
cat <<'EOF' > app/db/session.py
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from app.core.config import settings

engine = create_engine(settings.DATABASE_URL, pool_pre_ping=True)

SessionLocal = sessionmaker(
    autocommit=False,
    autoflush=False,
    bind=engine
)

def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
EOF

# -----------------------------
# Models
# -----------------------------
cat <<'EOF' > app/models/user.py
import uuid
from sqlalchemy import Column, String, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db.base import Base

class User(Base):
    __tablename__ = "users"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, index=True, nullable=False)
    password_hash = Column(String, nullable=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
EOF

cat <<'EOF' > app/models/note.py
import uuid
from sqlalchemy import Column, String, Text, DateTime, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db.base import Base

class Note(Base):
    __tablename__ = "notes"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    owner_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    content = Column(Text)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), onupdate=func.now())
EOF

cat <<'EOF' > app/models/problem.py
import uuid
from sqlalchemy import Column, String, DateTime
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.sql import func
from app.db.base import Base

class Problem(Base):
    __tablename__ = "problems"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    title = Column(String, nullable=False)
    slug = Column(String, unique=True, nullable=False)
    difficulty = Column(String, nullable=False)
    source = Column(String, nullable=False)

    created_at = Column(DateTime(timezone=True), server_default=func.now())
EOF

cat <<'EOF' > app/models/category.py
import uuid
from sqlalchemy import Column, String
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base

class Category(Base):
    __tablename__ = "categories"

    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    name = Column(String, unique=True, nullable=False)
    type = Column(String, nullable=False)
EOF

cat <<'EOF' > app/models/note_problem.py
from sqlalchemy import Column, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base

class NoteProblem(Base):
    __tablename__ = "note_problems"

    note_id = Column(UUID(as_uuid=True), ForeignKey("notes.id"), primary_key=True)
    problem_id = Column(UUID(as_uuid=True), ForeignKey("problems.id"), primary_key=True)
EOF

cat <<'EOF' > app/models/problem_category.py
from sqlalchemy import Column, ForeignKey
from sqlalchemy.dialects.postgresql import UUID
from app.db.base import Base

class ProblemCategory(Base):
    __tablename__ = "problem_categories"

    problem_id = Column(UUID(as_uuid=True), ForeignKey("problems.id"), primary_key=True)
    category_id = Column(UUID(as_uuid=True), ForeignKey("categories.id"), primary_key=True)
EOF

cat <<'EOF' > app/models/note_share.py
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
EOF

# -----------------------------
# Overwrite Alembic env.py safely
# -----------------------------
cat <<'EOF' > alembic/env.py
from logging.config import fileConfig
from sqlalchemy import engine_from_config, pool
from alembic import context

from app.core.config import settings
from app.db.base import Base
from app.models import (
    user,
    note,
    problem,
    category,
    note_problem,
    problem_category,
    note_share,
)

config = context.config
config.set_main_option("sqlalchemy.url", settings.DATABASE_URL)

fileConfig(config.config_file_name)

target_metadata = Base.metadata

def run_migrations_offline():
    context.configure(
        url=settings.DATABASE_URL,
        target_metadata=target_metadata,
        literal_binds=True,
        dialect_opts={"paramstyle": "named"},
    )

    with context.begin_transaction():
        context.run_migrations()

def run_migrations_online():
    connectable = engine_from_config(
        config.get_section(config.config_ini_section),
        prefix="sqlalchemy.",
        poolclass=pool.NullPool,
    )

    with connectable.connect() as connection:
        context.configure(
            connection=connection,
            target_metadata=target_metadata,
        )

        with context.begin_transaction():
            context.run_migrations()

if context.is_offline_mode():
    run_migrations_offline()
else:
    run_migrations_online()
EOF

# -----------------------------
# Run migrations
# -----------------------------
echo "🧬 Generating migration..."
alembic revision --autogenerate -m "initial schema"

echo "⬆️ Applying migration..."
alembic upgrade head

echo "✅ Database schema created successfully"
