import 'package:flutter/cupertino.dart';

import '../../../resource/generated/assets.gen.dart';
import '../../../resource/generated/l10n.dart';

enum SocialAuthProvider {
  google,
  facebook,
  apple;

  String fromTitle() {
    return switch (this) {
      SocialAuthProvider.google => S.current.google,
      SocialAuthProvider.facebook => S.current.facebook,
      SocialAuthProvider.apple => S.current.apple,
    };
  }

  Widget fromWidget() {
    return switch (this) {
      SocialAuthProvider.google => Assets.images.google.image(width: 24),
      SocialAuthProvider.facebook => Assets.images.facebook.image(width: 24),
      SocialAuthProvider.apple => Assets.images.apple.image(width: 24),
    };
  }
}

enum BottomTab {
  home,
  myCourse,
  inbox,
  transcation,
  profile;

  Widget fromWidget([bool enable = false]) {
    final path = switch (this) {
      BottomTab.home => enable ? Assets.icons.homeEnable : Assets.icons.home,
      BottomTab.myCourse => enable ? Assets.icons.documentEnable : Assets.icons.document,
      BottomTab.inbox => enable ? Assets.icons.chatEnable : Assets.icons.chat,
      BottomTab.transcation => enable ? Assets.icons.buyEnable : Assets.icons.buy,
      BottomTab.profile => enable ? Assets.icons.profileEnable : Assets.icons.profile,
    };

    return path.svg(width: 24, height: 24);
  }

  String fromTitle() {
    return switch (this) {
      BottomTab.home => S.current.home,
      BottomTab.myCourse => S.current.my_course,
      BottomTab.inbox => S.current.inbox,
      BottomTab.transcation => S.current.transaction,
      BottomTab.profile => S.current.profile,
    };
  }
}

enum CourseTab {
  about,
  lessons,
  reviews;

  String fromTitle() {
    return switch (this) {
      CourseTab.about => 'About',
      CourseTab.lessons => 'Lessons',
      CourseTab.reviews => 'Reviews',
    };
  }
}

enum RatingFilter {
  all(0),
  fiveStars(5),
  fourStars(4),
  threeStars(3),
  twoStars(2),
  oneStars(1);

  const RatingFilter(this.code);
  final int code;

  String fromTitle() {
    return switch (this) {
      RatingFilter.all => 'All',
      RatingFilter.fiveStars => '5',
      RatingFilter.fourStars => '4',
      RatingFilter.threeStars => '3',
      RatingFilter.twoStars => '2',
      RatingFilter.oneStars => '1',
    };
  }
}

enum MyCourseTab {
  onGoing,
  completed;

  String fromTitle() {
    return switch (this) {
      MyCourseTab.onGoing => 'OnGoing',
      MyCourseTab.completed => 'Completed',
    };
  }
}

enum InboxTab {
  chat,
  call;

  String fromTitle() {
    return switch (this) {
      InboxTab.chat => 'Chats',
      InboxTab.call => 'Calls',
    };
  }
}

enum SearchResultTab {
  course,
  mentor;

  String fromTitle() {
    return switch (this) {
      SearchResultTab.course => 'Course',
      SearchResultTab.mentor => 'Mentor',
    };
  }
}
