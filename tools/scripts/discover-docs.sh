#!/bin/bash

# Discover documentation across repositories
# Usage: ./discover-docs.sh [PATH]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCAN_PATH=${1:-.}
DISCOVERY_REPORT="discovery-report-$(date +%Y%m%d-%H%M%S).md"
TEMP_DIR=$(mktemp -d)

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

print_found() {
    echo -e "${CYAN}  ◦${NC} $1"
}

# Initialize report
cat > "$DISCOVERY_REPORT" << EOF
# Documentation Discovery Report

Scan Date: $(date)
Scan Path: $SCAN_PATH

## Summary

EOF

print_info "Starting documentation discovery scan"
print_info "Scanning path: $SCAN_PATH"
echo ""

# Statistics
total_files=0
total_docs=0
total_inline=0
total_api=0
total_tests=0

# Function to analyze file
analyze_file() {
    local file=$1
    local type=$2

    case $type in
        "markdown")
            # Check for documentation completeness
            if grep -q "^# " "$file" && grep -q "## " "$file"; then
                echo "  - Well-structured: $(basename $file)" >> "$TEMP_DIR/structured.txt"
            else
                echo "  - Needs structure: $(basename $file)" >> "$TEMP_DIR/needs_structure.txt"
            fi
            ;;
        "code")
            # Count documentation comments
            local comment_lines=0
            local total_lines=$(wc -l < "$file")

            case "${file##*.}" in
                js|ts|jsx|tsx)
                    comment_lines=$(grep -E '^\s*(//|/\*|\*)' "$file" 2>/dev/null | wc -l || echo 0)
                    # Check for JSDoc
                    if grep -q '/\*\*' "$file"; then
                        echo "  - Has JSDoc: $(basename $file)" >> "$TEMP_DIR/has_jsdoc.txt"
                    fi
                    ;;
                py)
                    comment_lines=$(grep -E '^\s*(#|"""|\'\'\'')' "$file" 2>/dev/null | wc -l || echo 0)
                    # Check for docstrings
                    if grep -q '"""' "$file"; then
                        echo "  - Has docstrings: $(basename $file)" >> "$TEMP_DIR/has_docstrings.txt"
                    fi
                    ;;
                java)
                    comment_lines=$(grep -E '^\s*(//|/\*|\*)' "$file" 2>/dev/null | wc -l || echo 0)
                    # Check for Javadoc
                    if grep -q '/\*\*' "$file"; then
                        echo "  - Has Javadoc: $(basename $file)" >> "$TEMP_DIR/has_javadoc.txt"
                    fi
                    ;;
            esac

            if [ $total_lines -gt 0 ]; then
                local doc_percentage=$((comment_lines * 100 / total_lines))
                echo "$file:$doc_percentage" >> "$TEMP_DIR/doc_percentages.txt"
            fi
            ;;
    esac
}

# Scan for README files
print_task "Scanning for README files"
while IFS= read -r file; do
    print_found "$(realpath --relative-to="$SCAN_PATH" "$file")"
    ((total_docs++))
    analyze_file "$file" "markdown"
done < <(find "$SCAN_PATH" -type f \( -iname "readme*" -o -iname "*.readme" \) 2>/dev/null)
print_success "Found $total_docs README files"
echo ""

# Scan for Markdown documentation
print_task "Scanning for Markdown documentation"
md_count=0
while IFS= read -r file; do
    if [[ ! $(basename "$file") =~ ^[Rr][Ee][Aa][Dd][Mm][Ee] ]]; then
        print_found "$(realpath --relative-to="$SCAN_PATH" "$file")"
        ((md_count++))
        ((total_docs++))
        analyze_file "$file" "markdown"
    fi
done < <(find "$SCAN_PATH" -type f -name "*.md" 2>/dev/null)
print_success "Found $md_count additional Markdown files"
echo ""

# Scan for API documentation
print_task "Scanning for API specifications"
api_files=()

# OpenAPI/Swagger
while IFS= read -r file; do
    print_found "OpenAPI: $(realpath --relative-to="$SCAN_PATH" "$file")"
    api_files+=("$file")
    ((total_api++))
done < <(find "$SCAN_PATH" -type f \( -name "openapi.yaml" -o -name "openapi.yml" -o -name "swagger.json" -o -name "swagger.yaml" \) 2>/dev/null)

# GraphQL schemas
while IFS= read -r file; do
    print_found "GraphQL: $(realpath --relative-to="$SCAN_PATH" "$file")"
    api_files+=("$file")
    ((total_api++))
done < <(find "$SCAN_PATH" -type f \( -name "*.graphql" -o -name "*.gql" \) 2>/dev/null)

print_success "Found $total_api API specification files"
echo ""

# Scan for inline documentation
print_task "Scanning for inline code documentation"

# JavaScript/TypeScript files
js_files=$(find "$SCAN_PATH" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.jsx" -o -name "*.tsx" \) 2>/dev/null | wc -l)
print_info "JavaScript/TypeScript files: $js_files"

# Python files
py_files=$(find "$SCAN_PATH" -type f -name "*.py" 2>/dev/null | wc -l)
print_info "Python files: $py_files"

# Java files
java_files=$(find "$SCAN_PATH" -type f -name "*.java" 2>/dev/null | wc -l)
print_info "Java files: $java_files"

total_code_files=$((js_files + py_files + java_files))

# Sample analysis of code documentation
if [ $total_code_files -gt 0 ]; then
    print_task "Analyzing code documentation coverage (sampling)"

    # Sample up to 100 files for analysis
    sample_count=0
    while IFS= read -r file && [ $sample_count -lt 100 ]; do
        analyze_file "$file" "code"
        ((sample_count++))
        ((total_inline++))
    done < <(find "$SCAN_PATH" -type f \( -name "*.js" -o -name "*.ts" -o -name "*.py" -o -name "*.java" \) 2>/dev/null)

    print_success "Analyzed $sample_count code files"
fi
echo ""

# Scan for test documentation
print_task "Scanning for test documentation"
test_files=$(find "$SCAN_PATH" -type f \( -name "*.test.*" -o -name "*.spec.*" -o -name "test_*.py" \) 2>/dev/null | wc -l)
print_info "Test files found: $test_files"
total_tests=$test_files
echo ""

# Check for documentation directories
print_task "Checking for documentation directories"
doc_dirs=()
for dir_name in "docs" "documentation" "doc" "api-docs" "guides"; do
    while IFS= read -r dir; do
        print_found "$(realpath --relative-to="$SCAN_PATH" "$dir")"
        doc_dirs+=("$dir")
    done < <(find "$SCAN_PATH" -type d -name "$dir_name" 2>/dev/null)
done
print_success "Found ${#doc_dirs[@]} documentation directories"
echo ""

# Generate discovery report
cat >> "$DISCOVERY_REPORT" << EOF
- Total documentation files: $total_docs
- API specifications: $total_api
- Code files analyzed: $total_inline
- Test files: $total_tests
- Documentation directories: ${#doc_dirs[@]}

## Documentation Found

### README Files
$(find "$SCAN_PATH" -type f \( -iname "readme*" -o -iname "*.readme" \) 2>/dev/null | while read -r f; do echo "- $(realpath --relative-to="$SCAN_PATH" "$f")"; done)

### Markdown Documentation
$(find "$SCAN_PATH" -type f -name "*.md" 2>/dev/null | grep -v -i readme | while read -r f; do echo "- $(realpath --relative-to="$SCAN_PATH" "$f")"; done)

### API Specifications
$(for f in "${api_files[@]}"; do [ -n "$f" ] && echo "- $(realpath --relative-to="$SCAN_PATH" "$f")"; done)

### Documentation Directories
$(for d in "${doc_dirs[@]}"; do [ -n "$d" ] && echo "- $(realpath --relative-to="$SCAN_PATH" "$d")"; done)

## Code Documentation Analysis

### Documentation Coverage (Sample)
EOF

# Calculate average documentation percentage
if [ -f "$TEMP_DIR/doc_percentages.txt" ]; then
    avg_percentage=$(awk -F: '{sum+=$2; count++} END {if (count>0) print int(sum/count); else print 0}' "$TEMP_DIR/doc_percentages.txt")
    echo "Average documentation percentage: $avg_percentage%" >> "$DISCOVERY_REPORT"
else
    echo "No code files analyzed" >> "$DISCOVERY_REPORT"
fi

# Add well-documented files
if [ -f "$TEMP_DIR/has_jsdoc.txt" ] || [ -f "$TEMP_DIR/has_docstrings.txt" ] || [ -f "$TEMP_DIR/has_javadoc.txt" ]; then
    echo "" >> "$DISCOVERY_REPORT"
    echo "### Well-Documented Code Files" >> "$DISCOVERY_REPORT"
    for file in "$TEMP_DIR"/has_*.txt; do
        [ -f "$file" ] && cat "$file" >> "$DISCOVERY_REPORT"
    done
fi

# Identify gaps
cat >> "$DISCOVERY_REPORT" << EOF

## Documentation Gaps Identified

### Missing Documentation
EOF

# Check for common missing documentation
missing_items=()

if [ $(find "$SCAN_PATH" -maxdepth 1 -iname "readme*" | wc -l) -eq 0 ]; then
    missing_items+=("- No root README file")
fi

if [ ${#doc_dirs[@]} -eq 0 ]; then
    missing_items+=("- No dedicated documentation directory")
fi

if [ $total_api -eq 0 ] && [ $js_files -gt 0 ]; then
    missing_items+=("- No API specification files found")
fi

if [ $(find "$SCAN_PATH" -iname "contributing*" | wc -l) -eq 0 ]; then
    missing_items+=("- No CONTRIBUTING guide")
fi

if [ $(find "$SCAN_PATH" -iname "changelog*" -o -iname "history*" | wc -l) -eq 0 ]; then
    missing_items+=("- No CHANGELOG or version history")
fi

if [ ${#missing_items[@]} -eq 0 ]; then
    echo "None identified - basic documentation present" >> "$DISCOVERY_REPORT"
else
    for item in "${missing_items[@]}"; do
        echo "$item" >> "$DISCOVERY_REPORT"
    done
fi

# Recommendations
cat >> "$DISCOVERY_REPORT" << EOF

## Recommendations

Based on the documentation discovery scan:

1. **Documentation Coverage**
   - Current coverage: $total_docs documentation files
   - Consider adding documentation for undocumented areas

2. **Code Documentation**
   - Average inline documentation: ${avg_percentage:-0}%
   - Consider adding JSDoc/docstrings to public APIs

3. **Structure**
   - Organize documentation in dedicated directories
   - Follow consistent naming conventions

4. **Completeness**
   - Ensure all projects have README files
   - Add API documentation where applicable
   - Include contributing and development guides

## Next Steps

1. Review identified gaps
2. Prioritize documentation needs
3. Use \`init-project.sh\` to create structured documentation
4. Use \`update-docs.sh\` to maintain existing documentation
5. Set up continuous documentation monitoring

EOF

# Cleanup
rm -rf "$TEMP_DIR"

# Final output
echo ""
print_success "Documentation discovery completed!"
echo ""
echo "Discovery report: $DISCOVERY_REPORT"
echo ""
print_info "Total documentation files found: $total_docs"
print_info "Total API specifications found: $total_api"
print_info "Documentation directories found: ${#doc_dirs[@]}"
echo ""
print_task "Review the discovery report for detailed findings and recommendations"