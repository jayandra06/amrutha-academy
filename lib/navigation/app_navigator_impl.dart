import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc_template/base/navigator/app_navigator.dart';
import 'package:flutter_bloc_template/base/shared_view/dialog/app_dialogs.dart';
import 'package:flutter_bloc_template/base/shared_view/dialog/common_dialog.dart';
import 'package:flutter_bloc_template/navigation/router.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: AppNavigator)
class AppNavigatorImpl implements AppNavigator {
  final AppRouter _appRouter;

  AppNavigatorImpl(this._appRouter);

  TabsRouter? _tabsRouter;

  final _dialogMaps = <AppDialogType, Completer<dynamic>>{};

  set tabsRouter(TabsRouter tab) {
    _tabsRouter = tab;
  }

  @override
  Future<T?> displayDialog<T extends Object?>(
    AppDialogType type, {
    bool barrierDismissible = true,
    bool useSafeArea = false,
    String? title,
    required dynamic message,
        Widget? icon,
  }) {
    if (_isDialogAlreadyShown(type)) {
      return _dialogMaps[type]!.future as Future<T>;
    }
    _dialogMaps[type] = Completer<T?>();
    return AppDialogs.showPopup(
      barrierDismissible: barrierDismissible,
      _appRouter.navigatorKey.currentContext!,
      builder: (_) {
        final child = CommonDialog(
          message: message,
          title: title,
          icon: icon,
          onTap: () => Navigator.of(_appRouter.navigatorKey.currentContext!).pop(),
          singleButton: type == AppDialogType.ok,
          type: type,
        );
        return PopScope(
          onPopInvokedWithResult: (_, __) async {
            _dialogMaps.remove(type);
            return Future.value();
          },
          child: child,
        );
      },
    );
  }

  bool _isDialogAlreadyShown(AppDialogType dialogType) {
    return _dialogMaps.containsKey(dialogType);
  }
}
