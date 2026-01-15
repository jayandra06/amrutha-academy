class UserModel {
  final String id;
  final String fullName;
  final String email;
  final String? avatar;
  final String? bio;
  final String phoneNumber;
  final DateTime? birthday;
  final String? location;
  final String role; // student, trainer, admin

  UserModel({
    required this.id,
    required this.fullName,
    required this.email,
    this.avatar,
    this.bio,
    required this.phoneNumber,
    this.birthday,
    this.location,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      avatar: json['avatar'],
      bio: json['bio'],
      phoneNumber: json['phoneNumber'] ?? '',
      birthday: json['birthday'] != null
          ? DateTime.parse(json['birthday'])
          : null,
      location: json['location'],
      role: json['role'] ?? 'student',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'avatar': avatar,
      'bio': bio,
      'phoneNumber': phoneNumber,
      'birthday': birthday?.toIso8601String(),
      'location': location,
      'role': role,
    };
  }

  bool get isStudent => role == 'student';
  bool get isTrainer => role == 'trainer';
  bool get isAdmin => role == 'admin';
}




