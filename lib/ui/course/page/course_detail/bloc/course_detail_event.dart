import 'package:flutter_bloc_template/base/bloc/base_bloc/base_event.dart';
import 'package:flutter_bloc_template/domain/entity/enum/enum.dart';

sealed class CourseDetailEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

final class FetchCourseDetailEvent extends CourseDetailEvent {
  final String courseId;
  FetchCourseDetailEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

final class EnrollCourseRequestedEvent extends CourseDetailEvent {
  final String courseId;
  EnrollCourseRequestedEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

final class UnenrollCourseRequestedEvent extends CourseDetailEvent {
  final String courseId;
  UnenrollCourseRequestedEvent({required this.courseId});

  @override
  List<Object?> get props => [courseId];
}

final class SubmitCourseReviewEvent extends CourseDetailEvent {
  final String courseId;
  final int rating;
  final String review;
  SubmitCourseReviewEvent({required this.courseId, required this.rating, required this.review});

  @override
  List<Object?> get props => [
        courseId,
        rating,
        review,
      ];
}

final class ToggleFavoriteCourseEvent extends CourseDetailEvent {
}

final class CourseTabChangedEvent extends CourseDetailEvent {
  final CourseTab tab;

  CourseTabChangedEvent({required this.tab});

  @override
  List<Object?> get props => [tab];
}