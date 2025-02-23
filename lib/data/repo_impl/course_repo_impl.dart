import 'dart:async';

import 'package:flutter_bloc_template/base/helper/result.dart';
import 'package:flutter_bloc_template/base/repo/base_repo.dart';
import 'package:flutter_bloc_template/data/data_source/remote/service/course_service.dart';
import 'package:flutter_bloc_template/data/mapper/course/category_mapper.dart';
import 'package:flutter_bloc_template/data/mapper/course/course_mapper.dart';
import 'package:flutter_bloc_template/data/mapper/course/lesson_mapper.dart';
import 'package:flutter_bloc_template/data/mapper/course/mentor_mapper.dart';
import 'package:flutter_bloc_template/data/mapper/course/promote_mapper.dart';
import 'package:flutter_bloc_template/data/mapper/course/review_mapper.dart';
import 'package:flutter_bloc_template/data/mapper/course/search_history_mapper.dart';
import 'package:flutter_bloc_template/domain/entity/course/category_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/course_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/lesson_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/mentor_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/promote_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/review_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';
import 'package:flutter_bloc_template/domain/repo/course_repo.dart';
import 'package:flutter_bloc_template/domain/use_case/course/fetch_course_detail_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/course/toggle_favourite_course_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/course/watch_favorite_course_stream_use_case.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: CourseRepo)
class CourseRepoImpl extends BaseRepository implements CourseRepo {
  final CourseService _courseService;

  CourseRepoImpl(this._courseService);

  final StreamController<WatchFavoriteCourseStreamOutput> _favouriteCourseStreamController = StreamController.broadcast();

  @override
  Future<Result<List<PromoteEntity>>> fetchPromotes() {
    return handleApiCall(
      _courseService.fetchPromotes(),
      mapper: (resp) => resp?.data?.map(PromoteMapper.mapToEntity).toList() ?? [],
    );
  }

  @override
  Future<Result<List<CourseEntity>>> fetchMostPopularCourse() {
    return handleApiCall(
      _courseService.fetchMostPopularCourse(),
      mapper: (resp) => resp?.data?.map(CourseMapper.mapToEntity).toList() ?? [],
    );
  }

  @override
  Future<Result<List<MentorEntity>>> fetchTopMentors() {
    return handleApiCall(
      _courseService.fetchMentors(),
      mapper: (resp) => resp?.data?.map(MentorMapper.mapToEntity).toList() ?? [],
    );
  }

  @override
  Future<Result<List<CategoryEntity>>> fetchCategories() {
    return handleApiCall(
      _courseService.fetchCategories(),
      mapper: (resp) => resp?.data?.map(CategoryMapper.mapToEntity).toList() ?? [],
    );
  }

  @override
  Future<Result<CourseEntity>> fetchCourseDetail(CourseDetailRequest req) {
    return handleApiCall(
      _courseService.fetchCourseFromId(req.id),
      mapper: (resp) => CourseMapper.mapToEntity(resp?.data),
    );
  }

  @override
  Future<Result<List<LessonEntity>>> fetchLessonListFromCourseId(String id) {
    return handleApiCall(
      _courseService.fetchLessonListFromCourseId(id),
      mapper: (resp) => resp?.data?.map(LessonMapper.mapToEntity).toList() ?? [],
    );
  }

  @override
  Future<Result<List<ReviewEntity>>> fetchReviewListFromCourseId(String id) {
    return handleApiCall(
      _courseService.fetchReviewListFromCourseId(id),
      mapper: (resp) => resp?.data?.map(ReviewMapper.mapToEntity).toList() ?? [],
    );
  }

  @override
  Stream<WatchFavoriteCourseStreamOutput> watchFavoriteCourseStream() {
    return _favouriteCourseStreamController.stream;
  }

  @override
  Future<Result<ToggleFavouriteCourseOutput>> toggleFavouriteCourse(ToggleFavouriteCourseInput input) async {
    _favouriteCourseStreamController.add(WatchFavoriteCourseStreamOutput(id: input.id, isFav: !input.isFav));
    return Result.ok(ToggleFavouriteCourseOutput());
  }

  @override
  Future<Result<List<SearchHistoryEntity>>> fetchSearchHistories() {
    return handleApiCall(
      _courseService.fetchSearchHistory(),
      mapper: (resp) => resp?.data?.map<SearchHistoryEntity>(SearchHistoryMapper.mapToEntity).toList() ?? [],
    );
  }

  @override
  Future<Result<List<String>>> fetchSearchSuggestions() {
    return handleApiCall(_courseService.fetchSearchSuggestion(), mapper: (resp) => resp?.data ?? []);
  }
}
