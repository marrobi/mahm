# Development Instructions for Coding Agents

This file provides instructions for GitHub Copilot and other coding agents working on the MAHM (Multi-Agentic Hypertension Management) repository.

## Project Context

This is a healthcare technology demonstration project for NHS App integration. The codebase uses **dummy data only** for demonstration purposes and follows NHS Digital development standards.

## Technology Stack and Development Practices

### Frontend Development
- **Framework**: React with TypeScript
- **Design System**: NHS Design System components must be used
- **Testing**: Jest + React Testing Library (minimum 80% coverage required)
- **Accessibility**: All components must meet WCAG 2.1 AA standards
- **Code Style**: Use Prettier and ESLint with NHS-specific configurations

### Backend Development
- **Framework**: Python with FastAPI
- **Type Safety**: All functions must include proper type hints
- **Validation**: Use Pydantic models for all data structures
- **Testing**: pytest with asyncio support (minimum 80% coverage required)
- **Code Style**: Black formatting, isort for imports, flake8 for linting

### Database and Infrastructure
- **Database**: Azure Cosmos DB (use emulator for local development)
- **Message Queue**: Azure Service Bus (Redis acceptable for local development)
- **Documentation**: All APIs must have OpenAPI/Swagger documentation

## Code Quality Requirements

### Security Practices
- Never commit real patient data or credentials
- Use environment variables for all configuration
- Implement proper input validation and sanitization
- Follow OWASP security guidelines
- Regular dependency scanning and updates

### Testing Standards
- All new code requires comprehensive tests
- Unit tests for individual functions and components
- Integration tests for API endpoints and data flows
- End-to-end tests for critical user workflows
- Accessibility tests for UI components

### Documentation Standards
- All public APIs must be documented
- Include docstrings for all Python functions and classes
- Document React component props and usage
- Update README files when adding new features
- Include setup and deployment instructions

## Development Workflow

### Code Reviews
- All changes require pull request review
- Tests must pass before merging
- Code coverage must not decrease
- Security scans must pass
- Accessibility checks must pass

### Commit Standards
- Use conventional commit message format
- Include issue numbers in commit messages
- Keep commits focused and atomic
- Squash related commits before merging

### NHS-Specific Requirements
- Follow NHS Digital coding standards
- Use NHS-approved language and terminology
- Implement NHS branding guidelines consistently
- Consider future NHS Spine integration requirements
- Ensure compliance with NHS data protection standards

## Local Development Setup

1. Install Node.js 18+ and Python 3.11+
2. Set up virtual environment for Python dependencies
3. Install frontend dependencies: `npm install`
4. Install backend dependencies: `pip install -r requirements.txt`
5. Start Cosmos DB Emulator for local development
6. Configure environment variables from `.env.example`
7. Run linting and formatting tools before committing

## Common Patterns

### Error Handling
- Implement consistent error response formats
- Use appropriate HTTP status codes
- Log errors with sufficient context for debugging
- Provide user-friendly error messages

### Data Handling
- Validate all inputs at API boundaries
- Use consistent date/time formats (ISO 8601)
- Implement proper data sanitization
- Ensure dummy data is clearly marked as such

### Performance Considerations
- Implement async patterns for I/O operations
- Use appropriate caching strategies
- Optimize database queries
- Monitor application performance metrics

## When Contributing Code

1. Ensure all tests pass locally
2. Run linting and formatting tools
3. Update documentation if needed
4. Test with dummy data only
5. Consider NHS compliance requirements
6. Follow established patterns and conventions