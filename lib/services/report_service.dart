import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/report_model.dart';
import '../models/test_model.dart';
import 'firestore_service.dart';

class ReportService {
  final FirestoreService _fs = FirestoreService();

  bool get _useMock => dotenv.get('USE_MOCK', fallback: 'false') == 'true';

  // ── Queries ─────────────────────────────────────────────────

  Future<ReportModel> getReport(String reportId) async {
    if (_useMock) return getMockReport();

    final doc = await _fs.getDocument(_fs.reports, reportId);
    if (doc == null) return getMockReport();

    // Fetch career recommendations sub-collection
    final recDocs = await _fs.getCollection(_fs.careerRecommendations(reportId));
    final recommendations = recDocs.map((r) => CareerRecommendation.fromJson(r)).toList();

    doc['recommendations'] = recDocs;
    final report = ReportModel.fromJson(doc);

    // Return with merged recommendations
    return ReportModel(
      id: report.id,
      studentId: report.studentId,
      testId: report.testId,
      overallScore: report.overallScore,
      performanceBand: report.performanceBand,
      categoryScores: report.categoryScores,
      recommendations: recommendations,
      remarks: report.remarks,
      generatedAt: report.generatedAt,
      aiSummary: report.aiSummary,
      strengths: report.strengths,
      areasForImprovement: report.areasForImprovement,
    );
  }

  Future<List<ReportModel>> getStudentReports(String studentId) async {
    if (_useMock) return [getMockReport()];

    final docs = await _fs.getCollection(
      _fs.reports,
      where: [WhereClause('studentId', isEqualTo: studentId)],
      orderBy: 'generatedAt',
      descending: true,
    );

    return docs.map((d) => ReportModel.fromJson(d)).toList();
  }

  // ── Mutations ───────────────────────────────────────────────

  Future<String> saveReport(ReportModel report) async {
    if (_useMock) return report.id;

    final data = report.toJson();
    // Remove recommendations — stored in sub-collection
    final recs = data.remove('recommendations') as List<dynamic>? ?? [];

    await _fs.setDocument(_fs.reports, report.id, data, merge: false);

    // Write each recommendation as a sub-doc
    for (var i = 0; i < recs.length; i++) {
      final recData = recs[i] is Map<String, dynamic>
          ? recs[i] as Map<String, dynamic>
          : (recs[i] as CareerRecommendation).toJson();
      await _fs.setDocument(
        _fs.careerRecommendations(report.id),
        'rec_$i',
        recData,
      );
    }

    return report.id;
  }

  Future<void> addRemark({
    required String studentId,
    required String counselorId,
    required String counselorName,
    required String message,
    required RemarkType type,
    required List<String> actionItems,
  }) async {
    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 500));
      return;
    }

    await _fs.addDocument(_fs.remarks, {
      'studentId': studentId,
      'counselorId': counselorId,
      'counselorName': counselorName,
      'message': message,
      'type': type.name,
      'actionItems': actionItems,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<List<CounselorRemark>> getStudentRemarks(String studentId) async {
    if (_useMock) return [];

    final docs = await _fs.getCollection(
      _fs.remarks,
      where: [WhereClause('studentId', isEqualTo: studentId)],
      orderBy: 'createdAt',
      descending: true,
    );
    return docs.map((d) => CounselorRemark.fromJson(d)).toList();
  }

  // ── Mock data (preserved) ───────────────────────────────────

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
          educationPath: 'B.Tech/B.E. in Computer Science \u2192 M.Tech or MBA in Tech Management',
        ),
        CareerRecommendation(
          careerName: 'Data Science',
          matchPercentage: 87,
          description: 'Analyze complex data sets to help organizations make better decisions. Your aptitude for mathematics is a strong foundation.',
          skillsRequired: ['Statistics', 'Programming', 'Data Analysis', 'Communication'],
          skillsToDevelop: ['Machine Learning', 'Python', 'SQL', 'Visualization Tools'],
          educationPath: 'B.Tech in CS/Stats \u2192 M.Sc in Data Science or PG Diploma',
        ),
        CareerRecommendation(
          careerName: 'Product Management',
          matchPercentage: 81,
          description: 'Bridge the gap between technology, business, and user experience. Your leadership traits and analytical skills are a great match.',
          skillsRequired: ['Leadership', 'Communication', 'Analytical Thinking', 'User Empathy'],
          skillsToDevelop: ['UX Design Basics', 'Agile Methodology', 'Market Research'],
          educationPath: 'Any B.Tech/BBA \u2192 MBA or Product Management Certification',
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
      aiSummary:
          'Arjun demonstrates strong analytical and logical reasoning abilities, '
          'scoring particularly well in aptitude-based assessments. His interest profile '
          'leans towards technology and innovation, making him a strong candidate for '
          'STEM-oriented career paths. With focused skill development in programming '
          'and data analysis, he has excellent potential for careers in software engineering '
          'or data science.',
      strengths: [
        'Strong logical and analytical reasoning',
        'High aptitude for mathematics and problem-solving',
        'Good communication and teamwork skills',
        'Curious mindset with interest in technology',
      ],
      areasForImprovement: [
        'Needs more exposure to hands-on coding projects',
        'Could benefit from public speaking practice',
        'Time management during timed assessments',
        'Exploring creative problem-solving approaches',
      ],
    );
  }
}
