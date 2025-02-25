import 'package:flutter_bloc_template/base/helper/checker.dart';
import 'package:formz/formz.dart';

enum NameInputError {
  empty;

  String fromTitle() {
    return switch(this) {
      NameInputError.empty => 'Name cannot be empty',
    };
  }
}

final class NameInput extends FormzInput<String, NameInputError> {
  const NameInput.pure() : super.pure('');
  const NameInput.dirty([super.value = '']) : super.dirty();

  @override
  NameInputError? validator(String value) {
    if (empty(value)) return NameInputError.empty;
    return null;
  }
}
