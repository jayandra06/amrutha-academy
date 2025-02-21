
import 'package:flutter_bloc_template/base/use_case/stream_use_case.dart';
import 'package:flutter_bloc_template/domain/repo/course_repo.dart';
import 'package:injectable/injectable.dart';

@injectable
final class WatchFavoriteCourseStreamUseCase extends StreamUseCase<WatchFavoriteCourseStreamOutput> {
  final CourseRepo _repo;

  WatchFavoriteCourseStreamUseCase(this._repo);

  @override
  Stream<WatchFavoriteCourseStreamOutput> invoke() {
    return _repo.watchFavoriteCourseStream();
  }
}

class WatchFavoriteCourseStreamOutput {
  final String id;
  final bool isFav;

  WatchFavoriteCourseStreamOutput({required this.id, required this.isFav});
}