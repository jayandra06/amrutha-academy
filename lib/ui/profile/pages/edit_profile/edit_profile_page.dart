import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/extension/context_extension.dart';
import 'package:flutter_bloc_template/base/shared_view/common_app_bar.dart';
import 'package:flutter_bloc_template/base/shared_view/common_bottom_navigator_bar_background.dart';
import 'package:flutter_bloc_template/base/shared_view/common_button.dart';
import 'package:flutter_bloc_template/base/shared_view/common_scaffold.dart';
import 'package:flutter_bloc_template/base/shared_view/common_text_field.dart';
import 'package:flutter_bloc_template/base/shared_view/dialog/app_dialogs.dart';
import 'package:flutter_bloc_template/base/shared_view/foundation_state.dart';
import 'package:gap/gap.dart';

import '../../../../base/constants/ui/app_colors.dart';
import '../../../../resource/generated/assets.gen.dart';
import '../../../../resource/generated/l10n.dart';
import 'bloc/edit_profile_bloc.dart';

@RoutePage()
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends FoundationState<EditProfilePage, EditProfileBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(text: S.current.edit_profile, centerTitle: false),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(Dimens.paddingHorizontalLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CommonTextField(
              hintText: 'Name',
              onChanged: (val) {},
            ),
            const Gap(Dimens.paddingVerticalLarge),
            CommonTextField(
              hintText: 'Birthday',
              onChanged: (val) {},
              suffixIcon: Assets.icons.calendarCurved.svg(
                  colorFilter: ColorFilter.mode(
                    AppColors.current.greyscale900,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.scaleDown),
            ),
            const Gap(Dimens.paddingVerticalLarge),
            CommonTextField(
              hintText: 'Email',
              onChanged: (val) {},
              suffixIcon: Assets.icons.messageCurved.svg(
                  colorFilter: ColorFilter.mode(
                    AppColors.current.greyscale900,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.scaleDown),
            ),
            const Gap(Dimens.paddingVerticalLarge),
            CommonTextField(
              hintText: 'Location',
              onChanged: (val) {},
              suffixIcon: Assets.icons.arrowDownBold2.svg(
                  colorFilter: ColorFilter.mode(
                    AppColors.current.greyscale900,
                    BlendMode.srcIn,
                  ),
                  fit: BoxFit.scaleDown),
            ),
            const Gap(Dimens.paddingVerticalLarge),
            CommonTextField(
              hintText: 'Phone',
              onChanged: (val) {},
            ),
            const Gap(Dimens.paddingVerticalLarge),
            GestureDetector(
              onTap: () {
                AppDialogs.showDisableScrollBottomSheet(
                  context,
                  builder: (_) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ListTile(title: Text('data')),
                      ],
                    );
                  },
                ).then((_) {
                  context.hideKeyboard();
                });
              },
              behavior: HitTestBehavior.opaque,
              child: IgnorePointer(
                ignoring: true,
                child: CommonTextField(
                  readOnly: false,
                  hintText: 'Gender',
                  suffixIcon: Assets.icons.arrowDownBold2.svg(
                      colorFilter: ColorFilter.mode(
                        AppColors.current.greyscale900,
                        BlendMode.srcIn,
                      ),
                      fit: BoxFit.scaleDown),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  _buildBottomNavigationBar() {
    return CommonBottomNavigatorBarBackground(
      visibleBorder: false,
      child: CommonButton(onPressed: () {}, title: 'Update'),
    );
  }
}
