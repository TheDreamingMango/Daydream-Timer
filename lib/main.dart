import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'access_controller.dart';
import 'app_theme.dart';
import 'session_controller.dart';
import 'theme_controller.dart';
import 'timer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  final themeController = ThemeController();
  final access = AccessController();
  await Future.wait([themeController.load(), access.load()]);
  runApp(DaydreamTimerApp(themeController: themeController, access: access));
}

class DaydreamTimerApp extends StatefulWidget {
  const DaydreamTimerApp({
    super.key,
    this.controller,
    this.themeController,
    this.access,
  });

  final SessionController? controller;
  final ThemeController? themeController;
  final AccessController? access;

  @override
  State<DaydreamTimerApp> createState() => _DaydreamTimerAppState();
}

class _DaydreamTimerAppState extends State<DaydreamTimerApp> {
  late final ThemeController _theme;
  late final bool _ownsTheme;
  late final AccessController _access;
  late final bool _ownsAccess;

  @override
  void initState() {
    super.initState();
    _ownsTheme = widget.themeController == null;
    _theme = widget.themeController ?? ThemeController(persist: false);
    _ownsAccess = widget.access == null;
    _access = widget.access ?? AccessController(persist: false);
  }

  @override
  void dispose() {
    if (_ownsTheme) _theme.dispose();
    if (_ownsAccess) _access.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeScope(
      controller: _theme,
      child: ListenableBuilder(
        listenable: _theme,
        builder: (context, _) {
          return WithForegroundTask(
            child: MaterialApp(
              title: 'Daydream Timer',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light,
              darkTheme: AppTheme.dark,
              themeMode: _theme.mode,
              themeAnimationDuration: const Duration(milliseconds: 280),
              themeAnimationCurve: Curves.easeOut,
              home: TimerScreen(controller: widget.controller, access: _access),
            ),
          );
        },
      ),
    );
  }
}
