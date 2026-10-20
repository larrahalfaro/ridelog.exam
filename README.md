# RideLog — Motorcycle Maintenance & Fuel Tracker

A Flutter mobile app (Android/iOS) that helps riders track motorcycle maintenance,
fuel fill-ups, get smart service reminders, and see cost reports — built to match
the project spec discussed earlier (see the companion concept document).

Stack: **Flutter + local SQLite (sqflite)** — no Firebase account or backend
server needed. Everything runs on-device, so you can clone this, open it in
VS Code, and run it on an emulator in minutes.

---

## 1. Prerequisites

Install these once on your machine:

1. **Flutter SDK** — https://docs.flutter.dev/get-started/install
   After installing, run `flutter doctor` and fix anything marked with a ✗.
2. **VS Code** — https://code.visualstudio.com/
3. **VS Code Flutter extension** — open VS Code → Extensions (`Ctrl+Shift+X`) →
   search "Flutter" → install the official one by Dart Code (it pulls in the
   Dart extension automatically).
4. **An emulator or device**:
   - Android: install Android Studio (for the SDK + AVD Manager) and create a
     virtual device, OR plug in a real Android phone with USB debugging on.
   - iOS (Mac only): install Xcode, then `open -a Simulator`.

---

## 2. Open the project

1. Unzip this project folder.
2. In VS Code: **File → Open Folder** → select the `ridelog` folder.
3. VS Code should detect it's a Flutter project. If prompted to run `pub get`,
   click **Get Packages** — or open a terminal (`` Ctrl+` ``) and run:

```bash
flutter pub get
```

This downloads the dependencies listed in `pubspec.yaml` (sqflite, fl_chart,
shared_preferences, intl, crypto, etc.).

---

## 3. Run it

1. Start your emulator (Android Studio's AVD Manager → click the ▶ next to a
   virtual device), or connect a physical device.
2. In VS Code, press `F5`, or use the terminal:

```bash
flutter run
```

3. Pick your target device if prompted. The app should build and launch —
   first launch takes longer (compiling), later runs are much faster with
   hot reload (`r` in terminal, or save a file with hot reload enabled).

---

## 4. Try the app

1. **Register** a new account (name, email, password — stored locally,
   hashed with SHA-256).
2. You'll be walked into **Add Motorcycle** — enter a brand, model, year,
   and current odometer.
3. From the bike's detail page, add a few **Maintenance** records (try "Oil
   Change" with different odometer readings) and **Fuel** fill-ups.
4. Check the **Reminders** tab — it computes due dates/mileage automatically
   based on the service intervals in `lib/utils/constants.dart`.
5. Check **Reports** — bar chart of monthly spend, line chart of fuel
   efficiency (km/L), and a pie chart of maintenance vs. fuel cost.

---

## 5. Project structure

```
lib/
  main.dart                     # App entry point
  models/                       # Plain Dart data classes (User, Motorcycle, etc.)
  db/
    database_helper.dart        # SQLite schema + all CRUD methods (singleton)
  utils/
    constants.dart              # Theme, colors, ServiceType definitions
    reminder_logic.dart         # Business logic: computes due/overdue reminders
    auth_service.dart           # Register/login/session handling
  widgets/
    main_nav_scaffold.dart      # Bottom nav bar hosting the 5 main tabs
    status_badge.dart           # Reusable "OVERDUE/DUE SOON/OK" badge + progress bar
  screens/
    splash_screen.dart
    auth/                       # Login, Register
    onboarding/                 # First-time "add your bike" wizard
    home/                       # Dashboard
    motorcycles/                # List, detail, add/edit
    maintenance/                # List, add/edit
    fuel/                       # List, add/edit
    reminders/                  # Reminders screen
    reports/                    # Charts screen
    profile/                    # Profile, Settings
```

This mirrors the screen-by-screen structure and database schema from the
project's concept document — so you can point to a specific file when
explaining a specific feature.

---

## 6. Database

SQLite database file is created automatically on first launch (via
`sqflite`) at the app's local data directory — you don't need to set up
anything. Tables: `users`, `motorcycles`, `maintenance_logs`, `fuel_logs`,
`maintenance_rules` (see `lib/db/database_helper.dart` for the exact schema —
it matches the ER design from the spec doc).

To inspect the DB directly during development (optional):
- Android emulator: **View → Command Palette → "Flutter: Open DevTools"**,
  or pull the `.db` file via `adb shell run-as com.example.ridelog` +
  `cat` the file from `databases/ridelog.db`.

To wipe all local data during testing: uninstall the app from the
emulator/device, or clear app storage.

---

## 7. Known simplifications (intentional, for a student project)

- **Password hashing** uses SHA-256 with a static salt — fine for
  demonstrating the concept, but a real production app should use bcrypt or
  argon2 with a per-user salt.
- **Local notifications** aren't wired up yet — the Reminders screen computes
  due/overdue status live when opened. Adding `flutter_local_notifications` to
  push actual notifications is a good "next feature" to demo if you have
  extra time (see the concept doc's Future Improvements list).
- **Single-device only** — there's no cloud sync. All data lives in the local
  SQLite file. Multi-device sync via Firebase is listed as a future
  enhancement in the concept doc.

---

## 8. Suggested demo script (for your defense/presentation)

1. Register → show it lands you in "Add Motorcycle" (onboarding flow).
2. Add a motorcycle → show Dashboard now displays it with an odometer.
3. Add 2–3 maintenance entries with different service types and past dates.
4. Add 2–3 fuel entries (mark them "Full Tank") → show fuel efficiency
   appears in the Fuel tab.
5. Open Reminders → explain the progress bar and OVERDUE/DUE SOON logic —
   this is the core "smart reminder" feature the whole app is built around.
6. Open Reports → show the bar chart (monthly spend), line chart (fuel
   efficiency trend), pie chart (cost breakdown).
7. Edit/delete a motorcycle or log entry → demonstrates full CRUD.
8. Open Settings → change currency/unit to show that's persisted per user.
