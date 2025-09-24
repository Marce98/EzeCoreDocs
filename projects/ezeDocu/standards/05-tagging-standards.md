# Resource Tagging Standards

## Overview
Consistent tagging across AWS resources enables cost tracking, compliance monitoring, automation, and operational management. These standards define required and recommended tags for all AWS resources.

## Tag Categories

### Required Tags (Minimum Set)
These tags must be applied to ALL AWS resources:

| Tag Key | Description | Example Values | Format |
|---------|-------------|----------------|--------|
| `Creator` | Person or system that created the resource | `john.doe@company.com`, `terraform`, `cloudformation` | Email or system name |
| `Purpose` | Business or technical purpose | `customer-api`, `data-processing`, `web-hosting` | Lowercase with hyphens |
| `Environment` | Deployment environment | `dev`, `staging`, `prod`, `prototype` | Lowercase |
| `Platform` | Platform identifier | `vendoloop`, `ezecore`, `shared` | Lowercase |
| `Temporary` | Is this a temporary resource? | `true`, `false` | Boolean string |

### Recommended Tags
Apply these tags where applicable:

| Tag Key | Description | Example Values | When to Use |
|---------|-------------|----------------|------------|
| `Company` | Company/tenant identifier | `winebb`, `GENR844848` | Multi-tenant resources |
| `Location` | Location identifier | `greenville`, `hq` | Location-specific resources |
| `CostCenter` | Billing/accounting code | `IT-001`, `SALES-DEPT` | Cost allocation |
| `Project` | Project or feature name | `mobile-app-v2`, `q1-migration` | Project tracking |
| `ExpiryDate` | When temporary resource expires | `2024-12-31` | Temporary resources |
| `Owner` | Team or person responsible | `backend-team`, `jane.smith@company.com` | Ownership tracking |
| `Version` | Version or iteration | `v1.0`, `2024.01` | Versioned resources |
| `Compliance` | Compliance requirements | `pci`, `hipaa`, `sox` | Regulated resources |
| `BackupPolicy` | Backup requirements | `daily`, `weekly`, `none` | Data resources |
| `DataClassification` | Data sensitivity level | `public`, `internal`, `confidential` | Security classification |

## Tag Formatting Rules

### General Rules
1. **Case Sensitivity**: Tag keys are case-sensitive - use PascalCase for keys
2. **Values**: Use lowercase with hyphens for values (except where noted)
3. **Length**: Maximum 128 characters for keys, 256 for values
4. **Characters**: Use only letters, numbers, spaces, and `+ - = . _ : / @`
5. **Consistency**: Always use the same format for the same type of data

### Date Formats
- Use ISO 8601 format: `YYYY-MM-DD`
- Example: `2024-01-15`

### Boolean Values
- Use lowercase string: `true` or `false`
- Not `True`, `TRUE`, `1`, or `yes`

### Email Addresses
- Use full email format: `user@domain.com`
- For service accounts: `service-name@system`

## Resource-Specific Tagging

### Lambda Functions
```json
{
  "Creator": "john.doe@company.com",
  "Purpose": "process-orders",
  "Environment": "prod",
  "Platform": "vendoloop",
  "Temporary": "false",
  "Company": "winebb",
  "Location": "greenville",
  "Version": "v2.1",
  "LastModified": "2024-01-15"
}
```

### DynamoDB Tables
```json
{
  "Creator": "terraform",
  "Purpose": "inventory-data",
  "Environment": "prod",
  "Platform": "vendoloop",
  "Temporary": "false",
  "BackupPolicy": "daily",
  "DataClassification": "confidential",
  "CostCenter": "IT-OPS"
}
```

### S3 Buckets
```json
{
  "Creator": "cloudformation",
  "Purpose": "static-assets",
  "Environment": "prod",
  "Platform": "ezecore",
  "Temporary": "false",
  "DataClassification": "public",
  "LifecyclePolicy": "90-days",
  "PublicAccess": "false"
}
```

### EC2 Instances (if used)
```json
{
  "Creator": "jane.smith@company.com",
  "Purpose": "development-server",
  "Environment": "dev",
  "Platform": "shared",
  "Temporary": "true",
  "ExpiryDate": "2024-02-28",
  "AutoShutdown": "true",
  "Owner": "backend-team"
}
```

## Automation Tags

### For Automated Operations
These tags trigger automated processes:

| Tag Key | Purpose | Values | Action |
|---------|---------|--------|--------|
| `AutoShutdown` | Auto stop/start schedule | `true`, `false` | Cost savings |
| `AutoScale` | Scaling policy | `enabled`, `disabled` | Performance |
| `AutoBackup` | Automated backup | `true`, `false` | Data protection |
| `AutoDelete` | Automatic deletion | Date (YYYY-MM-DD) | Cleanup |
| `MonitoringLevel` | Monitoring intensity | `basic`, `detailed`, `none` | Observability |

## Tagging Implementation

### CloudFormation Template
```yaml
Resources:
  MyLambdaFunction:
    Type: AWS::Lambda::Function
    Properties:
      FunctionName: vendoloop-orders-ProcessPayment
      Tags:
        - Key: Creator
          Value: cloudformation
        - Key: Purpose
          Value: payment-processing
        - Key: Environment
          Value: !Ref Environment
        - Key: Platform
          Value: vendoloop
        - Key: Temporary
          Value: false
```

### Terraform Example
```hcl
resource "aws_dynamodb_table" "inventory" {
  name = "vendoloop-Inventory-Table-Main"

  tags = {
    Creator            = "terraform"
    Purpose            = "inventory-management"
    Environment        = var.environment
    Platform          = "vendoloop"
    Temporary         = "false"
    DataClassification = "confidential"
  }
}
```

### AWS CLI Example
```bash
aws ec2 create-instance \
  --tag-specifications \
  'ResourceType=instance,Tags=[
    {Key=Creator,Value=john.doe@company.com},
    {Key=Purpose,Value=test-server},
    {Key=Environment,Value=dev},
    {Key=Platform,Value=shared},
    {Key=Temporary,Value=true},
    {Key=ExpiryDate,Value=2024-02-28}
  ]'
```

## Cost Allocation

### Setting Up Cost Reports
Use these tag keys for AWS Cost Explorer:
- `Environment` - Compare costs across environments
- `Platform` - Track platform-specific costs
- `Company` - Multi-tenant cost allocation
- `CostCenter` - Internal billing
- `Project` - Project-based accounting

### Monthly Cost Review Query
```sql
SELECT
  Platform,
  Environment,
  SUM(UnblendedCost) as TotalCost
FROM aws_cost_report
WHERE
  Temporary = 'false'
GROUP BY Platform, Environment
ORDER BY TotalCost DESC
```

## Compliance and Governance

### Tag Compliance Checking
```python
def check_resource_tags(resource):
    required_tags = ['Creator', 'Purpose', 'Environment', 'Platform', 'Temporary']
    missing_tags = []

    for tag in required_tags:
        if tag not in resource.tags:
            missing_tags.append(tag)

    if missing_tags:
        raise TagComplianceError(f"Missing required tags: {missing_tags}")

    return True
```

### Tag Enforcement Policy
```json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Deny",
    "Action": "*",
    "Resource": "*",
    "Condition": {
      "Null": {
        "aws:RequestTag/Creator": "true",
        "aws:RequestTag/Purpose": "true",
        "aws:RequestTag/Environment": "true"
      }
    }
  }]
}
```

## Tag Maintenance

### Regular Tag Audits
1. **Weekly**: Check for resources missing required tags
2. **Monthly**: Review temporary resources for expiration
3. **Quarterly**: Update cost allocation tags
4. **Annually**: Review and update tagging strategy

### Cleanup Process
```python
def cleanup_expired_resources():
    # Find resources with past expiry dates
    expired = find_resources_by_tag('ExpiryDate', '<', today())

    for resource in expired:
        if resource.tags.get('Temporary') == 'true':
            delete_resource(resource)
            log_deletion(resource)
```

## Reporting and Dashboards

### Tag-Based Metrics
Create CloudWatch dashboards filtered by tags:
- Resource count by Platform
- Costs by Environment
- Temporary resources nearing expiry
- Untagged resource alerts

### Sample Dashboard Query
```python
def get_platform_metrics(platform):
    return cloudwatch.get_metric_statistics(
        Namespace='AWS/Lambda',
        MetricName='Invocations',
        Dimensions=[
            {'Name': 'Platform', 'Value': platform}
        ],
        StartTime=datetime.now() - timedelta(days=7),
        EndTime=datetime.now(),
        Period=86400,
        Statistics=['Sum']
    )
```

## Best Practices

1. **Tag at Creation**: Always tag resources when creating them
2. **Automate Tagging**: Use IaC tools to enforce tagging
3. **Regular Audits**: Schedule automated tag compliance checks
4. **Document Exceptions**: Record why certain resources lack tags
5. **Tag Inheritance**: Use tag propagation where supported
6. **Version Control**: Track tag changes in git
7. **Training**: Ensure team understands tagging importance

## Exceptions

### When Tags May Be Omitted
- AWS-managed resources (some cannot be tagged)
- Resources created by AWS services automatically
- Third-party marketplace resources

### Exception Documentation
Document any untagged resources:
```yaml
Exception:
  ResourceId: arn:aws:lambda:us-east-1:123456789012:function:temp-debug
  Reason: Emergency debugging function
  ApprovedBy: tech-lead@company.com
  Date: 2024-01-15
  ReviewDate: 2024-02-15
```