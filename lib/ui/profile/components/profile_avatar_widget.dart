import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/shared_view/common_image_view.dart';
import 'package:flutter_bloc_template/di/di.dart';
import 'package:flutter_bloc_template/domain/entity/user/user_entity.dart';
import 'package:flutter_bloc_template/domain/use_case/user/listen_user_profile_stream_use_case.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:gap/gap.dart';

class ProfileAvatarWidget extends StatelessWidget {
  const ProfileAvatarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder<UserEntity>(
        stream: SL.get<ListenUserProfileStreamUseCase>().invoke(),
        initialData: UserEntity.defaultValue(),
        builder: (_, snapshot) {
          final user = snapshot.data;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  CommonImageView.circle(imageUrl: user!.avatar, size: 120),
                  Positioned(bottom: 5, right: 0, child: Assets.icons.editSquare.svg(width: 30)),
                ],
              ),
              const Gap(20),
              Text(user.fullName, style: AppTextStyles.h4Bold),
              const Gap(8),
              Text(
                user.email,
                style: AppTextStyles.bodyMediumSemiBold,
              )
            ],
          );
        },
      ),
    );
  }
}
