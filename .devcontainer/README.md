# MAHM Healthcare Development Container

This devcontainer provides a complete development environment for the MAHM (Multi-Agentic Hypertension Management) healthcare application, configured specifically for NHS digital standards and requirements.

## Features

### Base Environment
- **Base Image**: `mcr.microsoft.com/devcontainers/javascript-node:18`
- **Node.js**: Version 18+ with npm/yarn
- **Python**: Version 3.11+ with pip
- **Operating System**: Ubuntu Linux

### Development Tools

#### Azure Development
- Azure CLI
- Azure Resource Manager tools
- Cosmos DB extensions
- Azure Functions support
- Docker integration

#### Python/Backend Development
- FastAPI framework
- Pydantic for data validation
- pytest for testing
- Black code formatter
- flake8 linter
- mypy type checker
- isort import organizer

#### JavaScript/TypeScript/Frontend Development
- React with TypeScript support
- ESLint for code linting
- Prettier for code formatting
- Jest testing framework
- Playwright for end-to-end testing
- NHS Design System support

#### GitHub Integration
- GitHub CLI
- GitHub Actions support
- GitHub Copilot
- Pull Request and Issues integration

#### Healthcare/Accessibility
- WCAG compliance tools
- Web accessibility linting
- NHS-specific spell checking dictionary

### Pre-configured Ports

The following ports are automatically forwarded:

- **3000**: React development server
- **8000**: FastAPI backend API
- **8080**: Alternative web server
- **6379**: Redis
- **8081**: Cosmos DB Emulator Data Explorer
- **10250-10255**: Cosmos DB Emulator ports

### Environment Setup

The container automatically creates:

1. **Project Structure**:
   ```
   ├── frontend/          # React application
   ├── backend/           # FastAPI application
   ├── tests/             # Test files
   ├── docs/              # Documentation
   ├── scripts/           # Utility scripts
   └── .env.examples/     # Environment templates
   ```

2. **Configuration Files**:
   - `.env.example` - Environment variables template
   - `.vscode/settings.json` - VS Code workspace settings
   - `.vscode/launch.json` - Debug configurations
   - `.vscode/tasks.json` - Build and test tasks

### Getting Started

1. **Open in VS Code**: 
   - Install the Remote-Containers extension
   - Open the repository in VS Code
   - Click "Reopen in Container" when prompted

2. **Set up Environment**:
   ```bash
   cp .env.example .env
   # Edit .env with your configuration
   ```

3. **Create Applications**:
   ```bash
   # Create React frontend
   cd frontend
   npx create-react-app . --template typescript
   
   # Create FastAPI backend
   cd ../backend
   # Set up your FastAPI application
   ```

4. **Start Development**:
   - Use VS Code tasks (Ctrl+Shift+P → "Tasks: Run Task")
   - Or use the debug configurations (F5)

### Available VS Code Tasks

- **Start Backend**: Launch FastAPI development server
- **Start Frontend**: Launch React development server
- **Run Python Tests**: Execute pytest test suite
- **Format Python Code**: Run Black formatter
- **Lint Python Code**: Run flake8 linter

### Debug Configurations

- **FastAPI Backend**: Debug the Python API server
- **React Frontend**: Debug the React application
- **Python Tests**: Debug test execution

### NHS Compliance Features

- Pre-configured spell checker with NHS terminology
- WCAG accessibility linting
- NHS Digital coding standards enforcement
- Security-focused development tools
- Data protection compliance tools

### Security Considerations

- No real patient data should be used
- Environment variables for all configuration
- Docker-in-Docker for isolated service testing
- Pre-commit hooks for security scanning (when configured)

### Troubleshooting

#### Container Build Issues
If the container fails to build:
1. Check Docker is running
2. Ensure you have sufficient disk space
3. Try rebuilding: Ctrl+Shift+P → "Remote-Containers: Rebuild Container"

#### Port Conflicts
If ports are already in use:
1. Check `devcontainer.json` `forwardPorts` configuration
2. Modify ports as needed for your environment
3. Rebuild the container

#### Python/Node.js Issues
The post-create script installs common packages. For project-specific dependencies:
```bash
# Python
pip install -r requirements.txt

# Node.js
npm install
```

### Contributing

When developing in this container:

1. Follow NHS Digital coding standards
2. Use dummy data only
3. Maintain 80%+ test coverage
4. Run linting tools before committing
5. Follow conventional commit message format

### Support

For issues with the devcontainer configuration, please check:
- VS Code Remote-Containers documentation
- Azure development tools documentation
- NHS Digital development guidelines

---

**Note**: This development environment is configured for demonstration purposes using dummy data only, following NHS Digital standards for future healthcare system integration.