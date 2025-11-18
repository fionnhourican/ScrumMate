# Contributing to ScrumMate

## Development Workflow

1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Run tests: `mvn test` (backend) and `npm test` (frontend)
5. Commit your changes: `git commit -m "feat: add your feature"`
6. Push to your fork: `git push origin feature/your-feature-name`
7. Create a Pull Request

## Commit Message Convention

We follow the Conventional Commits specification:

- `feat:` new feature
- `fix:` bug fix
- `docs:` documentation changes
- `style:` formatting changes
- `refactor:` code refactoring
- `test:` adding tests
- `chore:` maintenance tasks

## Code Standards

### Backend (Java/Spring Boot)
- Follow Google Java Style Guide
- Use meaningful variable and method names
- Add JavaDoc for public methods
- Maintain test coverage above 80%

### Frontend (React/TypeScript)
- Follow Airbnb JavaScript Style Guide
- Use TypeScript strict mode
- Add JSDoc for complex functions
- Maintain test coverage above 80%

## Pull Request Guidelines

- Fill out the PR template completely
- Ensure all tests pass
- Update documentation if needed
- Link related issues
- Request review from maintainers
