import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../models/user_model.dart';

class VoiceCallScreen extends StatefulWidget {
  final UserModel user;

  const VoiceCallScreen({super.key, required this.user});

  @override
  State<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends State<VoiceCallScreen> with TickerProviderStateMixin {
  bool _isConnected = false;
  bool _isMuted = false;
  bool _isSpeakerOn = true;
  Duration _callDuration = Duration.zero;
  Timer? _callTimer;
  Timer? _wellbeingTimer;
  int _wellbeingCheckpointMinutes = 45;
  bool _showWellbeingPrompt = false;

  final List<String> _transcript = [];
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _startCall();
  }

  void _startCall() {
    setState(() => _isConnected = true);
    
    // Start call timer
    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() => _callDuration += const Duration(seconds: 1));
      
      // Check for wellbeing checkpoint
      final minutes = _callDuration.inMinutes;
      if (minutes > 0 && minutes % _wellbeingCheckpointMinutes == 0 && _callDuration.inSeconds % 60 == 0) {
        _showWellbeingCheckpoint();
      }
    });

    // Initial greeting
    _addToTranscript('Mindy', 'Hey there! I am Mindy, your wellness companion. How are you feeling today?');
  }

  void _showWellbeingCheckpoint() {
    if (!_showWellbeingPrompt) {
      setState(() => _showWellbeingPrompt = true);
    }
  }

  void _respondToWellbeing(bool continueCall) {
    setState(() => _showWellbeingPrompt = false);
    
    if (continueCall) {
      _addToTranscript('Mindy', 'Great! Let us continue. I am here whenever you need me.');
    } else {
      _endCall();
    }
  }

  void _endCall() {
    _callTimer?.cancel();
    _wellbeingTimer?.cancel();
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Call Ended'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.call_end, color: AppColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Duration: ${_formatDuration(_callDuration)}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 8),
            const Text(
              'Remember, I am here whenever you need me.',
              style: TextStyle(color: AppColors.textMuted),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  void _addToTranscript(String sender, String message) {
    setState(() {
      _transcript.add('[$sender]: $message');
    });
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    _addToTranscript(widget.user.name ?? 'You', text);
    _messageController.clear();

    // Simulate Mindy response
    Future.delayed(const Duration(seconds: 1), () {
      _generateMindyResponse(text);
    });
  }

  void _generateMindyResponse(String userText) {
    final lowerText = userText.toLowerCase();
    String response;

    if (lowerText.contains('anxious')) {
      response = "I hear that anxiety. Let's take a slow breath together. Breathe in for 4... hold for 4... and out for 4. You are doing great.";
    } else if (lowerText.contains('sad') || lowerText.contains('down')) {
      response = "I am here with you. It is okay to feel what you are feeling. Would you like to talk about what is bringing this up?";
    } else if (lowerText.contains('stressed') || lowerText.contains('overwhelmed')) {
      response = "Stress can feel heavy. Let's break it down together. What is the one thing weighing on you most right now?";
    } else if (lowerText.contains('tired') || lowerText.contains('exhausted')) {
      response = "I hear you. Rest is important. Is there anything small you can do today to be gentle with yourself?";
    } else {
      response = "Thank you for sharing that with me. I am here to listen. Tell me more about how you are feeling.";
    }

    _addToTranscript('Mindy', response);
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$seconds';
    }
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _callTimer?.cancel();
    _wellbeingTimer?.cancel();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                    color: AppColors.textPrimary,
                  ),
                  const Spacer(),
                  Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: const Icon(Icons.psychology, color: Colors.white, size: 32),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Mindy',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 48),
                ],
              ),
            ),

            // Call status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: _isConnected ? AppColors.success.withValues(alpha: 0.2) : AppColors.error.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _isConnected ? AppColors.success : AppColors.error,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _isConnected ? 'Connected • ${_formatDuration(_callDuration)}' : 'Connecting...',
                    style: TextStyle(color: _isConnected ? AppColors.success : AppColors.error),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Wellbeing checkpoint
            if (_showWellbeingPrompt)
              _buildWellbeingPrompt(),

            // Transcript
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ListView.builder(
                  itemCount: _transcript.length,
                  itemBuilder: (context, index) {
                    final message = _transcript[index];
                    final isMindy = message.startsWith('[Mindy]');
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isMindy ? AppColors.primary.withValues(alpha: 0.2) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        message,
                        style: TextStyle(
                          color: isMindy ? AppColors.textPrimary : AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),

            // Controls
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // Message input
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Type a message...',
                            filled: true,
                            fillColor: AppColors.surface,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          ),
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
                  
                  const SizedBox(height: 20),

                  // Call controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildControlButton(
                        icon: _isMuted ? Icons.mic_off : Icons.mic,
                        label: _isMuted ? 'Unmute' : 'Mute',
                        isActive: !_isMuted,
                        onTap: () => setState(() => _isMuted = !_isMuted),
                      ),
                      _buildControlButton(
                        icon: Icons.volume_up,
                        label: 'Speaker',
                        isActive: _isSpeakerOn,
                        onTap: () => setState(() => _isSpeakerOn = !_isSpeakerOn),
                      ),
                      _buildControlButton(
                        icon: Icons.call_end,
                        label: 'End',
                        isActive: false,
                        isDestructive: true,
                        onTap: _endCall,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWellbeingPrompt() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.warning.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Icon(Icons.favorite, color: AppColors.warning),
          const SizedBox(height: 8),
          const Text(
            'Wellbeing Check',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.warning,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'We have been talking for a while. How are you feeling? Do you want to continue?',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton(
                onPressed: () => _respondToWellbeing(false),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.textMuted),
                ),
                child: const Text('End Call'),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: () => _respondToWellbeing(true),
                child: const Text('Continue'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: isDestructive
                  ? AppColors.error
                  : isActive
                      ? AppColors.surface
                      : AppColors.surface.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Icon(
              icon,
              color: isActive
                  ? AppColors.primary
                  : isDestructive
                      ? Colors.white
                      : AppColors.textMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: AppColors.textMuted, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
