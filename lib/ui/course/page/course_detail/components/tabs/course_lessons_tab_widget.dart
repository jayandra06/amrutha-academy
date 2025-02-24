import 'package:auto_route/auto_route.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/domain/entity/course/course_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/lesson_entity.dart';
import 'package:flutter_bloc_template/navigation/router.gr.dart';
import 'package:flutter_bloc_template/ui/main/main_page.dart';
import 'package:flutter_bloc_template/ui/widgets/course/lesson_item_widget.dart';
import 'package:gap/gap.dart';

import '../../../../../../base/constants/ui/dimens.dart';
import '../../../../../../resource/generated/assets.gen.dart';

class CourseLessonsTabWidget extends StatelessWidget {
  const CourseLessonsTabWidget({super.key, required this.lessons, required this.course});

  final List<LessonEntity> lessons;
  final CourseEntity course;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.current.scaffoldColor,
      child: ListView.separated(
        itemCount: lessons.length,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingHorizontalLarge).copyWith(top: Dimens.paddingVerticalLarge),
        separatorBuilder: (_, __) => const Gap(Dimens.paddingVerticalLarge),
        itemBuilder: (_, int index) {
          final item = lessons[index];
          return LessonItemWidget(
            onTap: () {
              AutoRouter.of(context).push(LessonVideoPlayerRoute(
                videoUrl: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                title: item.title,
              ));
            },
            item: item,
            index: index,
          );
        },
      ),
    );
  }
}
