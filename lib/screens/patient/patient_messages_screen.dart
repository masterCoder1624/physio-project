import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import 'patient_chat_screen.dart';
import 'patient_components.dart';

/// Screen 17 — Messages Conversation List Screen (matching media_1787385006975.jpg)
class PatientMessagesScreen extends StatefulWidget {
  const PatientMessagesScreen({super.key});

  @override
  State<PatientMessagesScreen> createState() => _PatientMessagesScreenState();
}

class _PatientMessagesScreenState extends State<PatientMessagesScreen> {
  final TextEditingController _searchCtrl = TextEditingController();

  final List<Map<String, dynamic>> _conversations = [
    {
      'name': 'Dr. Vashu User',
      'lastMsg': 'How are you feeling today?',
      'time': '10:30 AM',
      'unread': 1,
      'isDoctor': true,
    },
    {
      'name': 'Physio Clinic',
      'lastMsg': 'Your appointment is confirmed for today.',
      'time': 'Yesterday',
      'unread': 0,
      'isDoctor': false,
    },
    {
      'name': 'Dr. Vashu User',
      'lastMsg': 'Please share your exercise update when completed.',
      'time': '15 Aug',
      'unread': 0,
      'isDoctor': true,
    },
    {
      'name': 'PhysioVerse Support',
      'lastMsg': 'Welcome to PhysioVerse! Need help with your routine?',
      'time': '01 Aug',
      'unread': 0,
      'isDoctor': false,
    },
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PatientTheme.pageBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: PatientTheme.textDark),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: PatientTheme.textDark),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
            child: TextField(
              controller: _searchCtrl,
              style: const TextStyle(fontSize: 13, color: PatientTheme.textDark),
              decoration: InputDecoration(
                hintText: 'Search messages',
                hintStyle: const TextStyle(color: PatientTheme.textMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: PatientTheme.textSecondary, size: 20),
                filled: true,
                fillColor: PatientTheme.inputBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PatientTheme.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PatientTheme.border),
                ),
              ),
            ),
          ),

          // Conversation List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _conversations.length,
              itemBuilder: (context, index) {
                final item = _conversations[index];
                final unreadCount = item['unread'] as int;

                return PatientCard(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PatientChatScreen(doctorName: item['name'] as String),
                      ),
                    );
                  },
                  child: Row(
                    children: [
                      // Avatar
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: (item['isDoctor'] as bool)
                            ? PatientTheme.primaryTealLight
                            : PatientTheme.infoBlueBg,
                        child: Icon(
                          (item['isDoctor'] as bool) ? Icons.medical_services_rounded : Icons.local_hospital_rounded,
                          color: (item['isDoctor'] as bool) ? PatientTheme.primaryTeal : PatientTheme.infoBlue,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),

                      // Message details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['name'] as String,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: PatientTheme.textDark,
                                  ),
                                ),
                                Text(
                                  item['time'] as String,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: PatientTheme.textMuted,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    item['lastMsg'] as String,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.normal,
                                      color: unreadCount > 0 ? PatientTheme.textDark : PatientTheme.textSecondary,
                                    ),
                                  ),
                                ),
                                if (unreadCount > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                    decoration: const BoxDecoration(
                                      color: PatientTheme.primaryTeal,
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '$unreadCount',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
