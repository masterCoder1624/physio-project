import 'clinical_models.dart';
import 'user_model.dart';

class PatientModel {
  const PatientModel({
    this.id,
    this.userId,
    this.physioId,
    required this.name,
    required this.condition,
    this.gender,
    this.age = '28',
    this.city = 'Jaipur',
    this.phone,
    this.status = 'ACTIVE',
    this.medicalHistory,
    this.createdAt,
    this.user,
    this.assessment,
    this.treatmentPrograms = const [],
    this.sessionNotes = const [],
    this.bills = const [],
    this.documents = const [],
    this.assignedExercises = const [],
  });

  final String? id;
  final String? userId;
  final String? physioId;
  final String name;
  final String condition;
  final String? gender;
  final String age;
  final String city;
  final String? phone;
  final String status;
  final String? medicalHistory;
  final String? createdAt;
  final UserModel? user;
  final AssessmentModel? assessment;
  final List<TreatmentProgramModel> treatmentPrograms;
  final List<SessionNoteModel> sessionNotes;
  final List<BillRecordModel> bills;
  final List<PatientDocumentModel> documents;
  final List<AssignedExercise> assignedExercises;

  String get initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'PT';
    if (parts.length == 1) {
      return parts.first.substring(0, parts.first.length > 1 ? 2 : 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  String? validate() {
    final errors = <String>[];
    if (name.trim().length < 2) {
      errors.add('Patient name must be at least 2 characters.');
    }
    if (condition.trim().isEmpty) {
      errors.add('Condition is required.');
    }
    return errors.isEmpty ? null : errors.join(' ');
  }

  factory PatientModel.fromJson(Map<String, dynamic> json) {
    String nameValue = '';
    if (json['user'] != null && json['user'] is Map) {
      final u = json['user'];
      nameValue = '${u['first_name'] ?? ''} ${u['last_name'] ?? ''}'.trim();
    }
    if (nameValue.isEmpty) {
      nameValue = json['name'] as String? ?? 'Patient';
    }

    var programs = <TreatmentProgramModel>[];
    if (json['treatment_programs'] != null && json['treatment_programs'] is List) {
      programs = (json['treatment_programs'] as List)
          .map((p) => TreatmentProgramModel.fromJson(p as Map<String, dynamic>))
          .toList();
    }

    var notes = <SessionNoteModel>[];
    if (json['session_notes'] != null && json['session_notes'] is List) {
      notes = (json['session_notes'] as List)
          .map((n) => SessionNoteModel.fromJson(n as Map<String, dynamic>))
          .toList();
    }

    var billsList = <BillRecordModel>[];
    if (json['bills'] != null && json['bills'] is List) {
      billsList = (json['bills'] as List)
          .map((b) => BillRecordModel.fromJson(b as Map<String, dynamic>))
          .toList();
    }

    var docs = <PatientDocumentModel>[];
    if (json['documents'] != null && json['documents'] is List) {
      docs = (json['documents'] as List)
          .map((d) => PatientDocumentModel.fromJson(d as Map<String, dynamic>))
          .toList();
    }

    var exercises = <AssignedExercise>[];
    if (json['assigned_exercises'] != null && json['assigned_exercises'] is List) {
      exercises = (json['assigned_exercises'] as List)
          .map((e) => AssignedExercise.fromJson(e as Map<String, dynamic>))
          .toList();
    }

    return PatientModel(
      id: json['id'] as String?,
      userId: json['user_id'] as String?,
      physioId: json['physiotherapist_id'] as String? ?? json['physioId'] as String?,
      name: nameValue,
      condition: json['primary_condition'] as String? ?? json['condition'] as String? ?? '',
      gender: json['gender'] as String?,
      age: json['age'] as String? ?? '28',
      city: json['city'] as String? ?? 'Jaipur',
      phone: json['emergency_contact_phone'] as String? ?? json['phone'] as String?,
      status: json['status'] as String? ?? 'ACTIVE',
      medicalHistory: json['medical_history'] as String?,
      createdAt: json['created_at'] as String?,
      user: json['user'] != null && json['user'] is Map<String, dynamic>
          ? UserModel.fromJson(json['user'])
          : null,
      assessment: json['assessment'] != null && json['assessment'] is Map<String, dynamic>
          ? AssessmentModel.fromJson(json['assessment'])
          : null,
      treatmentPrograms: programs,
      sessionNotes: notes,
      bills: billsList,
      documents: docs,
      assignedExercises: exercises,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'physiotherapist_id': physioId,
      'name': name,
      'primary_condition': condition,
      'gender': gender,
      'age': age,
      'city': city,
      'emergency_contact_phone': phone,
      'status': status,
      'medical_history': medicalHistory,
      'created_at': createdAt,
      'user': user?.toJson(),
      'assessment': assessment?.toJson(),
      'treatment_programs': treatmentPrograms.map((p) => p.toJson()).toList(),
      'session_notes': sessionNotes.map((n) => n.toJson()).toList(),
      'bills': bills.map((b) => b.toJson()).toList(),
      'documents': documents.map((d) => d.toJson()).toList(),
      'assigned_exercises': assignedExercises.map((e) => e.toJson()).toList(),
    };
  }

  PatientModel copyWith({
    String? id,
    String? userId,
    String? physioId,
    String? name,
    String? condition,
    String? gender,
    String? age,
    String? city,
    String? phone,
    String? status,
    String? medicalHistory,
    String? createdAt,
    UserModel? user,
    AssessmentModel? assessment,
    List<TreatmentProgramModel>? treatmentPrograms,
    List<SessionNoteModel>? sessionNotes,
    List<BillRecordModel>? bills,
    List<PatientDocumentModel>? documents,
    List<AssignedExercise>? assignedExercises,
  }) {
    return PatientModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      physioId: physioId ?? this.physioId,
      name: name ?? this.name,
      condition: condition ?? this.condition,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      city: city ?? this.city,
      phone: phone ?? this.phone,
      status: status ?? this.status,
      medicalHistory: medicalHistory ?? this.medicalHistory,
      createdAt: createdAt ?? this.createdAt,
      user: user ?? this.user,
      assessment: assessment ?? this.assessment,
      treatmentPrograms: treatmentPrograms ?? this.treatmentPrograms,
      sessionNotes: sessionNotes ?? this.sessionNotes,
      bills: bills ?? this.bills,
      documents: documents ?? this.documents,
      assignedExercises: assignedExercises ?? this.assignedExercises,
    );
  }
}
