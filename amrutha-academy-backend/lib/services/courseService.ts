import { db } from '@/lib/firebase/config';
import { COLLECTIONS } from '@/lib/firebase/collections';
import { Course, Category, Mentor, Lesson, Review, Promote } from '@/types';

export class CourseService {
  static async getCourseById(courseId: string): Promise<Course | null> {
    try {
      const courseDoc = await db.collection(COLLECTIONS.COURSES).doc(courseId).get();
      
      if (!courseDoc.exists) {
        return null;
      }

      const data = courseDoc.data();
      return await this.mapCourseData(courseDoc.id, data);
    } catch (error) {
      console.error('Error fetching course:', error);
      throw error;
    }
  }

  static async getPopularCourses(limit: number = 10): Promise<Course[]> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.COURSES)
        .orderBy('students', 'desc')
        .limit(limit)
        .get();

      const courses = await Promise.all(
        snapshot.docs.map(doc => this.mapCourseData(doc.id, doc.data()))
      );

      return courses;
    } catch (error) {
      console.error('Error fetching popular courses:', error);
      throw error;
    }
  }

  static async getLessonsByCourseId(courseId: string): Promise<Lesson[]> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.LESSONS)
        .where('courseId', '==', courseId)
        .orderBy('order', 'asc')
        .get();

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          title: data?.title || '',
          duration: data?.duration || 0,
          videoUrl: data?.videoUrl || '',
          isFree: data?.isFree || false,
        } as Lesson;
      });
    } catch (error) {
      console.error('Error fetching lessons:', error);
      throw error;
    }
  }

  static async getReviewsByCourseId(courseId: string): Promise<Review[]> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.REVIEWS)
        .where('courseId', '==', courseId)
        .orderBy('createdAt', 'desc')
        .get();

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          courseId: data?.courseId || '',
          userId: data?.userId || '',
          rating: data?.rating || 0,
          comment: data?.comment || '',
          createdAt: data?.createdAt?.toDate?.().toISOString() || data?.createdAt || '',
        } as Review;
      });
    } catch (error) {
      console.error('Error fetching reviews:', error);
      throw error;
    }
  }

  private static async mapCourseData(id: string, data: any): Promise<Course> {
    // Fetch mentor if mentorId exists
    let mentor: Mentor = {
      id: '',
      name: '',
      title: '',
      avatarUrl: '',
    };

    if (data?.mentorId) {
      try {
        const mentorDoc = await db.collection(COLLECTIONS.MENTORS).doc(data.mentorId).get();
        if (mentorDoc.exists) {
          const mentorData = mentorDoc.data();
          mentor = {
            id: mentorDoc.id,
            name: mentorData?.name || '',
            title: mentorData?.title || '',
            avatarUrl: mentorData?.avatarUrl || '',
          };
        }
      } catch (error) {
        console.error('Error fetching mentor:', error);
      }
    }

    return {
      id,
      title: data?.title || '',
      category: data?.category || '',
      image: data?.image || '',
      price: data?.price || 0,
      originalPrice: data?.originalPrice || 0,
      rating: data?.rating || 0,
      reviewsCount: data?.reviewsCount || 0,
      students: data?.students || 0,
      duration: data?.duration || 0,
      certificate: data?.certificate || false,
      mentor,
      tools: data?.tools || [],
      about: data?.about || '',
      isFavourite: data?.isFavourite || false,
    } as Course;
  }
}

export class CategoryService {
  static async getAllCategories(): Promise<Category[]> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.CATEGORIES)
        .orderBy('name', 'asc')
        .get();

      return snapshot.docs.map(doc => ({
        id: doc.id,
        name: doc.data()?.name || '',
      } as Category));
    } catch (error) {
      console.error('Error fetching categories:', error);
      throw error;
    }
  }
}

export class MentorService {
  static async getAllMentors(): Promise<Mentor[]> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.MENTORS)
        .orderBy('name', 'asc')
        .get();

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          name: data?.name || '',
          title: data?.title || '',
          avatarUrl: data?.avatarUrl || '',
        } as Mentor;
      });
    } catch (error) {
      console.error('Error fetching mentors:', error);
      throw error;
    }
  }
}

export class PromoteService {
  static async getActivePromotes(): Promise<Promote[]> {
    try {
      const snapshot = await db
        .collection(COLLECTIONS.PROMOTES)
        .where('isActive', '==', true)
        .orderBy('expiryDate', 'asc')
        .get();

      return snapshot.docs.map(doc => {
        const data = doc.data();
        return {
          id: doc.id,
          title: data?.title || '',
          description: data?.description || '',
          discount: data?.discount || '',
          isActive: data?.isActive || false,
          expiryDate: data?.expiryDate?.toDate?.().toISOString() || data?.expiryDate || '',
        } as Promote;
      });
    } catch (error) {
      console.error('Error fetching promotes:', error);
      throw error;
    }
  }
}
