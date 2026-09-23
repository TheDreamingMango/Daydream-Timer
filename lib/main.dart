import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'app_theme.dart';
import 'session_controller.dart';
import 'theme_controller.dart';
import 'timer_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  final themeController = ThemeController();
  await themeController.load();
  runApp(DaydreamTimerApp(themeController: themeController));
}

class DaydreamTimerApp extends StatefulWidget {
  const DaydreamTimerApp({super.key, this.controller, this.themeController});

  final SessionController? controller;
  final ThemeController? themeController;

  @override
  State<DaydreamTimerApp> createState() => _DaydreamTimerAppState();
}

class _DaydreamTimerAppState extends State<DaydreamTimerApp> {
  late final ThemeController _theme;
  late final bool _ownsTheme;

  @override
  void initState() {
    super.initState();
    _ownsTheme = widget.themeController == null;
    _theme = widget.themeController ?? ThemeController(persist: false);
  }

  @override
  void dispose() {
    if (_ownsTheme) _theme.dispose();
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
              home: TimerScreen(controller: widget.controller),
            ),
          );
        },
      ),
    );
  }
}
