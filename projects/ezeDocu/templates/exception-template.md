# Exception Documentation Template

## Project/Feature Information
**Project Name**: [Your project/feature name]
**Date**: [YYYY-MM-DD]
**Author**: [Your name/email]
**Reviewed By**: [Technical lead name/email]

## Standard Being Deviated From
**Standard Document**: [Link to specific standard document]
**Section**: [Specific section/requirement being exempted]

## Description of Deviation

### What is Different?
[Clearly describe what you're doing differently from the standard]

### Specific Implementation
```
[Provide code example or configuration that shows the deviation]
```

## Justification

### Technical Reasons
- [ ] Performance requirements not met by standard approach
- [ ] Integration with legacy system requires different approach
- [ ] Third-party service limitations
- [ ] Platform-specific constraints
- [ ] Other: [Specify]

**Detailed Explanation**:
[Provide detailed technical justification]

### Business Reasons
- [ ] Customer-specific requirement
- [ ] Regulatory/compliance requirement
- [ ] Cost constraints
- [ ] Timeline constraints
- [ ] Other: [Specify]

**Detailed Explanation**:
[Provide detailed business justification]

## Impact Analysis

### Affected Components
- **Resources**: [List AWS resources affected]
- **Services**: [List services/APIs affected]
- **Teams**: [List teams that need to be aware]

### Risk Assessment
| Risk | Likelihood | Impact | Mitigation |
|------|------------|--------|------------|
| [Risk 1] | Low/Medium/High | Low/Medium/High | [Mitigation strategy] |
| [Risk 2] | Low/Medium/High | Low/Medium/High | [Mitigation strategy] |

### Compatibility
- **Backward Compatible**: Yes/No
- **Forward Compatible**: Yes/No
- **Migration Path Required**: Yes/No

## Alternative Approaches Considered
| Approach | Pros | Cons | Why Not Chosen |
|----------|------|------|----------------|
| Standard Approach | [List pros] | [List cons] | [Reason] |
| Alternative 1 | [List pros] | [List cons] | [Reason] |
| Alternative 2 | [List pros] | [List cons] | [Reason] |

## Implementation Details

### Current Implementation
```yaml
# Example configuration or code
```

### How to Maintain This Exception
1. [Step 1 for maintaining this deviation]
2. [Step 2 for maintaining this deviation]
3. [Special considerations]

### Monitoring Requirements
- **Metrics to Track**: [List specific metrics]
- **Alerts to Configure**: [List alerts needed]
- **Review Frequency**: [How often to review this exception]

## Future Considerations

### Migration Path to Standard
**Conditions for Migration**:
- [ ] When [specific condition is met]
- [ ] After [specific milestone]
- [ ] If [specific change occurs]

**Migration Steps**:
1. [Step 1 for migration]
2. [Step 2 for migration]
3. [Validation steps]

### Sunset Plan
**Expected Duration**: [How long this exception should exist]
**Review Date**: [When to review this exception]
**Sunset Date**: [Target date to eliminate exception, if applicable]

## Documentation and Communication

### Documentation Updates Required
- [ ] Update project README
- [ ] Update API documentation
- [ ] Update runbooks
- [ ] Update architecture diagrams
- [ ] Other: [Specify]

### Teams Notified
- [ ] Development Team
- [ ] Operations Team
- [ ] Security Team
- [ ] Architecture Team
- [ ] Other: [Specify]

## Approval

### Approval Chain
| Role | Name | Date | Signature/Approval |
|------|------|------|-------------------|
| Technical Lead | | | |
| Architect | | | |
| Product Owner | | | |
| Other | | | |

### Conditions of Approval
[Any specific conditions that must be met for this exception to remain valid]

## Review History
| Date | Reviewer | Decision | Notes |
|------|----------|----------|-------|
| [YYYY-MM-DD] | [Name] | Approved/Extended/Migrate | [Notes] |

---

## Example Usage

### Example 1: Using RDS Instead of DynamoDB

**Standard Being Deviated From**: DynamoDB Design Patterns
**Section**: Single Table Design

**What is Different?**:
Using PostgreSQL RDS instead of DynamoDB for transaction processing system.

**Technical Reasons**:
- Need ACID transactions across multiple entities
- Complex reporting queries with JOINs required
- Existing team expertise in PostgreSQL

**Impact Analysis**:
- Resources: RDS instance, read replicas, backup storage
- Cost Impact: ~$200/month additional for RDS vs DynamoDB
- Risk: Higher operational overhead, mitigated by team expertise

**Migration Path**:
Will consider DynamoDB when reporting can be separated into different system and transaction volume exceeds 10,000/second.

### Example 2: Custom Authentication Instead of Cognito

**Standard Being Deviated From**: Authentication Standards
**Section**: AWS Cognito Implementation

**What is Different?**:
Using existing enterprise Active Directory with SAML integration.

**Business Reasons**:
- Corporate requirement for centralized identity management
- Existing AD investment and user base
- Compliance with SOC2 requirements

**Implementation Details**:
- SAML 2.0 integration with AD FS
- Custom Lambda authorizer for token validation
- Session management in DynamoDB

**Review Date**: 2025-01-01 (Annual review)

---

**Note**: This template should be completed for each deviation from the established standards. Store completed exceptions in the project repository under `/docs/exceptions/` directory.