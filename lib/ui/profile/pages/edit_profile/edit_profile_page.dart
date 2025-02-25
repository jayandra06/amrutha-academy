import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/base/constants/ui/dimens.dart';
import 'package:flutter_bloc_template/base/extension/context_extension.dart';
import 'package:flutter_bloc_template/base/shared_view/common_app_bar.dart';
import 'package:flutter_bloc_template/base/shared_view/common_bottom_navigator_bar_background.dart';
import 'package:flutter_bloc_template/base/shared_view/common_button.dart';
import 'package:flutter_bloc_template/base/shared_view/common_calendar_picker.dart';
import 'package:flutter_bloc_template/base/shared_view/common_scaffold.dart';
import 'package:flutter_bloc_template/base/shared_view/common_text_field.dart';
import 'package:flutter_bloc_template/base/shared_view/dialog/app_dialogs.dart';
import 'package:flutter_bloc_template/base/shared_view/foundation_state.dart';
import 'package:flutter_bloc_template/domain/entity/enum/enum.dart';
import 'package:flutter_bloc_template/domain/entity/user/user_entity.dart';
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/bloc/edit_profile_state.dart';
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/components/edit_profile_gender_widget.dart';
import 'package:gap/gap.dart';

import '../../../../base/constants/ui/app_colors.dart';
import '../../../../resource/generated/assets.gen.dart';
import '../../../../resource/generated/l10n.dart';
import 'bloc/edit_profile_bloc.dart';
import 'bloc/edit_profile_event.dart';

@RoutePage()
class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends FoundationState<EditProfilePage, EditProfileBloc> {
  @override
  void initState() {
    super.initState();
    bloc.add(EditProfileDataRequestEvent());
  }

  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(text: S.current.edit_profile, centerTitle: false),
      bottomNavigationBar: _buildBottomNavigationBar(),
      body: BlocSelector<EditProfileBloc, EditProfileState, UserEntity>(
        selector: (state) => state.user,
        builder: (_, user) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(Dimens.paddingHorizontalLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                BlocBuilder<EditProfileBloc, EditProfileState>(
                  buildWhen: (prev, curr) => (prev.nameInput != curr.nameInput),
                  builder: (_, state) {
                    return CommonTextField(
                      key: ValueKey('nameInput-${user.fullName}'),
                      initialValue: user.fullName,
                      hintText: 'Name',
                      errorText: state.nameInput.displayError?.fromTitle(),
                      onChanged: (val) => bloc.add(ProfileNameChangedEvent(val)),
                    );
                  },
                ),
                const Gap(Dimens.paddingVerticalLarge),
                CommonTextField(
                  onTap: () {
                    context.hideKeyboard();
                    AppDialogs.showDisableScrollBottomSheet(
                      context,
                      builder: (_) => CommonCalendarPicker(
                        lastDate: DateTime.now(),
                        onDateTimeChanged: (val) {},
                      ),
                    );
                  },
                  ignoring: true,
                  hintText: 'Birthday',
                  suffixIcon: Assets.icons.calendarCurved.svg(
                      colorFilter: ColorFilter.mode(
                        AppColors.current.greyscale900,
                        BlendMode.srcIn,
                      ),
                      fit: BoxFit.scaleDown),
                ),
                const Gap(Dimens.paddingVerticalLarge),
                BlocBuilder<EditProfileBloc, EditProfileState>(
                  buildWhen: (prev, curr) => (prev.emailInput != curr.emailInput),
                  builder: (_, state) {
                    return CommonTextField(
                      key: ValueKey('emailInput-${user.email}'),
                      initialValue: user.email,
                      hintText: 'Email',
                      onChanged: (val) => bloc.add(ProfileEmailChangedEvent(val)),
                      keyboardType: TextInputType.emailAddress,
                      suffixIcon: Assets.icons.messageCurved
                          .svg(colorFilter: ColorFilter.mode(AppColors.current.greyscale900, BlendMode.srcIn), fit: BoxFit.scaleDown),
                    );
                  },
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
                  key: ValueKey('phone-${user.phoneNumber}'),
                  initialValue: user.phoneNumber,
                  hintText: 'Phone',
                  keyboardType: TextInputType.phone,
                  onChanged: (val) => bloc.add(ProfilePhoneNumberChangedEvent(val)),
                ),
                const Gap(Dimens.paddingVerticalLarge),
                CommonTextField(
                  onTap: () {
                    AppDialogs.showDisableScrollBottomSheet(
                      context,
                      builder: (_) {
                        return const SafeArea(
                          minimum: EdgeInsets.symmetric(horizontal: Dimens.paddingHorizontalLarge),
                          child: EditProfileGenderWidget(),
                        );
                      },
                    );
                  },
                  ignoring: true,
                  hintText: 'Gender',
                  suffixIcon: Assets.icons.arrowDownBold2.svg(
                      colorFilter: ColorFilter.mode(
                        AppColors.current.greyscale900,
                        BlendMode.srcIn,
                      ),
                      fit: BoxFit.scaleDown),
                ),
              ],
            ),
          );
        },
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
