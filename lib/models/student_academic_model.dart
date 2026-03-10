class SubjectMark {
  final String subject;
  final double marks;
  final double maxMarks;

  SubjectMark({
    required this.subject,
    required this.marks,
    this.maxMarks = 100,
  });

  factory SubjectMark.fromJson(Map<String, dynamic> json) {
    return SubjectMark(
      subject: json['subject'] as String,
      marks: (json['marks'] as num).toDouble(),
      maxMarks: (json['maxMarks'] as num?)?.toDouble() ?? 100,
    );
  }

  Map<String, dynamic> toJson() => {
        'subject': subject,
        'marks': marks,
        'maxMarks': maxMarks,
      };

  double get percentage => (marks / maxMarks) * 100;
}

class StudentAcademicModel {
  final String? id;
  final String studentId;
  final List<SubjectMark> class10Marks;
  final double? class10Percentage;
  final List<SubjectMark> class12Marks;
  final double? class12Percentage;
  final String? class12Stream;
  final double? graduationPercentage;
  final String? graduationField;
  final double? pgPercentage;
  final String? pgField;

  StudentAcademicModel({
    this.id,
    required this.studentId,
    required this.class10Marks,
    this.class10Percentage,
    required this.class12Marks,
    this.class12Percentage,
    this.class12Stream,
    this.graduationPercentage,
    this.graduationField,
    this.pgPercentage,
    this.pgField,
  });

  factory StudentAcademicModel.fromJson(Map<String, dynamic> json) {
    return StudentAcademicModel(
      id: json['id'] as String?,
      studentId: json['studentId'] as String,
      class10Marks: (json['class10Marks'] as List<dynamic>?)
              ?.map((e) => SubjectMark.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      class10Percentage: (json['class10Percentage'] as num?)?.toDouble(),
      class12Marks: (json['class12Marks'] as List<dynamic>?)
              ?.map((e) => SubjectMark.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      class12Percentage: (json['class12Percentage'] as num?)?.toDouble(),
      class12Stream: json['class12Stream'] as String?,
      graduationPercentage:
          (json['graduationPercentage'] as num?)?.toDouble(),
      graduationField: json['graduationField'] as String?,
      pgPercentage: (json['pgPercentage'] as num?)?.toDouble(),
      pgField: json['pgField'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        if (id != null) 'id': id,
        'studentId': studentId,
        'class10Marks': class10Marks.map((e) => e.toJson()).toList(),
        'class10Percentage': class10Percentage,
        'class12Marks': class12Marks.map((e) => e.toJson()).toList(),
        'class12Percentage': class12Percentage,
        'class12Stream': class12Stream,
        'graduationPercentage': graduationPercentage,
        'graduationField': graduationField,
        'pgPercentage': pgPercentage,
        'pgField': pgField,
      };

  StudentAcademicModel copyWith({
    List<SubjectMark>? class10Marks,
    double? class10Percentage,
    List<SubjectMark>? class12Marks,
    double? class12Percentage,
    String? class12Stream,
    double? graduationPercentage,
    String? graduationField,
    double? pgPercentage,
    String? pgField,
  }) {
    return StudentAcademicModel(
      id: id,
      studentId: studentId,
      class10Marks: class10Marks ?? this.class10Marks,
      class10Percentage: class10Percentage ?? this.class10Percentage,
      class12Marks: class12Marks ?? this.class12Marks,
      class12Percentage: class12Percentage ?? this.class12Percentage,
      class12Stream: class12Stream ?? this.class12Stream,
      graduationPercentage:
          graduationPercentage ?? this.graduationPercentage,
      graduationField: graduationField ?? this.graduationField,
      pgPercentage: pgPercentage ?? this.pgPercentage,
      pgField: pgField ?? this.pgField,
    );
  }
}
