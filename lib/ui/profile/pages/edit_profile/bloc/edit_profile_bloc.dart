
import 'package:flutter_bloc_template/base/bloc/base_bloc/base_bloc.dart';
import 'package:flutter_bloc_template/domain/use_case/user/fetch_profile_use_case.dart';
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/bloc/edit_profile_event.dart';
import 'package:flutter_bloc_template/ui/profile/pages/edit_profile/bloc/edit_profile_state.dart';
import 'package:injectable/injectable.dart';

@injectable
class EditProfileBloc extends BaseBloc<EditProfileEvent, EditProfileState> {
  EditProfileBloc(this._fetchProfileUseCase) : super(EditProfileState());

  final FetchProfileUseCase _fetchProfileUseCase;
}