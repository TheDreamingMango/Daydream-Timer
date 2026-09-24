import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'access_controller.dart';
import 'app_theme.dart';

class Paywall extends StatefulWidget {
  const Paywall({super.key, required this.access});

  final AccessController access;

  @override
  State<Paywall> createState() => _PaywallState();
}

class _PaywallState extends State<Paywall> {
  var _closed = false;

  @override
  void initState() {
    super.initState();
    widget.access.addListener(_onAccess);
  }

  @override
  void dispose() {
    widget.access.removeListener(_onAccess);
    super.dispose();
  }

  void _onAccess() {
    if (!mounted || _closed) return;
    if (widget.access.unlocked) {
      _closed = true;
      Navigator.of(context).pop();
      return;
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final palette = AppPalette.of(context);
    final access = widget.access;
    final waiting = access.purchasing || access.restoring;
    final buttonLabel = waiting
        ? 'waiting…'
        : (access.price == null ? 'unlock' : 'unlock · ${access.price}');

    return Scaffold(
      key: const Key('paywall'),
      backgroundColor: palette.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(28, 8, 28, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  key: const Key('paywall-dismiss'),
                  onPressed: () {
                    HapticFeedback.lightImpact();
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'not now',
                    style: _mono(color: palette.muted, size: 15),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                'daydream timer',
                textAlign: TextAlign.center,
                style: _mono(
                  color: palette.muted,
                  size: 14,
                  weight: FontWeight.w500,
                  letterSpacing: 2.8,
                ),
              ),
              const SizedBox(height: 28),
              Text(
                'keep the timer',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'IBMPlexSans',
                  color: palette.text,
                  fontSize: 36,
                  fontWeight: FontWeight.w600,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'The three-day trial is over. Unlock Daydream Timer once, and it stays on this device.',
                textAlign: TextAlign.center,
                style: _mono(color: palette.muted, size: 15, height: 1.45),
              ),
              const Spacer(),
              if (access.purchaseError != null) ...[
                Text(
                  access.purchaseError!,
                  key: const Key('paywall-error'),
                  textAlign: TextAlign.center,
                  style: _mono(color: palette.error, size: 14, height: 1.4),
                ),
                const SizedBox(height: 16),
              ],
              FilledButton(
                key: const Key('paywall-unlock'),
                onPressed: access.canBuy
                    ? () {
                        HapticFeedback.lightImpact();
                        access.buy();
                      }
                    : null,
                style: FilledButton.styleFrom(
                  backgroundColor: palette.accent,
                  disabledBackgroundColor: palette.idleLine,
                  foregroundColor: palette.bg,
                  disabledForegroundColor: palette.muted,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  buttonLabel,
                  style: _mono(
                    color: access.canBuy ? palette.bg : palette.muted,
                    size: 16,
                    weight: FontWeight.w500,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('paywall-restore'),
                onPressed: waiting
                    ? null
                    : () {
                        HapticFeedback.lightImpact();
                        access.restore();
                      },
                child: Text(
                  'restore purchase',
                  style: _mono(color: palette.muted, size: 15),
                ),
              ),
            ],
          ),
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
