import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/session.dart';

/// Chat screen (text-based alternative to voice calls)
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [
    _ChatMessage(
      text: 'Hello! I\'m Mindy. How can I support you today?',
      isMindy: true,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(_ChatMessage(
        text: text,
        isMindy: false,
        timestamp: DateTime.now(),
      ));
      // Simulate Mindy's response
      _messages.add(_ChatMessage(
        text: 'Thank you for sharing that. Tell me more about what\'s on your mind.',
        isMindy: true,
        timestamp: DateTime.now(),
      ));
    });

    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.self_improvement,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
            const Text('Mindy'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Disclaimer banner
          Container(
            margin: const EdgeInsets.all(AppTheme.spacingM),
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.info.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.info, size: 18),
                const SizedBox(width: AppTheme.spacingS),
                Expanded(
                  child: Text(
                    'For serious concerns, please use voice call or contact a professional.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.info,
                        ),
                  ),
                ),
              ],
            ),
          ),

          // Messages
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingM),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(context, message);
              },
            ),
          ),

          // Input
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingM),
            decoration: BoxDecoration(
              color: AppTheme.surfaceWhite,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusCircular),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: AppTheme.backgroundLight,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingM,
                          vertical: AppTheme.spacingS,
                        ),
                      ),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingS),
                  Container(
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
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

  Widget _buildMessageBubble(BuildContext context, _ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingS),
      child: Row(
        mainAxisAlignment:
            message.isMindy ? MainAxisAlignment.start : MainAxisAlignment.end,
        children: [
          if (message.isMindy) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.self_improvement,
                color: Colors.white,
                size: 12,
              ),
            ),
            const SizedBox(width: AppTheme.spacingS),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingM),
              decoration: BoxDecoration(
                color: message.isMindy
                    ? AppTheme.primaryTeal.withOpacity(0.1)
                    : AppTheme.primaryTeal,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(AppTheme.radiusLarge),
                  topRight: const Radius.circular(AppTheme.radiusLarge),
                  bottomLeft: Radius.circular(
                      message.isMindy ? 0 : AppTheme.radiusLarge),
                  bottomRight: Radius.circular(
                      message.isMindy ? AppTheme.radiusLarge : 0),
                ),
              ),
              child: Text(
                message.text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: message.isMindy
                          ? AppTheme.textPrimary
                          : Colors.white,
                    ),
              ),
            ),
          ),
          if (!message.isMindy) ...[
            const SizedBox(width: AppTheme.spacingS),
            CircleAvatar(
              radius: 14,
              backgroundColor: AppTheme.textMuted.withOpacity(0.2),
              child: const Icon(Icons.person, size: 14, color: AppTheme.textMuted),
            ),
          ],
        ],
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isMindy;
  final DateTime timestamp;

  _ChatMessage({
    required this.text,
    required this.isMindy,
    required this.timestamp,
  });
}
