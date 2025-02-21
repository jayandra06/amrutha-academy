
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_text_styles.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/helper/checker.dart';
import 'package:flutter_bloc_template/base/navigator/app_navigator.dart';
import 'package:flutter_bloc_template/base/shared_view/common_button.dart';
import 'package:gap/gap.dart';

// enum PlatformDialogType { android, iOS, adaptive }

class CommonDialog extends StatelessWidget {
  const CommonDialog({
    super.key,
    this.icon,
    this.title,
    this.confirmText,
    this.onTap,
    required this.message,
    // this.dialogType = PlatformDialogType.adaptive,
    this.singleButton = false,
    this.type = AppDialogType.none,
  });

  final Widget? icon;
  final String? title;
  final String? confirmText;
  final dynamic message;
  // final PlatformDialogType dialogType;
  final bool singleButton;
  final VoidCallback? onTap;
  final AppDialogType type;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          const Gap(40),
          icon!,
          const Gap(32),
        ],
        if (!empty(title)) ...[
          Text(
            title!,
            style: AppTextStyles.h4Bold.copyWith(color: AppColors.current.primary500),
            textAlign: TextAlign.center,
          ),
          const Gap(Dimens.paddingVertical),
        ],
        message is Widget
            ? message
            : Text(
                message,
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyLargeRegular,
              ),
        if(type != AppDialogType.none) ...[
          const Gap(32),
          CommonButton(onPressed: () {
            onTap?.call();
          }, title: confirmText ?? 'Ok', fullWidth: true, size: CommonButtonSize.small)
        ],
      ],
    );
  }
}
