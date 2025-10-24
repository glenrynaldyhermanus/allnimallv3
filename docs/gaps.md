# Allnimall QR - Implementation Gap Analysis

**Date:** October 8, 2025  
**Source:** Brownfield PRD v2.0  
**Current Status:** MVP ~80% Complete

---

## Executive Summary

**Total Features in Brownfield PRD:** 7 Major Epics (41 Functional Requirements)  
**Implemented (MVP):** 1 Epic equivalent (~14% of planned features)  
**Remaining:** 6 Epics (86% of planned features)

**Estimated Effort:** 18 weeks (~4.5 months) with 5-person team

---

# 1. ✅ COMPLETED (MVP Features)

## What's Already Working

### ✅ Core Infrastructure (100%)

- Flutter 3.8.1 with Clean Architecture
- Supabase backend (Auth, Database, Storage, Realtime)
- Riverpod state management
- Go Router navigation
- Material 3 UI with custom theme (purple/pink)
- Google Maps integration
- Image upload & optimization

### ✅ Authentication (100%)

- Phone OTP via Supabase Auth
- Session management
- Auto-login
- User detection (new vs existing)
- Customer table integration

### ✅ Pet Management (100%)

- Pet CRUD operations
- Public pet profiles with 3 tabs (Biodata, Health, Gallery)
- QR code routing
- New collar detection (name="Allnimall")
- Photo upload & cropping
- Combined profile setup

### ✅ Lost Pet Basic (100%)

- Report lost functionality
- Mark found functionality
- Emergency contact display
- Lost pet banner on public profile

### ✅ Location Tracking (100%)

- Scan logging with geolocation
- Scan history page
- Map/List toggle views
- Google Maps integration
- Reverse geocoding

### ✅ Dashboard (100%)

- Pet list view
- Pull-to-refresh
- Empty states
- Navigation

### ✅ Database Schema (Core Tables)

- customers
- pets
- pet_healths
- pet_photos
- pet_scan_logs
- pet_categories

### ✅ Row Level Security

- RLS policies on all existing tables
- Public/private data separation
- Owner-based access control

---

# 2. ❌ GAPS - What's Missing

## Epic 1: Health Management & Reminders ❌

**Status:** 0% Complete  
**Priority:** High (Phase 1.5)  
**Timeline:** 3 weeks  
**Stories:** 7

### Missing Components:

#### ❌ Database

- [ ] `health_reminders` table
- [ ] Indexes on pet_id, scheduled_date
- [ ] RLS policies for reminders
- [ ] Migration file (005_create_health_reminders.sql)

#### ❌ Domain Layer

- [ ] HealthReminderEntity
- [ ] HealthReminderRepository interface
- [ ] CreateHealthReminderUseCase
- [ ] GetHealthRemindersForPetUseCase
- [ ] UpdateHealthReminderUseCase
- [ ] DeleteHealthReminderUseCase
- [ ] MarkReminderCompleteUseCase

#### ❌ Data Layer

- [ ] HealthReminderModel (JSON serialization)
- [ ] HealthReminderRemoteDataSource
- [ ] HealthReminderRepositoryImpl

#### ❌ Presentation Layer

- [ ] `lib/features/health/presentation/pages/health_reminders_page.dart`
- [ ] `lib/features/health/presentation/pages/add_reminder_page.dart`
- [ ] HealthReminderCard widget
- [ ] Riverpod providers for health reminders

#### ❌ Features

- [ ] Timeline view (Overdue, Today, Upcoming, Completed)
- [ ] Create/Edit reminder form
- [ ] Mark complete functionality
- [ ] Recurring reminders logic
- [ ] Document upload (vaccination certificates)
- [ ] "Health Records" tab in Pet Detail Page

---

## Epic 2: Push Notifications Infrastructure ❌

**Status:** 0% Complete  
**Priority:** High (Phase 1.5)  
**Timeline:** 2 weeks  
**Stories:** 6

### Missing Components:

#### ❌ Firebase Setup

- [ ] Firebase project creation
- [ ] FCM server key configuration
- [ ] APNs certificates
- [ ] `firebase_messaging: ^14.7.0` package
- [ ] `flutter_local_notifications: ^16.3.0` package
- [ ] Platform-specific config (AndroidManifest.xml, Info.plist)

#### ❌ Database

- [ ] `fcm_token` column in customers table
- [ ] `notification_preferences` JSONB column in customers
- [ ] `notification_logs` table
- [ ] Migration files

#### ❌ Backend

- [ ] Supabase edge function: `send-push-notification`
- [ ] Supabase cron function: `schedule-health-reminders`
- [ ] FCM/APNs integration logic
- [ ] Notification preference checking

#### ❌ Frontend

- [ ] Device token registration on app launch
- [ ] Notification preferences screen
- [ ] Deep linking setup for notifications
- [ ] Notification list screen (`notifications_page.dart`)

#### ❌ Features

- [ ] Push notification permission handling
- [ ] Category-based notification toggles
- [ ] Health reminder notifications (3 days, 1 day, same day)
- [ ] Lost pet scan notifications (real-time)
- [ ] Notification delivery logging

---

## Epic 3: Anonymous Chat for Lost Pets ❌

**Status:** 0% Complete  
**Priority:** High (Phase 1.5)  
**Timeline:** 2 weeks  
**Stories:** 7

### Missing Components:

#### ❌ Database

- [ ] `chat_messages` table
- [ ] `chat_rooms` table
- [ ] RLS policies for chat
- [ ] Migration file (006_create_chat_tables.sql)

#### ❌ Domain Layer

- [ ] ChatMessageEntity
- [ ] ChatRoomEntity
- [ ] ChatRepository interface
- [ ] SendMessageUseCase
- [ ] GetChatMessagesUseCase
- [ ] JoinChatRoomUseCase

#### ❌ Data Layer

- [ ] ChatMessageModel
- [ ] ChatRoomModel
- [ ] ChatRemoteDataSource (Supabase Realtime)
- [ ] ChatRepositoryImpl

#### ❌ Presentation Layer

- [ ] `lib/features/chat/presentation/pages/chat_page.dart`
- [ ] ChatBubble widget
- [ ] Riverpod StreamProvider for real-time messages

#### ❌ Features

- [ ] Real-time messaging (< 500ms latency)
- [ ] Anonymous ID generation for finders
- [ ] Location sharing in chat
- [ ] Image sharing in chat
- [ ] "Chat with Owner" button on lost pet profile
- [ ] Chat room auto-close when pet found
- [ ] Chat history preservation (7 days)

---

## Epic 4: Community Features ❌

**Status:** 0% Complete  
**Priority:** Medium (Phase 2.0)  
**Timeline:** 4 weeks  
**Stories:** ~10 (not fully detailed in PRD)

### Missing Components:

#### ❌ Database

- [ ] `community_posts` table
- [ ] `community_comments` table
- [ ] `community_reactions` table
- [ ] `user_follows` table (likely needed)
- [ ] Migration files

#### ❌ Backend

- [ ] Supabase edge function: `moderate-community-content`
- [ ] AI-based image moderation
- [ ] Google Places API integration

#### ❌ Frontend Modules

- [ ] `lib/features/community/` (complete module)
- [ ] Community feed page
- [ ] Create post page
- [ ] Nearby places page
- [ ] CommunityPostCard widget

#### ❌ Features

- [ ] Forum posts (text + images)
- [ ] Comments & reactions (like, love)
- [ ] Species tagging (cat, dog)
- [ ] Follow system
- [ ] Nearby play areas (Google Places)
- [ ] Location-based pet owner map
- [ ] Content moderation
- [ ] Feed algorithms (For You, Following)

---

## Epic 5: Analytics Dashboard ❌

**Status:** 0% Complete  
**Priority:** Medium (Phase 2.0)  
**Timeline:** 2 weeks  
**Stories:** ~6 (not fully detailed in PRD)

### Missing Components:

#### ❌ Backend

- [ ] Supabase edge function: `calculate-analytics`
- [ ] Nightly job for pre-calculation
- [ ] Analytics data aggregation logic

#### ❌ Frontend

- [ ] `lib/features/analytics/` (complete module)
- [ ] `analytics_dashboard_page.dart`
- [ ] AnalyticsChart widget
- [ ] `fl_chart: ^0.66.0` package
- [ ] `pdf: ^3.10.7` package

#### ❌ Features

- [ ] QR scan graph (daily, weekly, monthly)
- [ ] Scan location heatmap
- [ ] Health event completion rate
- [ ] Pet age milestones
- [ ] Trends, predictions, spending tracker
- [ ] PDF export functionality
- [ ] Time range selector

---

## Epic 6: Vet Clinic Integration ❌

**Status:** 0% Complete  
**Priority:** Low (Phase 2.0)  
**Timeline:** 3 weeks  
**Stories:** ~8 (not fully detailed in PRD)

### Missing Components:

#### ❌ Database

- [ ] `vet_clinics` table
- [ ] `pet_vet_links` table
- [ ] Migration files

#### ❌ Frontend Modules

- [ ] `lib/features/vet/` (complete module)
- [ ] Vet directory page
- [ ] Vet detail page
- [ ] Clinic portal (separate app/section)

#### ❌ Features

- [ ] Vet clinic registration & profiles
- [ ] Clinic directory (search, filter, ratings)
- [ ] Pet-vet linking
- [ ] Vet access to linked pet health records
- [ ] Vet-added health records
- [ ] Owner notifications for vet updates

---

## Epic 7: Multi-Species Support (Dogs) ❌

**Status:** 0% Complete  
**Priority:** Low (Phase 2.0)  
**Timeline:** 2 weeks  
**Stories:** ~5 (not fully detailed in PRD)

### Missing Components:

#### ❌ Database

- [ ] Dog breed data in `pet_categories`
- [ ] Species-specific fields in `pets` table
- [ ] Dog-specific health reminder templates

#### ❌ Frontend

- [ ] Species selector in pet registration
- [ ] Dog-specific form fields
- [ ] Dog breed dropdown
- [ ] Community species filters

#### ❌ Features

- [ ] Dog breed support
- [ ] Dog-specific data fields (training, temperament)
- [ ] Dog-specific vaccines in health reminders
- [ ] Species filtering in community
- [ ] Backward compatibility with cat-only features

---

# 3. 📋 STEP-BY-STEP ACTION PLAN

## Phase 1.5 (Weeks 1-10) - High Priority

### Week 1-3: Epic 1 - Health Management & Reminders

#### Week 1: Database & Backend Setup

**Day 1-2: Database Schema**

```sql
-- Step 1: Create health_reminders table
-- File: database/migrations/005_create_health_reminders.sql

Step 1.1: Write migration SQL
  - CREATE TABLE health_reminders with all columns
  - Add CHECK constraints for type enum
  - Add foreign key to pets table

Step 1.2: Create indexes
  - CREATE INDEX idx_health_reminders_pet_id ON health_reminders(pet_id)
  - CREATE INDEX idx_health_reminders_scheduled ON health_reminders(scheduled_date)
  - CREATE INDEX idx_health_reminders_completed ON health_reminders(is_completed)

Step 1.3: Add RLS policies
  - Enable RLS on health_reminders
  - Policy: Users can INSERT reminders for their own pets
  - Policy: Users can SELECT reminders for their own pets
  - Policy: Users can UPDATE their own pet reminders
  - Policy: Users can DELETE their own pet reminders

Step 1.4: Run migration in Supabase
  - Execute in SQL Editor
  - Verify table created
  - Test RLS policies
```

**Day 3-5: Domain Layer**

```dart
// Step 2: Create domain layer
// lib/features/health/domain/

Step 2.1: Create HealthReminderEntity
  File: lib/features/health/domain/entities/health_reminder_entity.dart
  - Add properties: id, petId, type, title, description, scheduledDate, etc.
  - Add copyWith method
  - Add Equatable

Step 2.2: Create HealthReminderRepository interface
  File: lib/features/health/domain/repositories/health_reminder_repository.dart
  - createReminder(HealthReminderEntity) → Future<Either<Failure, HealthReminderEntity>>
  - getRemindersForPet(String petId) → Future<Either<Failure, List<HealthReminderEntity>>>
  - updateReminder(HealthReminderEntity) → Future<Either<Failure, HealthReminderEntity>>
  - deleteReminder(String id) → Future<Either<Failure, Unit>>
  - markComplete(String id, String? notes) → Future<Either<Failure, HealthReminderEntity>>

Step 2.3: Create Use Cases
  File: lib/features/health/domain/usecases/
  - create_health_reminder_usecase.dart
  - get_health_reminders_for_pet_usecase.dart
  - update_health_reminder_usecase.dart
  - delete_health_reminder_usecase.dart
  - mark_reminder_complete_usecase.dart

Step 2.4: Write unit tests
  File: test/features/health/domain/usecases/
  - Test each use case with mock repository
  - Test success and failure scenarios
  - Target 80%+ coverage
```

#### Week 2: Data Layer & Backend

**Day 6-8: Data Layer**

```dart
// Step 3: Create data layer
// lib/features/health/data/

Step 3.1: Create HealthReminderModel
  File: lib/features/health/data/models/health_reminder_model.dart
  - Extend HealthReminderEntity
  - Add fromJson factory
  - Add toJson method
  - Add toEntity method

Step 3.2: Create RemoteDataSource
  File: lib/features/health/data/datasources/health_reminder_remote_data_source.dart
  - Inject Supabase client
  - Implement CRUD methods
  - Handle errors (try-catch)
  - Map Supabase responses to models

Step 3.3: Create RepositoryImpl
  File: lib/features/health/data/repositories/health_reminder_repository_impl.dart
  - Implement HealthReminderRepository
  - Call remote data source
  - Map exceptions to Failures
  - Return Either<Failure, T>

Step 3.4: Test with real Supabase
  - Integration tests with test database
  - Verify CRUD operations
  - Test RLS policies work correctly
```

**Day 9-10: Edge Function (Optional)**

```typescript
// Step 4: Create recurring reminder generator (optional for Week 1)
// supabase/functions/generate-recurring-reminders/index.ts

Step 4.1: Create edge function
  - Check for completed recurring reminders
  - Generate next instance based on recurrence_pattern
  - Insert new reminder into database

Step 4.2: Deploy function
  - supabase functions deploy generate-recurring-reminders
  - Set up as cron job (daily at 1 AM)

Step 4.3: Test function
  - Manually invoke function
  - Verify new reminders generated correctly
```

#### Week 2-3: UI Implementation

**Day 11-13: Providers & State**

```dart
// Step 5: Create Riverpod providers
// lib/features/health/presentation/providers/

Step 5.1: Create use case providers
  File: health_reminder_providers.dart
  - createHealthReminderUseCaseProvider
  - getHealthRemindersForPetUseCaseProvider
  - updateHealthReminderUseCaseProvider
  - deleteHealthReminderUseCaseProvider
  - markReminderCompleteUseCaseProvider

Step 5.2: Create family provider for pet reminders
  - healthRemindersForPetProvider(String petId)
  - Returns FutureProvider<List<HealthReminderEntity>>

Step 5.3: Create state notifier (if needed)
  - For managing reminder form state
  - For optimistic updates
```

**Day 14-16: Health Reminders List Page**

```dart
// Step 6: Create list view page
// lib/features/health/presentation/pages/health_reminders_page.dart

Step 6.1: Create page scaffold
  - AppBar with title "Health Reminders"
  - Pull-to-refresh
  - FloatingActionButton to add reminder

Step 6.2: Build timeline view
  - Group reminders by: Overdue, Today, Upcoming, Completed
  - Use ListView with section headers
  - Show HealthReminderCard for each reminder

Step 6.3: Create HealthReminderCard widget
  File: lib/features/health/presentation/widgets/health_reminder_card.dart
  - Show type icon, title, date
  - Checkmark button for completion
  - Tap to edit

Step 6.4: Add loading & empty states
  - Shimmer loading effect
  - Empty state: "No health reminders yet"
  - Error state with retry button

Step 6.5: Add to Pet Detail Page
  - Add "Health Records" tab
  - Navigate to HealthRemindersPage
```

**Day 17-19: Create/Edit Reminder Page**

```dart
// Step 7: Create add/edit form
// lib/features/health/presentation/pages/add_reminder_page.dart

Step 7.1: Create form scaffold
  - AppBar with "Add Reminder" or "Edit Reminder"
  - Form with GlobalKey

Step 7.2: Add form fields
  - Type dropdown (Vaccination, Medication, Checkup, Grooming, Other)
  - Title TextField
  - Description TextField (multiline)
  - Date/Time picker
  - Recurring toggle
  - Recurrence pattern dropdown (if recurring)

Step 7.3: Add document upload
  - Button to upload PDF/image
  - Use existing ImagePickerService
  - Use existing StorageService
  - Show uploaded file preview

Step 7.4: Form validation
  - Required fields: type, title, date
  - Date must be in future (for new reminders)
  - Show validation errors inline

Step 7.5: Submit logic
  - Call CreateHealthReminderUseCase
  - Show LoadingOverlay during save
  - On success: Navigate back with SnackBar
  - On error: Show error message with retry
```

**Day 20-21: Mark Complete & Recurring**

```dart
// Step 8: Mark complete functionality

Step 8.1: Add checkmark button action
  - Tap checkmark on HealthReminderCard
  - Show confirmation dialog
  - Optional notes field in dialog

Step 8.2: Call MarkReminderCompleteUseCase
  - Update UI optimistically
  - Move to "Completed" section with strikethrough
  - Store completion timestamp

Step 8.3: Implement undo (optional)
  - Show SnackBar with "Undo" action
  - Revert completion if undo clicked within 5 seconds

Step 8.4: Recurring reminder logic
  - If reminder is recurring, generate next instance
  - Show in UI: "Repeat" icon
  - Allow editing/deleting future instances
```

---

### Week 4-5: Epic 2 - Push Notifications

#### Week 4: Setup & Backend

**Day 22-23: Firebase Project Setup**

```bash
# Step 9: Firebase configuration

Step 9.1: Create Firebase project
  - Go to console.firebase.google.com
  - Create new project "Allnimall QR"
  - Enable Cloud Messaging

Step 9.2: Add Android app
  - Register app with package name (from android/app/build.gradle)
  - Download google-services.json
  - Place in android/app/
  - Update build.gradle files

Step 9.3: Add iOS app
  - Register app with bundle ID (from ios/Runner/Info.plist)
  - Download GoogleService-Info.plist
  - Place in ios/Runner/

Step 9.4: Generate APNs certificates
  - Create App ID in Apple Developer
  - Create APNs auth key
  - Upload to Firebase Console

Step 9.5: Get FCM server key
  - In Firebase Console → Project Settings → Cloud Messaging
  - Copy Server Key
  - Add to .env: FCM_SERVER_KEY=...
```

**Day 24-25: Flutter Package Setup**

```yaml
# Step 10: Add packages
# pubspec.yaml

Step 10.1: Add dependencies
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^16.3.0

Step 10.2: Run flutter pub get

Step 10.3: Update Android files
  android/app/build.gradle:
    - Add google-services plugin
  android/build.gradle:
    - Add google-services classpath

Step 10.4: Update iOS files
  ios/Runner/Info.plist:
    - Add notification permissions

Step 10.5: Initialize in main.dart
  - await Firebase.initializeApp()
  - FirebaseMessaging.instance.requestPermission()
```

**Day 26-27: Database Migration**

```sql
# Step 11: Add notification columns
# database/migrations/008_add_notification_columns.sql

Step 11.1: Add fcm_token to customers
  ALTER TABLE customers ADD COLUMN fcm_token TEXT;

Step 11.2: Add notification_preferences to customers
  ALTER TABLE customers ADD COLUMN notification_preferences JSONB DEFAULT '{"health_reminders": true, "lost_pet_alerts": true, "community_updates": true, "marketing": false}';

Step 11.3: Create notification_logs table
  CREATE TABLE notification_logs (...);
  - Add indexes on customer_id, sent_at

Step 11.4: Run migration in Supabase
```

**Day 28-29: Edge Function - Send Notification**

```typescript
// Step 12: Create edge function
// supabase/functions/send-push-notification/index.ts

Step 12.1: Create function file
  - Accept parameters: user_id, title, body, data, notification_type

Step 12.2: Get user's FCM token and preferences
  - Query customers table
  - Check if notification_type is enabled

Step 12.3: Send to FCM (Android) or APNs (iOS)
  - Use Firebase Admin SDK
  - Handle token refresh if invalid

Step 12.4: Log to notification_logs table
  - Insert record with delivery status

Step 12.5: Deploy function
  supabase functions deploy send-push-notification

Step 12.6: Test function
  - Use supabase functions invoke locally
  - Verify notification received on device
```

**Day 30: Cron Function - Health Reminders**

```typescript
// Step 13: Create cron function
// supabase/functions/schedule-health-reminders/index.ts

Step 13.1: Create cron function
  - Run daily at 9 AM
  - Query health_reminders for upcoming dates

Step 13.2: Check for reminders
  - 3 days before: Send "Reminder in 3 days"
  - 1 day before: Send "Reminder tomorrow"
  - Same day: Send "Reminder today"

Step 13.3: Call send-push-notification function
  - For each matching reminder

Step 13.4: Mark notification_sent = true
  - Update health_reminders table

Step 13.5: Set up cron schedule
  - In Supabase dashboard
  - Schedule: 0 9 * * * (9 AM daily)
```

#### Week 5: Frontend Integration

**Day 31-32: Device Token Registration**

```dart
// Step 14: Register device tokens
// lib/core/services/notification_service.dart

Step 14.1: Create NotificationService
  - Singleton pattern
  - Inject Supabase client

Step 14.2: Initialize FCM
  - FirebaseMessaging.instance.getToken()
  - Save token to customers table

Step 14.3: Handle token refresh
  - FirebaseMessaging.instance.onTokenRefresh
  - Update customers table

Step 14.4: Remove token on logout
  - Clear fcm_token in database

Step 14.5: Call from main.dart
  - After user login
  - Request notification permission
```

**Day 33-34: Notification Handlers**

```dart
// Step 15: Handle incoming notifications

Step 15.1: Handle foreground messages
  - FirebaseMessaging.onMessage.listen
  - Show local notification

Step 15.2: Handle background messages
  - FirebaseMessaging.onBackgroundMessage
  - Top-level function

Step 15.3: Handle notification taps
  - FirebaseMessaging.onMessageOpenedApp
  - Navigate to deep link

Step 15.4: Set up deep linking
  - Parse notification data
  - Navigate to correct page using Go Router
```

**Day 35-36: Notification Preferences UI**

```dart
// Step 16: Preferences screen
// lib/features/auth/presentation/pages/profile_settings_page.dart

Step 16.1: Add notification section
  - Section title: "Notifications"
  - List of toggle switches

Step 16.2: Add toggle switches
  - Health Reminders
  - Lost Pet Alerts
  - Community Updates
  - Marketing

Step 16.3: Load preferences from database
  - Get notification_preferences from customers
  - Set switch states

Step 16.4: Update preferences
  - On toggle change, update database
  - Real-time sync across devices
```

**Day 37-38: Notifications List Page**

```dart
// Step 17: Notification history
// lib/features/notifications/presentation/pages/notifications_page.dart

Step 17.1: Create page
  - AppBar with "Notifications"
  - Grouped by: Today, Yesterday, This Week, Older

Step 17.2: Query notification_logs
  - Get notifications for current user
  - Order by sent_at DESC

Step 17.3: Create NotificationCard widget
  - Show icon, title, body, timestamp
  - Swipe to dismiss
  - Tap to navigate

Step 17.4: Mark as read
  - Update read_at timestamp
  - Change visual style (dim unread)

Step 17.5: Add to Dashboard
  - Bottom navigation: Notifications tab
  - Badge with unread count
```

---

### Week 6-7: Epic 3 - Anonymous Chat

#### Week 6: Chat Backend

**Day 39-40: Database Schema**

```sql
# Step 18: Chat tables
# database/migrations/006_create_chat_tables.sql

Step 18.1: Create chat_rooms table
  CREATE TABLE chat_rooms (
    id UUID PRIMARY KEY,
    pet_id UUID REFERENCES pets(id),
    status TEXT CHECK (status IN ('active', 'closed')),
    created_at, closed_at
  )

Step 18.2: Create chat_messages table
  CREATE TABLE chat_messages (
    id UUID PRIMARY KEY,
    room_id UUID REFERENCES chat_rooms(id), -- Add this
    pet_id UUID REFERENCES pets(id),
    sender_type TEXT,
    sender_id TEXT,
    message TEXT,
    location_lat, location_lng,
    image_url,
    created_at
  )

Step 18.3: Add indexes
  - room_id, pet_id, created_at

Step 18.4: RLS policies
  - Owners can read all messages for their pets
  - Finders can read messages in rooms they've joined
  - Anyone can INSERT messages (with finder anonymous ID)

Step 18.5: Run migration
```

**Day 41-43: Chat Domain & Data**

```dart
// Step 19: Chat business logic

Step 19.1: Create entities
  - ChatRoomEntity
  - ChatMessageEntity

Step 19.2: Create repository interface
  - sendMessage()
  - getMessages() → Stream
  - joinRoom()
  - closeRoom()

Step 19.3: Create use cases
  - SendMessageUseCase
  - GetChatMessagesUseCase (Stream)
  - JoinChatRoomUseCase
  - CloseRoomUseCase

Step 19.4: Create models
  - ChatRoomModel
  - ChatMessageModel

Step 19.5: Create remote data source
  - Use Supabase Realtime channel subscription
  - Listen to INSERT events on chat_messages
  - Return Stream<List<ChatMessageModel>>

Step 19.6: Create repository implementation
  - Map data source to entities
  - Handle Realtime connection management
```

**Day 44: Auto-create Chat Room**

```dart
// Step 20: Trigger chat room creation

Step 20.1: Update ReportLostUseCase
  - When marking pet as lost
  - Create chat_room for that pet
  - Set status = 'active'

Step 20.2: Update MarkFoundUseCase
  - When marking pet as found
  - Update chat_room status = 'closed'

Step 20.3: Add cleanup job (optional)
  - Edge function to delete closed rooms after 7 days
  - Run as cron job
```

#### Week 7: Chat UI

**Day 45-47: Chat Screen**

```dart
// Step 21: Build chat interface
// lib/features/chat/presentation/pages/chat_page.dart

Step 21.1: Create page scaffold
  - AppBar with pet name
  - Message list (ListView)
  - Input field at bottom

Step 21.2: Create ChatBubble widget
  File: lib/features/chat/presentation/widgets/chat_bubble.dart
  - Different colors for owner (purple) vs finder (pink)
  - Show sender label (Owner, Finder 1, Finder 2)
  - Show timestamp
  - Handle text, location, image messages

Step 21.3: Real-time message stream
  - Use StreamProvider for messages
  - Auto-scroll to bottom on new message
  - Optimistic UI (show message immediately)

Step 21.4: Message input
  - TextField for text
  - Send button
  - Keyboard handling

Step 21.5: Anonymous ID generation
  - For finders (non-logged-in users)
  - Generate UUID, store in SharedPreferences
  - Use as sender_id
```

**Day 48: Location Sharing**

```dart
// Step 22: Location in chat

Step 22.1: Add location button
  - Icon button next to input field

Step 22.2: Get current location
  - Use existing GeolocatorService
  - Request permission if not granted

Step 22.3: Send location message
  - Create message with location_lat, location_lng
  - No text content

Step 22.4: Display location message
  - Show map thumbnail (Google Maps static API)
  - "View on Map" button
  - Tap opens full map view
```

**Day 49: Image Sharing**

```dart
// Step 23: Images in chat

Step 23.1: Add camera/gallery button
  - Icon button next to input

Step 23.2: Pick image
  - Use existing ImagePickerService

Step 23.3: Upload to Supabase Storage
  - Folder: chat-images/{petId}/
  - Use existing StorageService
  - Show upload progress

Step 23.4: Send image message
  - Create message with image_url
  - No text content

Step 23.5: Display image message
  - Show thumbnail in chat
  - Tap opens fullscreen viewer
```

**Day 50-51: Chat Integration**

```dart
// Step 24: Integrate chat with app

Step 24.1: Add "Chat" button to lost pet profile
  - Only show when is_lost = true
  - Floating action button

Step 24.2: Navigation to chat
  - Pass pet_id to ChatPage
  - Join or create chat room

Step 24.3: Push notification for new messages
  - Trigger from send-push-notification
  - When new message in chat for owner's pet
  - Deep link to chat page

Step 24.4: Close chat UI
  - When pet marked found
  - Show read-only banner
  - Disable input
```

---

## Phase 2.0 (Weeks 8-18) - Medium/Low Priority

### Week 8-11: Epic 4 - Community Features

**Note:** Detailed steps not provided in PRD, but general approach:

```
Week 8: Database schema + backend
  - Create community_posts, community_comments, community_reactions tables
  - RLS policies
  - Moderate-community-content edge function
  - Google Places API integration

Week 9: Domain & Data layers
  - Entities, repositories, use cases for posts/comments/reactions
  - Models and data sources

Week 10: Community Feed UI
  - Community feed page (Instagram-style)
  - Create post page
  - Post cards, comment sections

Week 11: Nearby Places & Polish
  - Nearby places page (Google Places)
  - Map view of pet owners
  - Follow system
  - Content moderation
```

### Week 12-13: Epic 5 - Analytics Dashboard

```
Week 12: Backend analytics
  - Calculate-analytics edge function
  - Nightly aggregation jobs
  - Analytics data models

Week 13: Analytics UI
  - Analytics dashboard page
  - Charts (fl_chart package)
  - PDF export
```

### Week 14-16: Epic 6 - Vet Clinic Integration

```
Week 14: Vet database & backend
  - vet_clinics, pet_vet_links tables
  - Clinic portal backend

Week 15: Clinic directory
  - Directory page
  - Search/filter
  - Clinic detail page

Week 16: Pet-vet linking
  - Link pet to clinic
  - Vet access to records
  - Health record sharing
```

### Week 17-18: Epic 7 - Multi-Species Support

```
Week 17: Dog data
  - Dog breeds in pet_categories
  - Species-specific fields
  - Dog health templates

Week 18: Dog UI
  - Species selector in registration
  - Dog-specific forms
  - Community species filters
  - Backward compatibility testing
```

---

# 4. 🎯 QUICK START GUIDE

## For Immediate Next Steps

**If starting today, begin with:**

### Option A: Start Phase 1.5 (Recommended)

1. Follow Week 1 Day 1-2: Create health_reminders table
2. Run migration in Supabase SQL Editor
3. Start building domain layer (Day 3-5)

### Option B: Individual Feature Deep Dive

Pick one epic and follow step-by-step for that epic only.

### Option C: Prototype & Validate

Build quick prototype of one feature (e.g., health reminders list page) to validate design before full implementation.

---

# 5. 📊 EFFORT ESTIMATION

## By Epic

| Epic                      | Stories | Estimated Weeks | Developer-Weeks |
| ------------------------- | ------- | --------------- | --------------- |
| 1. Health Management      | 7       | 3               | 6 (2 devs)      |
| 2. Push Notifications     | 6       | 2               | 4 (2 devs)      |
| 3. Anonymous Chat         | 7       | 2               | 4 (2 devs)      |
| 4. Community Features     | ~10     | 4               | 8 (2 devs)      |
| 5. Analytics Dashboard    | ~6      | 2               | 4 (2 devs)      |
| 6. Vet Clinic Integration | ~8      | 3               | 6 (2 devs)      |
| 7. Multi-Species Support  | ~5      | 2               | 4 (2 devs)      |
| **TOTAL**                 | **~49** | **18**          | **36**          |

## Team Requirements

- 2 Flutter developers (full-time)
- 1 Backend developer (full-time for Epics 1-4)
- 1 UI/UX designer (part-time, 50%)
- 1 QA engineer (full-time)

---

# 6. 🚨 CRITICAL DEPENDENCIES

## Must Complete First

1. **Health Reminders** before **Push Notifications** (need something to notify about)
2. **Push Notifications** before **Lost Pet Chat** (chat uses notifications)
3. **Analytics Dashboard** depends on having data from other features

## Can Be Parallel

- Health Reminders + Community Features (independent)
- Analytics + Vet Integration (independent)
- Multi-Species Support (mostly UI changes, can be done anytime)

---

# 7. 🎯 SUCCESS CRITERIA

## Phase 1.5 Complete When:

- [ ] Health reminders working end-to-end
- [ ] Push notifications delivering reliably
- [ ] Anonymous chat functional for lost pets

## Phase 2.0 Complete When:

- [ ] Community features live with moderation
- [ ] Analytics dashboard showing data
- [ ] 10+ vet clinics integrated
- [ ] Dog support fully functional
- [ ] All 41 functional requirements implemented

---

**Document Status:** Ready for implementation  
**Next Action:** Choose starting point and begin Week 1 Day 1  
**Questions?** Review brownfield PRD for detailed requirements
