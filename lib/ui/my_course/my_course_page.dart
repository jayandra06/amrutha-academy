import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/shared_view/common_image_view.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:gap/gap.dart';

import '../../base/shared_view/common_app_bar.dart';
import '../../base/shared_view/common_scaffold.dart';
import '../../domain/entity/enum/enum.dart';

@RoutePage()
class MyCoursePage extends StatefulWidget {
  const MyCoursePage({super.key});

  @override
  State<MyCoursePage> createState() => _MyCoursePageState();
}

class _MyCoursePageState extends State<MyCoursePage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: MyCourseTab.values.length,
      child: CommonScaffold(
        backgroundColor: AppColors.current.scaffoldColor,
        appBar: CommonAppBar(
          text: 'My Course',
          automaticallyImplyLeading: false,
          leadingWidth: 0,
          leadingIcon: LeadingIcon.none,
          centerTitle: false,
          actions: [
            IconButton(
              onPressed: () {},
              icon: Assets.icons.searchLight.svg(
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    AppColors.current.greyscale900,
                    BlendMode.srcIn,
                  )),
            ),
            IconButton(
              onPressed: () {},
              icon: Assets.icons.moreCircleLight.svg(
                  width: 28,
                  height: 28,
                  colorFilter: ColorFilter.mode(
                    AppColors.current.greyscale900,
                    BlendMode.srcIn,
                  )),
            ),
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              color: AppColors.current.otherWhite,
              padding: const EdgeInsets.all(24).copyWith(bottom: 0),
              child: TabBar(
                tabs: MyCourseTab.values.map<Widget>((e) => Tab(text: e.fromTitle())).toList(),
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: 5,
                padding: const EdgeInsets.all(20),
                separatorBuilder: (context, index) => const Gap(20),
                itemBuilder: (context, index) => _item(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _item() => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.current.otherWhite,
        ),
        child: Row(
          children: [
            CommonImageView(
              imageUrl: 'https://i.postimg.cc/mDJxhrrz/76f9cfe3aa38ebef858972c66a205bef.jpg',
              width: 100,
              height: 100,
              radius: 20,
            ),
            const Gap(16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Intro to UI/UX Design', style: AppTextStyles.h6Bold),
                  const Gap(12),
                  Text('2 hrs 30 mins', style: AppTextStyles.bodyMedium.copyWith(color: AppColors.current.greyscale700)),
                  const Gap(12),
                  Row(
                    children: [
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, constraints) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(100),
                              child: Stack(
                                children: [
                                  Container(
                                    height: 8,
                                    width: constraints.maxWidth,
                                    decoration: BoxDecoration(
                                      color: AppColors.current.greyscale200,
                                    ),
                                  ),
                                  Container(
                                    height: 8,
                                    width: (constraints.maxWidth * 50) / 100,
                                    decoration: BoxDecoration(
                                      gradient: AppColors.current.gradientOrange,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const Gap(8),
                      Text('93 / 124', style: AppTextStyles.bodySmallMedium.copyWith(color: AppColors.current.greyscale700))
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      );
}
