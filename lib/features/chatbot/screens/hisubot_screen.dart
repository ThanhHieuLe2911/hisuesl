import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/chat_history_service.dart';
import '../services/user_data_service.dart';
import '../models/conversation.dart';
import '../widgets/conversation_list_drawer.dart';

class HisubotScreen extends StatefulWidget {
  const HisubotScreen({super.key});

  @override
  State<HisubotScreen> createState() => _HisubotScreenState();
}

class _HisubotScreenState extends State<HisubotScreen> {
  final Gemini gemini = Gemini.instance;
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Multi-conversation state
  final ChatHistoryService _chatService = ChatHistoryService();
  final UserDataService _userService = UserDataService();
  UserData? _userData;
  
  List<Conversation> _conversations = [];
  String? _currentConversationId;
  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  // Stream subscriptions
  StreamSubscription? _conversationsSubscription;
  StreamSubscription? _messagesSubscription;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Load user data
    _userData = await _userService.getUserData();

    // Subscribe to conversations và đợi data load xong
    await for (final convs in _chatService.getConversationsStream()) {
      setState(() {
        _conversations = convs;
      });

      // Chỉ xử lý lần đầu khi có data
      if (_currentConversationId == null) {
        if (convs.isNotEmpty) {
          // Ưu tiên conversation gần nhất (updatedAt mới nhất)
          convs.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
          _selectConversation(convs.first.id, isInit: true);
        } else {
          // Không có conversation nào → tạo mới
          await _createNewConversation();
        }
      }

      setState(() {
        _isInitialized = true;
      });

      // Break sau khi xử lý lần đầu
      break;
    }
  }

  Future<void> _createNewConversation() async {
    try {
      final newConv = await _chatService.createConversation();
      setState(() {
        _conversations.insert(0, newConv);
        _currentConversationId = newConv.id;
        _messages = [];
      });
      // Load greeting cho conversation mới
      _addGreetingMessage();
    } catch (e) {
      print('Lỗi tạo conversation: $e');
    }
  }

  void _addGreetingMessage() {
    final userName = _userData?.name ?? 'bạn';
    _messages.add(ChatMessage(
      text: 'Xin chào $userName! Mình là Hisubot, gia sư tiếng Anh của bạn.\n\n'
            'Trình độ hiện tại: ${_userData?.level ?? "Chưa chọn"}\n'
            'Bạn có thể hỏi mình về ngữ pháp, từ vựng, hoặc bất cứ điều gì về tiếng Anh nhé!',
      isUser: false,
    ));
  }

  Future<void> _selectConversation(String conversationId, {bool isInit = false}) async {
    if (conversationId == _currentConversationId && !isInit) return;

    // Cancel previous subscription
    await _messagesSubscription?.cancel();

    setState(() {
      _currentConversationId = conversationId;
      _messages = [];
      _isLoading = true;
    });

    // Load messages của conversation mới
    _messagesSubscription = _chatService.loadMessages(conversationId).listen((msgs) {
      setState(() {
        _messages = msgs;
        _isLoading = false;
        if (msgs.isEmpty && !isInit) {
          _addGreetingMessage();
        }
      });
      _scrollToBottom();
    });
  }

  Future<void> _deleteConversation(String conversationId) async {
    await _chatService.deleteConversation(conversationId);

    if (_currentConversationId == conversationId) {
      if (_conversations.length > 1) {
        // Chọn conversation khác
        final otherConv = _conversations.firstWhere((c) => c.id != conversationId);
        await _selectConversation(otherConv.id);
      } else {
        // Tạo conversation mới nếu xóa hết
        await _createNewConversation();
      }
    }
  }

  Future<void> _renameConversation(String conversationId, String newTitle) async {
    await _chatService.renameConversation(conversationId, newTitle);
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty || !_isInitialized || _currentConversationId == null) return;

    final userQuestion = text; // Lưu câu hỏi để kiểm tra echo

    setState(() {
      _messages.add(ChatMessage(text: text, isUser: true));
      _messages.add(ChatMessage(text: "", isUser: false));
      _isLoading = true;
    });

    _textController.clear();
    _scrollToBottom();

    // Lưu message user vào Firestore
    _chatService.saveMessage(_currentConversationId!, text, true);

    // Tạo prompt với user context
    final systemPrompt = _userData?.buildSystemPrompt() ??
        'Bạn là Hisubot, gia sư tiếng Anh. Trả lời rõ ràng, dễ hiểu bằng tiếng Việt.';

    final fullPrompt = '$systemPrompt\n\n$text';

    // Biến để theo dõi có phải chunk đầu tiên không
    bool isFirstChunk = true;

    gemini.streamGenerateContent(fullPrompt, modelName: 'gemini-1.5-flash').listen((value) {
      final chunk = value.output ?? "";
      if (chunk.isEmpty) return;

      setState(() {
        _isLoading = false;
        if (_messages.isNotEmpty) {
          String currentText = _messages.last.text;

          // Strip echo: nếu là chunk đầu tiên và trùng với câu hỏi user
          if (isFirstChunk && currentText.isEmpty) {
            String cleanedChunk = _stripEcho(chunk, userQuestion);
            _messages.last.text += cleanedChunk;
            isFirstChunk = false;
          } else {
            _messages.last.text += chunk;
            isFirstChunk = false;
          }
        }
      });
      _scrollToBottom();
    }, onError: (e) {
      setState(() {
        _isLoading = false;
        if (_messages.isNotEmpty) {
          _messages.last.text = "Xin lỗi, Hisubot gặp lỗi khi gọi AI.\n\nChi tiết: $e";
        }
      });
      _scrollToBottom();
    }, onDone: () {
      // Strip echo cuối cùng nếu còn
      if (_messages.isNotEmpty && _messages.last.text.isNotEmpty) {
        String finalText = _messages.last.text;
        String strippedText = _stripEcho(finalText, userQuestion);
        if (strippedText != finalText) {
          setState(() {
            _messages.last.text = strippedText;
          });
        }
        _chatService.saveMessage(_currentConversationId!, _messages.last.text, false);
      }
    });
  }

  /// Strip phần echo (trùng lặp với câu hỏi user) khỏi response
  String _stripEcho(String response, String userQuestion) {
    if (response.isEmpty || userQuestion.isEmpty) return response;

    // Các pattern thường gặp khi AI echo câu hỏi
    final patterns = [
      '^${RegExp.escape(userQuestion)}[\\s:：.]*',                    // Trùng y hệt
      '^"${RegExp.escape(userQuestion)}"[\\s:：.]*',                   // Trong ngoặc kép
      '^"${RegExp.escape(userQuestion)}"\\s*',                        // Trong ngoặc kép toàn bộ
      '^"${RegExp.escape(userQuestion)}"\\n+',                         // Trong ngoặc kép + xuống dòng
      '^"${RegExp.escape(userQuestion)}"',                             // Trong ngoặc kép
      '^${RegExp.escape(userQuestion)}\\n+',                           // Trùng + xuống dòng
    ];

    for (final pattern in patterns) {
      final regex = RegExp(pattern, caseSensitive: false);
      if (regex.hasMatch(response)) {
        return response.replaceFirst(regex, '');
      }
    }

    // Kiểm tra nếu response bắt đầu với câu hỏi (không phân biệt hoa thường, có thể có dấu)
    final lowerResponse = response.toLowerCase().trim();
    final lowerQuestion = userQuestion.toLowerCase().trim();

    if (lowerResponse == lowerQuestion) {
      return response.replaceFirst(RegExp('^${RegExp.escape(userQuestion)}', caseSensitive: false), '').trimLeft();
    }

    return response;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _deleteCurrentConversation() async {
    if (_currentConversationId == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Xóa đoạn chat',
          style: GoogleFonts.dongle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc muốn xóa đoạn chat hiện tại không?',
          style: GoogleFonts.dongle(fontSize: 22),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Hủy', style: GoogleFonts.dongle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text('Xóa', style: GoogleFonts.dongle(fontSize: 20, color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await _deleteConversation(_currentConversationId!);
    }
  }

  String get _currentConversationTitle {
    if (_currentConversationId == null) return 'Hisubot Tutor';
    final conv = _conversations.firstWhere(
      (c) => c.id == _currentConversationId,
      orElse: () => Conversation(
        id: '',
        title: 'Hisubot Tutor',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
    return conv.title;
  }

  @override
  void dispose() {
    _messagesSubscription?.cancel();
    _conversationsSubscription?.cancel();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFF2F6F9),
      drawer: ConversationListDrawer(
        conversations: _conversations,
        currentConversationId: _currentConversationId,
        onCreateNew: _createNewConversation,
        onSelectConversation: _selectConversation,
        onDeleteConversation: _deleteConversation,
        onRenameConversation: _renameConversation,
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.menu_rounded, color: Colors.black87, size: 24),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.smart_toy_rounded, color: Colors.blueAccent, size: 28),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _currentConversationTitle,
                style: GoogleFonts.dongle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 28,
                  height: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black87, size: 24),
            onPressed: _createNewConversation,
            tooltip: 'Tạo đoạn chat mới',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.black87),
            onSelected: (value) {
              if (value == 'delete') {
                _deleteCurrentConversation();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete_outline, size: 20),
                    const SizedBox(width: 8),
                    Text('Xóa đoạn chat hiện tại', style: GoogleFonts.dongle(fontSize: 18)),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: Colors.grey.shade200, height: 1),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: !_isInitialized
                ? Center(
                    child: CircularProgressIndicator(
                      color: Colors.blueAccent.withOpacity(0.7),
                    ),
                  )
                : _messages.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade300),
                            const SizedBox(height: 16),
                            Text(
                              'Bắt đầu cuộc trò chuyện',
                              style: GoogleFonts.dongle(
                                fontSize: 24,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                        itemBuilder: (context, index) {
                          final msg = _messages[index];
                          return _buildMessageItem(msg);
                        },
                      ),
          ),

          if (_isLoading && (_messages.isEmpty || _messages.last.text.isNotEmpty))
            Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 10),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hisubot đang suy nghĩ...",
                  style: GoogleFonts.dongle(fontSize: 24, color: Colors.grey),
                ),
              ),
            ),

          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage msg) {
    final isUser = msg.isUser;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: const Icon(Icons.smart_toy_rounded, color: Colors.blueAccent, size: 20),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isUser ? Colors.blueAccent : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 20),
                ),
                boxShadow: [
                  if (!isUser)
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 4, offset: const Offset(0, 2)),
                ],
              ),
              child: isUser
                  ? Text(
                      msg.text,
                      style: GoogleFonts.dongle(
                        color: Colors.white,
                        fontSize: 26,
                        height: 1.1,
                      ),
                    )
                  : MarkdownBody(
                      data: msg.text,
                      styleSheet: MarkdownStyleSheet(
                        p: GoogleFonts.dongle(fontSize: 26, color: Colors.black87, height: 1.1),
                        h1: GoogleFonts.dongle(fontSize: 32, fontWeight: FontWeight.bold),
                        h2: GoogleFonts.dongle(fontSize: 30, fontWeight: FontWeight.bold),
                        h3: GoogleFonts.dongle(fontSize: 28, fontWeight: FontWeight.bold),
                        strong: GoogleFonts.dongle(fontWeight: FontWeight.bold),
                        code: GoogleFonts.robotoMono(fontSize: 14, backgroundColor: Colors.grey.shade100),
                        listBullet: GoogleFonts.dongle(fontSize: 26),
                      ),
                    ),
            ),
          ),

          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: Colors.blue.shade100,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.blueAccent, size: 20),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F7FA),
                borderRadius: BorderRadius.circular(30),
              ),
              child: TextField(
                controller: _textController,
                style: GoogleFonts.dongle(fontSize: 28, height: 1.2),
                decoration: InputDecoration(
                  hintText: 'Nhập câu hỏi...',
                  hintStyle: GoogleFonts.dongle(fontSize: 28, color: Colors.grey.shade400, height: 1.2),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.only(bottom: 8),
                ),
                enabled: _isInitialized && _currentConversationId != null,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
          ),
          const SizedBox(width: 12),
          InkWell(
            onTap: (_isInitialized && _currentConversationId != null) ? _sendMessage : null,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: (_isInitialized && _currentConversationId != null) ? Colors.blueAccent : Colors.grey,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}
