// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/features/main_editor/services/layer_interaction_manager.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/interaction_helper/layer_interaction_button.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

const _defaultConfigs = ProImageEditorConfigs(
  layerInteraction: LayerInteractionConfigs(
    selectable: LayerInteractionSelectable.enabled,
  ),
);

/// Mirrors how an app supplies its own interaction buttons, opting into the
/// zoom compensation through [LayerInteractionScale].
final _customChildrenConfigs = ProImageEditorConfigs(
  layerInteraction: LayerInteractionConfigs(
    selectable: LayerInteractionSelectable.enabled,
    widgets: LayerInteractionWidgets(
      children: [
        (rebuildStream, layer, interactions) => ReactiveWidget(
              stream: rebuildStream,
              builder: (context) => Positioned(
                bottom: 0,
                right: 0,
                child: Transform.scale(
                  scale: LayerInteractionScale.of(context),
                  alignment: Alignment.center,
                  child: LayerInteractionButton(
                    rotation: -layer.rotation,
                    onScaleRotateDown: interactions.scaleRotateDown,
                    onScaleRotateUp: interactions.scaleRotateUp,
                    buttonRadius: 10,
                    cursor: SystemMouseCursors.click,
                    icon: Icons.sync,
                    tooltip: 'Rotate and Scale',
                    color: Colors.black,
                    background: Colors.white,
                  ),
                ),
              ),
            ),
      ],
    ),
  ),
);

/// Renders a selected layer inside a zoomed [Transform], mimicking the
/// editor's interactive viewer, and returns the on-screen rect of the
/// rotate/scale button.
Future<Rect> _rotateButtonRectAtZoom(
  WidgetTester tester,
  double zoom, {
  required ProImageEditorConfigs configs,
}) async {
  final layer = TextLayer(
    text: 'Test Text',
    color: Colors.white,
    background: Colors.blue,
    offset: Offset.zero,
    align: TextAlign.center,
    rotation: 0.0,
    scale: 1.0,
  );

  final manager = LayerInteractionManager(
    helperLinesCallbacks: null,
    configs: configs,
    onSelectedLayersChanged: (_) {},
  );

  late StateSetter rebuild;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: Transform(
            transform: Matrix4.identity()..scaleByDouble(zoom, zoom, zoom, 1),
            child: SizedBox(
              width: 300,
              height: 300,
              child: StatefulBuilder(builder: (context, setState) {
                rebuild = setState;
                return Stack(
                  children: [
                    LayerWidget(
                      editorBodySize: const Size(300, 300),
                      layer: layer,
                      configs: configs,
                      layerInteractionManager: manager,
                      isInteractive: true,
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    ),
  );

  // Selecting after the first build triggers `didUpdateWidget`, which is
  // where the interaction overlay is shown.
  rebuild(() => manager.selectedLayerId = layer.id);
  await tester.pump();
  await tester.pump();

  return tester.getRect(find.ancestor(
    of: find.byIcon(Icons.sync),
    matching: find.byType(LayerInteractionButton),
  ));
}

void main() {
  const expectedSize = Size(26, 26);

  group('default interaction buttons keep a constant size while zoomed', () {
    for (final zoom in [1.0, 2.0, 4.0, 8.0]) {
      testWidgets('at zoom ${zoom}x', (tester) async {
        final rect = await _rotateButtonRectAtZoom(
          tester,
          zoom,
          configs: _defaultConfigs,
        );

        expect(rect.size, expectedSize);
      });
    }
  });

  group('custom interaction buttons can opt into the zoom compensation', () {
    for (final zoom in [1.0, 2.0, 4.0, 8.0]) {
      testWidgets('at zoom ${zoom}x', (tester) async {
        final rect = await _rotateButtonRectAtZoom(
          tester,
          zoom,
          configs: _customChildrenConfigs,
        );

        expect(rect.size, expectedSize);
      });
    }
  });
}
