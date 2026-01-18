import '../../../services/api_service.dart';
import '../models/api_response.dart';
import '../models/enrollment_model.dart';
import '../../core/config/di_config.dart';
import 'package:get_it/get_it.dart';

class EnrollmentRepository {
  final ApiService _apiService = GetIt.instance<ApiService>();

  Future<List<EnrollmentModel>> getMyEnrollments() async {
    try {
      final response = await _apiService.get<List<EnrollmentModel>>(
        '/courses/my-enrollments',
        fromJson: (json) {
          if (json is List) {
            return (json as List).map((item) => EnrollmentModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('Error fetching enrollments: $e');
      return [];
    }
  }

  Future<EnrollmentModel?> enrollInCourse(String courseId) async {
    try {
      final response = await _apiService.post<EnrollmentModel>(
        '/courses/enroll',
        data: {'courseId': courseId},
        fromJson: (json) => EnrollmentModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.isSuccess && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error enrolling in course: $e');
      return null;
    }
  }

  Future<List<EnrollmentModel>> getEnrollmentsByUserId(String userId) async {
    try {
      final response = await _apiService.get<List<EnrollmentModel>>(
        '/courses/enrollments?userId=$userId',
        fromJson: (json) {
          if (json is List) {
            return (json as List).map((item) => EnrollmentModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('Error fetching enrollments: $e');
      return [];
    }
  }
}

