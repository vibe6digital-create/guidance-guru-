import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/counselling_proposal_model.dart';
import '../models/counselor_model.dart';
import '../models/report_model.dart';
import '../models/test_model.dart';
import '../services/report_service.dart';
import '../services/proposal_service.dart';
import '../services/firestore_service.dart';

enum ParentLoadState { idle, loading, success, error }

class ParentController extends ChangeNotifier {
  final ReportService _reportService = ReportService();
  final ProposalService _proposalService = ProposalService();
  final FirestoreService _fs = FirestoreService();

  bool get _useMock => dotenv.get('USE_MOCK', fallback: 'false') == 'true';

  ParentLoadState _state = ParentLoadState.idle;
  List<Map<String, dynamic>> _linkedStudents = [];
  ReportModel? _selectedStudentReport;
  String? _errorMessage;
  List<CounselorRemark> _studentRemarks = [];
  List<TestModel> _studentTestHistory = [];

  List<CounselorModel> _availableCounselors = [];
  List<CounselorModel> _filteredCounselors = [];
  String _counselorSearchQuery = '';
  String? _counselorSpecFilter;
  CounselorModel? _selectedCounselor;

  // Counselling proposals
  List<CounsellingProposal> _proposals = [];
  List<CounsellingProposal> get proposals => _proposals;

  // Session invites
  List<Map<String, dynamic>> _sessionInvites = [];
  List<Map<String, dynamic>> get sessionInvites => _sessionInvites;

  ParentLoadState get state => _state;
  List<Map<String, dynamic>> get linkedStudents => _linkedStudents;
  ReportModel? get selectedStudentReport => _selectedStudentReport;
  String? get errorMessage => _errorMessage;
  List<CounselorRemark> get studentRemarks => _studentRemarks;
  List<TestModel> get studentTestHistory => _studentTestHistory;

  List<CounselorModel> get availableCounselors => _availableCounselors;
  List<CounselorModel> get filteredCounselors => _filteredCounselors;
  String get counselorSearchQuery => _counselorSearchQuery;
  String? get counselorSpecFilter => _counselorSpecFilter;
  CounselorModel? get selectedCounselor => _selectedCounselor;

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

  Future<void> loadDashboard({String? parentId, bool isNewSignup = false}) async {
    _state = ParentLoadState.loading;
    notifyListeners();

    try {
      if (isNewSignup) {
        _linkedStudents = [];
        _studentRemarks = [];
        _studentTestHistory = [];
        _state = ParentLoadState.success;
        notifyListeners();
        return;
      }

      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        _linkedStudents = [
          {
            'id': 'student_1',
            'name': 'Arjun Kumar',
            'grade': 'Class 12 - Science',
            'lastTestDate': DateTime.now().subtract(const Duration(days: 2)),
            'performanceBand': 'Good',
            'counselorName': 'Dr. Priya Sharma',
            'counselorPhone': '+91 98765 00001',
            'testsTaken': 3,
          },
        ];
        await _loadStudentDetailsMock();
      } else {
        // Query Firestore for linked students
        final pid = parentId ?? '';
        final userDoc = await _fs.getDocument(_fs.users, pid);
        final linkedIds = userDoc?['linkedStudents'] as List<dynamic>? ?? [];

        _linkedStudents = [];
        for (final sid in linkedIds) {
          final studentDoc = await _fs.getDocument(_fs.users, sid as String);
          if (studentDoc != null) {
            _linkedStudents.add({
              'id': studentDoc['id'],
              'name': studentDoc['name'],
              'grade': studentDoc['grade'] ?? '',
              'lastTestDate': null,
              'performanceBand': 'N/A',
              'counselorName': studentDoc['counselorName'] ?? 'Not assigned',
              'counselorPhone': studentDoc['counselorPhone'],
              'testsTaken': 0,
            });
          }
        }

        // Load remarks for first linked student
        if (_linkedStudents.isNotEmpty) {
          final sid = _linkedStudents[0]['id'] as String;
          _studentRemarks = await _reportService.getStudentRemarks(sid);
        }
      }

      _state = ParentLoadState.success;
    } catch (e) {
      _state = ParentLoadState.error;
      _errorMessage = 'Failed to load dashboard';
    }
    notifyListeners();
  }

  Future<void> _loadStudentDetailsMock() async {
    _studentRemarks = [
      CounselorRemark(
        id: 'rmk_p1',
        counselorId: 'c1',
        counselorName: 'Dr. Priya Sharma',
        studentId: 'student_1',
        message: 'Arjun shows strong analytical skills. He should focus on logical reasoning and practice more aptitude tests to improve further.',
        type: RemarkType.academic,
        actionItems: ['Practice aptitude tests daily', 'Review logical reasoning basics'],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
      ),
      CounselorRemark(
        id: 'rmk_p2',
        counselorId: 'c1',
        counselorName: 'Dr. Priya Sharma',
        studentId: 'student_1',
        message: 'Based on the career aptitude results, Engineering and Data Science are strong matches. Recommend exploring internship opportunities.',
        type: RemarkType.career,
        actionItems: ['Research internship programs', 'Attend career workshops'],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
      ),
      CounselorRemark(
        id: 'rmk_p3',
        counselorId: 'c1',
        counselorName: 'Dr. Priya Sharma',
        studentId: 'student_1',
        message: 'Great improvement in verbal ability scores since last test. Keep up the reading habit.',
        type: RemarkType.general,
        createdAt: DateTime.now().subtract(const Duration(days: 14)),
      ),
    ];
    _studentTestHistory = [
      TestModel(
        id: 'test_p1',
        title: 'Career Aptitude Test',
        description: 'Comprehensive career aptitude assessment',
        questions: [],
        durationMinutes: 45,
        status: TestStatus.completed,
        completedAt: DateTime.now().subtract(const Duration(days: 2)),
        score: 78,
      ),
      TestModel(
        id: 'test_p2',
        title: 'Personality Assessment',
        description: 'Personality type and work style evaluation',
        questions: [],
        durationMinutes: 30,
        status: TestStatus.completed,
        completedAt: DateTime.now().subtract(const Duration(days: 8)),
        score: 82,
      ),
      TestModel(
        id: 'test_p3',
        title: 'Interest Inventory',
        description: 'Holland code interest profiler',
        questions: [],
        durationMinutes: 25,
        status: TestStatus.completed,
        completedAt: DateTime.now().subtract(const Duration(days: 15)),
        score: 62,
      ),
    ];
  }

  Future<bool> linkStudent(String studentCode, {String? parentId}) async {
    _state = ParentLoadState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_useMock) {
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
      } else {
        // Find student by code in Firestore
        final results = await _fs.getCollection(
          _fs.users,
          where: [WhereClause('studentCode', isEqualTo: studentCode)],
          limit: 1,
        );
        if (results.isEmpty) {
          _state = ParentLoadState.error;
          _errorMessage = 'No student found with this code';
          notifyListeners();
          return false;
        }

        final student = results.first;
        final sid = student['id'] as String;

        // Update parent doc with linked student
        if (parentId != null) {
          final parentDoc = await _fs.getDocument(_fs.users, parentId);
          final existing = (parentDoc?['linkedStudents'] as List<dynamic>?) ?? [];
          if (!existing.contains(sid)) {
            await _fs.updateDocument(_fs.users, parentId, {
              'linkedStudents': [...existing, sid],
            });
          }
          // Update student doc with parent info
          await _fs.updateDocument(_fs.users, sid, {
            'parentId': parentId,
          });
        }

        _linkedStudents.add({
          'id': sid,
          'name': student['name'] ?? 'Student',
          'grade': student['grade'] ?? '',
          'lastTestDate': null,
          'performanceBand': 'N/A',
          'counselorName': student['counselorName'] ?? 'Not assigned',
          'testsTaken': 0,
        });
      }

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
      if (_useMock) {
        await Future.delayed(const Duration(milliseconds: 500));
        _selectedStudentReport = ReportService.getMockReport();
      } else {
        final reports = await _reportService.getStudentReports(studentId);
        _selectedStudentReport = reports.isNotEmpty ? reports.first : null;
      }
      _state = ParentLoadState.success;
    } catch (e) {
      _state = ParentLoadState.error;
      _errorMessage = 'Failed to load report';
    }
    notifyListeners();
  }

  // ── Counselor Selection ───────────────────────────────────────

  Future<void> loadAvailableCounselors() async {
    _state = ParentLoadState.loading;
    notifyListeners();

    if (_useMock) {
      await Future.delayed(const Duration(milliseconds: 400));
      _availableCounselors = _mockCounselors;
    } else {
      // Query Firestore for counselor users
      final docs = await _fs.getCollection(
        _fs.users,
        where: [WhereClause('role', isEqualTo: 'counselor')],
      );

      _availableCounselors = [];
      for (final doc in docs) {
        // Get counselor profile sub-collection
        final profileDocs = await _fs.getCollection(_fs.counselorProfile(doc['id']));
        final profile = profileDocs.isNotEmpty ? profileDocs.first : <String, dynamic>{};

        _availableCounselors.add(CounselorModel(
          id: doc['id'],
          name: doc['name'] ?? '',
          phone: doc['phone'] ?? '',
          email: doc['email'] ?? '',
          specialization: profile['specialization'] ?? '',
          experienceYears: profile['experienceYears'] ?? 0,
          rating: (profile['rating'] as num?)?.toDouble() ?? 0.0,
          studentsGuided: profile['studentsGuided'] ?? 0,
          pricePerSession: (profile['pricePerSession'] as num?)?.toDouble() ?? 0,
          bio: profile['bio'] ?? '',
          languages: (profile['languages'] as List<dynamic>?)?.cast<String>() ?? [],
          isAvailable: profile['isAvailable'] ?? true,
        ));
      }

      // Fallback to mock counselors if Firestore has none
      if (_availableCounselors.isEmpty) {
        _availableCounselors = _mockCounselors;
      }
    }

    _filteredCounselors = List.from(_availableCounselors);
    _state = ParentLoadState.success;
    notifyListeners();
  }

  void searchCounselors(String query) {
    _counselorSearchQuery = query;
    _applyCounselorFilters();
  }

  void setCounselorSpecFilter(String? spec) {
    _counselorSpecFilter = spec;
    _applyCounselorFilters();
  }

  void _applyCounselorFilters() {
    _filteredCounselors = _availableCounselors.where((c) {
      final matchesSearch = _counselorSearchQuery.isEmpty ||
          c.name.toLowerCase().contains(_counselorSearchQuery.toLowerCase()) ||
          c.specialization
              .toLowerCase()
              .contains(_counselorSearchQuery.toLowerCase());
      final matchesSpec =
          _counselorSpecFilter == null || c.specialization == _counselorSpecFilter;
      return matchesSearch && matchesSpec;
    }).toList();
    notifyListeners();
  }

  void selectCounselor(CounselorModel counselor) {
    _selectedCounselor = counselor;
    if (_linkedStudents.isEmpty) return;
    _linkedStudents[0]['counselorName'] = counselor.name;
    _linkedStudents[0]['counselorPhone'] = counselor.phone;
    notifyListeners();
  }

  Future<void> sendCounsellingProposal({
    required CounselorModel counselor,
    required String reason,
    required int numberOfSessions,
    required String expectedOutcomes,
    String? parentId,
    String? parentName,
  }) async {
    _state = ParentLoadState.loading;
    notifyListeners();

    final student = _linkedStudents.isNotEmpty
        ? _linkedStudents[0]
        : {'id': 'student_1', 'name': 'Arjun Kumar'};

    final proposal = CounsellingProposal(
      id: 'prop_${DateTime.now().millisecondsSinceEpoch}',
      parentId: parentId ?? 'parent_1',
      parentName: parentName ?? 'Rajesh Kumar',
      counselorId: counselor.id,
      counselorName: counselor.name,
      studentId: student['id'] as String,
      studentName: student['name'] as String,
      reason: reason,
      numberOfSessions: numberOfSessions,
      expectedOutcomes: expectedOutcomes,
    );

    if (!_useMock) {
      await _proposalService.createProposal(proposal);
    } else {
      await Future.delayed(const Duration(milliseconds: 600));
    }

    _proposals.insert(0, proposal);
    _state = ParentLoadState.success;
    notifyListeners();
  }

  void onProposalAccepted({
    required String counselorName,
    required String counselorPhone,
    required String studentId,
  }) {
    // Update the linked student's counselor info
    for (var i = 0; i < _linkedStudents.length; i++) {
      if (_linkedStudents[i]['id'] == studentId) {
        _linkedStudents[i]['counselorName'] = counselorName;
        _linkedStudents[i]['counselorPhone'] = counselorPhone;
        break;
      }
    }

    // Update proposal status in parent's list too
    _proposals = _proposals.map((p) {
      if (p.counselorName == counselorName && p.studentId == studentId && p.status == ProposalStatus.pending) {
        return p.copyWith(status: ProposalStatus.accepted);
      }
      return p;
    }).toList();

    notifyListeners();
  }

  // ── Mock counselors (preserved) ─────────────────────────────

  static final List<CounselorModel> _mockCounselors = [
    CounselorModel(
      id: 'c1',
      name: 'Dr. Priya Sharma',
      phone: '+91 98765 00001',
      email: 'priya.sharma@guidanceguru.com',
      specialization: 'STEM',
      experienceYears: 12,
      rating: 4.8,
      studentsGuided: 340,
      pricePerSession: 1500,
      bio: 'Specializes in engineering and technology career paths. Helped hundreds of students get into top IITs and NITs.',
      languages: ['English', 'Hindi'],
    ),
    CounselorModel(
      id: 'c2',
      name: 'Ms. Ananya Rao',
      phone: '+91 98765 00002',
      email: 'ananya.rao@guidanceguru.com',
      specialization: 'Arts',
      experienceYears: 8,
      rating: 4.6,
      studentsGuided: 210,
      pricePerSession: 1200,
      bio: 'Passionate about guiding students in fine arts, design, and liberal arts. Expert in portfolio building and creative career planning.',
      languages: ['English', 'Hindi', 'Kannada'],
    ),
    CounselorModel(
      id: 'c3',
      name: 'Mr. Rajesh Gupta',
      phone: '+91 98765 00003',
      email: 'rajesh.gupta@guidanceguru.com',
      specialization: 'Commerce',
      experienceYears: 15,
      rating: 4.9,
      studentsGuided: 520,
      pricePerSession: 1800,
      bio: 'Former CA and MBA mentor with deep expertise in commerce, finance, and business career tracks. Guides students for CA, CS, and MBA entrance.',
      languages: ['English', 'Hindi'],
    ),
    CounselorModel(
      id: 'c4',
      name: 'Dr. Meena Iyer',
      phone: '+91 98765 00004',
      email: 'meena.iyer@guidanceguru.com',
      specialization: 'Medical',
      experienceYears: 10,
      rating: 4.7,
      studentsGuided: 280,
      pricePerSession: 2000,
      bio: 'MBBS and MD mentor specializing in medical and healthcare career guidance. Extensive experience with NEET preparation strategy.',
      languages: ['English', 'Hindi', 'Tamil'],
      isAvailable: false,
    ),
    CounselorModel(
      id: 'c5',
      name: 'Prof. Sanjay Verma',
      phone: '+91 98765 00005',
      email: 'sanjay.verma@guidanceguru.com',
      specialization: 'Humanities',
      experienceYears: 20,
      rating: 4.5,
      studentsGuided: 450,
      pricePerSession: 1000,
      bio: 'Veteran educator in humanities covering law, psychology, sociology, and public policy. Guides students for CLAT, UPSC, and social science research.',
      languages: ['English', 'Hindi', 'Marathi'],
    ),
  ];
}
