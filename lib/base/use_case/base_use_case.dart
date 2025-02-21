import 'package:flutter_bloc_template/base/exception/app_exception.dart';

import '../helper/helper.dart';

abstract class UseCase<T, P> {
  Future<Result<T>> invoke(P param);
}

abstract class BaseUseCase<T, P> extends UseCase<T, P> {
  Future<Result<T>> buildExecute(P param) async {
    try {
      final output = await invoke(param);
      return output;
    } catch (e) {
      rethrow;
    }
  }
}

class NoParam {}
