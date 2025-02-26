import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc_template/base/extension/context_extension.dart';

import '../../resource/generated/assets.gen.dart';
import '../constants/ui/app_colors.dart';
import '../constants/ui/app_text_styles.dart';
import '../constants/ui/dimens.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  CommonAppBar({
    super.key,
    this.text,
    this.onLeadingPressed,
    this.onTitlePressed,
    this.leadingIcon = LeadingIcon.back,
    this.titleType = AppBarTitle.text,
    this.centerTitle,
    this.elevation,
    this.actions,
    this.height,
    this.automaticallyImplyLeading = true,
    this.flexibleSpace,
    this.bottom,
    this.shadowColor,
    this.shape,
    this.backgroundColor,
    this.foregroundColor,
    this.iconTheme,
    this.actionsIconTheme,
    this.primary = true,
    this.excludeHeaderSemantics = false,
    this.titleSpacing,
    this.toolbarOpacity = 1.0,
    this.bottomOpacity = 1.0,
    this.leadingWidth,
    this.titleTextStyle,
    this.systemOverlayStyle,
    this.leadingIconColor,
  }) : preferredSize = Size.fromHeight(height ?? kToolbarHeight);

  final dynamic text;
  final VoidCallback? onLeadingPressed;
  final VoidCallback? onTitlePressed;
  final LeadingIcon leadingIcon;
  final AppBarTitle titleType;
  final bool? centerTitle;
  final double? elevation;
  final List<Widget>? actions;
  final double? height;
  final bool automaticallyImplyLeading;
  final Widget? flexibleSpace;
  final PreferredSizeWidget? bottom;
  final Color? shadowColor;
  final ShapeBorder? shape;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final IconThemeData? iconTheme;
  final IconThemeData? actionsIconTheme;
  final bool primary;
  final bool excludeHeaderSemantics;
  final double? titleSpacing;
  final double toolbarOpacity;
  final double bottomOpacity;
  final double? leadingWidth;
  final TextStyle? titleTextStyle;
  final Color? leadingIconColor;
  final SystemUiOverlayStyle? systemOverlayStyle;

  @override
  final Size preferredSize;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // surfaceTintColor: Colors.red,
      // forceMaterialTransparency: true,
      // surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      toolbarHeight: preferredSize.height,
      automaticallyImplyLeading: leadingIcon == LeadingIcon.none ? false : automaticallyImplyLeading,
      flexibleSpace: flexibleSpace,
      bottom: bottom,
      shadowColor: shadowColor,
      shape: shape,
      backgroundColor: backgroundColor ?? AppColors.current.otherWhite,
      foregroundColor: foregroundColor,
      iconTheme: iconTheme,
      actionsIconTheme: actionsIconTheme,
      primary: primary,
      excludeHeaderSemantics: excludeHeaderSemantics,
      titleSpacing: titleSpacing,
      toolbarOpacity: toolbarOpacity,
      bottomOpacity: bottomOpacity,
      leadingWidth: leadingWidth,
      systemOverlayStyle: systemOverlayStyle,
      leading: leadingIcon == LeadingIcon.none
          ? null
          : IconButton(
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              onPressed: onLeadingPressed ?? () => _onPop(context),
              icon: Container(
                padding: const EdgeInsets.only(left: Dimens.paddingHorizontal),
                child: LeadingIcon.close == leadingIcon ? const Icon(Icons.close) : Assets.icons.arrowLeft.svg(),
              ),
            ),
      centerTitle: centerTitle,
      title: GestureDetector(
        onTap: onTitlePressed,
        behavior: HitTestBehavior.translucent,
        child: titleType == AppBarTitle.text
            ? Text(text ?? '', style: titleTextStyle ?? AppTextStyles.h4Bold)
            : (titleType == AppBarTitle.widget ? text : null),
      ),
      actions: actions,
      elevation: elevation,
    );
  }

  void _onPop(BuildContext context) {
    AutoRouter.of(context).back();
    // final isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom.toInt() > 0;
    // if (isKeyboardVisible) context.hideKeyboard();
    // Future.delayed(isKeyboardVisible ? const ShortDuration() : Duration.zero, () => AutoRouter.of(context).back());
  }
}

enum LeadingIcon {
  back,
  close,
  none,
}

enum AppBarTitle {
  text,
  widget,
  none,
}
