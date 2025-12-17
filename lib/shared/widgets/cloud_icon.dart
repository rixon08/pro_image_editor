import 'package:flutter/material.dart';

/// Custom icon that displays a square with scalloped border (cloud shape)
class CloudIcon extends StatelessWidget {
  final double size;
  final Color color;
  
  const CloudIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.black, // Use black so ColorFiltered can change it
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: CloudIconPainter(color: color),
    );
  }
}

class CloudIconPainter extends CustomPainter {
  final Color color;
  
  CloudIconPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Calculate dimensions with padding
    final padding = size.width * 0.15;
    final rect = Rect.fromLTWH(
      padding,
      padding,
      size.width - padding * 2,
      size.height - padding * 2,
    );
    
    final waveRadius = size.width * 0.08; // Small waves for icon
    final path = Path();
    
    // Start from top-left
    path.moveTo(rect.left, rect.top);
    
    // TOP - scalloped border going outward (up)
    for (double x = rect.left; x < rect.right; x += waveRadius * 2) {
      final nextX = (x + waveRadius * 2).clamp(rect.left, rect.right);
      final centerX = (x + nextX) / 2;
      path.quadraticBezierTo(
        centerX, rect.top - waveRadius,
        nextX, rect.top,
      );
    }

    // RIGHT - scalloped border going outward (right)
    for (double y = rect.top; y < rect.bottom; y += waveRadius * 2) {
      final nextY = (y + waveRadius * 2).clamp(rect.top, rect.bottom);
      final centerY = (y + nextY) / 2;
      path.quadraticBezierTo(
        rect.right + waveRadius, centerY,
        rect.right, nextY,
      );
    }

    // BOTTOM - scalloped border going outward (down)
    for (double x = rect.right; x > rect.left; x -= waveRadius * 2) {
      final nextX = (x - waveRadius * 2).clamp(rect.left, rect.right);
      final centerX = (x + nextX) / 2;
      path.quadraticBezierTo(
        centerX, rect.bottom + waveRadius,
        nextX, rect.bottom,
      );
    }

    // LEFT - scalloped border going outward (left)
    for (double y = rect.bottom; y > rect.top; y -= waveRadius * 2) {
      final nextY = (y - waveRadius * 2).clamp(rect.top, rect.bottom);
      final centerY = (y + nextY) / 2;
      path.quadraticBezierTo(
        rect.left - waveRadius, centerY,
        rect.left, nextY,
      );
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CloudIconPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}

