import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfileImage(String userId, File file) async {
    final ref = _storage.ref().child('profileImages/$userId.jpg');
    await ref.putFile(file, SettableMetadata(contentType: 'image/jpeg'));
    return ref.getDownloadURL();
  }

  Future<String> uploadReportPdf(String reportId, File file) async {
    final ref = _storage.ref().child('reports/$reportId.pdf');
    await ref.putFile(file, SettableMetadata(contentType: 'application/pdf'));
    return ref.getDownloadURL();
  }
}
