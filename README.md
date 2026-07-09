# 🔐 Auth Service + HRM App (Microservices Architecture)

A **centralized authentication system** with a separate **HRM application**, demonstrating how multiple apps can share a single authentication service while maintaining independent databases and business logic.

**Architecture:** Auth Service handles all authentication → HRM (and future apps like CRM) verify tokens locally and manage their own data.

---

## 🏗️ Architecture Overview

```
┌─────────────────────┐
│   Auth Service      │  ← Handles signup, login, refresh, logout
│   Port: 5000        │  ← Stores users, passwords, refresh tokens
└──────────┬──────────┘
           │
           │ JWT tokens (encrypted + signed)
           │
    ┌──────┴──────┬─────────────┐
    │             │             │
┌───▼────┐   ┌───▼────┐   ┌───▼────┐
│  HRM   │   │  CRM   │   │ Future │
│ :5001  │   │ :5002  │   │  Apps  │
└────────┘   └────────┘   └────────┘
     │            │            │
  HRM DB       CRM DB      Other DBs
```

**Key Points:**
- One Auth Service, multiple apps
- Each app has its own database
- Tokens verified locally (no constant Auth Service calls)
- Just-in-time user provisioning

---

## 🚀 Tech Stack

- **Node.js + Express** – Backend framework
- **PostgreSQL** – Relational database (separate DB per service)
- **Prisma ORM** – Type-safe database access
- **JWT (RSA-256 + JWE encryption)** – Authentication tokens
- **httpOnly Cookies** – Secure token storage
- **bcryptjs** – Password hashing
- **jose** – JWT signing and encryption

---

## ✨ Features

### Auth Service
- User registration with client validation
- Secure login with encrypted JWT tokens
- Refresh token rotation
- Token verification endpoint
- Logout with token revocation
- Client management (HRM, CRM apps registered as clients)

### HRM App
- JWT verification middleware (local, no network calls)
- Just-in-time user provisioning
- User-specific salary management (CRUD)
- Auto token refresh on expiry
- Independent business logic and database

---

## 📁 Project Structure

### Auth Service
```
authService/
├── config/
│   ├── config.js
│   ├── db.js
│   └── prisma.js
├── controllers/
│   └── auth.controller.js
├── middlewares/
│   ├── errorHandler.js
│   ├── validateClient.js
│   └── ...
├── repositories/
│   ├── user.repository.js
│   ├── client.repository.js
│   └── refreshToken.repository.js
├── services/
│   └── auth.service.js
├── routes/
│   ├── auth.routes.js
│   └── index.routes.js
├── scripts/
│   ├── setup-keys.js
│   └── seed-clients.js
├── keys/                    # JWT keys (gitignored)
├── prisma/
│   └── schema.prisma
├── utils/
│   ├── jwt.utils.js
│   └── responseHandler.js
├── validations/
│   └── auth.validation.js
└── server.js
```

### HRM App
```
HRM_AuthApp/
├── config/
│   ├── config.js
│   ├── db.js
│   └── prisma.js
├── controllers/
│   ├── auth.controller.js
│   └── salary.controller.js
├── middlewares/
│   ├── auth.middleware.js   # Token verification
│   └── errorHandler.js
├── repositories/
│   ├── user.repository.js
│   └── salary.repository.js
├── services/
│   ├── auth.service.js
│   └── salary.service.js
├── routes/
│   ├── auth.routes.js
│   ├── salary.routes.js
│   └── index.routes.js
├── keys/                    # Same JWT keys as Auth Service
├── prisma/
│   └── schema.prisma
├── utils/
│   ├── jwt.utils.js         # Verify only, no signing
│   └── responseHandler.js
└── server.js
```

---

## 🔧 Setup Instructions

### Prerequisites
- Node.js (v18+)
- PostgreSQL
- npm or yarn

---

### 1️⃣ Clone the Repository

```bash
git clone https://github.com/rohan-serviots/Multi-Auth.git
cd Multi-Auth
```

---

### 2️⃣ Setup Auth Service

#### Generate JWT Keys

```bash
cd Multi-Auth
npm install
npm run setup-keys
```

This generates RSA key pairs:
```
keys/private.key
keys/public.key
keys/private_env.txt
keys/public_env.txt
```

⚠️ **Never commit `keys/` folder** (already in `.gitignore`)

---

#### Configure Environment

```bash
cp .env.example .env
```

Edit `.env` and paste the key values from `keys/*_env.txt`:

```env
PORT=5000
NODE_ENV=development
DOMAIN=http://localhost

DATABASE_URL=postgresql://user:password@localhost:5432/auth_service

JWT_PRIVATE_KEY=<paste from keys/private_env.txt>
JWT_PUBLIC_KEY=<paste from keys/public_env.txt>
JWT_ACCESS_TOKEN_EXPIRE=900        # 15 minutes
JWT_REFRESH_TOKEN_EXPIRE=604800    # 7 days

# Client credentials (set these before seeding)
HRM_CLIENT_ID=hrm-app
HRM_CLIENT_SECRET=hrm-super-secret-key-change-in-production
CRM_CLIENT_ID=crm-app
CRM_CLIENT_SECRET=crm-super-secret-key-change-in-production

COOKIE_DOMAIN=                      # Empty for localhost, .yourcompany.com for production
```

---

#### Setup Database

Create PostgreSQL database:
```sql
CREATE DATABASE auth_service;
```

Run migrations:
```bash
npx prisma migrate dev
npx prisma generate
```

---

#### Seed Clients

```bash
npm run seed:clients
```

This creates HRM and CRM as registered clients in the Auth DB.

---

#### Start Auth Service

```bash
npm run dev
```

Auth Service runs at: **http://localhost:5000** (or http://127.0.0.1:5000)

---

### 3️⃣ Setup HRM App

#### Copy JWT Keys

**Important:** HRM needs the **same keys** as Auth Service.

```bash
cd ../Multi-Auth-Archtecture
mkdir keys
cp ../Multi-Auth-Archtecture/keys/* ./keys/
```

---

#### Install Dependencies

```bash
npm install
```

---

#### Configure Environment

```bash
cp .env.example .env
```

Edit `.env`:

```env
PORT=5001
NODE_ENV=development
DOMAIN=http://localhost

DATABASE_URL=postgresql://user:password@localhost:5432/hrm_db

# Auth Service connection
AUTH_SERVICE_URL=http://localhost:5000
CLIENT_ID=hrm-app
CLIENT_SECRET=hrm-super-secret-key-change-in-production

# JWT keys (same as Auth Service)
JWT_PRIVATE_KEY=<paste from keys/private_env.txt>
JWT_PUBLIC_KEY=<paste from keys/public_env.txt>

COOKIE_DOMAIN=                      # Empty for localhost
```

---

#### Setup Database

Create PostgreSQL database:
```sql
CREATE DATABASE hrm_db;
```

Run migrations:
```bash
npx prisma migrate dev
npx prisma generate
```

---

#### Start HRM App

```bash
npm run dev
```

HRM runs at: **http://localhost:5001** (or http://127.0.0.1:5001)

---

## 📚 API Endpoints

### Auth Service (Port 5000)

| Method | Endpoint | Headers Required | Description |
|--------|----------|------------------|-------------|
| POST | `/auth/signup` | `x-client-id`, `x-client-secret` | Register new user |
| POST | `/auth/login` | `x-client-id`, `x-client-secret` | Login user |
| GET | `/auth/verify` | Cookie | Verify access token |
| POST | `/auth/refresh` | Cookie | Refresh tokens |
| POST | `/auth/logout` | Cookie | Logout user |

### HRM App (Port 5001)

| Method | Endpoint | Protected | Description |
|--------|----------|-----------|-------------|
| GET | `/auth/me` | ✅ | Get current user (auto-provision) |
| POST | `/auth/logout` | ✅ | Logout from HRM |
| GET | `/salaries` | ✅ | Get user's salary records |
| POST | `/salaries` | ✅ | Create salary record |
| GET | `/salaries/:id` | ✅ | Get single salary record |
| PUT | `/salaries/:id` | ✅ | Update salary record |
| DELETE | `/salaries/:id` | ✅ | Delete salary record |

---

## 🔐 Authentication Flow

### Registration & Login
```
1. User registers at Auth Service
   → Auth DB stores user + hashed password

2. User logs in at Auth Service
   → Access token (15 min) + Refresh token (7 days) set as cookies
   → Tokens contain: userId, clientId, name, email, isActive

3. User accesses HRM
   → HRM verifies token locally (no Auth Service call)
   → Checks if user exists in HRM DB
   → If not, creates user (just-in-time provisioning)
   → Returns HRM-specific data
```

### Token Verification (Every Request)
```
User hits protected route in HRM
→ Middleware extracts token from cookie
→ Decrypts using private key (local)
→ Verifies signature using public key (local)
→ Checks expiry, clientId, isActive
→ All checks pass → request proceeds
→ Any check fails → 401 Unauthorized
```

### Auto Token Refresh
```
Access token expires after 15 minutes
→ HRM middleware catches expiry error
→ Automatically calls Auth Service /refresh
→ Auth Service validates refresh token
→ Checks user still active in DB
→ Issues new tokens
→ HRM retries original request
→ User never notices
```

---

## 🧪 Testing Flow (Postman)

**Important:** Use `127.0.0.1` consistently (not `localhost`) for cookies to work.

### 1. Register
```
POST http://127.0.0.1:5000/auth/signup

Headers:
  x-client-id: hrm-app
  x-client-secret: hrm-super-secret-key-change-in-production

Body:
{
  "name": "John Doe",
  "email": "john@example.com",
  "password": "Test@1234"
}
```

### 2. Login
```
POST http://127.0.0.1:5000/auth/login

Headers:
  x-client-id: hrm-app
  x-client-secret: hrm-super-secret-key-change-in-production

Body:
{
  "email": "john@example.com",
  "password": "Test@1234"
}

→ Cookies set automatically
```

### 3. Access HRM (First Time)
```
GET http://127.0.0.1:5001/auth/me

→ User auto-created in HRM DB
→ Returns HRM profile
```

### 4. Create Salary Record
```
POST http://127.0.0.1:5001/salaries

Body:
{
  "amount": 75000,
  "currency": "USD",
  "effectiveDate": "2024-01-01",
  "notes": "Annual salary 2024"
}
```

### 5. Get Salaries
```
GET http://127.0.0.1:5001/salaries

→ Returns all salary records for logged-in user
```

---

## 🔒 Security Features

- **RSA-256 JWT signing** – Asymmetric encryption
- **JWE encryption** – Tokens are encrypted, not just signed
- **httpOnly cookies** – Protected from XSS attacks
- **Client authentication** – Only registered apps can use Auth Service
- **Token payload validation** – clientId, isActive checked on every request
- **Refresh token rotation** – Old token revoked when new one issued
- **Password hashing** – bcrypt with salt rounds
- **User ownership enforcement** – Users can only access their own data

---

## 🛡️ Database Design

### Auth Service DB
```
Users           → id, email, password (hashed), isActive, isDeleted
Clients         → clientId, clientName, clientSecret (hashed), isActive
RefreshTokens   → token (hashed), userId, clientId, device, ip, expiresAt, isRevoked
```

### HRM DB
```
Users     → id, userId (from Auth), name, email, role, isActive
Employees → id, userId, position, department, joiningDate
Salaries  → id, userId, amount, currency, effectiveDate, notes
```

**Key Point:** `userId` is the common thread across all databases, but databases never directly connect to each other.

---

## 📝 Important Notes

### For Development (localhost)
- Use `127.0.0.1` consistently in all requests
- `COOKIE_DOMAIN` should be empty
- Cookies won't share across different ports in localhost (expected behavior)

### For Production
- Set `COOKIE_DOMAIN=.yourcompany.com` in both services
- Use proper subdomains: `auth.yourcompany.com`, `hrm.yourcompany.com`
- Cookies will automatically share across all subdomains
- Set `NODE_ENV=production`
- Use strong client secrets
- Enable HTTPS (`secure: true` in cookie options)

### Adding New Apps (e.g., CRM)
1. Add client to Auth Service `.env`
2. Run `npm run seed:clients`
3. Clone HRM structure
4. Update `CLIENT_ID` and `CLIENT_SECRET` in new app's `.env`
5. Copy same JWT keys
6. Create new database
7. Build app-specific business logic

---

## 🐛 Troubleshooting

### Cookies not working
- Ensure you're using `127.0.0.1` (not `localhost`) consistently
- Check Postman cookie jar is enabled
- Verify cookies exist for the correct domain

### JWT errors
- Ensure keys were generated using `npm run setup-keys`
- Verify both Auth and HRM have **identical** keys
- Check no extra quotes or spaces in `.env` values

### Token verification fails
- Check `CLIENT_ID` in HRM matches what's in the token payload
- Verify user `isActive = true` in Auth DB
- Ensure token hasn't expired (check timestamps)

### Database connection errors
- Verify PostgreSQL is running
- Check `DATABASE_URL` format is correct
- Ensure databases exist (`auth_service`, `hrm_db`)

---

## 📌 License

MIT License

---

⭐ **Star the repo if you found it useful!**

---

# Deployment Guide

## Infrastructure

- Cloud Provider: AWS
- Compute: EC2 Ubuntu 24.04 LTS
- Database: Amazon RDS PostgreSQL
- Reverse Proxy: Nginx
- CI/CD: Jenkins
- Container Runtime: Docker

## Architecture

Client
      │
      ▼
Nginx Reverse Proxy
      │
 ┌────┴─────┐
 │          │
 ▼          ▼
CRUD API   Multi-Auth
 │          │
 └────┬─────┘
      ▼
Amazon RDS PostgreSQL

## Database Strategy

Both applications use a single Amazon RDS PostgreSQL instance with two separate databases:

- crud_db
- multi_auth_db

This approach reduces infrastructure cost while maintaining logical isolation between applications.

## Open Ports

| Port | Purpose |
|------|---------|
|22|SSH (restricted to administrator IP)|
|80|HTTP|
|443|HTTPS|
|9090|Jenkins|
|5000|Multi-Auth (internal, proxied through Nginx)|

## CI/CD

Deployment is automated using Jenkins pipelines.

Pipeline stages:

- Checkout
- Install Dependencies
- Generate Prisma Client
- Run Prisma Migrations
- Restart Application
- Health Check
