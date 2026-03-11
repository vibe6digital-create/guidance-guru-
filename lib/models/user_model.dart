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
  final String? counselorName;
  final String? counselorPhone;
  final String? parentName;
  final String? parentPhone;

  UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.role,
    this.profileImage,
    required this.createdAt,
    this.studentCode,
    this.counselorName,
    this.counselorPhone,
    this.parentName,
    this.parentPhone,
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
      counselorName: json['counselorName'] as String?,
      counselorPhone: json['counselorPhone'] as String?,
      parentName: json['parentName'] as String?,
      parentPhone: json['parentPhone'] as String?,
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
      'counselorName': counselorName,
      'counselorPhone': counselorPhone,
      'parentName': parentName,
      'parentPhone': parentPhone,
    };
  }

  UserModel copyWith({
    String? name,
    String? email,
    String? profileImage,
    String? counselorName,
    String? counselorPhone,
    String? parentName,
    String? parentPhone,
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
      counselorName: counselorName ?? this.counselorName,
      counselorPhone: counselorPhone ?? this.counselorPhone,
      parentName: parentName ?? this.parentName,
      parentPhone: parentPhone ?? this.parentPhone,
    );
  }
}
