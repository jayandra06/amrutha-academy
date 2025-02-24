import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/shared_view/common_button.dart';
import 'package:gap/gap.dart';

import '../../../../../base/constants/ui/dimens.dart';

class HomeSearchFilterListWidget extends StatefulWidget {
  const HomeSearchFilterListWidget({super.key, required this.scrollController});

  final ScrollController scrollController;

  @override
  State<HomeSearchFilterListWidget> createState() => _HomeSearchFilterListWidgetState();
}

class _HomeSearchFilterListWidgetState extends State<HomeSearchFilterListWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
            child: SingleChildScrollView(
          controller: widget.scrollController,
          child: const Column(
            children: [],
          ),
        )),
        const Gap(30),
        SafeArea(
            minimum: const EdgeInsets.symmetric(horizontal: Dimens.paddingHorizontalLarge).copyWith(bottom: Dimens.paddingVertical),
            child: Row(
              children: [
                Expanded(
                    child: CommonButton(
                  onPressed: () {},
                      visibleShadow: false,
                  title: 'Reset',
                      titleColor: AppColors.current.primary500,
                  backgroundColor: AppColors.current.primary100,
                )),
                const Gap(16),
                Expanded(child: CommonButton(onPressed: () {}, title: 'Apply')),
              ],
            ))
      ],
    );
  }
}
