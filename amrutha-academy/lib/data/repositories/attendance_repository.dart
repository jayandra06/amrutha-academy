import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_config.dart';
import '../models/attendance_model.dart';

class AttendanceRepository {
  Future<List<AttendanceModel>> getMyAttendance({String? courseId}) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return [];
      }

      final currentUser = FirebaseConfig.auth?.currentUser;
      if (currentUser == null) {
        return [];
      }

      Query<Map<String, dynamic>> query = FirebaseConfig.firestore!
          .collection('attendance')
          .where('userId', isEqualTo: currentUser.uid);
      
      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) return null;
              return AttendanceModel.fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              print('Error parsing attendance ${doc.id}: $e');
              return null;
            }
          })
          .whereType<AttendanceModel>()
          .toList()
        ..sort((a, b) => b.markedAt.compareTo(a.markedAt)); // Most recent first
    } catch (e) {
      print('Error fetching attendance: $e');
      return [];
    }
  }

  Future<AttendanceModel?> markAttendance({
    required String scheduleId,
    required String courseId,
    required String status,
    DateTime? joinedAt,
  }) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return null;
      }

      final currentUser = FirebaseConfig.auth?.currentUser;
      if (currentUser == null) {
        return null;
      }

      final attendanceId = FirebaseConfig.firestore!.collection('attendance').doc().id;
      final attendanceData = {
        'id': attendanceId,
        'userId': currentUser.uid,
        'scheduleId': scheduleId,
        'courseId': courseId,
        'status': status,
        'markedAt': DateTime.now().toIso8601String(),
        if (joinedAt != null) 'joinedAt': joinedAt.toIso8601String(),
      };

      await FirebaseConfig.firestore!
          .collection('attendance')
          .doc(attendanceId)
          .set(attendanceData);

      return AttendanceModel.fromJson(attendanceData);
    } catch (e) {
      print('Error marking attendance: $e');
      return null;
    }
  }
}


