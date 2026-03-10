import '../models/test_model.dart';
import '../models/question_model.dart';
import 'api_service.dart';

class TestService {
  final ApiService _api = ApiService();

  Future<TestModel> generateTest() async {
    final response = await _api.get('/test/generate');
    return TestModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Map<String, dynamic>> submitTest({
    required String testId,
    required Map<String, String> answers,
  }) async {
    final response = await _api.post('/test/submit', data: {
      'testId': testId,
      'answers': answers,
    });
    return response.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getResult(String testId) async {
    final response = await _api.get('/test/result/$testId');
    return response.data as Map<String, dynamic>;
  }

  Future<List<TestModel>> getTestHistory() async {
    final response = await _api.get('/test/history');
    final list = response.data as List<dynamic>;
    return list
        .map((e) => TestModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // Mock data for development
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
