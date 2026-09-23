import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_theme.dart';
import 'session_clock.dart';
import 'session_controller.dart';
import 'theme_controller.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key, this.controller});

  final SessionController? controller;

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  late final SessionController _controller;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? SessionController();
    _controller.addListener(_onChange);
    _controller.attach();
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncSystemUi(AppPalette.of(context));
  }

  @override
  void dispose() {
    _controller.removeListener(_onChange);
    if (widget.controller == null) {
      _controller.dispose();
    }
    super.dispose();
  }

  void _onChange() {
    if (mounted) setState(() {});
  }

  void _toggle() {
    HapticFeedback.lightImpact();
    _controller.toggle();
  }

  void _syncSystemUi(AppPalette palette) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    final overlay = dark ? Brightness.light : Brightness.dark;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: dark ? Brightness.dark : Brightness.light,
        statusBarIconBrightness: overlay,
        systemNavigationBarColor: palette.bg,
        systemNavigationBarIconBrightness: overlay,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final running = _controller.running;
    final accent = running ? palette.accent : palette.idleLine;
    final status = _controller.error ?? (running ? 'running' : 'stopped');
    final statusColor = _controller.error != null
        ? palette.error
        : (running ? palette.accent : palette.muted);
    final footer = running ? 'tap to stop' : 'tap to start';

    return Scaffold(
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 4, 22, 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SizedBox(
                  width: constraints.maxWidth.clamp(0, 520),
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.centerRight,
                        child: _ThemeToggle(),
                      ),
                      Expanded(
                        child: GestureDetector(
                          key: const Key('clock-frame'),
                          behavior: HitTestBehavior.opaque,
                          onTap: _toggle,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(
                              color: palette.bg,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: accent, width: 1.5),
                              boxShadow: running
                                  ? [
                                      BoxShadow(
                                        color: palette.glow,
                                        blurRadius: 28,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : const [],
                            ),
                            padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
                            child: Column(
                              children: [
                                Text(
                                  'daydream timer',
                                  style: _mono(
                                    color: running
                                        ? palette.accent
                                        : palette.muted,
                                    size: 14,
                                    weight: FontWeight.w500,
                                    letterSpacing: 2.8,
                                  ),
                                ),
                                Expanded(
                                  child: Center(
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        _ElapsedReadout(
                                          elapsed: _controller.elapsed,
                                          color: running
                                              ? palette.text
                                              : palette.idleFill,
                                          running: running,
                                        ),
                                        if (running &&
                                            (_controller.quote ?? '')
                                                .isNotEmpty)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 20,
                                            ),
                                            child: _QuoteLine(
                                              text: _controller.quote!,
                                              color: palette.muted,
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ),
                                _StatusLine(
                                  label: status,
                                  color: statusColor,
                                  filled: running && _controller.error == null,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  footer,
                                  style: _mono(
                                    color: palette.muted,
                                    size: 15,
                                    weight: FontWeight.w500,
                                    letterSpacing: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (!running) ...[
                        const SizedBox(height: 16),
                        const _Disclaimer(),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _Disclaimer extends StatelessWidget {
  const _Disclaimer();

  static const text =
      'Daydream Timer is a grounding and time-awareness tool. '
      'It does not diagnose, treat, or cure any condition and is not a '
      'substitute for qualified professional care.';

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    return Text(
      text,
      key: const Key('disclaimer'),
      textAlign: TextAlign.center,
      style: _mono(
        color: palette.muted,
        size: 12,
        height: 1.45,
        letterSpacing: 0.1,
      ),
    );
  }
}

class _ThemeToggle extends StatelessWidget {
  const _ThemeToggle();

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final theme = ThemeScope.of(context);
    final toLight = theme.isDark;

    return IconButton(
      key: const Key('theme-toggle'),
      tooltip: toLight ? 'light mode' : 'dark mode',
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.fromLTRB(10, 4, 2, 8),
      constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
      splashColor: Colors.transparent,
      highlightColor: palette.accent.withValues(alpha: 0.1),
      onPressed: () {
        HapticFeedback.lightImpact();
        theme.toggle();
      },
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.86, end: 1).animate(animation),
              child: child,
            ),
          );
        },
        child: Icon(
          toLight ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          key: ValueKey(toLight),
          size: 20,
          color: palette.muted,
        ),
      ),
    );
  }
}

class _ElapsedReadout extends StatelessWidget {
  const _ElapsedReadout({
    required this.elapsed,
    required this.color,
    required this.running,
  });

  final Duration elapsed;
  final Color color;
  final bool running;

  static const _digitSize = 92.0;

  @override
  Widget build(BuildContext context) {
    final formatted = formatElapsed(elapsed);
    final colonOn = !running || elapsed.inMilliseconds % 1000 < 530;
    final parts = formatted.split(':');
    final digits = TextStyle(
      fontFamily: 'IBMPlexSans',
      color: color,
      fontSize: _digitSize,
      fontWeight: FontWeight.w600,
      height: 1,
      fontFeatures: const [FontFeature.tabularFigures()],
    );

    return Semantics(
      key: const Key('elapsed'),
      label: formatted,
      container: true,
      child: ExcludeSemantics(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              for (var i = 0; i < parts.length; i++) ...[
                if (i > 0)
                  _ClockColon(
                    color: colonOn ? color : color.withValues(alpha: 0.18),
                    height: _digitSize,
                  ),
                Text(parts[i], style: digits),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _QuoteLine extends StatelessWidget {
  const _QuoteLine({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      key: const Key('quote'),
      textAlign: TextAlign.center,
      style: TextStyle(
        fontFamily: 'IBMPlexMono',
        fontStyle: FontStyle.italic,
        color: color,
        fontSize: 16,
        height: 1.4,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

class _ClockColon extends StatelessWidget {
  const _ClockColon({required this.color, required this.height});

  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    Widget dot() => Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );

    return SizedBox(
      width: 26,
      height: height,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          dot(),
          SizedBox(height: height * 0.14),
          dot(),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({
    required this.label,
    required this.color,
    required this.filled,
  });

  final String label;
  final Color color;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 9,
          height: 9,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: filled ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          label,
          style: _mono(
            color: color,
            size: 16,
            weight: FontWeight.w500,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

TextStyle _mono({
  required Color color,
  required double size,
  FontWeight weight = FontWeight.w400,
  double letterSpacing = 0,
  double height = 1.2,
}) {
  return TextStyle(
    fontFamily: 'IBMPlexMono',
    color: color,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
  );
}
