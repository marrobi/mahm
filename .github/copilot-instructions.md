# GitHub Copilot Instructions for MAHM (Multi-Agentic Hypertension Management)

## Project Context

This repository contains a multi-agent AI system for NHS App hypertension management demonstration. The system uses **dummy data only** for demo purposes and showcases intelligent health monitoring and patient support capabilities within the NHS ecosystem.

## Key Project Information

- **Project Name**: Multi-Agentic Hypertension Management (MAHM)
- **Purpose**: NHS App hypertension management demo with multi-agent AI system
- **Data**: Uses dummy/synthetic data only - NOT for real patient care
- **Domain**: Healthcare technology, NHS digital services, hypertension management

## Technology Stack

### Frontend
- **Framework**: React (latest stable version)
- **Design Systems**: 
  - NHS Design System (https://service-manual.nhs.uk/design-system)
  - NHS App Design System (https://design-system.nhsapp.service.nhs.uk/) where applicable
- **Styling**: Follow NHS brand guidelines and accessibility standards
- **State Management**: Context API or Redux as appropriate
- **Testing**: Jest + React Testing Library
- **Accessibility**: WCAG 2.1 AA compliance required

### Backend
- **Framework**: Python with FastAPI
- **API Style**: RESTful APIs with OpenAPI/Swagger documentation
- **Async**: Use async/await patterns throughout
- **Data Validation**: Pydantic models for all data structures
- **Authentication**: NHS Identity integration (mocked in demo)
- **Testing**: pytest with asyncio support

### Database
- **Primary**: Azure Cosmos DB (document database)
- **Local Development**: Cosmos DB Emulator
- **Data Models**: Document-based schemas optimized for agent interactions
- **Demo Data**: All data must be clearly marked as dummy/synthetic

### Infrastructure
- **Message Queue**: Azure Service Bus (Redis for local dev)
- **Monitoring**: Application Insights
- **Deployment**: Azure-based (containerized)

## Coding Guidelines

### General Principles
- **Testing Required**: All code must include comprehensive tests (80%+ coverage)
- **Type Safety**: Use TypeScript for React, type hints for Python
- **Error Handling**: Implement proper error handling and logging
- **Documentation**: Document all public APIs and agent interfaces
- **Security**: Follow NHS Digital security guidelines

### Python/FastAPI Specific
- Use Pydantic models for request/response validation
- Implement proper async patterns with FastAPI
- Follow PEP 8 style guidelines (use Black formatter)
- Use dependency injection for database and service connections
- Include comprehensive docstrings for all functions and classes
- Handle NHS-specific data formats and validations

### React/Frontend Specific
- Use NHS Design System components whenever possible
- Implement responsive design with mobile-first approach
- Follow NHS accessibility guidelines
- Use semantic HTML and ARIA labels appropriately
- Implement proper error boundaries and loading states
- Ensure all health data displays are clear and user-friendly

### Multi-Agent System Patterns
- **Agent Communication**: Use event-driven patterns for agent interactions
- **Data Flow**: Implement clear data flow between agents
- **Error Recovery**: Handle agent failures gracefully
- **Monitoring**: Log all agent decisions and interactions
- **Scalability**: Design agents to be independently scalable

## Agent Architecture

The system includes these specialized agents:
1. **Patient Monitoring Agent** - Tracks vitals and symptoms
2. **Educational Agent** - Provides personalized health guidance
3. **Care Coordination Agent** - Manages healthcare team communication
4. **Risk Assessment Agent** - Evaluates clinical risks
5. **Data Integration Agent** - Handles data aggregation and validation

When working with agents:
- Maintain clear separation of concerns between agents
- Use consistent messaging patterns for inter-agent communication
- Implement proper error handling for agent failures
- Ensure all agent decisions are auditable and traceable

## Demo Data Requirements

- **Patient Data**: Use anonymized NHS numbers and realistic health data
- **Readings**: Generate medically plausible blood pressure ranges
- **Medications**: Include common hypertension medications
- **Interactions**: Simulate realistic patient-provider interactions
- **Privacy**: Ensure no real patient data is ever used

## NHS-Specific Considerations

- Follow NHS Digital coding standards and guidelines
- Implement NHS branding and design patterns consistently
- Consider NHS interoperability standards (HL7 FHIR for future)
- Ensure compliance with NHS data protection requirements
- Use NHS-appropriate language and terminology

## Testing Strategy

- **Unit Tests**: Test individual agent logic and API endpoints
- **Integration Tests**: Test agent-to-agent communication
- **End-to-End Tests**: Test complete user journeys
- **Accessibility Tests**: Ensure WCAG compliance
- **Performance Tests**: Verify system responsiveness
- **Security Tests**: Validate data protection measures

## Common Patterns to Follow

### API Development
- Use consistent error response formats
- Implement proper HTTP status codes
- Include comprehensive API documentation
- Version APIs appropriately for future changes

### UI Development
- Use NHS Design System components as primary building blocks
- Implement consistent navigation patterns
- Ensure all health information is clearly presented
- Follow NHS content style guide for health information

### Data Handling
- Validate all inputs using Pydantic models
- Implement proper data sanitization
- Use consistent date/time formats throughout
- Ensure all health data meets clinical standards

## Security Considerations

- Never commit real patient data or credentials
- Use environment variables for all configuration
- Implement proper authentication and authorization
- Encrypt sensitive data in transit and at rest
- Follow OWASP security guidelines
- Regular dependency updates and security scanning

## Development Workflow

- All features must include tests before merging
- Follow conventional commit message format
- Use feature branches and pull requests
- Ensure documentation is updated with code changes
- Run linting and formatting tools before committing

Remember: This is a demonstration system using dummy data only. All development should clearly maintain this distinction and prepare for future integration with real NHS systems through proper compliance and certification processes.