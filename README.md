# Daydream Timer

Minimal Flutter app for **Android** and **iOS**. One screen: tap the clock to start a timer that speaks each whole minute ("one minute", "two minutes") even when the app is backgrounded. Every two minutes it also reads a grounding quote from a local list, on screen and out loud.

## Run

```bash
cd ~/Code/Stop-Daydreaming
export JAVA_HOME="/opt/homebrew/opt/openjdk/libexec/openjdk.jdk/Contents/Home"
export ANDROID_HOME="/opt/homebrew/share/android-commandlinetools"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="/opt/homebrew/bin:/opt/homebrew/opt/openjdk/bin:$ANDROID_HOME/platform-tools:$PATH"

flutter pub get
flutter devices
flutter run   # pick an Android emulator/device or iOS simulator
```

## Tooling on this Mac

Already set up:
- Flutter (`brew install --cask flutter`)
- Android Studio → `~/Applications`
- Android SDK + licenses (`android-commandlinetools`, platform 36)
- CocoaPods
- OpenJDK (Homebrew)

**iOS still needs one admin step** (Xcode is installed, but CLI points at Command Line Tools):

```bash
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

Then open Simulator (`open -a Simulator`) and run `flutter run`.
