// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:auto_route/auto_route.dart' as _i21;
import 'package:flutter/material.dart' as _i22;
import 'package:flutter_bloc_template/ui/course/page/course_detail/course_detail_page.dart'
    as _i1;
import 'package:flutter_bloc_template/ui/course/page/course_list/course_list_page.dart'
    as _i2;
import 'package:flutter_bloc_template/ui/course/page/lesson_video_player/lesson_video_player_page.dart'
    as _i8;
import 'package:flutter_bloc_template/ui/home/home_page.dart' as _i5;
import 'package:flutter_bloc_template/ui/home/page/home_search/home_search_page.dart'
    as _i6;
import 'package:flutter_bloc_template/ui/inbox/inbox_page.dart' as _i7;
import 'package:flutter_bloc_template/ui/let_in/let_in_page.dart' as _i9;
import 'package:flutter_bloc_template/ui/login/login_page.dart' as _i10;
import 'package:flutter_bloc_template/ui/main/main_page.dart' as _i11;
import 'package:flutter_bloc_template/ui/my_course/my_course_page.dart' as _i12;
import 'package:flutter_bloc_template/ui/onboarding/onboarding_page.dart'
    as _i13;
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/edit_profile_page.dart'
    as _i3;
import 'package:flutter_bloc_template/ui/profile/pages/help_center/help_center_page.dart'
    as _i4;
import 'package:flutter_bloc_template/ui/profile/pages/setting_language/setting_language_page.dart'
    as _i15;
import 'package:flutter_bloc_template/ui/profile/pages/setting_notification/setting_notification_page.dart'
    as _i16;
import 'package:flutter_bloc_template/ui/profile/pages/setting_payment/setting_payment_page.dart'
    as _i17;
import 'package:flutter_bloc_template/ui/profile/profile_page.dart' as _i14;
import 'package:flutter_bloc_template/ui/sign_up/sign_up_page.dart' as _i18;
import 'package:flutter_bloc_template/ui/splash/splash_page.dart' as _i19;
import 'package:flutter_bloc_template/ui/transaction/transaction_page.dart'
    as _i20;

/// generated route for
/// [_i1.CourseDetailPage]
class CourseDetailRoute extends _i21.PageRouteInfo<CourseDetailRouteArgs> {
  CourseDetailRoute({
    _i22.Key? key,
    required String id,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          CourseDetailRoute.name,
          args: CourseDetailRouteArgs(
            key: key,
            id: id,
          ),
          rawPathParams: {'id': id},
          initialChildren: children,
        );

  static const String name = 'CourseDetailRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<CourseDetailRouteArgs>(
          orElse: () => CourseDetailRouteArgs(id: pathParams.getString('id')));
      return _i1.CourseDetailPage(
        key: args.key,
        id: args.id,
      );
    },
  );
}

class CourseDetailRouteArgs {
  const CourseDetailRouteArgs({
    this.key,
    required this.id,
  });

  final _i22.Key? key;

  final String id;

  @override
  String toString() {
    return 'CourseDetailRouteArgs{key: $key, id: $id}';
  }
}

/// generated route for
/// [_i2.CourseListPage]
class CourseListRoute extends _i21.PageRouteInfo<void> {
  const CourseListRoute({List<_i21.PageRouteInfo>? children})
      : super(
          CourseListRoute.name,
          initialChildren: children,
        );

  static const String name = 'CourseListRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i2.CourseListPage();
    },
  );
}

/// generated route for
/// [_i3.EditProfilePage]
class EditProfileRoute extends _i21.PageRouteInfo<void> {
  const EditProfileRoute({List<_i21.PageRouteInfo>? children})
      : super(
          EditProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'EditProfileRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i3.EditProfilePage();
    },
  );
}

/// generated route for
/// [_i4.HelpCenterPage]
class HelpCenterRoute extends _i21.PageRouteInfo<void> {
  const HelpCenterRoute({List<_i21.PageRouteInfo>? children})
      : super(
          HelpCenterRoute.name,
          initialChildren: children,
        );

  static const String name = 'HelpCenterRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i4.HelpCenterPage();
    },
  );
}

/// generated route for
/// [_i5.HomePage]
class HomeRoute extends _i21.PageRouteInfo<void> {
  const HomeRoute({List<_i21.PageRouteInfo>? children})
      : super(
          HomeRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i5.HomePage();
    },
  );
}

/// generated route for
/// [_i6.HomeSearchPage]
class HomeSearchRoute extends _i21.PageRouteInfo<void> {
  const HomeSearchRoute({List<_i21.PageRouteInfo>? children})
      : super(
          HomeSearchRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomeSearchRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i6.HomeSearchPage();
    },
  );
}

/// generated route for
/// [_i7.InboxPage]
class InboxRoute extends _i21.PageRouteInfo<void> {
  const InboxRoute({List<_i21.PageRouteInfo>? children})
      : super(
          InboxRoute.name,
          initialChildren: children,
        );

  static const String name = 'InboxRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i7.InboxPage();
    },
  );
}

/// generated route for
/// [_i8.LessonVideoPlayerPage]
class LessonVideoPlayerRoute
    extends _i21.PageRouteInfo<LessonVideoPlayerRouteArgs> {
  LessonVideoPlayerRoute({
    _i22.Key? key,
    required String videoUrl,
    String? title,
    List<_i21.PageRouteInfo>? children,
  }) : super(
          LessonVideoPlayerRoute.name,
          args: LessonVideoPlayerRouteArgs(
            key: key,
            videoUrl: videoUrl,
            title: title,
          ),
          initialChildren: children,
        );

  static const String name = 'LessonVideoPlayerRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LessonVideoPlayerRouteArgs>();
      return _i8.LessonVideoPlayerPage(
        key: args.key,
        videoUrl: args.videoUrl,
        title: args.title,
      );
    },
  );
}

class LessonVideoPlayerRouteArgs {
  const LessonVideoPlayerRouteArgs({
    this.key,
    required this.videoUrl,
    this.title,
  });

  final _i22.Key? key;

  final String videoUrl;

  final String? title;

  @override
  String toString() {
    return 'LessonVideoPlayerRouteArgs{key: $key, videoUrl: $videoUrl, title: $title}';
  }
}

/// generated route for
/// [_i9.LetInPage]
class LetInRoute extends _i21.PageRouteInfo<void> {
  const LetInRoute({List<_i21.PageRouteInfo>? children})
      : super(
          LetInRoute.name,
          initialChildren: children,
        );

  static const String name = 'LetInRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i9.LetInPage();
    },
  );
}

/// generated route for
/// [_i10.LoginPage]
class LoginRoute extends _i21.PageRouteInfo<void> {
  const LoginRoute({List<_i21.PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i10.LoginPage();
    },
  );
}

/// generated route for
/// [_i11.MainPage]
class MainRoute extends _i21.PageRouteInfo<void> {
  const MainRoute({List<_i21.PageRouteInfo>? children})
      : super(
          MainRoute.name,
          initialChildren: children,
        );

  static const String name = 'MainRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i11.MainPage();
    },
  );
}

/// generated route for
/// [_i12.MyCoursePage]
class MyCourseRoute extends _i21.PageRouteInfo<void> {
  const MyCourseRoute({List<_i21.PageRouteInfo>? children})
      : super(
          MyCourseRoute.name,
          initialChildren: children,
        );

  static const String name = 'MyCourseRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i12.MyCoursePage();
    },
  );
}

/// generated route for
/// [_i13.OnboardingPage]
class OnboardingRoute extends _i21.PageRouteInfo<void> {
  const OnboardingRoute({List<_i21.PageRouteInfo>? children})
      : super(
          OnboardingRoute.name,
          initialChildren: children,
        );

  static const String name = 'OnboardingRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i13.OnboardingPage();
    },
  );
}

/// generated route for
/// [_i14.ProfilePage]
class ProfileRoute extends _i21.PageRouteInfo<void> {
  const ProfileRoute({List<_i21.PageRouteInfo>? children})
      : super(
          ProfileRoute.name,
          initialChildren: children,
        );

  static const String name = 'ProfileRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i14.ProfilePage();
    },
  );
}

/// generated route for
/// [_i15.SettingLanguagePage]
class SettingLanguageRoute extends _i21.PageRouteInfo<void> {
  const SettingLanguageRoute({List<_i21.PageRouteInfo>? children})
      : super(
          SettingLanguageRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingLanguageRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i15.SettingLanguagePage();
    },
  );
}

/// generated route for
/// [_i16.SettingNotificationPage]
class SettingNotificationRoute extends _i21.PageRouteInfo<void> {
  const SettingNotificationRoute({List<_i21.PageRouteInfo>? children})
      : super(
          SettingNotificationRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingNotificationRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i16.SettingNotificationPage();
    },
  );
}

/// generated route for
/// [_i17.SettingPaymentPage]
class SettingPaymentRoute extends _i21.PageRouteInfo<void> {
  const SettingPaymentRoute({List<_i21.PageRouteInfo>? children})
      : super(
          SettingPaymentRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingPaymentRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i17.SettingPaymentPage();
    },
  );
}

/// generated route for
/// [_i18.SignUpPage]
class SignUpRoute extends _i21.PageRouteInfo<void> {
  const SignUpRoute({List<_i21.PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i18.SignUpPage();
    },
  );
}

/// generated route for
/// [_i19.SplashPage]
class SplashRoute extends _i21.PageRouteInfo<void> {
  const SplashRoute({List<_i21.PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i19.SplashPage();
    },
  );
}

/// generated route for
/// [_i20.TransactionPage]
class TransactionRoute extends _i21.PageRouteInfo<void> {
  const TransactionRoute({List<_i21.PageRouteInfo>? children})
      : super(
          TransactionRoute.name,
          initialChildren: children,
        );

  static const String name = 'TransactionRoute';

  static _i21.PageInfo page = _i21.PageInfo(
    name,
    builder: (data) {
      return const _i20.TransactionPage();
    },
  );
}
