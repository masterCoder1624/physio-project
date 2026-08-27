import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/storage/local_storage_service.dart';
import '../../models/chat_model.dart';
import '../../services/chat_service.dart';

const Color _shellCyan = Color(0xFF00AFC1);
const Color _shellLightCyan = Color(0xFFE8F9FB);
const Color _shellText = Color(0xFF123047);
const Color _shellMuted = Color(0xFF64748B);
const Color _shellBg = Color(0xFFF7FAFC);
const Color _shellBorder = Color(0xFFE2E8F0);
const Color _onlineGreen = Color(0xFF10B981);

class PhysioChatScreen extends StatefulWidget {
  const PhysioChatScreen({
    super.key,
    this.conversationId,
    required this.patientId,
    required this.patientName,
  });

  final String? conversationId;
  final String patientId;
  final String patientName;

  @override
  State<PhysioChatScreen> createState() => _PhysioChatScreenState();
}

class _PhysioChatScreenState extends State<PhysioChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _msgCtrl = TextEditingController();
  final ScrollController _scrollCtrl = ScrollController();

  String? _conversationId;
  String? _currentUserId;
  List<ChatMessageModel> _messages = [];
  bool _isLoading = true;
  StreamSubscription<ChatMessageModel>? _messageSub;
  StreamSubscription<String>? _readReceiptSub;

  @override
  void initState() {
    super.initState();
    _conversationId = widget.conversationId;
    _initChat();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _scrollCtrl.dispose();
    _messageSub?.cancel();
    _readReceiptSub?.cancel();
    super.dispose();
  }

  Future<void> _initChat() async {
    _currentUserId = await LocalStorageService.getUserId();
    await _chatService.connectWebSocket();

    if (_conversationId == null || _conversationId!.isEmpty) {
      final conv = await _chatService.getOrCreateConversation(widget.patientId);
      if (conv != null) {
        _conversationId = conv.id;
      }
    }

    if (_conversationId != null) {
      await _loadMessages();
      _chatService.markAsRead(_conversationId!);
    } else {
      if (mounted) setState(() => _isLoading = false);
    }

    _listenWebSocket();
  }

  void _listenWebSocket() {
    _messageSub = _chatService.messageStream.listen((msg) {
      if (msg.conversationId == _conversationId) {
        if (!mounted) return;
        setState(() {
          if (!_messages.any((m) => m.id == msg.id)) {
            _messages.add(msg);
          }
        });
        _scrollToBottom();
        if (msg.senderId != _currentUserId && _conversationId != null) {
          _chatService.markAsRead(_conversationId!);
        }
      }
    });

    _readReceiptSub = _chatService.readReceiptStream.listen((convId) {
      if (convId == _conversationId && mounted) {
        setState(() {
          for (var i = 0; i < _messages.length; i++) {
            if (_messages[i].senderId == _currentUserId) {
              _messages[i] = ChatMessageModel(
                id: _messages[i].id,
                conversationId: _messages[i].conversationId,
                senderId: _messages[i].senderId,
                senderRole: _messages[i].senderRole,
                senderName: _messages[i].senderName,
                recipientId: _messages[i].recipientId,
                content: _messages[i].content,
                messageType: _messages[i].messageType,
                mediaUrl: _messages[i].mediaUrl,
                isRead: true,
                readAt: DateTime.now(),
                createdAt: _messages[i].createdAt,
              );
            }
          }
        });
      }
    });
  }

  Future<void> _loadMessages() async {
    if (_conversationId == null) return;
    try {
      final msgs = await _chatService.getMessages(_conversationId!);
      if (!mounted) return;
      setState(() {
        _messages = msgs;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollCtrl.hasClients) {
        _scrollCtrl.animateTo(
          _scrollCtrl.position.maxScrollExtent + 60,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _sendMessage() async {
    final text = _msgCtrl.text.trim();
    if (text.isEmpty || _conversationId == null) return;

    _msgCtrl.clear();

    // Optimistic message
    final tempMsg = ChatMessageModel(
      id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
      conversationId: _conversationId!,
      senderId: _currentUserId ?? 'physio',
      senderRole: 'physiotherapist',
      senderName: 'You',
      recipientId: widget.patientId,
      content: text,
      isRead: false,
      createdAt: DateTime.now(),
    );

    setState(() => _messages.add(tempMsg));
    _scrollToBottom();

    final sent = await _chatService.sendMessage(_conversationId!, text);
    if (sent != null && mounted) {
      setState(() {
        final idx = _messages.indexWhere((m) => m.id == tempMsg.id);
        if (idx >= 0) {
          _messages[idx] = sent;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final initials = widget.patientName.trim().split(RegExp(r'\s+')).take(2).map((e) => e.isNotEmpty ? e[0].toUpperCase() : '').join();

    return Scaffold(
      backgroundColor: _shellBg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: _shellText),
          onPressed: () => Navigator.of(context).pop(),
        ),
        titleSpacing: 0,
        title: Row(
          children: [
            CircleAvatar(
              radius: 19,
              backgroundColor: _shellLightCyan,
              child: Text(
                initials.isEmpty ? 'PT' : initials,
                style: const TextStyle(
                  color: _shellCyan,
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.patientName,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: _shellText),
                ),
                Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: const BoxDecoration(
                        color: _onlineGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 5),
                    const Text(
                      'Active Patient',
                      style: TextStyle(fontSize: 11, color: _onlineGreen, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // Message List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: _shellCyan))
                : _messages.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: _shellLightCyan,
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: const Icon(Icons.chat_bubble_outline_rounded, color: _shellCyan, size: 28),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Start the Conversation',
                              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: _shellText),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Send a message to ${widget.patientName}',
                              style: const TextStyle(fontSize: 12, color: _shellMuted),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollCtrl,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          final isMe = msg.senderRole == 'physiotherapist' || msg.senderId == _currentUserId;

                          return Align(
                            alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              constraints: BoxConstraints(
                                maxWidth: MediaQuery.of(context).size.width * 0.76,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                color: isMe ? _shellCyan : Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: const Radius.circular(16),
                                  topRight: const Radius.circular(16),
                                  bottomLeft: Radius.circular(isMe ? 16 : 4),
                                  bottomRight: Radius.circular(isMe ? 4 : 16),
                                ),
                                border: isMe ? null : Border.all(color: _shellBorder),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.03),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    msg.content,
                                    style: TextStyle(
                                      color: isMe ? Colors.white : _shellText,
                                      fontSize: 13.5,
                                      height: 1.35,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        msg.timeFormatted,
                                        style: TextStyle(
                                          color: isMe ? Colors.white.withValues(alpha: 0.75) : _shellMuted,
                                          fontSize: 10,
                                        ),
                                      ),
                                      if (isMe) ...[
                                        const SizedBox(width: 4),
                                        Icon(
                                          msg.isRead ? Icons.done_all_rounded : Icons.done_rounded,
                                          size: 13,
                                          color: msg.isRead ? Colors.white : Colors.white.withValues(alpha: 0.7),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),

          // Input Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: _shellBorder)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: _shellBg,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _shellBorder),
                      ),
                      child: TextField(
                        controller: _msgCtrl,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: 4,
                        minLines: 1,
                        style: const TextStyle(fontSize: 13.5, color: _shellText),
                        decoration: const InputDecoration(
                          hintText: 'Type message...',
                          hintStyle: TextStyle(color: _shellMuted, fontSize: 13),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: _shellCyan,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white, size: 18),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
