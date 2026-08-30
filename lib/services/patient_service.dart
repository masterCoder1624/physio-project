import '../core/network/api_client.dart';
import '../models/clinical_models.dart';
import '../models/exercise_model.dart';
import '../models/patient_model.dart';
import 'clinical_service.dart';

class PatientService {
  factory PatientService({ApiClient? apiClient}) {
    if (apiClient != null) {
      _instance._apiClient = apiClient;
    }
    return _instance;
  }

  PatientService._internal();

  static final PatientService _instance = PatientService._internal();
  ApiClient _apiClient = ApiClient();

  // Comprehensive master exercise library (V1-08)
  static const List<ExerciseModel> masterExerciseLibrary = [
    ExerciseModel(
      id: 'ex-1',
      categoryId: 'knee',
      title: 'Quadriceps Setting (Quad Sets)',
      description: 'Isometric quadriceps strengthening and patellar mobilization',
      bodyPart: 'Knee',
      difficulty: 'Beginner',
      instructions: 'Lie on your back with a rolled towel under your knee. Tighten the thigh muscles, pushing the back of the knee down. Hold for 5 seconds, then relax.',
      sets: 3,
      reps: 10,
    ),
    ExerciseModel(
      id: 'ex-2',
      categoryId: 'knee',
      title: 'Straight Leg Raise (SLR)',
      description: 'Hip flexor and anterior chain strengthening without knee joint strain',
      bodyPart: 'Knee & Hip',
      difficulty: 'Beginner',
      instructions: 'Keep the active leg completely straight. Lift the leg 45 degrees off the ground, hold for 3 seconds, and slowly lower back down.',
      sets: 3,
      reps: 12,
    ),
    ExerciseModel(
      id: 'ex-3',
      categoryId: 'knee',
      title: 'Heel Slides with Towel',
      description: 'Active-assisted knee flexion range of motion restoration',
      bodyPart: 'Knee',
      difficulty: 'Beginner',
      instructions: 'Slide heel slowly towards buttocks bending the knee as far as comfortable. Hold for 3 seconds at end range, then slide back.',
      sets: 3,
      reps: 10,
    ),
    ExerciseModel(
      id: 'ex-4',
      categoryId: 'spine',
      title: 'Cat-Cow Spinal Mobilization',
      description: 'Flexibility and segmental mobility for the lumbar and thoracic spine',
      bodyPart: 'Spine & Back',
      difficulty: 'Beginner',
      instructions: 'Start on all fours. Inhale while arching your back and looking up (Cow). Exhale while rounding your spine and tucking chin (Cat).',
      sets: 3,
      reps: 10,
    ),
    ExerciseModel(
      id: 'ex-5',
      categoryId: 'spine',
      title: 'Bridging (Glute Bridge)',
      description: 'Posterior chain, gluteus maximus, and lumbar core activation',
      bodyPart: 'Spine & Hip',
      difficulty: 'Intermediate',
      instructions: 'Lie on your back with knees bent and feet flat on floor. Squeeze glutes and lift hips until body forms a straight line from shoulders to knees. Hold 5 seconds.',
      sets: 3,
      reps: 12,
    ),
    ExerciseModel(
      id: 'ex-6',
      categoryId: 'shoulder',
      title: 'Pendulum Exercises (Codman’s)',
      description: 'Passive glenohumeral joint distraction and pain relief',
      bodyPart: 'Shoulder',
      difficulty: 'Beginner',
      instructions: 'Lean forward supporting unaffected arm on a table. Let affected arm dangle freely. Use body sway to move arm in gentle circles.',
      sets: 3,
      reps: 15,
    ),
    ExerciseModel(
      id: 'ex-7',
      categoryId: 'shoulder',
      title: 'Scapular Retraction & Wall Slides',
      description: 'Scapular stabilizing muscles and postural alignment',
      bodyPart: 'Shoulder & Upper Back',
      difficulty: 'Intermediate',
      instructions: 'Stand facing a wall with forearms against it. Slide arms up while keeping shoulder blades down and back. Hold 3 seconds at top.',
      sets: 3,
      reps: 10,
    ),
    ExerciseModel(
      id: 'ex-8',
      categoryId: 'ankle',
      title: 'Ankle Pumps & Alphabet Circles',
      description: 'Circulation, edema reduction, and ankle joint range of motion',
      bodyPart: 'Ankle & Foot',
      difficulty: 'Beginner',
      instructions: 'Point toes down and flex back up rhythmically. Then trace the letters of the alphabet in the air with big toe.',
      sets: 4,
      reps: 15,
    ),
    ExerciseModel(
      id: 'ex-9',
      categoryId: 'neck',
      title: 'Chin Tucks (Cervical Retraction)',
      description: 'Deep cervical flexor strengthening and forward-head posture correction',
      bodyPart: 'Neck / Cervical',
      difficulty: 'Beginner',
      instructions: 'Sit tall with shoulders relaxed. Gently draw your chin straight back as if making a double chin, without tilting head. Hold 5 seconds.',
      sets: 3,
      reps: 10,
    ),
  ];

  final Map<String, PatientModel> _sessionPatients = {};

  void clearSession() {
    _sessionPatients.clear();
  }

  Future<List<PatientModel>> getPatients({int page = 1, int size = 100}) async {
    try {
      final response = await _apiClient.get<List<PatientModel>>(
        '/patients',
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
        fromJson: (json) {
          if (json is List) {
            return json
                .map((item) => PatientModel.fromJson(item as Map<String, dynamic>))
                .toList();
          }
          return [];
        },
      );

      if (response.success && response.data != null) {
        for (final p in response.data!) {
          if (p.id != null) _sessionPatients[p.id!] = p;
        }
        return response.data!;
      }
    } catch (_) {}

    return _sessionPatients.values.toList();
  }

  Future<PatientModel> getPatientById(String id) async {
    try {
      final response = await _apiClient.get<PatientModel>(
        '/patients/$id',
        fromJson: (json) => PatientModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        var patient = response.data!;
        final latestAssessment = await ClinicalService().getLatestAssessment(id);
        final notes = await ClinicalService().getNotes(id);
        patient = patient.copyWith(
          assessment: latestAssessment ?? patient.assessment,
          sessionNotes: notes.isNotEmpty ? notes : patient.sessionNotes,
        );
        _sessionPatients[id] = patient;
        return patient;
      }
    } catch (_) {}

    if (_sessionPatients.containsKey(id)) {
      return _sessionPatients[id]!;
    }
    throw Exception('Patient not found');
  }

  Future<PatientModel> createPatient({
    required String name,
    required String condition,
    String? gender,
    String? phone,
    String? city,
    String? age,
    String? initialNotes,
    BillRecordModel? initialBill,
  }) async {
    final localId = 'PAT_${DateTime.now().millisecondsSinceEpoch}';
    final localPatient = PatientModel(
      id: localId,
      name: name.trim(),
      condition: condition.trim(),
      gender: gender?.toLowerCase() ?? 'other',
      age: age?.trim() ?? '',
      city: city?.trim() ?? '',
      phone: phone?.trim() ?? '',
      medicalHistory: initialNotes,
      createdAt: DateTime.now().toIso8601String().substring(0, 10),
      assessment: AssessmentModel(
        id: 'ASS_${DateTime.now().millisecondsSinceEpoch}',
        date: DateTime.now().toIso8601String().substring(0, 10),
        chiefComplaint: condition.trim(),
        painLevel: 5,
        painType: 'Aching',
        activeRomFlexion: '110°',
        activeRomExtension: '0°',
        passiveRom: '115°',
        muscleStrengthMMT: '4/5',
        functionalLimitations: initialNotes ?? 'Restricted range and pain on exertion.',
      ),
      treatmentPrograms: [
        TreatmentProgramModel(
          id: 'PRG_${DateTime.now().millisecondsSinceEpoch}',
          title: '$condition Care Program',
          diagnosis: condition.trim(),
          primaryGoal: 'Restore full pain-free function and range of motion',
          durationWeeks: 6,
          totalSessionsTarget: 12,
          completedSessionsCount: 1,
          startDate: DateTime.now().toIso8601String().substring(0, 10),
          assignedExercises: [
            const AssignedExercise(
              id: 'ASG_INIT_1',
              exerciseId: 'ex-1',
              title: 'Quadriceps Setting (Quad Sets)',
              bodyPart: 'Knee',
              difficulty: 'Beginner',
              instructions: 'Press knee downwards into towel roll. Hold 5s.',
              sets: 3,
              reps: 10,
              holdSeconds: 5,
            ),
            const AssignedExercise(
              id: 'ASG_INIT_2',
              exerciseId: 'ex-2',
              title: 'Straight Leg Raise (SLR)',
              bodyPart: 'Knee & Hip',
              difficulty: 'Beginner',
              instructions: 'Lift straight leg 45 degrees and lower slowly.',
              sets: 3,
              reps: 12,
              holdSeconds: 3,
            ),
          ],
        ),
      ],
      bills: initialBill != null ? [initialBill] : [],
    );

    try {
      final response = await _apiClient.post<PatientModel>(
        '/patients',
        body: {
          'name': name.trim(),
          'full_name': name.trim(),
          'primary_condition': condition.trim(),
          'condition': condition.trim(),
          'gender': gender?.toLowerCase() ?? 'other',
          'emergency_contact_phone': phone?.trim(),
          'phone': phone?.trim(),
          'emergency_contact_name': name.trim(),
          'medical_history': initialNotes,
        },
        fromJson: (json) => PatientModel.fromJson(json as Map<String, dynamic>),
      );

      if (response.success && response.data != null) {
        final serverPatient = response.data!;
        final merged = serverPatient.copyWith(
          assessment: localPatient.assessment,
          treatmentPrograms: localPatient.treatmentPrograms,
          bills: localPatient.bills,
        );
        _sessionPatients[merged.id ?? localId] = merged;
        return merged;
      }
    } catch (_) {}

    _sessionPatients[localId] = localPatient;
    return localPatient;
  }

  /// Save or update clinical assessment for a patient (V1-05)
  Future<void> saveAssessment(String patientId, AssessmentModel assessment) async {
    try {
      await ClinicalService().createAssessment(patientId, assessment);
    } catch (_) {}

    if (_sessionPatients.containsKey(patientId)) {
      _sessionPatients[patientId] = _sessionPatients[patientId]!.copyWith(assessment: assessment);
    }
  }

  /// Add or update a treatment program (V1-07)
  Future<void> saveTreatmentProgram(String patientId, TreatmentProgramModel program) async {
    if (_sessionPatients.containsKey(patientId)) {
      final patient = _sessionPatients[patientId]!;
      final currentList = List<TreatmentProgramModel>.from(patient.treatmentPrograms);
      final progIndex = currentList.indexWhere((prg) => prg.id == program.id);
      if (progIndex != -1) {
        currentList[progIndex] = program;
      } else {
        currentList.insert(0, program);
      }
      _sessionPatients[patientId] = patient.copyWith(treatmentPrograms: currentList);
    }
  }

  /// Assign a new exercise to a patient's active program (V1-09)
  Future<void> assignExerciseToPatient(String patientId, AssignedExercise exercise) async {
    if (_sessionPatients.containsKey(patientId)) {
      final patient = _sessionPatients[patientId]!;
      if (patient.treatmentPrograms.isNotEmpty) {
        final activeProgram = patient.treatmentPrograms.first;
        final updatedExercises = List<AssignedExercise>.from(activeProgram.assignedExercises)..add(exercise);
        final updatedProgram = activeProgram.copyWith(assignedExercises: updatedExercises);
        final updatedPrograms = List<TreatmentProgramModel>.from(patient.treatmentPrograms);
        updatedPrograms[0] = updatedProgram;
        _sessionPatients[patientId] = patient.copyWith(treatmentPrograms: updatedPrograms);
      }
    }
  }

  /// Add a SOAP treatment session note with previous session context (V1-06)
  Future<void> addSessionNote(String patientId, SessionNoteModel note) async {
    try {
      await ClinicalService().createNote(patientId, note);
    } catch (_) {}

    if (_sessionPatients.containsKey(patientId)) {
      final patient = _sessionPatients[patientId]!;
      final currentNotes = List<SessionNoteModel>.from(patient.sessionNotes);
      currentNotes.insert(0, note);

      var programs = List<TreatmentProgramModel>.from(patient.treatmentPrograms);
      if (programs.isNotEmpty) {
        programs[0] = programs[0].copyWith(
          completedSessionsCount: programs[0].completedSessionsCount + 1,
        );
      }

      _sessionPatients[patientId] = patient.copyWith(
        sessionNotes: currentNotes,
        treatmentPrograms: programs,
      );
    }
  }

  /// Save generated bill into patient's Bill Vault (V1-16)
  Future<void> saveBillToVault(String patientId, BillRecordModel bill) async {
    if (_sessionPatients.containsKey(patientId)) {
      final patient = _sessionPatients[patientId]!;
      final currentBills = List<BillRecordModel>.from(patient.bills);
      currentBills.insert(0, bill);
      _sessionPatients[patientId] = patient.copyWith(bills: currentBills);
    }
  }

  /// Add clinical document to patient profile (V1-17)
  Future<void> addDocument(String patientId, PatientDocumentModel document) async {
    if (_sessionPatients.containsKey(patientId)) {
      final patient = _sessionPatients[patientId]!;
      final currentDocs = List<PatientDocumentModel>.from(patient.documents);
      currentDocs.insert(0, document);
      _sessionPatients[patientId] = patient.copyWith(documents: currentDocs);
    }
  }

  /// Patient side: toggle completion of an assigned exercise (V1-10)
  Future<void> toggleExerciseCompletion(String patientId, String assignedExerciseId, bool completed) async {
    if (_sessionPatients.containsKey(patientId)) {
      final patient = _sessionPatients[patientId]!;
      if (patient.treatmentPrograms.isNotEmpty) {
        final activeProgram = patient.treatmentPrograms.first;
        final updatedExercises = activeProgram.assignedExercises.map((ex) {
          if (ex.id == assignedExerciseId) {
            return ex.copyWith(isCompleted: completed);
          }
          return ex;
        }).toList();

        final updatedPrograms = List<TreatmentProgramModel>.from(patient.treatmentPrograms);
        updatedPrograms[0] = activeProgram.copyWith(assignedExercises: updatedExercises);
        _sessionPatients[patientId] = patient.copyWith(treatmentPrograms: updatedPrograms);
      }
    }
  }
}
