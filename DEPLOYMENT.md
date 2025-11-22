# Nestery Flutter App - Deployment Guide

This comprehensive guide covers building, testing, and deploying the Nestery Flutter application to production.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Environment Setup](#environment-setup)
3. [Build Configuration](#build-configuration)
4. [Testing](#testing)
5. [Android Deployment](#android-deployment)
6. [iOS Deployment](#ios-deployment)
7. [Backend Requirements](#backend-requirements)
8. [Post-Deployment](#post-deployment)

---

## Prerequisites

### Required Software

- **Flutter SDK**: 3.38.3 or higher
- **Dart SDK**: 3.10.1 or higher
- **Android Studio**: Latest stable version (for Android builds)
- **Xcode**: 15.0 or higher (for iOS builds, macOS only)
- **Git**: For version control

### Developer Accounts

- **Google Play Console**: For Android app distribution
- **Apple Developer Program**: For iOS app distribution ($99/year)
- **Stripe Account**: For payment processing
- **Firebase Project**: For analytics and notifications (optional)

---

## Environment Setup

### 1. Clone and Configure

```bash
git clone https://github.com/yourusername/nesteryrelease.git
cd nesteryrelease/nestery-flutter
```

### 2. Configure Environment Variables

Create `.env` file (if not exists) from `.env.example`:

```bash
cp .env.example .env
```

Update `.env` with production values:

```env
API_BASE_URL=https://api.nestery.com/v1
GOOGLE_MAPS_API_KEY=YOUR_GOOGLE_MAPS_API_KEY
STRIPE_PUBLISHABLE_KEY=pk_live_YOUR_STRIPE_PUBLISHABLE_KEY
ANALYTICS_ENABLED=true
ENVIRONMENT=production
```

⚠️ **Important**: Never commit `.env` with production keys to version control.

### 3. Install Dependencies

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## Build Configuration

### Android Configuration

#### 1. Update Version

Edit `android/app/build.gradle.kts`:

```kotlin
defaultConfig {
    applicationId = "com.nestery.app"
    versionCode = 1  // Increment for each release
    versionName = "1.0.0"  // Semantic versioning
}
```

#### 2. Configure Signing

Create `android/key.properties`:

```properties
storePassword=YOUR_KEYSTORE_PASSWORD
keyPassword=YOUR_KEY_PASSWORD
keyAlias=nestery-key
storeFile=../upload-keystore.jks
```

Generate upload keystore:

```bash
keytool -genkey -v -keystore upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias nestery-key
```

Move `upload-keystore.jks` to `android/` directory.

Update `android/app/build.gradle.kts` to use signing config (already configured).

### iOS Configuration

#### 1. Update Version

Edit `ios/Runner/Info.plist`:

```xml
<key>CFBundleShortVersionString</key>
<string>1.0.0</string>
<key>CFBundleVersion</key>
<string>1</string>
```

#### 2. Configure App ID

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Update Bundle Identifier to `com.nestery.app`
4. Set Team to your Apple Developer Team

#### 3. Configure Signing

1. In Xcode, go to Signing & Capabilities
2. Enable "Automatically manage signing"
3. Select your development team
4. Xcode will create provisioning profiles

---

## Testing

### Run Analyzer

```bash
flutter analyze
```

Fix all errors and warnings before building.

### Run Tests

```bash
flutter test
```

Ensure all tests pass.

### Build and Test Locally

**Android:**
```bash
flutter build apk --release
flutter install
```

**iOS:**
```bash
flutter build ios --release
# Then run from Xcode on a physical device
```

---

## Android Deployment

### 1. Build Release Bundle

```bash
flutter build appbundle --release
```

Output: `build/app/outputs/bundle/release/app-release.aab`

### 2. Upload to Play Console

1. Go to [Google Play Console](https://play.google.com/console)
2. Create new app or select existing
3. Navigate to "Release" → "Production"
4. Click "Create new release"
5. Upload `app-release.aab`
6. Fill in release notes
7. Review and roll out

### 3. Store Listing

Prepare the following:

- **App Icon**: 512x512 PNG
- **Feature Graphic**: 1024x500 PNG
- **Screenshots**:
  - Phone: At least 2 (1080x1920 or 1080x2340)
  - 7" Tablet: At least 2
  - 10" Tablet: At least 2
- **Short Description**: Max 80 characters
- **Full Description**: Max 4000 characters
- **Privacy Policy URL**: Required

### 4. Content Rating

Complete the content rating questionnaire in Play Console.

---

## iOS Deployment

### 1. Build Release Archive

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select "Any iOS Device (arm64)" as destination
3. Product → Archive
4. Wait for archive to complete

### 2. Upload to App Store Connect

1. Window → Organizer
2. Select your archive
3. Click "Distribute App"
4. Choose "App Store Connect"
5. Follow wizard to upload

### 3. App Store Listing

1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Select your app
3. Fill in metadata:
   - App Name
   - Subtitle
   - Description
   - Keywords
   - Support URL
   - Marketing URL (optional)
   - Privacy Policy URL

### 4. Screenshots

Prepare screenshots for:
- 6.7" Display (iPhone 14 Pro Max): 1290x2796
- 6.5" Display (iPhone 11 Pro Max): 1242x2688
- 5.5" Display (iPhone 8 Plus): 1242x2208
- 12.9" iPad Pro: 2048x2732

### 5. Submit for Review

1. Add build to version
2. Complete all required information
3. Submit for review
4. Typical review time: 24-48 hours

---

## Backend Requirements

### API Endpoints

The app expects the following API endpoints:

#### Authentication
- `POST /auth/register` - User registration
- `POST /auth/login` - User login
- `POST /auth/logout` - User logout
- `POST /auth/refresh` - Refresh auth token

#### Properties
- `GET /properties` - List properties
- `GET /properties/search` - Search properties
- `GET /properties/:id` - Get property details
- `GET /properties/featured` - Get featured properties
- `GET /properties/recommended` - Get recommended properties

#### Bookings
- `POST /bookings` - Create booking
- `GET /bookings` - List user bookings
- `GET /bookings/:id` - Get booking details
- `PUT /bookings/:id/cancel` - Cancel booking

#### Loyalty
- `GET /loyalty/status` - Get loyalty status
- `GET /loyalty/transactions` - Get loyalty transactions
- `POST /loyalty/checkin` - Daily check-in

#### Referrals
- `GET /referrals/stats` - Get referral stats
- `GET /referrals/code` - Get referral code
- `POST /referrals/track` - Track referral

#### Subscriptions
- `GET /subscriptions/current` - Get current subscription
- `POST /subscriptions/checkout` - Create checkout session
- `POST /subscriptions/upgrade` - Upgrade subscription
- `POST /subscriptions/cancel` - Cancel subscription

### Database Schema

Required tables:
- users
- properties
- bookings
- loyalty_transactions
- referrals
- subscriptions

See backend documentation for detailed schema.

---

## Post-Deployment

### 1. Monitor Crash Reports

**Android:**
- Google Play Console → Quality → Android vitals

**iOS:**
- App Store Connect → TestFlight → Crashes
- Xcode → Window → Organizer → Crashes

### 2. Track Analytics

If using Firebase:
- Firebase Console → Analytics
- Monitor user engagement, retention, crashes

### 3. Update Strategy

**Version Numbering:**
- Major: Breaking changes (1.0.0 → 2.0.0)
- Minor: New features (1.0.0 → 1.1.0)
- Patch: Bug fixes (1.0.0 → 1.0.1)

**Release Cycle:**
- Patch releases: As needed
- Minor releases: Monthly
- Major releases: Quarterly or as needed

### 4. Rollback Plan

If critical issues arise:

**Android:**
1. Stop rollout in Play Console
2. Roll back to previous version
3. Fix issue in new build
4. Gradual rollout

**iOS:**
1. Remove build from sale (if critical)
2. Submit hotfix build with expedited review
3. Phased release for future updates

---

## Checklist

### Pre-Release
- [ ] All tests passing
- [ ] No analyzer errors/warnings
- [ ] Version numbers updated
- [ ] Environment variables configured for production
- [ ] Signing configured for both platforms
- [ ] Privacy policy published
- [ ] Terms of service published

### Android
- [ ] App bundle built successfully
- [ ] Store listing complete
- [ ] Screenshots uploaded
- [ ] Content rating completed
- [ ] Release notes written

### iOS
- [ ] Archive built successfully
- [ ] App Store listing complete
- [ ] Screenshots for all sizes uploaded
- [ ] App icons set
- [ ] Build uploaded to App Store Connect
- [ ] All metadata filled

### Post-Release
- [ ] Monitor crash reports
- [ ] Check user reviews
- [ ] Track key metrics
- [ ] Plan next release

---

## Troubleshooting

### Common Issues

**Build fails with dependency errors:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

**iOS code signing issues:**
- Ensure Bundle ID matches App Store Connect
- Check provisioning profiles in Xcode
- Revoke and recreate certificates if needed

**Android upload fails:**
- Ensure versionCode is incremented
- Check for app bundle size limit (150MB)
- Verify signing configuration

---

## Support

For deployment issues:
- Flutter: https://flutter.dev/docs/deployment
- Android: https://developer.android.com/distribute
- iOS: https://developer.apple.com/app-store/

For app-specific issues:
- Create issue on GitHub
- Contact: support@nestery.com

---

**Last Updated**: 2025-11-22
**Version**: 1.0.0
