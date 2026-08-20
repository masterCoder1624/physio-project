import '../core/network/api_client.dart';
import '../models/clinical_models.dart';
import '../models/exercise_model.dart';
import '../models/patient_model.dart';

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

  // In-memory patient store populated with full V1 clinical test data
  final List<PatientModel> _localPatientsStore = [
    PatientModel(
      id: '1',
      name: 'Ananya Sharma',
      condition: 'Knee Injury Rehabilitation',
      gender: 'female',
      age: '29',
      city: 'Jaipur',
      phone: '+91 98765 43210',
      status: 'ACTIVE',
      createdAt: '2026-07-01',
      assessment: const AssessmentModel(
        id: 'ASS_001',
        date: '2026-07-02',
        chiefComplaint: 'Right knee pain post-twisting injury, swelling with weight bearing.',
        painLevel: 6,
        painType: 'Throbbing / Aching',
        activeRomFlexion: '105°',
        activeRomExtension: '0°',
        passiveRom: '115°',
        muscleStrengthMMT: '3+/5 (Fair+)',
        functionalLimitations: 'Difficulty negotiating stairs and sustained squatting.',
        postureGaitNotes: 'Antalgic gait favoring right lower extremity.',
        clinicalGoal: 'Achieve 130° flexion, pain score <= 2/10, resume light jogging in 6 weeks.',
      ),
      treatmentPrograms: [
        TreatmentProgramModel(
          id: 'PRG_001',
          title: 'Post-Injury Knee Recovery Protocol',
          diagnosis: 'Right Knee Medial Meniscal Strain & Patellar Tendinopathy',
          primaryGoal: 'Restore full pain-free ROM and quad strength',
          durationWeeks: 6,
          totalSessionsTarget: 12,
          completedSessionsCount: 4,
          startDate: '2026-07-03',
          status: 'ACTIVE',
          assignedExercises: const [
            AssignedExercise(
              id: 'ASG_001',
              exerciseId: 'ex-1',
              title: 'Quadriceps Setting (Quad Sets)',
              bodyPart: 'Knee',
              difficulty: 'Beginner',
              instructions: 'Press knee downwards into towel roll. Hold for 5 seconds.',
              sets: 3,
              reps: 10,
              holdSeconds: 5,
              frequencyPerDay: 2,
              isCompleted: true,
            ),
            AssignedExercise(
              id: 'ASG_002',
              exerciseId: 'ex-2',
              title: 'Straight Leg Raise (SLR)',
              bodyPart: 'Knee & Hip',
              difficulty: 'Beginner',
              instructions: 'Keep leg straight and lift 45 degrees. Lower slowly.',
              sets: 3,
              reps: 12,
              holdSeconds: 3,
              frequencyPerDay: 2,
              isCompleted: true,
            ),
            AssignedExercise(
              id: 'ASG_003',
              exerciseId: 'ex-3',
              title: 'Heel Slides with Towel',
              bodyPart: 'Knee',
              difficulty: 'Beginner',
              instructions: 'Slide heel towards buttocks to tolerance. Hold 3 seconds.',
              sets: 3,
              reps: 10,
              holdSeconds: 3,
              frequencyPerDay: 2,
              isCompleted: false,
            ),
          ],
        ),
      ],
      sessionNotes: const [
        SessionNoteModel(
          id: 'NOTE_001',
          sessionNumber: 1,
          date: '2026-07-03',
          painLevel: 6,
          subjectiveNotes: 'Patient reports moderate aching in medial knee after walking 15 mins.',
          objectiveFindings: 'Mild effusion, tenderness over medial joint line. Flexion 105°.',
          treatmentRendered: 'Cryotherapy, gentle passive mobilization Grade II, isometric quad activation.',
          planForNextSession: 'Progress to active-assisted heel slides and SLR with 1kg cuff weight.',
        ),
        SessionNoteModel(
          id: 'NOTE_002',
          sessionNumber: 2,
          date: '2026-07-10',
          painLevel: 4,
          subjectiveNotes: 'Effusion decreased significantly. Walking feels more stable.',
          objectiveFindings: 'Flexion improved to 115°. Extension full at 0°. No resting pain.',
          treatmentRendered: 'Ultrasound therapy 1.5W/cm2, patellar taping, closed chain mini-squats.',
          planForNextSession: 'Introduce resistance band hamstring curls and step-downs.',
        ),
      ],
      bills: const [
        BillRecordModel(
          id: 'BILL_001',
          fileNo: 'FILE0001',
          receiptNo: 'REC-2026-001',
          dateStr: '03-07-2026',
          description: 'Initial Evaluation & Treatment Session',
          amount: 1200,
          paidAmount: 1200,
          remainingAmount: 0,
          paymentMode: 'UPI / Online',
          status: 'COMPLETED',
        ),
        BillRecordModel(
          id: 'BILL_002',
          fileNo: 'FILE0001',
          receiptNo: 'REC-2026-015',
          dateStr: '10-07-2026',
          description: 'Rehabilitation Session 2 + Taping',
          amount: 800,
          paidAmount: 800,
          remainingAmount: 0,
          paymentMode: 'Offline Cash',
          status: 'COMPLETED',
        ),
      ],
      documents: const [
        PatientDocumentModel(
          id: 'DOC_001',
          title: 'Right Knee MRI Report',
          category: 'Imaging',
          uploadDate: '2026-07-02',
          fileSize: '2.4 MB',
          fileExtension: 'PDF',
          notes: 'Grade 1 medial meniscus tear, no ligament rupture.',
        ),
        PatientDocumentModel(
          id: 'DOC_002',
          title: 'Orthopedic Referral Prescription',
          category: 'Referral',
          uploadDate: '2026-07-02',
          fileSize: '850 KB',
          fileExtension: 'PDF',
        ),
      ],
    ),
    PatientModel(
      id: '2',
      name: 'Rahul Mehta',
      condition: 'Lower Back Pain',
      gender: 'male',
      age: '34',
      city: 'Jaipur',
      phone: '+91 87654 32109',
      status: 'ACTIVE',
      createdAt: '2026-07-15',
      assessment: const AssessmentModel(
        id: 'ASS_002',
        date: '2026-07-15',
        chiefComplaint: 'Lumbar pain radiating to left gluteal region exacerbated by sitting >30 mins.',
        painLevel: 5,
        painType: 'Dull / Aching with occasional stabbing',
        activeRomFlexion: 'Fingertips to mid-shin (approx 50°)',
        activeRomExtension: '10° with mild discomfort',
        passiveRom: 'Normal hip range',
        muscleStrengthMMT: '4/5',
        functionalLimitations: 'Prolonged desk work causes stiffness; difficulty lifting heavy objects.',
        clinicalGoal: 'Full lumbar extension without pain, sit comfortably for 90 mins.',
      ),
      treatmentPrograms: [
        TreatmentProgramModel(
          id: 'PRG_002',
          title: 'Lumbar Core Stabilization & Decompression',
          diagnosis: 'L4-L5 Disc Bulge with Mechanical Low Back Pain',
          primaryGoal: 'Strengthen core stabilizers and relieve neural tension',
          durationWeeks: 4,
          totalSessionsTarget: 8,
          completedSessionsCount: 2,
          startDate: '2026-07-16',
          status: 'ACTIVE',
          assignedExercises: const [
            AssignedExercise(
              id: 'ASG_004',
              exerciseId: 'ex-4',
              title: 'Cat-Cow Spinal Mobilization',
              bodyPart: 'Spine & Back',
              difficulty: 'Beginner',
              instructions: 'Perform gentle spinal flexion and extension with breathing.',
              sets: 3,
              reps: 10,
              holdSeconds: 3,
              frequencyPerDay: 2,
            ),
            AssignedExercise(
              id: 'ASG_005',
              exerciseId: 'ex-5',
              title: 'Bridging (Glute Bridge)',
              bodyPart: 'Spine & Hip',
              difficulty: 'Intermediate',
              instructions: 'Squeeze glutes and lift hips. Hold 5 seconds at top.',
              sets: 3,
              reps: 12,
              holdSeconds: 5,
              frequencyPerDay: 2,
            ),
          ],
        ),
      ],
      bills: const [
        BillRecordModel(
          id: 'BILL_003',
          fileNo: 'FILE0002',
          receiptNo: 'REC-2026-022',
          dateStr: '15-07-2026',
          description: 'Consultation & Spinal Traction Session',
          amount: 1000,
          paidAmount: 800,
          remainingAmount: 200,
          paymentMode: 'Offline Cash',
          status: 'COMPLETED',
        ),
      ],
    ),
    PatientModel(
      id: '3',
      name: 'Priya Patel',
      condition: 'Shoulder Impingement',
      gender: 'female',
      age: '42',
      city: 'Jaipur',
      phone: '+91 76543 21098',
      status: 'ACTIVE',
      createdAt: '2026-07-10',
      assessment: const AssessmentModel(
        id: 'ASS_003',
        date: '2026-07-10',
        chiefComplaint: 'Right shoulder pain when reaching overhead or behind back.',
        painLevel: 5,
        painType: 'Sharp on abduction >90°',
        activeRomFlexion: '130°',
        activeRomExtension: '35°',
        passiveRom: '145°',
        muscleStrengthMMT: '4-/5 for external rotators',
        functionalLimitations: 'Difficulty fastening clothes and reaching top shelves.',
      ),
      treatmentPrograms: [
        TreatmentProgramModel(
          id: 'PRG_003',
          title: 'Rotator Cuff & Scapular Rehab',
          diagnosis: 'Subacromial Impingement & Supraspinatus Tendinopathy',
          primaryGoal: 'Restore full overhead elevation without painful arc',
          durationWeeks: 6,
          totalSessionsTarget: 10,
          completedSessionsCount: 3,
          startDate: '2026-07-11',
          status: 'ACTIVE',
          assignedExercises: const [
            AssignedExercise(
              id: 'ASG_006',
              exerciseId: 'ex-6',
              title: 'Pendulum Exercises (Codman’s)',
              bodyPart: 'Shoulder',
              difficulty: 'Beginner',
              instructions: 'Let affected arm dangle and move in smooth circles.',
              sets: 3,
              reps: 15,
              holdSeconds: 0,
              frequencyPerDay: 3,
            ),
            AssignedExercise(
              id: 'ASG_007',
              exerciseId: 'ex-7',
              title: 'Scapular Retraction & Wall Slides',
              bodyPart: 'Shoulder & Upper Back',
              difficulty: 'Intermediate',
              instructions: 'Slide forearms up wall maintaining scapular depression.',
              sets: 3,
              reps: 10,
              holdSeconds: 3,
              frequencyPerDay: 2,
            ),
          ],
        ),
      ],
      bills: const [
        BillRecordModel(
          id: 'BILL_004',
          fileNo: 'FILE0003',
          receiptNo: 'REC-2026-031',
          dateStr: '10-07-2026',
          description: 'Evaluation & Manual Mobilization',
          amount: 1000,
          paidAmount: 1000,
          remainingAmount: 0,
          paymentMode: 'UPI / Online',
          status: 'COMPLETED',
        ),
      ],
    ),
    PatientModel(
      id: '4',
      name: 'Vikram Singh Nagar',
      condition: 'Post-ACL Surgery Rehab',
      gender: 'male',
      age: '25',
      city: 'JAIPUR',
      phone: '8739874457',
      status: 'ACTIVE',
      createdAt: '2026-07-20',
      assessment: const AssessmentModel(
        id: 'ASS_004',
        date: '2026-07-20',
        chiefComplaint: 'Post-operative stiffness and quadriceps atrophy 4 weeks post-ACL repair.',
        painLevel: 3,
        painType: 'Stiff / Mild aching on terminal extension',
        activeRomFlexion: '115°',
        activeRomExtension: '0°',
        passiveRom: '120°',
        muscleStrengthMMT: '4/5',
        functionalLimitations: 'Unable to run or perform cutting maneuvers. Full weight bearing achieved.',
        clinicalGoal: 'Return to competitive cricket in 6 months.',
      ),
      treatmentPrograms: [
        TreatmentProgramModel(
          id: 'PRG_004',
          title: 'Post-Op ACL Phase 2 Protocol',
          diagnosis: 'Right ACL Reconstruction (Hamstring Graft) - Week 4',
          primaryGoal: 'Achieve 135° flexion, symmetric quad girth, and normal gait',
          durationWeeks: 8,
          totalSessionsTarget: 16,
          completedSessionsCount: 4,
          startDate: '2026-07-21',
          status: 'ACTIVE',
          assignedExercises: const [
            AssignedExercise(
              id: 'ASG_008',
              exerciseId: 'ex-1',
              title: 'Quadriceps Setting (Quad Sets)',
              bodyPart: 'Knee',
              difficulty: 'Beginner',
              instructions: 'Press knee down into towel. Hold 5s. 3 sets of 10 reps.',
              sets: 3,
              reps: 10,
              holdSeconds: 5,
              frequencyPerDay: 2,
              isCompleted: true,
            ),
            AssignedExercise(
              id: 'ASG_009',
              exerciseId: 'ex-2',
              title: 'Straight Leg Raise (SLR)',
              bodyPart: 'Knee & Hip',
              difficulty: 'Intermediate',
              instructions: 'Lift straight leg 45 degrees. 3 sets of 12 reps.',
              sets: 3,
              reps: 12,
              holdSeconds: 3,
              frequencyPerDay: 2,
              isCompleted: false,
            ),
          ],
        ),
      ],
      sessionNotes: const [
        SessionNoteModel(
          id: 'NOTE_003',
          sessionNumber: 1,
          date: '2026-07-21',
          painLevel: 3,
          subjectiveNotes: 'Patient doing well with crutch weaning. No graft site pain.',
          objectiveFindings: 'Flexion 115°, extension full at 0°. Mild portal tenderness.',
          treatmentRendered: 'Scar tissue massage, active ROM, stationary cycling with zero resistance.',
          planForNextSession: 'Increase bike duration to 15 mins, introduce proprioception rocker board.',
        ),
      ],
      bills: const [
        BillRecordModel(
          id: 'BILL_005',
          fileNo: 'FILE0005',
          receiptNo: 'FILE0005-1',
          dateStr: '20-07-2026',
          description: 'Treatment Session',
          amount: 1000,
          paidAmount: 800,
          remainingAmount: 200,
          paymentMode: 'Offline Payment',
          status: 'COMPLETED',
        ),
      ],
    ),
  ];

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

      if (response.success && response.data != null && response.data!.isNotEmpty) {
        final existingIds = response.data!.map((p) => p.id).toSet();
        final localExtras = _localPatientsStore.where((p) => !existingIds.contains(p.id));
        return [...response.data!, ...localExtras];
      }
    } catch (_) {}

    return List.from(_localPatientsStore);
  }

  Future<PatientModel> getPatientById(String id) async {
    final match = _localPatientsStore.firstWhere(
      (p) => p.id == id,
      orElse: () => _localPatientsStore.first,
    );
    return match;
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
    final newId = 'PAT_${DateTime.now().millisecondsSinceEpoch}';
    final newPatient = PatientModel(
      id: newId,
      name: name.trim(),
      condition: condition.trim(),
      gender: gender?.toLowerCase() ?? 'male',
      age: age?.trim() ?? '28',
      city: city?.trim() ?? 'Jaipur',
      phone: phone?.trim() ?? '8739874457',
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

    _localPatientsStore.insert(0, newPatient);

    try {
      await _apiClient.post<PatientModel>(
        '/patients',
        body: {
          'name': name.trim(),
          'full_name': name.trim(),
          'primary_condition': condition.trim(),
          'gender': gender?.toLowerCase(),
          'emergency_contact_phone': phone?.trim(),
          'emergency_contact_name': name.trim(),
        },
        fromJson: (json) => PatientModel.fromJson(json as Map<String, dynamic>),
      );
    } catch (_) {}

    return newPatient;
  }

  /// Save or update clinical assessment for a patient (V1-05)
  Future<void> saveAssessment(String patientId, AssessmentModel assessment) async {
    final index = _localPatientsStore.indexWhere((p) => p.id == patientId);
    if (index != -1) {
      final updated = _localPatientsStore[index].copyWith(assessment: assessment);
      _localPatientsStore[index] = updated;
    }
  }

  /// Add or update a treatment program (V1-07)
  Future<void> saveTreatmentProgram(String patientId, TreatmentProgramModel program) async {
    final index = _localPatientsStore.indexWhere((p) => p.id == patientId);
    if (index != -1) {
      final currentList = List<TreatmentProgramModel>.from(_localPatientsStore[index].treatmentPrograms);
      final progIndex = currentList.indexWhere((prg) => prg.id == program.id);
      if (progIndex != -1) {
        currentList[progIndex] = program;
      } else {
        currentList.insert(0, program);
      }
      _localPatientsStore[index] = _localPatientsStore[index].copyWith(treatmentPrograms: currentList);
    }
  }

  /// Assign a new exercise to a patient's active program (V1-09)
  Future<void> assignExerciseToPatient(String patientId, AssignedExercise exercise) async {
    final index = _localPatientsStore.indexWhere((p) => p.id == patientId);
    if (index != -1) {
      final patient = _localPatientsStore[index];
      if (patient.treatmentPrograms.isNotEmpty) {
        final activeProgram = patient.treatmentPrograms.first;
        final updatedExercises = List<AssignedExercise>.from(activeProgram.assignedExercises)..add(exercise);
        final updatedProgram = activeProgram.copyWith(assignedExercises: updatedExercises);
        final updatedPrograms = List<TreatmentProgramModel>.from(patient.treatmentPrograms);
        updatedPrograms[0] = updatedProgram;
        _localPatientsStore[index] = patient.copyWith(treatmentPrograms: updatedPrograms);
      }
    }
  }

  /// Add a SOAP treatment session note with previous session context (V1-06)
  Future<void> addSessionNote(String patientId, SessionNoteModel note) async {
    final index = _localPatientsStore.indexWhere((p) => p.id == patientId);
    if (index != -1) {
      final currentNotes = List<SessionNoteModel>.from(_localPatientsStore[index].sessionNotes);
      currentNotes.insert(0, note);
      
      // Also advance completed sessions count in active program
      var programs = List<TreatmentProgramModel>.from(_localPatientsStore[index].treatmentPrograms);
      if (programs.isNotEmpty) {
        programs[0] = programs[0].copyWith(
          completedSessionsCount: programs[0].completedSessionsCount + 1,
        );
      }

      _localPatientsStore[index] = _localPatientsStore[index].copyWith(
        sessionNotes: currentNotes,
        treatmentPrograms: programs,
      );
    }
  }

  /// Save generated bill into patient's Bill Vault (V1-16)
  Future<void> saveBillToVault(String patientId, BillRecordModel bill) async {
    final index = _localPatientsStore.indexWhere((p) => p.id == patientId);
    if (index != -1) {
      final currentBills = List<BillRecordModel>.from(_localPatientsStore[index].bills);
      currentBills.insert(0, bill);
      _localPatientsStore[index] = _localPatientsStore[index].copyWith(bills: currentBills);
    }
  }

  /// Add clinical document to patient profile (V1-17)
  Future<void> addDocument(String patientId, PatientDocumentModel document) async {
    final index = _localPatientsStore.indexWhere((p) => p.id == patientId);
    if (index != -1) {
      final currentDocs = List<PatientDocumentModel>.from(_localPatientsStore[index].documents);
      currentDocs.insert(0, document);
      _localPatientsStore[index] = _localPatientsStore[index].copyWith(documents: currentDocs);
    }
  }

  /// Patient side: toggle completion of an assigned exercise (V1-10)
  Future<void> toggleExerciseCompletion(String patientId, String assignedExerciseId, bool completed) async {
    final index = _localPatientsStore.indexWhere((p) => p.id == patientId);
    if (index != -1) {
      final patient = _localPatientsStore[index];
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
        _localPatientsStore[index] = patient.copyWith(treatmentPrograms: updatedPrograms);
      }
    }
  }
}
