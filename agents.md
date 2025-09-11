# MAHM (Multi-Agentic Hypertension Management) - Development Instructions for Coding Agents

**ALWAYS follow these instructions first and only fallback to additional search and context gathering if the information here is incomplete or found to be in error.**

This file provides comprehensive instructions for GitHub Copilot and other coding agents working on the MAHM (Multi-Agentic Hypertension Management) repository.

## Project Overview

MAHM is a demonstration NHS App prototype for Multi-Agentic AI Hypertension Management. This is a healthcare technology demonstration project for NHS App integration that uses **dummy data only** for demonstration purposes and follows NHS Digital development standards. MVP scope and requirements are described in `MVP_DEMO_DOCUMENT.md` in the root of the repository. This must be read before making any changes, if given user comments we deviate from what is in this document ensure it is updated as part of the same pull request.

### Key Project Details
- **Purpose**: Demonstrate AI-supported hypertension care integration within NHS App
- **Data**: ALL data is simulated for demonstration only - NOT for clinical use

## Technology Stack and Development Practices: NHS Prototype Kit
- **Framework**: Node.js with Express.js web framework
- **Templating**: Nunjucks template engine (.html files)
- **Build System**: Gulp for asset compilation (SASS → CSS, JavaScript, asset copying)
- **Design System**: NHS App frontend components and NHS Design System
- **Testing**: Jest testing framework with coverage reporting (currently 76% overall, 3 test suites, 9 tests)
- **Code Quality**: ESLint with Airbnb configuration
- **Accessibility**: WCAG 2.1 AA compliance required for all components

### Installation (First Time)
- **Command**: `npm install`
- **Time**: 80 seconds
- **NEVER CANCEL**: Set timeout to 120+ seconds minimum
- **Notes**: Downloads dependencies and runs postinstall build automatically

### Build Process
- **Command**: `npm run build` or `gulp build`
- **Time**: 5 seconds
- **NEVER CANCEL**: Set timeout to 30+ seconds minimum
- **Process**: 
  1. Clean public directory (20ms)
  2. Compile SASS to CSS (2.7s)
  3. Compile JavaScript with Babel (1.2s)
  4. Copy assets (50ms)

### Test Suite
- **Command**: `npm test` or `npm run test:ci`
- **Time**: 2 seconds
- **NEVER CANCEL**: Set timeout to 30+ seconds minimum
- **Coverage**: Currently 76% overall, 3 test suites, 9 tests

### Linting
- **Command**: `npm run lint:js`
- **Time**: 1 second
- **Configuration**: ESLint with Airbnb configuration in `linters/.eslintrc.js`

### Prototype Kit Structure

```
prototype/v1/
├── app/                    # Main application code
│   ├── assets/            # SASS, JavaScript, images
│   ├── views/             # Nunjucks templates (.html)
│   ├── config.js          # App configuration
│   ├── routes.js          # Custom routes
│   └── filters.js         # Template filters
├── lib/                   # Library code and utilities
├── tests/                 # Jest test files
├── public/                # Built assets (generated)
├── gulpfile.js           # Build configuration
├── app.js                # Express server entry point
└── package.json          # Dependencies and scripts
```
### Starting Development
1. **ALWAYS run in prototype/v1 directory**: `cd /home/runner/work/mahm/mahm/prototype/v1`
2. **Install dependencies first**: `npm install` (80s - NEVER CANCEL)
3. **Build assets**: `npm run build` (5s)
4. **Run tests**: `npm test` (2s) 
5. **Start development**: `npm run watch` (25s to start - NEVER CANCEL)

### Watch Mode (Recommended for Development)
- **Command**: `npm run watch`
- **NEVER CANCEL**: Takes 25 seconds to fully initialize
- **Process**:
  1. Builds assets (4s)
  2. Starts nodemon (monitors JS files for changes)
  3. Starts BrowserSync proxy (takes 22s)
  4. Watches for file changes
- **URLs**: 
  - App: http://localhost:2000
  - BrowserSync: http://localhost:3000 (with live reload)

### Manual Validation Scenarios

**ALWAYS test these scenarios after making changes:**

1. **Homepage Validation**:
   - Navigate to http://localhost:2000
   - Verify NHS App prototype loads with blue NHS header
   - Check all main navigation links work

2. **MAHM Functionality Testing**:
   - Go to http://localhost:2000/pages/home-p9
   - Click "My BP - Hypertension Management"
   - Verify hypertension management dashboard loads
   - Test "Measure blood pressure" link
   - Verify BP measurement page displays Lifelight information

3. **Component Navigation**:
   - Test "Pages templates and layouts" from homepage
   - Verify multiple layout options load correctly
   - Test app layout with top/bottom navigation

4. **Template System**:
   - Verify Nunjucks templates render correctly
   - Check NHS App frontend components display properly
   - Test responsive design on different viewport sizes

### Screenshots
- All pull requests that create or update user interface functionality need to create new screenshots and ensure they are linked in `screenshots.md`
- When comments are made on `screenshots.md` please update the UI itself, and replace/add screenshots to `screenshots.md` for further review.

### Adding New Pages
1. Create template in `app/views/pages/`
2. Add route in `app/routes.js` if needed
3. Build assets: `npm run build`
4. Test in browser: http://localhost:2000/your-new-page

### Modifying Styles
1. Edit SASS files in `app/assets/sass/`
2. Build automatically rebuilds in watch mode
3. Changes appear immediately with BrowserSync

### Updating Components
1. Templates use NHS App frontend components
2. Reference: NHS Design System and NHS App Design System
3. Test accessibility with screen readers

### Adding Tests
1. Create `.test.js` files in `tests/` directory
2. Use Jest + basic assertions
3. Run `npm test` to verify coverage

## Code Quality Requirements

### Security Practices
- **NO real patient data**: All data is simulated for demonstration
- Never commit real patient data or credentials
- Use environment variables for all configuration
- Implement proper input validation and sanitization
- Follow OWASP security guidelines
- Ensure compliance with NHS data protection standards

### Testing Standards
- All new code requires comprehensive tests
- Unit tests for individual functions and components (using Jest)
- Integration tests for template rendering and data flows
- End-to-end tests for critical user workflows
- Accessibility tests for UI components (WCAG 2.1 AA compliance)
- Minimum 75% coverage required (currently at 76%)

### Documentation Standards
- Update README files when adding new features
- Include docstrings/comments for complex template logic
- Document new routes and their purpose
- Include setup and deployment instructions
- All APIs must have clear documentation

### Code Reviews
- All changes require pull request review
- Tests must pass before merging
- Code coverage must not decrease
- Linting checks must pass
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
- **NHS compliant**: Follows NHS Digital development standards
- Consider future NHS Spine integration requirements

## Key Integration Points

### NHS App Integration
- Uses `nhsapp-frontend` components
- Styled with NHS brand guidelines
- Mobile-first responsive design

## Troubleshooting

### Build Failures
- **Symptom**: Gulp fails during SASS compilation
- **Solution**: Check SASS syntax in `app/assets/sass/`
- **Validation**: Run `npm run build` after fixes

### Test Failures
- **Symptom**: Jest tests fail
- **Solution**: Check test files in `tests/` directory
- **Validation**: Run `npm test` with verbose output

### App Won't Start
- **Symptom**: `npm start` fails
- **Solution**: Ensure build completed first: `npm run build`
- **Check**: Verify port 2000 is available

### Watch Mode Issues
- **Symptom**: BrowserSync not working
- **Solution**: Kill existing processes, restart with `npm run watch`
- **Wait time**: Allow full 25 seconds for initialization

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

## Additional Resources

- **NHS Design System**: https://service-manual.nhs.uk/design-system
- **NHS App Design System**: https://design-system.nhsapp.service.nhs.uk/
- **NHS Prototype Kit**: https://prototype-kit.service-manual.nhs.uk/
- **Project Documentation**: See MVP_DEMO_DOCUMENT.md in repository root