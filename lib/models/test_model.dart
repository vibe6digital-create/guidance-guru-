import 'question_model.dart';

enum TestStatus { notStarted, inProgress, completed, expired }

class TestModel {
  final String id;
  final String title;
  final String description;
  final List<Question> questions;
  final int durationMinutes;
  final TestStatus status;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final Map<String, String> answers; // questionId -> selectedOption
  final double? score;

  TestModel({
    required this.id,
    required this.title,
    required this.description,
    required this.questions,
    this.durationMinutes = 45,
    this.status = TestStatus.notStarted,
    this.startedAt,
    this.completedAt,
    this.answers = const {},
    this.score,
  });

  factory TestModel.fromJson(Map<String, dynamic> json) {
    return TestModel(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      questions: (json['questions'] as List<dynamic>?)
              ?.map((e) => Question.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      durationMinutes: json['durationMinutes'] as int? ?? 45,
      status: TestStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => TestStatus.notStarted,
      ),
      startedAt: json['startedAt'] != null
          ? DateTime.parse(json['startedAt'] as String)
          : null,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
      answers: json['answers'] != null
          ? Map<String, String>.from(json['answers'] as Map)
          : {},
      score: (json['score'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'questions': questions.map((q) => q.toJson()).toList(),
        'durationMinutes': durationMinutes,
        'status': status.name,
        'startedAt': startedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'answers': answers,
        'score': score,
      };

  int get totalQuestions => questions.length;
  int get answeredQuestions => answers.length;
  bool get isComplete => answeredQuestions == totalQuestions;

  double get scorePercentage {
    if (score != null) return score!;
    if (questions.isEmpty) return 0;
    int correct = 0;
    for (final q in questions) {
      if (answers[q.id] == q.correctAnswer) correct++;
    }
    return (correct / totalQuestions) * 100;
  }

  TestModel copyWith({
    TestStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    Map<String, String>? answers,
    double? score,
  }) {
    return TestModel(
      id: id,
      title: title,
      description: description,
      questions: questions,
      durationMinutes: durationMinutes,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      answers: answers ?? this.answers,
      score: score ?? this.score,
    );
  }
}

class CategoryScore {
  final String category;
  final double score;
  final int totalQuestions;
  final int correctAnswers;

  CategoryScore({
    required this.category,
    required this.score,
    required this.totalQuestions,
    required this.correctAnswers,
  });

  factory CategoryScore.fromJson(Map<String, dynamic> json) {
    return CategoryScore(
      category: json['category'] as String,
      score: (json['score'] as num).toDouble(),
      totalQuestions: json['totalQuestions'] as int,
      correctAnswers: json['correctAnswers'] as int,
    );
  }
}
