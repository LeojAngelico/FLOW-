---
name: flutter-api-contract
description: Discover and implement backend API contracts for Flutter features. Use whenever a feature requires a REST endpoint, request/response model, authentication, pagination, upload, or API error handling.
---

# API Contract

For this project's HTTP client, interceptors, request and response
class conventions, and error-mapping type, read
`docs/PROJECT_MAP.md` § Network Layer. Do not rediscover them by
reading the data layer.

## Before coupling to a backend

Identify: path and method; authentication and headers; path and query
parameters; request body with required and optional fields; types,
enums and validation; the success response; error responses and status
codes; pagination; upload handling; and token refresh behaviour.

## When the contract is unknown

Do not invent an API, and do not proceed quietly on a guess.

Ask for documentation, a collection export, or a sample response. If a
proposal is useful, label it explicitly as proposed and get
confirmation before coupling implementation to it.

An implementation built on a guessed contract is worse than no
implementation, because it looks finished.

## Implementation

Transport details stay in the data layer. Reuse the existing client and
interceptors; do not construct a second one. Do not add a duplicate
response model for a shape that is already parsed somewhere.

Map errors through the project's existing error type rather than
letting a transport exception reach a Notifier.

## Security

Never log tokens, credentials or sensitive payloads. Treat every
response as untrusted input. Client-side validation is not
authorization.
