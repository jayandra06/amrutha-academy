import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:gap/gap.dart';

class HomeSearchSuggestionListWidget extends StatelessWidget {
  const HomeSearchSuggestionListWidget({super.key, required this.suggestions, required this.onTap});

  final List<String> suggestions;
  final ValueChanged<String> onTap;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      physics: const ClampingScrollPhysics(),
      separatorBuilder: (_, __) => const Gap(Dimens.paddingVerticalLarge),
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        final item = suggestions[index];
        return GestureDetector(
          onTap: () => onTap(item),
          behavior: HitTestBehavior.opaque,
          child: Text(
            item,
            style: AppTextStyles.bodyXLargeMedium.copyWith(color: AppColors.current.greyscale600),
          ),
        );
      },
    );
  }
}
