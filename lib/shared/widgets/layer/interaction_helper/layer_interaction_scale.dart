// Flutter imports:
import 'package:flutter/widgets.dart';

/// Exposes the factor that cancels out the editor's current zoom for widgets
/// inside a layer's interaction overlay.
///
/// The overlay is painted through the editor's zoom transform, so anything
/// placed inside it grows together with the zoom. The default interaction
/// buttons already compensate for this, but custom buttons supplied through
/// `LayerInteractionWidgets.children` have to opt in by scaling themselves:
///
/// ```dart
/// children: [
///   (rebuildStream, layer, interactions) => ReactiveWidget(
///         stream: rebuildStream,
///         builder: (context) => Positioned(
///           top: 0,
///           left: 0,
///           child: Transform.scale(
///             scale: LayerInteractionScale.of(context),
///             alignment: Alignment.center,
///             child: LayerInteractionButton(
///               rotation: -layer.rotation,
///               onTap: interactions.remove,
///               buttonRadius: 10,
///               cursor: SystemMouseCursors.click,
///               icon: Icons.clear,
///               tooltip: 'Remove',
///               color: Colors.black,
///               background: Colors.white,
///             ),
///           ),
///         ),
///       ),
/// ]
/// ```
///
/// Scaling around [Alignment.center] keeps the button anchored on the
/// selection border, since the overlay positions each button so that its
/// center sits on the corresponding corner.
class LayerInteractionScale extends InheritedWidget {
  /// Creates a [LayerInteractionScale] that provides [scale] to its subtree.
  const LayerInteractionScale({
    super.key,
    required this.scale,
    required super.child,
  });

  /// The reciprocal of the editor's current zoom factor.
  ///
  /// Multiplying a widget's size by this value keeps it at a constant size on
  /// screen, no matter how far the editor is zoomed in.
  final double scale;

  /// Returns the counter-scale of the closest [LayerInteractionScale].
  ///
  /// Falls back to `1` when called outside of a layer interaction overlay, so
  /// custom buttons keep working when they are reused elsewhere.
  static double of(BuildContext context) {
    final result =
        context.dependOnInheritedWidgetOfExactType<LayerInteractionScale>();
    return result?.scale ?? 1;
  }

  @override
  bool updateShouldNotify(LayerInteractionScale oldWidget) {
    return oldWidget.scale != scale;
  }
}
