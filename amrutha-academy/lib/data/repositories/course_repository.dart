import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/course_model.dart';
import '../../core/config/firebase_config.dart';

class CourseRepository {
  Future<List<CourseModel>> getCoursesByLevel(int level) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return [];
      }

      final snapshot = await FirebaseConfig.firestore!
          .collection('courses')
          .where('level', isEqualTo: level)
          .get();

      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return CourseModel.fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              print('Error parsing course ${doc.id}: $e');
              return null;
            }
          })
          .whereType<CourseModel>()
          .toList();
    } catch (e) {
      print('Error fetching courses by level: $e');
      return [];
    }
  }

  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return null;
      }

      final doc = await FirebaseConfig.firestore!
          .collection('courses')
          .doc(courseId)
          .get();

      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>;
        return CourseModel.fromJson({
          'id': doc.id,
          ...data,
        });
      }
      return null;
    } catch (e) {
      print('Error fetching course: $e');
      return null;
    }
  }

  Future<List<CourseModel>> getAllCourses() async {
    // Load from Firestore directly
    try {
      if (FirebaseConfig.firestore == null) {
        print('⚠️ Firestore not initialized');
        return [];
      }

      final coursesSnapshot = await FirebaseConfig.firestore!
          .collection('courses')
          .get();

      final courses = coursesSnapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>;
              return CourseModel.fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              print('Error parsing course ${doc.id}: $e');
              return null;
            }
          })
          .whereType<CourseModel>()
          .toList();

      print('✅ Loaded ${courses.length} courses from Firestore');
      return courses;
    } catch (e) {
      print('❌ Firestore fetch error: $e');
      return [];
    }
  }
}

