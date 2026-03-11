import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/test_model.dart';
import '../models/question_model.dart';
import 'firestore_service.dart';

class TestService {
  final FirestoreService _fs = FirestoreService();

  bool get _useMock => dotenv.get('USE_MOCK', fallback: 'false') == 'true';

  Future<TestModel> generateTest() async {
    if (_useMock) return getMockTest();

    // Query for an active test
    final tests = await _fs.getCollection(
      _fs.tests,
      where: [WhereClause('isActive', isEqualTo: true)],
      limit: 1,
    );

    if (tests.isEmpty) return getMockTest();

    final testDoc = tests.first;
    // Fetch questions sub-collection
    final questionDocs = await _fs.getCollection(_fs.questions(testDoc['id']));
    final questions = questionDocs.map((q) => Question.fromJson(q)).toList();

    return TestModel(
      id: testDoc['id'],
      title: testDoc['title'] ?? 'Career Aptitude Assessment',
      description: testDoc['description'] ?? '',
      questions: questions,
      durationMinutes: testDoc['durationMinutes'] ?? 45,
    );
  }

  Future<Map<String, dynamic>> submitTest({
    required String testId,
    required String studentId,
    required Map<String, String> answers,
    required double score,
    required List<Map<String, dynamic>> categoryScores,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return {'success': true, 'testAttemptId': 'mock_attempt_1'};
    }

    final data = {
      'testId': testId,
      'studentId': studentId,
      'answers': answers,
      'score': score,
      'categoryScores': categoryScores,
      'completedAt': DateTime.now().toIso8601String(),
    };

    final id = await _fs.addDocument(_fs.testAttempts, data);
    return {'success': true, 'testAttemptId': id};
  }

  Future<Map<String, dynamic>?> getResult(String attemptId) async {
    if (_useMock) return null;
    return _fs.getDocument(_fs.testAttempts, attemptId);
  }

  Future<List<TestModel>> getTestHistory(String studentId) async {
    if (_useMock) return [];

    final docs = await _fs.getCollection(
      _fs.testAttempts,
      where: [WhereClause('studentId', isEqualTo: studentId)],
      orderBy: 'completedAt',
      descending: true,
    );

    return docs.map((d) {
      return TestModel(
        id: d['id'],
        title: d['title'] ?? 'Career Aptitude Test',
        description: d['description'] ?? '',
        questions: [],
        durationMinutes: d['durationMinutes'] ?? 45,
        status: TestStatus.completed,
        completedAt: d['completedAt'] != null ? DateTime.parse(d['completedAt']) : null,
        score: (d['score'] as num?)?.toDouble(),
      );
    }).toList();
  }

  // ── Mock data (preserved for development / USE_MOCK=true) ──

  static List<Question> getMockQuestions() {
    return [
      Question(
        id: 'q1',
        questionText: 'Which activity do you enjoy the most in your free time?',
        options: ['Reading books', 'Building things', 'Helping others', 'Solving puzzles'],
        correctAnswer: 'Solving puzzles',
        category: 'interest',
        difficulty: 'easy',
      ),
      Question(
        id: 'q2',
        questionText: 'If 3x + 7 = 22, what is the value of x?',
        options: ['3', '5', '7', '15'],
        correctAnswer: '5',
        category: 'aptitude',
        difficulty: 'easy',
      ),
      Question(
        id: 'q3',
        questionText: 'How do you typically handle a disagreement with a friend?',
        options: [
          'Avoid the conflict',
          'Discuss it calmly',
          'Stand firm on my position',
          'Seek a mediator',
        ],
        correctAnswer: 'Discuss it calmly',
        category: 'personality',
        difficulty: 'easy',
      ),
      Question(
        id: 'q4',
        questionText: 'What is the next number in the series: 2, 6, 12, 20, ?',
        options: ['28', '30', '32', '36'],
        correctAnswer: '30',
        category: 'aptitude',
        difficulty: 'medium',
      ),
      Question(
        id: 'q5',
        questionText: 'Which career field interests you the most?',
        options: ['Technology', 'Healthcare', 'Business', 'Creative Arts'],
        correctAnswer: 'Technology',
        category: 'interest',
        difficulty: 'easy',
      ),
      Question(
        id: 'q6',
        questionText: 'In a group project, you usually:',
        options: [
          'Take the lead',
          'Do research',
          'Handle presentation',
          'Support team members',
        ],
        correctAnswer: 'Take the lead',
        category: 'personality',
        difficulty: 'easy',
      ),
      Question(
        id: 'q7',
        questionText: 'A train travels 120 km in 2 hours. What is its speed?',
        options: ['40 km/h', '50 km/h', '60 km/h', '80 km/h'],
        correctAnswer: '60 km/h',
        category: 'aptitude',
        difficulty: 'easy',
      ),
      Question(
        id: 'q8',
        questionText: 'Which subject do you find most engaging?',
        options: ['Mathematics', 'Science', 'Literature', 'Social Studies'],
        correctAnswer: 'Mathematics',
        category: 'interest',
        difficulty: 'easy',
      ),
      Question(
        id: 'q9',
        questionText: 'When facing a new challenge, you tend to:',
        options: [
          'Plan everything first',
          'Jump right in',
          'Ask for guidance',
          'Research thoroughly',
        ],
        correctAnswer: 'Plan everything first',
        category: 'personality',
        difficulty: 'medium',
      ),
      Question(
        id: 'q10',
        questionText: 'Find the odd one out: Apple, Mango, Potato, Banana',
        options: ['Apple', 'Mango', 'Potato', 'Banana'],
        correctAnswer: 'Potato',
        category: 'aptitude',
        difficulty: 'easy',
      ),
      Question(
        id: 'q11',
        questionText: 'Which work environment do you prefer?',
        options: ['Office', 'Outdoors', 'Laboratory', 'Remote/Home'],
        correctAnswer: 'Office',
        category: 'interest',
        difficulty: 'easy',
      ),
      Question(
        id: 'q12',
        questionText: 'How do you prefer to learn new things?',
        options: [
          'Visual aids and videos',
          'Reading and writing',
          'Hands-on practice',
          'Group discussions',
        ],
        correctAnswer: 'Hands-on practice',
        category: 'personality',
        difficulty: 'easy',
      ),
      Question(
        id: 'q13',
        questionText: 'If a rectangle has length 8 and width 5, what is its area?',
        options: ['13', '26', '40', '45'],
        correctAnswer: '40',
        category: 'aptitude',
        difficulty: 'easy',
      ),
      Question(
        id: 'q14',
        questionText: 'What motivates you the most?',
        options: ['Money', 'Recognition', 'Making a difference', 'Learning'],
        correctAnswer: 'Making a difference',
        category: 'interest',
        difficulty: 'easy',
      ),
      Question(
        id: 'q15',
        questionText: 'Complete the analogy: Doctor is to Hospital as Teacher is to:',
        options: ['School', 'Student', 'Books', 'Education'],
        correctAnswer: 'School',
        category: 'aptitude',
        difficulty: 'medium',
      ),
    ];
  }

  static TestModel getMockTest() {
    return TestModel(
      id: 'test_mock_1',
      title: 'Career Aptitude Assessment',
      description: 'Comprehensive test covering aptitude, interests, and personality traits',
      questions: getMockQuestions(),
      durationMinutes: 45,
    );
  }
}
