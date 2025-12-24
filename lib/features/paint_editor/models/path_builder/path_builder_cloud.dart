import 'package:flutter/widgets.dart';
import 'path_builder_base.dart';

/// Builds a cloud path with scalloped border using the start and end offsets.
class PathBuilderCloud extends PathBuilderBase {
  /// Creates a cloud path builder with the given item and scale.
  PathBuilderCloud({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    final rect = Rect.fromPoints(start, end);
    final size = rect.size;
    
    // Calculate wave radius adaptively based on shape size
    // Use 8 as base (like cloud_widget.dart), but scale it proportionally
    final minDimension = size.width < size.height ? size.width : size.height;
    final baseWaveRadius = 8.0 * scale;
    // Make wave radius proportional to shape size, but keep it reasonable
    final adaptiveWaveRadius = (minDimension / 10).clamp(4.0 * scale, baseWaveRadius);
    final waveRadius = adaptiveWaveRadius;
    
    // Start from top-left corner
    path.moveTo(rect.left, rect.top);
    
    // TOP - Draw scalloped border from left to right (waves going outward/up)
    for (double x = rect.left; x < rect.right; x += waveRadius * 2) {
      final nextX = (x + waveRadius * 2).clamp(rect.left, rect.right);
      final centerX = (x + nextX) / 2;
      // Create arc that bulges outward (upward for top edge) using quadraticBezierTo
      path.quadraticBezierTo(
        centerX, rect.top - waveRadius, // Control point outside (above) the edge
        nextX, rect.top,
      );
    }

    // RIGHT - Draw scalloped border from top to bottom (waves going outward/right)
    for (double y = rect.top; y < rect.bottom; y += waveRadius * 2) {
      final nextY = (y + waveRadius * 2).clamp(rect.top, rect.bottom);
      final centerY = (y + nextY) / 2;
      // Create arc that bulges outward (to the right for right edge)
      path.quadraticBezierTo(
        rect.right + waveRadius, centerY, // Control point outside (to the right) the edge
        rect.right, nextY,
      );
    }

    // BOTTOM - Draw scalloped border from right to left (waves going outward/down)
    for (double x = rect.right; x > rect.left; x -= waveRadius * 2) {
      final nextX = (x - waveRadius * 2).clamp(rect.left, rect.right);
      final centerX = (x + nextX) / 2;
      // Create arc that bulges outward (downward for bottom edge)
      path.quadraticBezierTo(
        centerX, rect.bottom + waveRadius, // Control point outside (below) the edge
        nextX, rect.bottom,
      );
    }

    // LEFT - Draw scalloped border from bottom to top (waves going outward/left)
    for (double y = rect.bottom; y > rect.top; y -= waveRadius * 2) {
      final nextY = (y - waveRadius * 2).clamp(rect.top, rect.bottom);
      final centerY = (y + nextY) / 2;
      // Create arc that bulges outward (to the left for left edge)
      path.quadraticBezierTo(
        rect.left - waveRadius, centerY, // Control point outside (to the left) the edge
        rect.left, nextY,
      );
    }

    path.close();
    return path;
  }

  @override
  bool hitTest(Offset position) {
    // Always use bounding box for hit testing to make it easier to click
    // especially when fill = false
    build();
    
    // Get the bounding box of the path
    final bounds = path.getBounds();
    
    // If fill is enabled, use path.contains for precise hit testing
    if (item.fill) {
      return path.contains(position);
    }
    
    // When fill is false, still use bounding box for easier clicking
    // instead of stroke-based hit test
    return bounds.contains(position);
  }
}

