import 'dart:math';
import 'package:flutter/material.dart';

// ═══════════════════════════════════════════════════════════════
// BACKGROUND ANIMATION — Floating Particles + Gradient Mesh
// Subtle, professional ambient animation for the whole app
// ═══════════════════════════════════════════════════════════════

class BackgroundAnimation extends StatefulWidget {
  final int particleCount;

  const BackgroundAnimation({super.key, this.particleCount = 35});

  @override
  State<BackgroundAnimation> createState() => _BackgroundAnimationState();
}

class _BackgroundAnimationState extends State<BackgroundAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_Particle> _particles;
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 30),
    )..repeat();

    _particles = List.generate(widget.particleCount, (_) {
      return _Particle(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        radius: 2.0 + _random.nextDouble() * 4.0,
        speedX: 0.015 + _random.nextDouble() * 0.025,
        speedY: 0.010 + _random.nextDouble() * 0.020,
        phaseX: _random.nextDouble() * pi * 2,
        phaseY: _random.nextDouble() * pi * 2,
        amplitudeX: 20 + _random.nextDouble() * 35,
        amplitudeY: 15 + _random.nextDouble() * 30,
        color: _randomGlowColor(),
      );
    });
  }

  static const List<Color> _glowPalette = [
    Color(0xFF42A5F5), // blue
    Color(0xFF26A69A), // teal
    Color(0xFFAB47BC), // purple
    Color(0xFF66BB6A), // green
    Color(0xFFFFCA28), // amber
    Color(0xFF42A5F5),
    Color(0xFF5C6BC0), // indigo
  ];

  Color _randomGlowColor() => _glowPalette[_random.nextInt(_glowPalette.length)];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isDark =>
      WidgetsBinding.instance.platformDispatcher.platformBrightness ==
          Brightness.dark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, _) => CustomPaint(
        painter: _BackgroundPainter(
          particles: _particles,
          progress: _controller.value,
          isDark: _isDark,
        ),
        size: Size.infinite,
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PARTICLE DATA
// ═══════════════════════════════════════════════════════════════

class _Particle {
  final double x;
  final double y;
  final double radius;
  final double speedX;
  final double speedY;
  final double phaseX;
  final double phaseY;
  final double amplitudeX;
  final double amplitudeY;
  final Color color;

  const _Particle({
    required this.x,
    required this.y,
    required this.radius,
    required this.speedX,
    required this.speedY,
    required this.phaseX,
    required this.phaseY,
    required this.amplitudeX,
    required this.amplitudeY,
    required this.color,
  });
}

// ═══════════════════════════════════════════════════════════════
// CUSTOM PAINTER
// ═══════════════════════════════════════════════════════════════

class _BackgroundPainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;
  final bool isDark;

  _BackgroundPainter({
    required this.particles,
    required this.progress,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _paintGradientBackdrop(canvas, size);
    _paintSoftOrbs(canvas, size);
    _paintParticles(canvas, size);
  }

  // ─── Animated gradient mesh ────────────────────────────────
  void _paintGradientBackdrop(Canvas canvas, Size size) {
    final t = progress;

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

    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [c1, c2, c3],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  // ─── Large soft ambient orbs ───────────────────────────────
  void _paintSoftOrbs(Canvas canvas, Size size) {
    final t = progress;

    final orbData = [
      (dx: 0.2, dy: 0.25, r: 220.0, color: const Color(0xFF42A5F5), phase: 0.0),
      (dx: 0.8, dy: 0.7,  r: 260.0, color: const Color(0xFF26A69A), phase: 2.0),
      (dx: 0.5, dy: 0.5,  r: 200.0, color: const Color(0xFFAB47BC), phase: 4.0),
      (dx: 0.7, dy: 0.2,  r: 180.0, color: const Color(0xFF66BB6A), phase: 1.5),
    ];

    for (final orb in orbData) {
      final dx = orb.dx * size.width + sin(t * pi * 2 * 0.15 + orb.phase) * 40;
      final dy = orb.dy * size.height + cos(t * pi * 2 * 0.12 + orb.phase) * 35;

      canvas.drawCircle(
        Offset(dx, dy),
        orb.r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              orb.color.withValues(alpha: isDark ? 0.06 : 0.08),
              orb.color.withValues(alpha: 0.0),
            ],
          ).createShader(
            Rect.fromCircle(center: Offset(dx, dy), radius: orb.r),
          ),
      );
    }
  }

  // ─── Small floating particles ──────────────────────────────
  void _paintParticles(Canvas canvas, Size size) {
    final t = progress;

    for (final p in particles) {
      final dx =
          p.x * size.width + sin(t * pi * 2 * p.speedX * 10 + p.phaseX) * p.amplitudeX;
      final dy =
          p.y * size.height + cos(t * pi * 2 * p.speedY * 10 + p.phaseY) * p.amplitudeY;

      final alpha = (0.18 + sin(t * pi * 2 + p.phaseX) * 0.12).clamp(0.05, 0.35);

      // Outer glow
      canvas.drawCircle(
        Offset(dx, dy),
        p.radius * 4.5,
        Paint()..color = p.color.withValues(alpha: alpha * 0.25),
      );

      // Inner glow
      canvas.drawCircle(
        Offset(dx, dy),
        p.radius * 2.0,
        Paint()..color = p.color.withValues(alpha: alpha * 0.45),
      );

      // Core
      canvas.drawCircle(
        Offset(dx, dy),
        p.radius,
        Paint()..color = p.color.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _BackgroundPainter old) => old.progress != progress;
}