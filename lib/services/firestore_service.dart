import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ── Top-level collection references ─────────────────────────
  CollectionReference<Map<String, dynamic>> get users => _db.collection('users');
  CollectionReference<Map<String, dynamic>> get tests => _db.collection('tests');
  CollectionReference<Map<String, dynamic>> get testAttempts => _db.collection('testAttempts');
  CollectionReference<Map<String, dynamic>> get reports => _db.collection('reports');
  CollectionReference<Map<String, dynamic>> get proposals => _db.collection('proposals');
  CollectionReference<Map<String, dynamic>> get remarks => _db.collection('remarks');
  CollectionReference<Map<String, dynamic>> get sessions => _db.collection('sessions');
  CollectionReference<Map<String, dynamic>> get notifications => _db.collection('notifications');

  // ── Sub-collection helpers ──────────────────────────────────
  CollectionReference<Map<String, dynamic>> studentProfile(String uid) =>
      users.doc(uid).collection('studentProfile');

  CollectionReference<Map<String, dynamic>> counselorProfile(String uid) =>
      users.doc(uid).collection('counselorProfile');

  CollectionReference<Map<String, dynamic>> academics(String uid) =>
      users.doc(uid).collection('academics');

  CollectionReference<Map<String, dynamic>> questions(String testId) =>
      tests.doc(testId).collection('questions');

  CollectionReference<Map<String, dynamic>> careerRecommendations(String reportId) =>
      reports.doc(reportId).collection('careerRecommendations');

  // ── Generic CRUD ────────────────────────────────────────────

  Future<Map<String, dynamic>?> getDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String docId,
  ) async {
    final snap = await collection.doc(docId).get();
    if (!snap.exists) return null;
    return {'id': snap.id, ...snap.data()!};
  }

  Future<List<Map<String, dynamic>>> getCollection(
    CollectionReference<Map<String, dynamic>> collection, {
    List<WhereClause>? where,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    Query<Map<String, dynamic>> query = collection;

    if (where != null) {
      for (final w in where) {
        query = query.where(w.field, isEqualTo: w.isEqualTo, isGreaterThan: w.isGreaterThan, isLessThan: w.isLessThan);
      }
    }
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    if (limit != null) {
      query = query.limit(limit);
    }

    final snap = await query.get();
    return snap.docs.map((d) => {'id': d.id, ...d.data()}).toList();
  }

  Future<void> setDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String docId,
    Map<String, dynamic> data, {
    bool merge = true,
  }) async {
    await collection.doc(docId).set(data, SetOptions(merge: merge));
  }

  Future<String> addDocument(
    CollectionReference<Map<String, dynamic>> collection,
    Map<String, dynamic> data,
  ) async {
    final ref = await collection.add(data);
    return ref.id;
  }

  Future<void> updateDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await collection.doc(docId).update(data);
  }

  Future<void> deleteDocument(
    CollectionReference<Map<String, dynamic>> collection,
    String docId,
  ) async {
    await collection.doc(docId).delete();
  }
}

class WhereClause {
  final String field;
  final Object? isEqualTo;
  final Object? isGreaterThan;
  final Object? isLessThan;

  WhereClause(this.field, {this.isEqualTo, this.isGreaterThan, this.isLessThan});
}
