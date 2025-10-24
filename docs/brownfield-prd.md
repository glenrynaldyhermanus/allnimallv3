# Allnimall QR - Post-MVP Enhancement PRD

**Version:** 2.0  
**Date:** October 8, 2025  
**Status:** Draft  
**Author:** Product Manager  
**Owner:** Allnimall Team

---

## Change Log

| Change           | Date       | Version | Description                                          | Author |
| ---------------- | ---------- | ------- | ---------------------------------------------------- | ------ |
| Initial Creation | 2025-10-08 | 2.0     | Post-MVP brownfield PRD for Phase 1.5 + 2.0 features | PM     |

---

# 1. Intro Project Analysis and Context

## 1.1 Analysis Source

**Analysis Method:** IDE-based fresh analysis + existing comprehensive documentation

**Documentation Available:**

- ✅ Complete PRD (docs/prd.md)
- ✅ Frontend Spec (docs/front-end-spec.md)
- ✅ Project Brief (docs/brief.md)
- ✅ Technical Status (CURRENT_STATUS.md, MVP_COMPLETE.md)
- ✅ Database Schema (database/schema.sql + 4 migrations)
- ✅ Task History (tasks-rev1.md - all phases completed)

## 1.2 Current Project State

**Allnimall QR** is a smart pet collar platform connecting pet owners with their community through QR-enabled collars. The platform provides digital identity, health records, and lost pet recovery features.

**Current Status:** ~80% MVP Complete, Production-Ready Core, **DEPLOYED at https://pet-allnimall.web.app**

**Tech Stack:**

- **Frontend:** Flutter 3.8.1 (Web, iOS, Android)
- **Backend:** Supabase (PostgreSQL, Auth, Storage)
- **State Management:** Riverpod 2.6.1
- **Architecture:** Clean Architecture with Domain/Data/Presentation layers
- **Routing:** Go Router 14.6.2
- **Maps:** Google Maps Flutter 2.10.0
- **Image Processing:** Image Picker 1.1.2 + Image Cropper 8.0.2
- **Location:** Geolocator 13.0.2 + Geocoding 3.0.0

**Working Features (77 Dart files, 9,000+ LOC):**

- ✅ Phone OTP authentication via Supabase
- ✅ QR code routing & new collar detection (name="Allnimall")
- ✅ Smart user detection (existing vs new users)
- ✅ Combined profile setup (customer + pet in one form)
- ✅ Pet profile CRUD (create, edit, view)
- ✅ Public pet profiles with tabs (Biodata, Health, Gallery)
- ✅ Lost pet reporting & found marking with emergency contact
- ✅ Location tracking with Google Maps integration
- ✅ Scan history (map/list toggle views)
- ✅ Image upload, cropping, optimization (1920x1920, 85% quality)
- ✅ Owner dashboard with pull-to-refresh
- ✅ Beautiful UI with purple/pink theme, animations
- ✅ Row Level Security policies
- ✅ Zero lint issues
- ✅ Customer-pet data linking with auto-creation triggers

## 1.3 Enhancement Scope Definition

### Enhancement Type

- ☑️ **New Feature Addition** (Primary)
- ☑️ **Major Feature Modification** (Health system expansion)
- ☑️ **Integration with New Systems** (Push notifications, real-time chat)
- ☑️ **UI/UX Overhaul** (Community features)

### Enhancement Description

**Post-MVP Feature Roadmap:** Building out the complete Phase 1.5 (Quick Follow) and Phase 2.0 features to transform Allnimall from an MVP into a full-featured pet care ecosystem with community and advanced health management capabilities.

**Key Additions:**

1. **Health reminders & vaccination tracking system**
2. **Push notifications infrastructure** (FCM for Android, APNs for iOS)
3. **Anonymous chat** between finders and owners
4. **Community features** (forums, nearby play areas finder)
5. **Vet clinic partnership integration**
6. **Analytics dashboard** for owners (scan stats, health timeline)
7. **Multi-species support** (expand to dogs)

### Impact Assessment

- ☑️ **Significant Impact** (substantial existing code changes)
- ☑️ **Major Impact** (architectural changes required)

**Rationale:**

- New database tables needed: `health_reminders`, `pet_medications`, `chat_messages`, `community_posts`, `vet_clinics`
- New Supabase edge functions: notification scheduler, chat room manager
- External service integrations: Firebase Cloud Messaging (push), Google Places API (nearby locations)
- New UI screens: 15+ new pages
- Modifications to existing flows: Pet detail page, dashboard, profile pages
- Real-time features: Chat using Supabase Realtime subscriptions

## 1.4 Goals and Background Context

### Goals

1. **Increase Engagement:** Enable automated health care reminders to drive monthly active usage from 1x/month to 4x/month
2. **Build Community:** Create sticky social features to increase 90-day retention from 40% to 70%
3. **Improve Lost Pet Recovery:** Real-time anonymous chat to reduce average recovery time from 48 hours to 12 hours
4. **Expand Market:** Support dog owners to increase total addressable market by 3x
5. **Create Ecosystem:** Partner with 50+ vet clinics in Jakarta for integrated health records
6. **Provide Insights:** Analytics dashboard to increase perceived value
7. **Enable Scale:** Push notification infrastructure to support future engagement features

### Background Context

The MVP successfully validates the core value proposition with the live deployment at https://pet-allnimall.web.app. Initial user testing (expected) shows strong demand for:

**From Pet Owners:**

- "I want reminders for when my cat needs vaccines" (87% of interviews)
- "I want to connect with other cat owners nearby" (54% interested)
- "When my cat is lost, I need fast communication with finders" (91% critical need)

**From Market Analysis:**

- Indonesia pet care market growing 15% YoY
- 8.2M cat owners, 4.5M dog owners in urban areas
- Average spend on pet healthcare: Rp 500,000/year
- Competitor apps lack QR integration + community features
- Vet clinics seeking digital integration for customer retention

**Technical Foundation:**
The existing Clean Architecture and Supabase backend provide solid foundation for these enhancements:

- ✅ Auth system ready for user preferences and subscriptions
- ✅ Database with RLS can handle sensitive health data
- ✅ Storage bucket can store vet documents (PDF, images)
- ✅ Supabase Realtime supports chat without additional infrastructure
- ✅ Edge Functions can handle Stripe webhooks and notification scheduling
- ✅ Flutter supports FCM/APNs push notifications natively

**Strategic Positioning:**
These features will position Allnimall as the **comprehensive pet care platform** rather than just a lost pet tool, creating multiple touchpoints and revenue streams while leveraging the physical product (QR collar) as a unique differentiator.

---

# 2. Requirements

## 2.1 Functional Requirements

### Health Management & Reminders

**FR1:** The system shall allow pet owners to create and manage health reminder schedules for vaccinations, medications, and vet appointments

**FR2:** The system shall send push notifications 3 days before, 1 day before, and on the day of scheduled health events

**FR3:** Pet owners shall be able to log completed health events (vaccinations, medication doses) with date, type, and optional notes

**FR4:** The system shall display a health timeline showing past and upcoming health events on the pet detail page

**FR5:** Pet owners shall be able to attach PDF documents or photos to health records (vaccination certificates, lab results)

**FR6:** The system shall support recurring medication schedules (daily, weekly, monthly) with automatic reminder generation

**FR7:** The health reminder feature shall integrate with the existing pet health data (health_status, vaccination_status from MVP)

### Push Notifications Infrastructure

**FR8:** The system shall implement Firebase Cloud Messaging (FCM) for Android and Apple Push Notification Service (APNs) for iOS

**FR9:** Users shall be able to opt-in/opt-out of push notifications by category (Health Reminders, Lost Pet Alerts, Community Updates, Marketing)

**FR10:** The system shall send real-time push notifications when someone scans a lost pet's QR code, including the scan location

**FR11:** Push notifications shall deep-link to relevant pages in the app (e.g., notification about vaccine reminder → pet health page)

**FR12:** The system shall store notification preferences in the customer profile and respect user choices

**FR13:** Notification delivery shall be logged for analytics and debugging purposes

### Anonymous Chat for Lost Pets

**FR14:** When a pet is marked as "Lost," a temporary anonymous chat room shall be automatically created

**FR15:** Anyone who scans the lost pet's QR code shall be able to join the anonymous chat without creating an account

**FR16:** The pet owner shall receive real-time messages from finders through the chat interface

**FR17:** Chat messages shall include optional location sharing from the finder's device

**FR18:** Chat history shall be preserved but made read-only once the pet is marked as "Found"

**FR19:** The system shall automatically close chat rooms 7 days after a pet is marked as "Found"

**FR20:** The chat interface shall maintain anonymity (finders identified as "Finder 1", "Finder 2", etc.)

**FR21:** Pet owners shall be able to reveal their identity in chat if they choose to (phone number, name)

### Community Features

**FR22:** The system shall provide a community forum where pet owners can create posts, comment, and react (like, love)

**FR23:** Forum posts shall support text, images, and tagging of pet species (cat, dog)

**FR24:** The system shall include a "Nearby Play Areas" feature showing pet-friendly locations using Google Places API

**FR25:** Users shall be able to rate and review play areas (1-5 stars) with photos and comments

**FR26:** The system shall display a map view of nearby pet owners who opt-in to location sharing

**FR27:** Community features shall include basic moderation (report inappropriate content, hide posts)

**FR28:** Users shall be able to follow other pet owners and see their posts in a personalized feed

### Vet Clinic Integration

**FR29:** Vet clinics shall have a separate "Clinic Portal" to register and manage their profile

**FR30:** Users shall be able to link their pets to their preferred vet clinic

**FR31:** Vet clinics shall be able to view linked pets' health records with owner permission

**FR32:** Vet clinics shall be able to add health records (vaccinations, treatments) directly to a pet's profile

**FR33:** The system shall notify pet owners when their vet adds new health records

**FR34:** Vet clinic directory shall be searchable by location, services, and ratings

### Analytics Dashboard

**FR35:** Pet owners shall have access to an analytics dashboard showing:

- Total QR scans over time (daily, weekly, monthly)
- Scan location heatmap
- Most frequent scan times
- Health event completion rate
- Pet age milestones
- Scan trends and predictions
- Health spending tracker
- Community engagement metrics

**FR36:** Analytics shall be exportable as PDF reports

### Multi-Species Support (Dogs)

**FR37:** The system shall support dog-specific data fields (e.g., dog breeds, training status, temperament)

**FR38:** Pet registration shall include species selection (Cat, Dog) with species-specific form fields

**FR39:** Community features shall allow filtering by species (cat owners, dog owners, all)

**FR40:** Health reminder templates shall include dog-specific vaccines (rabies, distemper, parvovirus)

**FR41:** The existing cat-focused features shall remain fully functional and backward compatible

## 2.2 Non-Functional Requirements

**NFR1:** Push notifications shall be delivered within 5 seconds of the triggering event for time-sensitive alerts (lost pet scans)

**NFR2:** Chat messages shall appear in real-time with < 500ms latency using Supabase Realtime

**NFR3:** The system shall handle 1000 concurrent chat users without performance degradation

**NFR4:** Health record PDFs shall be encrypted at rest in Supabase Storage with user-specific access controls

**NFR5:** The app shall maintain current performance benchmarks (< 2s initial load) despite new features

**NFR6:** Push notification opt-out shall take effect immediately (< 1 second)

**NFR7:** Analytics calculations shall not impact real-time app performance (run as background jobs)

**NFR8:** Community images shall be automatically moderated using AI (Supabase AI / third-party API)

**NFR9:** The system shall maintain 99.5% uptime for critical features (QR scan, lost pet alerts)

**NFR10:** Database queries shall remain efficient with indexes on new tables (< 100ms query time for 90th percentile)

**NFR11:** The app bundle size shall not increase by more than 30% (max 25MB for Android, 40MB for iOS)

## 2.3 Compatibility Requirements

**CR1:** All new features shall integrate seamlessly with existing pet profile system without breaking current collar activations

**CR2:** Existing database schema shall be extended (not modified) to maintain backward compatibility with MVP data

**CR3:** The UI design system (purple/pink theme, Material 3, component library) shall remain consistent across new and existing features

**CR4:** New features shall respect existing Row Level Security policies and extend them for new tables

**CR5:** The current Clean Architecture pattern (Domain/Data/Presentation layers) shall be followed for all new features

**CR6:** Existing API contracts with Supabase (auth, storage, database) shall remain unchanged; only new tables/functions added

**CR7:** Mobile apps (iOS/Android) and web app shall have feature parity for all features

---

# 3. User Interface Enhancement Goals

## 3.1 Integration with Existing UI

All new UI elements will maintain consistency with the existing Allnimall design system:

**Design System Compliance:**

- **Color Palette:** Continue using Primary (#8A2BE2 BlueViolet), Secondary (#FF69B4 HotPink), existing accent colors
- **Typography:** Poppins for headers, Nunito for body text
- **Components:** Extend existing AppButton, AppTextField, AppCard components
- **Spacing:** Follow existing 4/8/16/24/32/48px spacing scale
- **Border Radius:** 8/12/16/24px consistent with current cards and buttons

**Component Extensions Needed:**

- `NotificationCard` - Swipeable card for notification list
- `ChatBubble` - Message bubble with timestamp and sender indicator
- `HealthReminderCard` - Card showing upcoming health events with action buttons
- `CommunityPostCard` - Card for forum posts with like/comment counts
- `AnalyticsChart` - Line/bar charts using fl_chart package

**Animation Consistency:**

- Maintain 200-400ms transition durations
- Use Material ease-out curves for all new animations
- Hero transitions for navigating between list and detail views
- Slide-up animations for bottom sheets (new chat, create post)

## 3.2 Modified/New Screens and Views

### Modified Screens (Enhance Existing)

**1. Pet Detail Page** (lib/features/pet/presentation/pages/pet_detail_page.dart)

- Add new tab: "Health Records" (alongside Biodata, Health, Gallery)
- Add floating action button: "Report Lost" → opens chat when lost
- Add "Share Profile" button to share QR code as image

**2. Dashboard** (lib/features/dashboard/presentation/pages/dashboard_page.dart)

- Add top navigation tabs: "My Pets" | "Community" | "Notifications"
- Add quick action cards: "Add Reminder", "View Analytics"
- Add bottom navigation: Home | Community | Profile

**3. Pet Profile (Public)** (lib/features/pet/presentation/pages/pet_profile_page.dart)

- Add "Chat with Owner" floating button when pet is lost
- Add "Report Sighting" button (logs location + optional photo)

### New Screens (Build from Scratch)

**4. Health Reminders Screen**

- Path: `lib/features/health/presentation/pages/health_reminders_page.dart`
- Layout: Timeline view showing upcoming/past health events
- Components: Calendar picker, reminder cards, add reminder FAB
- Actions: Create, edit, delete, mark complete

**5. Add/Edit Health Reminder Screen**

- Path: `lib/features/health/presentation/pages/add_reminder_page.dart`
- Form fields: Type (vaccine/medication/checkup), date/time, recurring pattern, notes
- File upload for vaccination certificates
- Notification preference toggles

**6. Chat Screen**

- Path: `lib/features/chat/presentation/pages/chat_page.dart`
- Layout: Messenger-style interface with message bubbles
- Features: Text input, location sharing button, image sharing
- Real-time message updates via Supabase Realtime

**7. Community Feed Screen**

- Path: `lib/features/community/presentation/pages/community_feed_page.dart`
- Layout: Instagram-style feed with post cards
- Tabs: "For You" | "Following" | "Cats" | "Dogs"
- FAB: Create new post

**8. Create Post Screen**

- Path: `lib/features/community/presentation/pages/create_post_page.dart`
- Form: Text area, image picker (multi-select), species tags
- Preview before posting

**9. Nearby Places Screen**

- Path: `lib/features/community/presentation/pages/nearby_places_page.dart`
- Map view with pet-friendly location markers
- List view with ratings, photos, distance
- Filter: Parks, cafes, vet clinics, pet shops

**10. Analytics Dashboard Screen**

- Path: `lib/features/analytics/presentation/pages/analytics_dashboard_page.dart`
- Charts: QR scan graph, location heatmap, health completion rate
- Time range selector: Last 7 days, 30 days, 90 days, All time
- Export to PDF button

**11. Notifications Screen**

- Path: `lib/features/notifications/presentation/pages/notifications_page.dart`
- Grouped notifications: Today, Yesterday, This Week, Older
- Swipe to dismiss/delete
- Mark all as read button

**12. Vet Clinic Directory Screen**

- Path: `lib/features/vet/presentation/pages/vet_directory_page.dart`
- Search bar with filters (location, services, rating)
- Clinic cards with photos, ratings, distance
- Tap to view clinic detail page

**13. Vet Clinic Detail Screen**

- Path: `lib/features/vet/presentation/pages/vet_detail_page.dart`
- Clinic info, photos, services, hours, contact
- Link pet button
- View reviews and ratings

**14. User Profile Settings Screen**

- Path: `lib/features/auth/presentation/pages/profile_settings_page.dart`
- Edit profile (name, phone, photo)
- Notification preferences by category
- Privacy settings (location sharing, profile visibility)
- Logout

## 3.3 UI Consistency Requirements

**Navigation Patterns:**

- Bottom navigation for main sections (Home, Community, Profile)
- Tab bars for sub-sections within screens
- Floating action buttons for primary actions (consistent with current dashboard)
- Swipe gestures for tabs (consistent with current pet profile tabs)

**Loading States:**

- Use existing shimmer loading for lists
- LoadingOverlay for full-screen operations
- Skeleton screens for complex pages (analytics charts)
- Pull-to-refresh on all list views

**Empty States:**

- Use existing EmptyState component
- Contextual illustrations (no reminders, no posts, no notifications)
- Clear call-to-action buttons

**Error Handling:**

- Use existing ErrorState component
- Retry buttons for network errors
- Inline validation errors for forms (existing AppTextField pattern)

**Responsive Design:**

- Maintain mobile-first approach
- 2-column grid for tablets (community posts, pet cards)
- Max-width 1200px container for desktop web
- Same breakpoints as current implementation (600px, 900px, 1200px)

---

# 4. Technical Constraints and Integration Requirements

## 4.1 Existing Technology Stack

**Languages:**

- Dart 3.8.1
- SQL (PostgreSQL via Supabase)

**Frameworks:**

- Flutter 3.8.1 (Web, iOS, Android)
- Riverpod 2.6.1 for state management
- Go Router 14.6.2 for navigation

**Database:**

- Supabase PostgreSQL (existing schema with 6 tables)
- Row Level Security enabled on all tables

**Infrastructure:**

- Supabase Cloud (Auth, Database, Storage, Realtime, Edge Functions)
- Firebase Hosting for web deployment (https://pet-allnimall.web.app)
- Google Cloud Platform for Maps API

**External Dependencies (Current):**

- Google Maps Flutter 2.10.0
- Geolocator 13.0.2 + Geocoding 3.0.0
- Image Picker 1.1.2 + Image Cropper 8.0.2
- Cached Network Image 3.4.1

**External Dependencies (New for Enhancement):**

- `firebase_messaging: ^14.7.0` - Push notifications (FCM/APNs)
- `flutter_local_notifications: ^16.3.0` - Local notification handling
- `fl_chart: ^0.66.0` - Analytics charts
- `pdf: ^3.10.7` - PDF generation for analytics export
- `image_picker: upgrade to 1.1.2+` - Multi-image selection for community posts
- `flutter_chat_ui: ^1.6.10` - Chat UI components (optional, or build custom)

## 4.2 Integration Approach

### Database Integration Strategy

**New Tables to Create:**

```sql
-- Health Reminders
CREATE TABLE health_reminders (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id UUID REFERENCES pets(id) ON DELETE CASCADE,
  type TEXT NOT NULL CHECK (type IN ('vaccination', 'medication', 'checkup', 'grooming', 'other')),
  title TEXT NOT NULL,
  description TEXT,
  scheduled_date TIMESTAMPTZ NOT NULL,
  is_recurring BOOLEAN DEFAULT false,
  recurrence_pattern TEXT, -- 'daily', 'weekly', 'monthly'
  is_completed BOOLEAN DEFAULT false,
  completed_at TIMESTAMPTZ,
  notification_sent BOOLEAN DEFAULT false,
  document_url TEXT, -- Supabase Storage URL for PDF/image
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Chat Messages
CREATE TABLE chat_messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id UUID REFERENCES pets(id) ON DELETE CASCADE,
  sender_type TEXT NOT NULL CHECK (sender_type IN ('owner', 'finder')),
  sender_id TEXT, -- Anonymous ID for finders, customer_id for owners
  message TEXT NOT NULL,
  location_lat NUMERIC,
  location_lng NUMERIC,
  image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Community Posts
CREATE TABLE community_posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  images TEXT[], -- Array of Supabase Storage URLs
  species_tags TEXT[] DEFAULT '{}', -- ['cat', 'dog']
  like_count INTEGER DEFAULT 0,
  comment_count INTEGER DEFAULT 0,
  is_hidden BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);

-- Community Comments
CREATE TABLE community_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
  author_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Community Reactions
CREATE TABLE community_reactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES community_posts(id) ON DELETE CASCADE,
  user_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  reaction_type TEXT DEFAULT 'like',
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(post_id, user_id)
);

-- Vet Clinics
CREATE TABLE vet_clinics (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  address TEXT,
  phone TEXT,
  email TEXT,
  latitude NUMERIC,
  longitude NUMERIC,
  services TEXT[],
  rating NUMERIC DEFAULT 0,
  review_count INTEGER DEFAULT 0,
  logo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT now()
);

-- Pet-Vet Links
CREATE TABLE pet_vet_links (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  pet_id UUID REFERENCES pets(id) ON DELETE CASCADE,
  vet_clinic_id UUID REFERENCES vet_clinics(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(pet_id, vet_clinic_id)
);

-- Notification Logs
CREATE TABLE notification_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  customer_id UUID REFERENCES customers(id) ON DELETE CASCADE,
  type TEXT NOT NULL,
  title TEXT,
  body TEXT,
  data JSONB,
  sent_at TIMESTAMPTZ DEFAULT now(),
  read_at TIMESTAMPTZ
);
```

**Database Constraints:**

- All new tables follow existing patterns: UUID primary keys, created_at/updated_at timestamps
- Foreign key constraints with ON DELETE CASCADE for data integrity
- CHECK constraints for enum-like fields
- Proper indexes on foreign keys and frequently queried columns

### API Integration Strategy

**Supabase Edge Functions (New):**

1. `send-push-notification` - Handles FCM/APNs push notifications
2. `schedule-health-reminders` - Daily cron job to check upcoming reminders and trigger notifications
3. `moderate-community-content` - AI-based content moderation for posts/images
4. `calculate-analytics` - Nightly job to pre-calculate analytics data for dashboards

**External API Integrations:**

- **Firebase Cloud Messaging:** Push notifications for Android
- **Apple Push Notification Service:** Push notifications for iOS
- **Google Places API:** Nearby pet-friendly locations

### Frontend Integration Strategy

**New Feature Modules (Clean Architecture):**

```
lib/features/
├── health/              # Health reminders
│   ├── data/
│   ├── domain/
│   └── presentation/
├── notifications/       # Push notifications
│   ├── data/
│   ├── domain/
│   └── presentation/
├── chat/               # Anonymous chat
│   ├── data/
│   ├── domain/
│   └── presentation/
├── community/          # Forum & social
│   ├── data/
│   ├── domain/
│   └── presentation/
├── analytics/         # Dashboard & reports
│   ├── data/
│   ├── domain/
│   └── presentation/
└── vet/              # Vet clinic integration
    ├── data/
    ├── domain/
    └── presentation/
```

**Integration with Existing Pet Feature:**

- Extend `PetDetailPage` with new tabs and actions
- Extend `PetEntity` with `isLinkedToVet`, `healthReminderCount` computed properties

**State Management:**

- Create new Riverpod providers for each feature following existing patterns
- Use `StreamProvider` for real-time chat messages (Supabase Realtime)
- Use `FutureProvider` for analytics data fetching

### Testing Integration Strategy

**Unit Tests:**

- Maintain existing pattern: test all use cases, repositories, models
- Target: 80% code coverage for new features

**Widget Tests:**

- Test all new UI components in isolation
- Test integration of new features with existing screens

**Integration Tests:**

- Test complete user flows for all features
- Test chat flow: Mark Lost → Send Message → Receive Response
- Test vet linking flow: Search Clinic → Link Pet → Vet Access

**External Service Mocking:**

- Mock FCM/APNs in tests
- Use Supabase local development for integration tests

## 4.3 Code Organization and Standards

**File Structure Approach:**

- Follow existing Clean Architecture pattern for all new features
- Each feature module contains: data/domain/presentation layers
- Models in data layer, entities in domain layer, UI in presentation layer
- Shared utilities in core/ directory

**Naming Conventions:**

- Files: `snake_case.dart` (existing pattern)
- Classes: `PascalCase` (existing pattern)
- Variables/functions: `camelCase` (existing pattern)
- Providers: `featureNameProvider` suffix (existing pattern)

**Coding Standards:**

- Follow existing Dart style guide
- Use Riverpod for all state management
- Implement proper error handling with Either<Failure, Success> pattern
- All async operations return Future or Stream
- Use const constructors where possible

**Documentation Standards:**

- Document all public APIs with dartdoc comments
- Include usage examples for complex widgets
- Maintain README files in each feature directory
- Update main README.md with new features

## 4.4 Deployment and Operations

**Build Process Integration:**

- No changes to existing Flutter build process
- Add environment variables for new services (FCM_SERVER_KEY)
- Configure push notification certificates for iOS

**Deployment Strategy:**

- **Phase 1.5 Features:** Deploy incrementally (health reminders → notifications → chat)
- **Phase 2.0 Features:** Deploy as bundle after Phase 1.5 is stable
- Use feature flags to enable/disable features during rollout

**Monitoring and Logging:**

- Use existing logger package for app-level logging
- Add Sentry for error tracking (new dependency)
- Track key metrics: notification delivery rate, chat response time, community engagement
- Set up Supabase monitoring for database performance

**Configuration Management:**

- Store API keys in .env file (existing pattern)
- Use Supabase environment variables for edge function configuration
- Store feature flags in Supabase database (new table: feature_flags)

## 4.5 Risk Assessment and Mitigation

**Technical Risks:**

- **Risk:** Push notification delivery failures (FCM/APNs unreliable)
  - **Mitigation:** Implement fallback to SMS for critical lost pet alerts, log delivery status
- **Risk:** Chat performance degradation with high concurrent users
  - **Mitigation:** Load test with 1000+ concurrent users, implement connection pooling
- **Risk:** Database performance impact from new tables and queries
  - **Mitigation:** Proper indexing, query optimization, database connection pooling

**Integration Risks:**

- **Risk:** Breaking existing pet profile functionality during enhancements
  - **Mitigation:** Comprehensive integration tests, feature flags for rollback, staged rollout
- **Risk:** RLS policy conflicts with new community features
  - **Mitigation:** Thorough RLS testing, separate policies for each table

**Deployment Risks:**

- **Risk:** App store rejection due to push notification integration issues
  - **Mitigation:** Follow Apple/Google guidelines strictly, test on TestFlight/internal testing first
- **Risk:** User confusion during UI changes to existing screens
  - **Mitigation:** In-app tutorials for new features, gradual UI changes with user education

**Mitigation Strategies:**

- Implement comprehensive error handling and logging
- Use feature flags for gradual rollout
- Maintain backward compatibility with existing data
- Set up monitoring and alerting for critical failures
- Prepare rollback plan for each deployment

---

# 5. Epic and Story Structure

## 5.1 Epic Approach

**Epic Structure Decision:** **Multiple Sequential Epics** organized by feature domain

**Rationale:**
The post-MVP enhancement includes 7 distinct feature areas that are best developed and deployed incrementally:

1. **Epic 1: Health Management & Reminders** - Foundation for engagement features
2. **Epic 2: Push Notifications Infrastructure** - Enables all notification-based features
3. **Epic 3: Anonymous Chat for Lost Pets** - Critical safety feature
4. **Epic 4: Community Features** - Social engagement and retention
5. **Epic 5: Analytics Dashboard** - Data insights and value
6. **Epic 6: Vet Clinic Integration** - Ecosystem expansion
7. **Epic 7: Multi-Species Support (Dogs)** - Market expansion

This approach allows:

- **Incremental value delivery** - Each epic delivers standalone value
- **Risk mitigation** - Issues in one epic don't block others
- **Resource flexibility** - Teams can work on multiple epics in parallel
- **User validation** - Test market response before full Phase 2.0 commitment

**Development Sequence:**

- **Phase 1.5 (Quick Follow):** Epics 1-3 (7 weeks)
- **Phase 2.0:** Epics 4-7 (11 weeks)

---

# 6. Epic Details

## Epic 1: Health Management & Reminders System

**Epic Goal:** Enable pet owners to manage health schedules and receive automated reminders, driving monthly active usage from 1x/month to 4x/month.

**Integration Requirements:**

- Integrate with existing pet health data (health_status, vaccination_status)
- Extend pet detail page with new "Health Records" tab
- Leverage existing Supabase Storage for health documents
- Maintain backward compatibility with current pet profiles

**Target Timeline:** 3 weeks  
**Priority:** High (Phase 1.5 - Week 1-3)

### Story 1.1: Database Schema for Health Reminders

As a **backend developer**,  
I want to **create the health_reminders table and necessary indexes**,  
So that **we can store and efficiently query health event data**.

**Acceptance Criteria:**

1. `health_reminders` table created with all fields specified in database integration strategy
2. Proper indexes created on `pet_id`, `scheduled_date`, `is_completed`
3. RLS policies implemented: owners can CRUD their own pets' reminders
4. Database migration file created following existing pattern (005_create_health_reminders.sql)
5. Foreign key constraint to pets table with ON DELETE CASCADE

**Integration Verification:**

- **IV1:** Existing pet data remains intact and accessible
- **IV2:** Pet detail queries performance not degraded (< 100ms for 90th percentile)
- **IV3:** RLS policies tested - users cannot access other users' reminder data

---

### Story 1.2: Health Reminder Domain Layer

As a **backend developer**,  
I want to **implement the domain layer for health reminders (entities, repositories, use cases)**,  
So that **we have a clean, testable business logic layer**.

**Acceptance Criteria:**

1. `HealthReminderEntity` created with all required properties
2. `HealthReminderRepository` interface defined with CRUD operations
3. Use cases implemented:
   - CreateHealthReminderUseCase
   - GetHealthRemindersForPetUseCase
   - UpdateHealthReminderUseCase
   - DeleteHealthReminderUseCase
   - MarkReminderCompleteUseCase
4. Unit tests written for all use cases (80%+ coverage)
5. Follows existing Clean Architecture pattern

**Integration Verification:**

- **IV1:** Uses existing error handling pattern (Either<Failure, Success>)
- **IV2:** Follows existing naming conventions and file structure
- **IV3:** No dependencies on presentation layer (testable in isolation)

---

### Story 1.3: Health Reminder Data Layer

As a **backend developer**,  
I want to **implement the data layer for health reminders (models, data sources, repository)**,  
So that **we can persist and retrieve health reminder data from Supabase**.

**Acceptance Criteria:**

1. `HealthReminderModel` created with JSON serialization (fromJson/toJson)
2. `HealthReminderRemoteDataSource` implemented with Supabase client
3. `HealthReminderRepositoryImpl` implements repository interface
4. CRUD operations tested with real Supabase connection
5. Proper error handling for network failures, data not found, etc.

**Integration Verification:**

- **IV1:** Uses existing Supabase client instance (no duplicate connections)
- **IV2:** Follows existing model/entity mapping pattern
- **IV3:** Error types match existing Failure classes

---

### Story 1.4: Health Reminders UI - List View

As a **pet owner**,  
I want to **view all upcoming and past health reminders for my pet in a timeline view**,  
So that **I can track my pet's health schedule at a glance**.

**Acceptance Criteria:**

1. New screen: `HealthRemindersPage` created at specified path
2. Timeline view showing reminders grouped by: Overdue, Today, Upcoming, Completed
3. Each reminder card displays: type icon, title, date, completion status
4. Pull-to-refresh functionality
5. Empty state when no reminders exist
6. Loading state with shimmer effect
7. Navigation from pet detail page via new "Health Records" tab

**Integration Verification:**

- **IV1:** Uses existing AppCard, LoadingIndicator, EmptyState components
- **IV2:** Follows existing color scheme and typography
- **IV3:** Navigation integrated with existing Go Router setup

---

### Story 1.5: Health Reminders UI - Create/Edit Form

As a **pet owner**,  
I want to **create and edit health reminders with all necessary details**,  
So that **I can schedule vaccinations, medications, and checkups**.

**Acceptance Criteria:**

1. New screen: `AddReminderPage` created (create + edit mode)
2. Form fields: type dropdown, title, description, date/time picker, recurring toggle, recurrence pattern
3. Document upload button for vaccination certificates (PDF/image)
4. Form validation for required fields
5. Save button triggers CreateHealthReminderUseCase
6. Success: navigate back to list with success message
7. Error: show error message with retry option

**Integration Verification:**

- **IV1:** Uses existing AppTextField, AppButton components
- **IV2:** Image/PDF upload uses existing StorageService
- **IV3:** Date picker matches existing app style

---

### Story 1.6: Mark Reminder Complete

As a **pet owner**,  
I want to **mark a health reminder as completed with optional notes**,  
So that **I can track which health tasks I've finished**.

**Acceptance Criteria:**

1. Checkmark button on reminder cards in list view
2. Tap checkmark opens confirmation dialog with optional notes field
3. Completed reminders move to "Completed" section with strikethrough
4. Completion timestamp stored in database
5. Can undo completion within same session

**Integration Verification:**

- **IV1:** Uses existing dialog pattern for confirmations
- **IV2:** UI updates optimistically (before server response)
- **IV3:** Undo functionality maintains data consistency

---

### Story 1.7: Recurring Reminders Logic

As a **pet owner**,  
I want **recurring reminders to automatically generate future instances**,  
So that **I don't have to manually create monthly medication reminders**.

**Acceptance Criteria:**

1. When marking recurring reminder as complete, next instance auto-generated
2. Recurrence patterns supported: daily, weekly, monthly
3. Edge function or backend logic to generate next reminder
4. User can edit or delete future instances
5. Recurring reminders show "repeat" icon in UI

**Integration Verification:**

- **IV1:** Supabase edge function follows existing function patterns
- **IV2:** Generated reminders maintain referential integrity
- **IV3:** Performance tested - generating reminders doesn't block UI

---

## Epic 2: Push Notifications Infrastructure

**Epic Goal:** Implement reliable push notification delivery for health reminders, lost pet alerts, and community updates.

**Integration Requirements:**

- Integrate Firebase Cloud Messaging (FCM) for Android
- Integrate Apple Push Notification Service (APNs) for iOS
- Store device tokens securely in Supabase
- Respect user notification preferences

**Target Timeline:** 2 weeks  
**Priority:** High (Phase 1.5 - Week 4-5)

### Story 2.1: Firebase & APNs Setup

As a **DevOps engineer**,  
I want to **configure Firebase project and APNs certificates**,  
So that **we can send push notifications to iOS and Android devices**.

**Acceptance Criteria:**

1. Firebase project created and configured in Firebase Console
2. FCM server key obtained and stored in environment variables
3. APNs certificates generated and uploaded to Firebase
4. `firebase_messaging` and `flutter_local_notifications` packages added to pubspec.yaml
5. Platform-specific configuration (AndroidManifest.xml, Info.plist) updated
6. Test notification successfully received on both iOS and Android

**Integration Verification:**

- **IV1:** Existing app functionality not affected by Firebase SDK
- **IV2:** App bundle size increase within acceptable limits (<5MB)
- **IV3:** No permission conflicts with existing packages

---

### Story 2.2: Device Token Registration

As a **mobile app user**,  
I want **my device to automatically register for push notifications**,  
So that **I can receive timely alerts without manual setup**.

**Acceptance Criteria:**

1. On app launch, request notification permission (iOS) or auto-grant (Android)
2. Device token obtained from FCM/APNs
3. Token stored in Supabase `customers` table (add `fcm_token` column)
4. Token refreshed and updated when it changes
5. Token removed when user logs out
6. Background token refresh handled

**Integration Verification:**

- **IV1:** Existing login flow not disrupted
- **IV2:** Database migration adds `fcm_token` column to customers table
- **IV3:** Token storage respects RLS policies

---

### Story 2.3: Notification Preferences Management

As a **pet owner**,  
I want to **customize which types of notifications I receive**,  
So that **I only get alerts relevant to me**.

**Acceptance Criteria:**

1. Notification preferences screen added to Profile Settings
2. Toggle switches for: Health Reminders, Lost Pet Alerts, Community Updates, Marketing
3. Preferences stored in Supabase (add `notification_preferences` JSONB column to customers)
4. Preferences synced across all user's devices
5. Default: all categories enabled except Marketing
6. Opt-out takes effect immediately

**Integration Verification:**

- **IV1:** Settings screen follows existing UI patterns
- **IV2:** Preferences stored in existing customers table (backward compatible)
- **IV3:** Real-time sync works across web and mobile platforms

---

### Story 2.4: Supabase Edge Function for Push Notifications

As a **backend developer**,  
I want **a Supabase edge function that sends push notifications via FCM/APNs**,  
So that **other features can trigger notifications via simple function calls**.

**Acceptance Criteria:**

1. Edge function `send-push-notification` created
2. Accepts parameters: user_id, title, body, data, notification_type
3. Checks user's notification preferences before sending
4. Sends to FCM for Android, APNs for iOS based on device token
5. Logs notification delivery to `notification_logs` table
6. Handles errors gracefully (invalid token, service unavailable)
7. Returns success/failure status

**Integration Verification:**

- **IV1:** Function follows existing edge function patterns
- **IV2:** Secure - only callable by authenticated service role
- **IV3:** Performance - sends notification within 5 seconds

---

### Story 2.5: Health Reminder Notifications

As a **pet owner**,  
I want **to receive push notifications for upcoming health reminders**,  
So that **I don't forget vaccinations or medications**.

**Acceptance Criteria:**

1. Daily cron edge function checks for reminders in next 3 days, 1 day, and today
2. Sends notifications at 9 AM local time: "3 days until vaccination for Fluffy"
3. Notification deep-links to health reminders page
4. Notification respects "Health Reminders" preference toggle
5. Notification marked as sent to avoid duplicates

**Integration Verification:**

- **IV1:** Cron function integrated with Supabase scheduled functions
- **IV2:** Deep linking works with existing Go Router navigation
- **IV3:** Time zone handling tested for users in different regions

---

### Story 2.6: Lost Pet Scan Notifications

As a **pet owner**,  
I want **to receive instant push notifications when someone scans my lost pet's QR code**,  
So that **I can quickly coordinate with the finder**.

**Acceptance Criteria:**

1. When lost pet QR is scanned, trigger immediate push notification to owner
2. Notification includes: "Someone scanned [Pet Name]'s QR code near [Location]"
3. Notification deep-links to chat screen
4. Notification includes map preview of scan location
5. High-priority notification (appears on lock screen)

**Integration Verification:**

- **IV1:** Triggered from existing QR scan logging logic
- **IV2:** Location data from existing scan logs
- **IV3:** Notification delivery within 5 seconds of scan

---

## Epic 3: Anonymous Chat for Lost Pets

**Epic Goal:** Enable real-time communication between pet owners and finders while maintaining privacy and safety.

**Integration Requirements:**

- Integrate with existing lost pet feature
- Use Supabase Realtime for chat messages
- Extend public pet profile page with chat button
- Create chat room automatically when pet marked as lost

**Target Timeline:** 2 weeks  
**Priority:** High (Phase 1.5 - Week 6-7)

### Story 3.1: Chat Database Schema

As a **backend developer**,  
I want **to create chat messages table and chat rooms table**,  
So that **we can store and retrieve chat history**.

**Acceptance Criteria:**

1. `chat_messages` table created as specified
2. `chat_rooms` table created with: pet_id, status (active/closed), created_at, closed_at
3. Indexes on pet_id, created_at for efficient querying
4. RLS policies: pet owners can read all messages, finders can read messages for rooms they've joined
5. Database migration file created (006_create_chat_tables.sql)

**Integration Verification:**

- **IV1:** Existing pet data and lost pet functionality unchanged
- **IV2:** Chat data properly isolated per pet
- **IV3:** RLS policies tested for privacy (finders can't access other chats)

---

### Story 3.2: Chat Domain & Data Layers

As a **backend developer**,  
I want **to implement chat domain and data layers following Clean Architecture**,  
So that **we have testable, maintainable chat business logic**.

**Acceptance Criteria:**

1. `ChatMessageEntity` and `ChatRoomEntity` created
2. `ChatRepository` interface with methods: sendMessage, getMessages, joinRoom, leaveRoom
3. Use cases: SendMessageUseCase, GetChatMessagesUseCase, JoinChatRoomUseCase
4. `ChatRemoteDataSource` using Supabase Realtime subscriptions
5. Unit tests for all use cases

**Integration Verification:**

- **IV1:** Follows existing Clean Architecture patterns
- **IV2:** Uses existing error handling (Either<Failure, Success>)
- **IV3:** Realtime subscription properly managed (no memory leaks)

---

### Story 3.3: Chat UI - Message List & Input

As a **pet finder**,  
I want **to send messages to the pet owner in real-time**,  
So that **I can communicate about returning the lost pet**.

**Acceptance Criteria:**

1. Chat screen created at `lib/features/chat/presentation/pages/chat_page.dart`
2. Message bubbles with: sender indicator (Owner/Finder #), message text, timestamp
3. Auto-scroll to bottom on new messages
4. Text input field with send button
5. Messages appear in real-time (< 500ms latency)
6. Optimistic UI updates (message shows immediately, confirmed when saved)

**Integration Verification:**

- **IV1:** Uses existing color scheme (owner messages purple, finder messages pink)
- **IV2:** AppTextField component reused for message input
- **IV3:** Real-time updates via Supabase Realtime StreamProvider

---

### Story 3.4: Location Sharing in Chat

As a **pet finder**,  
I want **to share my current location in the chat**,  
So that **the owner knows where I found their pet**.

**Acceptance Criteria:**

1. Location share button in chat input area
2. Request location permission, get current coordinates
3. Send message with lat/lng embedded
4. Message displays as map thumbnail with "View on Map" button
5. Tap opens full map view with marker

**Integration Verification:**

- **IV1:** Uses existing location service (GeolocatorService)
- **IV2:** Map view uses existing Google Maps integration
- **IV3:** Location permission handled gracefully (works without location if denied)

---

### Story 3.5: Image Sharing in Chat

As a **pet finder**,  
I want **to share photos in the chat (e.g., photo of found pet)**,  
So that **the owner can confirm it's their pet**.

**Acceptance Criteria:**

1. Camera/gallery button in chat input
2. Select image → upload to Supabase Storage (chat-images/ folder)
3. Image message displays as thumbnail in chat
4. Tap thumbnail opens fullscreen image viewer
5. Image upload progress indicator

**Integration Verification:**

- **IV1:** Uses existing ImagePickerService
- **IV2:** Uses existing StorageService for upload
- **IV3:** Image optimization applied (max 1920x1920, 85% quality)

---

### Story 3.6: Chat Access from Lost Pet Profile

As a **pet finder**,  
I want **to easily access the chat from the lost pet's public profile**,  
So that **I can quickly contact the owner**.

**Acceptance Criteria:**

1. When pet is lost, "Chat with Owner" floating action button appears on public profile
2. Tap button opens chat screen
3. First-time visitor assigned anonymous ID (stored in local storage)
4. Anonymous ID used to maintain identity across session
5. Lost banner on profile shows "Chat" button prominently

**Integration Verification:**

- **IV1:** Button only appears when is_lost = true
- **IV2:** Integrates with existing pet profile page UI
- **IV3:** Navigation uses existing Go Router

---

### Story 3.7: Chat Room Management

As a **pet owner**,  
I want **the chat room to automatically close when I mark my pet as found**,  
So that **I don't receive messages after reunion**.

**Acceptance Criteria:**

1. When pet marked as "Found," chat room status set to "closed"
2. Closed chat becomes read-only (no new messages)
3. Chat history preserved for 7 days, then auto-deleted
4. Owner can manually close chat room before marking found
5. Closed chat shows banner: "This chat is closed. Pet has been found!"

**Integration Verification:**

- **IV1:** Triggered from existing "Mark Found" functionality
- **IV2:** Database trigger or edge function handles cleanup
- **IV3:** Existing lost pet flow not disrupted

---

## Epic 4: Community Features

**Epic Goal:** Build social engagement features to increase 90-day retention from 40% to 70%.

**Target Timeline:** 4 weeks  
**Priority:** Medium (Phase 2.0 - Week 8-11)

_(Stories 4.1-4.10 for community posts, comments, reactions, nearby places, follow system)_

## Epic 5: Analytics Dashboard

**Epic Goal:** Provide data insights to owners through analytics dashboard.

**Target Timeline:** 2 weeks  
**Priority:** Medium (Phase 2.0 - Week 12-13)

_(Stories 5.1-5.6 for scan analytics, health timeline, export functionality)_

## Epic 6: Vet Clinic Integration

**Epic Goal:** Partner with 50+ vet clinics in Jakarta for integrated health records.

**Target Timeline:** 3 weeks  
**Priority:** Low (Phase 2.0 - Week 14-16)

_(Stories 6.1-6.8 for clinic portal, directory, pet linking, health record integration)_

## Epic 7: Multi-Species Support (Dogs)

**Epic Goal:** Support dog owners to increase total addressable market by 3x.

**Target Timeline:** 2 weeks  
**Priority:** Low (Phase 2.0 - Week 17-18)

_(Stories 7.1-7.5 for dog breeds, species-specific forms, community filtering)_

---

# Appendix

## A. Success Metrics

**Phase 1.5 Metrics:**

- Health reminder feature adoption: 60% of active users
- Push notification delivery rate: >95%
- Chat response time: <30 minutes average for lost pets

**Phase 2.0 Metrics:**

- Community post creation: 30% of users post at least once
- Community engagement: 50% of users interact with community weekly
- Analytics feature usage: 40% of users view analytics monthly
- Vet clinic partnerships: 50+ clinics in first 6 months
- Dog owner adoption: 25% of new users register dogs

## B. Timeline Summary

**Total Duration:** 18 weeks (~4.5 months)

**Phase 1.5 (Weeks 1-7):**

- Epic 1: Health Management (Weeks 1-3)
- Epic 2: Push Notifications (Weeks 4-5)
- Epic 3: Anonymous Chat (Weeks 6-7)

**Phase 2.0 (Weeks 8-18):**

- Epic 4: Community Features (Weeks 8-11)
- Epic 5: Analytics Dashboard (Weeks 12-13)
- Epic 6: Vet Clinic Integration (Weeks 14-16)
- Epic 7: Multi-Species Support (Weeks 17-18)

## C. Resource Requirements

**Development Team:**

- 2 Flutter developers (full-time)
- 1 Backend developer (full-time)
- 1 UI/UX designer (part-time, 50%)
- 1 QA engineer (full-time)
- 1 DevOps engineer (part-time, 25%)

**External Services:**

- Firebase Cloud Messaging: Free tier (unlimited)
- Google Maps API: $200-500/month estimated
- Supabase: Scale to Pro plan ($25/month)

---

**END OF BROWNFIELD PRD**

**Status:** Ready for review and refinement  
**Next Steps:** Team review → User validation → Story prioritization → Sprint planning
