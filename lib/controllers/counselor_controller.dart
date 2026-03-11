import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/counselling_proposal_model.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../services/proposal_service.dart';
import '../services/firestore_service.dart';

enum CounselorLoadState { idle, loading, success, error }

class CounselorController extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  final ProposalService _proposalService = ProposalService();
  final FirestoreService _fs = FirestoreService();

  bool get _useMock => dotenv.get('USE_MOCK', fallback: 'false') == 'true';

  CounselorLoadState _state = CounselorLoadState.idle;
  List<Map<String, dynamic>> _students = [];
  List<Map<String, dynamic>> _filteredStudents = [];
  Map<String, dynamic>? _selectedStudent;
  ReportModel? _selectedStudentReport;
  List<CounselorRemark> _selectedStudentRemarks = [];
  String _filterStatus = 'All';
  String _searchQuery = '';
  String? _errorMessage;
  List<Map<String, dynamic>> _sessions = [];

  // Counselling proposals
  List<CounsellingProposal> _proposals = [];
  List<CounsellingProposal> get proposals => _proposals;

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
  List<Map<String, dynamic>> get sessions => _sessions;

  Future<void> loadDashboard({String? counselorId, bool isNewSignup = false}) async {
    _state = CounselorLoadState.loading;
    notifyListeners();

    try {
      if (isNewSignup) {
        _totalStudents = 0;
        _pendingReviews = 0;
        _completedReviews = 0;
        _state = CounselorLoadState.success;
        notifyListeners();
        return;
      }

      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        _totalStudents = 24;
        _pendingReviews = 8;
        _completedReviews = 16;
      } else {
        // Aggregate from Firestore
        final cid = counselorId ?? '';
        final studentDocs = await _fs.getCollection(
          _fs.users,
          where: [WhereClause('counselorId', isEqualTo: cid)],
        );
        _totalStudents = studentDocs.length;
        _pendingReviews = studentDocs.where((s) => s['reviewStatus'] == 'Pending' || s['reviewStatus'] == 'High Priority').length;
        _completedReviews = studentDocs.where((s) => s['reviewStatus'] == 'Reviewed' || s['reviewStatus'] == 'Counseled').length;
      }

      _state = CounselorLoadState.success;
    } catch (e) {
      _state = CounselorLoadState.error;
      _errorMessage = 'Failed to load dashboard';
    }
    notifyListeners();
  }

  Future<void> loadStudents({String? counselorId, bool isNewSignup = false}) async {
    _state = CounselorLoadState.loading;
    notifyListeners();

    try {
      if (isNewSignup) {
        _students = [];
        _filteredStudents = [];
        _state = CounselorLoadState.success;
        notifyListeners();
        return;
      }

      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        _students = _mockStudents;
      } else {
        final cid = counselorId ?? '';
        final docs = await _fs.getCollection(
          _fs.users,
          where: [WhereClause('counselorId', isEqualTo: cid)],
        );
        _students = docs.map((d) => {
          'id': d['id'],
          'name': d['name'] ?? '',
          'grade': d['grade'] ?? '',
          'lastTestDate': d['lastTestDate'] != null ? DateTime.parse(d['lastTestDate']) : null,
          'status': d['reviewStatus'] ?? 'Pending',
          'score': (d['latestScore'] as num?)?.toDouble() ?? 0.0,
          'testsTaken': d['testsTaken'] ?? 0,
          'phone': d['phone'] ?? '',
          'parentName': d['parentName'] ?? '',
          'parentPhone': d['parentPhone'] ?? '',
        }).toList();
      }

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
      _selectedStudent = _students.firstWhere((s) => s['id'] == studentId);

      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 300));
        _selectedStudentReport = ReportService.getMockReport();
        _selectedStudentRemarks = [];
      } else {
        // Get report + remarks from Firestore
        final reports = await _reportService.getStudentReports(studentId);
        _selectedStudentReport = reports.isNotEmpty ? reports.first : null;
        _selectedStudentRemarks = await _reportService.getStudentRemarks(studentId);
      }

      _state = CounselorLoadState.success;
    } catch (e) {
      _state = CounselorLoadState.error;
      _errorMessage = 'Failed to load student details';
    }
    notifyListeners();
  }

  Future<void> loadSessions({String? counselorId, bool isNewSignup = false}) async {
    if (isNewSignup) {
      _sessions = [];
      notifyListeners();
      return;
    }

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 300));
      _sessions = _mockSessions;
    } else {
      final cid = counselorId ?? '';
      final docs = await _fs.getCollection(
        _fs.sessions,
        where: [WhereClause('counselorId', isEqualTo: cid)],
        orderBy: 'dateTime',
        descending: true,
      );
      _sessions = docs.map((d) => {
        'id': d['id'],
        'studentName': d['studentName'] ?? '',
        'studentId': d['studentId'] ?? '',
        'topic': d['topic'] ?? '',
        'dateTime': d['dateTime'] != null ? DateTime.parse(d['dateTime']) : DateTime.now(),
        'status': d['status'] ?? 'upcoming',
        'duration': d['duration'] ?? 30,
      }).toList();
    }
    notifyListeners();
  }

  Future<void> scheduleSession({
    required String studentId,
    required String studentName,
    required String topic,
    required DateTime dateTime,
    String? counselorId,
    int duration = 30,
    String platform = 'Google Meet',
    bool notifyParent = false,
  }) async {
    final sessionData = {
      'id': 'ses_${_sessions.length + 1}',
      'studentName': studentName,
      'studentId': studentId,
      'topic': topic,
      'dateTime': dateTime,
      'status': 'upcoming',
      'duration': duration,
      'platform': platform,
      'notifyParent': notifyParent,
    };

    if (!_useMock && counselorId != null) {
      await _fs.addDocument(_fs.sessions, {
        ...sessionData,
        'counselorId': counselorId,
        'dateTime': dateTime.toIso8601String(),
      });
    }

    _sessions.insert(0, sessionData);
    notifyListeners();
  }

  Future<void> loadProposals({String? counselorId, bool isNewSignup = false}) async {
    if (isNewSignup) {
      _proposals = [];
      notifyListeners();
      return;
    }

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      _proposals = _mockProposals;
    } else {
      _proposals = await _proposalService.getProposalsForCounselor(counselorId ?? '');
    }
    notifyListeners();
  }

  Future<void> respondToProposal(String id, ProposalStatus status, {String? counselorId}) async {
    CounsellingProposal? matched;
    _proposals = _proposals.map((p) {
      if (p.id == id) {
        matched = p;
        return p.copyWith(status: status);
      }
      return p;
    }).toList();

    if (!_useMock) {
      await _proposalService.updateProposalStatus(id, status);
    }

    // When accepted, add the student to the counselor's student list
    if (status == ProposalStatus.accepted && matched != null) {
      final alreadyExists =
          _students.any((s) => s['id'] == matched!.studentId);
      if (!alreadyExists) {
        _students.add({
          'id': matched!.studentId,
          'name': matched!.studentName,
          'grade': 'New Student',
          'lastTestDate': null,
          'status': 'Pending',
          'score': 0.0,
          'testsTaken': 0,
          'phone': '',
          'parentName': matched!.parentName,
          'parentPhone': '',
        });
        _totalStudents++;
        _pendingReviews++;
        _applyFilters();
      }

      // Update Firestore: assign counselor to student
      if (!_useMock && counselorId != null) {
        await _fs.updateDocument(_fs.users, matched!.studentId, {
          'counselorId': counselorId,
        });
      }
    }

    notifyListeners();
  }

  void updateStudentStatus(String studentId, String status) {
    final index = _students.indexWhere((s) => s['id'] == studentId);
    if (index == -1) return;

    final oldStatus = _students[index]['status'] as String;
    _students[index] = Map.from(_students[index])..['status'] = status;

    // Update counters
    if (oldStatus == 'Pending' || oldStatus == 'High Priority') {
      _pendingReviews--;
    }
    if (status == 'Pending' || status == 'High Priority') {
      _pendingReviews++;
    }
    if (status == 'Reviewed' || status == 'Counseled') {
      if (oldStatus != 'Reviewed' && oldStatus != 'Counseled') {
        _completedReviews++;
      }
    } else if (oldStatus == 'Reviewed' || oldStatus == 'Counseled') {
      _completedReviews--;
    }

    _applyFilters();
    notifyListeners();
  }

  Future<bool> addRemark({
    required String studentId,
    required String message,
    required RemarkType type,
    required List<String> actionItems,
    String? counselorId,
    String? counselorName,
  }) async {
    _state = CounselorLoadState.loading;
    notifyListeners();

    try {
      if (!_useMock) {
        await _reportService.addRemark(
          studentId: studentId,
          counselorId: counselorId ?? 'counselor_1',
          counselorName: counselorName ?? 'Dr. Priya Sharma',
          message: message,
          type: type,
          actionItems: actionItems,
        );
      } else {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Append remark to the selected student's report locally
      if (_selectedStudentReport != null) {
        final newRemark = CounselorRemark(
          id: 'remark_${DateTime.now().millisecondsSinceEpoch}',
          counselorId: counselorId ?? 'counselor_1',
          counselorName: counselorName ?? 'Dr. Priya Sharma',
          studentId: studentId,
          message: message,
          type: type,
          actionItems: actionItems,
          createdAt: DateTime.now(),
        );
        _selectedStudentReport = ReportModel(
          id: _selectedStudentReport!.id,
          studentId: _selectedStudentReport!.studentId,
          testId: _selectedStudentReport!.testId,
          overallScore: _selectedStudentReport!.overallScore,
          performanceBand: _selectedStudentReport!.performanceBand,
          categoryScores: _selectedStudentReport!.categoryScores,
          recommendations: _selectedStudentReport!.recommendations,
          remarks: [..._selectedStudentReport!.remarks, newRemark],
          generatedAt: _selectedStudentReport!.generatedAt,
          aiSummary: _selectedStudentReport!.aiSummary,
          strengths: _selectedStudentReport!.strengths,
          areasForImprovement: _selectedStudentReport!.areasForImprovement,
        );
      }

      // Update student status
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

  // ── Mock data (preserved) ───────────────────────────────────

  static final List<Map<String, dynamic>> _mockStudents = [
    {
      'id': 'student_1',
      'name': 'Arjun Kumar',
      'grade': 'Class 12 - Science',
      'lastTestDate': DateTime.now().subtract(const Duration(days: 2)),
      'status': 'Pending',
      'score': 78.5,
      'testsTaken': 3,
      'phone': '+91 98765 43210',
      'parentName': 'Rajesh Kumar',
      'parentPhone': '+91 98765 00002',
    },
    {
      'id': 'student_2',
      'name': 'Sneha Patel',
      'grade': 'Class 12 - Commerce',
      'lastTestDate': DateTime.now().subtract(const Duration(days: 5)),
      'status': 'Reviewed',
      'score': 85.0,
      'testsTaken': 2,
      'phone': '+91 87654 32100',
      'parentName': 'Amit Patel',
      'parentPhone': '+91 87654 00001',
    },
    {
      'id': 'student_3',
      'name': 'Rahul Verma',
      'grade': 'Class 11 - Science',
      'lastTestDate': DateTime.now().subtract(const Duration(days: 1)),
      'status': 'Pending',
      'score': 62.0,
      'testsTaken': 1,
      'phone': '+91 76543 21000',
      'parentName': 'Sanjay Verma',
      'parentPhone': '+91 76543 00001',
    },
    {
      'id': 'student_4',
      'name': 'Priya Singh',
      'grade': 'Class 12 - Arts',
      'lastTestDate': DateTime.now().subtract(const Duration(days: 7)),
      'status': 'Reviewed',
      'score': 91.0,
      'testsTaken': 4,
      'phone': '+91 65432 10000',
      'parentName': 'Meena Singh',
      'parentPhone': '+91 65432 00001',
    },
    {
      'id': 'student_5',
      'name': 'Vikash Yadav',
      'grade': 'Class 10',
      'lastTestDate': DateTime.now().subtract(const Duration(hours: 5)),
      'status': 'High Priority',
      'score': 45.0,
      'testsTaken': 1,
      'phone': '+91 54321 00000',
      'parentName': 'Ramesh Yadav',
      'parentPhone': '+91 54321 00001',
    },
  ];

  static final List<Map<String, dynamic>> _mockSessions = [
    {
      'id': 'ses_1',
      'studentName': 'Arjun Kumar',
      'studentId': 'student_1',
      'topic': 'Career path discussion',
      'dateTime': DateTime.now().add(const Duration(days: 2, hours: 3)),
      'status': 'upcoming',
      'duration': 30,
    },
    {
      'id': 'ses_2',
      'studentName': 'Vikash Yadav',
      'studentId': 'student_5',
      'topic': 'Score improvement strategy',
      'dateTime': DateTime.now().add(const Duration(days: 4, hours: 1)),
      'status': 'upcoming',
      'duration': 45,
    },
    {
      'id': 'ses_3',
      'studentName': 'Sneha Patel',
      'studentId': 'student_2',
      'topic': 'Commerce career options review',
      'dateTime': DateTime.now().subtract(const Duration(days: 3)),
      'status': 'completed',
      'duration': 30,
    },
  ];

  static final List<CounsellingProposal> _mockProposals = [
    CounsellingProposal(
      id: 'prop_1',
      parentId: 'parent_1',
      parentName: 'Rajesh Kumar',
      counselorId: 'c1',
      counselorName: 'Dr. Priya Sharma',
      studentId: 'student_1',
      studentName: 'Arjun Kumar',
      reason:
          'My child is interested in engineering and needs guidance on choosing between computer science and mechanical engineering. He scored well in mathematics but needs clarity on career prospects.',
      numberOfSessions: 5,
      expectedOutcomes:
          'Clear understanding of career paths in engineering, a personalized study plan for entrance exams, and confidence in making the right choice.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    CounsellingProposal(
      id: 'prop_2',
      parentId: 'parent_2',
      parentName: 'Amit Patel',
      counselorId: 'c1',
      counselorName: 'Dr. Priya Sharma',
      studentId: 'student_2',
      studentName: 'Sneha Patel',
      reason:
          'Sneha is confused between pursuing pure sciences and applied sciences. She has a keen interest in research but is unsure about career stability.',
      numberOfSessions: 3,
      expectedOutcomes:
          'Awareness of research career options, understanding of funding and fellowship opportunities, and a roadmap for higher studies.',
      status: ProposalStatus.accepted,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];
}
