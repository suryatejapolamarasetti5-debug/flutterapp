import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutterapp/background_animation.dart';

const Size _surface = Size(400, 800);

/// Renders [painter] on a fully transparent surface so every visible
/// pixel must come from the painter itself.
///
/// Must be awaited inside `tester.runAsync`, because reading the pixels
/// back from the engine is an async operation.
Future<ByteData> renderOverlay(CustomPainter painter) async {
  final ui.PictureRecorder recorder = ui.PictureRecorder();
  final Canvas canvas = Canvas(recorder);

  // Deliberately transparent: the painter owns the background layer.
  painter.paint(canvas, _surface);

  final ui.Picture picture = recorder.endRecording();
  final ui.Image image = picture.toImageSync(
    _surface.width.toInt(),
    _surface.height.toInt(),
  );

  final ByteData? pixels =
      await image.toByteData(format: ui.ImageByteFormat.rawRgba);

  image.dispose();
  picture.dispose();

  return pixels!;
}

Color pixelAt(ByteData data, int x, int y) {
  final int offset = (y * _surface.width.toInt() + x) * 4;

  return Color.fromARGB(
    data.getUint8(offset + 3),
    data.getUint8(offset),
    data.getUint8(offset + 1),
    data.getUint8(offset + 2),
  );
}

double luminance(Color color) =>
    0.2126 * color.r + 0.7152 * color.g + 0.0722 * color.b;

/// Pumps a real [BackgroundAnimation] and hands back its painter so the
/// test exercises the exact code the app renders.
Future<CustomPainter> pumpAndGetPainter(
  WidgetTester tester, {
  required Brightness brightness,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(brightness: brightness),
      home: const Scaffold(body: BackgroundAnimation()),
    ),
  );

  await tester.pump(const Duration(milliseconds: 300));

  final Iterable<CustomPaint> candidates = tester.widgetList<CustomPaint>(
    find.descendant(
      of: find.byType(BackgroundAnimation),
      matching: find.byType(CustomPaint),
    ),
  );

  return candidates.firstWhere((CustomPaint paint) => paint.painter != null)
      .painter!;
}

void main() {
  testWidgets(
    'restores the original gradient backdrop in both brightnesses',
    (WidgetTester tester) async {
      // The original gradient mesh is what paints the app background,
      // because every Scaffold here is transparent. It must stay opaque
      // and keep its original light / dark character.
      for (final Brightness brightness in Brightness.values) {
        final CustomPainter painter = await pumpAndGetPainter(
          tester,
          brightness: brightness,
        );

        final ByteData? pixels = await tester.runAsync<ByteData?>(
          () => renderOverlay(painter),
        );

        expect(pixels, isNotNull);
        final ByteData data = pixels!;

        double sum = 0;
        int sampled = 0;

        for (int y = 0; y < _surface.height.toInt(); y += 4) {
          for (int x = 0; x < _surface.width.toInt(); x += 4) {
            final Color pixel = pixelAt(data, x, y);

            expect(
              pixel.a,
              greaterThan(0.99),
              reason: 'Background is transparent at ($x, $y).',
            );

            sum += luminance(pixel);
            sampled++;
          }
        }

        final double average = sum / sampled;

        if (brightness == Brightness.dark) {
          expect(
            average,
            lessThan(0.45),
            reason: 'Dark background is not dark enough (avg $average).',
          );
        } else {
          expect(
            average,
            greaterThan(0.80),
            reason: 'Light background is not light enough (avg $average).',
          );
        }
      }
    },
  );

  testWidgets(
    'keeps the new streetlight effects as a transparent overlay',
    (WidgetTester tester) async {
      // The pools and beam must tint the neutral gradient rather than
      // replace it, so warm and cool tints have to appear over it.
      for (final Brightness brightness in Brightness.values) {
        final CustomPainter painter = await pumpAndGetPainter(
          tester,
          brightness: brightness,
        );

        final ByteData? pixels = await tester.runAsync<ByteData?>(
          () => renderOverlay(painter),
        );

        expect(pixels, isNotNull);
        final ByteData data = pixels!;

        bool warmTint = false;
        bool coolTint = false;

        for (int y = 0; y < _surface.height.toInt(); y += 2) {
          for (int x = 0; x < _surface.width.toInt(); x += 2) {
            final Color pixel = pixelAt(data, x, y);

            if (pixel.r - pixel.g > 0.02) warmTint = true;
            if (pixel.b - pixel.r > 0.04) coolTint = true;
          }
        }

        expect(
          warmTint,
          isTrue,
          reason: 'No warm light pool was drawn over the backdrop '
              '($brightness).',
        );
        expect(
          coolTint,
          isTrue,
          reason: 'No cool light pool or beam was drawn over the backdrop '
              '($brightness).',
        );
      }
    },
  );

  testWidgets(
    'never paints the previously forced base colours',
    (WidgetTester tester) async {
      for (final Brightness brightness in Brightness.values) {
        final CustomPainter painter = await pumpAndGetPainter(
          tester,
          brightness: brightness,
        );

        final ByteData? pixels = await tester.runAsync<ByteData?>(
          () => renderOverlay(painter),
        );

        expect(pixels, isNotNull);
        final ByteData data = pixels!;

        // These came from the intermediate backdrop rewrite and are not
        // part of the original design.
        const Set<int> forbidden = <int>{
          0xFF0B0E15,
          0xFF131826,
          0xFF0E121B,
          0xFFFCFDFF,
          0xFFF2F6FD,
          0xFFE8EEF9,
        };

        for (int y = 0; y < _surface.height.toInt(); y += 4) {
          for (int x = 0; x < _surface.width.toInt(); x += 4) {
            expect(
              forbidden.contains(pixelAt(data, x, y).toARGB32()),
              isFalse,
              reason: 'Painted an unexpected base colour at ($x, $y).',
            );
          }
        }
      }
    },
  );
}