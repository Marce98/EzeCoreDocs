#!/bin/bash

# Update documentation for an existing project
# Usage: ./update-docs.sh PROJECT_NAME [SCOPE]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
DOCS_ROOT="../../projects"
TEMPLATES_DIR="../../standards/templates"
DEFAULT_SCOPE="all"

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

print_task() {
    echo -e "${BLUE}→${NC} $1"
}

# Check arguments
if [ $# -lt 1 ]; then
    print_error "Usage: $0 PROJECT_NAME [SCOPE]"
    echo "  SCOPE: all, api, architecture, readme, guides"
    exit 1
fi

PROJECT_NAME=$1
SCOPE=${2:-$DEFAULT_SCOPE}
PROJECT_PATH="$DOCS_ROOT/$PROJECT_NAME"
UPDATE_REPORT="$PROJECT_PATH/update-report-$(date +%Y%m%d-%H%M%S).md"

# Check if project exists
if [ ! -d "$PROJECT_PATH" ]; then
    print_error "Project documentation not found: $PROJECT_PATH"
    print_info "Run './init-project.sh $PROJECT_NAME' to initialize documentation"
    exit 1
fi

print_info "Updating documentation for project: $PROJECT_NAME"
print_info "Scope: $SCOPE"
echo ""

# Initialize update report
cat > "$UPDATE_REPORT" << EOF
# Documentation Update Report

Project: $PROJECT_NAME
Date: $(date)
Scope: $SCOPE

## Changes Detected

EOF

# Function to check if file needs update
check_outdated() {
    local file=$1
    local template=$2

    if [ ! -f "$file" ]; then
        echo "- Missing: $(basename $file)" >> "$UPDATE_REPORT"
        return 0
    fi

    # Check if file is older than 30 days
    if [ $(find "$file" -mtime +30 | wc -l) -gt 0 ]; then
        echo "- Outdated (>30 days): $(basename $file)" >> "$UPDATE_REPORT"
        return 0
    fi

    return 1
}

# Function to validate markdown
validate_markdown() {
    local file=$1
    # Simple validation - check for required sections
    if ! grep -q "^# " "$file"; then
        echo "  - Missing H1 header in $(basename $file)" >> "$UPDATE_REPORT"
    fi
    if ! grep -q "Last Updated:" "$file"; then
        echo "  - Missing 'Last Updated' in $(basename $file)" >> "$UPDATE_REPORT"
    fi
}

# Update README
if [ "$SCOPE" = "all" ] || [ "$SCOPE" = "readme" ]; then
    print_task "Checking README.md"
    if check_outdated "$PROJECT_PATH/README.md" "$TEMPLATES_DIR/PROJECT_README.md"; then
        print_info "README needs update"
        # Update last modified date
        sed -i.bak "s/> Last Updated:.*/> Last Updated: $(date +%Y-%m-%d)/" "$PROJECT_PATH/README.md"
    fi
    validate_markdown "$PROJECT_PATH/README.md"
    print_success "README checked"
fi

# Update Architecture documentation
if [ "$SCOPE" = "all" ] || [ "$SCOPE" = "architecture" ]; then
    print_task "Checking architecture documentation"
    if check_outdated "$PROJECT_PATH/architecture/ARCHITECTURE.md" "$TEMPLATES_DIR/ARCHITECTURE.md"; then
        print_info "Architecture documentation needs update"
        sed -i.bak "s/> Last Updated:.*/> Last Updated: $(date +%Y-%m-%d)/" "$PROJECT_PATH/architecture/ARCHITECTURE.md"
    fi
    validate_markdown "$PROJECT_PATH/architecture/ARCHITECTURE.md"
    print_success "Architecture documentation checked"
fi

# Update API documentation
if [ "$SCOPE" = "all" ] || [ "$SCOPE" = "api" ]; then
    print_task "Checking API documentation"
    if check_outdated "$PROJECT_PATH/api/API.md" "$TEMPLATES_DIR/API.md"; then
        print_info "API documentation needs update"
        sed -i.bak "s/> Last Updated:.*/> Last Updated: $(date +%Y-%m-%d)/" "$PROJECT_PATH/api/API.md"

        # Check for OpenAPI spec
        if [ -f "$PROJECT_PATH/api/openapi.yaml" ] || [ -f "$PROJECT_PATH/api/swagger.json" ]; then
            echo "  - Found API specification file" >> "$UPDATE_REPORT"
        else
            echo "  - No API specification file found (openapi.yaml or swagger.json)" >> "$UPDATE_REPORT"
        fi
    fi
    validate_markdown "$PROJECT_PATH/api/API.md"
    print_success "API documentation checked"
fi

# Check for missing documentation
print_task "Checking for missing documentation"
echo "" >> "$UPDATE_REPORT"
echo "## Missing Documentation" >> "$UPDATE_REPORT"

REQUIRED_DOCS=(
    "README.md"
    "architecture/ARCHITECTURE.md"
    "api/API.md"
    "CONTRIBUTING.md"
    "DEVELOPMENT.md"
    "DEPLOYMENT.md"
)

missing_count=0
for doc in "${REQUIRED_DOCS[@]}"; do
    if [ ! -f "$PROJECT_PATH/$doc" ]; then
        echo "- Missing: $doc" >> "$UPDATE_REPORT"
        print_info "Missing: $doc"
        ((missing_count++))
    fi
done

if [ $missing_count -eq 0 ]; then
    echo "None - all required documentation present" >> "$UPDATE_REPORT"
    print_success "All required documentation present"
fi

# Check for broken links
print_task "Checking for broken links"
echo "" >> "$UPDATE_REPORT"
echo "## Link Validation" >> "$UPDATE_REPORT"

broken_links=0
while IFS= read -r file; do
    # Extract markdown links
    links=$(grep -oE '\[([^]]+)\]\(([^)]+)\)' "$file" | sed 's/.*](\(.*\))/\1/' || true)

    for link in $links; do
        # Skip external links
        if [[ $link == http* ]]; then
            continue
        fi

        # Check if local file exists
        link_path="$PROJECT_PATH/$link"
        if [ ! -f "$link_path" ] && [ ! -d "$link_path" ]; then
            echo "- Broken link in $(basename $file): $link" >> "$UPDATE_REPORT"
            ((broken_links++))
        fi
    done
done < <(find "$PROJECT_PATH" -name "*.md" -type f)

if [ $broken_links -eq 0 ]; then
    echo "All links valid" >> "$UPDATE_REPORT"
    print_success "All links valid"
else
    print_info "Found $broken_links broken link(s)"
fi

# Generate TODOs
print_task "Generating action items"
echo "" >> "$UPDATE_REPORT"
echo "## Action Items" >> "$UPDATE_REPORT"

# Analyze and generate TODOs
if [ $missing_count -gt 0 ]; then
    echo "- [ ] Create missing documentation files" >> "$UPDATE_REPORT"
fi

if [ $broken_links -gt 0 ]; then
    echo "- [ ] Fix broken links" >> "$UPDATE_REPORT"
fi

if grep -q "Outdated" "$UPDATE_REPORT"; then
    echo "- [ ] Update outdated documentation" >> "$UPDATE_REPORT"
fi

echo "- [ ] Review and update project-specific content" >> "$UPDATE_REPORT"
echo "- [ ] Add examples and code snippets where missing" >> "$UPDATE_REPORT"
echo "- [ ] Verify all information is current" >> "$UPDATE_REPORT"

# Generate update script
UPDATE_SCRIPT="$PROJECT_PATH/apply-updates.sh"
cat > "$UPDATE_SCRIPT" << 'SCRIPT_EOF'
#!/bin/bash

# Auto-generated update script
# Review before running!

set -e

echo "Applying documentation updates..."

# Update Last Modified dates
find . -name "*.md" -exec sed -i.bak "s/> Last Updated:.*/> Last Updated: $(date +%Y-%m-%d)/" {} \;

# Clean up backup files
find . -name "*.bak" -delete

echo "Updates applied. Please review changes before committing."
SCRIPT_EOF

chmod +x "$UPDATE_SCRIPT"

# Summary
echo "" >> "$UPDATE_REPORT"
echo "## Summary" >> "$UPDATE_REPORT"
echo "" >> "$UPDATE_REPORT"
echo "- Documentation files checked: $(find $PROJECT_PATH -name "*.md" | wc -l)" >> "$UPDATE_REPORT"
echo "- Missing files: $missing_count" >> "$UPDATE_REPORT"
echo "- Broken links: $broken_links" >> "$UPDATE_REPORT"
echo "- Update script generated: apply-updates.sh" >> "$UPDATE_REPORT"

# Clean up backup files
find "$PROJECT_PATH" -name "*.bak" -delete 2>/dev/null || true

# Final output
echo ""
print_success "Documentation update check completed!"
echo ""
echo "Update report: $UPDATE_REPORT"
echo "Apply updates: $UPDATE_SCRIPT"
echo ""
print_info "Review the report and run the update script if needed"
print_info "Use 'doc-master validate $PROJECT_NAME' to validate documentation"