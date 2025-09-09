#!/bin/bash

# Post-create script for MAHM Healthcare Development Container
# This script runs after the container is created to set up the development environment

set -e

echo "🏥 Setting up MAHM Healthcare Development Environment..."

# Update system packages
echo "📦 Updating system packages..."
sudo apt-get update

# Install additional system dependencies
echo "🔧 Installing system dependencies..."
sudo apt-get install -y \
    curl \
    wget \
    git \
    vim \
    nano \
    jq \
    tree \
    htop \
    redis-tools \
    postgresql-client \
    build-essential

# Set up Python environment
echo "🐍 Setting up Python environment..."
python3 -m pip install --upgrade pip
python3 -m pip install --upgrade setuptools wheel

# Install common Python packages for healthcare/NHS development
echo "📋 Installing Python development packages..."
pip3 install \
    fastapi \
    uvicorn \
    pydantic \
    pytest \
    pytest-asyncio \
    pytest-cov \
    black \
    isort \
    flake8 \
    mypy \
    pre-commit \
    python-multipart \
    python-jose \
    passlib \
    azure-cosmos \
    azure-servicebus \
    redis \
    httpx \
    aiofiles

# Set up Node.js global packages
echo "📦 Installing Node.js global packages..."
npm install -g \
    create-react-app \
    @vitejs/create-vite \
    typescript \
    @types/node \
    eslint \
    prettier \
    jest \
    @testing-library/react \
    @testing-library/jest-dom \
    @playwright/test

# Create common project directories
echo "📁 Creating project structure..."
mkdir -p \
    frontend \
    backend \
    tests \
    docs \
    scripts \
    .env.examples

# Set up Git configuration for NHS development standards
echo "⚙️ Configuring Git for NHS development..."
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global core.autocrlf input

# Install pre-commit hooks if .pre-commit-config.yaml exists
if [ -f ".pre-commit-config.yaml" ]; then
    echo "🔧 Installing pre-commit hooks..."
    pre-commit install
fi

# Create example environment files
echo "🌍 Creating example environment files..."
cat > .env.example << EOF
# MAHM Healthcare Development Environment
# Copy this file to .env and configure with your settings

# Application Settings
NODE_ENV=development
DEBUG=true
APP_NAME=MAHM

# API Settings
API_HOST=localhost
API_PORT=8000
FRONTEND_PORT=3000

# Database Settings (Local Development)
COSMOS_DB_ENDPOINT=https://localhost:8081
COSMOS_DB_KEY=C2y6yDjf5/R+ob0N8A7Cgv30VRDJIWEHLM+4QDU5DE2nQ9nDuVTqobD4b8mGGyPMbIZnqyMsEcaGQy67XIw/Jw==
COSMOS_DB_NAME=mahm_dev

# Redis Settings
REDIS_HOST=localhost
REDIS_PORT=6379

# Azure Settings (for production/staging)
AZURE_SUBSCRIPTION_ID=your-subscription-id
AZURE_RESOURCE_GROUP=mahm-rg
AZURE_LOCATION=uksouth

# NHS Integration (dummy values for development)
NHS_API_BASE_URL=https://api.nhs.uk
NHS_API_KEY=dummy-key-for-development

# Security
JWT_SECRET=your-jwt-secret-key-here
ENCRYPTION_KEY=your-encryption-key-here

# Logging
LOG_LEVEL=info
EOF

# Create VS Code workspace settings
echo "🛠️ Creating VS Code workspace settings..."
mkdir -p .vscode
cat > .vscode/settings.json << EOF
{
  "python.defaultInterpreterPath": "/usr/local/bin/python",
  "python.terminal.activateEnvironment": false,
  "python.linting.enabled": true,
  "python.linting.flake8Enabled": true,
  "python.linting.mypyEnabled": true,
  "python.formatting.provider": "black",
  "python.sortImports.provider": "isort",
  "python.testing.pytestEnabled": true,
  "eslint.workingDirectories": ["frontend"],
  "editor.formatOnSave": true,
  "editor.codeActionsOnSave": {
    "source.organizeImports": true,
    "source.fixAll.eslint": true
  },
  "files.exclude": {
    "**/__pycache__": true,
    "**/.pytest_cache": true,
    "**/node_modules": true,
    "**/.git": false
  },
  "cSpell.words": [
    "NHS",
    "MAHM",
    "Hypertension",
    "FastAPI",
    "Pydantic",
    "Cosmos",
    "pytest",
    "WCAG",
    "OWASP",
    "uvicorn",
    "asyncio"
  ]
}
EOF

# Create launch configuration for debugging
cat > .vscode/launch.json << EOF
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "FastAPI Backend",
      "type": "python",
      "request": "launch",
      "program": "/usr/local/bin/uvicorn",
      "args": ["backend.main:app", "--reload", "--host", "0.0.0.0", "--port", "8000"],
      "console": "integratedTerminal",
      "envFile": "\${workspaceFolder}/.env"
    },
    {
      "name": "React Frontend",
      "type": "node",
      "request": "launch",
      "cwd": "\${workspaceFolder}/frontend",
      "runtimeExecutable": "npm",
      "runtimeArgs": ["start"],
      "console": "integratedTerminal"
    },
    {
      "name": "Python Tests",
      "type": "python",
      "request": "launch",
      "module": "pytest",
      "args": ["-v", "tests/"],
      "console": "integratedTerminal",
      "envFile": "\${workspaceFolder}/.env"
    }
  ]
}
EOF

# Create tasks configuration
cat > .vscode/tasks.json << EOF
{
  "version": "2.0.0",
  "tasks": [
    {
      "label": "Start Backend",
      "type": "shell",
      "command": "uvicorn",
      "args": ["backend.main:app", "--reload", "--host", "0.0.0.0", "--port", "8000"],
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      },
      "options": {
        "env": {
          "PYTHONPATH": "\${workspaceFolder}"
        }
      }
    },
    {
      "label": "Start Frontend",
      "type": "shell",
      "command": "npm",
      "args": ["start"],
      "options": {
        "cwd": "\${workspaceFolder}/frontend"
      },
      "group": "build",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      }
    },
    {
      "label": "Run Python Tests",
      "type": "shell",
      "command": "pytest",
      "args": ["-v", "tests/"],
      "group": "test",
      "presentation": {
        "echo": true,
        "reveal": "always",
        "focus": false,
        "panel": "new"
      }
    },
    {
      "label": "Format Python Code",
      "type": "shell",
      "command": "black",
      "args": [".", "--line-length", "88"],
      "group": "build"
    },
    {
      "label": "Lint Python Code",
      "type": "shell",
      "command": "flake8",
      "args": ["."],
      "group": "build"
    }
  ]
}
EOF

# Set proper permissions
chmod +x .devcontainer/post-create.sh

echo "✅ MAHM Healthcare Development Environment setup complete!"
echo ""
echo "🏥 Welcome to the MAHM (Multi-Agentic Hypertension Management) development environment!"
echo "📋 This container is configured for NHS healthcare application development."
echo ""
echo "🛠️ Available tools:"
echo "   • Node.js 18+ with npm/yarn"
echo "   • Python 3.11+ with pip"
echo "   • Azure CLI and tools"
echo "   • Docker-in-Docker support"
echo "   • GitHub CLI"
echo "   • Redis tools"
echo "   • PostgreSQL client"
echo ""
echo "📦 Pre-installed packages:"
echo "   • FastAPI, Pydantic, pytest (Python)"
echo "   • React, TypeScript, Jest (Node.js)"
echo "   • Black, flake8, mypy (Python linting/formatting)"
echo "   • ESLint, Prettier (JavaScript/TypeScript)"
echo ""
echo "🚀 Next steps:"
echo "   1. Copy .env.example to .env and configure"
echo "   2. Create your frontend and backend applications"
echo "   3. Install project-specific dependencies"
echo "   4. Start developing your NHS healthcare application!"
echo ""
echo "📚 Documentation:"
echo "   • See agents.md for coding guidelines"
echo "   • Follow NHS Digital standards"
echo "   • Use dummy data only for development"
echo ""