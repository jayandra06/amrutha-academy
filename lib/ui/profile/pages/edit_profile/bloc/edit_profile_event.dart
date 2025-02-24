import 'package:flutter_bloc_template/base/bloc/base_bloc/base_event.dart';

sealed class EditProfileEvent extends BaseEvent {
  @override
  List<Object?> get props => [];
}

class EditProfileDataRequestEvent extends EditProfileEvent {}