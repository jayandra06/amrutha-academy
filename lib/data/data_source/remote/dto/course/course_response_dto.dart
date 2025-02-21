import 'package:flutter_bloc_template/data/data_source/remote/dto/course/mentor_response_dto.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'course_response_dto.freezed.dart';
part 'course_response_dto.g.dart';

@freezed
class CourseResponseDto with _$CourseResponseDto {
  const factory CourseResponseDto({
    String? id,
    String? title,
    String? category,
    String? image,
    double? rating,
    int? reviewsCount,
    int? price,
    int? originalPrice,
    int? students,
    int? duration,
    bool? certificate,
    MentorResponseDto? mentor,
    String? about,
    List<ToolResponseDto>? tools,
    bool? isFavourite,
  }) = _CourseResponseDto;

  factory CourseResponseDto.fromJson(Map<String, Object?> json) => _$CourseResponseDtoFromJson(json);
}

@freezed
class ToolResponseDto with _$ToolResponseDto {
  const factory ToolResponseDto({
    String? name,
    String? iconUrl,
  }) = _ToolResponseDto;

  factory ToolResponseDto.fromJson(Map<String, Object?> json) => _$ToolResponseDtoFromJson(json);
}
