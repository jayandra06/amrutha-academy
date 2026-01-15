import '../../../services/api_service.dart';
import '../models/api_response.dart';
import '../models/course_model.dart';
import '../../core/config/di_config.dart';
import 'package:get_it/get_it.dart';

class CourseRepository {
  final ApiService _apiService = GetIt.instance<ApiService>();

  Future<List<CourseModel>> getCoursesByLevel(int level) async {
    try {
      final response = await _apiService.get<List<CourseModel>>(
        '/courses/by-level?level=$level',
        fromJson: (json) {
          if (json is List) {
            return (json as List).map((item) => CourseModel.fromJson(item as Map<String, dynamic>)).toList();
          }
          return [];
        },
      );

      if (response.isSuccess && response.data != null) {
        return response.data!;
      }
      return [];
    } catch (e) {
      print('Error fetching courses: $e');
      return [];
    }
  }

  Future<CourseModel?> getCourseById(String courseId) async {
    try {
      final response = await _apiService.get<CourseModel>(
        '/course/$courseId',
        fromJson: (json) => CourseModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.isSuccess && response.data != null) {
        return response.data;
      }
      return null;
    } catch (e) {
      print('Error fetching course: $e');
      return null;
    }
  }
}

