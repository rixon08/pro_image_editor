import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'path_builder_base.dart';

/// Builds a location pin using Icon widget (Icons.location_pin).
class PathBuilderLocationPin extends PathBuilderBase {
  /// Creates a location pin path builder using the given item and scale factor.
  PathBuilderLocationPin({
    required super.item,
    required super.scale,
    required super.paintEditorConfigs,
  });

  @override
  Path build() {
    // Return empty path as we'll draw using Icon widget directly
    return path;
  }

  @override
  void draw({required Canvas canvas, required Size size}) {
    if (offsets.isEmpty || offsets[0] == null) return;
    
    // Build path (even though we don't use it, for consistency)
    build();

    final tapPosition = start;
    // Use stroke width to determine icon size, with minimum size for visibility
    final baseSize = (item.strokeWidth > 0 ? item.strokeWidth : 8.0) * scale;
    final iconSize = baseSize * 5.0;

    // Get icon data
    final iconData = paintEditorConfigs.icons.locationPin;
    final iconColor = painter.color.withOpacity(item.opacity);

    // Create TextPainter to draw the icon
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(iconData.codePoint),
        style: TextStyle(
          fontSize: iconSize,
          fontFamily: iconData.fontFamily,
          color: iconColor,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    iconPainter.layout();
    
    // Draw icon at center position
    // final iconOffset = center - Offset(iconPainter.width / 2, iconPainter.height / 2);
    final iconOffset = Offset(
      tapPosition.dx - iconPainter.width / 2,  // Center horizontally
      tapPosition.dy - iconPainter.height,     // Bottom of icon at tap position
    );
    iconPainter.paint(canvas, iconOffset);
  }

  @override
  bool hitTest(Offset position) {
    if (offsets.isEmpty || offsets[0] == null) return false;
    
    final center = start;
    final baseSize = (item.strokeWidth > 0 ? item.strokeWidth : 8.0) * scale;
    final iconSize = baseSize * 2.5;
    final radius = iconSize / 2;
    
    // Simple circular hit test
    return (position - center).distance <= radius;
  }
}

