import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

enum CounselorLoadState { idle, loading, success, error }

class CounselorController extends ChangeNotifier {

  CounselorLoadState _state = CounselorLoadState.idle;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  Map<String, dynamic>? _selectedStudent;
  ReportModel? _selectedStudentReport;
  String _filterStatus = 'All';
  String _searchQuery = '';
  String? _errorMessage;

  // Dashboard stats
  int _totalStudents = 0;
  int _pendingReviews = 0;
  int _completedReviews = 0;

  CounselorLoadState get state => _state;
  List<Map<String, dynamic>> get students => _filteredStudents;
  Map<String, dynamic>? get selectedStudent => _selectedStudent;
  ReportModel? get selectedStudentReport => _selectedStudentReport;
  String get filterStatus => _filterStatus;
  String? get errorMessage => _errorMessage;
  int get totalStudents => _totalStudents;
  int get pendingReviews => _pendingReviews;
  int get completedReviews => _completedReviews;

  Future<void> loadDashboard() async {
    _state = CounselorLoadState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _totalStudents = 24;
      _pendingReviews = 8;
      _completedReviews = 16;
      _state = CounselorLoadState.success;
    } catch (e) {
      _state = CounselorLoadState.error;
      _errorMessage = 'Failed to load dashboard';
    }
    notifyListeners();
  }

  Future<void> loadStudents() async {
    _state = CounselorLoadState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _students = [
        {
          'id': 'student_1',
          'name': 'Arjun Kumar',
          'grade': 'Class 12 - Science',
          'lastTestDate': DateTime.now().subtract(const Duration(days: 2)),
          'status': 'Pending',
          'score': 78.5,
          'testsTaken': 3,
        },
        {
          'id': 'student_2',
          'name': 'Sneha Patel',
          'grade': 'Class 12 - Commerce',
          'lastTestDate': DateTime.now().subtract(const Duration(days: 5)),
          'status': 'Reviewed',
          'score': 85.0,
          'testsTaken': 2,
        },
        {
          'id': 'student_3',
          'name': 'Rahul Verma',
          'grade': 'Class 11 - Science',
          'lastTestDate': DateTime.now().subtract(const Duration(days: 1)),
          'status': 'Pending',
          'score': 62.0,
          'testsTaken': 1,
        },
        {
          'id': 'student_4',
          'name': 'Priya Singh',
          'grade': 'Class 12 - Arts',
          'lastTestDate': DateTime.now().subtract(const Duration(days: 7)),
          'status': 'Reviewed',
          'score': 91.0,
          'testsTaken': 4,
        },
        {
          'id': 'student_5',
          'name': 'Vikash Yadav',
          'grade': 'Class 10',
          'lastTestDate': DateTime.now().subtract(const Duration(hours: 5)),
          'status': 'High Priority',
          'score': 45.0,
          'testsTaken': 1,
        },
      ];
      _applyFilters();
      _state = CounselorLoadState.success;
    } catch (e) {
      _state = CounselorLoadState.error;
      _errorMessage = 'Failed to load students';
    }
    notifyListeners();
  }

  void setFilter(String status) {
    _filterStatus = status;
    _applyFilters();
    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredStudents = _students.where((s) {
      final matchesFilter =
          _filterStatus == 'All' || s['status'] == _filterStatus;
      final matchesSearch = _searchQuery.isEmpty ||
          (s['name'] as String)
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  Future<void> selectStudent(String studentId) async {
    _state = CounselorLoadState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 300));
      _selectedStudent = _students.firstWhere((s) => s['id'] == studentId);
      _selectedStudentReport = ReportService.getMockReport();
      _state = CounselorLoadState.success;
    } catch (e) {
      _state = CounselorLoadState.error;
      _errorMessage = 'Failed to load student details';
    }
    notifyListeners();
  }

  Future<bool> addRemark({
    required String studentId,
    required String message,
    required RemarkType type,
    required List<String> actionItems,
  }) async {
    _state = CounselorLoadState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      // Update local state
      final index = _students.indexWhere((s) => s['id'] == studentId);
      if (index != -1) {
        _students[index] = Map.from(_students[index])..['status'] = 'Reviewed';
        _pendingReviews--;
        _completedReviews++;
        _applyFilters();
      }
      _state = CounselorLoadState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = CounselorLoadState.error;
      _errorMessage = 'Failed to add remark';
      notifyListeners();
      return false;
    }
  }
}
