# Amrutha Academy Backend API

This is a Next.js backend API built with Firebase (Firestore, Firebase Auth, and Firebase Storage) to match the Flutter mobile application structure. It provides RESTful APIs for an e-learning platform.

## Features

- **Firebase Integration**: Uses Firestore for database, Firebase Auth for authentication, and Firebase Storage for file storage
- **Authentication**: Firebase Auth-based authentication with custom tokens
- **Course Management**: Course listings, details, lessons, and reviews
- **User Management**: User profiles stored in Firestore
- **Search**: Search suggestions and history
- **Promotions**: Active promotion management
- **File Upload**: Firebase Storage integration for file uploads

## Prerequisites

- Node.js 18+
- Firebase project: `amrutha-academy`
  - Firestore Database enabled
  - Firebase Authentication enabled
  - Firebase Storage enabled
  - Service Account key (for Admin SDK)

## Firebase Setup

**Quick Start**: See [FIREBASE_SETUP.md](./FIREBASE_SETUP.md) for detailed setup instructions.

### Your Firebase Project

- **Project ID**: `amrutha-academy`
- **Storage Bucket**: `amrutha-academy.firebasestorage.app`
- **Auth Domain**: `amrutha-academy.firebaseapp.com`

### Getting Service Account Credentials

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select project: `amrutha-academy`
3. Go to Project Settings → Service Accounts
4. Click "Generate new private key"
5. Download the JSON file

### Environment Configuration

Create a `.env.local` file in the root directory:

```env
FIREBASE_PROJECT_ID=amrutha-academy
FIREBASE_CLIENT_EMAIL=your-service-account-email@amrutha-academy.iam.gserviceaccount.com
FIREBASE_PRIVATE_KEY="-----BEGIN PRIVATE KEY-----\nYour Private Key Here\n-----END PRIVATE KEY-----\n"
FIREBASE_STORAGE_BUCKET=amrutha-academy.firebasestorage.app
```

**Important**: Copy the entire private key from the service account JSON file, including the BEGIN/END markers and newline characters (`\n`).

## Installation

1. **Install Dependencies**
```bash
npm install
```

2. **Configure Environment Variables**
   - Copy `.env.local.example` to `.env.local`
   - Fill in your Firebase Service Account credentials (see FIREBASE_SETUP.md)

3. **Run the Development Server**
```bash
npm run dev
```

The API will be available at `http://localhost:3000/api`

## Firestore Collections Structure

The backend expects the following Firestore collections:

### Collections

- **users**: User profiles
  - `fullName`, `email`, `avatar`, `bio`, `phoneNumber`, `birthday`, `location`, `role`

- **courses**: Course data
  - `title`, `category`, `image`, `price`, `originalPrice`, `rating`, `reviewsCount`, `students`, `duration`, `certificate`, `mentorId`, `tools`, `about`, `isFavourite`

- **categories**: Course categories
  - `name`

- **mentors**: Mentor information
  - `name`, `title`, `avatarUrl`

- **promotes**: Promotions
  - `title`, `description`, `discount`, `isActive`, `expiryDate`

- **lessons**: Course lessons
  - `courseId`, `title`, `duration`, `videoUrl`, `isFree`, `order`

- **reviews**: Course reviews
  - `courseId`, `userId`, `rating`, `comment`, `createdAt`

- **searchHistory**: User search history
  - `userId`, `keyword`, `searchedAt`

- **searchSuggestions**: Search suggestions
  - Document ID: `default`
  - Field: `suggestions` (array of strings)

## API Endpoints

### Authentication

#### POST `/api/login`
Login endpoint (uses Firebase Auth)

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "password123"
}
```

**Response:**
```json
{
  "statusCode": 200,
  "message": ["Login successful"],
  "data": {
    "token": "firebase-custom-token"
  }
}
```

### User

#### GET `/api/profile`
Get user profile (requires authentication)

**Headers:**
```
Authorization: Bearer <firebase-id-token>
```

### Courses

#### GET `/api/promote`
Get active promotions

#### GET `/api/categories`
Get all course categories

#### GET `/api/course/:id`
Get course details by ID

#### GET `/api/courses/popular`
Get most popular courses

#### GET `/api/mentors`
Get all mentors

#### GET `/api/courses/:id/lessons`
Get lessons for a specific course

#### GET `/api/courses/:id/reviews`
Get reviews for a specific course

### Search

#### GET `/api/search/suggestions`
Get search suggestions

#### GET `/api/search/history`
Get search history (requires authentication)

### Upload

#### POST `/api/upload`
Upload a file to Firebase Storage (requires authentication)

**Form Data:**
- `file`: The file to upload
- `folder`: Optional folder name (default: "uploads")

**Response:**
```json
{
  "statusCode": 200,
  "data": {
    "url": "https://storage.googleapis.com/...",
    "path": "uploads/1234567890-filename.jpg"
  }
}
```

## Response Format

All API responses follow a consistent format:

```typescript
{
  statusCode: number;
  message?: string[];
  error?: string;
  data?: T;
  pagination?: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  };
}
```

## Project Structure

```
├── app/
│   └── api/              # API routes
│       ├── login/
│       ├── profile/
│       ├── course/
│       ├── courses/
│       ├── mentors/
│       ├── promote/
│       ├── categories/
│       ├── search/
│       └── upload/
├── lib/
│   ├── firebase/         # Firebase configuration
│   ├── services/         # Business logic services
│   └── utils/            # Utility functions
├── types/                # TypeScript types
└── middleware.ts         # Next.js middleware
```

## Firebase Authentication Flow

1. Client sends login request with email/password
2. Backend creates a Firebase custom token
3. Client exchanges custom token for Firebase ID token
4. Client uses ID token in `Authorization: Bearer <token>` header for protected routes
5. Backend verifies ID token using Firebase Admin SDK

## Development Notes

- All data is stored in Firestore
- File uploads go to Firebase Storage
- Authentication uses Firebase Auth
- The backend uses Firebase Admin SDK for server-side operations

## Security Notes

- ⚠️ **Never commit service account credentials to git**
- Keep `.env.local` secure and never share it
- Service account keys have admin privileges
- Use Firebase Security Rules for Firestore and Storage

## Production Considerations

- Set up Firebase Security Rules for Firestore and Storage
- Use environment variables for all sensitive configuration
- Implement rate limiting
- Add input validation and sanitization
- Set up proper error logging
- Configure CORS appropriately
- Use Firebase App Check for additional security
- Set up monitoring and alerts

## License

MIT
