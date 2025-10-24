# Allnimall - Smart QR Pet Collar Platform 🐾

<div align="center">
  
  <h3>Platform digital yang menghubungkan pemilik hewan peliharaan dengan komunitas</h3>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.x-blue)](https://flutter.dev)
  [![Supabase](https://img.shields.io/badge/Supabase-Backend-green)](https://supabase.com)
  [![License](https://img.shields.io/badge/License-Private-red)](LICENSE)
</div>

## 📱 Tentang Allnimall

Allnimall adalah aplikasi cross-platform yang mengintegrasikan kalung kucing akrilik ber-QR code dengan profil digital komprehensif. Setiap QR code tertaut ke profil online yang berfungsi sebagai:

- 🆔 Identitas digital hewan peliharaan
- 🏥 Catatan kesehatan lengkap
- 🚨 Alat bantu pencarian saat hewan hilang
- 📍 Tracking lokasi pindaian QR

## ✨ Fitur Utama

### 🔐 Authentication

- Phone OTP authentication via Supabase
- Secure session management
- Auto-login functionality

### 📋 Pet Profile Management

- Public pet profile dengan tabs (Biodata, Kesehatan, Galeri)
- Multiple photos gallery
- Edit dan update profil real-time
- QR code activation system

### 🚨 Lost Pet Feature

- One-tap lost pet reporting
- Emergency contact display
- Custom lost message
- Real-time status updates

### 📍 Location Tracking

- Scan history dengan geolocation
- Map visualization
- Location privacy controls
- Real-time tracking untuk lost pets

### 🎨 Beautiful UI/UX

- Mobile-first design
- Fun, clean, modern aesthetic
- Smooth animations & micro-interactions
- Purple & Pink color scheme
- Responsive across all devices

## 🏗️ Architecture

Project ini menggunakan **Clean Architecture** dengan:

- **State Management**: Riverpod
- **Routing**: Go Router
- **Backend**: Supabase (Auth, Database, Storage)
- **Pattern**: Usecase pattern untuk business logic

```
lib/
├── core/                 # Core utilities, theme, constants
│   ├── config/          # App configuration
│   ├── constants/       # Colors, strings, assets, dimensions
│   ├── error/           # Error handling
│   ├── theme/           # App theme
│   └── utils/           # Utilities & validators
│
├── features/            # Feature modules
│   ├── auth/           # Authentication feature
│   │   ├── data/       # Data sources, models, repositories
│   │   ├── domain/     # Entities, repositories, usecases
│   │   └── presentation/  # UI, providers, widgets
│   │
│   ├── pet/            # Pet management feature
│   ├── qr/             # QR code feature
│   └── location/       # Location tracking feature
│
└── main.dart           # App entry point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / Xcode (untuk mobile development)
- Supabase account

### Installation

1. **Clone repository**

```bash
git clone https://github.com/yourusername/allnimall_qr.git
cd allnimall_qr
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Setup environment variables**

```bash
cp .env.example .env
# Edit .env dan isi dengan Supabase credentials
```

4. **Setup database**

- Ikuti instruksi di `database/README.md`
- Run migration files di Supabase SQL Editor

5. **Run the app**

```bash
# Development
flutter run

# Web
flutter run -d chrome

# Android
flutter run -d android

# iOS
flutter run -d ios
```

## 📦 Dependencies

### Core

- `flutter_riverpod` - State management
- `go_router` - Routing
- `supabase_flutter` - Backend & Auth
- `google_fonts` - Typography

### UI & Animation

- `flutter_animate` - Animations
- `cached_network_image` - Image caching
- `shimmer` - Loading effects

### Location & Maps

- `geolocator` - Geolocation
- `google_maps_flutter` - Maps
- `geocoding` - Reverse geocoding

### Utils

- `dartz` - Functional programming
- `equatable` - Value equality
- `logger` - Logging
- `uuid` - UUID generation

## 🎨 Design System

### Color Palette

- **Primary**: `#8A2BE2` (BlueViolet)
- **Secondary**: `#FF69B4` (HotPink)
- **Accent**: `#FFD700` (Gold), `#40E0D0` (Turquoise)
- **Neutral**: White, Light Grey

### Typography

- **Headers**: Poppins (Bold, SemiBold)
- **Body**: Nunito (Regular, Medium)

## 🗺️ Roadmap

### MVP (Current)

- [x] Project setup & architecture
- [x] Phone OTP authentication
- [x] Database schema & migrations
- [ ] QR routing system
- [ ] Public pet profile
- [ ] Pet management dashboard
- [ ] Lost pet feature
- [ ] Location tracking

### Phase 1.5

- [ ] Health records & reminders
- [ ] Push notifications
- [ ] Anonymous chat
- [ ] Photo gallery enhancements

### Phase 2.0

- [ ] Community features
- [ ] Premium subscription
- [ ] Vet clinic integration
- [ ] Dog support expansion

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Generate coverage report
genhtml coverage/lcov.info -o coverage/html
```

## 📄 License

This project is private and proprietary. All rights reserved.

## 🤝 Contributing

This is a private project. For any questions or suggestions, please contact the team.

## 📞 Support

For support, email support@allnimall.com

---

<div align="center">
  Made with ❤️ by Allnimall Team
</div>
