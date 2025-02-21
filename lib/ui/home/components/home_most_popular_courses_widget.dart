import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/shared_view/common_image_view.dart';
import 'package:flutter_bloc_template/domain/entity/course/category_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/course_entity.dart';
import 'package:flutter_bloc_template/navigation/router.gr.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:flutter_bloc_template/ui/widgets/course/course_item_widget.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../base/constants/ui/app_colors.dart';

class HomeMostPopularCoursesWidget extends StatelessWidget {
  const HomeMostPopularCoursesWidget(
      {super.key, required this.courses, required this.categories, required this.onCategoryChanged, required this.categoryId});

  final List<CourseEntity> courses;
  final List<CategoryEntity> categories;
  final String categoryId;

  final ValueChanged<CategoryEntity> onCategoryChanged;

  List<CourseEntity> get _courseList => courses.length > 5 ? courses.sublist(2).toList() : courses;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingHorizontalLarge),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Most Popular Courses', style: AppTextStyles.h5Bold),
              Text('See All', style: AppTextStyles.bodyLargeBold.withPrimaryColor()),
            ],
          ),
        ),
        const Gap(Dimens.paddingVerticalLarge),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingHorizontalLarge),
          child: _categories(),
        ),
        Container(
          margin: const EdgeInsets.only(top: 5),
          color: AppColors.current.scaffoldColor,
          padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingHorizontal).copyWith(top: 20),
          child: _items(context),
        ),
      ],
    );
  }

  Widget _categories() {
    if (categories.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView.separated(
        separatorBuilder: (_, __) => const Gap(Dimens.paddingHorizontal),
        itemCount: categories.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (_, index) {
          final item = categories[index];
          final bool selected = item.id == categoryId;
          return ChoiceChip(
            onSelected: (_) {
              onCategoryChanged.call(item);
            },
            label: Text(item.name),
            labelStyle:
                AppTextStyles.bodyLargeSemiBold.copyWith(color: selected ? AppColors.current.otherWhite : AppColors.current.primary500),
            selected: selected,
            showCheckmark: false,
            selectedColor: AppColors.current.primary500,
            color: WidgetStateProperty.all(selected ? AppColors.current.primary500 : AppColors.current.otherWhite),
            shape: RoundedRectangleBorder(
              side: BorderSide(color: AppColors.current.primary500, width: 2),
              borderRadius: BorderRadius.circular(100),
            ),
          );
        },
      ),
    );
  }

  Widget _items(BuildContext context) {
    return Column(
      children: List<Widget>.generate(
        _courseList.length,
        (i) {
          final item = _courseList[i];
          return CourseItemWidget(
            item: item,
            onTap: () {
              AutoRouter.of(context).push(CourseDetailRoute(id: item.id));
            },
          );
        },
      ).toList(),
    );
  }
}
