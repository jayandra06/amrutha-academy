// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseResponseDtoImpl _$$CourseResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$CourseResponseDtoImpl(
      id: json['id'] as String?,
      title: json['title'] as String?,
      category: json['category'] as String?,
      image: json['image'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewsCount: (json['reviewsCount'] as num?)?.toInt(),
      price: (json['price'] as num?)?.toInt(),
      originalPrice: (json['originalPrice'] as num?)?.toInt(),
      students: (json['students'] as num?)?.toInt(),
      duration: (json['duration'] as num?)?.toInt(),
      certificate: json['certificate'] as bool?,
      mentor: json['mentor'] == null
          ? null
          : MentorResponseDto.fromJson(json['mentor'] as Map<String, dynamic>),
      about: json['about'] as String?,
      tools: (json['tools'] as List<dynamic>?)
          ?.map((e) => ToolResponseDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      isFavourite: json['isFavourite'] as bool?,
    );

Map<String, dynamic> _$$CourseResponseDtoImplToJson(
        _$CourseResponseDtoImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'category': instance.category,
      'image': instance.image,
      'rating': instance.rating,
      'reviewsCount': instance.reviewsCount,
      'price': instance.price,
      'originalPrice': instance.originalPrice,
      'students': instance.students,
      'duration': instance.duration,
      'certificate': instance.certificate,
      'mentor': instance.mentor,
      'about': instance.about,
      'tools': instance.tools,
      'isFavourite': instance.isFavourite,
    };

_$ToolResponseDtoImpl _$$ToolResponseDtoImplFromJson(
        Map<String, dynamic> json) =>
    _$ToolResponseDtoImpl(
      name: json['name'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );

Map<String, dynamic> _$$ToolResponseDtoImplToJson(
        _$ToolResponseDtoImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'iconUrl': instance.iconUrl,
    };
