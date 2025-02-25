abstract final class ValidationUtils {
  const ValidationUtils._();

  static final _emailRegExp = RegExp(r'^[a-zA-Z0-9_.+-]+@[a-zA-Z0-9-]+\.[a-zA-Z0-9-.]+$');


  static bool hasMinimumLength(String val) {
    final regex = RegExp(r'^.{8,}$');
    return regex.hasMatch(val);
  }

  static bool isEmail(String input) {
    return _emailRegExp.hasMatch(input);
  }
}
