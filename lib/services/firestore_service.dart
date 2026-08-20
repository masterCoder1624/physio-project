import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _firestore;

  CollectionReference<Map<String, dynamic>> get _patientsCollection =>
      _firestore.collection('patients');

  Future<void> addPatient({
    required String physioId,
    required String name,
    required String condition,
    String? gender,
  }) async {
    final cleanedPhysioId = physioId.trim();
    final cleanedName = name.trim();
    final cleanedCondition = condition.trim();
    final cleanedGender = gender?.trim();

    if (cleanedPhysioId.isEmpty ||
        cleanedName.isEmpty ||
        cleanedCondition.isEmpty) {
      throw ArgumentError(
        'Physio ID, patient name, and condition are required.',
      );
    }

    final patientDocument = _patientsCollection.doc();
    final payload = <String, dynamic>{
      'patientId': patientDocument.id,
      'physioId': cleanedPhysioId,
      'name': cleanedName,
      'condition': cleanedCondition,
      'phone': '',
      'medicalHistory': '',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
    if (cleanedGender != null && cleanedGender.isNotEmpty) {
      payload['gender'] = cleanedGender;
    }

    try {
      debugPrint('DEBUG: Adding patient for physioId: $cleanedPhysioId');
      await patientDocument.set(payload);
      debugPrint(
        'DEBUG: Patient added successfully with ID: ${patientDocument.id}',
      );
    } on FirebaseException catch (error) {
      debugPrint(
        'ERROR: Failed to add patient (${error.code}): ${error.message}',
      );
      rethrow;
    } catch (error) {
      debugPrint('ERROR: Failed to add patient: $error');
      rethrow;
    }
  }
}
