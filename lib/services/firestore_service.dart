// lib/services/firestore_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // ── Submit a new application (Citizen side) ──────────────────────────
  Future<void> submitApplication({
    required String citizenName,
    required String citizenPhone,
    required String serviceType,
    required String details,
  }) async {
    await _db.collection('applications').add({
      'citizenName':  citizenName,
      'citizenPhone': citizenPhone,
      'serviceType':  serviceType,
      'details':      details,
      'status':       'pending',
      'approvalHash': null,
      'submittedAt':  FieldValue.serverTimestamp(),
      'reviewedAt':   null,
    });
  }

  // ── Stream for Citizen: only their phone-number applications ──────────
  Stream<QuerySnapshot> getCitizenApplicationsStream(String phone) {
    return _db
        .collection('applications')
        .where('citizenPhone', isEqualTo: phone)
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // ── Stream for Admin: all applications ───────────────────────────────
  Stream<QuerySnapshot> getAllApplicationsStream() {
    return _db
        .collection('applications')
        .orderBy('submittedAt', descending: true)
        .snapshots();
  }

  // ── Admin: Approve application + generate cryptographic hash ─────────
  Future<void> approveApplication(String docId, String citizenName, String serviceType) async {
    // Generate a unique hash based on the approval details + timestamp
    final raw = '$docId:$citizenName:$serviceType:${DateTime.now().toIso8601String()}';
    final hash = sha256.convert(utf8.encode(raw)).toString().substring(0, 16).toUpperCase();

    await _db.collection('applications').doc(docId).update({
      'status':       'approved',
      'approvalHash': hash,
      'reviewedAt':   FieldValue.serverTimestamp(),
    });
  }

  // ── Admin: Reject application ────────────────────────────────────────
  Future<void> rejectApplication(String docId, String reason) async {
    await _db.collection('applications').doc(docId).update({
      'status':     'rejected',
      'rejectNote': reason,
      'reviewedAt': FieldValue.serverTimestamp(),
    });
  }
}
