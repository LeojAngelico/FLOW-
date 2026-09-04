---
name: flutter-security
description: Perform secure-by-default reviews and implementations for Flutter features. Use for authentication, tokens, sensitive data, local storage, API calls, files, deep links, logging, analytics, permissions, and security-sensitive flows.
---

# Security Review

For where this project stores credentials and how it maps errors, read
`docs/PROJECT_MAP.md` § Network Layer.

For every feature, ask:

- What data is sensitive?
- Who is authorized?
- Where is the data stored?
- Is the network protected?
- Can input be manipulated?
- Can sensitive data leak through logs/analytics/errors?
- Does this depend on backend authorization?
- Are platform permissions appropriate?
- Does a dependency introduce native/security risk?

## Rules

Use secure storage for sensitive credentials/tokens.

Treat user input, API responses, files, deep links, and notification payloads as untrusted.

Do not expose sensitive information unnecessarily through logs, analytics, screenshots, notifications, or error messages.

Client-side checks are not authorization.

Clearly flag controls that require backend/infrastructure support.
