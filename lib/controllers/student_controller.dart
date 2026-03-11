import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_model.dart';
import '../models/question_model.dart';
import '../models/report_model.dart';
import '../models/student_academic_model.dart';
import '../services/test_service.dart';
import '../services/report_service.dart';
import '../services/gemini_service.dart';
import '../services/firestore_service.dart';

enum LoadState { idle, loading, success, error }

class StudentController extends ChangeNotifier {
  final TestService _testService = TestService();
  final ReportService _reportService = ReportService();
  final FirestoreService _fs = FirestoreService();

  bool get _useMock => dotenv.get('USE_MOCK', fallback: 'false') == 'true';

  // Dashboard state
  LoadState _dashboardState = LoadState.idle;
  int _testsTaken = 0;
  int _reportsGenerated = 0;
  int _streak = 0;
  double _completionPercentage = 0;
  List<Map<String, dynamic>> _recentActivity = [];

  // Test history & reports list
  List<TestModel> _testHistory = [];
  List<ReportModel> _reportsList = [];
  double _averageScore = 0;
  String _averageScoreBand = 'N/A';
  List<Map<String, dynamic>> _recommendedTests = [];

  // Test state
  TestModel? _currentTest;
  int _currentQuestionIndex = 0;
  Map<String, String> _answers = {};
  int _remainingSeconds = 0;
  Timer? _timer;
  bool _isTestSubmitted = false;
  LoadState _testState = LoadState.idle;

  // Report state
  ReportModel? _currentReport;
  List<ReportModel> _reports = [];
  LoadState _reportState = LoadState.idle;

  // Academic state
  StudentAcademicModel? _academicData;
  int _academicFormStep = 0;
  LoadState _academicState = LoadState.idle;

  // Session invites
  List<Map<String, dynamic>> _sessionInvites = [];
  List<Map<String, dynamic>> get sessionInvites => _sessionInvites;

  // Getters - Dashboard
  LoadState get dashboardState => _dashboardState;
  int get testsTaken => _testsTaken;
  int get reportsGenerated => _reportsGenerated;
  int get streak => _streak;
  double get completionPercentage => _completionPercentage;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;

  // Getters - Test history & reports list
  List<TestModel> get testHistory => _testHistory;
  List<ReportModel> get reportsList => _reportsList;
  double get averageScore => _averageScore;
  String get averageScoreBand => _averageScoreBand;
  List<Map<String, dynamic>> get recommendedTests => _recommendedTests;

  // Getters - Test
  TestModel? get currentTest => _currentTest;
  int get currentQuestionIndex => _currentQuestionIndex;
  Map<String, String> get answers => _answers;
  int get remainingSeconds => _remainingSeconds;
  bool get isTestSubmitted => _isTestSubmitted;
  LoadState get testState => _testState;
  Question? get currentQuestion =>
      _currentTest != null && _currentQuestionIndex < _currentTest!.questions.length
          ? _currentTest!.questions[_currentQuestionIndex]
          : null;
  int get totalQuestions => _currentTest?.totalQuestions ?? 0;
  bool get isLastQuestion => _currentQuestionIndex == totalQuestions - 1;
  bool get isFirstQuestion => _currentQuestionIndex == 0;

  // Getters - Report
  ReportModel? get currentReport => _currentReport;
  List<ReportModel> get reports => _reports;
  LoadState get reportState => _reportState;

  void setCurrentReport(ReportModel report) {
    _currentReport = report;
    _reportState = LoadState.success;
    notifyListeners();
  }

  // Getters - Academic
  StudentAcademicModel? get academicData => _academicData;
  int get academicFormStep => _academicFormStep;
  LoadState get academicState => _academicState;

  // Session invite methods
  void addSessionInvite(Map<String, dynamic> invite) {
    _sessionInvites.insert(0, invite);
    notifyListeners();
  }

  void respondToSessionInvite(String id, bool accept) {
    _sessionInvites = _sessionInvites.map((inv) {
      if (inv['id'] == id) {
        return {...inv, 'status': accept ? 'accepted' : 'declined'};
      }
      return inv;
    }).toList();
    notifyListeners();
  }

  // Dashboard methods
  Future<void> loadDashboard({String? studentId, bool isNewSignup = false}) async {
    _dashboardState = LoadState.loading;
    notifyListeners();

    try {
      if (isNewSignup || _useMock && isNewSignup) {
        _testsTaken = 0;
        _reportsGenerated = 0;
        _streak = 0;
        _completionPercentage = 0;
        _recentActivity = [];
        _averageScore = 0;
        _averageScoreBand = 'N/A';
        _dashboardState = LoadState.success;
        notifyListeners();
        return;
      }

      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        _testsTaken = 3;
        _reportsGenerated = 2;
        _streak = 5;
        _completionPercentage = 65;
        _recentActivity = [
          {
            'title': 'Career Test Completed',
            'subtitle': 'Score: 78% - Good',
            'time': '2 hours ago',
            'icon': 'test',
          },
          {
            'title': 'AI Report Generated',
            'time': '1 day ago',
            'icon': 'report',
          },
          {
            'title': 'Academic Details Updated',
            'subtitle': 'Class 10: 85% | Class 12: 78%',
            'time': '3 days ago',
            'icon': 'academic',
          },
          {
            'title': 'Counsellor Remark',
            'subtitle': 'Focus on logical reasoning and practice more aptitude tests.',
            'counselorName': 'Dr. Priya Sharma',
            'remarkType': 'academic',
            'actionItems': ['Practice aptitude tests daily', 'Review logical reasoning basics'],
            'time': '5 days ago',
            'icon': 'remark',
          },
        ];
        _averageScore = 74.0;
        _averageScoreBand = 'Good';
      } else {
        // Live: aggregate from Firestore
        final sid = studentId ?? '';
        final history = await _testService.getTestHistory(sid);
        final reports = await _reportService.getStudentReports(sid);

        _testsTaken = history.length;
        _reportsGenerated = reports.length;
        _streak = _testsTaken > 0 ? _testsTaken : 0;
        _completionPercentage = _testsTaken > 0 ? (_reportsGenerated / _testsTaken * 100).clamp(0, 100) : 0;

        if (history.isNotEmpty) {
          _averageScore = history
              .where((t) => t.score != null)
              .fold<double>(0, (sum, t) => sum + t.score!) /
              history.where((t) => t.score != null).length.clamp(1, 999);
        } else {
          _averageScore = 0;
        }
        _averageScoreBand = _averageScore >= 85
            ? 'Excellent'
            : _averageScore >= 70
                ? 'Good'
                : _averageScore >= 50
                    ? 'Average'
                    : _averageScore > 0
                        ? 'Below Average'
                        : 'N/A';
        _recentActivity = [];
      }

      _dashboardState = LoadState.success;
    } catch (_) {
      _dashboardState = LoadState.error;
    }
    notifyListeners();
  }

  // Test history
  Future<void> loadTestHistory({String? studentId, bool isNewSignup = false}) async {
    if (isNewSignup) {
      _testHistory = [];
      _recommendedTests = _defaultRecommendedTests;
      notifyListeners();
      return;
    }

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _testHistory = [
        TestModel(
          id: 'test_h1',
          title: 'Career Aptitude Test',
          description: 'Comprehensive career aptitude assessment',
          questions: [],
          durationMinutes: 45,
          status: TestStatus.completed,
          completedAt: DateTime.now().subtract(const Duration(hours: 2)),
          score: 78,
        ),
        TestModel(
          id: 'test_h2',
          title: 'Personality Assessment',
          description: 'Personality type and work style evaluation',
          questions: [],
          durationMinutes: 30,
          status: TestStatus.completed,
          completedAt: DateTime.now().subtract(const Duration(days: 5)),
          score: 82,
        ),
        TestModel(
          id: 'test_h3',
          title: 'Interest Inventory',
          description: 'Holland code interest profiler',
          questions: [],
          durationMinutes: 25,
          status: TestStatus.completed,
          completedAt: DateTime.now().subtract(const Duration(days: 12)),
          score: 62,
        ),
      ];
    } else {
      _testHistory = await _testService.getTestHistory(studentId ?? '');
    }

    _recommendedTests = _defaultRecommendedTests;
    notifyListeners();
  }

  // Reports list
  Future<void> loadReportsList({String? studentId, bool isNewSignup = false}) async {
    if (isNewSignup) {
      _reportsList = [];
      notifyListeners();
      return;
    }

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _reportsList = [
        ReportModel(
          id: 'rpt_1',
          studentId: 'mock_student_1',
          testId: 'test_h1',
          overallScore: 78,
          performanceBand: 'Good',
          categoryScores: [
            CategoryScore(category: 'Logical', score: 85, totalQuestions: 10, correctAnswers: 8),
            CategoryScore(category: 'Verbal', score: 70, totalQuestions: 10, correctAnswers: 7),
            CategoryScore(category: 'Spatial', score: 80, totalQuestions: 10, correctAnswers: 8),
          ],
          recommendations: [],
          remarks: [
            CounselorRemark(
              id: 'rmk_1',
              counselorId: 'c1',
              counselorName: 'Dr. Priya Sharma',
              studentId: 'mock_student_1',
              message: 'Strong analytical skills. Focus on verbal reasoning for improvement.',
              type: RemarkType.academic,
              createdAt: DateTime.now().subtract(const Duration(days: 1)),
            ),
          ],
          generatedAt: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ReportModel(
          id: 'rpt_2',
          studentId: 'mock_student_1',
          testId: 'test_h2',
          overallScore: 82,
          performanceBand: 'Good',
          categoryScores: [
            CategoryScore(category: 'Openness', score: 90, totalQuestions: 8, correctAnswers: 7),
            CategoryScore(category: 'Conscientiousness', score: 75, totalQuestions: 8, correctAnswers: 6),
          ],
          recommendations: [],
          remarks: [],
          generatedAt: DateTime.now().subtract(const Duration(days: 5)),
        ),
      ];
    } else {
      _reportsList = await _reportService.getStudentReports(studentId ?? '');
    }
    notifyListeners();
  }

  // Test methods
  Future<void> startTest() async {
    _testState = LoadState.loading;
    notifyListeners();

    try {
      _currentTest = _useMock
          ? TestService.getMockTest()
          : await _testService.generateTest();
      _currentQuestionIndex = 0;
      _answers = {};
      _isTestSubmitted = false;
      _remainingSeconds = _currentTest!.durationMinutes * 60;
      _testState = LoadState.success;
      _startTimer();
    } catch (_) {
      _testState = LoadState.error;
    }
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        submitTest();
      }
    });
  }

  Future<void> saveTimerState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('test_remaining_seconds', _remainingSeconds);
    await prefs.setString('test_id', _currentTest?.id ?? '');
  }

  Future<void> resumeTimer() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt('test_remaining_seconds');
    if (saved != null && saved > 0) {
      _remainingSeconds = saved;
      _startTimer();
    }
  }

  void pauseTimer() {
    _timer?.cancel();
    saveTimerState();
  }

  void selectAnswer(String questionId, String answer) {
    _answers = Map.from(_answers)..[questionId] = answer;
    notifyListeners();
  }

  void nextQuestion() {
    if (_currentQuestionIndex < totalQuestions - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void goToQuestion(int index) {
    if (index >= 0 && index < totalQuestions) {
      _currentQuestionIndex = index;
      notifyListeners();
    }
  }

  Future<void> submitTest({String? studentId}) async {
    _timer?.cancel();
    _isTestSubmitted = true;
    _testState = LoadState.loading;
    notifyListeners();

    try {
      // Calculate score locally
      _currentTest = _currentTest!.copyWith(
        status: TestStatus.completed,
        answers: _answers,
        completedAt: DateTime.now(),
      );

      // Persist to Firestore when live
      if (!_useMock && studentId != null) {
        await _testService.submitTest(
          testId: _currentTest!.id,
          studentId: studentId,
          answers: _answers,
          score: testScore,
          categoryScores: categoryScores.map((cs) => {
            'category': cs.category,
            'score': cs.score,
            'totalQuestions': cs.totalQuestions,
            'correctAnswers': cs.correctAnswers,
          }).toList(),
        );
      }

      _testsTaken++;
      _testState = LoadState.success;
    } catch (_) {
      _testState = LoadState.error;
    }
    notifyListeners();
  }

  double get testScore => _currentTest?.scorePercentage ?? 0;

  List<CategoryScore> get categoryScores {
    if (_currentTest == null) return [];
    final Map<String, List<Question>> grouped = {};
    for (final q in _currentTest!.questions) {
      grouped.putIfAbsent(q.category, () => []).add(q);
    }
    return grouped.entries.map((e) {
      int correct = 0;
      for (final q in e.value) {
        if (_answers[q.id] == q.correctAnswer) correct++;
      }
      return CategoryScore(
        category: e.key.substring(0, 1).toUpperCase() + e.key.substring(1),
        score: e.value.isEmpty ? 0 : (correct / e.value.length) * 100,
        totalQuestions: e.value.length,
        correctAnswers: correct,
      );
    }).toList();
  }

  // Report methods
  Future<void> loadReport({String? studentId}) async {
    _reportState = LoadState.loading;
    notifyListeners();

    try {
      final gemini = GeminiService();
      final scores = categoryScores;
      final score = testScore;
      final band = score >= 85
          ? 'Excellent'
          : score >= 70
              ? 'Good'
              : score >= 50
                  ? 'Average'
                  : 'Below Average';

      _currentReport = await gemini.generateFullReport(
        studentId: studentId ?? _currentTest?.id ?? 'student_1',
        testId: _currentTest?.id ?? 'test_1',
        overallScore: score,
        performanceBand: band,
        categoryScores: scores,
        answers: _answers,
        academicData: _academicData,
      );

      // Save report to Firestore when live
      if (!_useMock && _currentReport != null) {
        await _reportService.saveReport(_currentReport!);
      }

      _reportState = LoadState.success;
    } catch (_) {
      _currentReport = ReportService.getMockReport();
      _reportState = LoadState.success;
    }
    notifyListeners();
  }

  // Academic methods
  void setAcademicFormStep(int step) {
    _academicFormStep = step;
    notifyListeners();
  }

  void updateAcademicData(StudentAcademicModel data) {
    _academicData = data;
    notifyListeners();
  }

  Future<void> submitAcademicData({String? studentId}) async {
    _academicState = LoadState.loading;
    notifyListeners();

    try {
      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 800));
      } else if (studentId != null && _academicData != null) {
        await _fs.setDocument(
          _fs.academics(studentId),
          'data',
          _academicData!.toJson(),
        );
      }
      _academicState = LoadState.success;
    } catch (_) {
      _academicState = LoadState.error;
    }
    notifyListeners();
  }

  static final List<Map<String, dynamic>> _defaultRecommendedTests = [
    {
      'title': 'Logical Reasoning Test',
      'description': 'Assess your analytical and logical thinking abilities',
      'duration': 30,
      'questions': 25,
      'difficulty': 'Medium',
    },
    {
      'title': 'Verbal Ability Test',
      'description': 'Evaluate your language comprehension and communication skills',
      'duration': 20,
      'questions': 20,
      'difficulty': 'Easy',
    },
    {
      'title': 'STEM Aptitude Test',
      'description': 'Discover your potential in Science, Technology, Engineering & Math',
      'duration': 40,
      'questions': 30,
      'difficulty': 'Hard',
    },
  ];

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
