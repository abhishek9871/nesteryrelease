# Nestery - Hotel Booking Aggregation Platform 🏨

[![Flutter](https://img.shields.io/badge/Flutter-3.38.3-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.10.1-0175C2?logo=dart)](https://dart.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red.svg)](LICENSE)

**Nestery** is a revolutionary hotel booking aggregation mobile app that integrates with multiple travel APIs (Booking.com, OYO, Google Maps) to provide users with the best deals, personalized recommendations, and a seamless booking experience.

---

## ✨ Features

### 🔍 **Smart Property Search**
- Multi-platform aggregation (Booking.com, OYO, direct listings)
- Advanced filtering (price, amenities, property type, rating)
- Real-time availability checking
- Price comparison across platforms

### 🏆 **Loyalty Program - "Nestery Navigator Club"**
- Tiered rewards system (Scout → Explorer → Navigator → Globetrotter)
- **Nestery Miles** points for bookings, referrals, and reviews
- Miles redemption for discounts and premium features

### 💎 **Premium Subscription - "Nestery Premium"**
- AI Trip Weaver (advanced itinerary planner)
- SmartPrice Alerts & Arbitrage Deals
- Nestery Shield (price drop protection)
- Exclusive deals and ad-free experience
- **Pricing:** $5.99/month or $59.99/year

### 📱 **Modern UI/UX**
- Hero animations between screens
- Shimmer loading states
- Haptic feedback for interactions
- Progressive image loading
- Dark mode support
- Responsive design (phone & tablet)

### 🔐 **Secure Authentication**
- JWT-based authentication
- Secure token storage (Flutter Secure Storage)
- Password reset functionality
- Auto-login with token refresh

### 📊 **Complete Booking Management**
- View upcoming, active, and past bookings
- Booking cancellation
- Special requests handling
- Booking confirmation codes

---

## 🚀 Getting Started

### Prerequisites

- **Flutter SDK:** 3.38.3 or higher ([Install Flutter](https://docs.flutter.dev/get-started/install))
- **Dart SDK:** 3.10.1 or higher (included with Flutter)
- **Android Studio** (for Android development) or **Xcode** (for iOS development)
- **Git**

### Installation

1. **Clone the repository:**
   ```bash
   git clone https://github.com/yourusername/nestery-flutter.git
   cd nestery-flutter
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate Drift database code:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. **Create `.env` file:**
   ```bash
   cp .env.example .env
   ```

   Then edit `.env` with your API keys:
   ```env
   API_BASE_URL=http://localhost:3000/v1
   GOOGLE_MAPS_API_KEY=your_google_maps_api_key
   STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key
   ANALYTICS_ENABLED=true
   ENVIRONMENT=development
   ```

5. **Run the app:**
   ```bash
   # For development
   flutter run

   # For release build
   flutter build apk --release  # Android
   flutter build ios --release  # iOS
   ```

---

## 🏗️ Project Structure

```
nestery-flutter/
├── lib/
│   ├── main.dart                      # App entry point
│   ├── screens/                       # UI screens (15 screens)
│   ├── models/                        # Data models
│   ├── providers/                     # Riverpod state management
│   ├── services/                      # API services
│   ├── data/repositories/             # Data access layer
│   ├── core/network/                  # API client
│   ├── core/db/                       # Drift/SQLite cache
│   ├── widgets/                       # Reusable components
│   └── utils/                         # Constants, routing
├── assets/                            # Images, icons, animations
├── test/                              # Tests
├── android/                           # Android platform
├── ios/                               # iOS platform
└── pubspec.yaml                       # Dependencies
```

---

## 🛠️ Tech Stack

- **Flutter 3.38.3** - Cross-platform UI
- **Riverpod** - State management
- **GoRouter** - Routing
- **Dio** - HTTP client with caching
- **Drift** - SQLite database
- **Firebase** - Analytics (optional)

---

## 🏃 Running the Backend

The app requires the **Nestery Backend** API:

```bash
cd ../nestery-backend
npm install
cp .env.example .env
docker-compose up -d
npm run migration:run
npm run start:dev
```

Backend runs at `http://localhost:3000`

---

## 🙏 Acknowledgments

Built with ❤️ using Flutter and open-source packages.

*Last Updated: November 22, 2025*
