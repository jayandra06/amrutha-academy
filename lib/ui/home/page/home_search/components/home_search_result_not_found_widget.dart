import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:gap/gap.dart';

class HomeSearchResultNotFoundWidget extends StatelessWidget {
  const HomeSearchResultNotFoundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Gap(40),
            Assets.images.emptyCourse.image(height: 250),
            const Gap(Dimens.paddingVerticalLarge),
            Text('Not Found', style: AppTextStyles.h4Bold),
            const Gap(12),
            Text(
              'Sorry, the keyword you entered cannot be found, please check again or search with another keyword.',
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyXLargeRegular,
            )
          ],
        ),
      ),
    );
  }
}
