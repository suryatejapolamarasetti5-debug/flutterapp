import 'dart:math';
import 'package:flutter/material.dart';
import 'theme.dart';

// ═══════════════════════════════════════════════════════════════
// MOTION FOUNDATION
// Shared building blocks for the "Smart City / Light Pulse" style.
// Every helper here respects reduced-motion settings, pauses when the
// app is backgrounded and disposes every controller it creates.
// ═══════════════════════════════════════════════════════════════

/// Returns `true` when the platform (or the user) asked for less motion.
///
/// All helpers in this file honour this flag, so no essential
/// information is ever hidden behind an animation.
bool reduceMotionOf(BuildContext context) {
  return MediaQuery.maybeOf(context)?.disableAnimations ?? false;
}

/// Owns a repeating [AnimationController] that only runs while it is
/// actually useful: never while the app is backgrounded, never while
/// the widget is off screen ([TickerMode]) and never when reduced
/// motion is requested.
class AmbientTicker with WidgetsBindingObserver {
  AmbientTicker({
    required TickerProvider vsync,
    required this.duration,
    this.reverse = true,
    this.neutralValue = 0.5,
  }) : controller = AnimationController(vsync: vsync, duration: duration) {
    WidgetsBinding.instance.addObserver(this);
  }

  final Duration duration;
  final bool reverse;

  /// Value parked at while reduced motion is on, so the widget still
  /// renders in a pleasant static state instead of half-faded.
  final double neutralValue;

  final AnimationController controller;

  bool _inForeground = true;
  bool _onScreen = true;
  bool _reduceMotion = false;

  double get value => controller.value;

  /// Re-evaluates whether the loop should be running.
  void sync({required bool reduceMotion, required bool onScreen}) {
    _reduceMotion = reduceMotion;
    _onScreen = onScreen;
    _apply();
  }

  void _apply() {
    final bool shouldRun = _inForeground && _onScreen && !_reduceMotion;

    if (shouldRun) {
      if (!controller.isAnimating) {
        controller.repeat(reverse: reverse);
      }
      return;
    }

    if (controller.isAnimating) {
      controller.stop();
    }

    if (_reduceMotion && controller.value != neutralValue) {
      controller.value = neutralValue;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _inForeground = state == AppLifecycleState.resumed;
    _apply();
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    controller.dispose();
  }
}

/// Gives a [State] an [AmbientTicker] that is kept in sync with the app
/// lifecycle, the ambient [TickerMode] and reduced-motion settings.
///
/// The state must also provide a single [TickerProvider], i.e. mix in
/// [SingleTickerProviderStateMixin] before this mixin.
mixin AmbientLoopState<T extends StatefulWidget> on State<T>, TickerProvider {
  AmbientTicker? _ambient;

  /// The ambient loop owned by this state.
  AmbientTicker get ambient {
    return _ambient ??= AmbientTicker(
      vsync: this,
      duration: ambientDuration,
      reverse: ambientReverse,
      neutralValue: ambientNeutralValue,
    );
  }

  /// How long one full ambient cycle takes.
  Duration get ambientDuration;

  /// Whether the loop plays forwards and then backwards.
  bool get ambientReverse => true;

  /// Static value used while reduced motion is on.
  double get ambientNeutralValue => 0.5;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    ambient.sync(
      reduceMotion: reduceMotionOf(context),
      onScreen: TickerMode.valuesOf(context).enabled,
    );
  }

  @override
  void dispose() {
    _ambient?.dispose();
    _ambient = null;
    super.dispose();
  }
}

// ═══════════════════════════════════════════════════════════════
// ENTRANCE ANIMATIONS
// ═══════════════════════════════════════════════════════════════

/// Fades (and gently lifts) its child into place.
///
/// The delay is expressed as an [Interval] on a single controller, so no
/// timers are created and nothing leaks when the widget is disposed.
class FadeSlideIn extends StatefulWidget {
  const FadeSlideIn({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 380),
    this.delay = Duration.zero,
    this.slide = const Offset(0, 0.08),
    this.scale,
    this.curve = Curves.easeOutCubic,
    this.replayKey,
  });

  final Widget child;
  final Duration duration;
  final Duration delay;

  /// Where the child starts, relative to its final position.
  final Offset slide;

  /// Optional starting scale, e.g. `0.96` for a subtle zoom in.
  final double? scale;

  final Curve curve;

  /// Changing this value replays the entrance. Useful for screens that
  /// stay alive but swap their content.
  final Object? replayKey;

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late Animation<double> _entrance;

  Duration get _total => widget.delay + widget.duration;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _total);
    _entrance = _buildEntrance();
    _controller.forward();
  }

  Animation<double> _buildEntrance() {
    if (widget.duration <= Duration.zero) {
      return const AlwaysStoppedAnimation<double>(1);
    }

    final double begin =
        (widget.delay.inMilliseconds / _total.inMilliseconds).clamp(
          0.0,
          1.0,
        );

    return CurvedAnimation(
      parent: _controller,
      curve: Interval(begin, 1.0, curve: widget.curve),
    );
  }

  @override
  void didUpdateWidget(covariant FadeSlideIn oldWidget) {
    super.didUpdateWidget(oldWidget);

    final bool needsReplay =
        widget.replayKey != oldWidget.replayKey ||
        widget.delay != oldWidget.delay ||
        widget.duration != oldWidget.duration;

    if (needsReplay) {
      _controller
        ..duration = _total
        ..forward(from: 0);
      _entrance = _buildEntrance();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotionOf(context) || widget.duration <= Duration.zero) {
      return widget.child;
    }

    return AnimatedBuilder(
      animation: _entrance,
      child: widget.child,
      builder: (context, child) {
        final double t = _entrance.value;
        final double fromScale = widget.scale ?? 1.0;
        final double scale = fromScale + (1.0 - fromScale) * t;

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(
              widget.slide.dx * (1.0 - t),
              widget.slide.dy * (1.0 - t),
            ),
            child: fromScale == 1.0
                ? child
                : Transform.scale(scale: scale, child: child),
          ),
        );
      },
    );
  }
}

/// Wraps [children] in [FadeSlideIn]s with progressively longer delays.
///
/// Use it inside a [Wrap], [Row] or any parent that cannot be replaced by
/// a [StaggeredListAnimation]. The total delay is capped so long lists
/// still appear immediately.
List<Widget> buildStaggeredChildren(
  List<Widget> children, {
  Duration interval = const Duration(milliseconds: 60),
  Duration duration = const Duration(milliseconds: 360),
  Duration initialDelay = Duration.zero,
  Duration maxTotalDelay = const Duration(milliseconds: 420),
  Offset slide = const Offset(0, 0.08),
  double? scale,
  Curve curve = Curves.easeOutCubic,
}) {
  final int cap = maxTotalDelay.inMilliseconds;
  final int base = initialDelay.inMilliseconds;

  return <Widget>[
    for (int i = 0; i < children.length; i++)
      FadeSlideIn(
        duration: duration,
        delay: Duration(milliseconds: (base + interval.inMilliseconds * i)
            .clamp(0, cap)),
        slide: slide,
        scale: scale,
        curve: curve,
        child: children[i],
      ),
  ];
}

/// A vertical list whose items fade and slide in one after another.
class StaggeredListAnimation extends StatelessWidget {
  const StaggeredListAnimation({
    super.key,
    required this.children,
    this.interval = const Duration(milliseconds: 60),
    this.duration = const Duration(milliseconds: 360),
    this.initialDelay = Duration.zero,
    this.maxTotalDelay = const Duration(milliseconds: 420),
    this.slide = const Offset(0, 0.08),
    this.scale,
    this.spacing,
    this.curve = Curves.easeOutCubic,
    this.crossAxisAlignment = CrossAxisAlignment.start,
    this.mainAxisSize = MainAxisSize.min,
  });

  final List<Widget> children;
  final Duration interval;
  final Duration duration;
  final Duration initialDelay;
  final Duration maxTotalDelay;
  final Offset slide;
  final double? scale;

  /// Optional gap inserted between the animated children.
  final double? spacing;

  final Curve curve;
  final CrossAxisAlignment crossAxisAlignment;
  final MainAxisSize mainAxisSize;

  @override
  Widget build(BuildContext context) {
    final List<Widget> animated = buildStaggeredChildren(
      children,
      interval: interval,
      duration: duration,
      initialDelay: initialDelay,
      maxTotalDelay: maxTotalDelay,
      slide: slide,
      scale: scale,
      curve: curve,
    );

    if (spacing == null) {
      return Column(
        mainAxisSize: mainAxisSize,
        crossAxisAlignment: crossAxisAlignment,
        children: animated,
      );
    }

    return Column(
      mainAxisSize: mainAxisSize,
      crossAxisAlignment: crossAxisAlignment,
      children: <Widget>[
        for (int i = 0; i < animated.length; i++) ...<Widget>[
          if (i > 0) SizedBox(height: spacing),
          animated[i],
        ],
      ],
    );
  }
}

/// Subtle press feedback for important actions (scale + opacity).
///
/// It only listens to pointer events, so the wrapped button keeps all of
/// its own behaviour: focus, ripples, validation and callbacks.
class PressScale extends StatefulWidget {
  const PressScale({
    super.key,
    required this.child,
    this.pressedScale = 0.97,
    this.pressedOpacity = 0.92,
    this.duration = const Duration(milliseconds: 130),
  });

  final Widget child;
  final double pressedScale;
  final double pressedOpacity;
  final Duration duration;

  @override
  State<PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<PressScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed == value || !mounted) return;
    setState(() {
      _pressed = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (reduceMotionOf(context)) {
      return widget.child;
    }

    return Listener(
      behavior: HitTestBehavior.deferToChild,
      onPointerDown: (_) => _setPressed(true),
      onPointerUp: (_) => _setPressed(false),
      onPointerCancel: (_) => _setPressed(false),
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1.0,
        duration: widget.duration,
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: _pressed ? widget.pressedOpacity : 1.0,
          duration: widget.duration,
          curve: Curves.easeOut,
          child: widget.child,
        ),
      ),
    );
  }
}

/// The signature "lamp is on" motion: a very slow scale + opacity +
/// glow breathing cycle, used for hero streetlight icons.
class LightPulse extends StatefulWidget {
  const LightPulse({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 2600),
    this.minScale = 1.0,
    this.maxScale = 1.04,
    this.minOpacity = 0.72,
    this.glowColor,
    this.maxGlow = 18,
    this.borderRadius,
  });

  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final double minOpacity;
  final Color? glowColor;
  final double maxGlow;
  final BorderRadius? borderRadius;

  @override
  State<LightPulse> createState() => _LightPulseState();
}

class _LightPulseState extends State<LightPulse>
    with SingleTickerProviderStateMixin, AmbientLoopState<LightPulse> {
  @override
  Duration get ambientDuration => widget.duration;

  @override
  double get ambientNeutralValue => 0.6;

  @override
  Widget build(BuildContext context) {
    final Color glowColor =
        widget.glowColor ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: ambient.controller,
      child: widget.child,
      builder: (context, child) {
        final double t = Curves.easeInOut.transform(ambient.value);

        return Container(
          decoration: BoxDecoration(
            borderRadius:
                widget.borderRadius ?? BorderRadius.circular(12),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: glowColor.withValues(alpha: 0.16 * t),
                blurRadius: widget.maxGlow * t,
                spreadRadius: 1.5 * t,
              ),
            ],
          ),
          child: Opacity(
            opacity: widget.minOpacity + (1.0 - widget.minOpacity) * t,
            child: Transform.scale(
              scale: widget.minScale +
                  (widget.maxScale - widget.minScale) * t,
              child: child,
            ),
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// STATUS INDICATOR
// Pending → In Progress → Resolved, with a subtle cross-fade.
// ═══════════════════════════════════════════════════════════════

class StatusIndicator extends StatelessWidget {
  const StatusIndicator({
    super.key,
    required this.status,
    this.color,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    this.showIcon = true,
  });

  final String status;
  final Color? color;
  final double fontSize;
  final EdgeInsets padding;
  final bool showIcon;

  /// Shared status palette, so every screen speaks the same colours.
  static const Map<String, Color> palette = <String, Color>{
    'Pending': AppThemes.statusPending,
    'In Progress': AppThemes.statusInProgress,
    'Resolved': AppThemes.statusResolved,
    'Rejected': AppThemes.statusRejected,
  };

  static Color colorFor(String status) =>
      palette[status] ?? AppThemes.statusPending;

  static IconData iconFor(String status) {
    switch (status) {
      case 'Resolved':
        return Icons.check_circle_outline;
      case 'In Progress':
        return Icons.sync;
      case 'Rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.schedule;
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color accent = color ?? colorFor(status);
    final bool reduceMotion = reduceMotionOf(context);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: AnimatedSwitcher(
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 280),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              ...previousChildren,
              ?currentChild,
            ],
          );
        },
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.92, end: 1.0).animate(animation),
              child: child,
            ),
          );
        },
        child: Row(
          key: ValueKey<String>(status),
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            if (showIcon) ...<Widget>[
              Icon(iconFor(status), size: fontSize + 2, color: accent),
              const SizedBox(width: 5),
            ],
            Text(
              status,
              style: TextStyle(
                color: accent,
                fontWeight: FontWeight.bold,
                fontSize: fontSize,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// NAVIGATION
// ═══════════════════════════════════════════════════════════════

/// Route transition: a calm fade with a very small upward slide.
class SubtlePageTransitionsBuilder extends PageTransitionsBuilder {
  const SubtlePageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    if (reduceMotionOf(context)) {
      return child;
    }

    final Animation<double> curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.035),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      ),
    );
  }
}

/// Password visibility suffix icon that cross-fades between the two
/// states instead of snapping, so toggling feels smooth.
class PasswordVisibilityToggle extends StatelessWidget {
  const PasswordVisibilityToggle({
    super.key,
    required this.isObscured,
    required this.onPressed,
  });

  final bool isObscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final bool reduceMotion = reduceMotionOf(context);

    return IconButton(
      onPressed: onPressed,
      tooltip: isObscured ? 'Show password' : 'Hide password',
      icon: AnimatedSwitcher(
        duration:
            reduceMotion ? Duration.zero : const Duration(milliseconds: 220),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.85, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutBack,
                ),
              ),
              child: child,
            ),
          );
        },
        child: Icon(
          isObscured
              ? Icons.visibility_outlined
              : Icons.visibility_off_outlined,
          key: ValueKey<bool>(isObscured),
        ),
      ),
    );
  }
}

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
    with SingleTickerProviderStateMixin, AmbientLoopState<GlowPulse> {
  late final Animation<double> _glow;

  @override
  Duration get ambientDuration => widget.duration;

  @override
  void initState() {
    super.initState();
    _glow = Tween<double>(begin: widget.minGlow, end: widget.maxGlow).animate(
      CurvedAnimation(
        parent: ambient.controller,
        curve: Curves.easeInOut,
      ),
    );
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
          child: Opacity(opacity: _glow.value, child: child),
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
    with SingleTickerProviderStateMixin, AmbientLoopState<BlinkingDot> {
  @override
  Duration get ambientDuration =>
      widget.onDuration + widget.offDuration;

  @override
  Widget build(BuildContext context) {
    final Color dotColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: ambient.controller,
      builder: (context, child) {
        final double glow = ambient.value;
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
    with SingleTickerProviderStateMixin, AmbientLoopState<BlinkingHalo> {
  @override
  Duration get ambientDuration => widget.duration;

  @override
  bool get ambientReverse => false;

  @override
  Widget build(BuildContext context) {
    final Color haloColor = widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: ambient.controller,
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
        ((ambient.value + (index / widget.rings)).clamp(0.0, 1.0));
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
    with SingleTickerProviderStateMixin, AmbientLoopState<BreathingGlow> {
  late final Animation<double> _radius;

  @override
  Duration get ambientDuration => widget.duration;

  @override
  void initState() {
    super.initState();
    _radius = Tween<double>(
      begin: widget.minRadius,
      end: widget.maxRadius,
    ).animate(
      CurvedAnimation(
        parent: ambient.controller,
        curve: Curves.easeInOut,
      ),
    );
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
    with SingleTickerProviderStateMixin, AmbientLoopState<LightRipple> {
  @override
  Duration get ambientDuration => widget.duration;

  @override
  bool get ambientReverse => false;

  List<double> get _waveValues {
    return [
      ((ambient.value + 0.0) % 1.0),
      ((ambient.value + 0.25) % 1.0),
      ((ambient.value + 0.5) % 1.0),
      ((ambient.value + 0.75) % 1.0),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final Color waveColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return AnimatedBuilder(
      animation: ambient.controller,
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
    with SingleTickerProviderStateMixin, AmbientLoopState<TwinkleField> {
  final Random _random = Random();
  late final List<TwinkleDot> _dots;

  @override
  Duration get ambientDuration => widget.baseDuration;

  @override
  bool get ambientReverse => false;

  @override
  void initState() {
    super.initState();
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
  Widget build(BuildContext context) {
    final Color twinkleColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return SizedBox(
      width: widget.areaWidth,
      height: widget.areaHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // The width may be unbounded, so fall back to the window size
          // instead of producing an infinite offset.
          final double width = constraints.hasBoundedWidth
              ? constraints.maxWidth
              : MediaQuery.sizeOf(context).width;
          final double height = constraints.hasBoundedHeight
              ? constraints.maxHeight
              : widget.areaHeight;

          return AnimatedBuilder(
            animation: ambient.controller,
            builder: (context, child) {
              return Stack(
                children: _dots
                    .map((dot) {
                      // Stagger each dot by multiplying its phase with the tick
                      final double value =
                          ((ambient.value + dot.phase) % 1.0);
                      // Sine curve for natural fading in/out, not harsh on/off
                      final double brightness =
                          0.15 + (0.85 * (sin(value * pi * 2) * 0.5 + 0.5));
                      return Positioned(
                        left: dot.x * (width - 20),
                        top: dot.y * (height - 20),
                        child: Opacity(
                          opacity: brightness,
                          child: Container(
                            width: widget.dotSize * dot.sizeFactor,
                            height: widget.dotSize * dot.sizeFactor,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: twinkleColor.withValues(
                                alpha: brightness,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: twinkleColor.withValues(
                                    alpha: 0.4 * brightness,
                                  ),
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
    with SingleTickerProviderStateMixin, AmbientLoopState<LightSweep> {
  @override
  Duration get ambientDuration => widget.duration;

  @override
  bool get ambientReverse => false;

  @override
  Widget build(BuildContext context) {
    final Color sweepColor =
        widget.color ?? Theme.of(context).colorScheme.primary;

    return ClipRect(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: ambient.controller,
          builder: (context, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                child!,
                Transform.translate(
                  offset: Offset(500 * (ambient.value * 3 - 1), 0),
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