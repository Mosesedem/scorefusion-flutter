# Score Fusion (Flutter)

Native Flutter shell for [Score Fusion](https://www.getscorefusion.com) — live scores, match alerts, and the full dashboard experience in a WebView with native push notifications.

## Features

- Full-screen WebView loading the Score Fusion dashboard
- Lottie animated splash screen
- Firebase Cloud Messaging (FCM) push notifications
- Pre-permission notification prompt and denied-state banner
- FCM token injection into the web app
- Social follow modal (WhatsApp, Telegram, Email)
- No-internet and error fallback screens
- Pull-to-refresh (Android)
- Android back-button handling with exit confirmation
- Blocked URL redirects for login flow

## Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.11+)
- Xcode (for iOS builds)
- Android Studio / Android SDK (for Android builds)
- Firebase project with `google-services.json` and `GoogleService-Info.plist` (included)

## Getting Started

```bash
flutter pub get
flutter run
```

### iOS

```bash
cd ios && pod install && cd ..
flutter run -d ios
```

### Android

```bash
flutter run -d android
```

## Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Project Structure

```
lib/
├── main.dart
├── firebase_options.dart
├── constants/app_constants.dart
├── services/
│   ├── connectivity_service.dart
│   ├── notification_service.dart
│   └── storage_service.dart
├── screens/home_screen.dart
├── widgets/
│   ├── splash_screen.dart
│   ├── error_screen.dart
│   ├── social_follow_modal.dart
│   ├── notification_pre_prompt.dart
│   └── notification_denied_banner.dart
└── utils/url_utils.dart
```

## Configuration

| Setting | Location |
|---------|----------|
| Web URL | `lib/constants/app_constants.dart` |
| Social links | `lib/constants/app_constants.dart` |
| Bundle ID | `com.scorefusion.app` |
| Firebase | `google-services.json`, `GoogleService-Info.plist` |

## Push Notifications

1. Run on a physical device (simulators have limited push support).
2. Grant notification permission when prompted.
3. The FCM token is logged in debug mode and injected into the WebView as `window.__fcmToken`.

## License

Configured for the Score Fusion app.