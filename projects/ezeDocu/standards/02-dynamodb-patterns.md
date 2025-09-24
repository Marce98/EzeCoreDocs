# DynamoDB Design Patterns

## Overview
We follow a **single table design** approach for DynamoDB to optimize performance and reduce costs. This document outlines our patterns for multi-tenant, multi-location data modeling.

## Single Table Design Principles

### Why Single Table?
- **Reduced costs** - Fewer tables mean lower base costs
- **Simplified operations** - Single point of management
- **Atomic transactions** - Can span multiple entity types
- **Optimized queries** - Fetch related data in one request

### When to Use Single Table
- Related entities frequently queried together
- Need for strong consistency across entities
- Cost optimization is priority
- Predictable access patterns

### When to Consider Multiple Tables
- Completely unrelated domains
- Different scaling requirements
- Different backup/recovery needs
- Regulatory data isolation requirements

## Key Structure Patterns

### Partition Key (PK) Design
Our standard multi-tenant partition key follows this hierarchy:

**Pattern**: `PLATFORM#[platform]#COMPANY#[companyCode]#LOCATION#[locationCode]`

**Examples**:
```
PK: "PLATFORM#vendoloop#COMPANY#GENR844848#LOCATION#greenville"
PK: "PLATFORM#vendoloop#COMPANY#winebb#LOCATION#hq"
PK: "PLATFORM#ezecore#COMPANY#shared#LOCATION#global"
```

### Sort Key (SK) Patterns
Sort keys identify entity types and enable efficient queries:

#### Entity Metadata
```
SK: "METADATA"
```
Used for company or location configuration data

#### Inventory Items
```
SK: "INVENTORY#UPC#00080686009962"
SK: "INVENTORY#SKU#WINE-RED-750ML"
```

#### Customer Records
```
SK: "CUSTOMER#12345"
SK: "CUSTOMER#EMAIL#john@example.com"
```

#### Transactions/Orders
```
SK: "ORDER#2024-01-15#ORD-789"
SK: "TRANSACTION#2024-01-15T10:30:00Z"
```

#### Relationships
```
SK: "REL#CUSTOMER#12345#PURCHASE#67890"
SK: "REL#PRODUCT#UPC123#SUPPLIER#SUP456"
```

## Entity Examples

### Company Entity
```json
{
  "PK": "PLATFORM#vendoloop#COMPANY#GENR844848",
  "SK": "METADATA",
  "entityType": "COMPANY",
  "companyName": "Wine & Beverage Co",
  "taxId": "XX-XXXXXXX",
  "status": "active",
  "createdAt": "2024-01-01T00:00:00Z",
  "settings": {
    "currency": "USD",
    "timezone": "America/New_York"
  }
}
```

### Location Entity
```json
{
  "PK": "PLATFORM#vendoloop#COMPANY#GENR844848",
  "SK": "LOCATION#greenville",
  "entityType": "LOCATION",
  "locationName": "Greenville Store",
  "address": {
    "street": "123 Main St",
    "city": "Greenville",
    "state": "SC",
    "zip": "29601"
  },
  "managerId": "USR-001",
  "operatingHours": {}
}
```

### Product/Inventory Entity
```json
{
  "PK": "PLATFORM#vendoloop#COMPANY#winebb#LOCATION#greenville",
  "SK": "INVENTORY#UPC#00080686009962",
  "entityType": "PRODUCT",
  "productName": "Cabernet Sauvignon 2020",
  "category": "RED_WINE",
  "quantity": 24,
  "unitPrice": 29.99,
  "reorderPoint": 10,
  "supplier": "SUP-123",
  "lastUpdated": "2024-01-15T10:00:00Z"
}
```

### Customer with Preferences (Composite Entity)
```json
{
  "PK": "PLATFORM#vendoloop#COMPANY#winebb#LOCATION#greenville",
  "SK": "CUSTOMER#CUST-789",
  "entityType": "CUSTOMER_PROFILE",
  "customerId": "CUST-789",
  "name": "John Doe",
  "email": "john@example.com",
  "preferences": {
    "wineType": ["red", "white"],
    "priceRange": "medium",
    "notifications": true
  },
  "purchaseHistory": {
    "totalOrders": 15,
    "totalSpent": 1250.00,
    "lastPurchase": "2024-01-10"
  },
  "loyaltyPoints": 250
}
```

## Access Patterns

### Pattern 1: Get All Locations for a Company
```
Query: PK = "PLATFORM#vendoloop#COMPANY#GENR844848"
       SK begins_with "LOCATION#"
```

### Pattern 2: Get All Inventory for a Location
```
Query: PK = "PLATFORM#vendoloop#COMPANY#winebb#LOCATION#greenville"
       SK begins_with "INVENTORY#"
```

### Pattern 3: Get Customer and Purchase History
```
Query: PK = "PLATFORM#vendoloop#COMPANY#winebb#LOCATION#greenville"
       SK = "CUSTOMER#CUST-789"
```

### Pattern 4: Get All Entities for a Location
```
Query: PK = "PLATFORM#vendoloop#COMPANY#winebb#LOCATION#greenville"
```

## Global Secondary Indexes (GSI)

### GSI1: Entity Type Index
- **PK**: `entityType`
- **SK**: Original PK
- **Use**: Query all entities of a specific type across tenants

### GSI2: Temporal Index
- **PK**: `PLATFORM#[platform]#DATE#[YYYY-MM-DD]`
- **SK**: `timestamp`
- **Use**: Time-based queries for transactions, logs

### GSI3: Search Index
- **PK**: `PLATFORM#[platform]#SEARCH#[attribute]`
- **SK**: `[value]#[originalPK]`
- **Use**: Search by email, phone, or other attributes

## Best Practices

### 1. Item Size Management
- Keep items under 400KB
- Store large objects in S3 with reference in DynamoDB
- Compress JSON attributes when needed

### 2. Hot Partition Prevention
- Distribute writes across partitions
- Use write sharding for high-volume data
- Consider partition key randomization for extreme cases

### 3. Cost Optimization
- Use on-demand billing for prototype/development
- Switch to provisioned capacity for predictable workloads
- Implement item expiration (TTL) for temporary data

### 4. Query Optimization
- Design partition keys for even distribution
- Minimize item collection size
- Use projection expressions to reduce data transfer

### 5. Data Consistency
- Use transactions for multi-item updates
- Implement optimistic locking with version numbers
- Consider eventual consistency for read-heavy workloads

## Migration Considerations

### From Relational Database
1. Identify access patterns
2. Denormalize data appropriately
3. Duplicate data where needed for query efficiency
4. Maintain referential integrity at application level

### Adding New Entity Types
1. Define SK pattern
2. Document access patterns
3. Update GSIs if needed
4. Test query performance

## Exception Handling
When deviating from single table design:
1. Document the technical justification
2. Define separate table naming convention
3. Establish data synchronization strategy if needed
4. Consider impact on transactions and consistency