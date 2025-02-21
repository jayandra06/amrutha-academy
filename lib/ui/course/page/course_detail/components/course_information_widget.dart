import 'package:flutter/widgets.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/domain/entity/course/course_entity.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:flutter_bloc_template/ui/widgets/course/course_category_name_widget.dart';
import 'package:flutter_bloc_template/ui/widgets/course/course_rating_widget.dart';
import 'package:gap/gap.dart';

class CourseInformationWidget extends StatelessWidget {
  const CourseInformationWidget({super.key, required this.item, required this.onToggleFavorite});

  final CourseEntity item;
  final VoidCallback onToggleFavorite;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
                child: Text(
              item.title,
              style: AppTextStyles.h3Bold,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )),
            const Gap(12),
            GestureDetector(
              onTap: onToggleFavorite,
              behavior: HitTestBehavior.opaque,
              child: Assets.icons.bookmarkCurved.svg(
                  colorFilter: ColorFilter.mode(
                AppColors.current.primary500,
                BlendMode.srcIn,
              )),
            ),
          ],
        ),
        const Gap(20),
        Row(
          children: [
            CourseCategoryNameWidget(name: item.category),
            const Gap(Dimens.paddingHorizontal),
            CourseRatingWidget(
              total: item.reviewsCount,
              rating: item.rating,
              textStyle: AppTextStyles.bodyLargeMedium,
              iconSize: 20,
            ),
          ],
        ),
        const Gap(20),
        RichText(
            text: TextSpan(
          children: [
            TextSpan(text: '\$${item.price}', style: AppTextStyles.h3Bold.withPrimaryColor()),
            const WidgetSpan(child: SizedBox(width: 8)),
            TextSpan(
                text: '\$${item.originalPrice}',
                style: AppTextStyles.h5Bold.copyWith(
                  color: AppColors.current.greyscale500,
                  decoration: TextDecoration.lineThrough,
                )),
          ],
        )),
      ],
    );
  }
}
