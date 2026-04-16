# Auth API Contracts

This document describes the expected REST API endpoints that the auth feature communicates with.

## Base URL

Configure in `AuthService._baseUrl` (defaults to `https://your-api.example.com/api`).

---

## POST /auth/login

Login with email and password.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "secret123"
}
```

**Success Response (200):**
```json
{
  "data": {
    "id": "abc123",
    "email": "user@example.com",
    "name": "John Doe",
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Error Response (401 / 400):**
```json
{
  "message": "Invalid email or password"
}
```

---

## POST /auth/register

Register a new account.

**Request Body:**
```json
{
  "name": "John Doe",
  "email": "user@example.com",
  "password": "secret123"
}
```

**Success Response (201):**
```json
{
  "data": {
    "id": "abc123",
    "email": "user@example.com",
    "name": "John Doe",
    "token": "eyJhbGciOiJIUzI1NiIs..."
  }
}
```

**Error Response (400 / 409):**
```json
{
  "message": "Email already in use"
}
```

---

## POST /auth/logout

Invalidate the current token.

**Headers:**
```
Authorization: Bearer <token>
```

**Success Response (200):**
```json
{
  "message": "Logged out"
}
```

---

## GET /auth/me

Validate the current token and get user info.

**Headers:**
```
Authorization: Bearer <token>
```

**Success Response (200):**
```json
{
  "data": {
    "id": "abc123",
    "email": "user@example.com",
    "name": "John Doe"
  }
}
```

**Error Response (401):**
```json
{
  "message": "Invalid or expired token"
}
```
