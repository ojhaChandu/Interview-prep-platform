# Backend Architecture

The backend is built with FastAPI and follows a clean architecture pattern with clear separation of concerns.

## 🏗️ Project Structure

```
backend/
├── app/
│   ├── main.py                 # FastAPI application entry point
│   ├── core/                   # Core configuration and utilities
│   │   ├── config.py          # Environment configuration
│   │   ├── database.py        # Database connection setup
│   │   └── auth_dependency.py # JWT authentication dependency
│   ├── models/                 # SQLAlchemy ORM models
│   │   ├── user.py            # User model
│   │   ├── problem.py         # Problem model
│   │   ├── test_case.py       # TestCase model
│   │   ├── note.py            # Note model
│   │   └── knowledge_base.py  # AI knowledge base model
│   ├── schemas/                # Pydantic schemas for API
│   │   ├── user.py            # User request/response schemas
│   │   ├── problem.py         # Problem schemas
│   │   ├── note.py            # Note schemas
│   │   └── auth.py            # Authentication schemas
│   ├── services/               # Business logic layer
│   │   ├── auth_service.py    # Authentication logic
│   │   ├── problem_service.py # Problem management
│   │   ├── note_service.py    # Notes management
│   │   └── user_service.py    # User management
│   ├── api/                    # API route handlers
│   │   └── v1/                # API version 1
│   │       ├── auth/          # Authentication endpoints
│   │       ├── problems/      # Problem endpoints
│   │       ├── notes/         # Notes endpoints
│   │       └── ai/            # AI assistant endpoints
│   ├── ai/                     # AI system components
│   │   ├── router.py          # AI request routing
│   │   ├── rag/               # RAG pipeline
│   │   ├── providers/         # AI provider integrations
│   │   ├── embeddings/        # Text embedding generation
│   │   └── indexer/           # Knowledge indexing
│   └── db/                     # Database utilities
│       ├── base.py            # Base model class
│       └── session.py         # Database session management
├── alembic/                    # Database migrations
├── scripts/                    # Utility scripts
└── requirements.txt           # Python dependencies
```

## 🗄️ Database Models

### User Model
```python
class User(Base):
    __tablename__ = "users"
    
    id = Column(UUID, primary_key=True, default=uuid.uuid4)
    email = Column(String, unique=True, nullable=False)
    hashed_password = Column(String, nullable=False)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())
```

### Problem Model
```python
class Problem(Base):
    __tablename__ = "problems"
    
    id = Column(UUID, primary_key=True, default=uuid.uuid4)
    title = Column(String, nullable=False)
    slug = Column(String, unique=True, nullable=False)
    difficulty = Column(String, nullable=False)  # Easy, Medium, Hard
    description = Column(Text)
    source = Column(String)  # LeetCode, HackerRank, etc.
    
    # Relationships
    test_cases = relationship("TestCase", back_populates="problem", cascade="all, delete-orphan")
```

### TestCase Model
```python
class TestCase(Base):
    __tablename__ = "test_cases"
    
    id = Column(UUID, primary_key=True, default=uuid.uuid4)
    problem_id = Column(UUID, ForeignKey("problems.id"), nullable=False)
    input_data = Column(Text, nullable=False)
    expected_output = Column(Text, nullable=False)
    is_hidden = Column(Boolean, default=False)
    order_index = Column(Integer, default=0)
    
    # Relationships
    problem = relationship("Problem", back_populates="test_cases")
```

### Note Model
```python
class Note(Base):
    __tablename__ = "notes"
    
    id = Column(UUID, primary_key=True, default=uuid.uuid4)
    owner_id = Column(UUID, ForeignKey("users.id"), nullable=False)
    title = Column(String, nullable=False)
    content = Column(Text)
    created_at = Column(DateTime, server_default=func.now())
    updated_at = Column(DateTime, onupdate=func.now())
```

## 🔌 API Endpoints

### Authentication Endpoints
- `POST /api/v1/auth/signup` - User registration
- `POST /api/v1/auth/login` - User login (returns JWT token)

### Problem Endpoints
- `GET /api/v1/problems/` - List all problems
- `GET /api/v1/problems/{id}` - Get problem by ID
- `GET /api/v1/problems/{id}/detail` - Get problem with test cases

### Notes Endpoints
- `GET /api/v1/notes/` - Get user's notes
- `POST /api/v1/notes/` - Create new note
- `GET /api/v1/notes/{id}` - Get specific note
- `PUT /api/v1/notes/{id}` - Update note
- `DELETE /api/v1/notes/{id}` - Delete note

### AI Endpoints
- `POST /api/v1/ai/chat` - Chat with AI assistant

## 🔐 Authentication System

### JWT Implementation
```python
def create_access_token(data: dict, expires_delta: Optional[timedelta] = None):
    to_encode = data.copy()
    if expires_delta:
        expire = datetime.utcnow() + expires_delta
    else:
        expire = datetime.utcnow() + timedelta(minutes=15)
    
    to_encode.update({"exp": expire})
    encoded_jwt = jwt.encode(to_encode, SECRET_KEY, algorithm=ALGORITHM)
    return encoded_jwt
```

### Authentication Dependency
```python
async def get_current_user(token: str = Depends(oauth2_scheme), db: Session = Depends(get_db)):
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": "Bearer"},
    )
    
    try:
        payload = jwt.decode(token, SECRET_KEY, algorithms=[ALGORITHM])
        email: str = payload.get("sub")
        if email is None:
            raise credentials_exception
    except JWTError:
        raise credentials_exception
    
    user = get_user_by_email(db, email=email)
    if user is None:
        raise credentials_exception
    return user
```

## 🧠 AI System Integration

### RAG Pipeline
The backend implements a Retrieval-Augmented Generation (RAG) system:

1. **Knowledge Indexing**: Notes and problems are indexed with vector embeddings
2. **Context Retrieval**: Relevant context is retrieved based on user queries
3. **Response Generation**: AI generates responses using retrieved context

### AI Router
```python
class AIRouter:
    def route(self, db, query: str, user_id: str = None):
        # Retrieve relevant context
        context_chunks = search_similar_knowledge(db, query)
        
        # Add user-specific context
        if user_id:
            user_notes = get_user_notes(db, user_id)
            user_context = self._format_user_context(user_notes)
            context = context_chunks + [user_context]
        
        # Generate response
        return self._generate_response(query, context)
```

## 🗃️ Database Configuration

### PostgreSQL with pgvector
```python
# Database URL format
DATABASE_URL = "postgresql://user:password@localhost/interview_prep"

# pgvector extension for embeddings
CREATE EXTENSION IF NOT EXISTS vector;

# Knowledge base table with vector column
CREATE TABLE knowledge_base (
    id UUID PRIMARY KEY,
    source_type VARCHAR(50),
    source_id UUID,
    content TEXT,
    embedding vector(1536),  -- OpenAI embedding dimension
    created_at TIMESTAMP DEFAULT NOW()
);

# Vector similarity index
CREATE INDEX ON knowledge_base USING ivfflat (embedding vector_cosine_ops);
```

## 🔄 Service Layer Pattern

### Problem Service Example
```python
class ProblemService:
    def __init__(self, db: Session):
        self.db = db
    
    def get_problems(self, skip: int = 0, limit: int = 100):
        return self.db.query(Problem).offset(skip).limit(limit).all()
    
    def get_problem_with_test_cases(self, problem_id: str):
        return self.db.query(Problem)\
            .options(joinedload(Problem.test_cases))\
            .filter(Problem.id == problem_id)\
            .first()
    
    def create_problem(self, problem_data: ProblemCreate):
        db_problem = Problem(**problem_data.dict())
        self.db.add(db_problem)
        self.db.commit()
        self.db.refresh(db_problem)
        return db_problem
```

## 🚀 Performance Optimizations

### Database Optimizations
- **Indexes**: Strategic indexes on frequently queried columns
- **Connection Pooling**: SQLAlchemy connection pooling
- **Query Optimization**: Use of `joinedload` for eager loading
- **Vector Search**: Efficient similarity search with pgvector

### Caching Strategy
- **Response Caching**: Cache AI responses for common queries
- **Database Query Caching**: Cache expensive database operations
- **Static Content**: Cache problem descriptions and test cases

## 🧪 Testing Strategy

### Unit Tests
```python
def test_create_user():
    user_data = {"email": "test@example.com", "password": "testpass123"}
    user = create_user(db, user_data)
    assert user.email == "test@example.com"
    assert user.id is not None

def test_get_problems():
    problems = get_problems(db)
    assert len(problems) > 0
    assert problems[0].title is not None
```

### Integration Tests
- API endpoint testing with TestClient
- Database integration tests
- AI system integration tests

## 🔧 Configuration Management

### Environment Variables
```python
class Settings(BaseSettings):
    database_url: str
    groq_api_key: str
    jwt_secret_key: str
    jwt_algorithm: str = "HS256"
    jwt_access_token_expire_minutes: int = 30
    
    class Config:
        env_file = ".env"

settings = Settings()
```

## 📊 Monitoring and Logging

### Logging Configuration
```python
import logging

logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    handlers=[
        logging.FileHandler("app.log"),
        logging.StreamHandler()
    ]
)

logger = logging.getLogger(__name__)
```

### Health Checks
```python
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "timestamp": datetime.utcnow(),
        "version": "1.0.0"
    }
```

## 🚀 Deployment Considerations

### Production Settings
- Use environment variables for all secrets
- Enable CORS for frontend domain only
- Set up proper logging and monitoring
- Use connection pooling for database
- Implement rate limiting for AI endpoints

### Docker Configuration
```dockerfile
FROM python:3.9-slim

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt

COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```