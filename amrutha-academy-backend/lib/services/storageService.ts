import { storage } from '@/lib/firebase/config';

export class StorageService {
  /**
   * Upload a file to Firebase Storage
   * @param file Buffer or Uint8Array
   * @param path Path in storage bucket (e.g., 'images/course-1.jpg')
   * @param contentType MIME type of the file
   * @returns Download URL
   */
  static async uploadFile(
    file: Buffer | Uint8Array,
    path: string,
    contentType: string
  ): Promise<string> {
    try {
      const bucket = storage.bucket();
      const fileRef = bucket.file(path);
      
      await fileRef.save(file, {
        metadata: {
          contentType,
        },
      });

      // Make file publicly accessible (optional)
      await fileRef.makePublic();

      // Get public URL
      return fileRef.publicUrl();
    } catch (error) {
      console.error('Error uploading file:', error);
      throw error;
    }
  }

  /**
   * Delete a file from Firebase Storage
   * @param path Path in storage bucket
   */
  static async deleteFile(path: string): Promise<void> {
    try {
      const bucket = storage.bucket();
      const fileRef = bucket.file(path);
      await fileRef.delete();
    } catch (error) {
      console.error('Error deleting file:', error);
      throw error;
    }
  }

  /**
   * Get download URL for a file
   * @param path Path in storage bucket
   * @returns Download URL
   */
  static async getDownloadURL(path: string): Promise<string> {
    try {
      const bucket = storage.bucket();
      const fileRef = bucket.file(path);
      
      const [url] = await fileRef.getSignedUrl({
        action: 'read',
        expires: '03-09-2491', // Far future date
      });

      return url;
    } catch (error) {
      console.error('Error getting download URL:', error);
      throw error;
    }
  }
}
