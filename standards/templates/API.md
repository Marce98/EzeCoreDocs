# {Project Name} API Documentation

> Version: {VERSION}
> Last Updated: {DATE}

## Base URL
```
Production: https://api.example.com/v1
Staging: https://staging-api.example.com/v1
Development: http://localhost:3000/api/v1
```

## Authentication

### API Key Authentication
Include API key in request header:
```http
X-API-Key: your-api-key-here
```

### Bearer Token Authentication
Include JWT token in Authorization header:
```http
Authorization: Bearer your-jwt-token-here
```

### Token Refresh
```http
POST /auth/refresh
Content-Type: application/json

{
  "refresh_token": "your-refresh-token"
}
```

## Common Headers

| Header | Required | Description |
|--------|----------|-------------|
| `Content-Type` | Yes | `application/json` for all requests with body |
| `Accept` | No | `application/json` (default) |
| `X-Request-ID` | No | Unique request identifier for tracking |
| `X-API-Version` | No | Specific API version override |

## Response Format

### Success Response
```json
{
  "success": true,
  "data": {
    // Response data
  },
  "meta": {
    "timestamp": "2024-01-01T00:00:00Z",
    "version": "1.0.0"
  }
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "ERROR_CODE",
    "message": "Human-readable error message",
    "details": {
      // Additional error information
    }
  },
  "meta": {
    "timestamp": "2024-01-01T00:00:00Z",
    "request_id": "unique-request-id"
  }
}
```

## Status Codes

| Code | Description |
|------|-------------|
| 200 | Success |
| 201 | Created |
| 204 | No Content |
| 400 | Bad Request |
| 401 | Unauthorized |
| 403 | Forbidden |
| 404 | Not Found |
| 429 | Too Many Requests |
| 500 | Internal Server Error |

## Rate Limiting

- **Default limit:** 1000 requests per hour
- **Authenticated limit:** 5000 requests per hour

Rate limit information in response headers:
```http
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1609459200
```

## Endpoints

### Authentication

#### Login
```http
POST /auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "secure-password"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "token": "jwt-token",
    "refresh_token": "refresh-token",
    "expires_in": 3600,
    "user": {
      "id": "user-id",
      "email": "user@example.com",
      "name": "User Name"
    }
  }
}
```

### Users

#### List Users
```http
GET /users?page=1&limit=20&sort=created_at&order=desc
```

**Query Parameters:**
| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| page | integer | 1 | Page number |
| limit | integer | 20 | Items per page (max: 100) |
| sort | string | created_at | Sort field |
| order | string | asc | Sort order (asc/desc) |

**Response:**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "user-id",
        "email": "user@example.com",
        "name": "User Name",
        "created_at": "2024-01-01T00:00:00Z"
      }
    ],
    "pagination": {
      "page": 1,
      "limit": 20,
      "total": 100,
      "pages": 5
    }
  }
}
```

#### Get User
```http
GET /users/{id}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "user-id",
    "email": "user@example.com",
    "name": "User Name",
    "profile": {
      "bio": "User bio",
      "avatar_url": "https://example.com/avatar.jpg"
    },
    "created_at": "2024-01-01T00:00:00Z",
    "updated_at": "2024-01-02T00:00:00Z"
  }
}
```

#### Create User
```http
POST /users
Content-Type: application/json

{
  "email": "newuser@example.com",
  "password": "secure-password",
  "name": "New User",
  "profile": {
    "bio": "User bio"
  }
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "new-user-id",
    "email": "newuser@example.com",
    "name": "New User",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

#### Update User
```http
PUT /users/{id}
Content-Type: application/json

{
  "name": "Updated Name",
  "profile": {
    "bio": "Updated bio"
  }
}
```

#### Delete User
```http
DELETE /users/{id}
```

### Resources

#### Search Resources
```http
POST /resources/search
Content-Type: application/json

{
  "query": "search terms",
  "filters": {
    "category": "technology",
    "date_range": {
      "start": "2024-01-01",
      "end": "2024-12-31"
    }
  },
  "pagination": {
    "page": 1,
    "limit": 20
  }
}
```

### Batch Operations

#### Batch Create
```http
POST /batch/users
Content-Type: application/json

{
  "operations": [
    {
      "method": "POST",
      "data": {
        "email": "user1@example.com",
        "name": "User 1"
      }
    },
    {
      "method": "POST",
      "data": {
        "email": "user2@example.com",
        "name": "User 2"
      }
    }
  ]
}
```

## Webhooks

### Webhook Events
- `user.created`
- `user.updated`
- `user.deleted`
- `resource.created`
- `resource.updated`

### Webhook Payload
```json
{
  "event": "user.created",
  "timestamp": "2024-01-01T00:00:00Z",
  "data": {
    // Event-specific data
  },
  "signature": "webhook-signature"
}
```

### Webhook Signature Verification
```python
import hmac
import hashlib

def verify_webhook(payload, signature, secret):
    expected = hmac.new(
        secret.encode(),
        payload.encode(),
        hashlib.sha256
    ).hexdigest()
    return hmac.compare_digest(expected, signature)
```

## WebSocket API

### Connection
```javascript
const ws = new WebSocket('wss://api.example.com/ws');

ws.onopen = () => {
  ws.send(JSON.stringify({
    type: 'auth',
    token: 'your-jwt-token'
  }));
};
```

### Message Format
```json
{
  "type": "message-type",
  "data": {
    // Message data
  },
  "timestamp": "2024-01-01T00:00:00Z"
}
```

## Error Codes

| Code | Description | Resolution |
|------|-------------|------------|
| `AUTH_001` | Invalid credentials | Check email/password |
| `AUTH_002` | Token expired | Refresh token |
| `VALIDATION_001` | Missing required field | Check request body |
| `VALIDATION_002` | Invalid field format | Validate input format |
| `RESOURCE_001` | Resource not found | Check resource ID |
| `RATE_LIMIT_001` | Rate limit exceeded | Wait and retry |

## SDKs and Libraries

### JavaScript/TypeScript
```bash
npm install @example/api-client
```

```javascript
import { ApiClient } from '@example/api-client';

const client = new ApiClient({
  apiKey: 'your-api-key'
});

const users = await client.users.list();
```

### Python
```bash
pip install example-api-client
```

```python
from example_api import Client

client = Client(api_key='your-api-key')
users = client.users.list()
```

## Testing

### Test Environment
Base URL: `https://sandbox.api.example.com/v1`

Test credentials:
- Email: `test@example.com`
- Password: `test123`
- API Key: `test-api-key`

### Postman Collection
Download: [API Postman Collection](./postman-collection.json)

## Changelog

### Version 1.1.0 (2024-01-15)
- Added batch operations endpoint
- Improved error responses
- Added webhook support

### Version 1.0.0 (2024-01-01)
- Initial API release
- Basic CRUD operations
- Authentication system

## Support

- Email: api-support@example.com
- Documentation: https://docs.example.com
- Status Page: https://status.example.com