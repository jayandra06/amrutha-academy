import 'package:flutter/material.dart';

import '../../../base/constants/ui/app_colors.dart';
import '../../../base/shared_view/common_text_field.dart';
import '../../../base/shared_view/dialog/app_dialogs.dart';
import '../../../base/shared_view/dialog/common_dialog.dart';
import '../../../resource/generated/assets.gen.dart';

class HomeSearchWidget extends StatelessWidget {
  const HomeSearchWidget({super.key, required this.onChanged, this.autoFocus = false});

  final ValueChanged<String> onChanged;
  final bool autoFocus;

  @override
  Widget build(BuildContext context) {
    return CommonTextField(
      onChanged: onChanged,
      autoFocus: autoFocus,
      prefixIconPath: Assets.icons.searchLight.path,
      hintText: 'Search',
      suffixIcon: IconButton(
        onPressed: () {
          AppDialogs.showPopup(context,
              child: CommonDialog(
                icon: Assets.images.shieldPopup.image(width: 185),
                title: 'Congratulations!',
                message: 'Your account is ready to use. You will be redirected to the Home page in a few seconds..',
              ));
        },
        icon: CircleAvatar(
          backgroundColor: Colors.transparent,
          child: Assets.icons.filterLight.svg(colorFilter: ColorFilter.mode(AppColors.current.primary500, BlendMode.srcIn)),
        ),
      ),
    );
  }
}
