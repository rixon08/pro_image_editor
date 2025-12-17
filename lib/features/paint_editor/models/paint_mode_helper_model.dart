import 'package:flutter/widgets.dart';

/// Helper class for defining a paint mode's UI representation.
///
/// Contains the [icon] and [label] used in the editor's toolbars.
class PaintModeHelper {
  /// Creates a [PaintModeHelper] with the given [icon] and [label].
  ///
  /// Either [icon] or [customIcon] must be provided, but not both.
  const PaintModeHelper({
    this.icon,
    this.customIcon,
    required this.label,
  }) : assert(
          (icon != null && customIcon == null) ||
              (icon == null && customIcon != null),
          'Either icon or customIcon must be provided, but not both.',
        );

  /// The icon that represents the paint mode.
  final IconData? icon;

  /// Custom widget icon that represents the paint mode.
  /// If provided, this will be used instead of [icon].
  final Widget? customIcon;

  /// The label text shown for the paint mode.
  final String label;
}
