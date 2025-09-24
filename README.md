# Company Documentation System

## Overview
Centralized documentation repository for all company development standards, project documentation, and technical knowledge.

## Structure

### `/standards`
Global development standards and patterns that apply across all projects:
- **coding/** - Language-specific coding standards
- **architecture/** - System design patterns and principles
- **security/** - Security guidelines and best practices
- **templates/** - Reusable documentation templates

### `/projects`
Project-specific documentation. Each project has its own folder containing:
- Architecture documentation
- API specifications
- Development guides
- Deployment procedures

### `/knowledge-base`
Shared technical knowledge and solutions:
- **best-practices/** - Proven approaches and methodologies
- **troubleshooting/** - Common issues and solutions
- **how-to/** - Step-by-step guides for common tasks

### `/tools`
Documentation automation and management:
- **agents/** - Claude Code agent configurations
- **scripts/** - Automation and utility scripts

## Quick Start

### Document a New Project
```bash
# Initialize project documentation
./tools/scripts/init-project.sh PROJECT_NAME

# Or use Claude Code agent
# Run: doc-master init-project PROJECT_NAME
```

### Update Existing Documentation
```bash
# Scan and update project docs
./tools/scripts/update-docs.sh PROJECT_NAME

# Or use Claude Code agent
# Run: doc-master update PROJECT_NAME
```

### Discover Documentation
```bash
# Scan repositories for documentation
./tools/scripts/discover-docs.sh

# Or use Claude Code agent
# Run: doc-master discover
```

## Documentation Standards

All documentation must follow our [Documentation Style Guide](standards/templates/STYLE_GUIDE.md) and include:
- Clear purpose and scope
- Prerequisites and dependencies
- Step-by-step instructions where applicable
- Examples and code snippets
- Troubleshooting section
- Last updated date

## Claude Code Agents

Our documentation system uses specialized Claude Code agents:

- **doc-master** - Main orchestrator for all documentation tasks
- **doc-repo-manager** - Handles repository operations and version control
- **doc-sync-specialist** - Discovers and extracts documentation from codebases
- **technical-writer** - Creates and updates documentation content
- **docs-standards-enforcer** - Validates documentation quality and compliance

## Contributing

1. Follow the documentation templates in `/standards/templates`
2. Ensure all documentation passes validation checks
3. Update the project index when adding new projects
4. Keep documentation in sync with code changes

## Validation

All documentation changes are validated through GitHub Actions:
- Markdown linting
- Link checking
- Template compliance
- Completeness verification

See [.github/workflows/validate-docs.yml](.github/workflows/validate-docs.yml) for details.