# AWS Resource Naming Standards

## Overview
Consistent naming conventions across AWS resources ensure clarity, maintainability, and ease of resource management. These standards apply to all AWS resources created within our ecosystem.

## General Naming Rules

### Format
- Use **hyphens** (-) as separators, not underscores
- Use **PascalCase** for multi-word components when hyphens can't be used
- Keep names **descriptive but concise**
- Include **environment indicators** where applicable

### Character Limits
- Be aware of AWS service-specific naming limits
- Plan for scalability in naming patterns

## Naming Patterns

### 1. Common/Shared Resources (EzeCore)
Resources that provide shared functionality across multiple applications use the `EzeCore` prefix.

**Pattern**: `EzeCore-[Category]-[ResourceType]-[Identifier]`

**Examples**:
- `EzeCore-Analytics-Lambda-ProcessMetrics`
- `EzeCore-Forms-API-Gateway`
- `EzeCore-Shared-DynamoTable-Master`
- `EzeCore-Auth-CognitoPool-Main`
- `EzeCore-Monitoring-SNSTopic-Alerts`

**Categories**:
- `Analytics` - Data processing and analytics
- `Forms` - Form processing and validation
- `Auth` - Authentication and authorization
- `Monitoring` - Logging and monitoring
- `Shared` - Cross-application resources
- `Integration` - Third-party integrations

### 2. Application-Specific Resources
Resources dedicated to specific applications use the application name as prefix.

**Pattern**: `[AppName]-[Category]-[ResourceType]-[Identifier]`

**Examples**:
- `vendoloop-Inventory-Lambda-UpdateStock`
- `vendoloop-Orders-DynamoTable-Main`
- `vendoloop-Public-API-Gateway`
- `vendoloop-IAM-Role-LambdaExecution`
- `vendoloop-S3-Bucket-ProductImages`

### 3. IAM Resources

#### Roles
**Pattern**: `[Prefix]-IAM-Role-[Purpose]`
- `EzeCore-IAM-Role-LambdaBasicExecution`
- `vendoloop-IAM-Role-DynamoDBAccess`

#### Policies
**Pattern**: `[Prefix]-IAM-Policy-[Purpose]`
- `EzeCore-IAM-Policy-S3ReadOnly`
- `vendoloop-IAM-Policy-FullStackAccess`

### 4. Lambda Functions
**Pattern**: `[Prefix]-[Domain]-Lambda-[Action]`
- `EzeCore-Analytics-Lambda-GenerateReports`
- `vendoloop-Inventory-Lambda-CheckStock`
- `vendoloop-Orders-Lambda-ProcessPayment`

### 5. DynamoDB Tables
**Pattern**: `[Prefix]-[Domain]-Table-[Purpose]`
- `EzeCore-Shared-Table-Configuration`
- `vendoloop-Inventory-Table-Products`
- `vendoloop-Orders-Table-Transactions`

### 6. S3 Buckets
**Pattern**: `[prefix]-[domain]-[purpose]-[uniqueid]`
> Note: S3 bucket names must be globally unique and lowercase

- `ezecore-shared-configs-prod-2024`
- `vendoloop-inventory-images-us-east-1`
- `vendoloop-backups-daily-001`

### 7. API Gateway
**Pattern**: `[Prefix]-[Access]-API-[Version]`
- `EzeCore-Internal-API-v1`
- `vendoloop-Public-API-v2`
- `vendoloop-Partner-API-v1`

### 8. CloudFormation Stacks
**Pattern**: `[Prefix]-Stack-[Component]-[Environment]`
- `EzeCore-Stack-Infrastructure-Prod`
- `vendoloop-Stack-Frontend-Dev`
- `vendoloop-Stack-Database-Staging`

## Environment Indicators
When resources are environment-specific, append the environment:
- Development: `-Dev`
- Staging: `-Staging`
- Production: `-Prod`

**Examples**:
- `vendoloop-Orders-Lambda-ProcessPayment-Dev`
- `vendoloop-Orders-Lambda-ProcessPayment-Prod`

## Special Considerations

### Temporary Resources
For temporary or experimental resources, include a timestamp or ticket number:
- `vendoloop-Test-Lambda-TEMP-20240115`
- `EzeCore-Experiment-Table-JIRA1234`

### Multi-Region Resources
Include region identifier when resources span multiple regions:
- `vendoloop-Inventory-Table-Products-UsEast1`
- `vendoloop-Inventory-Table-Products-EuWest1`

## Exceptions
Document any naming convention exceptions in your project documentation with:
1. The resource name that deviates
2. Reason for deviation
3. Approval from technical lead
4. Impact assessment

## Migration Path
For existing resources that don't follow these conventions:
1. Document current naming in migration log
2. Plan transition during next major update
3. Use tags to maintain traceability

## Best Practices
1. **Be Consistent** - Follow patterns throughout the project
2. **Be Descriptive** - Names should indicate purpose
3. **Plan for Scale** - Consider future growth in naming
4. **Document Exceptions** - Always document deviations
5. **Use Tags** - Supplement naming with comprehensive tagging