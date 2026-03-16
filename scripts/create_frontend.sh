#!/bin/bash

echo "Creating Next.js frontend..."

npx create-next-app@latest frontend \
--typescript \
--tailwind \
--eslint \
--app \
--src-dir=false \
--import-alias="@/*" \
--no-turbo

cd frontend

echo "Creating folders..."

mkdir components
mkdir services
mkdir types
mkdir utils
mkdir styles

mkdir app/problems
mkdir app/notes
mkdir app/ai

echo "Creating files..."

touch components/Navbar.tsx
touch components/ProblemCard.tsx
touch components/ChatBox.tsx

touch services/api.ts
touch services/problemService.ts
touch services/aiService.ts

touch types/problem.ts
touch utils/errorHandler.ts

touch app/problems/page.tsx
touch app/notes/page.tsx
touch app/ai/page.tsx

echo "Frontend skeleton created successfully!"
