class CounselorModel {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String specialization;
  final int experienceYears;
  final double rating;
  final int studentsGuided;
  final double pricePerSession;
  final String bio;
  final List<String> languages;
  final bool isAvailable;

  CounselorModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.email,
    required this.specialization,
    required this.experienceYears,
    required this.rating,
    required this.studentsGuided,
    required this.pricePerSession,
    required this.bio,
    required this.languages,
    this.isAvailable = true,
  });

  factory CounselorModel.fromJson(Map<String, dynamic> json) {
    return CounselorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String,
      email: json['email'] as String,
      specialization: json['specialization'] as String,
      experienceYears: json['experienceYears'] as int,
      rating: (json['rating'] as num).toDouble(),
      studentsGuided: json['studentsGuided'] as int,
      pricePerSession: (json['pricePerSession'] as num).toDouble(),
      bio: json['bio'] as String,
      languages: List<String>.from(json['languages'] as List),
      isAvailable: json['isAvailable'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'specialization': specialization,
      'experienceYears': experienceYears,
      'rating': rating,
      'studentsGuided': studentsGuided,
      'pricePerSession': pricePerSession,
      'bio': bio,
      'languages': languages,
      'isAvailable': isAvailable,
    };
  }
}
