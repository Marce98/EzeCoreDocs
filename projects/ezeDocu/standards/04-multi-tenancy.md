# Multi-Tenancy Standards

## Overview
Our applications support multiple platforms, companies, and locations through a hierarchical multi-tenant architecture. This document defines how we structure, isolate, and manage tenant data across our systems.

## Tenant Hierarchy

### Three-Level Structure
```
Platform → Company → Location
```

1. **Platform**: The application or product line (e.g., vendoloop, ezecore)
2. **Company**: The business entity using the platform (e.g., winebb, GENR844848)
3. **Location**: Physical or logical locations within a company (e.g., greenville, hq, warehouse-1)

### Identifier Format

#### Platform Identifiers
- Lowercase alphanumeric
- No special characters except hyphens
- Examples: `vendoloop`, `ezecore`, `retail-pro`

#### Company Codes
- Uppercase alphanumeric
- 6-12 characters recommended
- Examples: `WINEBB`, `GENR844848`, `CORP2024`

#### Location Codes
- Lowercase alphanumeric with hyphens
- Descriptive and unique within company
- Examples: `greenville`, `hq`, `store-001`, `warehouse-east`

## Data Isolation Strategies

### 1. Logical Isolation (Recommended)
Single infrastructure with data separation through keys and queries.

**Advantages**:
- Lower operational overhead
- Cost-effective
- Easier cross-tenant analytics
- Simplified deployment

**Implementation**:
```json
{
  "tenantKey": "PLATFORM#vendoloop#COMPANY#winebb#LOCATION#greenville",
  "data": {
    "inventory": [],
    "customers": []
  }
}
```

### 2. Physical Isolation
Separate resources per tenant (use only when required).

**When to Use**:
- Regulatory compliance requirements
- Customer contractual demands
- Extreme performance isolation needs

## DynamoDB Multi-Tenant Patterns

### Standard Partition Key Structure
```
PK: PLATFORM#[platform]#COMPANY#[company]#LOCATION#[location]
```

### Tenant-Specific Queries
```python
# Query all data for a location
response = table.query(
    KeyConditionExpression='PK = :pk',
    ExpressionAttributeValues={
        ':pk': 'PLATFORM#vendoloop#COMPANY#winebb#LOCATION#greenville'
    }
)

# Query all locations for a company
response = table.query(
    IndexName='CompanyIndex',
    KeyConditionExpression='CompanyId = :company',
    ExpressionAttributeValues={
        ':company': 'PLATFORM#vendoloop#COMPANY#winebb'
    }
)
```

### Global Tenant Data
For platform-wide shared data:
```
PK: PLATFORM#vendoloop#GLOBAL
SK: CONFIG#[configType]
```

## API Multi-Tenancy

### Tenant Identification
Tenants are identified through:

1. **JWT Claims** (Preferred)
```json
{
  "sub": "user-id",
  "platform": "vendoloop",
  "company": "winebb",
  "location": "greenville",
  "permissions": ["read", "write"]
}
```

2. **API Headers**
```
X-Platform: vendoloop
X-Company: winebb
X-Location: greenville
```

3. **URL Path**
```
/api/v1/vendoloop/winebb/greenville/inventory
```

### Request Validation
```python
def validate_tenant_access(event):
    # Extract tenant from JWT
    claims = event['requestContext']['authorizer']['claims']

    tenant_context = {
        'platform': claims.get('platform'),
        'company': claims.get('company'),
        'location': claims.get('location')
    }

    # Validate against requested resource
    requested_tenant = extract_tenant_from_path(event['path'])

    if not matches_tenant_context(tenant_context, requested_tenant):
        raise UnauthorizedError("Tenant mismatch")

    return tenant_context
```

## Lambda Function Patterns

### Tenant Context Injection
```python
import os
import json

def lambda_handler(event, context):
    # Extract tenant context
    tenant = get_tenant_context(event)

    # Set tenant context for all operations
    with tenant_scope(tenant):
        # All database operations automatically scoped
        result = process_request(event['body'])

    return {
        'statusCode': 200,
        'body': json.dumps(result)
    }

def get_tenant_context(event):
    """Extract tenant from JWT claims or headers"""
    if 'authorizer' in event.get('requestContext', {}):
        claims = event['requestContext']['authorizer']['claims']
        return {
            'platform': claims['platform'],
            'company': claims['company'],
            'location': claims.get('location')
        }
    # Fallback to headers
    headers = event.get('headers', {})
    return {
        'platform': headers.get('X-Platform'),
        'company': headers.get('X-Company'),
        'location': headers.get('X-Location')
    }
```

## Cognito User Pool Strategy

### Pool Structure Options

#### Option 1: Single User Pool (Recommended)
One pool with custom attributes for tenant identification.

**User Attributes**:
```json
{
  "email": "user@example.com",
  "custom:platform": "vendoloop",
  "custom:company": "winebb",
  "custom:locations": "greenville,charleston",
  "custom:role": "manager"
}
```

#### Option 2: Pool per Platform
Separate pools for major platforms when isolation is critical.

### User Groups
Structure groups hierarchically:
```
vendoloop-winebb-admins
vendoloop-winebb-greenville-users
vendoloop-winebb-greenville-managers
```

## S3 Multi-Tenant Structure

### Bucket Organization
```
bucket-name/
├── platform/vendoloop/
│   ├── company/winebb/
│   │   ├── location/greenville/
│   │   │   ├── documents/
│   │   │   ├── images/
│   │   │   └── reports/
│   │   └── location/charleston/
│   └── company/corp2024/
└── platform/ezecore/
    └── shared/
```

### Access Policies
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Action": ["s3:GetObject", "s3:PutObject"],
    "Resource": "arn:aws:s3:::bucket/platform/${jwt:platform}/company/${jwt:company}/location/${jwt:location}/*"
  }]
}
```

## Cross-Tenant Operations

### Analytics and Reporting
For platform-wide analytics:
```python
def aggregate_platform_metrics(platform):
    # Query with GSI for platform-wide data
    response = table.query(
        IndexName='PlatformIndex',
        KeyConditionExpression='Platform = :platform',
        ExpressionAttributeValues={':platform': f'PLATFORM#{platform}'}
    )
    return aggregate_results(response['Items'])
```

### Shared Resources
Resources available across tenants:
```
PK: PLATFORM#vendoloop#SHARED
SK: RESOURCE#[resourceType]#[resourceId]
```

## Security Considerations

### Data Isolation Enforcement
1. **Always validate tenant context** in every request
2. **Never allow cross-tenant queries** without explicit permission
3. **Log all cross-tenant access attempts**
4. **Encrypt tenant-specific data** with tenant-specific keys (when required)

### Tenant Switching
For users with multi-tenant access:
```python
def switch_tenant_context(user_id, target_tenant):
    # Verify user has access to target tenant
    if not user_has_access(user_id, target_tenant):
        raise UnauthorizedError()

    # Generate new JWT with target tenant
    return generate_token(user_id, target_tenant)
```

## Migration and Onboarding

### New Tenant Onboarding
```python
def onboard_new_tenant(platform, company, location):
    # 1. Create tenant record
    create_tenant_record(platform, company, location)

    # 2. Initialize default configurations
    setup_default_configs(platform, company, location)

    # 3. Create admin user
    create_admin_user(platform, company, location)

    # 4. Set up billing (if applicable)
    initialize_billing(company)
```

### Tenant Data Migration
```python
def migrate_tenant_data(source_tenant, target_tenant):
    # 1. Validate migration authorization
    # 2. Copy data with new tenant keys
    # 3. Verify data integrity
    # 4. Update user associations
    # 5. Archive source data
```

## Monitoring and Metrics

### Tenant-Specific Metrics
```python
def log_metric(metric_name, value, tenant):
    cloudwatch.put_metric_data(
        Namespace='MultiTenant/Operations',
        MetricData=[{
            'MetricName': metric_name,
            'Value': value,
            'Dimensions': [
                {'Name': 'Platform', 'Value': tenant['platform']},
                {'Name': 'Company', 'Value': tenant['company']},
                {'Name': 'Location', 'Value': tenant['location']}
            ]
        }]
    )
```

### Tenant Usage Tracking
- API calls per tenant
- Storage usage per tenant
- Compute time per tenant
- Cost allocation per tenant

## Best Practices

1. **Consistent Tenant Keys**: Use the same format across all services
2. **Early Validation**: Validate tenant context at API Gateway level
3. **Audit Logging**: Log all operations with tenant context
4. **Tenant Limits**: Implement rate limiting per tenant
5. **Graceful Degradation**: Isolate tenant failures
6. **Regular Testing**: Test tenant isolation in CI/CD

## Exception Scenarios

### Single-Tenant Deployments
When a customer requires dedicated infrastructure:
1. Document in project specifications
2. Use standard patterns with single tenant
3. Maintain upgrade path to multi-tenant
4. Consider cost implications

### Cross-Tenant Features
When features span tenants:
1. Require explicit permissions
2. Log extensively
3. Implement approval workflows
4. Monitor for abuse