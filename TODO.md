# Priority App — Known Issues & Roadmap

---

## Bugs to Fix

- [ ] **Avatar image 429 error** — Google profile photo returns HTTP 429 (rate-limited). Wrap `_UserAvatar` in a try-catch and show a fallback initials circle when the image fails to load.
- [ ] **Note editor: items do not autofocus correctly** — When a new item is created via Enter key, the autofocus logic uses `position` comparison which may be brittle after many reorders. Replace with an item ID tracked in state.
- [ ] **Task editor: subtasks not editable in-line** — Currently subtask text is shown as read-only `CheckboxListTile`. Add an inline text field like the note checklist.
- [ ] **Goal editor: same inline milestone editing needed** — Same as above for milestones.
- [ ] **Firestore indexes** — Composite indexes in `firebase/firestore.indexes.json` are deployed but not used (queries are sorted client-side). Indexes can be removed from the file once confirmed unnecessary, or left for future server-side pagination.

---

## Features to Add (Short Term)

- [ ] **2-Factor Authentication (TOTP)** — Requires upgrading Firebase to Blaze (pay-as-you-go) plan. Code is already written in `totp_setup_screen.dart` and `totp_verify_screen.dart`. Steps:
  1. Upgrade Firebase project to Blaze plan
  2. Enable Multi-factor Authentication in Firebase Console → Authentication → Multi-factor
  3. The app code is already in place — it will work immediately

- [ ] **Note editor: undo/redo** — Implement `UndoHistoryController` on the title `TextField`.
- [ ] **Matrix: drag task between quadrants** — `LongPressDraggable` + `DragTarget` on each `QuadrantContainer`.
- [ ] **Note color picker: more colors** — Expand `kNoteColors` in `app_colors.dart`.
- [ ] **Empty note cleanup** — Delete notes that are still empty (no title, no items) when the user navigates away from `NoteEditorScreen`.
- [ ] **Search: include item text** — Currently search only matches note titles. Extend to match checklist item text.

---

## Features to Add (Long Term / Product Launch)

- [ ] **Android app** — Build signed AAB and submit to Google Play Store. See `COMMANDS.md` for build commands and `README.md` for signing key setup.
- [ ] **iOS app** — Run `flutterfire configure` with iOS platform selected, add `GoogleService-Info.plist`.
- [ ] **Push notifications** — Deadline reminders require Firebase Cloud Messaging + Cloud Functions (Blaze plan).
- [ ] **Tags on notes and tasks** — Add `tags: List<String>` field and filter UI.
- [ ] **Note sharing** — Read-only share link via Firebase Dynamic Links or a public Firestore subcollection.
- [ ] **Export data** — Download all notes/tasks/goals as JSON or CSV.
- [ ] **Dark mode toggle** — Already supported (system theme auto-switches). Add a manual override setting stored in user preferences Firestore doc.
- [ ] **Multi-account support** — Firebase Auth supports multiple sign-in providers. Would need a per-account data namespace.

---

## Technical Debt

- [ ] **Client-side sorting** — All Firestore queries currently sort in Dart after fetching. This is fine for personal use but will become slow with 1000+ items. When needed, re-enable server-side orderBy and ensure composite indexes are built first.
- [ ] **BLoC per-tab lifecycle** — `NotesBloC`, `MatrixBloC`, `GoalsBloC` are created fresh on every tab visit because GoRouter unmounts the screen on navigation. Wrap them in a `Riverpod` `StateNotifierProvider` or hoist them to a parent widget to preserve state across tab switches.
- [ ] **Tests** — Unit tests cover repository delegation only. Add BLoC tests (with `bloc_test` once version conflict is resolved), widget tests for `NoteCard`, and integration test for the full sign-in → create note → verify note appears flow.
- [ ] **`bloc_test` version conflict** — `freezed ^2.5.2` and `bloc_test ^9.1.7` have an incompatible `analyzer` transitive dependency. Resolve once either package releases a compatible version, then restore `bloc_test` to `pubspec.yaml`.

---

## Infrastructure

- [ ] **Custom domain** — Point a custom domain at Firebase Hosting (e.g. `app.priorityapp.com`). Free on Spark plan.
- [ ] **CI/CD** — Add GitHub Actions workflows for: (1) `flutter analyze + flutter test` on every push, (2) auto-deploy web on merge to `main`.
- [ ] **Firestore backup** — Enable automated Firestore backups in Google Cloud Console before public launch.
