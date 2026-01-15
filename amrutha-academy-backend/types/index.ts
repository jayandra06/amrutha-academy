// API Response wrapper
export interface ApiResponse<T> {
  statusCode: number;
  message?: string[];
  error?: string;
  data?: T;
  pagination?: PaginationResponse;
}

export interface PaginationResponse {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
}

// User Types
export interface User {
  id: string;
  fullName: string;
  email: string;
  avatar: string;
  bio: string;
  phoneNumber: string;
  birthday: string; // ISO date string
  location: string;
  role: string;
}

// Auth Types
export interface LoginRequest {
  email: string;
  password: string;
}

export interface LoginResponse {
  token: string;
}

// Course Types
export interface Course {
  id: string;
  title: string;
  category: string;
  image: string;
  price: number;
  originalPrice: number;
  rating: number;
  reviewsCount: number;
  students: number;
  duration: number; // in minutes
  certificate: boolean;
  mentor: Mentor;
  tools: Tool[];
  about: string;
  isFavourite?: boolean;
}

export interface Mentor {
  id: string;
  name: string;
  title: string;
  avatarUrl: string;
}

export interface Category {
  id: string;
  name: string;
}

export interface Lesson {
  id: string;
  title: string;
  duration: number; // in minutes
  videoUrl: string;
  isFree: boolean;
}

export interface Review {
  id: string;
  courseId: string;
  userId: string;
  rating: number;
  comment: string;
  createdAt: string; // ISO date string
}

export interface Tool {
  name: string;
  iconUrl: string;
}

export interface Promote {
  id: string;
  title: string;
  description: string;
  discount: string;
  isActive: boolean;
  expiryDate: string; // ISO date string
}

export interface SearchHistory {
  id: string;
  keyword: string;
  searchedAt: string; // ISO date string
}

// Phone Auth Types
export interface SendOTPRequest {
  phoneNumber: string;
}

export interface VerifyOTPRequest {
  phoneNumber: string;
  otp: string;
  verificationId: string;
}

export interface VerifyOTPResponse {
  token: string;
  isNewUser: boolean;
  user?: User;
}

// Extended Course Types
export interface CourseExtended extends Course {
  level: number; // 1, 2, or 3
  startDate: string; // ISO date string
  endDate: string; // ISO date string
  duration: number; // in days
  trainerId?: string;
  trainerName?: string;
  adminId?: string;
}

// Enrollment Types
export interface Enrollment {
  id: string;
  userId: string;
  courseId: string;
  paymentStatus: string; // pending, completed, failed
  paymentId?: string;
  enrolledAt: string; // ISO date string
  status: string; // pending, active, completed, cancelled
  chatRoomId?: string;
}

export interface CreateEnrollmentRequest {
  courseId: string;
}

// Schedule Types
export interface Schedule {
  id: string;
  courseId: string;
  trainerId: string;
  startTime: string; // ISO datetime string
  endTime: string; // ISO datetime string
  date: string; // ISO date string
  meetingLink?: string; // Jitsi Meet link
  status: string; // scheduled, ongoing, completed, cancelled
  attendanceEnabled: boolean;
}

export interface CreateScheduleRequest {
  courseId: string;
  trainerId: string;
  startTime: string;
  endTime: string;
  date: string;
  meetingLink?: string;
}

// Attendance Types
export interface Attendance {
  id: string;
  scheduleId: string;
  userId: string;
  status: string; // present, absent
  joinedAt?: string; // ISO datetime string
  markedAt: string; // ISO datetime string
}

// Chat Room Types
export interface ChatRoom {
  id: string;
  courseId: string;
  courseName: string;
  enrollmentId: string;
  createdAt: string; // ISO datetime string
  endDate: string; // ISO date string
  status: string; // active, read-only
  participants: string[]; // user IDs
  roomId: string; // Firebase Realtime DB path
}

// Payment Types
export interface RazorpayOrderRequest {
  amount: number; // in paise (smallest currency unit)
  currency: string;
  receipt?: string;
  notes?: Record<string, string>;
}

export interface RazorpayOrderResponse {
  orderId: string;
  amount: number;
  currency: string;
  keyId: string; // Razorpay key for client
}

export interface RazorpayVerifyRequest {
  orderId: string;
  paymentId: string;
  signature: string;
}

