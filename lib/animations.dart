import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

// ═══════════════════════════════════════════════════════════════
// LIGHT BLINKING ANIMATIONS
// Professional, subtle glow/blink effects
// ═══════════════════════════════════════════════════════════════

/// Lights up a widget with a soft pulsing glow around it.
class GlowPulse extends StatefulWidget {
  final Widget child;
  final double maxGlow;
  final double minGlow;
  final Duration duration;
  final Color? glowColor;
  final BorderRadius? borderRadius;

  const GlowPulse({
    super.key,
    required this.child,
    this.maxGlow = 1.0,
    this.minGlow = 0.2,
    this.duration = const Duration(milliseconds: 1600),
    this.glowColor,
    this.borderRadius,
  });

  @override
  State<GlowPulse> createState() => _GlowPulseState();
}

class _GlowPulseState extends State<GlowPulse>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _glow = Tween<double>(begin: widget.minGlow, end: widget.maxGlow).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color glowColor =
        widget.glowColor ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _glow,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.08 * _glow.value),
                blurRadius: 18 * _glow.value,
                spreadRadius: 2 * _glow.value,
              ),
            ],
          ),
          child: AnimatedOpacity(
            opacity: _glow.value,
            duration: widget.duration,
            child: child,
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A small circular "light" dot that blinks on and off.
/// Perfect for status indicators, header accents, or loading lights.
class BlinkingDot extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration onDuration;
  final Duration offDuration;

  const BlinkingDot({
    super.key,
    this.color,
    this.size = 10,
    this.onDuration = const Duration(milliseconds: 700),
    this.offDuration = const Duration(milliseconds: 500),
  });

  @override
  State<BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.onDuration,
      reverseDuration: widget.offDuration,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color dotColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double glow = _controller.value;
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: dotColor.withValues(alpha: 0.15 + (0.85 * glow)),
            boxShadow: [
              BoxShadow(
                color: dotColor.withValues(alpha: 0.5 * glow),
                blurRadius: 8 * glow + 2,
                spreadRadius: 1 * glow,
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A blinking halo ring that expands and fades repeatedly.
/// Gives a professional "radar" / "signal" effect.
class BlinkingHalo extends StatefulWidget {
  final Color? color;
  final double size;
  final Duration duration;
  final int rings;
  final Widget? child;

  const BlinkingHalo({
    super.key,
    this.color,
    this.size = 60,
    this.duration = const Duration(milliseconds: 1800),
    this.rings = 3,
    this.child,
  });

  @override
  State<BlinkingHalo> createState() => _BlinkingHaloState();
}

class _BlinkingHaloState extends State<BlinkingHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.duration)
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color haloColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              for (int i = 0; i < widget.rings; i++)
                _buildHaloRing(haloColor, i),
              child ?? Container(),
            ],
          ),
        );
      },
      child: widget.child,
    );
  }

  Widget _buildHaloRing(Color color, int index) {
    final double base =
        (_controller.value + (index / widget.rings)).clamp(0.0, 1.0);
    final double scale = 0.2 + (0.8 * base);
    final double opacity = (1.0 - base);

    return Transform.scale(
      scale: scale,
      child: Opacity(
        opacity: 0.05 + (0.35 * opacity),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: color.withValues(alpha: 0.5 * opacity),
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

/// Soft breathing glow that wraps any widget.
/// Ideal for cards, buttons, and important sections.
class BreathingGlow extends StatefulWidget {
  final Widget child;
  final Color? color;
  final double minRadius;
  final double maxRadius;
  final Duration duration;

  const BreathingGlow({
    super.key,
    required this.child,
    this.color,
    this.minRadius = 4,
    this.maxRadius = 14,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<BreathingGlow> createState() => _BreathingGlowState();
}

class _BreathingGlowState extends State<BreathingGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _radius;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(reverse: true);
    _radius = Tween<double>(
      begin: widget.minRadius,
      end: widget.maxRadius,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color glowColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _radius,
      builder: (context, child) {
        return DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: glowColor.withValues(alpha: 0.12 * _radius.value / 14),
                blurRadius: _radius.value,
                spreadRadius: _radius.value * 0.2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Light wave that ripples through text or widgets.
/// Great for status banners and header text.
class LightRipple extends StatefulWidget {
  final Widget child;
  final Color? color;
  final Duration duration;
  final double maxOpacity;

  const LightRipple({
    super.key,
    required this.child,
    this.color,
    this.duration = const Duration(milliseconds: 2500),
    this.maxOpacity = 0.6,
  });

  @override
  State<LightRipple> createState() => _LightRippleState();
}

class _LightRippleState extends State<LightRipple>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  List<double> get _waveValues {
    return [
      ((_controller.value + 0.0) % 1.0),
      ((_controller.value + 0.25) % 1.0),
      ((_controller.value + 0.5) % 1.0),
      ((_controller.value + 0.75) % 1.0),
    ];
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color waveColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            for (final wave in _waveValues)
              Transform.scale(
                scale: 0.3 + (0.7 * wave),
                child: Opacity(
                  opacity: widget.maxOpacity * (1.0 - wave),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: waveColor.withValues(alpha: 0.08 * (1.0 - wave)),
                      border: Border.all(
                        color: waveColor.withValues(alpha: 0.4 * (1.0 - wave)),
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            child!,
          ],
        );
      },
      child: widget.child,
    );
  }
}

/// Twinkling starfield - subtle shimmering dots.
/// Great for ambient backgrounds behind splash/hero sections.
class TwinkleField extends StatefulWidget {
  final Color? color;
  final int dotCount;
  final double areaWidth;
  final double areaHeight;
  final double dotSize;
  final Duration baseDuration;

  const TwinkleField({
    super.key,
    this.color,
    this.dotCount = 8,
    this.areaWidth = double.infinity,
    this.areaHeight = 200,
    this.dotSize = 4,
    this.baseDuration = const Duration(milliseconds: 1500),
  });

  @override
  State<TwinkleField> createState() => _TwinkleFieldState();
}

class _TwinkleFieldState extends State<TwinkleField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  final Random _random = Random();
  late final List<TwinkleDot> _dots;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: widget.baseDuration)
          ..repeat();
    _dots = List.generate(widget.dotCount, (index) {
      return TwinkleDot(
        x: _random.nextDouble(),
        y: _random.nextDouble(),
        phase: _random.nextDouble(),
        sizeFactor: 0.5 + _random.nextDouble() * 1.0,
        baseDuration: widget.baseDuration,
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color twinkleColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.areaWidth,
      height: widget.areaHeight,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            children: _dots
                .map((dot) {
                  // Stagger each dot by multiplying its phase with the tick
                  final double value =
                      ((_controller.value + dot.phase) % 1.0);
                  // Sine curve for natural fading in/out, not harsh on/off
                  final double brightness =
                      0.15 + (0.85 * (sin(value * pi * 2) * 0.5 + 0.5));
                  return Positioned(
                    left: dot.x * (widget.areaWidth - 20),
                    top: dot.y * (widget.areaHeight - 20),
                    child: Opacity(
                      opacity: brightness,
                      child: Container(
                        width: widget.dotSize * dot.sizeFactor,
                        height: widget.dotSize * dot.sizeFactor,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: twinkleColor.withValues(alpha: brightness),
                          boxShadow: [
                            BoxShadow(
                              color: twinkleColor
                                  .withValues(alpha: 0.4 * brightness),
                              blurRadius: 6 * brightness + 1,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                })
                .toList(),
          );
        },
      ),
    );
  }
}

class TwinkleDot {
  final double x;
  final double y;
  final double phase;
  final double sizeFactor;
  final Duration baseDuration;

  const TwinkleDot({
    required this.x,
    required this.y,
    required this.phase,
    required this.sizeFactor,
    required this.baseDuration,
  });
}

/// A glowing status light - combines a dot with a label.
/// Great for online/offline or active/inactive statuses.
class StatusLight extends StatelessWidget {
  final String label;
  final Color? color;
  final double dotSize;

  const StatusLight({
    super.key,
    required this.label,
    this.color,
    this.dotSize = 10,
  });

  @override
  Widget build(BuildContext context) {
    final Color lightColor =
        color ?? Theme.of(context).colorScheme.primary;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        BlinkingDot(color: lightColor, size: dotSize),
        const SizedBox(width: 8),
        Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

/// Animated gradient shimmer sweep - light sweep across a surface.
/// Good for headers, gradiant banners, and highlighted cards.
class LightSweep extends StatefulWidget {
  final Widget child;
  final Color? color;
  final Duration duration;

  const LightSweep({
    super.key,
    required this.child,
    this.color,
    this.duration = const Duration(milliseconds: 2200),
  });

  @override
  State<LightSweep> createState() => _LightSweepState();
}

class _LightSweepState extends State<LightSweep>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color sweepColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return ClipRect(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              child!,
              Transform.translate(
                offset: Offset(500 * (_controller.value * 3 - 1), 0),
                child: Container(
                  width: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [
                        Colors.transparent,
                        sweepColor.withValues(alpha: 0.06),
                        sweepColor.withValues(alpha: 0.10),
                        sweepColor.withValues(alpha: 0.06),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// Convenience combo: header with blinking status light.
/// Use at top of screens for a professional active indicator.
class AnimatedStatusHeader extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color? accentColor;
  final bool isActive;

  const AnimatedStatusHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.accentColor,
    this.isActive = true,
  });

  @override
  Widget build(BuildContext context) {
    final Color color =
        accentColor ?? Theme.of(context).colorScheme.primary;

    return Row(
      children: [
        BlinkingHalo(color: color, size: 32, rings: 2),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  BlinkingDot(
                    color: isActive
                        ? AppThemes.statusResolved
                        : AppThemes.statusPending,
                    size: 8,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isActive
                          ? AppThemes.statusResolved
                          : AppThemes.statusPending,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}