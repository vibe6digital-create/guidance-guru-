enum UserRole { student, parent, counselor }

class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final UserRole role;
  final String? profileImage;
  final DateTime createdAt;
  final String? studentCode;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.studentCode,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String?,
      role: UserRole.values.firstWhere(
        (r) => r.name == json['role'],
        orElse: () => UserRole.student,
      ),
      profileImage: json['profileImage'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      studentCode: json['studentCode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'role': role.name,
      'profileImage': profileImage,
      'createdAt': createdAt.toIso8601String(),
      'studentCode': studentCode,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? profileImage,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      phone: phone,
      email: email ?? this.email,
      role: role,
      profileImage: profileImage ?? this.profileImage,
      createdAt: createdAt,
      studentCode: studentCode,
    );
  }
}
