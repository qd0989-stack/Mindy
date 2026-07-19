import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../core/theme/app_theme.dart';

/// Audio waveform visualization widget
class WaveformWidget extends StatelessWidget {
  final List<double> waveformData;
  final bool isActive;
  final Color? color;

  const WaveformWidget({
    super.key,
    required this.waveformData,
    this.isActive = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppTheme.primaryTeal;

    return CustomPaint(
      painter: WaveformPainter(
        waveformData: waveformData,
        color: effectiveColor,
        isActive: isActive,
      ),
      size: const Size(double.infinity, 100),
    );
  }
}

class WaveformPainter extends CustomPainter {
  final List<double> waveformData;
  final Color color;
  final bool isActive;

  WaveformPainter({
    required this.waveformData,
    required this.color,
    required this.isActive,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (waveformData.isEmpty) return;

    final paint = Paint()
      ..color = isActive ? color : color.withOpacity(0.3)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final barWidth = size.width / waveformData.length;
    final centerY = size.height / 2;
    final maxHeight = size.height * 0.8;

    for (int i = 0; i < waveformData.length; i++) {
      final value = waveformData[i].clamp(0.0, 1.0);
      final barHeight = value * maxHeight;

      // Draw bar from center
      final x = i * barWidth + barWidth / 2;
      final top = centerY - barHeight / 2;
      final bottom = centerY + barHeight / 2;

      // Gradient effect
      final gradientPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withOpacity(0.8),
            color,
            color.withOpacity(0.8),
          ],
        ).createShader(Rect.fromLTRB(x - 2, top, x + 2, bottom))
        ..strokeWidth = barWidth * 0.6
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(
        Offset(x, top),
        Offset(x, bottom),
        gradientPaint,
      );
    }
  }

  @override
  bool shouldRepaint(WaveformPainter oldDelegate) {
    return oldDelegate.waveformData != waveformData ||
        oldDelegate.isActive != isActive;
  }
}

/// Pulsing animation widget for the call button
class PulsingCircle extends StatefulWidget {
  final Widget child;
  final bool isPulsing;
  final Color color;

  const PulsingCircle({
    super.key,
    required this.child,
    this.isPulsing = false,
    this.color = AppTheme.primaryTeal,
  });

  @override
  State<PulsingCircle> createState() => _PulsingCircleState();
}

class _PulsingCircleState extends State<PulsingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.6, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    if (widget.isPulsing) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(PulsingCircle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPulsing && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPulsing && _controller.isAnimating) {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isPulsing ? _scaleAnimation.value : 1.0,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(
                    widget.isPulsing ? _opacityAnimation.value : 0.0,
                  ),
                ),
              ),
            );
          },
        ),
        widget.child,
      ],
    );
  }
}
