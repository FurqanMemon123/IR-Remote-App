# IR Remote - Universal Remote Control

A Flutter-based Android app that turns your phone's built-in infrared blaster into a universal remote for **Air Conditioners, Projectors, DVD Players, and Blu-ray Players**.

**No ads. No login. Fully offline.**

> **Screenshots:** add device captures to `screenshots/` (home, add-remote flow, remote screens) and reference them here.

**Status:** builds, analyzes clean (`flutter analyze` → 0 issues) and runs on Android (verified on an x86_64 API 28 emulator). No IR blaster on emulators, so it runs in **Demo Mode** there; real transmission requires a phone with an IR emitter.

---

## How IR Works

Infrared remote controls work by pulsing an IR LED at a **carrier frequency** (typically 38 kHz) in specific patterns of marks (on) and spaces (off). Each button press sends a unique pattern that the target device recognizes.

### NEC Protocol
The most common IR protocol. A transmission consists of:
- **Header:** 9000us mark + 4500us space
- **Data:** 32 bits (address, inverted address, command, inverted command), LSB first
  - Logical 0: 560us mark + 560us space
  - Logical 1: 560us mark + 1690us space
- **Stop bit:** 560us mark

### Pronto Hex
A universal encoding format where each number represents carrier cycles at a reference frequency. The app converts these to microsecond pulse patterns.

### Android ConsumerIrManager
The native Android API that accepts a carrier frequency (Hz) and an int array of pulse durations (microseconds). The app bridges this through a custom `MethodChannel` (no third-party IR plugins).

---

## Architecture

```
┌─────────────────────────────────────────────────┐
│  UI Layer (features/)                           │
│  Splash, Home, Add Remote Flow, Remote Screens  │
├─────────────────────────────────────────────────┤
│  State Management (providers/)                  │
│  Riverpod: providers, notifiers, add flow state │
├─────────────────────────────────────────────────┤
│  Services & Repositories (core/, data/)         │
│  IrService, IrRepository, RemoteStorage         │
├─────────────────────────────────────────────────┤
│  Native Bridge (MainActivity.kt)                │
│  MethodChannel "ir" → ConsumerIrManager         │
├─────────────────────────────────────────────────┤
│  Data Layer                                     │
│  Hive (persisted remotes), JSON assets (IR DB)  │
└─────────────────────────────────────────────────┘
```

**Tech stack:**
- Flutter 3 / Dart 3
- `flutter_riverpod` for state management
- `go_router` for navigation
- `hive` + `hive_flutter` for local storage
- `uuid` for unique IDs
- Kotlin `ConsumerIrManager` via MethodChannel

---

## How to Run

### Prerequisites
- Flutter SDK (stable channel)
- Android SDK with API 21+ (`minSdk` satisfies `ConsumerIrManager`, which needs API 19+)
- An Android device or emulator. Real transmission requires hardware with an IR blaster.

### Steps
```bash
flutter pub get
flutter devices          # confirm your Android device/emulator is listed
flutter run -d <deviceId>
```

To build an installable APK:
```bash
flutter build apk --debug     # or --release
# output: build/app/outputs/flutter-apk/
```

To run the checks:
```bash
flutter analyze    # 0 issues
flutter test       # 9/9 passing
```

### Demo Mode
If your device has no IR blaster, the app automatically enters **Demo Mode**. All buttons work — instead of transmitting, the app logs and displays the frequency and pulse pattern that would be sent, and a "Demo" chip appears in the app bar.

---

## Data Sources & Licenses

The IR code database uses **sample NEC codes** (marked with `"sample": true` in JSON assets). These are structurally valid NEC protocol codes but have **not been verified against real devices**.

For production use, codes should be sourced from:
- [Flipper-IRDB](https://github.com/Lucaslhm/Flipper-IRDB) — MIT License
- [probonopd/irdb](https://github.com/probonopd/irdb) — various licenses per file
- [IRremoteESP8266](https://github.com/crankyoldgit/IRremoteESP8266) — LGPL-2.1 (AC frame reference)

**Current status:** All codes in `assets/ir_db/*.json` are sample placeholders (each code set carries `"sample": true`, and the Test Code screen shows a "Sample data" note). The app correctly encodes NEC protocol, but specific address/command pairs need to be replaced with verified codes from the above databases for real device control.

---

## Known Limitations

1. **Android only** — iOS has no public IR API
2. **Requires IR blaster** — phones without one use Demo Mode
3. **AC uses per-button signals** — not full-state frames, so the on-screen AC state can drift from the real unit (e.g., if someone changes the temp with the physical remote)
4. **Limited brand coverage** — 3 brands per device type with 2 code sets each
5. **Sample data** — IR codes are placeholder NEC codes, not verified against real devices

---

## Future Work

- Full AC frame builders per brand (Samsung, LG, Daikin, etc.)
- IR learning mode (capture codes from physical remotes)
- More brands and device types (soundbars, TVs, cameras)
- Home screen widgets / Quick Settings tiles
- Import/export remotes
- Community code sharing

---

## Project Structure

```
lib/
├── main.dart                    # App entry, Hive init, ProviderScope
├── core/
│   ├── theme.dart               # Material 3 light/dark themes
│   ├── router.dart              # go_router configuration
│   ├── constants.dart           # Button key constants (Btn class)
│   └── ir/
│       ├── ir_service.dart      # MethodChannel wrapper
│       └── ir_encoder.dart      # NEC + Pronto encoders
├── data/
│   ├── models/
│   │   ├── ir_signal.dart       # IrSignal + IrCodeSet models
│   │   ├── saved_remote.dart    # SavedRemote model
│   │   └── ac_state.dart        # AC state model
│   ├── ir_repository.dart       # JSON asset loader
│   └── remote_storage.dart      # Hive CRUD
├── providers/
│   └── providers.dart           # Riverpod providers & notifiers
└── features/
    ├── splash/splash_screen.dart
    ├── home/home_screen.dart
    ├── add_remote/
    │   ├── device_type_screen.dart
    │   ├── brand_screen.dart
    │   ├── test_code_screen.dart
    │   └── save_remote_screen.dart
    └── remote/
        ├── remote_screen.dart
        ├── ac_remote.dart
        ├── projector_remote.dart
        ├── dvd_remote.dart
        └── widgets.dart
```

---

## Testing

```bash
flutter test
```

Unit tests cover:
- NEC encoder: pattern length, header, address/command inversion, stop bit
- Pronto decoder: frequency calculation, pattern length

---

## License

This project is built as a demonstration/interview task. IR code databases are sourced from open projects with their respective licenses (see Data Sources above).
