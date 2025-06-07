# Firebase Diagnostic Report - Nestery Flutter Project

**Project:** nestery-flutter  
**Branch:** mahadev  
**Date:** Generated for Firebase startup failure research  
**Location:** C:\Users\VASU\Desktop\nesteryrelease\nestery-flutter

---

## 1. Android Gradle Plugin Version

**Found in:** `nestery-flutter/android/settings.gradle.kts` (line 21)  
**Version:** `8.7.0`

```kotlin
id("com.android.application") version "8.7.0" apply false
```

---

## 2. Kotlin Gradle Plugin Version

**Found in:** `nestery-flutter/android/settings.gradle.kts` (line 22)  
**Version:** `2.1.21`

```kotlin
id("org.jetbrains.kotlin.android") version "2.1.21" apply false
```

---

## 3. Gradle Distribution Version

**Found in:** `nestery-flutter/android/gradle/wrapper/gradle-wrapper.properties` (line 5)  
**Full URL:** `https://services.gradle.org/distributions/gradle-8.10.2-all.zip`  
**Version:** `8.10.2`

---

## 4. Flutter and Dart SDK Versions

**Flutter Version:** `3.29.3` (Channel stable)  
**Dart Version:** `3.7.2`  
**Framework Revision:** `ea121f8859` (8 weeks ago, 2025-04-11 19:10:07 +0000)  
**Engine Revision:** `cf56914b32`  
**DevTools Version:** `2.42.3`

### Additional Environment Details:
- **Platform:** Microsoft Windows [Version 10.0.26100.4202]
- **Android SDK:** 34.0.0
- **Platform:** android-35, build-tools 34.0.0
- **Java:** Java(TM) SE Runtime Environment (build 21.0.7+8-LTS-245)
- **NDK Version:** `27.0.12077973` (from app build.gradle.kts)

### Flutter Doctor Output:
```
[√] Flutter (Channel stable, 3.29.3, on Microsoft Windows [Version 10.0.26100.4202], locale en-IN)
[√] Windows Version (11 Home Single Language 64-bit, 24H2, 2009)
[√] Android toolchain - develop for Android devices (Android SDK version 34.0.0)
[√] Chrome - develop for the web
[√] Visual Studio - develop Windows apps (Visual Studio Community 2022 17.14.0)
[!] Android Studio (not installed)
[√] VS Code (version 1.100.3)
[√] Connected device (4 available)
[√] Network resources
```

---

## 5. Key Firebase Dependencies

**Firebase Core:** `^2.24.2`  
**Firebase Analytics:** `^10.8.0`  
**Firebase Crashlytics:** `^3.4.9`

**Flutter SDK Constraint:** `>=3.0.0 <4.0.0`

---

## 6. Complete Project Dependencies (pubspec.yaml)

```yaml
name: nestery_flutter
description: Nestery mobile application for hotel booking and management
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.6
  # State management
  flutter_riverpod: ^2.4.9
  provider: ^6.1.5
  # Navigation
  go_router: ^15.1.2
  # Network and API
  dio: ^5.4.0
  http: ^1.1.2
  dio_cache_interceptor: ^4.0.3
  # Replaced sembast store with drift store for caching
  http_cache_drift_store: ^7.0.0
  drift: ^2.15.0
  sqlite3_flutter_libs: ^0.5.33 # For native SQLite bindings, updated to match drift_dev
  # Storage and persistence
  flutter_secure_storage: ^9.0.0
  shared_preferences: ^2.2.2
  # File Picker
  file_picker: ^10.1.9
  # Environment configuration
  flutter_dotenv: ^5.1.0
  # UI components
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.1
  shimmer: ^3.0.0
  carousel_slider: ^4.2.1
  flutter_staggered_grid_view: ^0.7.0
  flutter_rating_bar: ^4.0.1
  # Maps and location
  google_maps_flutter: ^2.5.3
  geolocator: ^10.1.0
  # Date and time
  intl: ^0.19.0
  # Analytics and monitoring
  firebase_core: ^2.24.2
  firebase_analytics: ^10.8.0
  firebase_crashlytics: ^3.4.9
  # Social sharing
  share_plus: ^7.2.1
  # Payments
  flutter_stripe: ^9.6.0 # Updated to match lock file
  # Animations
  lottie: ^2.7.0
  # QR Code and Image Picker
  qr_flutter: ^4.1.0
  image_picker: ^1.1.2
  # Utilities
  url_launcher: ^6.2.2
  package_info_plus: ^4.2.0
  path: ^1.9.0 # For path manipulation with Drift/sqflite
  device_info_plus: ^9.1.1
  connectivity_plus: ^5.0.2
  path_provider: ^2.1.1
  google_mobile_ads: ^6.0.0 # Added Google AdMob
  uuid: ^4.2.2
  flutter_native_splash: ^2.4.4 # Updated to match lock file
  # Charting
  fl_chart: ^0.68.0
  syncfusion_flutter_charts: ^24.1.43
  # Code generation (needed at runtime)
  freezed_annotation: ^2.4.4
  json_annotation: ^4.8.1

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.1
  mockito: ^5.4.4 # Updated as per task
  build_runner: ^2.4.7
  drift_dev: ^2.15.0 # For Drift code generation
  freezed: ^2.4.7 # For freezed models (dev only)
  json_serializable: ^6.8.0
  flutter_launcher_icons: ^0.13.1
  integration_test:
    sdk: flutter

flutter:
  uses-material-design: true
  assets:
    - assets/images/
    - assets/icons/
    - assets/animations/
    - .env

flutter_icons:
  android: "launcher_icon"
  ios: true
  image_path: "assets/icons/app_icon.png"
  adaptive_icon_background: "#FFFFFF"
  adaptive_icon_foreground: "assets/icons/app_icon_foreground.png"

flutter_native_splash:
  color: "#1E88E5"
  image: assets/images/splash_logo.png
  android: true
  ios: true
```

---

## Summary

This is a Flutter 3.29.3 project using:
- **Android Gradle Plugin:** 8.7.0
- **Kotlin:** 2.1.21  
- **Gradle:** 8.10.2
- **Firebase Core:** 2.24.2

All version information extracted from the current `mahadev` branch state for Firebase startup failure research.
