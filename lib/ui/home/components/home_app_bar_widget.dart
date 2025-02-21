import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/shared_view/common_image_view.dart';
import 'package:flutter_bloc_template/di/di.dart';
import 'package:flutter_bloc_template/domain/entity/user/user_entity.dart';
import 'package:flutter_bloc_template/domain/use_case/user/listen_user_profile_stream_use_case.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:gap/gap.dart';

class HomeAppBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const HomeAppBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        height: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingHorizontalLarge),
        child: IntrinsicHeight(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              StreamBuilder<UserEntity>(
                stream: SL.get<ListenUserProfileStreamUseCase>().invoke(),
                builder: (_, snapshot) {
                  final user = snapshot.data ?? UserEntity.defaultValue();
                  return Row(
                    children: [
                      CommonImageView.circle(imageUrl: user.avatar, size: 48),
                      const Gap(16),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Good Morning 👋', style: AppTextStyles.bodyLargeRegular),
                          Text(user.fullName, style: AppTextStyles.h5Bold),
                        ],
                      )
                    ],
                  );
                },
              ),
              const Gap(16),
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Assets.icons.notificationCurved.svg(),
                  ),
                  const Gap(16),
                  CircleAvatar(
                    backgroundColor: Colors.transparent,
                    child: Assets.icons.bookmarkCurved.svg(),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(76);
}
