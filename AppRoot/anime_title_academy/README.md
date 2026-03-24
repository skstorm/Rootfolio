# anime_title_academy

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Rewarded Ads

### Fake ad flow on desktop
```powershell
flutter run -d windows --dart-define=FORCE_QUOTA_AND_ADS=true --dart-define=REWARDED_AD_MODE=fake
```

### Real test rewarded ads on Android
```powershell
flutter run -d android --dart-define=FORCE_QUOTA_AND_ADS=true --dart-define=REWARDED_AD_MODE=test
```

### Production release prerequisites
- Android AdMob app id:
  Set `admob.android.app.id=<your-app-id>` in `android/local.properties`
  or pass `-PADMOB_ANDROID_APP_ID=<your-app-id>` to Gradle.
- Rewarded ad unit id:
  Pass `--dart-define=ADMOB_ANDROID_REWARDED_AD_UNIT_ID=<your-unit-id>` when running/building Android production mode.

### Example production run
```powershell
flutter run -d android --release --dart-define=REWARDED_AD_MODE=production --dart-define=ADMOB_ANDROID_REWARDED_AD_UNIT_ID=ca-app-pub-xxxxxxxxxxxxxxxx/xxxxxxxxxx
```

Release safety rules:
- Android release builds fail early if the AdMob app id is missing.
- Mobile production mode fails on app startup if the rewarded ad unit id is missing.
