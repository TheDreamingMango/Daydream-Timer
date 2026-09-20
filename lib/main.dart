import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

import 'session_controller.dart';
import 'timer_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  FlutterForegroundTask.initCommunicationPort();
  runApp(const StopDaydreamingApp());
}

class StopDaydreamingApp extends StatelessWidget {
  const StopDaydreamingApp({super.key, this.controller});

  final SessionController? controller;

  @override
  Widget build(BuildContext context) {
    return WithForegroundTask(
      child: MaterialApp(
        title: 'Stop Daydreaming',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          fontFamily: 'IBMPlexMono',
          scaffoldBackgroundColor: const Color(0xFF0A0A0A),
          colorScheme: const ColorScheme.dark(
            surface: Color(0xFF0A0A0A),
            primary: Color(0xFF00E5C3),
          ),
        ),
        home: TimerScreen(controller: controller),
      ),
    );
  }
}
