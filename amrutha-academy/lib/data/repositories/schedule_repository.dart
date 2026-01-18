import 'package:cloud_firestore/cloud_firestore.dart';
import '../../core/config/firebase_config.dart';
import '../models/schedule_model.dart';

class ScheduleRepository {
  Future<List<ScheduleModel>> getUpcomingSchedules({String? courseId}) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return [];
      }

      Query<Map<String, dynamic>> query = FirebaseConfig.firestore!.collection('schedules');
      
      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }
      
      // Get all schedules and filter by date
      final snapshot = await query.get();
      final now = DateTime.now();

      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) return null;
              return ScheduleModel.fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              print('Error parsing schedule ${doc.id}: $e');
              return null;
            }
          })
          .whereType<ScheduleModel>()
          .where((schedule) => schedule.endTime.isAfter(now))
          .toList()
        ..sort((a, b) => a.startTime.compareTo(b.startTime));
    } catch (e) {
      print('Error fetching upcoming schedules: $e');
      return [];
    }
  }

  Future<List<ScheduleModel>> getPastSchedules({String? courseId}) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return [];
      }

      Query<Map<String, dynamic>> query = FirebaseConfig.firestore!.collection('schedules');
      
      if (courseId != null) {
        query = query.where('courseId', isEqualTo: courseId);
      }
      
      final snapshot = await query.get();
      final now = DateTime.now();

      return snapshot.docs
          .map((doc) {
            try {
              final data = doc.data() as Map<String, dynamic>?;
              if (data == null) return null;
              return ScheduleModel.fromJson({
                'id': doc.id,
                ...data,
              });
            } catch (e) {
              print('Error parsing schedule ${doc.id}: $e');
              return null;
            }
          })
          .whereType<ScheduleModel>()
          .where((schedule) => schedule.endTime.isBefore(now))
          .toList()
        ..sort((a, b) => b.startTime.compareTo(a.startTime)); // Most recent first
    } catch (e) {
      print('Error fetching past schedules: $e');
      return [];
    }
  }

  Future<ScheduleModel?> createSchedule(Map<String, dynamic> scheduleData) async {
    try {
      if (FirebaseConfig.firestore == null) {
        return null;
      }

      final scheduleId = FirebaseConfig.firestore!.collection('schedules').doc().id;

      final data = {
        ...scheduleData,
        'id': scheduleId,
      };

      await FirebaseConfig.firestore!
          .collection('schedules')
          .doc(scheduleId)
          .set(data);

      return ScheduleModel.fromJson(data);
    } catch (e) {
      print('Error creating schedule: $e');
      return null;
    }
  }
}

