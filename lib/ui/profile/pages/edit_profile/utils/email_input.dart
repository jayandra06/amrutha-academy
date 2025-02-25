import 'package:flutter_bloc_template/base/helper/checker.dart';
import 'package:flutter_bloc_template/base/utils/validation_utils.dart';
import 'package:formz/formz.dart';

enum EmailInputError {
  empty,
  invalid;

  String fromTitle() {
    return switch (this) {
      EmailInputError.empty => 'Email cannot be empty',
      EmailInputError.invalid => 'Invalid email',
    };
  }
}

final class EmailInput extends FormzInput<String, EmailInputError> {
  const EmailInput.pure() : super.pure('');
  const EmailInput.dirty([super.value = '']) : super.dirty();

  @override
  EmailInputError? validator(String value) {
    if (empty(value)) return EmailInputError.empty;
    if (!ValidationUtils.isEmail(value)) return EmailInputError.invalid;
    return null;
  }
}
