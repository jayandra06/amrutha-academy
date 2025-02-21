enum AppDialogType {
  confirm,
  ok,
  retry,
  none;
}

abstract class AppNavigator {
  Future<T?> displayDialog<T extends Object?>(
    AppDialogType type, {
    bool barrierDismissible = true,
    bool useSafeArea = false,
    String? title,
    required dynamic message,
  });
}
