---
name: flutter-api-contract
description: Discover and implement backend API contracts for Flutter features. Use whenever a feature requires a REST endpoint, request/response model, authentication, pagination, upload, or API error handling.
---

# API Contract Workflow

Before API implementation, identify:

- endpoint/path
- HTTP method
- authentication
- headers
- path/query parameters
- request body
- required/optional fields
- types/enums
- validation
- success response
- error response/status codes
- pagination
- multipart/file upload
- token/refresh behavior

## Unknown contract

Do not invent an API silently.

Ask for the API documentation/Postman collection/example when necessary.

If a proposal is useful, label it clearly as a proposed contract and wait for confirmation before tightly coupling implementation to it.

## Implementation

Follow:

`ViewModel/Notifier → UseCase → Repository → DataSource → HTTP client`

Keep transport details in the data layer.

Reuse existing network infrastructure and models.

Do not create duplicate response models.

## Security

Never log tokens, passwords, or sensitive payloads.

Treat API responses as untrusted input.

Client validation does not replace backend authorization.
