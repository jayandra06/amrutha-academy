import 'package:flutter_bloc_template/domain/entity/course/category_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/course_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/lesson_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/promote_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/review_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';
import 'package:flutter_bloc_template/domain/use_case/course/fetch_course_detail_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/course/toggle_favourite_course_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/course/watch_favorite_course_stream_use_case.dart';

import '../../base/helper/result.dart';
import '../entity/course/mentor_entity.dart';

abstract class CourseRepo {
  Future<Result<List<PromoteEntity>>> fetchPromotes();

  Future<Result<List<CourseEntity>>> fetchMostPopularCourse();

  Future<Result<List<MentorEntity>>> fetchTopMentors();

  Future<Result<List<CategoryEntity>>> fetchCategories();

  Future<Result<List<LessonEntity>>> fetchLessonListFromCourseId(String id);

  Future<Result<List<ReviewEntity>>> fetchReviewListFromCourseId(String id);

  Future<Result<CourseEntity>> fetchCourseDetail(CourseDetailRequest req);

  Stream<WatchFavoriteCourseStreamOutput> watchFavoriteCourseStream();

  Future<Result<ToggleFavouriteCourseOutput>> toggleFavouriteCourse(ToggleFavouriteCourseInput input);

  Future<Result<List<String>>> fetchSearchSuggestions();

  Future<Result<List<SearchHistoryEntity>>> fetchSearchHistories();
}
