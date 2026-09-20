import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'session_clock.dart';
import 'session_controller.dart';
import 'session_interval.dart';

const _bg = Color(0xFF0A0A0A);
const _muted = Color(0xFF6E6E6E);
const _idleFill = Color(0xFF9A9A9A);
const _idleLine = Color(0xFF3A3A3A);
const _cyan = Color(0xFF00E5C3);
const _text = Color(0xFFF2F2F2);
const _error = Color(0xFFE57373);

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
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
    ]);
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: _bg,
        systemNavigationBarIconBrightness: Brightness.light,
      ),
    );
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

  @override
  Widget build(BuildContext context) {
    final running = _controller.running;
    final accent = running ? _cyan : _idleLine;
    final status = _controller.error ?? (running ? 'running' : 'stopped');
    final statusColor = _controller.error != null
        ? _error
        : (running ? _cyan : _muted);
    final footer = running ? 'tap to stop' : 'tap to start';

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Center(
                child: SizedBox(
                  width: constraints.maxWidth.clamp(0, 520),
                  height: constraints.maxHeight,
                  child: GestureDetector(
                    key: const Key('clock-frame'),
                    behavior: HitTestBehavior.opaque,
                    onTap: _toggle,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      decoration: BoxDecoration(
                        color: _bg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: accent, width: 1.5),
                        boxShadow: running
                            ? [
                                BoxShadow(
                                  color: _cyan.withValues(alpha: 0.16),
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
                            'stop daydreaming',
                            style: _mono(
                              color: running ? _cyan : _muted,
                              size: 12,
                              weight: FontWeight.w500,
                              letterSpacing: 3.2,
                            ),
                          ),
                          Expanded(
                            child: Center(
                              child: _ElapsedReadout(
                                elapsed: _controller.elapsed,
                                color: running ? _text : _idleFill,
                                running: running,
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
                              color: _muted,
                              size: 13,
                              letterSpacing: 1.4,
                            ),
                          ),
                          if (isFastMinutes) ...[
                            const SizedBox(height: 16),
                            const _DebugChip(),
                          ],
                        ],
                      ),
                    ),
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
            size: 14,
            weight: FontWeight.w500,
            letterSpacing: 1.6,
          ),
        ),
      ],
    );
  }
}

class _DebugChip extends StatelessWidget {
  const _DebugChip();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _idleLine),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        child: Text(
          'debug  5s',
          style: _mono(color: _muted, size: 11, letterSpacing: 1),
        ),
      ),
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
