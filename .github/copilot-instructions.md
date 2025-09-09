# GitHub Copilot Instructions for MAHM Repository

## Project Overview

This repository contains a healthcare technology demonstration for NHS App integration. All development uses **dummy data only** and follows NHS Digital standards for healthcare applications.

## Development Practices

### Code Quality Standards
- **Testing**: Minimum 80% code coverage required for all new code
- **Type Safety**: Use TypeScript for React, type hints for Python
- **Security**: Follow NHS Digital security guidelines and OWASP standards
- **Accessibility**: All UI components must meet WCAG 2.1 AA compliance
- **Documentation**: Document all public APIs and interfaces

### Technology Stack

#### Frontend
- **Framework**: React with TypeScript
- **Design System**: NHS Design System components (https://service-manual.nhs.uk/design-system)
- **Testing**: Jest + React Testing Library
- **Build Tools**: Create React App or Vite
- **State Management**: Context API or Redux as appropriate

#### Backend
- **Framework**: Python with FastAPI
- **Data Validation**: Pydantic models for all request/response objects
- **Testing**: pytest with asyncio support
- **Documentation**: OpenAPI/Swagger automatic generation
- **Code Style**: Black, isort, flake8, mypy

#### Infrastructure
- **Database**: Azure Cosmos DB (local emulator for development)
- **Message Queue**: Azure Service Bus (Redis for local development)
- **Deployment**: Azure-based containerized deployment
- **Monitoring**: Application Insights integration

### Security Requirements

- Never commit credentials, API keys, or real patient data
- Use environment variables for all configuration
- Implement proper authentication and authorization
- Encrypt sensitive data in transit and at rest
- Regular dependency scanning and security updates
- Follow NHS data protection standards

### Testing Strategy

- **Unit Tests**: Test individual functions and components
- **Integration Tests**: Test API endpoints and service interactions
- **End-to-End Tests**: Test complete user workflows
- **Accessibility Tests**: Automated WCAG compliance checking
- **Performance Tests**: Monitor response times and resource usage

### NHS-Specific Guidelines

- Use NHS-approved terminology and language
- Follow NHS Digital coding standards
- Implement NHS branding guidelines consistently
- Consider future NHS Spine integration requirements
- Ensure all health information is presented clearly and accurately
- Use appropriate clinical validation for health-related features

### Code Review Process

- All changes require pull request review
- Automated testing must pass before merge
- Security scans must complete successfully
- Code coverage cannot decrease below current levels
- Documentation must be updated for new features

### Development Workflow

1. **Feature Development**: Use feature branches for all changes
2. **Commit Standards**: Follow conventional commit message format
3. **Testing**: Write tests before implementing features
4. **Documentation**: Update relevant documentation with code changes
5. **Review**: Submit pull requests for all changes

### Local Development Setup

1. Install required tools: Node.js 18+, Python 3.11+, Docker
2. Clone repository and install dependencies
3. Configure environment variables from `.env.example`
4. Start local services (Cosmos DB Emulator, Redis)
5. Run tests to verify setup
6. Start development servers

### Common Patterns

#### Error Handling
- Use consistent error response formats across APIs
- Implement proper HTTP status codes
- Provide meaningful error messages for users
- Log errors with sufficient context for debugging

#### Data Management
- Validate all inputs using Pydantic models
- Use consistent date/time formats (ISO 8601)
- Implement proper data sanitization
- Clearly mark all data as dummy/demonstration data

#### API Development
- Follow RESTful API design principles
- Use appropriate HTTP methods and status codes
- Implement proper request/response validation
- Generate comprehensive API documentation
- Version APIs appropriately for future changes

#### UI Development
- Use NHS Design System components as building blocks
- Implement responsive, mobile-first design
- Follow NHS accessibility guidelines
- Use semantic HTML and appropriate ARIA labels
- Implement proper loading states and error boundaries

### Performance Guidelines

- Use async/await patterns for I/O operations
- Implement appropriate caching strategies
- Optimize database queries and data access
- Monitor and optimize bundle sizes for frontend
- Use lazy loading for large components or data sets

### Documentation Requirements

- All public functions and classes must have docstrings
- React components must document props and usage
- API endpoints must have complete OpenAPI specifications
- README files must be kept up to date
- Include setup and deployment instructions

Remember: This is a demonstration system using dummy data only. All development should maintain this distinction while preparing for future integration with real NHS systems through proper compliance and certification processes.