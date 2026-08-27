import 'package:flutter/material.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';
import 'physio_chat_screen.dart';

const Color _shellCyan = Color(0xFF00AFC1);
const Color _shellLightCyan = Color(0xFFE8F9FB);
const Color _shellText = Color(0xFF123047);
const Color _shellMuted = Color(0xFF64748B);
const Color _shellBg = Color(0xFFF7FAFC);
const Color _shellBorder = Color(0xFFE2E8F0);

class PhysioMessagesScreen extends StatefulWidget {
  const PhysioMessagesScreen({super.key});

  @override
  State<PhysioMessagesScreen> createState() => _PhysioMessagesScreenState();
}

class _PhysioMessagesScreenState extends State<PhysioMessagesScreen> {
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
            c.patientName.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            c.lastMessageContent.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredConversations;

    return Scaffold(
      backgroundColor: _shellBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _shellText),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Patient Messages',
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: _shellText),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
            child: TextField(
              controller: _searchCtrl,
              onChanged: (val) => setState(() => _searchQuery = val),
              style: const TextStyle(fontSize: 13.5, color: _shellText),
              decoration: InputDecoration(
                hintText: 'Search patients or messages...',
                hintStyle: const TextStyle(color: _shellMuted, fontSize: 13),
                prefixIcon: const Icon(Icons.search_rounded, color: _shellMuted, size: 20),
                filled: true,
                fillColor: _shellBg,
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _shellBorder),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _shellBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: _shellCyan, width: 1.5),
                ),
              ),
            ),
          ),

          // Conversation List
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchConversations,
              color: _shellCyan,
              child: _isLoading && _conversations.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(color: _shellCyan),
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
                                      color: _shellLightCyan,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Icon(
                                      Icons.chat_bubble_outline_rounded,
                                      color: _shellCyan,
                                      size: 32,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  const Text(
                                    'No Messages Yet',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w800,
                                      color: _shellText,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  const Text(
                                    'Select a patient from your patient list to start a real-time conversation.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: _shellMuted,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: filtered.length,
                          itemBuilder: (context, index) {
                            final conv = filtered[index];
                            final hasUnread = conv.unreadCount > 0;

                            return Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: hasUnread ? _shellCyan.withValues(alpha: 0.35) : _shellBorder,
                                  width: hasUnread ? 1.2 : 1.0,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.02),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) => PhysioChatScreen(
                                        conversationId: conv.id,
                                        patientId: conv.patientId,
                                        patientName: conv.patientName,
                                      ),
                                    ),
                                  );
                                  _fetchConversations();
                                },
                                leading: CircleAvatar(
                                  radius: 22,
                                  backgroundColor: _shellLightCyan,
                                  child: Text(
                                    conv.patientInitials,
                                    style: const TextStyle(
                                      color: _shellCyan,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        conv.patientName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: hasUnread ? FontWeight.w800 : FontWeight.w700,
                                          color: _shellText,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      conv.timeFormatted,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: hasUnread ? FontWeight.w700 : FontWeight.w500,
                                        color: hasUnread ? _shellCyan : _shellMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Text(
                                          conv.lastMessageContent.isEmpty
                                              ? 'Tap to start conversation'
                                              : conv.lastMessageContent,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            fontWeight: hasUnread ? FontWeight.w600 : FontWeight.normal,
                                            color: hasUnread ? _shellText : _shellMuted,
                                          ),
                                        ),
                                      ),
                                      if (hasUnread)
                                        Container(
                                          margin: const EdgeInsets.only(left: 8),
                                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: _shellCyan,
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Text(
                                            '${conv.unreadCount}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w800,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
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
