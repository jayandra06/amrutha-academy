import 'package:flutter_bloc_template/base/helper/result.dart';
import 'package:flutter_bloc_template/base/use_case/base_use_case.dart';
import 'package:flutter_bloc_template/base/use_case/future_use_case.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';
import 'package:flutter_bloc_template/domain/repo/course_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
class FetchSearchHistoryListUseCase extends FutureUseCase<List<SearchHistoryEntity>, NoParam?> {
  final CourseRepo _repo;

  FetchSearchHistoryListUseCase(this._repo);

  @override
  Future<Result<List<SearchHistoryEntity>>> invoke(NoParam? param) {
    return _repo.fetchSearchHistories();
  }
}
