// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/features/main_editor/services/layer_interaction_manager.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/interaction_helper/layer_interaction_button.dart';
import 'package:pro_image_editor/shared/widgets/layer/layer_widget.dart';

const _configs = ProImageEditorConfigs(
  layerInteraction: LayerInteractionConfigs(
    selectable: LayerInteractionSelectable.enabled,
  ),
);

/// Renders a selected layer inside a zoomed [Transform], mimicking the
/// editor's interactive viewer, and returns the on-screen rect of the
/// rotate/scale button.
Future<Rect> _rotateButtonRectAtZoom(WidgetTester tester, double zoom) async {
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
    configs: _configs,
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
                      configs: _configs,
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
    of: find.byIcon(_configs.layerInteraction.icons.rotateScale),
    matching: find.byType(LayerInteractionButton),
  ));
}

void main() {
  group('layer interaction buttons keep a constant size while zoomed', () {
    const expectedSize = Size(26, 26);

    for (final zoom in [1.0, 2.0, 4.0, 8.0]) {
      testWidgets('at zoom ${zoom}x', (tester) async {
        final rect = await _rotateButtonRectAtZoom(tester, zoom);

        expect(rect.size, expectedSize);
      });
    }
  });
}
