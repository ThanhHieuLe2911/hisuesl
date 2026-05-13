import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/conversation.dart';

class ConversationListDrawer extends StatelessWidget {
  final List<Conversation> conversations;
  final String? currentConversationId;
  final VoidCallback onCreateNew;
  final Function(String) onSelectConversation;
  final Function(String) onDeleteConversation;
  final Function(String, String) onRenameConversation;

  const ConversationListDrawer({
    super.key,
    required this.conversations,
    required this.currentConversationId,
    required this.onCreateNew,
    required this.onSelectConversation,
    required this.onDeleteConversation,
    required this.onRenameConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.1),
                border: Border(
                  bottom: BorderSide(color: Colors.grey.shade200),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.chat_bubble_outline, color: Colors.blueAccent, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Đoạn chat',
                      style: GoogleFonts.dongle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: onCreateNew,
                    icon: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 20),
                    ),
                    tooltip: 'Tạo đoạn chat mới',
                  ),
                ],
              ),
            ),

            // Conversation list
            Expanded(
              child: conversations.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.chat_outlined, size: 64, color: Colors.grey.shade300),
                          const SizedBox(height: 16),
                          Text(
                            'Chưa có đoạn chat nào',
                            style: GoogleFonts.dongle(
                              fontSize: 22,
                              color: Colors.grey.shade500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Nhấn + để tạo mới',
                            style: GoogleFonts.dongle(
                              fontSize: 18,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      itemCount: conversations.length,
                      itemBuilder: (context, index) {
                        final conv = conversations[index];
                        final isSelected = conv.id == currentConversationId;
                        return _ConversationTile(
                          conversation: conv,
                          isSelected: isSelected,
                          onTap: () {
                            onSelectConversation(conv.id);
                            Navigator.pop(context);
                          },
                          onDelete: () => _showDeleteDialog(context, conv),
                          onRename: () => _showRenameDialog(context, conv),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Conversation conv) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Xóa đoạn chat',
          style: GoogleFonts.dongle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Bạn có chắc muốn xóa "${conv.title}" không?\nHành động này không thể hoàn tác.',
          style: GoogleFonts.dongle(fontSize: 22),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: GoogleFonts.dongle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              onDeleteConversation(conv.id);
            },
            child: Text(
              'Xóa',
              style: GoogleFonts.dongle(fontSize: 20, color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, Conversation conv) {
    final controller = TextEditingController(text: conv.title);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Đổi tên đoạn chat',
          style: GoogleFonts.dongle(fontSize: 28, fontWeight: FontWeight.bold),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: GoogleFonts.dongle(fontSize: 22),
          decoration: InputDecoration(
            hintText: 'Nhập tên mới',
            hintStyle: GoogleFonts.dongle(fontSize: 22, color: Colors.grey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Hủy', style: GoogleFonts.dongle(fontSize: 20)),
          ),
          TextButton(
            onPressed: () {
              final newTitle = controller.text.trim();
              if (newTitle.isNotEmpty) {
                Navigator.pop(ctx);
                onRenameConversation(conv.id, newTitle);
              }
            },
            child: Text(
              'Lưu',
              style: GoogleFonts.dongle(fontSize: 20, color: Colors.blueAccent),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final VoidCallback onRename;

  const _ConversationTile({
    required this.conversation,
    required this.isSelected,
    required this.onTap,
    required this.onDelete,
    required this.onRename,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? Colors.blueAccent.withOpacity(0.1) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            border: Border(
              left: BorderSide(
                color: isSelected ? Colors.blueAccent : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                size: 20,
                color: isSelected ? Colors.blueAccent : Colors.grey.shade600,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      conversation.title,
                      style: GoogleFonts.dongle(
                        fontSize: 22,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.blueAccent : Colors.black87,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      _formatDate(conversation.updatedAt),
                      style: GoogleFonts.dongle(
                        fontSize: 16,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                icon: Icon(
                  Icons.more_vert,
                  size: 20,
                  color: Colors.grey.shade500,
                ),
                onSelected: (value) {
                  if (value == 'rename') {
                    onRename();
                  } else if (value == 'delete') {
                    onDelete();
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'rename',
                    child: Row(
                      children: [
                        const Icon(Icons.edit_outlined, size: 18),
                        const SizedBox(width: 8),
                        Text('Đổi tên', style: GoogleFonts.dongle(fontSize: 18)),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(Icons.delete_outline, size: 18, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Xóa',
                          style: GoogleFonts.dongle(fontSize: 18, color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inDays < 1) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
