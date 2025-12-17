// Flutter imports:
import 'package:flutter/widgets.dart';

// Project imports:
import '../enums/paint_editor_enum.dart';

/// Represents a model for a paint-mode item, including an icon, a mode
/// identifier, and a label.
class PaintModeBottomBarItem {
  /// Creates a [PaintModeBottomBarItem] instance to define a paint mode.
  ///
  /// Either [icon] or [customIcon] must be provided, but not both.
  /// - [icon]: An optional icon to visually represent the paint mode.
  /// - [customIcon]: A custom widget icon to visually represent the paint mode.
  /// - [mode]: The identifier for the paint mode (enum value).
  /// - [label]: A descriptive label for the paint mode.
  const PaintModeBottomBarItem({
    this.icon,
    this.customIcon,
    required this.mode,
    required this.label,
  }) : assert(
          (icon != null && customIcon == null) ||
              (icon == null && customIcon != null),
          'Either icon or customIcon must be provided, but not both.',
        );

  /// The icon representing the paint mode.
  final IconData? icon;

  /// Custom widget icon representing the paint mode.
  /// If provided, this will be used instead of [icon].
  final Widget? customIcon;

  /// The identifier for the paint mode.
  final PaintMode mode;

  /// A descriptive label for the paint mode.
  final String label;
}
