import 'package:flutter/material.dart';
import '../../constants/patient_theme.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import 'patient_chat_screen.dart';
import 'patient_components.dart';

/// Screen 17 — Messages Conversation List Screen (matching media_1787385006975.jpg)
class PatientMessagesScreen extends StatefulWidget {
  const PatientMessagesScreen({super.key});

  @override
  State<PatientMessagesScreen> createState() => _PatientMessagesScreenState();
}

class _PatientMessagesScreenState extends State<PatientMessagesScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchCtrl = TextEditingController();
  List<ConversationModel> _conversations = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _conversations = _chatService.cachedConversations;
    _fetchConversations();
    _chatService.connectWebSocket();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchConversations() async {
    setState(() => _isLoading = true);
    try {
      final convs = await _chatService.getConversations();
      if (!mounted) return;
      setState(() {
        _conversations = convs;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<ConversationModel> get _filteredConversations {
    if (_searchQuery.trim().isEmpty) return _conversations;
    return _conversations
        .where((c) =>
            c.physiotherapistName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.lastMessageContent.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConversations;

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
              onChanged: (val) => setState(() => _searchQuery = val),
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
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: PatientTheme.primaryTeal, width: 1.5),
                ),
              ),
            ),
          ),

          // Conversation List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchConversations,
              color: PatientTheme.primaryTeal,
              child: _isLoading && _conversations.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: PatientTheme.primaryTeal),
                    )
                  : filtered.isEmpty
                      ? ListView(
                          padding: const EdgeInsets.all(30),
                          children: [
                            const SizedBox(height: 60),
                            Center(
                              child: Column(
                                children: [
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: PatientTheme.primaryTealLight,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      color: PatientTheme.primaryTeal,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Messages Yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: PatientTheme.textDark,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Conversations with your assigned physiotherapist will appear here.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: PatientTheme.textMuted,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(20),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final item = filtered[index];
                            final unreadCount = item.unreadCount;

                            return PatientCard(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => PatientChatScreen(
                                      conversationId: item.id,
                                      doctorName: item.physiotherapistName,
                                    ),
                                  ),
                                );
                                _fetchConversations();
                              },
                              child: Row(
                                children: [
                                  // Avatar
                                  CircleAvatar(
                                    radius: 22,
                                    backgroundColor: PatientTheme.primaryTealLight,
                                    child: const Icon(
                                      Icons.medical_services_rounded,
                                      color: PatientTheme.primaryTeal,
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
                                            Expanded(
                                              child: Text(
                                                item.physiotherapistName,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                  color: PatientTheme.textDark,
                                                ),
                                              ),
                                            ),
                                            Text(
                                              item.timeFormatted,
                                              style: TextStyle(
                                                fontSize: 11,
                                                color: unreadCount > 0
                                                    ? PatientTheme.primaryTeal
                                                    : PatientTheme.textMuted,
                                                fontWeight: unreadCount > 0
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(
                                                item.lastMessageContent.isEmpty
                                                    ? 'Conversation started'
                                                    : item.lastMessageContent,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontSize: 12.5,
                                                  color: unreadCount > 0
                                                      ? PatientTheme.textDark
                                                      : PatientTheme.textSecondary,
                                                  fontWeight: unreadCount > 0
                                                      ? FontWeight.w600
                                                      : FontWeight.normal,
                                                ),
                                              ),
                                            ),
                                            if (unreadCount > 0)
                                              Container(
                                                margin: const EdgeInsets.only(left: 8),
                                                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                                decoration: BoxDecoration(
                                                  color: PatientTheme.primaryTeal,
                                                  borderRadius: BorderRadius.circular(10),
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
          ),
        ],
      ),
    );
  }
}
