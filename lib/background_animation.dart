import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import 'animations.dart';

// ════════════════════════════════════════════════════════════════
// BACKGROUND ANIMATION
//
// The app's base layer is the original animated gradient mesh, kept
// byte-for-byte so the app looks exactly as it did before. Because every
// Scaffold in this project uses `scaffoldBackgroundColor: transparent`,
// this gradient IS the screen background and must stay painted.
//
// Everything added afterwards — the pools of light, the drifting lamp
// beam and the dust motes — is a transparent overlay drawn on top of
// that gradient, so it tints the background instead of replacing it.
//
// All paints, paths and shaders are created once and reused where
// possible, so an animation frame only issues a few draw calls. The loop
// also stops while the app is backgrounded, while the widget is off
// screen, or when the user asked for reduced motion.
// ════════════════════════════════════════════════════════════════

class BackgroundAnimation extends StatefulWidget {
  const BackgroundAnimation({super.key, this.particleCount = 24});

  /// Number of slow drifting dust motes.
  final int particleCount;

  @override
  State<BackgroundAnimation> createState() => _BackgroundAnimationState();
}

class _BackgroundAnimationState extends State<BackgroundAnimation>
    with
        SingleTickerProviderStateMixin,
        AmbientLoopState<BackgroundAnimation> {
  final Random _random = Random();

  late final List<_LightPool> _pools;
  late final List<_DustMote> _motes;
  final _LampBeam _beam = _LampBeam();

  bool? _paletteDark;

  @override
  Duration get ambientDuration => const Duration(seconds: 26);

  @override
  bool get ambientReverse => false;

  @override
  double get ambientNeutralValue => 0.3;

  @override
  void initState() {
    super.initState();
    _pools = _LightPool.createAll(_random);
    _motes = List.generate(
      widget.particleCount,
      (_) => _DustMote.create(_random),
    );
  }

  /// Rebuilds the cached shaders only when the brightness actually flips.
  void _ensurePalette(bool isDark) {
    if (_paletteDark == isDark) return;
    _paletteDark = isDark;

    for (final _LightPool pool in _pools) {
      pool.paint.shader = ui.Gradient.radial(
        Offset.zero,
        pool.radius,
        <Color>[
          pool.color.withValues(alpha: isDark ? 0.20 : 0.13),
          pool.color.withValues(alpha: 0.0),
        ],
      );
    }

    _beam.applyPalette(isDark);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    _ensurePalette(isDark);

    return RepaintBoundary(
      child: CustomPaint(
        painter: _BackgroundPainter(
          progress: ambient.value,
          isDark: isDark,
          pools: _pools,
          motes: _motes,
          beam: _beam,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PAINT ASSETS
// ════════════════════════════════════════════════════════════════

/// A soft pool of light, as if cast by a streetlight onto the road.
class _LightPool {
  _LightPool({
    required this.centerX,
    required this.centerY,
    required this.radius,
    required this.driftX,
    required this.driftY,
    required this.breath,
    required this.phase,
    required this.color,
    required this.paint,
  });

  /// Position at rest, as a fraction of the surface size.
  final double centerX;
  final double centerY;

  final double radius;
  final double driftX;
  final double driftY;

  /// How many breath cycles happen over the full ambient loop.
  final double breath;
  final double phase;
  final Color color;
  final Paint paint;

  static List<_LightPool> createAll(Random random) {
    return <_LightPool>[
      _LightPool(
        centerX: 0.18,
        centerY: 0.78,
        radius: 260,
        driftX: 26,
        driftY: 16,
        breath: 1,
        phase: 0.0,
        color: const Color(0xFFFFC857),
        paint: Paint(),
      ),
      _LightPool(
        centerX: 0.82,
        centerY: 0.24,
        radius: 220,
        driftX: 22,
        driftY: 20,
        breath: 1,
        phase: 0.35,
        color: const Color(0xFF9EC5FF),
        paint: Paint(),
      ),
      _LightPool(
        centerX: 0.55,
        centerY: 0.92,
        radius: 300,
        driftX: 34,
        driftY: 12,
        breath: 2,
        phase: 0.7,
        color: const Color(0xFFFFE0A3),
        paint: Paint(),
      ),
    ];
  }
}

/// A tiny bright speck that drifts through the light.
class _DustMote {
  _DustMote({
    required this.x,
    required this.y,
    required this.radius,
    required this.speed,
    required this.phase,
    required this.amplitude,
    required this.color,
    required this.paint,
  });

  final double x;
  final double y;
  final double radius;
  final double speed;
  final double phase;
  final double amplitude;
  final Color color;
  final Paint paint;

  static const List<Color> _palette = <Color>[
    Color(0xFFFFD98A),
    Color(0xFFCFE1FF),
    Color(0xFFFFF3D6),
  ];

  static _DustMote create(Random random) {
    final Color color = _palette[random.nextInt(_palette.length)];

    return _DustMote(
      x: random.nextDouble(),
      y: random.nextDouble(),
      radius: 1.4 + random.nextDouble() * 1.8,
      speed: 0.4 + random.nextDouble() * 0.8,
      phase: random.nextDouble(),
      amplitude: 8 + random.nextDouble() * 18,
      color: color,
      paint: Paint()..color = color,
    );
  }
}

/// A wide, very faint cone of light that slowly sweeps across the scene.
class _LampBeam {
  final Paint _wide = Paint();
  final Paint _core = Paint();

  /// Trapezoid in normalised space: x and y both run 0..1.
  final Path _path = Path()
    ..moveTo(-0.24, 0.0)
    ..lineTo(0.24, 0.0)
    ..lineTo(0.62, 1.0)
    ..lineTo(-0.62, 1.0)
    ..close();

  void applyPalette(bool isDark) {
    final Color color = isDark
        ? const Color(0xFFFFF0C4)
        : const Color(0xFF8FB6FF);

    // Very low alphas: the beam must only tint what is already there.
    final double wideAlpha = isDark ? 0.10 : 0.06;
    final double coreAlpha = isDark ? 0.07 : 0.04;

    // ui.Gradient.linear only accepts two colours unless explicit stops
    // are supplied, so the falloff has to declare them.
    const List<double> stops = <double>[0.0, 0.45, 1.0];

    _wide.shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(0, 1),
      <Color>[
        color.withValues(alpha: wideAlpha),
        color.withValues(alpha: wideAlpha * 0.35),
        color.withValues(alpha: 0.0),
      ],
      stops,
    );

    _core.shader = ui.Gradient.linear(
      Offset.zero,
      const Offset(0, 1),
      <Color>[
        color.withValues(alpha: coreAlpha),
        color.withValues(alpha: coreAlpha * 0.25),
        color.withValues(alpha: 0.0),
      ],
      stops,
    );
  }

  void paint(Canvas canvas, Size size, double progress) {
    final double x = 0.5 + 0.32 * sin(progress * 2 * pi);
    final double skew = 0.06 * cos(progress * 2 * pi);

    canvas.save();
    canvas.translate(size.width * x, 0.0);
    canvas.scale(size.width, size.height == 0 ? 1.0 : size.height);

    _drawCone(canvas, _wide, skew, 1.0);
    _drawCone(canvas, _core, skew, 0.55);

    canvas.restore();
  }

  void _drawCone(Canvas canvas, Paint paint, double skew, double scale) {
    canvas.save();
    canvas.translate(skew, 0.0);
    canvas.scale(scale, 1.0);
    canvas.drawPath(_path, paint);
    canvas.restore();
  }
}

// ════════════════════════════════════════════════════════════════
// CUSTOM PAINTER
// ════════════════════════════════════════════════════════════════

class _BackgroundPainter extends CustomPainter {
  final double progress;
  final bool isDark;
  final List<_LightPool> pools;
  final List<_DustMote> motes;
  final _LampBeam beam;

  _BackgroundPainter({
    required this.progress,
    required this.isDark,
    required this.pools,
    required this.motes,
    required this.beam,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    // Base layer: the original animated gradient mesh. This is the app's
    // background, so it is painted first and kept unchanged.
    _paintGradientBackdrop(canvas, size);

    // Overlay layers: the new streetlight effects, all semi-transparent.
    _paintBeam(canvas, size);
    _paintPools(canvas, size);
    _paintMotes(canvas, size);
  }

  // ─── Animated gradient mesh ─────────────────────────────────
  void _paintGradientBackdrop(Canvas canvas, Size size) {
    final double t = progress;

    final Color c1 = Color.lerp(
      isDark ? const Color(0xFF0F1118) : const Color(0xFFFAFBFF),
      isDark ? const Color(0xFF1A2744) : const Color(0xFFE8F0FE),
      0.5 + sin(t * pi * 2) * 0.5,
    )!;

    final Color c2 = Color.lerp(
      isDark ? const Color(0xFF151520) : const Color(0xFFFCFCFF),
      isDark ? const Color(0xFF1F2A48) : const Color(0xFFEEF3FC),
      0.5 + cos(t * pi * 2 * 0.7) * 0.5,
    )!;

    final Color c3 = Color.lerp(
      isDark ? const Color(0xFF12121C) : const Color(0xFFF8F9FF),
      isDark ? const Color(0xFF182040) : const Color(0xFFF0F4FF),
      0.5 + sin(t * pi * 2 * 1.3) * 0.5,
    )!;

    final Paint paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: <Color>[c1, c2, c3],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  // ─── Drifting lamp beam ─────────────────────────────────────
  void _paintBeam(Canvas canvas, Size size) {
    beam.paint(canvas, size, progress);
  }

  // ─── Pools of light ─────────────────────────────────────────
  void _paintPools(Canvas canvas, Size size) {
    for (final _LightPool pool in pools) {
      final double cycle = (progress * pool.breath + pool.phase) * 2 * pi;

      final double dx =
          pool.centerX * size.width + sin(cycle) * pool.driftX;
      final double dy =
          pool.centerY * size.height + cos(cycle * 0.7) * pool.driftY;

      // Breathing is done by scaling the canvas, so the cached gradient
      // never has to be rebuilt.
      final double breath = 0.94 + 0.08 * (sin(cycle) * 0.5 + 0.5);

      canvas.save();
      canvas.translate(dx, dy);
      canvas.scale(breath);
      canvas.drawCircle(Offset.zero, pool.radius, pool.paint);
      canvas.restore();
    }
  }

  // ─── Dust motes ─────────────────────────────────────────────
  void _paintMotes(Canvas canvas, Size size) {
    for (final _DustMote mote in motes) {
      final double cycle = (progress * mote.speed + mote.phase) * 2 * pi;

      final double dx = mote.x * size.width + sin(cycle) * mote.amplitude;
      final double dy =
          mote.y * size.height + cos(cycle * 0.8) * mote.amplitude;

      final double alpha =
          (0.10 + 0.16 * (sin(cycle * 1.3) * 0.5 + 0.5)).clamp(0.04, 0.30);

      mote.paint.color = mote.color.withValues(alpha: alpha);
      canvas.drawCircle(Offset(dx, dy), mote.radius, mote.paint);
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.isDark != isDark ||
        oldDelegate.pools != pools ||
        oldDelegate.motes != motes;
  }
}