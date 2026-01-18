class CourseModel {
  final String id;
  final String title;
  final String description;
  final int level; // 1, 2, or 3
  final double price;
  final DateTime startDate;
  final DateTime endDate;
  final int duration; // in days
  final String? category;
  final String? image;
  final String? trainerId;
  final String? trainerName;
  final String? adminId;
  final DateTime createdAt;

  CourseModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.price,
    required this.startDate,
    required this.endDate,
    required this.duration,
    this.category,
    this.image,
    this.trainerId,
    this.trainerName,
    this.adminId,
    required this.createdAt,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    // Handle both String and DateTime for dates
    DateTime parseDate(dynamic dateValue) {
      if (dateValue == null) {
        // Default to 1 year from now if null
        return DateTime.now().add(const Duration(days: 365));
      }
      if (dateValue is DateTime) {
        return dateValue;
      } else if (dateValue is String) {
        try {
          return DateTime.parse(dateValue);
        } catch (e) {
          print('⚠️ Failed to parse date: $dateValue, error: $e');
          // Default to 1 year from now if parsing fails
          return DateTime.now().add(const Duration(days: 365));
        }
      }
      // Default to 1 year from now
      return DateTime.now().add(const Duration(days: 365));
    }

    return CourseModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? 1,
      price: (json['price'] ?? 0).toDouble(),
      startDate: parseDate(json['startDate']),
      endDate: parseDate(json['endDate']),
      duration: json['duration'] ?? 0,
      category: json['category'],
      image: json['image'],
      trainerId: json['trainerId'],
      trainerName: json['trainerName'],
      adminId: json['adminId'],
      createdAt: parseDate(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    // Helper to convert date to string
    String dateToString(dynamic date) {
      if (date is DateTime) {
        return date.toIso8601String();
      } else if (date is String) {
        return date;
      }
      return DateTime.now().toIso8601String();
    }

    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'price': price,
      'startDate': dateToString(startDate),
      'endDate': dateToString(endDate),
      'duration': duration,
      'category': category,
      'image': image,
      'trainerId': trainerId,
      'trainerName': trainerName,
      'adminId': adminId,
      'createdAt': dateToString(createdAt),
    };
  }

  bool get isActive {
    try {
      // endDate is always DateTime after parsing in fromJson
      return DateTime.now().isBefore(endDate);
    } catch (e) {
      // If there's an error, assume active to show the course
      return true;
    }
  }
}

