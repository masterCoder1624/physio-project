import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'dart:io';
import '../core/network/api_client.dart';
import '../core/storage/local_storage_service.dart';
import '../models/chat_model.dart';

class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final ApiClient _apiClient = ApiClient();

  WebSocket? _webSocket;
  bool _isConnected = false;
  bool get isConnected => _isConnected;

  final StreamController<ChatMessageModel> _messageStreamController =
      StreamController<ChatMessageModel>.broadcast();
  Stream<ChatMessageModel> get messageStream => _messageStreamController.stream;

  final StreamController<String> _readReceiptStreamController =
      StreamController<String>.broadcast();
  Stream<String> get readReceiptStream => _readReceiptStreamController.stream;

  List<ConversationModel> _cachedConversations = [];
  List<ConversationModel> get cachedConversations => _cachedConversations;

  int _totalUnreadCount = 0;
  int get totalUnreadCount => _totalUnreadCount;

  // ── 1. REST Methods ───────────────────────────────────────────────────────

  Future<List<ConversationModel>> getConversations({int page = 1, int size = 50}) async {
    try {
      final response = await _apiClient.get<List<ConversationModel>>(
        '/conversations',
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
        fromJson: (json) {
          if (json is List) {
            return json
                .map((e) => ConversationModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
          }
          return <ConversationModel>[];
        },
      );

      if (response.success && response.data != null) {
        _cachedConversations = response.data!;
        _totalUnreadCount = _cachedConversations.fold(0, (sum, c) => sum + c.unreadCount);
        return response.data!;
      }
    } catch (e) {
      dev.log('ChatService.getConversations error: $e');
    }
    return _cachedConversations;
  }

  Future<ConversationModel?> getOrCreateConversation(String patientId) async {
    try {
      final response = await _apiClient.post<ConversationModel>(
        '/conversations',
        body: {'patient_id': patientId},
        fromJson: (json) =>
            ConversationModel.fromJson(Map<String, dynamic>.from(json as Map)),
      );

      if (response.success && response.data != null) {
        final conv = response.data!;
        final idx = _cachedConversations.indexWhere((c) => c.id == conv.id);
        if (idx >= 0) {
          _cachedConversations[idx] = conv;
        } else {
          _cachedConversations.insert(0, conv);
        }
        return conv;
      }
    } catch (e) {
      dev.log('ChatService.getOrCreateConversation error for $patientId: $e');
    }
    return null;
  }

  Future<List<ChatMessageModel>> getMessages(
    String conversationId, {
    int page = 1,
    int size = 100,
  }) async {
    try {
      final response = await _apiClient.get<List<ChatMessageModel>>(
        '/conversations/$conversationId/messages',
        queryParameters: {
          'page': page.toString(),
          'size': size.toString(),
        },
        fromJson: (json) {
          if (json is List) {
            return json
                .map((e) => ChatMessageModel.fromJson(Map<String, dynamic>.from(e as Map)))
                .toList();
          }
          return <ChatMessageModel>[];
        },
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      dev.log('ChatService.getMessages error for $conversationId: $e');
    }
    return <ChatMessageModel>[];
  }

  Future<ChatMessageModel?> sendMessage(
    String conversationId,
    String content, {
    String messageType = 'text',
    String? mediaUrl,
  }) async {
    try {
      final response = await _apiClient.post<ChatMessageModel>(
        '/conversations/$conversationId/messages',
        body: {
          'content': content,
          'message_type': messageType,
          // ignore: use_null_aware_elements
          if (mediaUrl != null) 'media_url': mediaUrl,
        },
        fromJson: (json) =>
            ChatMessageModel.fromJson(Map<String, dynamic>.from(json as Map)),
      );

      if (response.success && response.data != null) {
        return response.data!;
      }
    } catch (e) {
      dev.log('ChatService.sendMessage error: $e');
    }
    return null;
  }

  Future<bool> markAsRead(String conversationId) async {
    try {
      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/conversations/$conversationId/read',
      );
      if (response.success) {
        final idx = _cachedConversations.indexWhere((c) => c.id == conversationId);
        if (idx >= 0) {
          final c = _cachedConversations[idx];
          _cachedConversations[idx] = ConversationModel(
            id: c.id,
            patientId: c.patientId,
            patientUserId: c.patientUserId,
            physiotherapistId: c.physiotherapistId,
            patientName: c.patientName,
            physiotherapistName: c.physiotherapistName,
            lastMessageContent: c.lastMessageContent,
            lastMessageSenderId: c.lastMessageSenderId,
            lastMessageAt: c.lastMessageAt,
            unreadCount: 0,
            createdAt: c.createdAt,
            isActive: c.isActive,
          );
        }
        return true;
      }
    } catch (e) {
      dev.log('ChatService.markAsRead error: $e');
    }
    return false;
  }

  Future<int> getUnreadCount() async {
    try {
      final response = await _apiClient.get<Map<String, dynamic>>(
        '/conversations/unread-count',
      );
      if (response.success && response.data != null) {
        _totalUnreadCount = (response.data!['unread_count'] as num?)?.toInt() ?? 0;
        return _totalUnreadCount;
      }
    } catch (e) {
      dev.log('ChatService.getUnreadCount error: $e');
    }
    return _totalUnreadCount;
  }

  // ── 2. Real-Time WebSocket Connection ────────────────────────────────────

  Future<void> connectWebSocket() async {
    if (_isConnected || _webSocket != null) return;

    try {
      final token = await LocalStorageService.getAccessToken();
      if (token == null || token.isEmpty || token.startsWith('mock_')) return;

      final baseWsUrl = _apiClient.baseUrl
          .replaceAll('https://', 'wss://')
          .replaceAll('http://', 'ws://');
      final uri = Uri.parse('$baseWsUrl/ws/chat?token=$token');

      _webSocket = await WebSocket.connect(uri.toString())
          .timeout(const Duration(seconds: 8));

      _isConnected = true;
      dev.log('WebSocket connected successfully to $uri');

      _webSocket!.listen(
        (data) {
          _handleIncomingWsData(data);
        },
        onError: (err) {
          dev.log('WebSocket error: $err');
          _disconnectInternal();
        },
        onDone: () {
          dev.log('WebSocket closed');
          _disconnectInternal();
        },
        cancelOnError: true,
      );
    } catch (e) {
      dev.log('WebSocket connection failed: $e');
      _disconnectInternal();
    }
  }

  void _handleIncomingWsData(dynamic data) {
    try {
      final decoded = jsonDecode(data.toString());
      if (decoded is Map<String, dynamic>) {
        final type = decoded['type'];
        if (type == 'new_message' && decoded.containsKey('data')) {
          final msgJson = decoded['data'];
          if (msgJson is Map) {
            final msg = ChatMessageModel.fromJson(Map<String, dynamic>.from(msgJson));
            _messageStreamController.add(msg);

            // Update conversation last message preview
            final convId = decoded['conversation_id'] ?? msg.conversationId;
            final idx = _cachedConversations.indexWhere((c) => c.id == convId);
            if (idx >= 0) {
              final c = _cachedConversations[idx];
              _cachedConversations[idx] = ConversationModel(
                id: c.id,
                patientId: c.patientId,
                patientUserId: c.patientUserId,
                physiotherapistId: c.physiotherapistId,
                patientName: c.patientName,
                physiotherapistName: c.physiotherapistName,
                lastMessageContent: msg.content,
                lastMessageSenderId: msg.senderId,
                lastMessageAt: msg.createdAt,
                unreadCount: c.unreadCount + 1,
                createdAt: c.createdAt,
                isActive: c.isActive,
              );
            }
          }
        } else if (type == 'messages_read') {
          final convId = decoded['conversation_id']?.toString() ?? '';
          _readReceiptStreamController.add(convId);
        }
      }
    } catch (e) {
      dev.log('Error parsing WS message: $e');
    }
  }

  void _disconnectInternal() {
    _isConnected = false;
    _webSocket = null;
  }

  void disconnectWebSocket() {
    try {
      _webSocket?.close();
    } catch (_) {}
    _disconnectInternal();
  }
}
