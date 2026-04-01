# Hookd - Gen-Z Intent-Based Dating App

A modern dating platform built for radical honesty. Users declare their intent upfront (serious, casual, hookup, FWB, explore) and match with others who want the same thing.

## 🎯 Features

- **Intent-Based Matching** - Users declare what they're looking for upfront
- **Fantasy Tags** - Optional tags for specific interests/kinks
- **Swipe Discovery** - Tinder-style card stack with mutual match detection
- **Real-Time Chat** - Powered by Stream Chat, unlocked on mutual match
- **Anonymous Confessions** - Reddit-style feed for sharing experiences
- **Media Uploads** - Secure photo uploads via MinIO (local S3)

## 🏗️ Tech Stack

### Backend
- **NestJS** (Node 20, TypeScript)
- **PostgreSQL 16** - All app data
- **TypeORM** - Database ORM with auto-sync in dev
- **JWT** - Authentication with 7-day expiry
- **Stream Chat** - Real-time messaging
- **MinIO** - Local S3-compatible object storage
- **Docker** - PostgreSQL + MinIO containers

### iOS App
- **SwiftUI** (iOS 17+)
- **Stream Chat Swift SDK** - Chat UI and real-time messaging
- **Async/Await** - Modern Swift concurrency
- **Keychain** - Secure JWT storage
- **PHPickerViewController** - Native photo picker

## 📁 Project Structure

```
Hookd/
├── docker-compose.yml          # PostgreSQL + MinIO services
├── Hookd_Backend/              # NestJS backend
│   ├── src/
│   │   ├── main.ts
│   │   ├── app.module.ts
│   │   ├── auth/               # Registration, login, JWT
│   │   ├── users/              # Profile management
│   │   ├── matching/           # Likes, matches, discovery
│   │   ├── stream/             # Stream token generation
│   │   ├── media/              # MinIO presigned URLs
│   │   └── confessions/        # Anonymous feed
│   ├── .env                    # Environment variables
│   └── package.json
└── Hookd/                      # iOS Xcode project
    └── Hookd/
        ├── HookdApp.swift
        ├── Models/             # Codable data models
        ├── Networking/         # APIClient, KeychainHelper
        ├── Views/              # SwiftUI screens
        │   ├── Auth/           # Login, Register, Onboarding
        │   ├── Dating/         # Card stack, profile cards
        │   ├── Matches/        # Chat list
        │   ├── Confessions/    # Feed, post
        │   └── Profile/        # User profile, settings
        └── AppState.swift      # Global state management
```

## 🚀 Quick Start

### Prerequisites

- **macOS** with Xcode 15+
- **Docker Desktop** installed and running
- **Node.js 20+** installed
- **Stream.io Account** - Get free API key at [getstream.io](https://getstream.io)

### 1. Start Infrastructure

```bash
cd Hookd
docker compose up -d

# Verify services are running
docker ps
# You should see: hookd_postgres (port 5432) and hookd_minio (ports 9000, 9001)
```

**Access Services:**
- PostgreSQL: `localhost:5432` (user: `hookd`, password: `hookd123`, db: `hookd_db`)
- MinIO Console: [http://localhost:9001](http://localhost:9001) (credentials: `minioadmin` / `minioadmin`)
- MinIO API: [http://localhost:9000](http://localhost:9000)

### 2. Configure Backend

```bash
cd Hookd_Backend

# Edit .env file and add your Stream credentials
# STREAM_API_KEY=your_key_here
# STREAM_API_SECRET=your_secret_here

# Install dependencies (already done if scaffolded)
npm install

# Start development server
npm run start:dev
```

Backend will be available at: [http://localhost:3000/api/v1](http://localhost:3000/api/v1)

### 3. Configure iOS App

1. Open `Hookd/Hookd.xcodeproj` in Xcode
2. Add Swift Package Dependencies:
   - **StreamChat**: `https://github.com/GetStream/stream-chat-swift`
   - **StreamChatSwiftUI**: `https://github.com/GetStream/stream-chat-swiftui`
   - **Kingfisher**: `https://github.com/onevcat/Kingfisher`

3. Update `Networking/AppConstants.swift`:
   ```swift
   enum AppConstants {
       static let backendBaseURL = "http://localhost:3000/api/v1"
       static let streamAPIKey = "YOUR_STREAM_API_KEY"  // ⚠️ Replace this
   }
   ```

4. Build and Run (⌘+R)
   - Select iOS Simulator (iPhone 15 Pro recommended)
   - App will launch on simulator

## 🔑 Stream.io Setup

1. Go to [getstream.io](https://getstream.io) and create a free account
2. Create a new app (select "Chat" type)
3. Copy your **API Key** and **API Secret** from the dashboard
4. Add them to:
   - Backend: `Hookd_Backend/.env`
   - iOS: `Hookd/Hookd/Networking/AppConstants.swift`

## 📊 Database Schema

### Users Table
- `id` (UUID, PK)
- `email` (unique)
- `password_hash`
- `name`, `bio`, `age`, `gender`
- `intent` (serious | casual | hookup | fwb | explore)
- `fantasy_tags` (text array)
- `photos` (text array - CDN URLs)
- `stream_user_id`
- `is_verified`, `created_at`, `updated_at`

### Likes & Matches
- **Likes**: `liker_id` → `liked_id` (unique constraint)
- **Matches**: `user1_id` ↔ `user2_id` + `stream_channel_id`

### Confessions
- `id`, `author_id` (nullable), `is_anonymous`, `body`, `image_url`, `stream_activity_id`

TypeORM auto-creates tables in development mode.

## 🛣️ API Endpoints

### Auth
- `POST /api/v1/auth/register` - Create account
- `POST /api/v1/auth/login` - Login (returns JWT + Stream token)

### Users (JWT Protected)
- `GET /api/v1/users/me` - Current user profile
- `PATCH /api/v1/users/me` - Update profile
- `GET /api/v1/users/:id` - Public profile

### Matching (JWT Protected)
- `POST /api/v1/matching/like/:targetId` - Like a user
- `GET /api/v1/matching/matches` - List all matches
- `GET /api/v1/matching/discovery` - Get profiles to swipe
- `DELETE /api/v1/matching/unmatch/:matchId` - Remove match

### Stream (JWT Protected)
- `GET /api/v1/stream/token` - Get Stream user token

### Media (JWT Protected)
- `POST /api/v1/media/presigned-url` - Get presigned upload URL

### Confessions
- `POST /api/v1/confessions` (JWT protected) - Create confession
- `GET /api/v1/confessions` (public) - List confessions
- `GET /api/v1/confessions/:id` - Get single confession

## 🧪 Testing

### Test Backend
```bash
# Check if backend is running
curl http://localhost:3000/api/v1/auth/register \
  -X POST \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","email":"test@example.com","password":"password123","age":25,"gender":"male"}'

# Should return JWT token and user object
```

### Test iOS App
1. Launch app in simulator
2. Register a new account
3. Complete onboarding (intent + tags + photos)
4. Should reach main tab view with Dating feed

## 🎨 App Flow

### First Time User
1. **Login/Register** - Email/password auth
2. **Onboarding** - Select intent (e.g., "Casual")
3. **Fantasy Tags** - Pick 1-10 tags (optional)
4. **Upload Photos** - 2-6 photos required
5. **Main App** - Access dating feed

### Matching Flow
1. User swipes through profiles
2. Swipe right = like
3. If mutual like → **Match overlay appears**
4. Stream Chat channel auto-created
5. Both users can now message

### Confessions
- Users post anonymous or public confessions
- Others can upvote and comment
- Feed sorted by latest or top-voted

## 🔐 Security Notes

- **JWT tokens** stored in iOS Keychain (secure enclave)
- **Passwords** hashed with bcrypt (10 rounds)
- **Stream tokens** generated server-side (never exposed)
- **MinIO** configured for public read (development only)
- **CORS** enabled for all origins (development only)

## 🐛 Troubleshooting

### Docker not starting
```bash
# Ensure Docker Desktop is running
open -a Docker

# Wait 30 seconds, then try again
docker ps
```

### Backend port conflict
```bash
# Check if port 3000 is in use
lsof -i :3000

# Kill the process or change PORT in .env
```

### iOS build errors
1. Clean build folder: Product → Clean Build Folder (⌘+Shift+K)
2. Reset package cache: File → Packages → Reset Package Cache
3. Restart Xcode

### MinIO bucket not found
```bash
# Recreate the bucket manually
export PATH="/Applications/Docker.app/Contents/Resources/bin:$PATH"
docker exec -it hookd_minio mc mb /data/hookd-media
docker exec -it hookd_minio mc anonymous set public /data/hookd-media
```

## 📝 Environment Variables

Create `Hookd_Backend/.env`:

```env
DATABASE_URL=postgresql://hookd:hookd123@localhost:5432/hookd_db
JWT_SECRET=hookd_super_secret_jwt_key_change_in_prod
JWT_EXPIRES_IN=7d
STREAM_API_KEY=your_stream_api_key_here
STREAM_API_SECRET=your_stream_api_secret_here
MINIO_ENDPOINT=localhost
MINIO_PORT=9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
MINIO_BUCKET=hookd-media
PORT=3000
NODE_ENV=development
```

## 🚧 Roadmap

- [ ] Phone OTP authentication (replace email/password)
- [ ] Push notifications for matches
- [ ] Voice notes in chat
- [ ] Video calls (Stream Video SDK)
- [ ] Location-based filtering
- [ ] Admin moderation dashboard
- [ ] AI content moderation
- [ ] Production deployment (AWS/Railway)

## 📄 License

MIT

## 👨‍💻 Author

Deepanshu Maliyan - Built with GitHub Copilot CLI

---

**Need help?** Open an issue or check the [complete spec document](Hookd%20—%20Complete%20App%20Architecture%20&%20Local%20Developm.md).
