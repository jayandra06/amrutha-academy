
import 'package:flutter_bloc_template/base/use_case/stream_use_case.dart';
import 'package:flutter_bloc_template/domain/entity/user/user_entity.dart';
import 'package:flutter_bloc_template/domain/repo/user_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
final class ListenUserProfileStreamUseCase extends StreamUseCase<UserEntity> {
  final UserRepo _repo;

  ListenUserProfileStreamUseCase(this._repo);

  @override
  Stream<UserEntity> invoke() {
    return _repo.listenUserProfileStream();
  }
}
