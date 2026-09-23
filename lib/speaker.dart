import 'dart:async';
import 'dart:io' show Platform;

import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Serial spoken announcements. Other audio yields only for each burst.
class Speaker {
  FlutterTts? _tts;
  AudioSession? _session;
  Future<void> _chain = Future.value();
  bool _stopped = false;
  bool _ready = false;

  Future<void> init() async {
    _stopped = false;
    final tts = FlutterTts();
    await tts.awaitSpeakCompletion(true);
    await tts.setLanguage('en-US');
    if (Platform.isIOS) {
      // No mix or duck options, so playback interrupts other media.
      await tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        const [],
        IosTextToSpeechAudioMode.voicePrompt,
      );
      // Keep the session up for a minute+quote burst; we deactivate it below.
      await tts.autoStopSharedSession(false);
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.none,
          avAudioSessionMode: AVAudioSessionMode.voicePrompt,
          avAudioSessionSetActiveOptions:
              AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
        ),
      );
      _session = session;
    } else if (Platform.isAndroid) {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions:
              AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.assistanceSonification,
          ),
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
          androidWillPauseWhenDucked: false,
        ),
      );
      _session = session;
    }
    _tts = tts;
    _ready = true;
  }

  Future<void> speak(String text) => speakBurst([text]);

  /// Speaks [lines] in order under one interruption so a minute + quote stay one burst.
  Future<void> speakBurst(Iterable<String> lines) {
    if (_stopped) return Future.value();
    final texts = [
      for (final line in lines)
        if (line.isNotEmpty) line,
    ];
    if (texts.isEmpty) return Future.value();
    _chain = _chain.then((_) => _utterBurst(texts));
    return _chain;
  }

  Future<void> _utterBurst(List<String> texts) async {
    if (_stopped || !_ready) return;
    try {
      await _setActive(true);
      for (final text in texts) {
        if (_stopped) return;
        try {
          await _tts?.speak(text);
        } catch (_) {
          // Fail quietly: the clock still runs.
        }
      }
    } finally {
      if (Platform.isIOS && _session != null) {
        // didFinish fires while the synthesizer still owns I/O. Deactivating
        // then fails, and the other app never gets the resume signal.
        await Future<void>.delayed(const Duration(milliseconds: 500));
      }
      await _setActive(false);
    }
  }

  Future<void> _setActive(bool active) async {
    final session = _session;
    if (session == null) return;
    try {
      if (active) {
        await session.setActive(
          true,
          androidAudioFocusGainType:
              AndroidAudioFocusGainType.gainTransientMayDuck,
        );
      } else {
        await session.setActive(false);
      }
    } catch (_) {
      // Ignore focus failure.
    }
  }

  Future<void> stop() async {
    _stopped = true;
    _ready = false;
    try {
      await _tts?.stop();
    } catch (_) {
      // Ignore stop failure.
    }
    try {
      await _session?.setActive(false);
    } catch (_) {
      // Ignore deactivation failure.
    }
  }
}
