class ConversationModel {
  final String id;
  final String patientId;
  final String patientUserId;
  final String physiotherapistId;
  final String patientName;
  final String physiotherapistName;
  final String lastMessageContent;
  final String lastMessageSenderId;
  final DateTime lastMessageAt;
  final int unreadCount;
  final DateTime createdAt;
  final bool isActive;

  ConversationModel({
    required this.id,
    required this.patientId,
    required this.patientUserId,
    required this.physiotherapistId,
    required this.patientName,
    required this.physiotherapistName,
    this.lastMessageContent = '',
    this.lastMessageSenderId = '',
    DateTime? lastMessageAt,
    this.unreadCount = 0,
    DateTime? createdAt,
    this.isActive = true,
  })  : lastMessageAt = lastMessageAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  String get timeFormatted {
    final now = DateTime.now();
    final diff = now.difference(lastMessageAt);

    if (diff.inMinutes < 1) {
      return 'Just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      final hour = lastMessageAt.hour > 12
          ? lastMessageAt.hour - 12
          : (lastMessageAt.hour == 0 ? 12 : lastMessageAt.hour);
      final minute = lastMessageAt.minute.toString().padLeft(2, '0');
      final amPm = lastMessageAt.hour >= 12 ? 'PM' : 'AM';
      return '$hour:$minute $amPm';
    } else if (diff.inDays == 1) {
      return 'Yesterday';
    } else {
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${lastMessageAt.day} ${months[lastMessageAt.month - 1]}';
    }
  }

  String get patientInitials {
    final parts = patientName.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts[0].isEmpty) return 'PT';
    if (parts.length == 1) return parts[0].substring(0, 1).toUpperCase();
    return (parts[0][0] + parts[1][0]).toUpperCase();
  }

  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d == null) return DateTime.now();
      try {
        return DateTime.parse(d.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return ConversationModel(
      id: json['id']?.toString() ?? '',
      patientId: json['patient_id']?.toString() ?? '',
      patientUserId: json['patient_user_id']?.toString() ?? '',
      physiotherapistId: json['physiotherapist_id']?.toString() ?? '',
      patientName: json['patient_name']?.toString() ?? 'Patient',
      physiotherapistName: json['physiotherapist_name']?.toString() ?? 'Physiotherapist',
      lastMessageContent: json['last_message_content']?.toString() ?? '',
      lastMessageSenderId: json['last_message_sender_id']?.toString() ?? '',
      lastMessageAt: parseDate(json['last_message_at']),
      unreadCount: (json['unread_count'] as num?)?.toInt() ?? 0,
      createdAt: parseDate(json['created_at']),
      isActive: json['is_active'] != false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'patient_id': patientId,
        'patient_user_id': patientUserId,
        'physiotherapist_id': physiotherapistId,
        'patient_name': patientName,
        'physiotherapist_name': physiotherapistName,
        'last_message_content': lastMessageContent,
        'last_message_sender_id': lastMessageSenderId,
        'last_message_at': lastMessageAt.toIso8601String(),
        'unread_count': unreadCount,
        'created_at': createdAt.toIso8601String(),
        'is_active': isActive,
      };
}

class ChatMessageModel {
  final String id;
  final String conversationId;
  final String senderId;
  final String senderRole;
  final String senderName;
  final String recipientId;
  final String content;
  final String messageType;
  final String? mediaUrl;
  final bool isRead;
  final DateTime? readAt;
  final DateTime createdAt;

  ChatMessageModel({
    required this.id,
    required this.conversationId,
    required this.senderId,
    required this.senderRole,
    required this.senderName,
    required this.recipientId,
    required this.content,
    this.messageType = 'text',
    this.mediaUrl,
    this.isRead = false,
    this.readAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  String get timeFormatted {
    final hour = createdAt.hour > 12
        ? createdAt.hour - 12
        : (createdAt.hour == 0 ? 12 : createdAt.hour);
    final minute = createdAt.minute.toString().padLeft(2, '0');
    final amPm = createdAt.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $amPm';
  }

  bool isSentBy(String userId) => senderId == userId;

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    DateTime parseDate(dynamic d) {
      if (d == null) return DateTime.now();
      try {
        return DateTime.parse(d.toString());
      } catch (_) {
        return DateTime.now();
      }
    }

    return ChatMessageModel(
      id: json['id']?.toString() ?? '',
      conversationId: json['conversation_id']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderRole: json['sender_role']?.toString() ?? 'patient',
      senderName: json['sender_name']?.toString() ?? '',
      recipientId: json['recipient_id']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      messageType: json['message_type']?.toString() ?? 'text',
      mediaUrl: json['media_url']?.toString(),
      isRead: json['is_read'] == true,
      readAt: json['read_at'] != null ? parseDate(json['read_at']) : null,
      createdAt: parseDate(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversation_id': conversationId,
        'sender_id': senderId,
        'sender_role': senderRole,
        'sender_name': senderName,
        'recipient_id': recipientId,
        'content': content,
        'message_type': messageType,
        'media_url': mediaUrl,
        'is_read': isRead,
        'read_at': readAt?.toIso8601String(),
        'created_at': createdAt.toIso8601String(),
      };
}
