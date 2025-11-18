# Repository Setup Guide

## Branch Protection Rules

Configure the following branch protection rules for the `main` branch:

1. **Require pull request reviews before merging**
   - Required approving reviews: 1
   - Dismiss stale reviews when new commits are pushed

2. **Require status checks to pass before merging**
   - Require branches to be up to date before merging
   - Status checks: CI/CD pipeline, tests

3. **Restrict pushes that create files**
   - Include administrators in restrictions

## Repository Labels

Create the following labels for issue and PR management:

### Type Labels
- `bug` (red) - Something isn't working
- `enhancement` (blue) - New feature or request
- `documentation` (green) - Improvements or additions to documentation
- `refactor` (yellow) - Code refactoring
- `security` (purple) - Security-related issues

### Priority Labels
- `priority:high` (red) - High priority
- `priority:medium` (orange) - Medium priority
- `priority:low` (green) - Low priority

### Component Labels
- `backend` (blue) - Backend service related
- `frontend` (cyan) - Frontend service related
- `infrastructure` (gray) - Infrastructure/DevOps related
- `database` (brown) - Database related

### Status Labels
- `in-progress` (yellow) - Currently being worked on
- `blocked` (red) - Blocked by external dependency
- `ready-for-review` (green) - Ready for code review

## Milestones

Create milestones for each development phase:
- Phase 1: Foundation Setup
- Phase 2: Containerization
- Phase 3: Kubernetes Deployment
- Phase 4: Helm Package Management
- Phase 5: Helmfile Deployment Automation
