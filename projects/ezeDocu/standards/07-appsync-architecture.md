# AppSync Architecture Standard

## Overview
AppSync serves as the primary GraphQL API layer for all projects within the EzeCore ecosystem. This standard establishes the architectural pattern of using one AppSync API per project to provide a unified, efficient, and scalable interface for client applications while maintaining clear project boundaries.

## Core Principle
**One AppSync API per project** - Each project should have a dedicated AppSync GraphQL API that serves as the primary interface for all client interactions with that project's Lambda functions and data sources.

## Architecture Pattern

### AppSync as Primary API Layer
AppSync replaces traditional REST API patterns as the preferred approach for client-server communication due to:

- **Unified Schema**: Single endpoint for all data operations
- **Type Safety**: Strong typing with GraphQL schemas
- **Real-time Capabilities**: Built-in subscriptions for live data
- **Efficient Queries**: Clients request only needed data
- **Built-in Security**: Integration with AWS authentication services
- **Cost Efficiency**: Pay-per-operation pricing model

### Integration with Lambda Functions
AppSync should integrate with Lambda functions following these patterns:

#### Direct Lambda Resolvers (Preferred)
```graphql
type Query {
  getUser(id: ID!): User
  listUsers(filter: UserFilter): [User]
}

type Mutation {
  createUser(input: CreateUserInput!): User
  updateUser(id: ID!, input: UpdateUserInput!): User
  deleteUser(id: ID!): Boolean
}
```

#### Pipeline Resolvers (For Complex Operations)
Use pipeline resolvers when operations require multiple data sources or complex orchestration:

```yaml
# Example: Order processing pipeline
Pipeline:
  - ValidateUserResolver
  - CheckInventoryResolver
  - ProcessPaymentResolver
  - CreateOrderResolver
  - SendNotificationResolver
```

## Naming Conventions

### AppSync API Naming
Follow the established AWS naming pattern:
**Pattern**: `[ProjectName]-GraphQL-API-[Environment]`

**Examples**:
- `vendoloop-GraphQL-API-Prod`
- `vendoloop-GraphQL-API-Dev`
- `EzeCore-Analytics-GraphQL-API-Prod`

### Schema and Resolver Naming

#### Lambda Function Names
**Pattern**: `[ProjectName]-[Domain]-Lambda-[Operation]`
- `vendoloop-User-Lambda-GetUser`
- `vendoloop-Order-Lambda-CreateOrder`
- `vendoloop-Inventory-Lambda-UpdateStock`

#### Resolver Names
**Pattern**: `[TypeName][FieldName]Resolver`
- `QueryGetUserResolver`
- `MutationCreateOrderResolver`
- `UserOrdersResolver`

#### Data Source Names
**Pattern**: `[ProjectName][ServiceType]DataSource`
- `vendoloopLambdaDataSource`
- `vendoloopDynamoDataSource`
- `vendoloopRDSDataSource`

## Schema Design Standards

### Type Definitions
```graphql
# Standard scalar types
scalar AWSDateTime
scalar AWSJSON
scalar AWSEmail
scalar AWSPhone
scalar AWSURL

# Base types should include metadata
interface Node {
  id: ID!
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
}

# Use consistent pagination pattern
type UserConnection {
  items: [User]
  nextToken: String
  total: Int
}
```

### Input Types
```graphql
# Create inputs should not include system fields
input CreateUserInput {
  email: AWSEmail!
  name: String!
  profile: UserProfileInput
}

# Update inputs should be flexible
input UpdateUserInput {
  name: String
  profile: UserProfileInput
}

# Filter inputs should be comprehensive
input UserFilter {
  email: StringFilter
  name: StringFilter
  createdAt: DateTimeFilter
  and: [UserFilter]
  or: [UserFilter]
}
```

### Error Handling
```graphql
# Standard error interface
interface Error {
  message: String!
  code: String!
  path: [String]
}

# Specific error types
type ValidationError implements Error {
  message: String!
  code: String!
  path: [String]
  field: String!
}

type AuthenticationError implements Error {
  message: String!
  code: String!
  path: [String]
}
```

## Resolver Configuration Best Practices

### Lambda Resolvers
```vtl
## Request Mapping Template (Preferred: Direct Lambda)
{
  "version": "2018-05-29",
  "operation": "Invoke",
  "payload": {
    "field": "$context.info.fieldName",
    "arguments": $util.toJson($context.arguments),
    "identity": $util.toJson($context.identity),
    "source": $util.toJson($context.source),
    "request": {
      "headers": $util.toJson($context.request.headers)
    }
  }
}

## Response Mapping Template
#if($context.error)
  $util.error($context.error.message, $context.error.type)
#end
$util.toJson($context.result)
```

### Pipeline Resolver Templates
```vtl
## Request Template
{}

## Response Template
#if($context.error)
  $util.error($context.error.message, $context.error.type)
#end
$util.toJson($context.prev.result)
```

### Caching Strategy
```yaml
# Resolver-level caching configuration
CachingBehavior: PER_RESOLVER_CACHING
CachingKeys:
  - "$context.arguments.id"
  - "$context.identity.sub"
TTL: 300  # 5 minutes default
```

## Authentication and Authorization Patterns

### Multi-Auth Configuration
```yaml
AuthenticationTypes:
  - Type: AMAZON_COGNITO_USER_POOLS
    UserPoolId: !Ref CognitoUserPool
    DefaultAction: ALLOW
  - Type: AWS_IAM
    DefaultAction: ALLOW
  - Type: API_KEY
    DefaultAction: ALLOW

DefaultAuthenticationType: AMAZON_COGNITO_USER_POOLS
```

### Field-Level Authorization
```graphql
type User @aws_cognito_user_pools {
  id: ID!
  email: AWSEmail!
  name: String!
  # Sensitive data requires ownership
  ssn: String @aws_auth(cognito_groups: ["admin"])
  # User can only access their own profile
  profile: UserProfile @aws_auth(cognito_groups: ["user"])
}

type Mutation {
  # Only authenticated users can create
  createUser(input: CreateUserInput!): User
    @aws_cognito_user_pools

  # Only admins can delete
  deleteUser(id: ID!): Boolean
    @aws_auth(cognito_groups: ["admin"])
}
```

### Authorization Patterns in Resolvers
```vtl
## Check user ownership
#if($context.identity.sub != $context.source.userId)
  $util.unauthorized()
#end

## Check admin role
#set($isAdmin = false)
#foreach($group in $context.identity.claims.get("cognito:groups"))
  #if($group == "admin")
    #set($isAdmin = true)
  #end
#end
#if(!$isAdmin)
  $util.unauthorized()
#end
```

## Data Source Integration Patterns

### Lambda Integration
```yaml
# Primary pattern: One Lambda per GraphQL operation
DataSource:
  Type: AWS_LAMBDA
  LambdaFunctionArn: !GetAtt UserManagementFunction.Arn
  ServiceRoleArn: !GetAtt AppSyncServiceRole.Arn

# Alternative: Single Lambda with operation routing
DataSource:
  Type: AWS_LAMBDA
  LambdaFunctionArn: !GetAtt GraphQLRouterFunction.Arn
```

### DynamoDB Direct Integration
```yaml
# Use for simple CRUD operations only
DataSource:
  Type: AMAZON_DYNAMODB
  TableName: !Ref UsersTable
  Region: !Ref AWS::Region
  ServiceRoleArn: !GetAtt AppSyncServiceRole.Arn
```

### RDS Integration
```yaml
# For relational data requirements
DataSource:
  Type: RELATIONAL_DATABASE
  RdsHttpEndpointConfig:
    AwsRegion: !Ref AWS::Region
    DbClusterIdentifier: !Ref AuroraCluster
    DatabaseName: !Ref DatabaseName
    Schema: public
  ServiceRoleArn: !GetAtt AppSyncServiceRole.Arn
```

## Real-time Subscriptions

### Subscription Design
```graphql
type Subscription {
  # User-specific updates
  onUserUpdated(userId: ID!): User
    @aws_subscribe(mutations: ["updateUser"])

  # Broadcast updates
  onOrderStatusChanged: Order
    @aws_subscribe(mutations: ["updateOrderStatus"])

  # Filtered subscriptions
  onInventoryAlert(threshold: Int!): InventoryItem
    @aws_subscribe(mutations: ["updateInventoryItem"])
}
```

### Subscription Authorization
```vtl
## Subscription request template
{
  "version": "2018-05-29",
  "payload": {
    "userId": "$context.arguments.userId",
    "requestingUser": "$context.identity.sub"
  }
}

## Response template with authorization check
#if($context.arguments.userId != $context.identity.sub)
  #if(!$context.identity.claims.get("cognito:groups").contains("admin"))
    $util.unauthorized()
  #end
#end
$util.toJson($context.arguments)
```

## Performance Optimization

### Query Complexity Analysis
```yaml
# Limit query depth and complexity
QueryDepthLimit: 10
QueryComplexityLimit: 1000
IntrospectionConfig: DISABLED  # For production
```

### Batch Operations
```graphql
# Implement batch operations for efficiency
type Mutation {
  batchCreateUsers(inputs: [CreateUserInput!]!): [User]
  batchUpdateUsers(updates: [BatchUpdateUserInput!]!): [User]
}

input BatchUpdateUserInput {
  id: ID!
  input: UpdateUserInput!
}
```

### DataLoader Pattern
```javascript
// Lambda function with DataLoader for N+1 prevention
const DataLoader = require('dataloader');

const userLoader = new DataLoader(async (userIds) => {
  const users = await batchGetUsers(userIds);
  return userIds.map(id => users.find(user => user.id === id));
});
```

## Monitoring and Logging

### CloudWatch Metrics
Monitor these key AppSync metrics:
- Request count and latency
- Error rates by resolver
- Cache hit/miss ratios
- Subscription connection counts

### X-Ray Tracing
```yaml
# Enable X-Ray for distributed tracing
XRayEnabled: true
```

### Custom Logging in Resolvers
```vtl
$util.log.info("Processing request for user: ${context.identity.sub}")
$util.log.error("Validation failed: ${error.message}")
```

## Deployment Patterns

### Infrastructure as Code
```yaml
# CloudFormation template structure
AWSTemplateFormatVersion: '2010-09-09'
Parameters:
  Environment:
    Type: String
    AllowedValues: [dev, staging, prod]

Resources:
  GraphQLApi:
    Type: AWS::AppSync::GraphQLApi
    Properties:
      Name: !Sub "${ProjectName}-GraphQL-API-${Environment}"
      AuthenticationType: AMAZON_COGNITO_USER_POOLS
      UserPoolConfig:
        UserPoolId: !Ref CognitoUserPool
        AwsRegion: !Ref AWS::Region
        DefaultAction: ALLOW
```

### Schema Deployment
```yaml
# Separate schema management
GraphQLSchema:
  Type: AWS::AppSync::GraphQLSchema
  Properties:
    ApiId: !GetAtt GraphQLApi.ApiId
    DefinitionS3Location:
      Bucket: !Ref SchemaDeploymentBucket
      Key: !Sub "schemas/${ProjectName}/${Environment}/schema.graphql"
```

## Security Best Practices

### API Key Management
- Use API keys only for development and testing
- Rotate API keys regularly
- Implement proper expiration policies

### Rate Limiting
```yaml
# Implement at the resolver level
RequestMappingTemplate: |
  #set($rateLimit = 100)  ## requests per minute
  #if($context.identity.rateLimit > $rateLimit)
    $util.error("Rate limit exceeded", "RateLimitError")
  #end
```

### Input Validation
```vtl
## Validate required fields
#if(!$context.arguments.input.email)
  $util.error("Email is required", "ValidationError")
#end

## Validate data types and formats
#if(!$util.matches("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$", $context.arguments.input.email))
  $util.error("Invalid email format", "ValidationError")
#end
```

## Testing Strategies

### Unit Testing Resolvers
```javascript
// Lambda resolver testing
const { handler } = require('./user-resolver');

test('should create user successfully', async () => {
  const event = {
    field: 'createUser',
    arguments: {
      input: {
        email: 'test@example.com',
        name: 'Test User'
      }
    },
    identity: { sub: 'user-123' }
  };

  const result = await handler(event);
  expect(result.email).toBe('test@example.com');
});
```

### Integration Testing
```javascript
// GraphQL endpoint testing
const { GraphQLClient } = require('graphql-request');

const client = new GraphQLClient(process.env.GRAPHQL_ENDPOINT, {
  headers: { Authorization: `Bearer ${authToken}` }
});

test('should execute mutation successfully', async () => {
  const mutation = `
    mutation CreateUser($input: CreateUserInput!) {
      createUser(input: $input) {
        id
        email
        name
      }
    }
  `;

  const result = await client.request(mutation, {
    input: { email: 'test@example.com', name: 'Test User' }
  });

  expect(result.createUser.email).toBe('test@example.com');
});
```

## Migration Strategy

### From REST to AppSync
1. **Parallel Implementation**: Implement AppSync alongside existing REST APIs
2. **Client Migration**: Gradually migrate client applications
3. **Feature Parity**: Ensure all REST functionality is available in GraphQL
4. **Performance Testing**: Validate performance meets or exceeds REST
5. **Deprecation**: Gradually deprecate REST endpoints

### Schema Evolution
```graphql
# Use deprecation for breaking changes
type User {
  id: ID!
  email: String!
  # Deprecated field with migration path
  fullName: String @deprecated(reason: "Use firstName and lastName instead")
  firstName: String
  lastName: String
}
```

## Cost Optimization

### Request Optimization
- Use query complexity analysis to prevent expensive operations
- Implement proper pagination to limit data transfer
- Cache frequently accessed data at the resolver level

### Resource Optimization
- Use provisioned capacity for predictable workloads
- Implement auto-scaling for Lambda functions
- Monitor and optimize resolver execution time

## Cross-Project Considerations

### Shared Types and Interfaces
```graphql
# Common types across projects
interface BaseEntity {
  id: ID!
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
  createdBy: String!
}

# Project-specific implementations
type VendoloopProduct implements BaseEntity {
  id: ID!
  createdAt: AWSDateTime!
  updatedAt: AWSDateTime!
  createdBy: String!
  sku: String!
  name: String!
  price: Float!
}
```

### Federation Considerations
For future multi-project integration, design schemas with federation in mind:

```graphql
# Use federation directives when needed
type User @key(fields: "id") {
  id: ID!
  email: String!
}

extend type User @key(fields: "id") {
  orders: [Order]
}
```

## Decision Framework

### When to Use AppSync
✅ **Use AppSync When**:
- Building client-facing applications
- Need real-time data capabilities
- Want type-safe API contracts
- Building mobile or web applications
- Need efficient data fetching

❌ **Consider Alternatives When**:
- Building simple internal APIs
- Need file uploads (use REST + S3 presigned URLs)
- Have legacy system integration requirements
- Building webhook endpoints

### Complexity Assessment
Before implementing complex resolvers or pipeline patterns:
1. Can this be simplified into direct Lambda integration?
2. Is the complexity justified by the use case?
3. Will this pattern scale with expected load?
4. Does it align with our cost optimization goals?

## Documentation Requirements

### API Documentation
- Maintain GraphQL schema as the primary API documentation
- Provide resolver implementation examples
- Document authentication and authorization patterns
- Include performance characteristics

### Change Management
- Document schema changes with migration notes
- Maintain changelog for API versions
- Communicate breaking changes in advance
- Provide client migration guides

## Implementation Checklist

### New AppSync API Setup
- [ ] Create AppSync API following naming conventions
- [ ] Configure authentication types (Cognito User Pools primary)
- [ ] Design GraphQL schema following standards
- [ ] Implement resolvers with proper error handling
- [ ] Configure data sources (Lambda functions)
- [ ] Set up monitoring and logging
- [ ] Implement subscription handling if needed
- [ ] Configure caching strategy
- [ ] Set up CI/CD pipeline for schema deployment
- [ ] Document API usage and patterns

### Security Verification
- [ ] Validate authentication configuration
- [ ] Test field-level authorization
- [ ] Verify input validation in resolvers
- [ ] Check rate limiting implementation
- [ ] Audit IAM roles and permissions
- [ ] Test subscription authorization

### Performance Validation
- [ ] Load test with expected traffic
- [ ] Validate query complexity limits
- [ ] Test caching behavior
- [ ] Monitor resolver execution times
- [ ] Verify efficient data fetching patterns

Remember: **AppSync as the unified API layer enables efficient, type-safe, and scalable client-server communication while maintaining clear project boundaries and cost optimization.**

## Cross-References

### Related Standards
- **[Authentication Standards](./06-authentication.md)** - Cognito integration patterns and configuration
- **[AWS Naming Standards](./01-aws-naming-standards.md)** - AppSync resource naming conventions
- **[Architecture Principles](./03-architecture-principles.md)** - AppSync alignment with core principles
- **[Multi-Tenancy Standards](./04-multi-tenancy.md)** - Tenant isolation in GraphQL resolvers

### External Documentation
- [AWS AppSync Developer Guide](https://docs.aws.amazon.com/appsync/)
- [GraphQL Specification](https://graphql.org/learn/)
- [AWS AppSync Security](https://docs.aws.amazon.com/appsync/latest/devguide/security.html)
- [Velocity Template Language (VTL) Reference](https://docs.aws.amazon.com/appsync/latest/devguide/resolver-context-reference.html)