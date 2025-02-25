import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/shared_view/common_expandable_section.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:gap/gap.dart';

class HelpCenterItemWidget extends StatelessWidget {
  const HelpCenterItemWidget({super.key});


  @override
  Widget build(BuildContext context) {
    bool expand = false;
    return StatefulBuilder(builder: (_, setState) {
      return GestureDetector(
        onTap: () {
          setState(() {
            expand = !expand;
          });
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(Dimens.paddingVerticalLarge),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: AppColors.current.otherWhite, boxShadow: [
            BoxShadow(
              color: const Color(0xff04060F).withOpacity(.05),
              offset: const Offset(0, 4),
              blurRadius: 60,
            )
          ]),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('What is E-Learning?', style: AppTextStyles.h6Bold),
                  Assets.icons.arrowDownBold2.svg(colorFilter: ColorFilter.mode(AppColors.current.primary500, BlendMode.srcIn)),
                ],
              ),
              CommonExpandableSection(
                expand: expand,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Gap(16),
                    Divider(height: 1, color: AppColors.current.greyscale200),
                    const Gap(16),
                    Text(
                      'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.',
                      style: AppTextStyles.bodyMedium.copyWith(color: AppColors.current.greyscale800, height: 20 / 14),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },);
  }
}

