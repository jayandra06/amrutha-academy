import 'package:flutter_bloc_template/data/data_source/remote/dto/course/course_response_dto.dart';
import 'package:flutter_bloc_template/data/mapper/course/tool_mapper.dart';

import '../../../domain/entity/course/course_entity.dart';
import 'mentor_mapper.dart';

abstract final class CourseMapper {
  static CourseEntity mapToEntity(CourseResponseDto? dto) {
    return CourseEntity(
      id: dto?.id ?? '',
      title: dto?.title ?? '',
      category: dto?.category ?? '',
      image: dto?.image ?? '',
      price: dto?.price ?? 0,
      originalPrice: dto?.originalPrice ?? 0,
      rating: dto?.rating ?? .0,
      reviewsCount: dto?.reviewsCount ?? 0,
      students: dto?.students ?? 0,
      duration: dto?.duration ?? 0,
      certificate: dto?.certificate ?? false,
      mentor: MentorMapper.mapToEntity(dto?.mentor),
      tools: dto?.tools?.map(ToolMapper.mapToEntity).toList() ?? [],
      about: dto?.about ?? '',
      isFavourite: false,
    );
  }
}
