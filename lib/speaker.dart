import 'dart:async';
import 'dart:io' show Platform;

import 'package:audio_session/audio_session.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// Serial spoken announcements. Ducks other audio only for the utterance.
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
      await tts.setSharedInstance(true);
      await tts.setIosAudioCategory(
        IosTextToSpeechAudioCategory.playback,
        [
          IosTextToSpeechAudioCategoryOptions.duckOthers,
          IosTextToSpeechAudioCategoryOptions.interruptSpokenAudioAndMixWithOthers,
        ],
        IosTextToSpeechAudioMode.voicePrompt,
      );
      await tts.autoStopSharedSession(true);
    } else if (Platform.isAndroid) {
      final session = await AudioSession.instance;
      await session.configure(
        const AudioSessionConfiguration(
          avAudioSessionCategory: AVAudioSessionCategory.playback,
          avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.duckOthers,
          avAudioSessionMode: AVAudioSessionMode.spokenAudio,
          androidAudioAttributes: AndroidAudioAttributes(
            contentType: AndroidAudioContentType.speech,
            usage: AndroidAudioUsage.assistanceSonification,
          ),
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
          androidWillPauseWhenDucked: false,
        ),
      );
      _session = session;
    }
    _tts = tts;
    _ready = true;
  }

  Future<void> speak(String text) {
    if (_stopped || text.isEmpty) return Future.value();
    _chain = _chain.then((_) => _utter(text));
    return _chain;
  }

  Future<void> _utter(String text) async {
    if (_stopped || !_ready) return;
    try {
      final session = _session;
      if (session != null) {
        await session.setActive(
          true,
          androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
        );
      }
      await _tts?.speak(text);
    } catch (_) {
      // Fail quietly: the clock still runs.
    } finally {
      final session = _session;
      if (session != null) {
        try {
          await session.setActive(false);
        } catch (_) {
          // Ignore deactivation failure.
        }
      }
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
