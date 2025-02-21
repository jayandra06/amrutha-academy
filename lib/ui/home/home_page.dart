import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/shared_view/common_base_state.dart';
import 'package:flutter_bloc_template/base/shared_view/common_scaffold.dart';
import 'package:flutter_bloc_template/base/shared_view/common_text_field.dart';
import 'package:flutter_bloc_template/base/shared_view/dialog/app_dialogs.dart';
import 'package:flutter_bloc_template/domain/entity/course/course_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/mentor_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/promote_entity.dart';
import 'package:flutter_bloc_template/navigation/router.gr.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:flutter_bloc_template/ui/home/bloc/home_state.dart';
import 'package:flutter_bloc_template/ui/home/components/home_banner_slide_widget.dart';
import 'package:flutter_bloc_template/ui/home/components/home_most_popular_courses_widget.dart';
import 'package:flutter_bloc_template/ui/home/components/home_search_widget.dart';
import 'package:flutter_bloc_template/ui/home/components/home_top_mentors_widget.dart';
import 'package:gap/gap.dart';

import '../../base/shared_view/dialog/common_dialog.dart';
import '../../domain/entity/course/category_entity.dart';
import 'bloc/home_bloc.dart';
import 'bloc/home_event.dart';
import 'components/home_app_bar_widget.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends CommonBaseState<HomePage, HomeBloc> {
  @override
  void initState() {
    super.initState();
    bloc.add(HomeDataRequestedEvent());
    bloc.add(HomeProfileRequestEvent());
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: const HomeAppBarWidget(),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
                padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingHorizontalLarge),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(24),
                    GestureDetector(
                      onTap: () {
                        AutoRouter.of(context).push(const HomeSearchRoute());
                      },
                      behavior: HitTestBehavior.opaque,
                      child: IgnorePointer(
                          ignoring: true,
                          child: HomeSearchWidget(
                            onChanged: (String value) {},
                          )),
                    ),
                    const Gap(24),
                    BlocSelector<HomeBloc, HomeState, List<PromoteEntity>>(
                      selector: (state) => state.promotes,
                      builder: (_, promotes) {
                        return HomeBannerSlideWidget(items: promotes);
                      },
                    ),
                    const Gap(24),
                    BlocSelector<HomeBloc, HomeState, List<MentorEntity>>(
                      selector: (state) => state.mentors,
                      builder: (_, mentors) {
                        return HomeTopMentorsWidget(items: mentors);
                      },
                    ),
                  ],
                )),
            const Gap(24),
            BlocBuilder<HomeBloc, HomeState>(
              buildWhen: (prev, curr) =>
                  (prev.courses != curr.courses) || (prev.categories != curr.categories) || (prev.categoryId != curr.categoryId),
              builder: (_, state) {
                return HomeMostPopularCoursesWidget(
                  courses: state.courses,
                  categories: state.categories,
                  categoryId: state.categoryId,
                  onCategoryChanged: (CategoryEntity value) {
                    bloc.add(HomeCategoryChangedEvent(value.id));
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
