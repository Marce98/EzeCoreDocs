#!/bin/bash

# Initialize documentation for a new project
# Usage: ./init-project.sh PROJECT_NAME [TEMPLATE]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
DOCS_ROOT="../../projects"
TEMPLATES_DIR="../../standards/templates"
DEFAULT_TEMPLATE="standard"

# Functions
print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

print_info() {
    echo -e "${YELLOW}ℹ${NC} $1"
}

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Usage: $0 PROJECT_NAME [TEMPLATE]"
    exit 1
fi

PROJECT_NAME=$1
TEMPLATE=${2:-$DEFAULT_TEMPLATE}
PROJECT_PATH="$DOCS_ROOT/$PROJECT_NAME"

# Check if project already exists
if [ -d "$PROJECT_PATH" ]; then
    print_error "Project documentation already exists: $PROJECT_PATH"
    exit 1
fi

print_info "Initializing documentation for project: $PROJECT_NAME"
print_info "Using template: $TEMPLATE"

# Create project directory structure
mkdir -p "$PROJECT_PATH"/{architecture,api,decisions,guides,diagrams}
print_success "Created project directory structure"

# Copy template files
cp "$TEMPLATES_DIR/PROJECT_README.md" "$PROJECT_PATH/README.md"
cp "$TEMPLATES_DIR/ARCHITECTURE.md" "$PROJECT_PATH/architecture/ARCHITECTURE.md"
cp "$TEMPLATES_DIR/API.md" "$PROJECT_PATH/api/API.md"
print_success "Copied template files"

# Create additional standard files
cat > "$PROJECT_PATH/CONTRIBUTING.md" << 'EOF'
# Contributing to {Project Name}

## Getting Started

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## Code Style

Please follow our [coding standards](../standards/coding/STANDARDS.md).

## Testing

All changes must include appropriate tests.

## Documentation

Update documentation for any changed functionality.
EOF

cat > "$PROJECT_PATH/DEVELOPMENT.md" << 'EOF'
# Development Guide

## Local Setup

### Prerequisites
- List prerequisites here

### Installation
```bash
# Installation commands
```

### Configuration
Describe configuration steps

## Development Workflow

1. Create feature branch
2. Implement changes
3. Write tests
4. Update documentation
5. Submit PR

## Common Tasks

### Running Tests
```bash
# Test commands
```

### Building
```bash
# Build commands
```

## Troubleshooting

Common issues and solutions.
EOF

cat > "$PROJECT_PATH/DEPLOYMENT.md" << 'EOF'
# Deployment Guide

## Environments

### Development
- URL: http://localhost:3000
- Purpose: Local development

### Staging
- URL: https://staging.example.com
- Purpose: Pre-production testing

### Production
- URL: https://example.com
- Purpose: Live environment

## Deployment Process

### Manual Deployment
```bash
# Deployment commands
```

### CI/CD Pipeline
Describe automated deployment

## Rollback Procedures

Steps to rollback a deployment

## Monitoring

- Application logs
- Performance metrics
- Error tracking
EOF

print_success "Created additional documentation files"

# Create index entry
INDEX_FILE="$DOCS_ROOT/INDEX.md"
if [ ! -f "$INDEX_FILE" ]; then
    cat > "$INDEX_FILE" << 'EOF'
# Projects Index

## Active Projects

EOF
fi

# Add project to index
echo "- [$PROJECT_NAME](./$PROJECT_NAME/README.md) - $(date +%Y-%m-%d)" >> "$INDEX_FILE"
print_success "Added project to index"

# Create initial ADR (Architecture Decision Record)
ADR_FILE="$PROJECT_PATH/decisions/ADR-001-documentation-structure.md"
cat > "$ADR_FILE" << EOF
# ADR-001: Documentation Structure

## Status
Accepted

## Context
We need a consistent structure for project documentation.

## Decision
We will use the company standard documentation template.

## Consequences
- Consistent documentation across projects
- Easier onboarding for new team members
- Simplified documentation maintenance
EOF

print_success "Created initial ADR"

# Replace placeholders with project name
find "$PROJECT_PATH" -type f -name "*.md" -exec sed -i.bak "s/{Project Name}/$PROJECT_NAME/g" {} \;
find "$PROJECT_PATH" -type f -name "*.md" -exec sed -i.bak "s/{project-name}/${PROJECT_NAME,,}/g" {} \;
find "$PROJECT_PATH" -type f -name "*.md" -exec sed -i.bak "s/{DATE}/$(date +%Y-%m-%d)/g" {} \;
find "$PROJECT_PATH" -type f -name "*.md.bak" -delete
print_success "Replaced template placeholders"

# Generate initial documentation report
REPORT_FILE="$PROJECT_PATH/documentation-report.md"
cat > "$REPORT_FILE" << EOF
# Documentation Report for $PROJECT_NAME

Generated: $(date)

## Files Created
- README.md
- architecture/ARCHITECTURE.md
- api/API.md
- CONTRIBUTING.md
- DEVELOPMENT.md
- DEPLOYMENT.md
- decisions/ADR-001-documentation-structure.md

## Next Steps
1. Review and customize the generated documentation
2. Add project-specific details
3. Document actual architecture and API
4. Add diagrams and examples
5. Set up continuous documentation updates

## Documentation Coverage
- [ ] Project overview
- [ ] Architecture documentation
- [ ] API documentation
- [ ] Development guide
- [ ] Deployment guide
- [ ] Contributing guidelines
- [ ] Decision records
EOF

print_success "Generated documentation report"

# Create .gitignore for documentation
cat > "$PROJECT_PATH/.gitignore" << 'EOF'
# Documentation specific
*.tmp
*.bak
.DS_Store
node_modules/
.env
EOF

# Final summary
echo ""
print_success "Documentation initialized successfully!"
echo ""
echo "Project location: $PROJECT_PATH"
echo ""
echo "Next steps:"
echo "1. Review generated documentation in $PROJECT_PATH"
echo "2. Customize content for your project"
echo "3. Run validation: ./validate-docs.sh $PROJECT_NAME"
echo "4. Commit changes to repository"
echo ""
print_info "Use 'doc-master update $PROJECT_NAME' to keep documentation in sync with code"