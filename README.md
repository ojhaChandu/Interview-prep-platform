# Interview Prep Platform

A production-ready interview preparation platform with AI assistance, built with Next.js, FastAPI, and PostgreSQL.

## 🚀 Features

- **Problem Solving**: 100+ LeetCode-style coding problems with test cases
- **AI Assistant**: GPT-powered explanations and coding help with RAG system
- **Notes Management**: Create, edit, and organize study notes
- **Code Editor**: Monaco editor with syntax highlighting and code execution
- **User Authentication**: JWT-based secure authentication
- **Responsive Design**: Modern UI with Tailwind CSS and shadcn/ui
- **Real-time Features**: Live code execution and AI chat

## 🛠️ Tech Stack

### Frontend
- **Framework**: Next.js 15 with App Router
- **Language**: TypeScript
- **Styling**: Tailwind CSS + shadcn/ui components
- **Code Editor**: Monaco Editor
- **HTTP Client**: Axios
- **Syntax Highlighting**: react-syntax-highlighter

### Backend
- **Framework**: FastAPI (Python)
- **Database**: PostgreSQL with SQLAlchemy ORM
- **Authentication**: JWT tokens
- **AI Integration**: Groq API with RAG pipeline
- **Vector Database**: pgvector for embeddings
- **Migrations**: Alembic

### Infrastructure
- **Database**: PostgreSQL 15+
- **Vector Search**: pgvector extension
- **API Documentation**: Swagger/OpenAPI
- **Development**: Docker support

## 📋 Prerequisites

- Node.js 18+ and npm
- Python 3.9+
- PostgreSQL 15+ with pgvector extension
- Groq API key for AI features

## 🚀 Quick Start

### 1. Clone Repository
```bash
git clone https://github.com/ojhaChandu/Interview-prep-platform.git
cd Interview-prep-platform
```

### 2. Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt

# Set environment variables
cp .env.example .env
# Edit .env with your database and API keys

# Run migrations
alembic upgrade head

# Seed database with problems
python scripts/seed_leetcode_100.py

# Start server
uvicorn app.main:app --reload
```

### 3. Frontend Setup
```bash
cd frontend
npm install
npm run dev
```

### 4. Access Application
- Frontend: http://localhost:3000
- Backend API: http://localhost:8000
- API Documentation: http://localhost:8000/docs

## 📚 Documentation

- [Backend Architecture](./docs/BACKEND.md) - Detailed backend structure and API documentation
- [Frontend Architecture](./docs/FRONTEND.md) - Frontend components and routing structure
- [System Architecture](./docs/ARCHITECTURE.md) - Complete system design and data flow
- [AI System Design](./docs/AI_SYSTEM.md) - RAG pipeline and AI integration details

## 🔧 Environment Variables

### Backend (.env)
```env
DATABASE_URL=postgresql://user:password@localhost/interview_prep
GROQ_API_KEY=your_groq_api_key
JWT_SECRET_KEY=your_jwt_secret
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=30
```

### Frontend (.env.local)
```env
NEXT_PUBLIC_API_URL=http://localhost:8000
```

## 🗄️ Database Schema

Key entities:
- **Users**: Authentication and user management
- **Problems**: Coding problems with difficulty levels
- **TestCases**: Input/output test cases for problems
- **Notes**: User study notes
- **KnowledgeBase**: Vector embeddings for AI RAG system

## 🤖 AI Features

- **Problem Explanations**: AI-powered detailed problem breakdowns
- **Code Help**: Interactive coding assistance
- **Personal Context**: AI knows your notes and progress
- **RAG System**: Retrieval-Augmented Generation for accurate responses

## 🧪 Testing

### Backend Tests
```bash
cd backend
pytest
```

### Frontend Tests
```bash
cd frontend
npm test
```

## 📦 Deployment

### Production Build
```bash
# Frontend
cd frontend
npm run build

# Backend
cd backend
pip install -r requirements.txt
```

### Docker Deployment
```bash
docker-compose up -d
```

## 🤝 Contributing

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- LeetCode for problem inspiration
- OpenAI/Groq for AI capabilities
- shadcn/ui for beautiful components
- FastAPI and Next.js communities

## 📞 Support

For support, email support@interviewprep.com or create an issue on GitHub.

---

**Built with ❤️ for interview preparation**