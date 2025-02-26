import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/navigation/router.gr.dart';
import 'package:flutter_bloc_template/resource/generated/assets.gen.dart';
import 'package:flutter_bloc_template/ui/profile/pages/setting_payment/setting_payment_page.dart';
import 'package:gap/gap.dart';

import '../../../base/constants/ui/app_colors.dart';

class ProfileSettingListViewWidget extends StatelessWidget {
  const ProfileSettingListViewWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _item(
          onTap: () {
            AutoRouter.of(context).push(const EditProfileRoute());
          },
          label: 'Edit Profile',
          icon: Assets.icons.profileCurved.svg(),
        ),
        _item(
            onTap: () => AutoRouter.of(context).push(const SettingNotificationRoute()),
            label: 'Notification',
            icon: Assets.icons.notificationCurved.svg()),
        _item(
            onTap: () => AutoRouter.of(context).push(const SettingPaymentRoute()), label: 'Payment', icon: Assets.icons.walletCurved.svg()),
        _item(onTap: () {}, label: 'Security', icon: Assets.icons.shieldDoneCurved.svg()),
        _item(
          onTap: () => AutoRouter.of(context).push(const SettingNotificationRoute()),
          label: 'Language',
          icon: Assets.icons.moreCircleCurved.svg(),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('English (US)'),
              const Gap(20),
              Assets.icons.arrowRight2.svg(),
            ],
          ),
        ),
        _item(
            onTap: () {},
            label: 'Dark Mode',
            icon: Assets.icons.showCurved.svg(),
            trailing: Builder(
              builder: (_) {
                bool enable = false;
                return StatefulBuilder(
                  builder: (context, setState) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          enable = !enable;
                        });
                      },
                      child: enable ? Assets.icons.toggleEnable.svg() : Assets.icons.toggleDisabled.svg(),
                    );
                  },
                );
              },
            )),
        _item(onTap: () {}, label: 'Privacy Policy', icon: Assets.icons.lockCurved.svg()),
        _item(
            onTap: () => AutoRouter.of(context).push(const HelpCenterRoute()),
            label: 'Help Center',
            icon: Assets.icons.infoSquareCurved.svg()),
        _item(onTap: () {}, label: 'Invite Friends', icon: Assets.icons.usersCurve.svg()),
        _item(
          onTap: () {},
          label: 'Logout',
          labelStyle: AppTextStyles.bodyXLargeBold.copyWith(color: AppColors.current.error),
          icon: Assets.icons.logoutCurved.svg(
              colorFilter: ColorFilter.mode(
            AppColors.current.error,
            BlendMode.srcIn,
          )),
          trailing: const SizedBox.shrink(),
        ),
      ],
    );
  }

  Widget _item({
    required VoidCallback? onTap,
    required String label,
    required Widget icon,
    Widget? trailing,
    TextStyle? labelStyle,
    // bool visibleBorderBottom = true,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                icon,
                const Gap(20),
                Text(label, style: labelStyle ?? AppTextStyles.bodyXLargeBold),
              ],
            ),
            trailing ?? Assets.icons.arrowRight2.svg(width: 20, height: 20),
          ],
        ),
      ),
    );
  }
}
