import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/glass_scaffold.dart';
import '../../core/widgets/glass_app_bar.dart';

class CounselorChatScreen extends StatefulWidget {
  final String studentName;
  final String studentId;

  const CounselorChatScreen({
    super.key,
    required this.studentName,
    required this.studentId,
  });

  @override
  State<CounselorChatScreen> createState() => _CounselorChatScreenState();
}

class _CounselorChatScreenState extends State<CounselorChatScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    // Load mock conversation history
    _messages.addAll([
      _ChatMessage(
        text: 'Hello! I wanted to discuss my career options.',
        isMe: false,
        time: DateTime.now().subtract(const Duration(days: 1, hours: 3)),
      ),
      _ChatMessage(
        text:
            'Hi ${widget.studentName.split(' ').first}! Sure, I\'d love to help. What areas are you interested in?',
        isMe: true,
        time: DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 50)),
      ),
      _ChatMessage(
        text:
            'I\'m considering engineering but also interested in design. Not sure which path suits me better.',
        isMe: false,
        time: DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 40)),
      ),
      _ChatMessage(
        text:
            'That\'s a great combination! Your test results show strong analytical and creative skills. Let\'s explore options that blend both.',
        isMe: true,
        time: DateTime.now().subtract(const Duration(days: 1, hours: 2, minutes: 30)),
      ),
    ]);
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isMe: true,
        time: DateTime.now(),
      ));
      _messageController.clear();
    });

    // Scroll to bottom
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

  String _formatTime(DateTime date) {
    final hour = date.hour > 12
        ? date.hour - 12
        : date.hour == 0
            ? 12
            : date.hour;
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:${date.minute.toString().padLeft(2, '0')} $period';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GlassScaffold(
      appBar: GlassAppBar(
        title: widget.studentName,
        actions: [
          IconButton(
            icon: Icon(Icons.call_rounded,
                color: isDark ? AppColors.successBright : AppColors.success),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${widget.studentName}...')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final showDate = index == 0 ||
                    _messages[index - 1].time.day != msg.time.day;

                return Column(
                  children: [
                    if (showDate)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          _formatDateLabel(msg.time),
                          style: GoogleFonts.dmSans(
                            fontSize: 12,
                            color: isDark
                                ? AppColors.textSecondaryDark
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    _buildMessageBubble(msg, isDark),
                  ],
                );
              },
            ),
          ),
          // Input bar
          Container(
            padding: EdgeInsets.only(
              left: 16,
              right: 8,
              top: 10,
              bottom: MediaQuery.of(context).padding.bottom + 10,
            ),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF1A1A2E).withValues(alpha: 0.95)
                  : Colors.white.withValues(alpha: 0.95),
              border: Border(
                top: BorderSide(
                  color: (isDark ? Colors.white : Colors.black)
                      .withValues(alpha: 0.08),
                ),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    style: GoogleFonts.dmSans(
                      fontSize: 14,
                      color: isDark
                          ? AppColors.textPrimaryDark
                          : AppColors.textPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      hintStyle: GoogleFonts.dmSans(
                        fontSize: 14,
                        color: isDark
                            ? AppColors.textSecondaryDark
                            : AppColors.textSecondary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: isDark
                          ? Colors.white.withValues(alpha: 0.06)
                          : Colors.grey.withValues(alpha: 0.1),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _sendMessage,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      gradient: isDark
                          ? AppColors.buttonGradientDark
                          : AppColors.buttonGradient,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.send_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(_ChatMessage msg, bool isDark) {
    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          bottom: 8,
          left: msg.isMe ? 48 : 0,
          right: msg.isMe ? 0 : 48,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: msg.isMe
              ? (isDark ? AppColors.primaryBright : AppColors.primary)
              : (isDark
                  ? Colors.white.withValues(alpha: 0.08)
                  : Colors.grey.withValues(alpha: 0.12)),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isMe ? 16 : 4),
            bottomRight: Radius.circular(msg.isMe ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              msg.text,
              style: GoogleFonts.dmSans(
                fontSize: 14,
                color: msg.isMe
                    ? Colors.white
                    : (isDark
                        ? AppColors.textPrimaryDark
                        : AppColors.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _formatTime(msg.time),
              style: GoogleFonts.dmSans(
                fontSize: 10,
                color: msg.isMe
                    ? Colors.white.withValues(alpha: 0.7)
                    : (isDark
                        ? AppColors.textSecondaryDark
                        : AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateLabel(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Today';
    if (diff.inDays == 1) return 'Yesterday';
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _ChatMessage {
  final String text;
  final bool isMe;
  final DateTime time;

  _ChatMessage({
    required this.text,
    required this.isMe,
    required this.time,
  });
}
