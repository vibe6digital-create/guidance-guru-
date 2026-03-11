enum ProposalStatus { pending, accepted, declined, discussion }

class CounsellingProposal {
  final String id;
  final String parentId;
  final String parentName;
  final String counselorId;
  final String counselorName;
  final String studentId;
  final String studentName;
  final String reason;
  final int numberOfSessions;
  final String expectedOutcomes;
  final ProposalStatus status;
  final DateTime createdAt;

  CounsellingProposal({
    required this.id,
    required this.parentId,
    required this.parentName,
    required this.counselorId,
    required this.counselorName,
    required this.studentId,
    required this.studentName,
    required this.reason,
    required this.numberOfSessions,
    required this.expectedOutcomes,
    this.status = ProposalStatus.pending,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  factory CounsellingProposal.fromJson(Map<String, dynamic> json) {
    return CounsellingProposal(
      id: json['id'] as String,
      parentId: json['parentId'] as String,
      parentName: json['parentName'] as String,
      counselorId: json['counselorId'] as String,
      counselorName: json['counselorName'] as String,
      studentId: json['studentId'] as String,
      studentName: json['studentName'] as String,
      reason: json['reason'] as String,
      numberOfSessions: json['numberOfSessions'] as int,
      expectedOutcomes: json['expectedOutcomes'] as String,
      status: ProposalStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ProposalStatus.pending,
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'parentId': parentId,
        'parentName': parentName,
        'counselorId': counselorId,
        'counselorName': counselorName,
        'studentId': studentId,
        'studentName': studentName,
        'reason': reason,
        'numberOfSessions': numberOfSessions,
        'expectedOutcomes': expectedOutcomes,
        'status': status.name,
        'createdAt': createdAt.toIso8601String(),
      };

  CounsellingProposal copyWith({ProposalStatus? status}) {
    return CounsellingProposal(
      id: id,
      parentId: parentId,
      parentName: parentName,
      counselorId: counselorId,
      counselorName: counselorName,
      studentId: studentId,
      studentName: studentName,
      reason: reason,
      numberOfSessions: numberOfSessions,
      expectedOutcomes: expectedOutcomes,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}
