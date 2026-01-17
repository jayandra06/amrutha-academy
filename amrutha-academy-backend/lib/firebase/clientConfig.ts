// Firebase Client SDK Configuration for Next.js (Web)
import { initializeApp, getApps, FirebaseApp } from 'firebase/app';
import { getAuth, Auth } from 'firebase/auth';

// Firebase web app configuration
const firebaseConfig = {
  apiKey: "AIzaSyBQ1x6bwLTxKn3WGHtTc3ClD451JiSuciw",
  authDomain: "amrutha-academy.firebaseapp.com",
  projectId: "amrutha-academy",
  storageBucket: "amrutha-academy.firebasestorage.app",
  messagingSenderId: "349596859394",
  databaseURL: "https://amrutha-academy-default-rtdb.firebaseio.com"
};

// Initialize Firebase Client SDK (only on client side)
let app: FirebaseApp | null = null;
let auth: Auth | null = null;

if (typeof window !== 'undefined') {
  // Only initialize on client side (browser)
  if (getApps().length === 0) {
    app = initializeApp(firebaseConfig);
  } else {
    app = getApps()[0];
  }
  auth = getAuth(app);
}

// Export auth (will be null on server-side)
export { auth };

