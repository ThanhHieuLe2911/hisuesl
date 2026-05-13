import 'package:cloud_firestore/cloud_firestore.dart';

class Conversation {
  final String id;
  String title;
  final DateTime createdAt;
  DateTime updatedAt;
  List<ChatMessage> messages;

  Conversation({
    required this.id,
    required this.title,
    required this.createdAt,
    required this.updatedAt,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  factory Conversation.fromFirestore(String id, Map<String, dynamic> data) {
    final messagesData = data['messages'] as List<dynamic>? ?? [];
    return Conversation(
      id: id,
      title: data['title'] as String? ?? 'Đoạn chat mới',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      messages: messagesData.map((m) => ChatMessage.fromMap(m as Map<String, dynamic>)).toList(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }
}

class ChatMessage {
  String text;
  final bool isUser;
  final DateTime? timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    this.timestamp,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      text: map['text'] as String? ?? '',
      isUser: map['isUser'] as bool? ?? false,
      timestamp: (map['timestamp'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp != null ? Timestamp.fromDate(timestamp!) : FieldValue.serverTimestamp(),
    };
  }
}
