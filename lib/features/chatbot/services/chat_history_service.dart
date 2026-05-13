import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/conversation.dart';

class ChatHistoryService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  String get _uid {
    final auth = FirebaseAuth.instance;
    if (auth.currentUser == null) {
      throw Exception('User chưa đăng nhập');
    }
    return auth.currentUser!.uid;
  }

  CollectionReference get _conversationsCollection {
    return _db.collection('users').doc(_uid).collection('conversations');
  }

  DocumentReference _conversationDoc(String id) {
    return _conversationsCollection.doc(id);
  }

  CollectionReference _messagesCollection(String conversationId) {
    return _conversationDoc(conversationId).collection('messages');
  }

  /// Lấy danh sách tất cả conversations (không bao gồm messages)
  Stream<List<Conversation>> getConversations() {
    return _conversationsCollection
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Conversation(
          id: doc.id,
          title: data['title'] as String? ?? 'Đoạn chat mới',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    });
  }

  /// Lấy danh sách conversations một lần (không stream)
  Future<List<Conversation>> getConversationsOnce() async {
    try {
      final snapshot = await _conversationsCollection
          .orderBy('updatedAt', descending: true)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Conversation(
          id: doc.id,
          title: data['title'] as String? ?? 'Đoạn chat mới',
          createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
          updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        );
      }).toList();
    } catch (e) {
      print('Lỗi lấy conversations: $e');
      return [];
    }
  }

  /// Lấy danh sách conversations như một Stream (dùng trong async for)
  Stream<List<Conversation>> getConversationsStream() {
    return getConversations();
  }

  /// Tạo conversation mới
  Future<Conversation> createConversation() async {
    final now = DateTime.now();
    final conversations = await getConversationsOnce();
    final newTitle = 'Đoạn chat ${conversations.length + 1}';

    final docRef = await _conversationsCollection.add({
      'title': newTitle,
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });

    return Conversation(
      id: docRef.id,
      title: newTitle,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Xóa một conversation và tất cả messages trong đó
  Future<void> deleteConversation(String conversationId) async {
    try {
      // Xóa tất cả messages trước
      final messagesSnapshot = await _messagesCollection(conversationId).get();
      final batch = _db.batch();
      
      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }
      
      // Xóa conversation document
      batch.delete(_conversationDoc(conversationId));
      
      await batch.commit();
    } catch (e) {
      print('Lỗi xóa conversation: $e');
    }
  }

  /// Đổi tên conversation
  Future<void> renameConversation(String conversationId, String newTitle) async {
    try {
      await _conversationDoc(conversationId).update({
        'title': newTitle,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Lỗi đổi tên conversation: $e');
    }
  }

  /// Load messages của một conversation
  Stream<List<ChatMessage>> loadMessages(String conversationId) {
    return _messagesCollection(conversationId)
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatMessage(
          text: data['text'] as String? ?? '',
          isUser: data['isUser'] as bool? ?? false,
          timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
        );
      }).toList();
    });
  }

  /// Load messages một lần (không stream)
  Future<List<ChatMessage>> loadMessagesOnce(String conversationId) async {
    try {
      final snapshot = await _messagesCollection(conversationId)
          .orderBy('timestamp', descending: false)
          .get();
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return ChatMessage(
          text: data['text'] as String? ?? '',
          isUser: data['isUser'] as bool? ?? false,
          timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
        );
      }).toList();
    } catch (e) {
      print('Lỗi load messages: $e');
      return [];
    }
  }

  /// Lưu một message vào conversation
  Future<void> saveMessage(String conversationId, String text, bool isUser) async {
    try {
      await _messagesCollection(conversationId).add({
        'text': text,
        'isUser': isUser,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Cập nhật updatedAt của conversation
      await _conversationDoc(conversationId).update({
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Lỗi lưu message: $e');
    }
  }

  /// Xóa một message cụ thể
  Future<void> deleteMessage(String conversationId, String messageId) async {
    try {
      await _messagesCollection(conversationId).doc(messageId).delete();
    } catch (e) {
      print('Lỗi xóa message: $e');
    }
  }
}
