#!/bin/bash
set -e

PROJECT_NAME="interview-prep-platform"

echo "🚀 Bootstrapping $PROJECT_NAME..."

# Root folders
mkdir -p backend frontend docs scripts

# Git
git init

# Gitignore
cat <<EOF > .gitignore
node_modules/
.env
__pycache__/
*.pyc
venv/
dist/
build/
EOF

# README
cat <<EOF > README.md
# Interview Prep Platform

Production-ready interview preparation platform with AI assistance.
EOF

echo "✅ Base project structure created"
