import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/constants/ui/app_colors.dart';

enum PopupType {
  notify,
  normal;
}

abstract final class AppDialogs {
  const AppDialogs._();

  static Future showScrollBottomSheet(
    BuildContext context, {
    required ScrollableWidgetBuilder builder,
    bool useRootNavigator = false,
    bool isDismissible = true,
    double maxChildSize = 1,
    double minChildSize = 0.3,
    initialChildSize = 0.5,
    bool canTopClose = false,
  }) async {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: false,
        isScrollControlled: true,
        isDismissible: isDismissible,
        backgroundColor: Colors.transparent,
        builder: (context) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              if (isDismissible) {
                Navigator.of(context).pop();
              }
            },
            child: GestureDetector(
              child: DraggableScrollableSheet(
                  maxChildSize: maxChildSize,
                  minChildSize: minChildSize,
                  initialChildSize: initialChildSize,
                  builder: (context, controller) {
                    return Container(
                      decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(16),
                            topLeft: Radius.circular(16),
                          )),
                      child: Column(
                        children: [
                          GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () {
                              if (canTopClose) Navigator.of(context).pop();
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 8, bottom: 12),
                              height: 5,
                              width: 48,
                              decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(99)),
                            ),
                          ),
                          Expanded(child: builder(context, controller))
                        ],
                      ),
                    );
                  }),
              onTap: () {},
            ),
          );
        });
  }

  static Future showDisableScrollBottomSheet(
    BuildContext context, {
    required WidgetBuilder builder,
    bool useRootNavigator = false,
    bool isDismissible = true,
    bool isDynamic = false,
  }) async {
    return showModalBottomSheet(
        context: context,
        useRootNavigator: useRootNavigator,
        isScrollControlled: true,
        isDismissible: isDismissible,
        builder: (context) {
          return Container(
            decoration: const BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.only(topRight: Radius.circular(16), topLeft: Radius.circular(16))),
            child: isDynamic
                ? builder(context)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 8, bottom: 12),
                        height: 5,
                        width: 48,
                        decoration: BoxDecoration(color: Colors.grey, borderRadius: BorderRadius.circular(99)),
                      ),
                      builder(context)
                    ],
                  ),
          );
        });
  }

  static Future<T?> showPopup<T extends Object?>(
    BuildContext context, {
    bool barrierDismissible = true,
    WidgetBuilder? builder,
    Widget? child,
    Curve curve = Curves.linear,
    Duration? duration,
    Alignment alignment = Alignment.center,
    Axis? axis,
    Color? barrierColor,
    PopupType popupType = PopupType.normal,
  }) async {
    return showGeneralDialog(
      context: context,
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        final Widget? pageChild = builder != null ? Builder(builder: builder) : child;
        return Builder(
          builder: (BuildContext context) => Dialog(
            insetPadding: const EdgeInsets.all(44),
            backgroundColor: AppColors.current.otherWhite,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: pageChild,
            ),
          ),
        );
      },
      barrierDismissible: barrierDismissible,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: barrierColor ?? Colors.black54,
      transitionDuration: duration ?? const Duration(milliseconds: 400),
      transitionBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
