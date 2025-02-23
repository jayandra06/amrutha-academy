import 'package:flutter_bloc_template/data/data_source/remote/dto/course/search_history_response_dto.dart';
import 'package:flutter_bloc_template/domain/entity/course/search_history_entity.dart';

abstract class SearchHistoryMapper {
  static SearchHistoryEntity mapToEntity(SearchHistoryResponseDto? dto) {
    return SearchHistoryEntity(
      id: dto?.id ?? '',
      keyword: dto?.keyword ?? '',
      searchedAt: dto?.searchedAt ?? DateTime.now(),
    );
  }
}
