# ScrumMate GitOps Setup

## Quick Start

1. Install Flux CLI:
```bash
./scripts/install-flux-cli.sh
```

2. Bootstrap Flux:
```bash
export GITHUB_USER=your-username
export GITHUB_TOKEN=your-token
./scripts/bootstrap-flux.sh
```

## Structure

- `gitops/infrastructure/` - Base infrastructure configs
- `gitops/apps/scrummate/` - Application configs  
- `gitops/environments/` - Environment overlays (dev/staging/prod)

## Features

- ✅ Automated image updates
- ✅ Multi-tenant RBAC
- ✅ Environment isolation
- ✅ Dependency ordering
- ✅ Health monitoring
