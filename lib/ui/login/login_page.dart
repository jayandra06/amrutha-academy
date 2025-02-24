import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';
import 'package:flutter_bloc_template/base/shared_view/foundation_state.dart';
import 'package:flutter_bloc_template/base/shared_view/dialog/app_dialogs.dart';
import 'package:flutter_bloc_template/navigation/router.gr.dart';
import 'package:gap/gap.dart';

import '../../base/constants/ui/app_text_styles.dart';
import '../../base/constants/ui/dimens.dart';
import '../../base/shared_view/common_app_bar.dart';
import '../../base/shared_view/common_button.dart';
import '../../base/shared_view/common_check_box.dart';
import '../../base/shared_view/common_scaffold.dart';
import '../../base/shared_view/common_text_field.dart';
import '../../resource/generated/assets.gen.dart';
import '../../resource/generated/l10n.dart';
import '../widgets/auth_prompt_widget.dart';
import '../widgets/social_auth_provider/social_auth_provider_page.dart';
import '../widgets/via_widget.dart';
import 'bloc/login_bloc.dart';

@RoutePage()
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends FoundationState<LoginPage, LoginBloc> {
  @override
  Widget buildPage(BuildContext context) {
    return CommonScaffold(
      appBar: CommonAppBar(),
      bottomNavigationBar: AuthPromptWidget(
        message: S.current.dont_have_an_account,
        actionText: S.current.sign_up,
        onActionTap: () {
          AutoRouter.of(context).push(const SignUpRoute());
        },
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: Dimens.paddingHorizontalLarge),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Gap(60),
            Text(S.current.login_to_ur_account, style: AppTextStyles.h1Bold.copyWith(height: 57.6 / 48)),
            const Gap(60),
            CommonTextField(
              hintText: S.current.email,
              prefixIconPath: Assets.icons.message.path,
              onChanged: (val) {},
            ),
            const Gap(20),
            CommonTextField(
              obscureText: true,
              hintText: S.current.password,
              prefixIconPath: Assets.icons.lock.path,
              onChanged: (val) {},
            ),
            const Gap(20),
            Center(
              child: CommonCheckbox(
                label: S.current.remember_me,
                value: false,
                onChanged: (val) {},
              ),
            ),
            const Gap(20),
            CommonButton(
              enable: true,
              onPressed: () {
                // bloc.add(LoginSubmittedEvent());
                AppDialogs.showPopup(
                  context,
                  builder: (context) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [],
                    );
                  },
                );
              },
              title: S.current.sign_in,
              fullWidth: true,
            ),
            const Gap(Dimens.paddingVerticalLarge),
            Center(
              child: Text(
                S.current.forgot_the_password,
                style: AppTextStyles.bodyLargeSemiBold.copyWith(color: AppColors.current.primary500),
                textAlign: TextAlign.center,
              ),
            ),
            const Gap(45),
            ViaWidget(title: S.current.or_continue_with.toLowerCase()),
            const Gap(Dimens.paddingVerticalLarge),
            const SocialAuthProviderPage(hideLabel: true),
          ],
        ),
      ),
    );
  }
}
