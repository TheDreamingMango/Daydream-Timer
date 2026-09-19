import 'package:flutter/material.dart';

void main() {
  runApp(const StopDaydreamingApp());
}

class StopDaydreamingApp extends StatelessWidget {
  const StopDaydreamingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Stop Daydreaming',
      home: Scaffold(
        appBar: AppBar(title: const Text('Stop Daydreaming')),
        body: const Center(child: Text('Hello')),
      ),
    );
  }
}
