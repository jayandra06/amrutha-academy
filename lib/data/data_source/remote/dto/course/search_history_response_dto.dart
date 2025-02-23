import 'package:freezed_annotation/freezed_annotation.dart';
part 'search_history_response_dto.freezed.dart';
part 'search_history_response_dto.g.dart';

@freezed
class SearchHistoryResponseDto with _$SearchHistoryResponseDto {
  const factory SearchHistoryResponseDto({
    String? id,
    String? keyword,
    DateTime? searchedAt,
  }) = _SearchHistoryResponseDto;

  factory SearchHistoryResponseDto.fromJson(Map<String, Object?> json) => _$SearchHistoryResponseDtoFromJson(json);
}
