import 'test_model.dart';

class CareerRecommendation {
  final String careerName;
  final double matchPercentage;
  final String description;
  final List<String> skillsRequired;
  final List<String> skillsToDevelop;
  final String educationPath;

  CareerRecommendation({
    required this.careerName,
    required this.matchPercentage,
    required this.description,
    required this.skillsRequired,
    required this.skillsToDevelop,
    required this.educationPath,
  });

  factory CareerRecommendation.fromJson(Map<String, dynamic> json) {
    return CareerRecommendation(
      careerName: json['careerName'] as String,
      matchPercentage: (json['matchPercentage'] as num).toDouble(),
      description: json['description'] as String,
      skillsRequired: List<String>.from(json['skillsRequired'] as List),
      skillsToDevelop: List<String>.from(json['skillsToDevelop'] as List),
      educationPath: json['educationPath'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'careerName': careerName,
        'matchPercentage': matchPercentage,
        'description': description,
        'skillsRequired': skillsRequired,
        'skillsToDevelop': skillsToDevelop,
        'educationPath': educationPath,
      };
}

class CounselorRemark {
  final String id;
  final String counselorId;
  final String counselorName;
  final String studentId;
  final String message;
  final RemarkType type;
  final List<String> actionItems;
  final DateTime createdAt;

  CounselorRemark({
    required this.id,
    required this.counselorId,
    required this.counselorName,
    required this.studentId,
    required this.message,
    required this.type,
    this.actionItems = const [],
    required this.createdAt,
  });

  factory CounselorRemark.fromJson(Map<String, dynamic> json) {
    return CounselorRemark(
      id: json['id'] as String,
      counselorId: json['counselorId'] as String,
      counselorName: json['counselorName'] as String,
      studentId: json['studentId'] as String,
      message: json['message'] as String,
      type: RemarkType.values.firstWhere(
        (t) => t.name == json['type'],
        orElse: () => RemarkType.general,
      ),
      actionItems: json['actionItems'] != null
          ? List<String>.from(json['actionItems'] as List)
          : [],
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'counselorId': counselorId,
        'counselorName': counselorName,
        'studentId': studentId,
        'message': message,
        'type': type.name,
        'actionItems': actionItems,
        'createdAt': createdAt.toIso8601String(),
      };
}

enum RemarkType { general, academic, career, urgent }

class ReportModel {
  final String id;
  final String studentId;
  final String testId;
  final double overallScore;
  final String performanceBand;
  final List<CategoryScore> categoryScores;
  final List<CareerRecommendation> recommendations;
  final List<CounselorRemark> remarks;
  final DateTime generatedAt;
  final String? aiSummary;
  final List<String>? strengths;
  final List<String>? areasForImprovement;

  ReportModel({
    required this.id,
    required this.studentId,
    required this.testId,
    required this.overallScore,
    required this.performanceBand,
    required this.categoryScores,
    required this.recommendations,
    this.remarks = const [],
    required this.generatedAt,
    this.aiSummary,
    this.strengths,
    this.areasForImprovement,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      studentId: json['studentId'] as String,
      testId: json['testId'] as String,
      overallScore: (json['overallScore'] as num).toDouble(),
      performanceBand: json['performanceBand'] as String,
      categoryScores: (json['categoryScores'] as List<dynamic>)
          .map((e) => CategoryScore.fromJson(e as Map<String, dynamic>))
          .toList(),
      recommendations: (json['recommendations'] as List<dynamic>)
          .map((e) =>
              CareerRecommendation.fromJson(e as Map<String, dynamic>))
          .toList(),
      remarks: (json['remarks'] as List<dynamic>?)
              ?.map(
                  (e) => CounselorRemark.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      generatedAt: DateTime.parse(json['generatedAt'] as String),
      aiSummary: json['aiSummary'] as String?,
      strengths: (json['strengths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      areasForImprovement: (json['areasForImprovement'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'studentId': studentId,
        'testId': testId,
        'overallScore': overallScore,
        'performanceBand': performanceBand,
        'categoryScores':
            categoryScores.map((e) => {'category': e.category, 'score': e.score}).toList(),
        'recommendations': recommendations.map((e) => e.toJson()).toList(),
        'remarks': remarks.map((e) => e.toJson()).toList(),
        'generatedAt': generatedAt.toIso8601String(),
        if (aiSummary != null) 'aiSummary': aiSummary,
        if (strengths != null) 'strengths': strengths,
        if (areasForImprovement != null) 'areasForImprovement': areasForImprovement,
      };
}
