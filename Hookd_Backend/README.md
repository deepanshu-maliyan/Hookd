# Hookd Backend API

Complete NestJS backend for the Hookd dating application.

## 🚀 Quick Start

1. **Install dependencies:**
```bash
npm install
```

2. **Start PostgreSQL and MinIO:**
```bash
docker-compose up -d
```

3. **Run the application:**
```bash
npm run start:dev
```

The API will be available at `http://localhost:3000/api/v1`

## 📋 API Endpoints

### Authentication
- `POST /api/v1/auth/register` - Register new user
- `POST /api/v1/auth/login` - Login user

### Users
- `GET /api/v1/users/me` - Get current user profile (protected)
- `PATCH /api/v1/users/me` - Update current user profile (protected)
- `GET /api/v1/users/:id` - Get user by ID (public)

### Matching
- `POST /api/v1/matching/like/:targetId` - Like a user (protected)
- `GET /api/v1/matching/matches` - Get all matches (protected)
- `DELETE /api/v1/matching/unmatch/:matchId` - Unmatch (protected)
- `GET /api/v1/matching/discovery` - Get discovery users (protected)

### Stream Chat
- `GET /api/v1/stream/token` - Get Stream Chat token (protected)

### Media
- `POST /api/v1/media/presigned-url` - Get presigned upload URL (protected)

### Confessions
- `POST /api/v1/confessions` - Create confession (protected)
- `GET /api/v1/confessions` - Get all confessions (public)
- `GET /api/v1/confessions/:id` - Get confession by ID (public)

## 🛠 Tech Stack

- **Framework:** NestJS
- **Database:** PostgreSQL with TypeORM
- **Authentication:** JWT with Passport
- **Chat:** Stream Chat
- **File Storage:** MinIO (S3-compatible)
- **Validation:** class-validator & class-transformer

## 📦 Environment Variables

All environment variables are configured in `.env`:
- Database connection (PostgreSQL)
- JWT secret and expiration
- Stream API credentials
- MinIO configuration

## 🏗 Project Structure

```
src/
├── main.ts                 # Application bootstrap
├── app.module.ts           # Root module
├── auth/                   # Authentication module
│   ├── auth.controller.ts
│   ├── auth.service.ts
│   ├── auth.module.ts
│   ├── jwt.strategy.ts
│   ├── jwt-auth.guard.ts
│   ├── current-user.decorator.ts
│   └── dto/
├── users/                  # Users module
│   ├── users.controller.ts
│   ├── users.service.ts
│   ├── users.module.ts
│   ├── entities/
│   └── dto/
├── matching/               # Matching module
│   ├── matching.controller.ts
│   ├── matching.service.ts
│   ├── matching.module.ts
│   └── entities/
├── stream/                 # Stream Chat integration
│   ├── stream.controller.ts
│   ├── stream.service.ts
│   └── stream.module.ts
├── media/                  # Media upload module
│   ├── media.controller.ts
│   ├── media.service.ts
│   └── media.module.ts
└── confessions/            # Confessions module
    ├── confessions.controller.ts
    ├── confessions.service.ts
    ├── confessions.module.ts
    ├── entities/
    └── dto/
```

## ✅ Features Implemented

✅ Complete user registration and authentication with JWT
✅ User profile management with photos and fantasy tags
✅ Like/match system with mutual matching detection
✅ Automatic Stream Chat channel creation on match
✅ Discovery feed with already-liked user filtering
✅ Anonymous confessions with Stream activity feed
✅ Presigned URL generation for file uploads to MinIO
✅ Full TypeORM entity relationships
✅ Complete validation with class-validator
✅ JWT authentication guards on protected routes
✅ CORS enabled
✅ Global validation pipe

## 🔒 Security

- Passwords hashed with bcrypt (10 rounds)
- JWT tokens with configurable expiration
- Route guards on all protected endpoints
- Input validation on all DTOs
- SQL injection protection via TypeORM parameterized queries

## 🗄 Database Schema

### Users
- UUID primary key
- Email (unique), password hash, name, bio
- Age, gender, intent
- Fantasy tags (array), photos (array)
- Stream user ID for chat integration
- Verification status, timestamps

### Likes
- Liker and liked user foreign keys
- Unique constraint on (liker_id, liked_id)
- Timestamps

### Matches
- Two user foreign keys (user1_id, user2_id)
- Stream channel ID for chat
- Timestamps

### Confessions
- Author foreign key (nullable for anonymous)
- Body text, optional image URL
- Anonymous flag
- Stream activity ID
- Timestamps

## 📝 Notes

- TypeORM synchronize is enabled for development
- Stream Chat integration requires valid API credentials
- MinIO runs on port 9000 (configure in docker-compose)
- PostgreSQL runs on port 5432
- All routes use `/api/v1` prefix
