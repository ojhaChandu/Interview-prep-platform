# AI System Technical Design

This document provides an in-depth technical overview of the AI system powering the Interview Prep Platform, including the RAG pipeline, vector embeddings, and AI integration architecture.

## 🧠 AI System Overview

The AI system is built around a Retrieval-Augmented Generation (RAG) architecture that combines vector similarity search with large language model generation to provide contextually relevant and personalized responses.

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Query     │    │  Embedding  │    │  Retrieval  │    │ Generation  │
│ Processing  │───►│  Generation │───►│   System    │───►│   System    │
│             │    │             │    │             │    │             │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

## 🏗️ RAG Pipeline Architecture

### 1. Knowledge Indexing Pipeline
```python
# Knowledge indexing workflow
class KnowledgeIndexer:
    def __init__(self):
        self.embedder = OpenAIEmbeddings()
        self.chunker = TextChunker(chunk_size=1000, overlap=200)
        
    def index_content(self, content: str, source_type: str, source_id: str):
        # 1. Chunk the content
        chunks = self.chunker.chunk_text(content)
        
        # 2. Generate embeddings for each chunk
        for chunk in chunks:
            embedding = self.embedder.embed(chunk)
            
            # 3. Store in vector database
            self.store_embedding(
                content=chunk,
                embedding=embedding,
                source_type=source_type,
                source_id=source_id
            )
```

### 2. Query Processing Pipeline
```python
class QueryProcessor:
    def __init__(self):
        self.embedder = OpenAIEmbeddings()
        self.retriever = VectorRetriever()
        self.generator = GroqGenerator()
        
    async def process_query(self, query: str, user_id: str) -> str:
        # 1. Generate query embedding
        query_embedding = await self.embedder.embed(query)
        
        # 2. Retrieve relevant context
        context = await self.retriever.retrieve(
            query_embedding=query_embedding,
            user_id=user_id,
            top_k=5
        )
        
        # 3. Add user-specific context
        user_context = await self.get_user_context(user_id)
        
        # 4. Generate response
        response = await self.generator.generate(
            query=query,
            context=context + user_context
        )
        
        return response
```

## 🔍 Vector Embedding System

### Embedding Model Configuration
```python
# OpenAI Embeddings Configuration
class EmbeddingService:
    def __init__(self):
        self.model = "text-embedding-ada-002"
        self.dimension = 1536
        self.max_tokens = 8191
        
    async def embed_text(self, text: str) -> List[float]:
        # Truncate text if too long
        if len(text) > self.max_tokens:
            text = text[:self.max_tokens]
            
        response = await openai.Embedding.acreate(
            model=self.model,
            input=text
        )
        
        return response['data'][0]['embedding']
    
    async def embed_batch(self, texts: List[str]) -> List[List[float]]:
        # Batch processing for efficiency
        response = await openai.Embedding.acreate(
            model=self.model,
            input=texts
        )
        
        return [item['embedding'] for item in response['data']]
```

### Vector Database Schema
```sql
-- Knowledge base table with vector embeddings
CREATE TABLE knowledge_base (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    source_type VARCHAR(50) NOT NULL,  -- 'problem', 'note', 'solution'
    source_id UUID,                    -- Reference to source entity
    content TEXT NOT NULL,             -- Actual text content
    embedding vector(1536),            -- OpenAI embedding vector
    metadata JSONB,                    -- Additional metadata
    created_at TIMESTAMP DEFAULT NOW(),
    updated_at TIMESTAMP DEFAULT NOW()
);

-- Indexes for efficient vector search
CREATE INDEX ON knowledge_base USING ivfflat (embedding vector_cosine_ops) WITH (lists = 100);
CREATE INDEX idx_knowledge_source ON knowledge_base(source_type, source_id);
CREATE INDEX idx_knowledge_created ON knowledge_base(created_at);
```

### Vector Similarity Search
```python
class VectorRetriever:
    def __init__(self, db: Session):
        self.db = db
        
    async def retrieve(
        self, 
        query_embedding: List[float], 
        user_id: str = None,
        top_k: int = 5,
        similarity_threshold: float = 0.7
    ) -> List[str]:
        
        # Convert embedding to pgvector format
        embedding_str = "[" + ",".join(map(str, query_embedding)) + "]"
        
        # Base query for similarity search
        query = """
        SELECT 
            content,
            source_type,
            source_id,
            1 - (embedding <=> %s) as similarity
        FROM knowledge_base
        WHERE 1 - (embedding <=> %s) > %s
        """
        
        params = [embedding_str, embedding_str, similarity_threshold]
        
        # Add user-specific filtering if user_id provided
        if user_id:
            query += """
            AND (
                source_type = 'global' 
                OR (source_type = 'note' AND source_id IN (
                    SELECT id FROM notes WHERE owner_id = %s
                ))
            )
            """
            params.append(user_id)
        
        query += " ORDER BY similarity DESC LIMIT %s"
        params.append(top_k)
        
        result = self.db.execute(text(query), params)
        return [row.content for row in result.fetchall()]
```

## 🤖 LLM Integration

### Groq API Integration
```python
class GroqGenerator:
    def __init__(self):
        self.client = Groq(api_key=settings.groq_api_key)
        self.model = "mixtral-8x7b-32768"
        self.max_tokens = 2048
        self.temperature = 0.7
        
    async def generate(
        self, 
        query: str, 
        context: List[str],
        system_prompt: str = None
    ) -> str:
        
        # Construct context string
        context_str = "\n\n".join(context) if context else ""
        
        # Default system prompt
        if not system_prompt:
            system_prompt = self._get_default_system_prompt()
        
        # Construct user message
        user_message = f"""
        Context information:
        {context_str}
        
        User question:
        {query}
        
        Please provide a helpful and accurate response based on the context provided.
        """
        
        try:
            response = await self.client.chat.completions.create(
                model=self.model,
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": user_message}
                ],
                max_tokens=self.max_tokens,
                temperature=self.temperature
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            logger.error(f"Groq API error: {e}")
            return "I apologize, but I'm having trouble generating a response right now. Please try again later."
    
    def _get_default_system_prompt(self) -> str:
        return """
        You are a helpful AI assistant for an interview preparation platform.
        You help users with coding problems, algorithms, data structures, and interview preparation.
        
        Guidelines:
        - Provide clear, accurate, and helpful explanations
        - Use the context information when relevant
        - If you don't know something, say so honestly
        - Format code examples clearly with proper syntax
        - Be encouraging and supportive
        - Focus on educational value and learning
        """
```

### Response Streaming
```python
class StreamingGenerator:
    async def generate_stream(
        self, 
        query: str, 
        context: List[str]
    ) -> AsyncGenerator[str, None]:
        
        response = await self.client.chat.completions.create(
            model=self.model,
            messages=self._build_messages(query, context),
            stream=True
        )
        
        async for chunk in response:
            if chunk.choices[0].delta.content:
                yield chunk.choices[0].delta.content
```

## 🔄 Context Management

### User Context Aggregation
```python
class UserContextManager:
    def __init__(self, db: Session):
        self.db = db
        
    async def get_user_context(self, user_id: str) -> str:
        context_parts = []
        
        # Get user's notes
        notes = await self._get_user_notes(user_id)
        if notes:
            notes_summary = f"User's Notes ({len(notes)} total):\n"
            for note in notes[:5]:  # Limit to recent notes
                notes_summary += f"- {note.title}: {note.content[:100]}...\n"
            context_parts.append(notes_summary)
        
        # Get user's problem solving history
        solved_problems = await self._get_solved_problems(user_id)
        if solved_problems:
            problems_summary = f"Recently solved problems: {', '.join(solved_problems[:10])}"
            context_parts.append(problems_summary)
        
        return "\n\n".join(context_parts)
    
    async def _get_user_notes(self, user_id: str) -> List[Note]:
        return self.db.query(Note)\
            .filter(Note.owner_id == user_id)\
            .order_by(Note.updated_at.desc())\
            .limit(10)\
            .all()
```

### Dynamic Context Selection
```python
class ContextSelector:
    def __init__(self):
        self.max_context_length = 4000  # tokens
        
    def select_relevant_context(
        self, 
        query: str, 
        retrieved_chunks: List[str],
        user_context: str
    ) -> List[str]:
        
        # Score chunks by relevance
        scored_chunks = []
        for chunk in retrieved_chunks:
            score = self._calculate_relevance_score(query, chunk)
            scored_chunks.append((chunk, score))
        
        # Sort by relevance
        scored_chunks.sort(key=lambda x: x[1], reverse=True)
        
        # Select chunks within token limit
        selected_chunks = []
        current_length = len(user_context.split())
        
        for chunk, score in scored_chunks:
            chunk_length = len(chunk.split())
            if current_length + chunk_length <= self.max_context_length:
                selected_chunks.append(chunk)
                current_length += chunk_length
            else:
                break
        
        return [user_context] + selected_chunks
    
    def _calculate_relevance_score(self, query: str, chunk: str) -> float:
        # Simple keyword-based scoring (can be enhanced with ML)
        query_words = set(query.lower().split())
        chunk_words = set(chunk.lower().split())
        
        intersection = query_words.intersection(chunk_words)
        union = query_words.union(chunk_words)
        
        return len(intersection) / len(union) if union else 0
```

## 📊 Content Processing Pipeline

### Text Chunking Strategy
```python
class TextChunker:
    def __init__(self, chunk_size: int = 1000, overlap: int = 200):
        self.chunk_size = chunk_size
        self.overlap = overlap
        
    def chunk_text(self, text: str) -> List[str]:
        # Split by paragraphs first
        paragraphs = text.split('\n\n')
        chunks = []
        current_chunk = ""
        
        for paragraph in paragraphs:
            # If adding this paragraph exceeds chunk size
            if len(current_chunk) + len(paragraph) > self.chunk_size:
                if current_chunk:
                    chunks.append(current_chunk.strip())
                    
                    # Start new chunk with overlap
                    overlap_text = self._get_overlap_text(current_chunk)
                    current_chunk = overlap_text + paragraph
                else:
                    # Paragraph itself is too long, split it
                    chunks.extend(self._split_long_paragraph(paragraph))
                    current_chunk = ""
            else:
                current_chunk += "\n\n" + paragraph if current_chunk else paragraph
        
        # Add final chunk
        if current_chunk:
            chunks.append(current_chunk.strip())
        
        return chunks
    
    def _get_overlap_text(self, text: str) -> str:
        words = text.split()
        if len(words) <= self.overlap:
            return text
        return " ".join(words[-self.overlap:])
    
    def _split_long_paragraph(self, paragraph: str) -> List[str]:
        # Split long paragraphs by sentences
        sentences = paragraph.split('. ')
        chunks = []
        current_chunk = ""
        
        for sentence in sentences:
            if len(current_chunk) + len(sentence) > self.chunk_size:
                if current_chunk:
                    chunks.append(current_chunk.strip())
                current_chunk = sentence
            else:
                current_chunk += ". " + sentence if current_chunk else sentence
        
        if current_chunk:
            chunks.append(current_chunk.strip())
        
        return chunks
```

### Content Preprocessing
```python
class ContentPreprocessor:
    def __init__(self):
        self.stop_words = set(['the', 'a', 'an', 'and', 'or', 'but', 'in', 'on', 'at'])
        
    def preprocess_content(self, content: str, content_type: str) -> str:
        # Clean and normalize content
        content = self._clean_text(content)
        
        # Add content type context
        if content_type == "problem":
            content = f"Problem Description: {content}"
        elif content_type == "note":
            content = f"Study Note: {content}"
        elif content_type == "solution":
            content = f"Solution Explanation: {content}"
        
        return content
    
    def _clean_text(self, text: str) -> str:
        # Remove excessive whitespace
        text = ' '.join(text.split())
        
        # Remove special characters but keep code-related ones
        import re
        text = re.sub(r'[^\w\s\(\)\[\]\{\}\.\,\;\:\!\?\-\+\*\/\=\<\>\#]', '', text)
        
        return text.strip()
```

## 🎯 Query Understanding

### Intent Classification
```python
class QueryClassifier:
    def __init__(self):
        self.intent_patterns = {
            'explanation': ['explain', 'what is', 'how does', 'describe'],
            'solution': ['solve', 'solution', 'approach', 'algorithm'],
            'debugging': ['error', 'bug', 'wrong', 'fix', 'debug'],
            'optimization': ['optimize', 'improve', 'faster', 'efficient'],
            'comparison': ['difference', 'compare', 'vs', 'versus'],
            'personal': ['my notes', 'my progress', 'how many']
        }
    
    def classify_intent(self, query: str) -> str:
        query_lower = query.lower()
        
        for intent, patterns in self.intent_patterns.items():
            if any(pattern in query_lower for pattern in patterns):
                return intent
        
        return 'general'
    
    def extract_entities(self, query: str) -> Dict[str, List[str]]:
        # Extract programming languages, algorithms, data structures
        entities = {
            'languages': [],
            'algorithms': [],
            'data_structures': [],
            'concepts': []
        }
        
        # Simple keyword extraction (can be enhanced with NER)
        query_lower = query.lower()
        
        # Programming languages
        languages = ['python', 'java', 'javascript', 'c++', 'c', 'go', 'rust']
        entities['languages'] = [lang for lang in languages if lang in query_lower]
        
        # Algorithms
        algorithms = ['sorting', 'searching', 'dynamic programming', 'greedy', 'backtracking']
        entities['algorithms'] = [algo for algo in algorithms if algo in query_lower]
        
        # Data structures
        data_structures = ['array', 'list', 'tree', 'graph', 'hash', 'stack', 'queue']
        entities['data_structures'] = [ds for ds in data_structures if ds in query_lower]
        
        return entities
```

### Query Expansion
```python
class QueryExpander:
    def __init__(self):
        self.synonyms = {
            'array': ['list', 'vector', 'sequence'],
            'function': ['method', 'procedure', 'routine'],
            'algorithm': ['approach', 'solution', 'method'],
            'optimize': ['improve', 'enhance', 'speed up']
        }
    
    def expand_query(self, query: str) -> List[str]:
        expanded_queries = [query]
        
        # Add synonym variations
        words = query.lower().split()
        for word in words:
            if word in self.synonyms:
                for synonym in self.synonyms[word]:
                    expanded_query = query.lower().replace(word, synonym)
                    expanded_queries.append(expanded_query)
        
        return expanded_queries
```

## 🔧 Performance Optimization

### Caching Strategy
```python
class AIResponseCache:
    def __init__(self):
        self.redis_client = redis.Redis(host='localhost', port=6379, db=1)
        self.cache_ttl = 3600  # 1 hour
        
    async def get_cached_response(self, query_hash: str) -> Optional[str]:
        cached = await self.redis_client.get(f"ai_response:{query_hash}")
        return cached.decode() if cached else None
    
    async def cache_response(self, query_hash: str, response: str):
        await self.redis_client.setex(
            f"ai_response:{query_hash}", 
            self.cache_ttl, 
            response
        )
    
    def generate_query_hash(self, query: str, user_id: str) -> str:
        # Create hash from query and user context
        import hashlib
        content = f"{query}:{user_id}"
        return hashlib.md5(content.encode()).hexdigest()
```

### Batch Processing
```python
class BatchProcessor:
    def __init__(self):
        self.batch_size = 10
        self.processing_queue = asyncio.Queue()
        
    async def process_batch_embeddings(self, texts: List[str]) -> List[List[float]]:
        # Process embeddings in batches for efficiency
        embeddings = []
        
        for i in range(0, len(texts), self.batch_size):
            batch = texts[i:i + self.batch_size]
            batch_embeddings = await self.embedding_service.embed_batch(batch)
            embeddings.extend(batch_embeddings)
        
        return embeddings
```

## 📈 Monitoring and Analytics

### AI System Metrics
```python
class AIMetrics:
    def __init__(self):
        self.response_time_histogram = Histogram(
            'ai_response_time_seconds',
            'AI response generation time'
        )
        self.query_counter = Counter(
            'ai_queries_total',
            'Total AI queries',
            ['intent', 'user_type']
        )
        self.context_relevance_gauge = Gauge(
            'ai_context_relevance_score',
            'Average context relevance score'
        )
    
    def record_query(self, intent: str, user_type: str, response_time: float):
        self.query_counter.labels(intent=intent, user_type=user_type).inc()
        self.response_time_histogram.observe(response_time)
    
    def record_context_relevance(self, score: float):
        self.context_relevance_gauge.set(score)
```

### Quality Assessment
```python
class ResponseQualityAssessor:
    def __init__(self):
        self.quality_metrics = {
            'relevance': 0.0,
            'completeness': 0.0,
            'accuracy': 0.0,
            'helpfulness': 0.0
        }
    
    def assess_response_quality(
        self, 
        query: str, 
        response: str, 
        context: List[str]
    ) -> Dict[str, float]:
        
        # Simple heuristic-based quality assessment
        metrics = {}
        
        # Relevance: keyword overlap between query and response
        metrics['relevance'] = self._calculate_keyword_overlap(query, response)
        
        # Completeness: response length relative to query complexity
        metrics['completeness'] = min(len(response) / (len(query) * 3), 1.0)
        
        # Context usage: how much of the provided context was used
        metrics['context_usage'] = self._calculate_context_usage(response, context)
        
        return metrics
    
    def _calculate_keyword_overlap(self, query: str, response: str) -> float:
        query_words = set(query.lower().split())
        response_words = set(response.lower().split())
        
        intersection = query_words.intersection(response_words)
        return len(intersection) / len(query_words) if query_words else 0
    
    def _calculate_context_usage(self, response: str, context: List[str]) -> float:
        if not context:
            return 0.0
        
        response_lower = response.lower()
        used_contexts = 0
        
        for ctx in context:
            # Check if any significant words from context appear in response
            ctx_words = [w for w in ctx.lower().split() if len(w) > 4]
            if any(word in response_lower for word in ctx_words[:5]):
                used_contexts += 1
        
        return used_contexts / len(context)
```

## 🚀 Future Enhancements

### Advanced Features
1. **Multi-modal Support**: Handle code, images, and diagrams
2. **Conversation Memory**: Maintain context across multiple queries
3. **Personalized Learning**: Adapt responses based on user's learning style
4. **Code Generation**: Generate code solutions with explanations
5. **Interactive Tutorials**: Step-by-step problem-solving guidance

### Technical Improvements
1. **Fine-tuned Models**: Custom models trained on coding interview data
2. **Advanced Retrieval**: Hybrid search combining vector and keyword search
3. **Real-time Learning**: Update knowledge base from user interactions
4. **Multi-language Support**: Support for multiple programming languages
5. **Performance Optimization**: GPU acceleration for embeddings and inference

### Architecture Evolution
```python
# Future microservices architecture
class AIServiceOrchestrator:
    def __init__(self):
        self.embedding_service = EmbeddingMicroservice()
        self.retrieval_service = RetrievalMicroservice()
        self.generation_service = GenerationMicroservice()
        self.personalization_service = PersonalizationMicroservice()
    
    async def process_query(self, query: str, user_id: str) -> str:
        # Orchestrate multiple AI services
        embedding = await self.embedding_service.embed(query)
        context = await self.retrieval_service.retrieve(embedding, user_id)
        personalization = await self.personalization_service.get_user_profile(user_id)
        response = await self.generation_service.generate(query, context, personalization)
        
        return response
```