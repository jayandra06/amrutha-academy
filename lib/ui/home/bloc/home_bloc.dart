import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/base/bloc/base_bloc/base_bloc.dart';
import 'package:flutter_bloc_template/domain/entity/course/category_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/course_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/mentor_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/promote_entity.dart';
import 'package:flutter_bloc_template/domain/use_case/course/fetch_category_list_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/course/fetch_most_popular_course_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/course/fetch_promote_list_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/course/fetch_top_mentor_list_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/course/toggle_favourite_course_use_case.dart';
import 'package:flutter_bloc_template/domain/use_case/user/fetch_profile_use_case.dart';
import 'package:flutter_bloc_template/ui/home/bloc/home_event.dart';
import 'package:flutter_bloc_template/ui/home/bloc/home_state.dart';
import 'package:injectable/injectable.dart';

import '../../../domain/use_case/course/watch_favorite_course_stream_use_case.dart';

@injectable
class HomeBloc extends BaseBloc<HomeEvent, HomeState> {
  HomeBloc(
    this._fetchPromoteListUseCase,
    this._fetchMostPopularCourseUseCase,
    this._fetchTopMentorListUseCase,
    this._fetchCategoryListUseCase,
    this._fetchProfileUseCase,
    this._watchFavoriteCourseStreamUseCase,
    this._toggleFavouriteCourseUseCase,
  ) : super(HomeState(categoryId: 'all')) {
    on<HomeDataRequestedEvent>(_onHomeDataRequestedEvent);
    on<HomeCategoryChangedEvent>(_onHomeCategoryChangedEvent);
    on<HomeProfileRequestEvent>(_onHomeProfileRequestEvent);
  }

  final FetchPromoteListUseCase _fetchPromoteListUseCase;
  final FetchMostPopularCourseUseCase _fetchMostPopularCourseUseCase;
  final FetchTopMentorListUseCase _fetchTopMentorListUseCase;
  final FetchCategoryListUseCase _fetchCategoryListUseCase;
  final FetchProfileUseCase _fetchProfileUseCase;
  final WatchFavoriteCourseStreamUseCase _watchFavoriteCourseStreamUseCase;
  final ToggleFavouriteCourseUseCase _toggleFavouriteCourseUseCase;

  Future<void> _onHomeDataRequestedEvent(HomeDataRequestedEvent event, Emitter<HomeState> emit) async {
    return runAction(
      onAction: () async {
        final apiCalls = [
          _fetchPromoteListUseCase.invoke(null),
          _fetchTopMentorListUseCase.invoke(null),
          _fetchCategoryListUseCase.invoke(null),
          _fetchMostPopularCourseUseCase.invoke(null),
        ];
        final result = await Future.wait(apiCalls);

        final emitters = [
          (data) => emit(state.copyWith(promotes: data as List<PromoteEntity>)),
          (data) => emit(state.copyWith(mentors: data as List<MentorEntity>)),
          (data) => emit(state.copyWith(categories: data as List<CategoryEntity>)),
          (data) => emit(state.copyWith(courses: data as List<CourseEntity>)),
        ];

        for (int i = 0; i < result.length; i++) {
          result[i].when(ok: emitters[i]);
        }
      },
    );
  }

  FutureOr<void> _onHomeCategoryChangedEvent(HomeCategoryChangedEvent event, Emitter<HomeState> emit) {
    emit(state.copyWith(categoryId: event.id));
  }

  FutureOr<void> _onHomeProfileRequestEvent(HomeProfileRequestEvent event, Emitter<HomeState> emit) {
    return runAction(
      onAction: () async {
        await _fetchProfileUseCase.invoke(null);
      },
      handleLoading: false,
      onError: (e) {
      }
    );
  }
}
