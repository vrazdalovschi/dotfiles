---
name: writing-openapi-specs
description: Use when writing, reviewing, or generating OpenAPI specifications, extracting specs from existing APIs, setting up spec validation, or converting schemas to TypeScript types. Triggers on OpenAPI, Swagger, API spec, API documentation, API contract, schema generation.
---

# Writing OpenAPI Specs

Reference for writing, extracting, validating, and generating code from OpenAPI 3.x specifications.

## When to Use

- Writing or improving an OpenAPI specification
- Extracting a spec from existing API code
- Expressing complex types (polymorphism, nullable, file uploads, SSE)
- Setting up spec validation and linting
- Generating TypeScript types or SDKs from a spec

**Not for:** API design strategy, REST vs GraphQL decisions, or runtime API testing.

## Naming Conventions

Pick one convention and be consistent. Common choices:

| Element | Convention | Example |
|---------|-----------|---------|
| Operation IDs | `snake_case` or `camelCase` | `users_list` / `usersList` |
| Component names | `PascalCase` | `UserProfile`, `OrderHistory` |
| Tags | `kebab-case` or Title Case | `user-management` / `User Management` |
| Enum values | `snake_case` or `SCREAMING_SNAKE` | `pending` / `PENDING` |

## Documentation & Reusability

All `description` fields support CommonMark. Be specific and actionable:

```yaml
description: Returns a paginated list of active users, ordered by creation date (newest first)
# not: "Gets users"
```

Use `examples` (plural) over `example` for better SDK generation. Extract to `components` when used in 2+ operations; keep one-off schemas inline.

## Common Patterns

### Polymorphism

| Keyword | Meaning | Use Case |
|---------|---------|----------|
| `oneOf` | Exactly one schema | Type discrimination (use with `discriminator`) |
| `allOf` | All schemas | Composition / inheritance |
| `anyOf` | One or more schemas | Flexible union |

```yaml
# oneOf with discriminator -- each sub-schema MUST have the discriminator property
PaymentMethod:
  oneOf:
    - $ref: '#/components/schemas/CreditCard'
    - $ref: '#/components/schemas/BankAccount'
  discriminator:
    propertyName: type
    mapping:
      credit_card: '#/components/schemas/CreditCard'
      bank_account: '#/components/schemas/BankAccount'
CreditCard:
  type: object
  required: [type]
  properties:
    type: { type: string, enum: [credit_card] }
    last4: { type: string }

# allOf for composition
AdminUser:
  allOf:
    - $ref: '#/components/schemas/User'
    - type: object
      properties:
        permissions:
          type: array
          items: { type: string }
```

### Nullable Types

```yaml
# OpenAPI 3.1                    # OpenAPI 3.0
type: [string, "null"]           type: string
                                 nullable: true
```

### File Uploads

```yaml
requestBody:
  content:
    multipart/form-data:
      schema:
        type: object
        properties:
          file: { type: string, format: binary }
        required: [file]
```

### Server-Sent Events

```yaml
responses:
  '200':
    description: SSE stream
    content:
      text/event-stream:
        schema:
          type: string
    headers:
      Content-Type: { schema: { type: string, enum: [text/event-stream] } }
      Cache-Control: { schema: { type: string, enum: [no-cache] } }
```

### Pagination

```yaml
components:
  schemas:
    Pagination:
      type: object
      required: [page, limit, total]
      properties:
        page: { type: integer, minimum: 1 }
        limit: { type: integer, minimum: 1, maximum: 100 }
        total: { type: integer, minimum: 0 }
  parameters:
    PageParam:
      name: page
      in: query
      schema: { type: integer, minimum: 1, default: 1 }
    LimitParam:
      name: limit
      in: query
      schema: { type: integer, minimum: 1, maximum: 100, default: 20 }
```

### Error Responses

```yaml
components:
  schemas:
    Error:
      type: object
      required: [code, message]
      properties:
        code: { type: string }
        message: { type: string }
        details:
          type: array
          items:
            type: object
            properties:
              field: { type: string }
              message: { type: string }
  responses:
    BadRequest:
      description: Invalid request
      content:
        application/json:
          schema: { $ref: '#/components/schemas/Error' }
    NotFound:
      description: Resource not found
      content:
        application/json:
          schema: { $ref: '#/components/schemas/Error' }
```

## Extracting Specs from Code

Use framework tooling instead of hand-writing specs for existing APIs:

| Framework | Command | Server? |
|-----------|---------|:---:|
| FastAPI | `python -c "from app import app; print(app.openapi())" > openapi.json` | No |
| Flask (flask-smorest) | `curl localhost:5000/openapi.json -o openapi.json` | Yes |
| Django (drf-spectacular) | `python manage.py spectacular --file openapi.yaml` | No |
| Spring Boot (springdoc) | `curl localhost:8080/v3/api-docs -o openapi.json` | Yes |
| NestJS (@nestjs/swagger) | `curl localhost:3000/api-json -o openapi.json` | Yes |
| Hono (zod-openapi) | Programmatic export via script | No |
| Rails (rswag) | `rails rswag:specs:swaggerize` | No |
| Laravel (l5-swagger) | `php artisan l5-swagger:generate` | No |

Never edit extracted specs directly -- use overlays so re-extraction preserves fixes.

## Validation & Linting

### Spectral

```bash
npm install -g @stoplight/spectral-cli
spectral lint openapi.yaml
```

Minimal `.spectral.yaml`:

```yaml
extends: ["spectral:oas"]
rules:
  operation-operationId: error
  operation-security-defined: error
  operation-success-response: error
```

### Redocly

```bash
npm install -g @redocly/cli
redocly lint openapi.yaml
redocly preview-docs openapi.yaml    # live preview
redocly bundle openapi.yaml -o bundled.yaml
```

## TypeScript Generation

### Type Mapping (non-obvious)

| OpenAPI | TypeScript |
|---------|-----------|
| `integer` | `number` |
| `string` + `enum: [a, b]` | `"a" \| "b"` |
| `$ref: "#/.../Product"` | `Product` (reference, don't inline) |
| `oneOf: [Cat, Dog]` | `Cat \| Dog` |
| `allOf: [Base, Extra]` | `Base & { ...extra }` (intersection type) |
| `format: uuid/date-time/email/uri` | `string` (add JSDoc comment) |

### Generated Output (openapi-typescript)

```typescript
/** Auto-generated from openapi.json -- DO NOT EDIT */

export type UserRole = "admin" | "user";

export interface User {
  /** UUID */
  id: string;
  email: string;
  role: UserRole;
  createdAt?: string;  // not in required[] = optional
}
```

Optional custom type guard (not generated by tools, write alongside):

```typescript
export function isUser(value: unknown): value is User {
  return (
    typeof value === "object" && value !== null &&
    "id" in value && typeof (value as any).id === "string" &&
    "role" in value && ["admin", "user"].includes((value as any).role)
  );
}
```

Tools: `openapi-typescript` (npm), `openapi-generator-cli` (`-g typescript-fetch`, `python`, `go`, `java`, `kotlin`, `swift5`, `rust`).

## Common Pitfalls

| Mistake | Fix |
|---------|-----|
| Missing `operationId` | SDK generates ugly path-derived names (`getApiV2UsersUserId`). Always define. |
| `example` (singular) | Use `examples` (plural) with named entries |
| No `discriminator` on `oneOf` | Generators produce less ergonomic types; add when schemas share a type field |
| No `required` arrays | Be explicit -- affects SDK method signatures |
| No `format` on strings | Set `uuid`, `date-time`, `email`, `uri` for better types |
| Everything inline | Extract shared schemas to `components` |
| Everything in `components` | Keep one-off schemas inline |
| Generic descriptions | Write specific, actionable descriptions |
| Missing error responses | Document all error codes with schema |
| No security schemes | Define auth even if handled externally |
| `additionalProperties: true` | Produces `Record<string, unknown>` in SDKs. Omit or set `false`. |
| Editing extracted specs | Use overlays so re-extraction preserves fixes |
