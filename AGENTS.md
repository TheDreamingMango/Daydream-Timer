# Stop Daydreaming

Mobile Flutter app (Android and iOS) that interrupts maladaptive daydreaming by making elapsed time impossible to ignore. Keep it fast, calm, local-first, and easy to understand.

A sibling macOS terminal app lives in `~/Code/focus`. Same problem, different platform. Do not port Focus's Ollama grounding prompts unless the user asks.

## Product

The user starts a timer that keeps running in the background. Every minute, the app speaks the minute it is on: "one minute", "two minutes", and so on.

Music and other audio are common triggers. The announcement should cut through whatever the user is already hearing. Pause or duck other audio for the spoken minute, then restore it immediately when the announcement ends. Never leave the user's music stopped.

The point is mindfulness of time passing — and of time lost — while daydreaming. Do not shame, lecture, or gamify.

## Core Contract

- Spoken copy is the cardinal minute in words plus "minute"/"minutes". Not "minute 1", not just "1".
- Announcements fire on whole-minute boundaries and must not overlap.
- The timer survives backgrounding, screen lock, and other apps in the foreground. A timer that only speaks while this app is visible has failed.
- Other audio is interrupted only for the announcement, then restored right away.
- Start/stop should be obvious and one tap. No accounts, no cloud, no network requirement.

## Working Agreements

- Prefer the smallest clear change. Avoid abstractions until they remove real duplication.
- Keep user-facing language brief, compassionate, and non-judgmental.
- Treat audio session, background execution, and speech as the product, not extras. UI is secondary to a reliable spoken interrupt.
- Add dependencies only when Flutter or existing packages cannot do the job.
- Do not add Focus-style LLM prompts, stats dashboards, or social features unless asked.

## Current Shape

One TUI screen (`lib/timer_screen.dart`): tap the clock frame to start/stop. `SessionClock` is Stopwatch-based and resets on stop. Spoken minutes come from `Speaker` (`flutter_tts` + `audio_session` ducking). On Android, clock+TTS live in a `mediaPlayback` foreground-service isolate (`lib/session_task.dart`). On iOS, they run in the UI isolate with `audio` background mode and no silent keep-alive loop.

## Verification

```sh
flutter analyze
flutter test
```

For timer, speech, backgrounding, or audio-interruption changes, also run on a real device or emulator and check: start/stop, minute announcements, app backgrounded, and that other audio resumes after each announcement.
