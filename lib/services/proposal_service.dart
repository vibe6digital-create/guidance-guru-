import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/counselling_proposal_model.dart';
import 'firestore_service.dart';

class ProposalService {
  final FirestoreService _fs = FirestoreService();

  bool get _useMock => dotenv.get('USE_MOCK', fallback: 'false') == 'true';

  // ── Mock data ───────────────────────────────────────────────
  static final List<CounsellingProposal> _mockProposals = [
    CounsellingProposal(
      id: 'prop_1',
      parentId: 'parent_1',
      parentName: 'Rajesh Kumar',
      counselorId: 'c1',
      counselorName: 'Dr. Priya Sharma',
      studentId: 'student_1',
      studentName: 'Arjun Kumar',
      reason: 'My child is interested in engineering and needs guidance.',
      numberOfSessions: 5,
      expectedOutcomes: 'Clear understanding of career paths in engineering.',
      createdAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
  ];

  // ── Queries ─────────────────────────────────────────────────

  Future<List<CounsellingProposal>> getProposalsForCounselor(String counselorId) async {
    if (_useMock) {
      return _mockProposals.where((p) => p.counselorId == counselorId).toList();
    }
    final docs = await _fs.getCollection(
      _fs.proposals,
      where: [WhereClause('counselorId', isEqualTo: counselorId)],
      orderBy: 'createdAt',
      descending: true,
    );
    return docs.map((d) => CounsellingProposal.fromJson(d)).toList();
  }

  Future<List<CounsellingProposal>> getProposalsForParent(String parentId) async {
    if (_useMock) {
      return _mockProposals.where((p) => p.parentId == parentId).toList();
    }
    final docs = await _fs.getCollection(
      _fs.proposals,
      where: [WhereClause('parentId', isEqualTo: parentId)],
      orderBy: 'createdAt',
      descending: true,
    );
    return docs.map((d) => CounsellingProposal.fromJson(d)).toList();
  }

  // ── Mutations ───────────────────────────────────────────────

  Future<String> createProposal(CounsellingProposal proposal) async {
    if (_useMock) {
      _mockProposals.insert(0, proposal);
      return proposal.id;
    }
    final data = proposal.toJson()..remove('id');
    return _fs.addDocument(_fs.proposals, data);
  }

  Future<void> updateProposalStatus(String id, ProposalStatus status) async {
    if (_useMock) {
      final idx = _mockProposals.indexWhere((p) => p.id == id);
      if (idx != -1) {
        _mockProposals[idx] = _mockProposals[idx].copyWith(status: status);
      }
      return;
    }
    await _fs.updateDocument(_fs.proposals, id, {'status': status.name});
  }
}
