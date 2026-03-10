import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/test_model.dart';
import '../models/question_model.dart';
import '../models/report_model.dart';
import '../models/student_academic_model.dart';
import '../services/test_service.dart';
import '../services/report_service.dart';
import '../services/gemini_service.dart';

enum LoadState { idle, loading, success, error }

class StudentController extends ChangeNotifier {
  final TestService _testService = TestService();

  // Dashboard state
  LoadState _dashboardState = LoadState.idle;
  int _testsTaken = 0;
  int _reportsGenerated = 0;
  int _streak = 0;
  double _completionPercentage = 0;
  List<Map<String, dynamic>> _recentActivity = [];

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

  // Getters - Dashboard
  LoadState get dashboardState => _dashboardState;
  int get testsTaken => _testsTaken;
  int get reportsGenerated => _reportsGenerated;
  int get streak => _streak;
  double get completionPercentage => _completionPercentage;
  List<Map<String, dynamic>> get recentActivity => _recentActivity;

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

  // Getters - Academic
  StudentAcademicModel? get academicData => _academicData;
  int get academicFormStep => _academicFormStep;
  LoadState get academicState => _academicState;

  // Dashboard methods
  Future<void> loadDashboard() async {
    _dashboardState = LoadState.loading;
    notifyListeners();

    try {
      // Mock data for demo
      await Future.delayed(const Duration(milliseconds: 500));
      _testsTaken = 3;
      _reportsGenerated = 2;
      _streak = 5;
      _completionPercentage = 65;
      _recentActivity = [
        {'title': 'Career Test Completed', 'time': '2 hours ago', 'icon': 'test'},
        {'title': 'AI Report Generated', 'time': '1 day ago', 'icon': 'report'},
        {'title': 'Academic Details Updated', 'time': '3 days ago', 'icon': 'academic'},
        {'title': 'New Counselor Remark', 'time': '5 days ago', 'icon': 'remark'},
      ];
      _dashboardState = LoadState.success;
    } catch (_) {
      _dashboardState = LoadState.error;
    }
    notifyListeners();
  }

  // Test methods
  Future<void> startTest() async {
    _testState = LoadState.loading;
    notifyListeners();

    try {
      // Use mock test for demo
      _currentTest = TestService.getMockTest();
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

  Future<void> submitTest() async {
    _timer?.cancel();
    _isTestSubmitted = true;
    _testState = LoadState.loading;
    notifyListeners();

    try {
      // Calculate score locally for demo
      _currentTest = _currentTest!.copyWith(
        status: TestStatus.completed,
        answers: _answers,
        completedAt: DateTime.now(),
      );
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
  Future<void> loadReport() async {
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
        studentId: _currentTest?.id ?? 'student_1',
        testId: _currentTest?.id ?? 'test_1',
        overallScore: score,
        performanceBand: band,
        categoryScores: scores,
        answers: _answers,
        academicData: _academicData,
      );
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

  Future<void> submitAcademicData() async {
    _academicState = LoadState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 800));
      _academicState = LoadState.success;
    } catch (_) {
      _academicState = LoadState.error;
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
