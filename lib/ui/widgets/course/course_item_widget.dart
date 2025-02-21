import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/di/di.dart';
import 'package:flutter_bloc_template/domain/entity/course/course_entity.dart';
import 'package:flutter_bloc_template/domain/use_case/course/watch_favorite_course_stream_use_case.dart';
import 'package:flutter_bloc_template/ui/widgets/course/course_rating_widget.dart';
import 'package:gap/gap.dart';
import 'package:intl/intl.dart';

import '../../../base/constants/ui/app_colors.dart';
import '../../../base/constants/ui/app_text_styles.dart';
import '../../../base/constants/ui/dimens.dart';
import '../../../base/shared_view/common_image_view.dart';
import '../../../resource/generated/assets.gen.dart';
import 'course_category_name_widget.dart';

class CourseItemWidget extends StatefulWidget {
  const CourseItemWidget({super.key, required this.item, this.onTap});

  final CourseEntity item;
  final VoidCallback? onTap;

  @override
  State<CourseItemWidget> createState() => _CourseItemWidgetState();
}

class _CourseItemWidgetState extends State<CourseItemWidget> {
  late bool _isFav = false;
  StreamSubscription? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = SL.get<WatchFavoriteCourseStreamUseCase>().invoke().listen((data) {
      if (data.id == widget.item.id) {
        setState(() {
          _isFav = data.isFav;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        margin: const EdgeInsets.only(bottom: Dimens.paddingVertical),
        decoration: BoxDecoration(
          color: AppColors.current.otherWhite,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: const Color(0xff04060F).withOpacity(.05),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              CommonImageView(
                imageUrl: widget.item.image,
                width: 120,
                height: 120,
                radius: 20,
              ),
              const Gap(Dimens.paddingHorizontal),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CourseCategoryNameWidget(name: widget.item.category),

                        _isFav
                            ? Assets.icons.bookmarkBold
                            .svg(width: 24, colorFilter: ColorFilter.mode(AppColors.current.primary500, BlendMode.srcIn))
                            : Assets.icons.bookmarkCurved
                                .svg(width: 24, colorFilter: ColorFilter.mode(AppColors.current.primary500, BlendMode.srcIn))
                      ],
                    ),
                    const Gap(12),
                    Text(widget.item.title, style: AppTextStyles.h6Bold),
                    const Gap(12),
                    RichText(
                        text: TextSpan(
                      children: [
                        TextSpan(text: '\$${widget.item.price}', style: AppTextStyles.h6Bold.withPrimaryColor()),
                        const WidgetSpan(child: SizedBox(width: 8)),
                        TextSpan(
                            text: '\$${widget.item.originalPrice}',
                            style: AppTextStyles.bodySmallMedium.copyWith(
                              color: AppColors.current.greyscale700,
                              decoration: TextDecoration.lineThrough,
                            )),
                      ],
                    )),
                    const Gap(12),
                    CourseRatingWidget(total: widget.item.reviewsCount, rating: widget.item.rating),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
