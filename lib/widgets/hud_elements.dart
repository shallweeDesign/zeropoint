import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class HudPanel extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? borderColor;

  const HudPanel({super.key, required this.child, this.padding, this.borderColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ZeroPointColors.panel.withOpacity(0.92),
        border: Border.all(color: borderColor ?? ZeroPointColors.border, width: 1),
      ),
      child: child,
    );
  }
}

class HudLabel extends StatelessWidget {
  final String text;
  final Color? color;
  final double fontSize;

  const HudLabel(this.text, {super.key, this.color, this.fontSize = 11});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: fontSize,
        color: color ?? ZeroPointColors.textSecondary,
        letterSpacing: 2.0,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class MissionProgressBar extends StatelessWidget {
  final double progress;
  final Color? color;

  const MissionProgressBar({super.key, required this.progress, this.color});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: CustomPaint(
        painter: _ProgressPainter(progress: progress, color: color ?? ZeroPointColors.accent),
      ),
    );
  }
}

class _ProgressPainter extends CustomPainter {
  final double progress;
  final Color color;

  _ProgressPainter({required this.progress, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final track = Paint()..color = ZeroPointColors.border;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), track);

    final fill = Paint()..color = color;
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width * progress.clamp(0, 1), size.height), fill);

    // tick marks
    final tick = Paint()..color = ZeroPointColors.bg..strokeWidth = 1;
    for (int i = 1; i < 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), tick);
    }
  }

  @override
  bool shouldRepaint(_ProgressPainter old) => old.progress != progress;
}

class AccentCornerBox extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;

  const AccentCornerBox({super.key, required this.child, this.padding = const EdgeInsets.all(16)});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerPainter(),
      child: Padding(padding: padding, child: child),
    );
  }
}

class _CornerPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = ZeroPointColors.accent
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    const len = 16.0;
    // top-left
    canvas.drawLine(Offset.zero, Offset(len, 0), paint);
    canvas.drawLine(Offset.zero, Offset(0, len), paint);
    // top-right
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - len, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, len), paint);
    // bottom-left
    canvas.drawLine(Offset(0, size.height), Offset(len, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - len), paint);
    // bottom-right
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - len, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - len), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
