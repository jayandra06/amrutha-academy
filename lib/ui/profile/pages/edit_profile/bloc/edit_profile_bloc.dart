import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_bloc_template/base/bloc/base_bloc/base_bloc.dart';
import 'package:flutter_bloc_template/base/use_case/base_use_case.dart';
import 'package:flutter_bloc_template/domain/entity/user/user_entity.dart';
import 'package:flutter_bloc_template/domain/use_case/user/fetch_profile_use_case.dart';
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/bloc/edit_profile_event.dart';
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/bloc/edit_profile_state.dart';
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/utils/email_input.dart';
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/utils/name_input.dart';
import 'package:injectable/injectable.dart';

@injectable
class EditProfileBloc extends BaseBloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc(this._fetchProfileUseCase)
      : super(EditProfileState(
          nameInput: const NameInput.pure(),
          emailInput: const EmailInput.pure(),
          user: UserEntity.defaultValue(),
        )) {
    on<EditProfileDataRequestEvent>(_onEditProfileDataRequestEvent);
    on<ProfileNameChangedEvent>(_onProfileNameChangedEvent);
    on<ProfileEmailChangedEvent>(_onProfileEmailChangedEvent);
    on<ProfilePhoneNumberChangedEvent>(_onProfilePhoneNumberChangedEvent);
  }

  final FetchProfileUseCase _fetchProfileUseCase;

  Future<void> _onEditProfileDataRequestEvent(EditProfileDataRequestEvent event, Emitter<EditProfileState> emit) async {
    return runAction(
      onAction: () async {
        final result = await _fetchProfileUseCase.invoke(null);
        result.when(
          ok: (data) {
            emit(state.copyWith(user: data));
          },
        );
      },
    );
  }

  FutureOr<void> _onProfilePhoneNumberChangedEvent(ProfilePhoneNumberChangedEvent event, Emitter<EditProfileState> emit) {}

  FutureOr<void> _onProfileEmailChangedEvent(ProfileEmailChangedEvent event, Emitter<EditProfileState> emit) {}

  FutureOr<void> _onProfileNameChangedEvent(ProfileNameChangedEvent event, Emitter<EditProfileState> emit) {
    final value = NameInput.dirty(event.value);
    emit(state.copyWith(nameInput: value));
  }
}
