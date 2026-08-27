import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_application_1/models/chat_model.dart';
import 'package:flutter_application_1/services/chat_service.dart';
import 'package:flutter_application_1/screens/physio/physio_messages_screen.dart';
import 'package:flutter_application_1/screens/physio/physio_chat_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_messages_screen.dart';
import 'package:flutter_application_1/screens/patient/patient_chat_screen.dart';

void main() {
  setUp(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'access_token': 'mock_valid_chat_token_test',
      'user_id': 'physio_test_001',
      'user_role': 'physiotherapist',
    });
  });

  group('Phase 6 Chat Model & Service Tests', () {
    test('ConversationModel serializes and parses JSON correctly', () {
      final json = {
        'id': 'conv_123',
        'patient_id': 'pat_rec_001',
        'patient_user_id': 'pat_user_001',
        'physiotherapist_id': 'phys_user_001',
        'patient_name': 'Rahul Sharma',
        'physiotherapist_name': 'Dr. Alex',
        'last_message_content': 'How is your knee flexion today?',
        'last_message_sender_id': 'phys_user_001',
        'last_message_at': '2026-08-20T10:30:00.000Z',
        'unread_count': 2,
        'created_at': '2026-08-15T08:00:00.000Z',
        'is_active': true,
      };

      final conv = ConversationModel.fromJson(json);

      expect(conv.id, 'conv_123');
      expect(conv.patientId, 'pat_rec_001');
      expect(conv.patientName, 'Rahul Sharma');
      expect(conv.physiotherapistName, 'Dr. Alex');
      expect(conv.patientInitials, 'RS');
      expect(conv.unreadCount, 2);
      expect(conv.timeFormatted, contains('Aug'));

      final out = conv.toJson();
      expect(out['id'], 'conv_123');
      expect(out['patient_name'], 'Rahul Sharma');
      expect(out['unread_count'], 2);
    });

    test('ChatMessageModel serializes and parses JSON correctly', () {
      final json = {
        'id': 'msg_001',
        'conversation_id': 'conv_123',
        'sender_id': 'phys_user_001',
        'sender_role': 'physiotherapist',
        'sender_name': 'Dr. Alex',
        'recipient_id': 'pat_user_001',
        'content': 'Please perform the quad sets twice daily.',
        'message_type': 'text',
        'is_read': true,
        'read_at': '2026-08-20T10:35:00.000Z',
        'created_at': '2026-08-20T10:30:00.000Z',
      };

      final msg = ChatMessageModel.fromJson(json);

      expect(msg.id, 'msg_001');
      expect(msg.conversationId, 'conv_123');
      expect(msg.content, 'Please perform the quad sets twice daily.');
      expect(msg.senderRole, 'physiotherapist');
      expect(msg.isRead, isTrue);
      expect(msg.isSentBy('phys_user_001'), isTrue);
      expect(msg.isSentBy('pat_user_001'), isFalse);
    });

    test('ChatService is a singleton', () {
      final s1 = ChatService();
      final s2 = ChatService();
      expect(identical(s1, s2), isTrue);
    });
  });

  group('Phase 6 Chat UI Widget Tests', () {
    testWidgets('Renders PhysioMessagesScreen with search bar and app bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PhysioMessagesScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Patient Messages'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Renders PhysioChatScreen with patient header and input bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PhysioChatScreen(
            conversationId: 'mock_conv_001',
            patientId: 'pat_001',
            patientName: 'Rahul Sharma',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Rahul Sharma'), findsOneWidget);
      expect(find.text('Active Patient'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Renders PatientMessagesScreen with app bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientMessagesScreen(),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Messages'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('Renders PatientChatScreen with doctor header and input bar', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        const MaterialApp(
          home: PatientChatScreen(
            conversationId: 'mock_conv_001',
            doctorName: 'Dr. Alex Physiotherapist',
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Dr. Alex Physiotherapist'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
    });
  });
}
