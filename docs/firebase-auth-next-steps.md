# Firebase Auth Migration - Next Steps

**Status:** 🔄 30% Complete - Database Ready, Start Firebase Setup  
**Last Updated:** October 8, 2025

---

## ✅ What's Done

- [x] **Database Migration Complete** (Phase 1)
  - `customers.name` → nullable ✅
  - `customers.auth_id` → TEXT (from UUID) ✅
  - `customers.auth_provider` → constraint added ✅
  - Indexes created ✅

---

## 🔥 Next Steps (Start Now)

### Phase 2: Firebase Setup (2-3 hours)

#### Step 1: Create Firebase Project (30 mins)

```bash
# 1. Go to Firebase Console
https://console.firebase.google.com/

# 2. Click "Add Project"
# 3. Project name: allnimall-qr-prod
# 4. Disable Google Analytics (optional)
# 5. Click Create Project
```

**Result:** Firebase project created ✅

---

#### Step 2: Enable Phone Authentication (5 mins)

```bash
# In Firebase Console
1. Go to Authentication → Get Started
2. Click "Sign-in method" tab
3. Click "Phone" provider
4. Toggle Enable → Save
```

**Quota:** 10,000 FREE verifications/month ✅

---

#### Step 3: Setup Android App (30 mins)

```bash
# 1. Firebase Console → Project Settings
# 2. Click Android icon (Add App)
# 3. Android package name: com.allnimall.qr
#    (check: android/app/build.gradle.kts)
# 4. Download google-services.json
# 5. Move to: android/app/google-services.json
```

**Update `android/build.gradle.kts`:**

```kotlin
buildscript {
    dependencies {
        // ... existing deps
        classpath("com.google.gms:google-services:4.4.0")  // ADD THIS
    }
}
```

**Update `android/app/build.gradle.kts`:**

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ADD THIS
}
```

---

#### Step 4: Setup iOS App (30 mins)

```bash
# 1. Firebase Console → Project Settings
# 2. Click iOS icon (Add App)
# 3. iOS bundle ID: com.allnimall.qr
#    (check: ios/Runner/Info.plist → CFBundleIdentifier)
# 4. Download GoogleService-Info.plist
# 5. Open Xcode: ios/Runner.xcworkspace
# 6. Drag GoogleService-Info.plist to Runner/ folder
#    (check "Copy items if needed")
```

**Update `ios/Runner/Info.plist`:**

```xml
<!-- Add before </dict></plist> -->
<key>CFBundleURLTypes</key>
<array>
    <dict>
        <key>CFBundleTypeRole</key>
        <string>Editor</string>
        <key>CFBundleURLSchemes</key>
        <array>
            <!-- Get from GoogleService-Info.plist: REVERSED_CLIENT_ID -->
            <string>com.googleusercontent.apps.YOUR-CLIENT-ID</string>
        </array>
    </dict>
</array>
```

---

#### Step 5: Add Flutter Dependencies (15 mins)

**Update `pubspec.yaml`:**

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Existing
  supabase_flutter: ^2.6.0
  riverpod: ^2.6.1
  go_router: ^14.6.2
  # ... other deps

  # NEW: Add these
  firebase_core: ^3.6.0
  firebase_auth: ^5.3.1
```

**Run:**

```bash
flutter pub get
```

---

#### Step 6: Generate Firebase Options (15 mins)

```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Generate firebase_options.dart
flutterfire configure --project=allnimall-qr-prod

# Select platforms: Android, iOS, Web
# This will auto-generate: lib/firebase_options.dart
```

---

#### Step 7: Initialize Firebase in App (15 mins)

**Update `lib/main.dart`:**

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';  // Auto-generated

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase FIRST
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Then Supabase
  await Supabase.initialize(
    url: SupabaseConfig.supabaseUrl,
    anonKey: SupabaseConfig.supabaseAnonKey,
  );

  runApp(const ProviderScope(child: MyApp()));
}
```

---

## 🧪 Verify Firebase Setup

```bash
# Run app and check logs
flutter run --debug

# Expected in logs:
# ✅ [firebase_core] Firebase initialized successfully
# ✅ [firebase_auth] FirebaseAuth instance created
```

**If successful, Phase 2 is complete! ✅**

---

## 📋 Next: Phase 3 - Code Implementation (4-6 hours)

Once Phase 2 is done, we'll implement:

1. **Firebase Auth Data Source** (1.5 hours)

   - `FirebaseAuthRemoteDataSourceImpl`
   - Phone OTP methods

2. **Customer Data Source** (1 hour)

   - `CustomerRemoteDataSourceImpl`
   - Create/get customer in Supabase

3. **Auth Repository** (1.5 hours)

   - Update `AuthRepositoryImpl`
   - Integrate Firebase + Supabase

4. **UI Updates** (1-2 hours)
   - Update login page
   - Update OTP page
   - Update providers

**Detailed code snippets available in:**
`docs/firebase-auth-migration-plan.md` → Phase 3

---

## ⚠️ Common Issues & Solutions

### Issue 1: `google-services.json` not found

```bash
# Solution: Verify file location
ls -la android/app/google-services.json

# Should exist and have content
cat android/app/google-services.json | grep project_id
```

### Issue 2: iOS build fails - GoogleService-Info.plist not found

```bash
# Solution: Open Xcode and check
# 1. Open: ios/Runner.xcworkspace (NOT .xcodeproj!)
# 2. Check GoogleService-Info.plist is in Runner folder
# 3. Right-click → Show in Finder → verify path
```

### Issue 3: FlutterFire CLI not found

```bash
# Solution: Add to PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"

# Or add to ~/.zshrc permanently
echo 'export PATH="$PATH":"$HOME/.pub-cache/bin"' >> ~/.zshrc
source ~/.zshrc
```

### Issue 4: Firebase already initialized error

```dart
// Solution: Only initialize once
if (Firebase.apps.isEmpty) {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}
```

---

## 📊 Progress Tracker

| Phase                   | Status         | Time Spent | Remaining |
| ----------------------- | -------------- | ---------- | --------- |
| Phase 1: Database       | ✅ Done        | ~1 hour    | 0         |
| Phase 2: Firebase Setup | 🔄 **CURRENT** | ~20 min    | 1-2 hours |
| Phase 3: Code           | ⏳ Next        | 0          | 4-6 hours |
| Phase 4: Testing        | ⏳ Pending     | 0          | 2-3 hours |
| Phase 5: Deploy         | ⏳ Pending     | 0          | 1-2 hours |
| Phase 6: Docs           | ⏳ Pending     | 0          | 1 hour    |

**Overall:** 35% Complete

**✅ Completed Today:**

- Firebase dependencies added (firebase_core, firebase_auth)
- FlutterFire CLI installed
- Setup guide created: `FIREBASE_SETUP_STEPS.md`

---

## 🎯 Today's Goal

✅ Complete Phase 2 (Firebase Setup)

**Checklist:**

- [x] Dependencies added (firebase_core, firebase_auth) ✅
- [x] FlutterFire CLI installed ✅
- [x] Firebase project created (allnimall) ✅
- [x] firebase_options.dart generated ✅
- [x] Android app registered (google-services.json) ✅
- [x] iOS app registered (GoogleService-Info.plist) ✅
- [x] Android Gradle plugins configured ✅
- [x] iOS URL schemes added to Info.plist ✅
- [x] Firebase initialized in main.dart ✅
- [x] Code analysis passed ✅
- [ ] **Phone auth enabled** ⬅️ **DO THIS NOW** (5 min)
- [ ] Test app runs without errors

**Estimated Time:** 5 minutes remaining for Phase 2!

**📖 SEE SUMMARY:** `PHASE2_COMPLETE.md` ⬅️ **PHASE 2 ALMOST DONE!**

---

## 💬 Need Help?

**Stuck on setup?** Run this and share output:

```bash
# Check Flutter doctor
flutter doctor -v

# Check Firebase dependencies
flutter pub deps | grep firebase

# Check files exist
ls -la android/app/google-services.json
ls -la ios/Runner/GoogleService-Info.plist
ls -la lib/firebase_options.dart
```

**Ready to code?** See:

- Full migration plan: `docs/firebase-auth-migration-plan.md`
- Detailed code: Phase 3 in migration plan

---

**Let's go! 🚀**
