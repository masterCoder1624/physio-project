import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/models/clinical_models.dart';
import 'package:flutter_application_1/services/patient_service.dart';

void main() {
  group('PhysioVerse V1 Clinical Workflow & Release Gate Tests', () {
    final patientService = PatientService();

    test('Full V1 Release Gate: Register -> Assess -> Plan -> Note -> Prescribe -> HEP Complete -> Bill in Vault', () async {
      // 1. Register Patient with Initial Bill
      final initialBill = BillRecordModel(
        id: 'BILL_TEST_101',
        fileNo: 'FILE9999',
        receiptNo: 'REC-2026-9999',
        dateStr: '17-08-2026',
        description: 'Initial Evaluation & Treatment',
        amount: 1500,
        paidAmount: 1200,
        remainingAmount: 300,
        paymentMode: 'Offline Cash',
        status: 'COMPLETED',
      );

      final patient = await patientService.createPatient(
        name: 'Aarav Patel',
        condition: 'ACL Reconstruction Rehabilitation',
        gender: 'male',
        age: '27',
        city: 'Jaipur',
        phone: '9876543210',
        initialNotes: 'Post-op week 3. Limited flexion.',
        initialBill: initialBill,
      );

      expect(patient.id, isNotNull);
      expect(patient.name, 'Aarav Patel');
      expect(patient.bills.length, 1);
      expect(patient.bills.first.receiptNo, 'REC-2026-9999');

      // 2. Clinical Assessment (V1-05)
      const assessment = AssessmentModel(
        id: 'ASS_TEST_1',
        date: '2026-08-17',
        chiefComplaint: 'Stiffness and inability to bend knee past 90 degrees.',
        painLevel: 6,
        painType: 'Mechanical aching',
        activeRomFlexion: '90°',
        activeRomExtension: '0°',
        passiveRom: '95°',
        muscleStrengthMMT: '3+/5',
        functionalLimitations: 'Cannot descend stairs normally.',
        clinicalGoal: 'Achieve 130° flexion and return to sports.',
      );

      await patientService.saveAssessment(patient.id!, assessment);
      final assessedPatient = await patientService.getPatientById(patient.id!);
      expect(assessedPatient.assessment?.painLevel, 6);
      expect(assessedPatient.assessment?.activeRomFlexion, '90°');

      // 3. Treatment Program Creation (V1-07)
      final treatmentProgram = TreatmentProgramModel(
        id: 'PRG_TEST_1',
        title: 'ACL Phase 2 Mobility & Strength Program',
        diagnosis: 'Right ACL Reconstruction - Week 3',
        primaryGoal: 'Restore full ROM and quad symmetry',
        durationWeeks: 8,
        totalSessionsTarget: 16,
        completedSessionsCount: 0,
        startDate: '2026-08-17',
        assignedExercises: const [
          AssignedExercise(
            id: 'ASG_TEST_1',
            exerciseId: 'ex-1',
            title: 'Quadriceps Setting (Quad Sets)',
            bodyPart: 'Knee',
            difficulty: 'Beginner',
            instructions: 'Press knee down into towel roll for 5s.',
            sets: 3,
            reps: 10,
            holdSeconds: 5,
            isCompleted: false,
          ),
        ],
      );

      await patientService.saveTreatmentProgram(patient.id!, treatmentProgram);
      final plannedPatient = await patientService.getPatientById(patient.id!);
      expect(plannedPatient.treatmentPrograms.first.title, 'ACL Phase 2 Mobility & Strength Program');

      // 4. Prescribe additional exercise from Library (V1-08, V1-09)
      const newExercise = AssignedExercise(
        id: 'ASG_TEST_2',
        exerciseId: 'ex-2',
        title: 'Straight Leg Raise (SLR)',
        bodyPart: 'Knee & Hip',
        difficulty: 'Intermediate',
        instructions: 'Lift straight leg 45 degrees, hold 3s.',
        sets: 3,
        reps: 12,
        holdSeconds: 3,
      );

      await patientService.assignExerciseToPatient(patient.id!, newExercise);
      final prescribedPatient = await patientService.getPatientById(patient.id!);
      expect(prescribedPatient.treatmentPrograms.first.assignedExercises.length, 2);

      // 5. Patient views and marks exercise completed (V1-10)
      await patientService.toggleExerciseCompletion(patient.id!, 'ASG_TEST_1', true);
      final completedPatient = await patientService.getPatientById(patient.id!);
      expect(completedPatient.treatmentPrograms.first.assignedExercises.first.isCompleted, true);

      // 6. Record SOAP Session Note (V1-06)
      const sessionNote = SessionNoteModel(
        id: 'NOTE_TEST_1',
        sessionNumber: 1,
        date: '2026-08-17',
        painLevel: 4,
        subjectiveNotes: 'Patient feels knee is looser after morning quad sets.',
        objectiveFindings: 'Flexion improved to 100°. No increased joint effusion.',
        treatmentRendered: 'Patellofemoral joint mobilizations Grade II, stationary cycle 10 mins.',
        planForNextSession: 'Introduce closed-chain wall slides and mini-squats.',
      );

      await patientService.addSessionNote(patient.id!, sessionNote);
      final notedPatient = await patientService.getPatientById(patient.id!);
      expect(notedPatient.sessionNotes.length, 1);
      expect(notedPatient.sessionNotes.first.painLevel, 4);
      expect(notedPatient.treatmentPrograms.first.completedSessionsCount, 1);

      // 7. Save additional generated Bill into Bill Vault (V1-14, V1-16)
      final followUpBill = BillRecordModel(
        id: 'BILL_TEST_102',
        fileNo: 'FILE9999',
        receiptNo: 'REC-2026-10000',
        dateStr: '17-08-2026',
        description: 'Session 1 Manual Therapy & Modalities',
        amount: 800,
        paidAmount: 800,
        remainingAmount: 0,
        paymentMode: 'UPI / Online',
        status: 'COMPLETED',
      );

      await patientService.saveBillToVault(patient.id!, followUpBill);
      final finalPatient = await patientService.getPatientById(patient.id!);
      expect(finalPatient.bills.length, 2);
      expect(finalPatient.bills.first.receiptNo, 'REC-2026-10000');
      expect(finalPatient.bills.first.isFullyPaid, true);
    });
  });
}
