// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../base/bloc/app_bloc/app_bloc.dart' as _i334;
import '../base/bloc/common_bloc/common_bloc.dart' as _i63;
import '../base/navigator/app_navigator.dart' as _i414;
import '../data/data_source/local/app_shared_preferences.dart' as _i906;
import '../data/data_source/remote/service/auth_service.dart' as _i762;
import '../data/data_source/remote/service/course_service.dart' as _i417;
import '../data/data_source/remote/service/user_service.dart' as _i867;
import '../data/network/interceptors/access_token_interceptor.dart' as _i355;
import '../data/network/interceptors/refresh_token_interceptor.dart' as _i746;
import '../data/repo_impl/auth_repo_impl.dart' as _i183;
import '../data/repo_impl/course_repo_impl.dart' as _i396;
import '../data/repo_impl/user_repo_impl.dart' as _i1027;
import '../domain/repo/auth_repo.dart' as _i623;
import '../domain/repo/course_repo.dart' as _i492;
import '../domain/repo/user_repo.dart' as _i575;
import '../domain/use_case/auth/login_use_case.dart' as _i924;
import '../domain/use_case/auth/logout_use_case.dart' as _i92;
import '../domain/use_case/config/load_app_config_use_case.dart' as _i839;
import '../domain/use_case/course/fetch_category_list_use_case.dart' as _i1026;
import '../domain/use_case/course/fetch_course_detail_use_case.dart' as _i538;
import '../domain/use_case/course/fetch_lesson_list_from_course_id_use_case.dart'
    as _i430;
import '../domain/use_case/course/fetch_most_popular_course_use_case.dart'
    as _i280;
import '../domain/use_case/course/fetch_promote_list_use_case.dart' as _i974;
import '../domain/use_case/course/fetch_review_list_from_course_id_use_case.dart'
    as _i408;
import '../domain/use_case/course/fetch_top_mentor_list_use_case.dart' as _i193;
import '../domain/use_case/course/toggle_favourite_course_use_case.dart'
    as _i954;
import '../domain/use_case/course/watch_favorite_course_stream_use_case.dart'
    as _i399;
import '../domain/use_case/user/fetch_profile_use_case.dart' as _i79;
import '../domain/use_case/user/listen_user_profile_stream_use_case.dart'
    as _i360;
import '../navigation/app_navigator_impl.dart' as _i285;
import '../navigation/router.dart' as _i502;
import '../ui/course/page/course_detail/bloc/course_detail_bloc.dart' as _i942;
import '../ui/course/page/course_list/bloc/course_list_bloc.dart' as _i792;
import '../ui/home/bloc/home_bloc.dart' as _i401;
import '../ui/home/page/home_search/bloc/home_search_bloc.dart' as _i702;
import '../ui/login/bloc/login_bloc.dart' as _i919;

extension GetItInjectableX on _i174.GetIt {
// initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(
      this,
      environment,
      environmentFilter,
    );
    gh.factory<_i702.HomeSearchBloc>(() => _i702.HomeSearchBloc());
    gh.factory<_i792.CourseListBloc>(() => _i792.CourseListBloc());
    gh.factory<_i919.LoginBloc>(() => _i919.LoginBloc());
    gh.factory<_i839.LoadAppConfigUseCase>(() => _i839.LoadAppConfigUseCase());
    gh.factory<_i92.LogoutUseCase>(() => _i92.LogoutUseCase());
    gh.singleton<_i334.AppBloc>(() => _i334.AppBloc());
    gh.lazySingleton<_i502.AppRouter>(() => _i502.AppRouter());
    gh.lazySingleton<_i417.CourseService>(
        () => _i417.CourseService(gh<_i361.Dio>()));
    gh.lazySingleton<_i762.AuthService>(
        () => _i762.AuthService(gh<_i361.Dio>()));
    gh.lazySingleton<_i867.UserService>(
        () => _i867.UserService(gh<_i361.Dio>()));
    gh.lazySingleton<_i355.AccessTokenInterceptor>(
        () => _i355.AccessTokenInterceptor(gh<_i906.AppSharedPreferences>()));
    gh.factory<_i63.CommonBloc>(
        () => _i63.CommonBloc(gh<_i92.LogoutUseCase>()));
    gh.lazySingleton<_i623.AuthRepo>(
        () => _i183.AuthRepoImpl(gh<_i762.AuthService>()));
    gh.lazySingleton<_i414.AppNavigator>(
        () => _i285.AppNavigatorImpl(gh<_i502.AppRouter>()));
    gh.lazySingleton<_i746.RefreshTokenInterceptor>(
        () => _i746.RefreshTokenInterceptor(
              gh<_i906.AppSharedPreferences>(),
              gh<_i361.Dio>(),
            ));
    gh.lazySingleton<_i575.UserRepo>(
        () => _i1027.UserRepoImpl(gh<_i867.UserService>()));
    gh.lazySingleton<_i492.CourseRepo>(
        () => _i396.CourseRepoImpl(gh<_i417.CourseService>()));
    gh.factory<_i79.FetchProfileUseCase>(
        () => _i79.FetchProfileUseCase(gh<_i575.UserRepo>()));
    gh.factory<_i360.ListenUserProfileStreamUseCase>(
        () => _i360.ListenUserProfileStreamUseCase(gh<_i575.UserRepo>()));
    gh.factory<_i924.LoginUseCase>(
        () => _i924.LoginUseCase(gh<_i623.AuthRepo>()));
    gh.factory<_i974.FetchPromoteListUseCase>(
        () => _i974.FetchPromoteListUseCase(gh<_i492.CourseRepo>()));
    gh.factory<_i954.ToggleFavouriteCourseUseCase>(
        () => _i954.ToggleFavouriteCourseUseCase(gh<_i492.CourseRepo>()));
    gh.factory<_i399.WatchFavoriteCourseStreamUseCase>(
        () => _i399.WatchFavoriteCourseStreamUseCase(gh<_i492.CourseRepo>()));
    gh.factory<_i1026.FetchCategoryListUseCase>(
        () => _i1026.FetchCategoryListUseCase(gh<_i492.CourseRepo>()));
    gh.factory<_i280.FetchMostPopularCourseUseCase>(
        () => _i280.FetchMostPopularCourseUseCase(gh<_i492.CourseRepo>()));
    gh.factory<_i408.FetchReviewListFromCourseIdUseCase>(
        () => _i408.FetchReviewListFromCourseIdUseCase(gh<_i492.CourseRepo>()));
    gh.factory<_i430.FetchLessonListFromCourseIdUseCase>(
        () => _i430.FetchLessonListFromCourseIdUseCase(gh<_i492.CourseRepo>()));
    gh.factory<_i538.FetchCourseDetailUseCase>(
        () => _i538.FetchCourseDetailUseCase(gh<_i492.CourseRepo>()));
    gh.factory<_i193.FetchTopMentorListUseCase>(
        () => _i193.FetchTopMentorListUseCase(gh<_i492.CourseRepo>()));
    gh.factory<_i401.HomeBloc>(() => _i401.HomeBloc(
          gh<_i974.FetchPromoteListUseCase>(),
          gh<_i280.FetchMostPopularCourseUseCase>(),
          gh<_i193.FetchTopMentorListUseCase>(),
          gh<_i1026.FetchCategoryListUseCase>(),
          gh<_i79.FetchProfileUseCase>(),
          gh<_i399.WatchFavoriteCourseStreamUseCase>(),
          gh<_i954.ToggleFavouriteCourseUseCase>(),
        ));
    gh.factory<_i942.CourseDetailBloc>(() => _i942.CourseDetailBloc(
          gh<_i538.FetchCourseDetailUseCase>(),
          gh<_i430.FetchLessonListFromCourseIdUseCase>(),
          gh<_i408.FetchReviewListFromCourseIdUseCase>(),
          gh<_i954.ToggleFavouriteCourseUseCase>(),
        ));
    return this;
  }
}
