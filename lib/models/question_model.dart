class Question {
  final String id;
  final String questionText;
  final List<String> options;
  final String correctAnswer;
  final String category; // aptitude, interest, personality
  final String difficulty; // easy, medium, hard

  Question({
    required this.id,
    required this.questionText,
    required this.options,
    required this.correctAnswer,
    required this.category,
    required this.difficulty,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      id: json['id'] as String,
      questionText: json['questionText'] as String,
      options: List<String>.from(json['options'] as List),
      correctAnswer: json['correctAnswer'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'questionText': questionText,
        'options': options,
        'correctAnswer': correctAnswer,
        'category': category,
        'difficulty': difficulty,
      };

  bool isCorrect(String answer) => answer == correctAnswer;
}
