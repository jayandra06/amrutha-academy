import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/domain/entity/course/lesson_entity.dart';
import 'package:gap/gap.dart';

import '../../../base/constants/ui/app_colors.dart';
import '../../../base/constants/ui/app_text_styles.dart';
import '../../../base/constants/ui/dimens.dart';
import '../../../resource/generated/assets.gen.dart';

class LessonItemWidget extends StatelessWidget {
  const LessonItemWidget({super.key, required this.item, required this.index, this.onTap});

  final LessonEntity item;
  final int index;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if(!item.isFree) return;
        onTap?.call();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: Dimens.paddingVertical, horizontal: 20),
        decoration: BoxDecoration(
            color: AppColors.current.otherWhite,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [BoxShadow(offset: const Offset(0, 2), blurRadius: 16, color: const Color(0xff04060F).withOpacity(.05))]),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: double.infinity,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.current.transparentBlue,
                      ),
                      child: Text(_getIndex(), style: AppTextStyles.h6Bold.withPrimaryColor()),
                    ),
                    const Gap(Dimens.paddingHorizontal),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.title, style: AppTextStyles.h6Bold, maxLines: 2, overflow: TextOverflow.ellipsis),
                          const Gap(6),
                          Text('${item.duration} mins', style: AppTextStyles.bodyMedium)
                        ],
                      ),
                    )
                  ],
                ),
              ),
              const Gap(Dimens.paddingHorizontal),
              // if()
              item.isFree
                  ? Assets.icons.playBold.svg(colorFilter: ColorFilter.mode(AppColors.current.primary500, BlendMode.srcIn))
                  : Assets.icons.lockCurved.svg(),
            ],
          ),
        ),
      ),
    );
  }

  String _getIndex() => (index + 1).toString().padLeft(2, '0');
}
