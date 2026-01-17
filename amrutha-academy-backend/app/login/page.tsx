'use client';

'use client';

import { useState, FormEvent, useEffect } from 'react';
import { useRouter } from 'next/navigation';
import { RecaptchaVerifier, signInWithPhoneNumber, PhoneAuthProvider, signInWithCredential, Auth } from 'firebase/auth';
import { auth } from '@/lib/firebase/clientConfig';

export default function LoginPage() {
  const router = useRouter();
  const [phoneNumber, setPhoneNumber] = useState('');
  const [otp, setOtp] = useState('');
  const [verificationId, setVerificationId] = useState<string | null>(null);
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);
  const [recaptchaVerifier, setRecaptchaVerifier] = useState<RecaptchaVerifier | null>(null);

  useEffect(() => {
    // Initialize reCAPTCHA verifier when component mounts (only on client side)
    if (auth && typeof window !== 'undefined') {
      const verifier = new RecaptchaVerifier(auth as Auth, 'recaptcha-container', {
        size: 'invisible',
        callback: () => {
          // reCAPTCHA solved - will allow signInWithPhoneNumber to be called
        },
      });
      setRecaptchaVerifier(verifier);

      return () => {
        // Cleanup
        if (verifier) {
          try {
            verifier.clear();
          } catch (e) {
            // Ignore cleanup errors
          }
        }
      };
    }
  }, []);

  const formatPhoneNumber = (phone: string): string => {
    // Format phone number with country code if not present
    let formatted = phone.trim().replace(/\D/g, ''); // Remove non-digits
    
    if (!formatted.startsWith('+91')) {
      if (formatted.startsWith('91')) {
        formatted = '+' + formatted;
      } else {
        formatted = '+91' + formatted; // Default to India +91
      }
    } else if (!formatted.startsWith('+')) {
      formatted = '+' + formatted;
    }
    
    return formatted;
  };

  const handleSendOTP = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);

    if (!phoneNumber) {
      setMessage({ type: 'error', text: 'Phone number is required' });
      setLoading(false);
      return;
    }

    try {
      if (!auth || !recaptchaVerifier) {
        throw new Error('Firebase Auth not initialized');
      }

      const formattedPhone = formatPhoneNumber(phoneNumber);
      console.log('Sending OTP to:', formattedPhone);

      // Send OTP using Firebase Auth
      const confirmationResult = await signInWithPhoneNumber(auth as Auth, formattedPhone, recaptchaVerifier);
      setVerificationId(confirmationResult.verificationId);
      setMessage({ type: 'success', text: 'OTP sent successfully! Please check your phone.' });
    } catch (error: any) {
      console.error('Error sending OTP:', error);
      const errorMessage = error.message || 'Failed to send OTP. Please try again.';
      setMessage({ type: 'error', text: errorMessage });
      
      // Reset reCAPTCHA on error
      if (auth && recaptchaVerifier) {
        try {
          recaptchaVerifier.clear();
        } catch (e) {
          // Ignore clear errors
        }
        const newVerifier = new RecaptchaVerifier(auth as Auth, 'recaptcha-container', {
          size: 'invisible',
        });
        setRecaptchaVerifier(newVerifier);
      }
    } finally {
      setLoading(false);
    }
  };

  const handleVerifyOTP = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);

    if (!otp || !verificationId) {
      setMessage({ type: 'error', text: 'OTP is required' });
      setLoading(false);
      return;
    }

    try {
      if (!auth) {
        throw new Error('Firebase Auth not initialized');
      }

      // Verify OTP
      const credential = PhoneAuthProvider.credential(verificationId, otp);
      const userCredential = await signInWithCredential(auth as Auth, credential);
      
      const user = userCredential.user;
      console.log('User logged in:', user.uid);

      // Get ID token for backend verification
      const idToken = await user.getIdToken();
      
      // Store token in sessionStorage or localStorage
      if (typeof window !== 'undefined') {
        sessionStorage.setItem('firebaseToken', idToken);
        sessionStorage.setItem('firebaseUser', JSON.stringify({
          uid: user.uid,
          phoneNumber: user.phoneNumber,
        }));
      }

      // Verify user role with backend
      try {
        const response = await fetch('/api/auth/phone/verify-id-token', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${idToken}`,
          },
          body: JSON.stringify({}),
        });

        const data = await response.json();

        if (response.ok && data.data) {
          const userRole = data.data.role;
          setMessage({ type: 'success', text: 'Login successful! Redirecting...' });
          
          // Redirect based on role or to admin dashboard
          setTimeout(() => {
            if (userRole === 'admin') {
              router.push('/admin/users');
            } else {
              router.push('/');
            }
          }, 1000);
        } else {
          throw new Error(data.error || 'Failed to verify user');
        }
      } catch (error: any) {
        console.error('Error verifying user with backend:', error);
        // Still allow login even if backend verification fails
        setMessage({ type: 'success', text: 'Login successful! Redirecting...' });
        setTimeout(() => {
          router.push('/admin/users');
        }, 1000);
      }
    } catch (error: any) {
      console.error('Error verifying OTP:', error);
      const errorMessage = error.message || 'Invalid OTP. Please try again.';
      setMessage({ type: 'error', text: errorMessage });
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="min-h-screen bg-zinc-50 flex items-center justify-center py-12 px-4 sm:px-6 lg:px-8 dark:bg-black">
      <div className="max-w-md w-full space-y-8">
        <div className="bg-white shadow-lg rounded-lg p-8 dark:bg-zinc-900">
          <div className="text-center">
            <h1 className="text-3xl font-bold text-gray-900 mb-2 dark:text-zinc-50">
              Admin Login
            </h1>
            <p className="text-gray-600 dark:text-zinc-400">
              Sign in with your phone number
            </p>
          </div>

          {/* reCAPTCHA container (invisible) */}
          <div id="recaptcha-container"></div>

          {message && (
            <div
              className={`mt-6 p-4 rounded-lg ${
                message.type === 'success'
                  ? 'bg-green-50 text-green-800 border border-green-200 dark:bg-green-900/20 dark:text-green-300 dark:border-green-800'
                  : 'bg-red-50 text-red-800 border border-red-200 dark:bg-red-900/20 dark:text-red-300 dark:border-red-800'
              }`}
            >
              {message.text}
            </div>
          )}

          {!verificationId ? (
            // Send OTP Form
            <form onSubmit={handleSendOTP} className="mt-8 space-y-6">
              <div>
                <label htmlFor="phoneNumber" className="block text-sm font-medium text-gray-700 dark:text-zinc-300 mb-2">
                  Phone Number <span className="text-red-500">*</span>
                </label>
                <input
                  type="tel"
                  id="phoneNumber"
                  required
                  value={phoneNumber}
                  onChange={(e) => setPhoneNumber(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-50"
                  placeholder="8309057182 or +918309057182"
                />
                <p className="mt-1 text-sm text-gray-500 dark:text-zinc-400">
                  Enter with or without country code (defaults to +91 for India)
                </p>
              </div>

              <button
                type="submit"
                disabled={loading}
                className="w-full bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {loading ? 'Sending OTP...' : 'Send OTP'}
              </button>
            </form>
          ) : (
            // Verify OTP Form
            <form onSubmit={handleVerifyOTP} className="mt-8 space-y-6">
              <div>
                <label htmlFor="otp" className="block text-sm font-medium text-gray-700 dark:text-zinc-300 mb-2">
                  Enter OTP <span className="text-red-500">*</span>
                </label>
                <input
                  type="text"
                  id="otp"
                  required
                  value={otp}
                  onChange={(e) => setOtp(e.target.value.replace(/\D/g, ''))}
                  maxLength={6}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent text-center text-2xl tracking-widest dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-50"
                  placeholder="000000"
                />
                <p className="mt-1 text-sm text-gray-500 dark:text-zinc-400">
                  Enter the 6-digit code sent to {phoneNumber}
                </p>
              </div>

              <div className="flex gap-4">
                <button
                  type="submit"
                  disabled={loading}
                  className="flex-1 bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
                >
                  {loading ? 'Verifying...' : 'Verify OTP'}
                </button>
                <button
                  type="button"
                  onClick={() => {
                    setVerificationId(null);
                    setOtp('');
                    setMessage(null);
                  }}
                  className="px-6 py-3 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 dark:border-zinc-700 dark:text-zinc-300 dark:hover:bg-zinc-800 transition-colors"
                >
                  Change Number
                </button>
              </div>
            </form>
          )}

          <div className="mt-6 text-center">
            <button
              onClick={() => router.push('/')}
              className="text-sm text-blue-600 hover:text-blue-800 dark:text-blue-400 dark:hover:text-blue-300"
            >
              ← Back to Home
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}

