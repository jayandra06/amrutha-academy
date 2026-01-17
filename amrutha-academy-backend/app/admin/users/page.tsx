'use client';

import { useState, FormEvent } from 'react';

export default function CreateUserPage() {
  const [formData, setFormData] = useState({
    fullName: '',
    email: '',
    phoneNumber: '',
    role: 'student' as 'student' | 'trainer' | 'admin',
    bio: '',
    birthday: '',
    location: '',
  });

  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ type: 'success' | 'error'; text: string } | null>(null);

  const handleSubmit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault();
    setLoading(true);
    setMessage(null);

    try {
      console.log('Submitting form data:', formData);
      
      const response = await fetch('/api/users/create', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
        },
        body: JSON.stringify(formData),
      });

      console.log('Response status:', response.status, response.statusText);
      console.log('Response headers:', Object.fromEntries(response.headers.entries()));

      let data: any = {};
      let responseText = '';
      
      try {
        responseText = await response.text();
        console.log('Response text:', responseText);
        
        if (responseText && responseText.trim()) {
          data = JSON.parse(responseText);
        } else {
          console.warn('Empty response body received');
          data = { error: 'Empty response from server' };
        }
      } catch (parseError: any) {
        console.error('Failed to parse response:', parseError);
        console.error('Raw response text:', responseText);
        data = { 
          error: `Failed to parse response: ${parseError.message}`,
          rawResponse: responseText.substring(0, 500) // First 500 chars
        };
      }

      if (response.ok) {
        setMessage({ type: 'success', text: data.message?.[0] || data.message || 'User created successfully!' });
        // Reset form
        setFormData({
          fullName: '',
          email: '',
          phoneNumber: '',
          role: 'student',
          bio: '',
          birthday: '',
          location: '',
        });
      } else {
        // Extract error message from API response
        // The error structure is: { statusCode, error, data: null }
        const errorMessage = data.error || data.message?.[0] || data.message || `Failed to create user (${response.status} ${response.statusText})`;
        setMessage({ type: 'error', text: errorMessage });
        
        // Only log detailed error in development
        if (process.env.NODE_ENV === 'development') {
          console.error('API Error Response:', {
            status: response.status,
            statusText: response.statusText,
            data,
            rawResponse: responseText.substring(0, 200), // First 200 chars
          });
        }
      }
    } catch (error: any) {
      const errorMessage = error.message || 'An error occurred while creating user';
      setMessage({ type: 'error', text: errorMessage });
      console.error('Request Error:', error);
      console.error('Error stack:', error.stack);
    } finally {
      setLoading(false);
    }
  };

  const handleChange = (e: React.ChangeEvent<HTMLInputElement | HTMLSelectElement | HTMLTextAreaElement>) => {
    const { name, value } = e.target;
    setFormData((prev) => ({
      ...prev,
      [name]: value,
    }));
  };

  return (
    <div className="min-h-screen bg-zinc-50 py-12 px-4 sm:px-6 lg:px-8 dark:bg-black">
      <div className="max-w-2xl mx-auto">
        <div className="bg-white shadow-lg rounded-lg p-8 dark:bg-zinc-900">
          <h1 className="text-3xl font-bold text-gray-900 mb-6 dark:text-zinc-50">
            Create User
          </h1>

          {message && (
            <div
              className={`mb-6 p-4 rounded-lg ${
                message.type === 'success'
                  ? 'bg-green-50 text-green-800 border border-green-200 dark:bg-green-900/20 dark:text-green-300 dark:border-green-800'
                  : 'bg-red-50 text-red-800 border border-red-200 dark:bg-red-900/20 dark:text-red-300 dark:border-red-800'
              }`}
            >
              {message.text}
            </div>
          )}

          <form onSubmit={handleSubmit} className="space-y-6">
            {/* Full Name */}
            <div>
              <label htmlFor="fullName" className="block text-sm font-medium text-gray-700 dark:text-zinc-300 mb-2">
                Full Name <span className="text-red-500">*</span>
              </label>
              <input
                type="text"
                id="fullName"
                name="fullName"
                required
                value={formData.fullName}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-50"
                placeholder="John Doe"
              />
            </div>

            {/* Email */}
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 dark:text-zinc-300 mb-2">
                Email
              </label>
              <input
                type="email"
                id="email"
                name="email"
                value={formData.email}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-50"
                placeholder="john.doe@example.com"
              />
            </div>

            {/* Phone Number */}
            <div>
              <label htmlFor="phoneNumber" className="block text-sm font-medium text-gray-700 dark:text-zinc-300 mb-2">
                Phone Number
              </label>
              <input
                type="tel"
                id="phoneNumber"
                name="phoneNumber"
                value={formData.phoneNumber}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-50"
                placeholder="9550538735 or +919550538735"
              />
              <p className="mt-1 text-sm text-gray-500 dark:text-zinc-400">
                Enter with or without country code (defaults to +91 for India)
              </p>
            </div>

            {/* Role */}
            <div>
              <label htmlFor="role" className="block text-sm font-medium text-gray-700 dark:text-zinc-300 mb-2">
                Role <span className="text-red-500">*</span>
              </label>
              <select
                id="role"
                name="role"
                required
                value={formData.role}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-50"
              >
                <option value="student">Student</option>
                <option value="trainer">Trainer</option>
                <option value="admin">Admin</option>
              </select>
            </div>

            {/* Bio */}
            <div>
              <label htmlFor="bio" className="block text-sm font-medium text-gray-700 dark:text-zinc-300 mb-2">
                Bio
              </label>
              <textarea
                id="bio"
                name="bio"
                rows={3}
                value={formData.bio}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-50"
                placeholder="User bio or description"
              />
            </div>

            {/* Birthday */}
            <div>
              <label htmlFor="birthday" className="block text-sm font-medium text-gray-700 dark:text-zinc-300 mb-2">
                Birthday
              </label>
              <input
                type="date"
                id="birthday"
                name="birthday"
                value={formData.birthday}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-50"
              />
            </div>

            {/* Location */}
            <div>
              <label htmlFor="location" className="block text-sm font-medium text-gray-700 dark:text-zinc-300 mb-2">
                Location
              </label>
              <input
                type="text"
                id="location"
                name="location"
                value={formData.location}
                onChange={handleChange}
                className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-blue-500 focus:border-transparent dark:bg-zinc-800 dark:border-zinc-700 dark:text-zinc-50"
                placeholder="City, Country"
              />
            </div>

            {/* Submit Button */}
            <div className="flex gap-4">
              <button
                type="submit"
                disabled={loading}
                className="flex-1 bg-blue-600 text-white py-3 px-6 rounded-lg font-medium hover:bg-blue-700 focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2 disabled:opacity-50 disabled:cursor-not-allowed transition-colors"
              >
                {loading ? 'Creating...' : 'Create User'}
              </button>
              <button
                type="button"
                onClick={() => {
                  setFormData({
                    fullName: '',
                    email: '',
                    phoneNumber: '',
                    role: 'student',
                    bio: '',
                    birthday: '',
                    location: '',
                  });
                  setMessage(null);
                }}
                className="px-6 py-3 border border-gray-300 rounded-lg font-medium text-gray-700 hover:bg-gray-50 focus:outline-none focus:ring-2 focus:ring-gray-500 focus:ring-offset-2 dark:border-zinc-700 dark:text-zinc-300 dark:hover:bg-zinc-800 transition-colors"
              >
                Clear
              </button>
            </div>
          </form>
        </div>
      </div>
    </div>
  );
}

