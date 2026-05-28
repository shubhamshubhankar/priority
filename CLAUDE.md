# Priority App — AI Agent Instructions

> This file is the authoritative guide for Claude, Codex, Gemini, and any other AI agent
> working on this project. Read it fully before making any changes.

---

## Project Overview

**Priority** is a cross-platform personal productivity app with three core features:

| View | Description |
|------|-------------|
| Notes | Google Keep-style cards with checklists, pinning, color coding |
| Matrix | Eisenhower 2×2 quadrant task management with deadlines and subtasks |
| Goals | Short-term and long-term goals with milestones and progress tracking |

**Stack:** Flutter (Dart) + Firebase (Auth, Firestore, Hosting)
**Platforms:** Android (primary), Web (Firebase Hosting), iOS (future)
**Auth:** Google OAuth → TOTP 2-factor (no SMS, no Cloud Functions)
**Database:** Cloud Firestore with offline persistence enabled

---

## Architecture

Clean Architecture with three layers:

```
lib/
├── data/         — Models (freezed), datasources (Firebase), repository implementations
├── domain/       — Use cases (pure Dart, no Firebase imports)
└── presentation/ — BLoCs, screens, widgets, theme, providers
```

**State management:**
- `flutter_bloc` for feature-level state (NotesBLoC, MatrixBLoC, GoalsBLoC)
- `Riverpod` (StreamProvider/Provider) for auth state, connectivity, and DI

**Navigation:** `go_router` with auth redirect guard in `lib/app/router.dart`

---

## Key Conventions

### File naming
- All Dart files: `snake_case.dart`
- BLoC files: `{feature}_bloc.dart` + `{feature}_event.dart` + `{feature}_state.dart`
- Screens: `{feature}_screen.dart`
- Models: `{model}_model.dart`

### State management pattern
- BLoC events: past-tense actions → `NoteCreated`, `NotePinToggled`
- BLoC states: conditions → `NotesLoaded`, `NotesError`
- **Never put Firebase calls in widget build() methods**
- **Never use setState for Firestore data** — always go through BLoC/Riverpod

### Firestore data rules
- All data lives under `/users/{uid}/` — **never create top-level collections**
- Items, subtasks, milestones are subcollections (not arrays) to avoid 1 MB doc limit
- `position: double` fields use midpoint trick for reorder (LexoRank-lite)
- Always convert Firestore `Timestamp` ↔ `DateTime` in datasource layer, NOT in models
- **Firestore queries use simple `.snapshots()` with NO composite `orderBy`** — all sorting is done client-side in the stream `.map()`. This avoids composite index requirements and works instantly without index build time.

### BLoC stream error handling
- **Never call `emit()` inside a stream `onError` callback** — by the time the async error arrives, the event handler has already completed and `emit` throws an assertion error.
- Always dispatch a `*StreamErrored` event via `add()` in the `onError` callback, then handle it in a separate event handler that calls `emit()`.
- Pattern: `onError: (e) => add(FeatureStreamErrored(e.toString()))`

### Google Sign-In platform handling
- Web: uses `FirebaseAuth.instance.signInWithPopup(GoogleAuthProvider())` — no OAuth client ID needed
- Mobile: uses `google_sign_in` package with lazy initialization (`GoogleSignIn` must NOT be instantiated at field level on web — it asserts a clientId on construction)
- `GoogleSignIn` is created lazily via a getter: `GoogleSignIn get _mobileSignIn => _googleSignIn ??= GoogleSignIn()`

### Completion behaviour (all three views)
When an item/task/subtask is marked done:
- Set `isCompleted/isChecked: true`
- Sort: completed items at bottom (client-side: `isCompleted ASC, position/updatedAt ASC`)
- Render: grey text + strikethrough, `AnimatedOpacity(opacity: 0.45)`

### Checklist item behaviour
- Enter/Next key creates a new item below (calls `onSubmit` callback)
- Delete item only via the × button — not via keyboard shortcut

---

## Adding a New Feature

1. Create model in `lib/data/models/{name}_model.dart` (use freezed)
2. Run `dart run build_runner build --delete-conflicting-outputs`
3. Create datasource in `lib/data/datasources/firestore_{name}_datasource.dart`
4. Create repository interface in `lib/data/repositories/{name}_repository.dart`
5. Create repository impl in `lib/data/repositories/impl/{name}_repository_impl.dart`
6. Create use cases in `lib/domain/usecases/{name}/`
7. Add repository provider to `lib/presentation/providers/providers.dart`
8. Create BLoC files in `lib/presentation/screens/{name}/`
9. Create screen(s) in `lib/presentation/screens/{name}/`
10. Add route to `lib/app/router.dart`
11. Add navigation destination to `lib/presentation/widgets/main_shell.dart`

---

## Firebase Configuration

### Services used (Spark free plan)
| Service | Purpose |
|---------|---------|
| Authentication | Google OAuth + TOTP 2FA |
| Firestore | Real-time database + offline persistence |
| Hosting | Flutter Web deployment |

### Security rules
- Location: `firebase/firestore.rules`
- Deploy: `firebase deploy --only firestore:rules`
- **Always deploy rules BEFORE deploying code** that depends on new collection paths

### Firestore schema
```
/users/{uid}
  /notes/{noteId}        — title, isPinned, color, isArchived, createdAt, updatedAt
    /items/{itemId}      — text, isChecked, position, createdAt, updatedAt
  /tasks/{taskId}        — title, description, quadrant, isCompleted, deadline, ...
    /subtasks/{subtaskId}
  /goals/{goalId}        — title, horizon, targetDate, isCompleted, progressPercent, ...
    /milestones/{milestoneId}
```

---

## Environment & Secrets

| File | Status | How to get it |
|------|--------|---------------|
| `android/app/google-services.json` | **GITIGNORED** | Firebase Console → Project Settings → Android |
| `ios/Runner/GoogleService-Info.plist` | **GITIGNORED** | Firebase Console → Project Settings → iOS |
| `lib/firebase_options.dart` | **GITIGNORED** | Run `flutterfire configure` |
| `android/key.properties` | **GITIGNORED** | Create manually (see Play Store setup) |

**Do not commit any of the above files.**

---

## Setup From Scratch

```bash
# 1. Install Flutter (stable channel) from https://flutter.dev
# 2. Install Firebase CLI
npm install -g firebase-tools
firebase login

# 3. Install flutterfire CLI
dart pub global activate flutterfire_cli

# 4. Create Firebase project at https://console.firebase.google.com
#    - Enable Authentication: Google + Multi-factor (TOTP)
#    - Create Firestore database (production mode)

# 5. Configure Firebase for this app
flutterfire configure
# This generates lib/firebase_options.dart and downloads google-services.json

# 6. Install Flutter dependencies
flutter pub get

# 7. Generate freezed code
dart run build_runner build --delete-conflicting-outputs

# 8. Deploy Firestore rules and indexes
firebase deploy --only firestore:rules,firestore:indexes

# 9. Run on web
flutter run -d chrome

# 10. Run on Android emulator
flutter run
```

---

## Build & Deploy Commands

```bash
# Run locally
flutter run                                          # Android/emulator
flutter run -d chrome                               # Web

# Analyze code
flutter analyze

# Run tests
flutter test

# Build for production
flutter build web --release --web-renderer canvaskit   # Web build
flutter build apk --release                            # Android APK
flutter build appbundle --release                      # Android AAB (Play Store)

# Deploy
firebase deploy --only hosting                         # Web to Firebase
firebase deploy --only firestore:rules,firestore:indexes  # Rules + indexes
```

---

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_auth` | Google OAuth + TOTP multi-factor |
| `cloud_firestore` | Real-time database + offline cache |
| `flutter_bloc` | Feature-level state machines |
| `flutter_riverpod` | DI, auth stream, connectivity |
| `go_router` | Declarative routing + auth guard |
| `flutter_staggered_grid_view` | Masonry grid for Notes screen |
| `qr_flutter` | QR code for TOTP enrollment |
| `freezed` + `json_serializable` | Immutable models with serialization |
| `connectivity_plus` | Offline detection |

---

## TOTP 2FA Implementation Notes

Enrollment flow (first sign-in):
1. `user.multiFactor.getSession()` → MultiFactorSession
2. `TotpMultiFactorGenerator.generateSecret(session)` → TotpSecret
3. Display QR with `qr_flutter` using `secret.generateQrCodeUrl()`
4. User scans with Google Authenticator / Authy
5. `TotpMultiFactorGenerator.getAssertionForEnrollment(secret, otp)` → enroll

Verification flow (subsequent sign-ins):
1. Firebase throws `FirebaseAuthMultiFactorException` with resolver
2. App navigates to `/auth/totp-verify` passing resolver as `extra`
3. `TotpMultiFactorGenerator.getAssertionForSignIn(enrollmentId, otp)`
4. `resolver.resolveSignIn(assertion)`

---

## DO NOT

- Do not put Firebase logic in widget `build()` methods
- Do not add top-level Firestore collections — keep everything under `/users/{uid}/`
- Do not disable Firestore security rules during development
- Do not commit `google-services.json`, `GoogleService-Info.plist`, `key.properties`, or `firebase_options.dart`
- Do not add Cloud Functions unless necessary (requires Blaze plan)
- Do not import Firebase packages in `lib/domain/` — domain layer must stay pure Dart
- Do not use `setState` for data that comes from Firestore — use BLoC/Riverpod streams

---

## Play Store Submission (Future)

```bash
# 1. Generate upload keystore
keytool -genkey -v \
  -keystore upload-keystore.jks \
  -alias upload \
  -keyalg RSA -keysize 2048 \
  -validity 10000

# 2. Create android/key.properties (NEVER commit this file)
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=../upload-keystore.jks

# 3. Build signed AAB
flutter build appbundle --release

# 4. Submit via Google Play Console ($25 one-time developer fee)
```

---

## Roadmap

- [ ] Push notifications for deadline reminders (requires Blaze plan → Cloud Functions or FCM)
- [ ] Tags/labels on notes and tasks
- [ ] Note sharing (read-only link)
- [ ] iOS App Store submission
- [ ] Dark mode color customization
- [ ] Export data as JSON/CSV
- [ ] Multi-account support
- [ ] Google Play Store public launch
