import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';
import '../models/message_model.dart';
import '../services/crisis_service.dart';

class ChatScreen extends StatefulWidget {
  final UserModel user;

  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final CrisisDetectionService _crisisService = CrisisDetectionService();
  
  final List<MessageModel> _messages = [];
  bool _showCrisisAlert = false;
  CrisisResponse? _currentCrisisResponse;

  @override
  void initState() {
    super.initState();
    _addSystemMessage('Welcome! I am Mindy, your wellness companion. How are you feeling today?');
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

    // Add user message
    final userMessage = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      isFromUser: true,
    );
    setState(() => _messages.add(userMessage));
    _messageController.clear();

    // Check for crisis
    final crisisResult = _crisisService.analyze(text);
    
    if (crisisResult.requiresEscalation) {
      setState(() {
        _showCrisisAlert = true;
        _currentCrisisResponse = _crisisService.getCrisisResponse(crisisResult);
      });
    }

    // Simulate Mindy's response
    _generateResponse(text, crisisResult);

    // Scroll to bottom
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  void _generateResponse(String userText, CrisisResult crisisResult) {
    String response;
    
    if (crisisResult.requiresEscalation && _currentCrisisResponse != null) {
      response = _currentCrisisResponse!.message;
    } else {
      // Simple response generator based on keywords
      final lowerText = userText.toLowerCase();
      
      if (lowerText.contains('anxious') || lowerText.contains('anxiety') || lowerText.contains('worried')) {
        response = "I hear that you're feeling anxious. That's completely valid. Let's take a moment together. Can you try taking three slow, deep breaths with me? Remember, anxiety is temporary and you're equipped to handle it.";
      } else if (lowerText.contains('sad') || lowerText.contains('depressed') || lowerText.contains('down')) {
        response = "I'm sorry you're feeling down. It takes strength to share how you feel. Remember, it's okay to not be okay sometimes. What do you think might help you feel a little better right now?";
      } else if (lowerText.contains('stressed') || lowerText.contains('overwhelmed')) {
        response = "Stress can feel overwhelming. Let's break it down together. What's the one thing that's feeling most pressing right now? We can work through it step by step.";
      } else if (lowerText.contains('angry') || lowerText.contains('frustrated') || lowerText.contains('mad')) {
        response = "It's okay to feel angry - it's a natural emotion. Anger often tells us something important. What do you think triggered these feelings?";
      } else if (lowerText.contains('thank')) {
        response = "You're welcome! I'm here whenever you need me. Remember, taking care of your mental health is a sign of strength.";
      } else if (lowerText.contains('help')) {
        response = "I'm here to support you. While I'm not a replacement for professional help, I'm happy to chat and share some wellness strategies. What specific area would you like to focus on?";
      } else if (lowerText.contains('sleep') || lowerText.contains('tired') || lowerText.contains('insomnia')) {
        response = "Sleep is so important for our wellbeing. Have you tried establishing a calming bedtime routine? Maybe some gentle stretching or reading before bed? What's usually on your mind when you can't sleep?";
      } else {
        response = _getContextualResponse(lowerText);
      }
    }

    _addMindyMessage(response);
  }

  String _getContextualResponse(String text) {
    // Check user preferences and provide tailored response
    switch (widget.user.communicationStyle) {
      case CommunicationStyle.direct:
        return "Thanks for sharing. Here's what stands out to me: ${_extractKeyPoint(text)}. What would you like to focus on?";
      case CommunicationStyle.gentle:
        return "Thank you for telling me that. I appreciate you sharing this with me. Take all the time you need. Would you like to explore this further together?";
      case CommunicationStyle.balanced:
        return "I hear you. Based on what you've shared, ${_extractKeyPoint(text)}. Let's explore some options together if you'd like.";
    }
  }

  String _extractKeyPoint(String text) {
    if (text.length < 50) return "that sounds challenging";
    if (text.contains('work')) return "work seems to be on your mind";
    if (text.contains('family') || text.contains('parent') || text.contains('mom') || text.contains('dad')) {
      return "family matters are weighing on you";
    }
    if (text.contains('friend') || text.contains('relationship')) return "your relationships are important to you";
    if (text.contains('school') || text.contains('exam') || text.contains('study')) return "academic life is stressful right now";
    return "this situation matters to you";
  }

  void _addMindyMessage(String content) {
    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromUser: false,
    );
    setState(() => _messages.add(message));
  }

  void _addSystemMessage(String content) {
    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: content,
      isFromUser: false,
      type: MessageType.system,
    );
    setState(() => _messages.add(message));
  }

  void _dismissCrisisAlert() {
    setState(() {
      _showCrisisAlert = false;
      _currentCrisisResponse = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.psychology, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            const Text('Mindy'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showDisclaimer(),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Column(
          children: [
            // Crisis alert banner
            if (_showCrisisAlert && _currentCrisisResponse != null)
              _buildCrisisAlertBanner(),

            // Messages
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(_messages[index]);
                },
              ),
            ),

            // Input area
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildCrisisAlertBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: AppColors.crisis.withValues(alpha: 0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning, color: AppColors.crisis),
              const SizedBox(width: 8),
              const Text(
                'Support Available',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.crisis,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: _dismissCrisisAlert,
                color: AppColors.textMuted,
              ),
            ],
          ),
          if (_currentCrisisResponse!.resources.isNotEmpty) ...[
            const SizedBox(height: 12),
            ..._currentCrisisResponse!.resources.map((resource) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: AppColors.crisis, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(resource.name, style: const TextStyle(fontWeight: FontWeight.w500)),
                          if (resource.phone != null)
                            Text(resource.phone!, style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
                          if (resource.website != null)
                            Text(resource.website!, style: const TextStyle(color: AppColors.primary, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(MessageModel message) {
    final isUser = message.isFromUser;
    final isSystem = message.type == MessageType.system;

    if (isSystem) {
      return Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          message.content,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: isUser ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isUser ? 16 : 4),
            bottomRight: Radius.circular(isUser ? 4 : 16),
          ),
        ),
        child: Text(
          message.content,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                decoration: InputDecoration(
                  hintText: 'Message Mindy...',
                  filled: true,
                  fillColor: AppColors.background,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
                textCapitalization: TextCapitalization.sentences,
                maxLines: 4,
                minLines: 1,
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(24),
              ),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send),
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDisclaimer() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Row(
          children: [
            Icon(Icons.info_outline, color: AppColors.warning),
            SizedBox(width: 8),
            Text('About Mindy'),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Mindy is a wellness support tool, not a replacement for professional mental health services.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              SizedBox(height: 16),
              Text(
                'If you are experiencing a mental health emergency, please contact:',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              SizedBox(height: 8),
              Text('• Emergency Services: 112 (EU)', style: TextStyle(color: AppColors.textMuted)),
              Text('• Crisis Text Line: Text HOME to 741741', style: TextStyle(color: AppColors.textMuted)),
              Text('• Befrienders: befrienders.org', style: TextStyle(color: AppColors.textMuted)),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
