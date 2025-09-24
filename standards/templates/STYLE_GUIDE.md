# Documentation Style Guide

## Purpose
This guide ensures consistency, clarity, and completeness across all technical documentation in our organization.

## General Principles

### 1. Clarity First
- Write for your audience (developers, not necessarily experts in your domain)
- Use simple, direct language
- Avoid jargon unless necessary (and define it when used)
- One idea per paragraph

### 2. Consistency
- Use consistent terminology throughout
- Follow established patterns and templates
- Maintain consistent formatting

### 3. Completeness
- Include all necessary information
- Provide context and background
- Link to related documentation

## Document Structure

### Required Sections
Every technical document must include:
1. **Title** - Clear, descriptive title
2. **Last Updated** - Date of last modification
3. **Overview/Purpose** - What and why
4. **Table of Contents** - For documents > 3 sections
5. **Content** - The main documentation
6. **References** - Links to related docs

### Optional Sections
Include when relevant:
- Prerequisites
- Examples
- Troubleshooting
- FAQ
- Glossary
- Changelog

## Formatting Standards

### Headers
```markdown
# Document Title (H1 - only one per document)
## Main Section (H2)
### Subsection (H3)
#### Minor Section (H4)
```

### Code Blocks
Always specify language for syntax highlighting:
````markdown
```javascript
const example = "Use language-specific highlighting";
```
````

### Lists

**Unordered Lists** for related items without sequence:
- Item one
- Item two
- Item three

**Ordered Lists** for sequential steps:
1. First step
2. Second step
3. Third step

### Tables
Use tables for structured data:
```markdown
| Column 1 | Column 2 | Column 3 |
|----------|----------|----------|
| Data 1   | Data 2   | Data 3   |
```

### Links
- Use descriptive link text: `[API Documentation](./api.md)`
- Avoid: `[Click here](./api.md)`
- Use relative links for internal documentation

## Language Guidelines

### Voice and Tone
- **Active voice:** "The function returns an array" ✓
- Not passive: "An array is returned by the function" ✗
- **Present tense:** "The API accepts JSON" ✓
- **Imperative for instructions:** "Install dependencies" ✓

### Word Choice
- **Use:** configure, set up, create, delete, update
- **Avoid:** config, setup (as verb), make, kill, modify
- **Be specific:** "in 5 seconds" instead of "quickly"

### Common Terms
| Use | Don't Use |
|-----|-----------|
| repository | repo |
| documentation | docs |
| configuration | config |
| administrator | admin |
| database | db |

## Code Documentation

### Inline Comments
```javascript
// Calculate the total including tax
// Tax rate is defined in config.js
const total = subtotal * (1 + taxRate);
```

### Function Documentation
```javascript
/**
 * Calculates the total price including tax
 * @param {number} subtotal - Price before tax
 * @param {number} taxRate - Tax rate as decimal (0.1 for 10%)
 * @returns {number} Total price including tax
 */
function calculateTotal(subtotal, taxRate) {
  return subtotal * (1 + taxRate);
}
```

## API Documentation Standards

### Endpoint Documentation
Always include:
- HTTP method
- Endpoint path
- Description
- Parameters (query, path, body)
- Request example
- Response example
- Error responses
- Authentication requirements

### Example Format
```markdown
### Create User
`POST /api/users`

Creates a new user account.

**Authentication:** Required (Bearer token)

**Request Body:**
```json
{
  "email": "user@example.com",
  "name": "John Doe"
}
```

**Response:** `201 Created`
```json
{
  "id": "123",
  "email": "user@example.com",
  "name": "John Doe"
}
```
```

## README Standards

### Project README Must Include
1. Project name and description
2. Prerequisites and requirements
3. Installation instructions
4. Basic usage examples
5. Development setup
6. Testing instructions
7. Deployment guide
8. Contributing guidelines
9. License information

### Example Structure
```markdown
# Project Name

Brief description of what the project does.

## Prerequisites
- Node.js >= 14
- PostgreSQL >= 12

## Installation
\```bash
npm install
\```

## Usage
Basic usage example

## Development
Development setup instructions

## Testing
How to run tests

## License
MIT
```

## Diagrams and Visualizations

### When to Use Diagrams
- Architecture overviews
- Data flows
- Sequence interactions
- State machines
- Complex relationships

### Mermaid Diagrams
```markdown
\```mermaid
graph LR
    A[Start] --> B{Decision}
    B -->|Yes| C[Process]
    B -->|No| D[End]
\```
```

### ASCII Diagrams
For simple relationships:
```
┌─────────┐     ┌─────────┐
│ Client  │────▶│ Server  │
└─────────┘     └─────────┘
```

## File Naming Conventions

### Documentation Files
- Use UPPERCASE for standard docs: `README.md`, `LICENSE.md`
- Use lowercase with hyphens for others: `api-guide.md`
- No spaces in filenames

### Document Types
- `README.md` - Project overview
- `ARCHITECTURE.md` - System design
- `API.md` - API documentation
- `CONTRIBUTING.md` - Contribution guidelines
- `CHANGELOG.md` - Version history

## Version Documentation

### Versioning Format
```markdown
## Version 2.1.0 (2024-01-15)

### Added
- New feature X
- Enhancement Y

### Changed
- Updated behavior of Z

### Fixed
- Bug in component A

### Deprecated
- Method B (will be removed in 3.0.0)
```

## Review Checklist

Before publishing documentation, ensure:

### Content
- [ ] Accurate and up-to-date
- [ ] Complete with all necessary information
- [ ] Examples are working and tested
- [ ] Links are valid
- [ ] No sensitive information exposed

### Format
- [ ] Follows this style guide
- [ ] Consistent formatting
- [ ] Proper markdown syntax
- [ ] Code blocks have language specified
- [ ] Tables are properly formatted

### Language
- [ ] Clear and concise
- [ ] Grammar and spelling checked
- [ ] Technical terms defined
- [ ] Active voice used
- [ ] Consistent terminology

## Tools and Validation

### Markdown Linting
Use `markdownlint` with our configuration:
```bash
npm run lint:markdown
```

### Link Checking
Validate all links:
```bash
npm run check:links
```

### Spell Checking
Check spelling with:
```bash
npm run check:spelling
```

## Maintenance

### Regular Updates
- Review quarterly for accuracy
- Update when code changes
- Remove outdated information
- Add new examples as needed

### Deprecation Process
1. Mark as deprecated with date
2. Provide migration path
3. Maintain for 2 versions
4. Remove in major version update

## Examples of Good Documentation

### Good: Clear and Specific
> "The `processPayment()` function validates the credit card, charges the amount, and returns a transaction ID. It throws a `PaymentError` if the charge fails."

### Poor: Vague and Unclear
> "This function handles payments and returns something."

### Good: Complete Error Information
> "Returns `404 Not Found` when the user ID doesn't exist in the database. The response includes an error message and request ID for debugging."

### Poor: Incomplete
> "Returns an error sometimes."

## Getting Help

For questions about documentation standards:
- Check existing documentation examples
- Ask in #documentation Slack channel
- Review recent pull requests
- Contact the documentation team