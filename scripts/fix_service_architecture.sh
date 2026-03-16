#!/bin/bash

echo "🔧 Fixing service architecture..."

APP_DIR="backend/app"
SERVICES_DIR="$APP_DIR/services"
MAPPERS_DIR="$SERVICES_DIR/mappers"

mkdir -p $MAPPERS_DIR

touch $MAPPERS_DIR/**init**.py

echo "📦 Creating mapper files..."

# ---------------------------

# NOTE MAPPER

# ---------------------------

cat > $MAPPERS_DIR/note_mapper.py << 'EOF'
from app.models.note import Note

def note_to_dto(note: Note):

```
return {
    "id": note.id,
    "title": getattr(note, "title", None),
    "content": getattr(note, "content", None),
    "owner_id": getattr(note, "owner_id", None),
    "created_at": getattr(note, "created_at", None)
}
```

EOF

# ---------------------------

# NOTE_PROBLEM MAPPER

# ---------------------------

cat > $MAPPERS_DIR/note_problem_mapper.py << 'EOF'
from app.models.note_problem import NoteProblem

def note_problem_to_dto(link: NoteProblem):

```
return {
    "note_id": getattr(link, "note_id", None),
    "problem_id": getattr(link, "problem_id", None)
}
```

EOF

# ---------------------------

# CODING ATTEMPT MAPPER

# ---------------------------

cat > $MAPPERS_DIR/coding_attempt_mapper.py << 'EOF'

def coding_attempt_to_dto(attempt):

```
return {
    "id": getattr(attempt, "id", None),
    "problem_id": getattr(attempt, "problem_id", None),
    "user_id": getattr(attempt, "user_id", None),
    "code": getattr(attempt, "code", None),
    "language": getattr(attempt, "language", None),
    "created_at": getattr(attempt, "created_at", None)
}
```

EOF

# ---------------------------

# AI RESULT MAPPER

# ---------------------------

cat > $MAPPERS_DIR/ai_result_mapper.py << 'EOF'

def ai_result_to_dto(result):

```
return {
    "id": getattr(result, "id", None),
    "query": getattr(result, "query", None),
    "response": getattr(result, "response", None),
    "created_at": getattr(result, "created_at", None)
}
```

EOF

echo "📦 Moving existing problem_mapper..."

if [ -f "$SERVICES_DIR/problem_mapper.py" ]; then
mv "$SERVICES_DIR/problem_mapper.py" "$MAPPERS_DIR/problem_mapper.py"
fi

echo "🔄 Updating imports..."

grep -rl "from app.services.problem_mapper" $APP_DIR | xargs sed -i '' 's/from app.services.problem_mapper/from app.services.mappers.problem_mapper/g'

echo "✅ Architecture fixed!"
echo ""
echo "New structure:"
echo ""
echo "services/"
echo "   auth_service.py"
echo "   note_service.py"
echo "   problem_service.py"
echo "   mappers/"
echo "        problem_mapper.py"
echo "        note_mapper.py"
echo "        note_problem_mapper.py"
echo "        coding_attempt_mapper.py"
echo "        ai_result_mapper.py"
