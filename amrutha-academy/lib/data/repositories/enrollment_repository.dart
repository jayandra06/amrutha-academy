import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/enrollment_model.dart';
import '../../core/config/firebase_config.dart';

class EnrollmentRepository {
  Future<List<EnrollmentModel>> getMyEnrollments() async {
    try {
      if (FirebaseConfig.firestore == null) {
        return [];
      }

      final currentUser = FirebaseConfig.auth?.currentUser;
      if (currentUser == null) {
        return [];
      }

      final snapshot = await FirebaseConfig.firestore!
          .collection('enrollments')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) return null;
              return EnrollmentModel.fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              print('Error parsing enrollment ${doc.id}: $e');
              return null;
            }
          })
          .whereType<EnrollmentModel>()
          .toList();
    } catch (e) {
      print('Error fetching enrollments: $e');
      return [];
    }
  }

  Future<EnrollmentModel?> enrollInCourse(String courseId) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return null;
      }

      final currentUser = FirebaseConfig.auth?.currentUser;
      if (currentUser == null) {
        return null;
      }

      final enrollmentId = FirebaseConfig.firestore!.collection('enrollments').doc().id;
      final enrollmentData = {
        'id': enrollmentId,
        'userId': currentUser.uid,
        'courseId': courseId,
        'enrolledAt': DateTime.now().toIso8601String(),
        'status': 'active',
      };

      await FirebaseConfig.firestore!
          .collection('enrollments')
          .doc(enrollmentId)
          .set(enrollmentData);

      return EnrollmentModel.fromJson(enrollmentData);
    } catch (e) {
      print('Error enrolling in course: $e');
      return null;
    }
  }

  Future<List<EnrollmentModel>> getEnrollmentsByUserId(String userId) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return [];
      }

      final snapshot = await FirebaseConfig.firestore!
          .collection('enrollments')
          .where('userId', isEqualTo: userId)
          .get();

      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) return null;
              return EnrollmentModel.fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              print('Error parsing enrollment ${doc.id}: $e');
              return null;
            }
          })
          .whereType<EnrollmentModel>()
          .toList();
    } catch (e) {
      print('Error fetching enrollments: $e');
      return [];
    }
  }
}

