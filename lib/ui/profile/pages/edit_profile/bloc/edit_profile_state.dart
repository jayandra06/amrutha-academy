import 'package:flutter_bloc_template/base/bloc/base_bloc/base_state.dart';
import 'package:flutter_bloc_template/domain/entity/user/user_entity.dart';
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/utils/name_input.dart';

import '../utils/email_input.dart';

final class EditProfileState extends BaseState {
  final NameInput nameInput;
  final EmailInput emailInput;
  final UserEntity userEntity;

  EditProfileState({
    required this.nameInput,
    required this.emailInput,
    required this.userEntity,
  });

  EditProfileState copyWith({
    NameInput? nameInput,
    EmailInput? emailInput,
    UserEntity? userEntity,
  }) {
    return EditProfileState(
      nameInput: nameInput ?? this.nameInput,
      emailInput: emailInput ?? this.emailInput,
      userEntity: userEntity ?? this.userEntity,
    );
  }

  @override
  List<Object?> get props => [
        nameInput,
        emailInput,
        userEntity,
      ];
}
