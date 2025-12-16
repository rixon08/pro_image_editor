// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:pro_image_editor/pro_image_editor.dart';

// Project imports:
import '/core/constants/example_constants.dart';
import '/core/mixin/example_helper.dart';

/// A widget that demonstrates zoom and move functionality within an editor.
///
/// The [ZoomExample] widget is a stateful widget that provides an
/// example of how to implement zooming and moving features, likely within an
/// image editor or a similar application that requires user interaction for
/// manipulating content.
///
/// This widget holds the state, and the state class
/// [_ZoomExampleState]
/// will contain the logic to handle zoom and move gestures.
///
/// Example usage:
/// ```dart
/// ZoomExample();
/// ```
class ZoomExample extends StatefulWidget {
  /// Creates a new [ZoomExample] widget.
  const ZoomExample({super.key});

  @override
  State<ZoomExample> createState() => _ZoomExampleState();
}

class _ZoomExampleState extends State<ZoomExample>
    with ExampleHelperState<ZoomExample> {
  @override
  void initState() {
    super.initState();
    preCacheImage(assetPath: kImageEditorExampleAssetPath);
  }

  @override
  Widget build(BuildContext context) {
    if (!isPreCached) return const PrepareImageWidget();

    return ProImageEditor.asset(
      kImageEditorExampleAssetPath,
      key: editorKey,
      callbacks: ProImageEditorCallbacks(
        onImageEditingStarted: onImageEditingStarted,
        onImageEditingComplete: onImageEditingComplete,
        onCloseEditor: (editorMode) => onCloseEditor(
          editorMode: editorMode,
          enablePop: !isDesktopMode(context),
        ),
        mainEditorCallbacks: MainEditorCallbacks(
          helperLines: HelperLinesCallbacks(onLineHit: vibrateLineHit),
        ),
      ),
      configs: ProImageEditorConfigs(
        designMode: platformDesignMode,
        mainEditor: MainEditorConfigs(
            enableZoom: true,
            editorMinScale: 0.8,
            editorMaxScale: 5,
            boundaryMargin: const EdgeInsets.all(100),
            enableCloseButton: !isDesktopMode(context),
            widgets: MainEditorWidgets(
              bodyItems: (editor, rebuildStream) {
                return [
                  ReactiveWidget(
                    stream: rebuildStream,
                    builder: (_) =>
                        editor.isLayerBeingTransformed || editor.isSubEditorOpen
                            ? const SizedBox.shrink()
                            : Positioned(
                                bottom: 20,
                                left: 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade700,
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(100),
                                      bottomRight: Radius.circular(100),
                                    ),
                                  ),
                                  child: GestureInterceptor(
                                    child: IconButton(
                                      onPressed: editor.resetZoom,
                                      icon: const Icon(
                                        Icons.zoom_out_map_rounded,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                  ),
                ];
              },
            )),
        paintEditor: PaintEditorConfigs(
          enableZoom: true,
          editorMinScale: 0.8,
          editorMaxScale: 5,
          boundaryMargin: const EdgeInsets.all(100),
          icons: const PaintEditorIcons(
            moveAndZoom: Icons.pinch_outlined,
            locationPin: Icons.location_pin,
          ),
          tools: const [
            PaintMode.moveAndZoom,
            PaintMode.freeStyle,
            PaintMode.arrow,
            PaintMode.line,
            PaintMode.rect,
            PaintMode.circle,
            PaintMode.locationPin,
          ],
        ),
        layerInteraction: const LayerInteractionConfigs(
          /// Choose between `auto`, `enabled` and `disabled`.
          ///
          /// Mode `auto`:
          /// Automatically determines if the layer is selectable based on the
          /// device type.
          /// If the device is a desktop-device, the layer is selectable;
          /// otherwise, the layer is not selectable.
          selectable: LayerInteractionSelectable.enabled,
          initialSelected: true,
          icons: LayerInteractionIcons(
            remove: Icons.clear,
            edit: Icons.edit_outlined,
            rotateScale: Icons.sync,
          ),
          style: LayerInteractionStyle(
            buttonRadius: 10,
            strokeWidth: 1.2,
            borderElementWidth: 7,
            borderElementSpace: 5,
            borderColor: Colors.blue,
            removeCursor: SystemMouseCursors.click,
            rotateScaleCursor: SystemMouseCursors.click,
            editCursor: SystemMouseCursors.click,
            hoverCursor: SystemMouseCursors.move,
            borderStyle: LayerInteractionBorderStyle.solid,
            showTooltips: false,
          ),
        ),
        i18n: const I18n(
          paintEditor: I18nPaintEditor(
            moveAndZoom: 'Zoom',
          ),
        ),
      ),
    );
  }
}
