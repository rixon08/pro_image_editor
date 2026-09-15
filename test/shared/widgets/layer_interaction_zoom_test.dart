// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/features/main_editor/services/layer_interaction_manager.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/interaction_helper/layer_interaction_border_painter.dart';
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
/// editor's interactive viewer.
Future<void> _pumpSelectedLayerAtZoom(
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
}

/// The on-screen rect of the rotate/scale button.
Rect _rotateButtonRect(WidgetTester tester) {
  return tester.getRect(find.ancestor(
    of: find.byIcon(Icons.sync),
    matching: find.byType(LayerInteractionButton),
  ));
}

/// The painter that draws the selection border.
LayerInteractionBorderPainter _borderPainter(WidgetTester tester) {
  return tester
      .widgetList<CustomPaint>(find.byType(CustomPaint))
      .map((widget) => widget.foregroundPainter)
      .whereType<LayerInteractionBorderPainter>()
      .single;
}

void main() {
  const zoomLevels = [1.0, 2.0, 4.0, 8.0];
  const expectedSize = Size(26, 26);
  const style = LayerInteractionStyle();

  group('default interaction buttons keep a constant size while zoomed', () {
    for (final zoom in zoomLevels) {
      testWidgets('at zoom ${zoom}x', (tester) async {
        await _pumpSelectedLayerAtZoom(tester, zoom,
            configs: _defaultConfigs);

        expect(_rotateButtonRect(tester).size, expectedSize);
      });
    }
  });

  group('custom interaction buttons can opt into the zoom compensation', () {
    for (final zoom in zoomLevels) {
      testWidgets('at zoom ${zoom}x', (tester) async {
        await _pumpSelectedLayerAtZoom(tester, zoom,
            configs: _customChildrenConfigs);

        expect(_rotateButtonRect(tester).size, expectedSize);
      });
    }
  });

  group('the selection border keeps a constant thickness while zoomed', () {
    for (final zoom in zoomLevels) {
      testWidgets('at zoom ${zoom}x', (tester) async {
        await _pumpSelectedLayerAtZoom(tester, zoom,
            configs: _defaultConfigs);

        final painted = _borderPainter(tester).style;

        expect(painted.strokeWidth, style.strokeWidth / zoom);
        expect(painted.borderElementWidth, style.borderElementWidth / zoom);
        expect(painted.borderElementSpace, style.borderElementSpace / zoom);
      });
    }
  });

  group('the border painter repaints when the compensated style changes', () {
    const base = LayerInteractionBorderStyle.solid;

    test('repaints on a different stroke width', () {
      final painter = LayerInteractionBorderPainter(
        style: style.copyWith(strokeWidth: 1.2, borderStyle: base),
      );
      final zoomed = LayerInteractionBorderPainter(
        style: style.copyWith(strokeWidth: 0.6, borderStyle: base),
      );

      expect(zoomed.shouldRepaint(painter), isTrue);
    });

    test('does not repaint when nothing relevant changed', () {
      final painter = LayerInteractionBorderPainter(style: style.copyWith());
      final rebuilt = LayerInteractionBorderPainter(style: style.copyWith());

      expect(rebuilt.shouldRepaint(painter), isFalse);
    });
  });
}
