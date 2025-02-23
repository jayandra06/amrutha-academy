import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';
import 'package:gap/gap.dart';

import '../../../../../base/constants/ui/app_colors.dart';
import '../../../../../base/constants/ui/app_text_styles.dart';
import '../../../../../base/constants/ui/dimens.dart';
import '../../../../../resource/generated/assets.gen.dart';

class HomeSearchHistoryListWidget extends StatelessWidget {
  const HomeSearchHistoryListWidget({super.key, required this.histories, required this.onTap});

  final List<SearchHistoryEntity> histories;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent', style: AppTextStyles.h5Bold),
        const Gap(Dimens.paddingVerticalLarge),
        Divider(height: 1, color: AppColors.current.greyscale200),
        const Gap(Dimens.paddingVerticalLarge),
        Expanded(
            child: ListView.separated(
          physics: const ClampingScrollPhysics(),
          separatorBuilder: (_, __) => const Gap(Dimens.paddingVerticalLarge),
          itemCount: histories.length,
          itemBuilder: (context, index) {
            final item = histories[index];
            return GestureDetector(
              onTap: () => onTap(item.keyword),
              behavior: HitTestBehavior.opaque,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    item.keyword,
                    style: AppTextStyles.bodyXLargeMedium.copyWith(color: AppColors.current.greyscale600),
                  ),
                  const Gap(12),
                  Assets.icons.closeSquareCurved.svg(),
                ],
              ),
            );
          },
        ))
      ],
    );
  }
}
