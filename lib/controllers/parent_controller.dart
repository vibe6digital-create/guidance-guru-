import 'package:flutter/material.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

enum ParentLoadState { idle, loading, success, error }

class ParentController extends ChangeNotifier {

  ParentLoadState _state = ParentLoadState.idle;
  List<Map<String, dynamic>> _linkedStudents = [];
  ReportModel? _selectedStudentReport;
  String? _errorMessage;

  ParentLoadState get state => _state;
  List<Map<String, dynamic>> get linkedStudents => _linkedStudents;
  ReportModel? get selectedStudentReport => _selectedStudentReport;
  String? get errorMessage => _errorMessage;

  Future<void> loadDashboard() async {
    _state = ParentLoadState.loading;
    notifyListeners();

    try {
      // Mock data for demo
      await Future.delayed(const Duration(milliseconds: 500));
      _linkedStudents = [
        {
          'id': 'student_1',
          'name': 'Arjun Kumar',
          'grade': 'Class 12 - Science',
          'lastTestDate': DateTime.now().subtract(const Duration(days: 2)),
          'performanceBand': 'Good',
          'counselorName': 'Dr. Priya Sharma',
          'testsTaken': 3,
        },
      ];
      _state = ParentLoadState.success;
    } catch (e) {
      _state = ParentLoadState.error;
      _errorMessage = 'Failed to load dashboard';
    }
    notifyListeners();
  }

  Future<bool> linkStudent(String studentCode) async {
    _state = ParentLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      // Mock linking for demo
      await Future.delayed(const Duration(milliseconds: 800));
      _linkedStudents.add({
        'id': 'student_${_linkedStudents.length + 1}',
        'name': 'New Student',
        'grade': 'Class 10',
        'lastTestDate': null,
        'performanceBand': 'N/A',
        'counselorName': 'Not assigned',
        'testsTaken': 0,
      });
      _state = ParentLoadState.success;
      notifyListeners();
      return true;
    } catch (e) {
      _state = ParentLoadState.error;
      _errorMessage = 'Invalid student code';
      notifyListeners();
      return false;
    }
  }

  Future<void> loadStudentReport(String studentId) async {
    _state = ParentLoadState.loading;
    notifyListeners();

    try {
      await Future.delayed(const Duration(milliseconds: 500));
      _selectedStudentReport = ReportService.getMockReport();
      _state = ParentLoadState.success;
    } catch (e) {
      _state = ParentLoadState.error;
      _errorMessage = 'Failed to load report';
    }
    notifyListeners();
  }
}
