import 'package:flutter_bloc_template/base/bloc/base_bloc/base_event.dart';

sealed class EditProfileEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

final class EditProfileDataRequestEvent extends EditProfileEvent {}

final class ProfileNameChangedEvent extends EditProfileEvent {
  final String value;

  ProfileNameChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

final class ProfileEmailChangedEvent extends EditProfileEvent {
  final String value;

  ProfileEmailChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}

final class ProfilePhoneNumberChangedEvent extends EditProfileEvent {
  final String value;

  ProfilePhoneNumberChangedEvent(this.value);

  @override
  List<Object?> get props => [value];
}