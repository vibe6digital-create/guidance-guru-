import '../models/report_model.dart';
import '../models/test_model.dart';
import 'api_service.dart';

class ReportService {
  final ApiService _api = ApiService();

  Future<ReportModel> getReport(String reportId) async {
    final response = await _api.get('/student/report/$reportId');
    return ReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<ReportModel> getStudentReport(String studentId) async {
    final response = await _api.get('/parent/student-report/$studentId');
    return ReportModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<void> addRemark({
    required String studentId,
    required String message,
    required RemarkType type,
    required List<String> actionItems,
  }) async {
    await _api.post('/counselor/remark', data: {
      'studentId': studentId,
      'message': message,
      'type': type.name,
      'actionItems': actionItems,
    });
  }

  Future<void> updateRemark({
    required String remarkId,
    required String message,
    required RemarkType type,
    required List<String> actionItems,
  }) async {
    await _api.put('/counselor/remark/$remarkId', data: {
      'message': message,
      'type': type.name,
      'actionItems': actionItems,
    });
  }

  // Mock data for development
  static ReportModel getMockReport() {
    return ReportModel(
      id: 'report_1',
      studentId: 'student_1',
      testId: 'test_mock_1',
      overallScore: 78.5,
      performanceBand: 'Good',
      categoryScores: [
        CategoryScore(category: 'Aptitude', score: 82, totalQuestions: 5, correctAnswers: 4),
        CategoryScore(category: 'Interest', score: 75, totalQuestions: 5, correctAnswers: 4),
        CategoryScore(category: 'Personality', score: 78, totalQuestions: 5, correctAnswers: 4),
      ],
      recommendations: [
        CareerRecommendation(
          careerName: 'Software Engineering',
          matchPercentage: 92,
          description: 'Design, develop, and maintain software systems. Strong analytical and problem-solving skills align well with your profile.',
          skillsRequired: ['Programming', 'Problem Solving', 'System Design', 'Teamwork'],
          skillsToDevelop: ['Data Structures', 'Cloud Computing', 'AI/ML Basics'],
          educationPath: 'B.Tech/B.E. in Computer Science → M.Tech or MBA in Tech Management',
        ),
        CareerRecommendation(
          careerName: 'Data Science',
          matchPercentage: 87,
          description: 'Analyze complex data sets to help organizations make better decisions. Your aptitude for mathematics is a strong foundation.',
          skillsRequired: ['Statistics', 'Programming', 'Data Analysis', 'Communication'],
          skillsToDevelop: ['Machine Learning', 'Python', 'SQL', 'Visualization Tools'],
          educationPath: 'B.Tech in CS/Stats → M.Sc in Data Science or PG Diploma',
        ),
        CareerRecommendation(
          careerName: 'Product Management',
          matchPercentage: 81,
          description: 'Bridge the gap between technology, business, and user experience. Your leadership traits and analytical skills are a great match.',
          skillsRequired: ['Leadership', 'Communication', 'Analytical Thinking', 'User Empathy'],
          skillsToDevelop: ['UX Design Basics', 'Agile Methodology', 'Market Research'],
          educationPath: 'Any B.Tech/BBA → MBA or Product Management Certification',
        ),
      ],
      remarks: [
        CounselorRemark(
          id: 'remark_1',
          counselorId: 'counselor_1',
          counselorName: 'Dr. Priya Sharma',
          studentId: 'student_1',
          message: 'Strong analytical aptitude observed. Recommend exploring STEM career paths with focus on technology. Consider participating in coding competitions.',
          type: RemarkType.career,
          actionItems: [
            'Join a coding club or online platform',
            'Take an introductory programming course',
            'Attend a career guidance workshop',
          ],
          createdAt: DateTime.now().subtract(const Duration(days: 3)),
        ),
      ],
      generatedAt: DateTime.now(),
    );
  }
}
