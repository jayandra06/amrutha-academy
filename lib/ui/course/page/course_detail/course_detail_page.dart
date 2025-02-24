import 'package:auto_route/annotations.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/helper/duration_provider.dart';
import 'package:flutter_bloc_template/base/shared_view/foundation_state.dart';
import 'package:flutter_bloc_template/base/shared_view/common_bottom_navigator_bar_background.dart';
import 'package:flutter_bloc_template/base/shared_view/common_button.dart';
import 'package:flutter_bloc_template/base/shared_view/common_image_view.dart';
import 'package:flutter_bloc_template/base/shared_view/common_scaffold.dart';
import 'package:flutter_bloc_template/domain/entity/course/course_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/lesson_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/review_entity.dart';
import 'package:flutter_bloc_template/domain/entity/enum/enum.dart';
import 'package:flutter_bloc_template/ui/course/page/course_detail/bloc/course_detail_bloc.dart';
import 'package:flutter_bloc_template/ui/course/page/course_detail/bloc/course_detail_event.dart';
import 'package:flutter_bloc_template/ui/course/page/course_detail/bloc/course_detail_state.dart';
import 'package:flutter_bloc_template/ui/course/page/course_detail/components/course_information_widget.dart';
import 'package:flutter_bloc_template/ui/course/page/course_detail/components/course_persistent_header_delegate.dart';
import 'package:flutter_bloc_template/ui/course/page/course_detail/components/tabs/course_about_tab_widget.dart';
import 'package:flutter_bloc_template/ui/course/page/course_detail/components/tabs/course_lessons_tab_widget.dart';
import 'package:flutter_bloc_template/ui/course/page/course_detail/components/tabs/course_reviews_tab_widget.dart';
import 'package:gap/gap.dart';

import '../../../../resource/generated/assets.gen.dart';

@RoutePage()
class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({super.key, @PathParam('id') required this.id});

  final String id;

  @override
  State<CourseDetailPage> createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends FoundationState<CourseDetailPage, CourseDetailBloc> {
  final ScrollController _scrollController = ScrollController();

  final ValueNotifier<bool> isHeaderVisible = ValueNotifier(false);

  static const double _scrollThreshold = 300;

  @override
  void initState() {
    super.initState();
    bloc.add(FetchCourseDetailEvent(courseId: widget.id));
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    isHeaderVisible.dispose();
    super.dispose();
  }

  void _onScroll() {
    final shouldShowHeader = _scrollController.position.pixels >= _scrollThreshold;
    if (isHeaderVisible.value != shouldShowHeader) {
      isHeaderVisible.value = shouldShowHeader;
    }
  }

  @override
  Widget buildPage(BuildContext context) {
    return DefaultTabController(
      length: CourseTab.values.length,
      child: BlocBuilder<CourseDetailBloc, CourseDetailState>(
        buildWhen: (prev, curr) => prev.course != curr.course,
        builder: (context, state) {
          return CommonScaffold(
            body: Stack(
              children: [
                NestedScrollView(
                  controller: _scrollController,
                  headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
                    return [
                      ValueListenableBuilder<bool>(
                        valueListenable: isHeaderVisible,
                        builder: (_, visible, __) {
                          return SliverAppBar(
                            expandedHeight: 300,
                            pinned: true,
                            scrolledUnderElevation: 0,
                            backgroundColor: AppColors.current.otherWhite,
                            title: AnimatedCrossFade(
                                firstChild: Text(state.course.title, style: AppTextStyles.h4Bold),
                                secondChild: const SizedBox.shrink(),
                                crossFadeState: !visible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                duration: const ShortDuration()),
                            leading: IconButton(
                              onPressed: () => AutoRouter.of(context).back(),
                              icon: AnimatedCrossFade(
                                  firstChild: _backButton(),
                                  secondChild: _backButton(ColorFilter.mode(AppColors.current.otherWhite, BlendMode.srcIn)),
                                  crossFadeState: !visible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
                                  duration: const ShortDuration()),
                            ),
                            flexibleSpace: FlexibleSpaceBar(
                              background: CommonImageView(imageUrl: state.course.image),
                            ),
                          );
                        },
                      ),
                      SliverToBoxAdapter(child: _information(state.course)),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: CoursePersistentHeaderDelegate(
                          onTap: (i) {
                            bloc.add(CourseTabChangedEvent(tab: CourseTab.values[i]));
                          },
                        ),
                      )
                    ];
                  },
                  body: TabBarView(children: [
                    CourseAboutTabWidget(item: state.course),
                    BlocSelector<CourseDetailBloc, CourseDetailState, List<LessonEntity>>(
                      selector: (state) => state.lessons,
                      builder: (_, lessons) {
                        return CourseLessonsTabWidget(lessons: lessons, course: state.course);
                      },
                    ),
                    BlocSelector<CourseDetailBloc, CourseDetailState, List<ReviewEntity>>(
                      selector: (state) => state.reviews,
                      builder: (_, reviews) {
                        return CourseReviewsTabWidget(reviews: reviews, course: state.course);
                      },
                    ),
                  ]),
                ),
                // const SafeArea(child: BackButton()),
              ],
            ),
            bottomNavigationBar: CommonBottomNavigatorBarBackground(
              visibleBorder: false,
              child: CommonButton(
                onPressed: () {},
                title: 'Enroll Course - ${state.course.displayPrice()}',
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _backButton([ColorFilter? colorFilter]) {
    return Assets.icons.arrowLeft.svg(colorFilter: colorFilter);
  }

  Widget _information(CourseEntity item) {
    return Padding(
      padding: const EdgeInsets.all(Dimens.paddingHorizontalLarge).copyWith(bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CourseInformationWidget(
            item: item,
            onToggleFavorite: () {
              bloc.add(ToggleFavoriteCourseEvent());
            },
          ),
          const Gap(Dimens.paddingVerticalLarge),
          Divider(height: 1, color: AppColors.current.greyscale200),
        ],
      ),
    );
  }
}
