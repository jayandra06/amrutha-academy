import 'package:flutter_bloc_template/base/extension/num_extension.dart';
import 'package:flutter_bloc_template/domain/entity/course/mentor_entity.dart';
import 'package:flutter_bloc_template/domain/entity/course/tool_entity.dart';

class CourseEntity {
  final String id;
  final String title;
  final String category;
  final String image;
  final int price;
  final int originalPrice;
  final double rating;
  final int reviewsCount;
  final int students;
  final int duration;
  final bool certificate;
  final MentorEntity mentor;
  final List<ToolEntity> tools;
  final String about;
  final bool isFavourite;

  CourseEntity({
    required this.id,
    required this.title,
    required this.category,
    required this.image,
    required this.price,
    required this.originalPrice,
    required this.rating,
    required this.reviewsCount,
    required this.students,
    required this.duration,
    required this.certificate,
    required this.mentor,
    required this.tools,
    required this.about,
    required this.isFavourite,
  });

  static CourseEntity defaultValue() => CourseEntity(
        id: '',
        title: '',
        category: '',
        image: '',
        price: 0,
        originalPrice: 0,
        rating: 0.0,
        reviewsCount: 0,
        students: 0,
        duration: 0,
        certificate: false,
        mentor: MentorEntity.defaultValue(),
        tools: const [],
        about: '',
        isFavourite: false,
      );

  String displayPrice() {
    return (price.toDouble()).convertToUSD();
  }
}
