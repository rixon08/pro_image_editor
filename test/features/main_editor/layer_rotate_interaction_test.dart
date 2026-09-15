// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:pro_image_editor/features/main_editor/widgets/main_editor_interactive_content.dart';
import 'package:pro_image_editor/pro_image_editor.dart';
import 'package:pro_image_editor/shared/widgets/layer/interaction_helper/layer_interaction_button.dart';

import '../../mock/mock_image.dart';

const _configs = ProImageEditorConfigs(
  layerInteraction: LayerInteractionConfigs(
    selectable: LayerInteractionSelectable.enabled,
  ),
  progressIndicatorConfigs: ProgressIndicatorConfigs(
    widgets: ProgressIndicatorWidgets(
      circularProgressIndicator: SizedBox.shrink(),
    ),
  ),
  imageGeneration: ImageGenerationConfigs(
    enableIsolateGeneration: false,
    enableBackgroundGeneration: false,
  ),
);

/// Pumps the editor with a single selected text layer.
Future<GlobalKey<ProImageEditorState>> _pumpEditorWithSelectedLayer(
  WidgetTester tester,
) async {
  final key = GlobalKey<ProImageEditorState>();

  MaterialApp buildEditor() => MaterialApp(
        home: ProImageEditor.memory(
          mockMemoryImage,
          key: key,
          configs: _configs,
          callbacks: ProImageEditorCallbacks(
            onImageEditingComplete: (Uint8List bytes) async {},
          ),
        ),
      );

  await tester.pumpWidget(buildEditor());
  await tester.pump();

  key.currentState!.addLayer(
    TextLayer(
      text: 'Test Text',
      color: Colors.white,
      background: Colors.blue,
      align: TextAlign.center,
    ),
  );
  await tester.pump();

  // The interaction overlay is shown from `didUpdateWidget`, so the layer needs
  // one update after it was added and selected.
  await tester.pumpWidget(buildEditor());
  await tester.pump();
  await tester.pump();

  return key;
}

/// The pivot the rotation is calculated around, in global coordinates.
///
/// The layer sits in the center of the editor body, which is also the origin
/// the editor uses for its interaction math.
Offset _layerPivot(WidgetTester tester) {
  return tester.getCenter(find.byType(MainEditorInteractiveContent));
}

/// Drags the rotate button along a circle around [pivot] by [sweep] radians.
Future<void> _dragRotateButton(
  WidgetTester tester, {
  required Offset pivot,
  required double sweep,
  int steps = 8,
}) async {
  final start = tester.getCenter(find.ancestor(
    of: find.byIcon(Icons.sync),
    matching: find.byType(LayerInteractionButton),
  ));

  final radius = (start - pivot).distance;
  final startAngle = atan2(start.dy - pivot.dy, start.dx - pivot.dx);

  final gesture = await tester.startGesture(start);
  await tester.pump();

  for (var step = 1; step <= steps; step++) {
    final angle = startAngle + sweep * step / steps;
    await gesture.moveTo(pivot + Offset(cos(angle), sin(angle)) * radius);
    await tester.pump();
  }

  await gesture.up();
  await tester.pump();
}

void main() {
  group('rotate-scale button', () {
    testWidgets('rotates the layer when dragged around it', (tester) async {
      final key = await _pumpEditorWithSelectedLayer(tester);

      expect(key.currentState!.activeLayers.single.rotation, 0);

      await _dragRotateButton(
        tester,
        pivot: _layerPivot(tester),
        sweep: pi / 2,
      );

      expect(
        key.currentState!.activeLayers.single.rotation,
        closeTo(pi / 2, pi / 8),
      );
    });

    testWidgets('rotates in the opposite direction as well', (tester) async {
      final key = await _pumpEditorWithSelectedLayer(tester);

      await _dragRotateButton(
        tester,
        pivot: _layerPivot(tester),
        sweep: -pi / 2,
      );

      expect(
        key.currentState!.activeLayers.single.rotation,
        closeTo(-pi / 2, pi / 8),
      );
    });

    testWidgets('keeps the layer untouched without a drag', (tester) async {
      final key = await _pumpEditorWithSelectedLayer(tester);

      await _dragRotateButton(
        tester,
        pivot: _layerPivot(tester),
        sweep: 0,
      );

      expect(key.currentState!.activeLayers.single.rotation, 0);
    });
  });
}
