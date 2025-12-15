# Allnimall - Smart QR Pet Collar Platform 🐾

<div align="center">
  
  <h3>Platform digital yang menghubungkan pemilik hewan peliharaan dengan komunitas</h3>
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.8.1-blue)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Auth-orange)](https://firebase.google.com)
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

- Phone OTP authentication via Firebase Auth (FREE tier: 10,000 verifications/month)
- Firebase + Supabase integration for user management
- Secure session management with auto-login
- Smart user detection (new vs existing users)
- Customer profile auto-creation on first login

### 📋 Pet Profile Management

- Public pet profile dengan tabs (Biodata, Kesehatan, Galeri)
- Instagram-like photo/video gallery with social features
- Photo likes, comments, and share functionality
- Video upload and playback support
- Edit dan update profil real-time
- QR code activation system with new collar detection

### 🏥 Health Management System

- Dynamic health parameters per pet category
- Health scoring system (healthy/needs_attention)
- Health history tracking with timeline
- Pet schedules (recurring & one-time)
  - Grooming, Medical Checkup, Vaccination
  - Medication, Feeding, Playtime, Bath
  - Birthday reminders, Nail Trimming, Dental Care
- Calendar view for schedule management
- Weight tracking with history
- Vaccination & sterilization status tracking

### 📸 Social Gallery Features

- Photo/video gallery with grid and detail views
- Like/unlike photos (tracked by user ID or IP)
- Comment system on photos
- Share photos to external platforms
- Photo metadata (upload date, like count, comment count)
- Video thumbnail generation

### 🚨 Lost Pet Feature

- One-tap lost pet reporting
- Emergency contact display
- Custom lost message
- Real-time status updates

### 📍 Location Tracking

- Scan history dengan geolocation
- Google Maps integration with map/list toggle views
- Reverse geocoding for address display
- Location privacy controls
- Real-time tracking untuk lost pets
- Scan log tracking with IP and user agent

### 🎨 Beautiful UI/UX

- Mobile-first design
- Fun, clean, modern aesthetic
- Smooth animations & micro-interactions
- Purple & Pink color scheme
- Responsive across all devices

## 🏗️ Architecture

Project ini menggunakan **Clean Architecture** dengan:

- **State Management**: Riverpod 2.6.1 with code generation
- **Routing**: Go Router 14.6.2 with declarative routing
- **Backend**: 
  - Firebase Auth (Phone OTP authentication)
  - Supabase (Database, Storage, Realtime)
- **Database**: Multi-schema PostgreSQL structure (public, pet, social, pos)
- **Pattern**: Usecase pattern untuk business logic
- **Code Generation**: build_runner for Riverpod, Go Router, and JSON serialization

```
lib/
├── core/                 # Core utilities, theme, constants
│   ├── config/          # App configuration (Supabase, Firebase)
│   ├── constants/       # Colors, strings, assets, dimensions
│   ├── error/           # Error handling (exceptions, failures)
│   ├── providers/       # Service providers
│   ├── router/          # Go Router configuration
│   ├── services/        # Core services (image, location, storage, media)
│   ├── theme/           # App theme
│   ├── utils/           # Utilities & validators
│   └── widgets/         # Reusable widgets
│
├── features/            # Feature modules
│   ├── auth/           # Authentication feature (Firebase Auth)
│   │   ├── data/       # Firebase datasource, repositories
│   │   ├── domain/     # Entities, repositories, usecases
│   │   └── presentation/  # UI, providers, widgets
│   │
│   ├── customer/       # Customer management
│   ├── dashboard/     # Pet dashboard
│   └── pet/           # Pet management feature
│       ├── data/       # Models, datasources, repositories
│       ├── domain/     # Entities, repositories, usecases (28 usecases)
│       └── presentation/  # Pages, providers, widgets
│
└── main.dart           # App entry point
```

### Database Schema Structure

The database uses a **multi-schema architecture**:

- **`public`**: Core system tables (customers, activity_logs, app_settings)
- **`pet`**: Pet-related tables (pets, pet_healths, pet_photos, pet_schedules, pet_timelines, scan_logs, health_parameter_definitions, photo_likes, photo_comments, photo_shares)
- **`social`**: Community features (reserved for future)
- **`pos`**: Business management (reserved for future)

All tables have Row Level Security (RLS) policies for data protection.

## 🚀 Getting Started

### Prerequisites

- Flutter SDK 3.8.1 or higher
- Dart SDK 3.8.1 or higher
- Android Studio / Xcode (untuk mobile development)
- Firebase account (for Phone Authentication)
- Supabase account (for Database & Storage)

### Installation

1. **Clone repository**

```bash
git clone https://github.com/glenrynaldyhermanus/allnimallv3.git
cd allnimallv3
```

2. **Install dependencies**

```bash
flutter pub get
```

3. **Setup Firebase**

- Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
- Enable Phone Authentication in Authentication → Sign-in method
- For Android: Add app with package name `com.allnimall.app`, download `google-services.json` to `android/app/`
- For iOS: Add app with bundle ID, download `GoogleService-Info.plist` to `ios/Runner/`
- Firebase credentials are already configured in `firebase_options.dart` for web

4. **Setup Supabase**

- Create a Supabase project at [Supabase](https://supabase.com)
- Copy your project URL and anon key
- For mobile/desktop: Create `.env` file in project root:
  ```bash
  SUPABASE_URL=your_supabase_url
  SUPABASE_ANON_KEY=your_supabase_anon_key
  ```
- For web: Credentials are hardcoded in `lib/core/config/supabase_config.dart` (production)

5. **Setup database**

- Run all migration files in order from `database/` folder:
  1. `create_schemas_first.sql` - Create schemas
  2. `schema.sql` - Main schema
  3. `add_pet_photos_and_scan_logs.sql` - Photo and scan log tables
  4. `add_pet_timelines.sql` - Timeline table
  5. `add_default_schedule_types.sql` - Schedule types
  6. `dynamic_health_system.sql` - Health system tables
  7. `add_qr_codes_table.sql` - QR codes table
  8. `fix_rls_policies.sql` - RLS policies
  9. `storage_policies.sql` - Storage bucket policies
- Run migrations in Supabase SQL Editor

6. **Run the app**

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

- `flutter_riverpod` ^2.6.1 - State management
- `riverpod_annotation` ^2.6.1 - Riverpod annotations
- `go_router` ^14.6.2 - Declarative routing
- `supabase_flutter` ^2.9.1 - Supabase backend (Database, Storage, Realtime)
- `google_fonts` ^6.2.1 - Typography

### Authentication

- `firebase_core` ^4.1.1 - Firebase initialization
- `firebase_auth` ^6.1.0 - Firebase Phone OTP authentication

### UI & Animation

- `flutter_animate` ^4.5.0 - Animations
- `cached_network_image` ^3.4.1 - Image caching
- `shimmer` ^3.0.0 - Loading effects
- `lucide_icons_flutter` ^3.1.4 - Icon library
- `flutter_svg` ^2.0.16 - SVG support
- `confetti` ^0.7.0 - Confetti animations
- `table_calendar` ^3.1.0 - Calendar widget for schedules

### Image & Video Handling

- `image_picker` ^1.1.2 - Image/video picker
- `image_cropper` ^8.0.2 - Image cropping
- `flutter_image_compress` ^2.3.0 - Image compression
- `video_player` ^2.9.2 - Video playback
- `video_thumbnail` ^0.5.3 - Video thumbnail generation

### QR Code & Location

- `qr_code_scanner` ^1.0.1 - QR code scanning
- `geolocator` ^13.0.2 - Geolocation
- `google_maps_flutter` ^2.10.0 - Google Maps
- `geocoding` ^3.0.0 - Reverse geocoding

### Sharing & Permissions

- `url_launcher` ^6.3.1 - Launch URLs
- `share_plus` ^10.0.2 - Share content
- `permission_handler` ^11.3.1 - Permission management

### Utils

- `dartz` ^0.10.1 - Functional programming (Either, Option)
- `equatable` ^2.0.7 - Value equality
- `logger` ^2.5.0 - Logging
- `uuid` ^4.5.1 - UUID generation
- `intl` ^0.20.1 - Internationalization & date formatting
- `shared_preferences` ^2.3.4 - Local storage
- `flutter_dotenv` ^5.2.1 - Environment variables
- `path_provider` ^2.1.5 - File system paths

### Code Generation (Dev)

- `build_runner` ^2.4.14 - Code generation runner
- `riverpod_generator` ^2.6.2 - Riverpod code generation
- `go_router_builder` ^2.7.1 - Go Router code generation
- `json_serializable` ^6.9.2 - JSON serialization
- `mockito` ^5.4.4 - Mocking for tests

## 🗄️ Database

### Schema Structure

The database uses a **multi-schema PostgreSQL architecture** managed by Supabase:

#### Public Schema
- `customers` - User/customer data with Firebase UID integration
- `activity_logs` - System activity tracking
- `app_settings` - Application configuration

#### Pet Schema
- `pets` - Pet profiles and basic information
- `pet_healths` - Health records with dynamic parameters (JSONB)
- `pet_health_history` - Historical health parameter changes
- `health_parameter_definitions` - Dynamic health parameters per pet category
- `pet_photos` - Photo/video gallery with metadata
- `photo_likes` - Photo like tracking (user ID or IP)
- `photo_comments` - Photo comments system
- `photo_shares` - Photo share tracking
- `pet_schedules` - Recurring and one-time schedules
- `schedule_types` - Schedule type definitions (Grooming, Vaccination, etc.)
- `pet_timelines` - Activity feed (photos, schedules, weight updates, birthdays)
- `pet_scan_logs` - QR scan history with geolocation
- `pet_categories` - Pet category definitions (Cat, Dog, etc.)
- `qr_codes` - QR code tracking

#### Social Schema (Reserved)
- Reserved for future community features

#### POS Schema (Reserved)
- Reserved for future business management features

### Key Features

- **Row Level Security (RLS)**: All tables have RLS policies for data protection
- **Multi-tenancy**: Owner-based access control
- **Public/Private Data**: Timeline and photo visibility controls
- **Dynamic Health System**: Category-specific health parameters
- **Audit Trail**: Health history tracking for all parameter changes

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

### MVP (Completed ✅)

- [x] Project setup & Clean Architecture
- [x] Firebase Phone OTP authentication
- [x] Multi-schema database structure & migrations
- [x] QR code routing system with new collar detection
- [x] Public pet profile with tabs (Biodata, Health, Gallery)
- [x] Pet management dashboard
- [x] Lost pet feature (report & mark found)
- [x] Location tracking with Google Maps
- [x] Scan history with geolocation
- [x] Photo/video gallery with upload
- [x] Dynamic health system with scoring
- [x] Pet schedules & calendar view
- [x] Pet timelines (activity feed)
- [x] Instagram-like gallery (likes, comments, shares)
- [x] Health history tracking
- [x] Weight tracking

### Phase 1.5 (In Progress)

- [ ] Health reminder notifications (push notifications)
- [ ] Recurring schedule automation
- [ ] Anonymous chat between finders and owners
- [ ] Photo gallery filters & search
- [ ] Health document upload (PDF certificates)

### Phase 2.0 (Planned)

- [ ] Community features (forums, nearby play areas)
- [ ] Premium subscription model
- [ ] Vet clinic integration
- [ ] Multi-species expansion (dogs, etc.)
- [ ] Analytics dashboard for owners
- [ ] Social sharing enhancements

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
