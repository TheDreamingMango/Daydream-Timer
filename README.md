# Stop Daydreaming

Minimal Flutter app for **Android** and **iOS**.

## Run

```bash
flutter pub get
flutter run   # pick a connected device / emulator
```

### Tooling

- **Flutter:** `brew install --cask flutter`
- **Android:** install [Android Studio](https://developer.android.com/studio), open it once to install the SDK, then accept licenses: `flutter doctor --android-licenses`
- **iOS:** install full [Xcode](https://developer.apple.com/xcode/), then:
  ```bash
  sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
  sudo xcodebuild -runFirstLaunch
  brew install cocoapods
  ```
