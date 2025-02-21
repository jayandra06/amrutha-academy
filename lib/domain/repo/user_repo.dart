import 'package:flutter_bloc_template/domain/entity/user/user_entity.dart';

import '../../base/helper/result.dart';

abstract class UserRepo {
  Future<Result<UserEntity>> fetchProfile();

  Stream<UserEntity> listenUserProfileStream();
}
