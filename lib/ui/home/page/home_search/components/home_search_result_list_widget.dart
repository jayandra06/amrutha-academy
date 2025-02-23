import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/domain/entity/enum/enum.dart';
import 'package:flutter_bloc_template/ui/home/page/home_search/components/home_search_result_not_found_widget.dart';
import 'package:gap/gap.dart';

class HomeSearchResultListWidget extends StatelessWidget {
  const HomeSearchResultListWidget({super.key, required this.keyword, required this.total});

  final String keyword;
  final int total;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: SearchResultTab.values.length,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TabBar(
            dividerColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory,
            indicator: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: AppColors.current.primary500,
            ),
            labelStyle: AppTextStyles.bodyXLargeBold.withWhiteColor(),
            tabs: SearchResultTab.values
                .map(
                  (e) => Tab(
                    text: e.fromTitle(),
                  ),
                )
                .toList(),
          ),
          const Gap(Dimens.paddingVerticalLarge),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: RichText(
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(
                      style: AppTextStyles.h5Bold,
                      children: [
                        const TextSpan(text: 'Results for “'),
                        TextSpan(text: keyword, style: TextStyle(color: AppColors.current.primary500)),
                        const TextSpan(text: '”'),
                      ],
                    )),
              ),
              const Gap(12),
              Text('$total found', style: AppTextStyles.bodyLargeBold.withPrimaryColor()),
            ],
          ),
          const Gap(Dimens.paddingVerticalLarge),
          const HomeSearchResultNotFoundWidget(),
        ],
      ),
    );
  }
}
