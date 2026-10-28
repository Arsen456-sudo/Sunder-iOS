# Sunder iOS development workspace

Independent client based on SimpleX Chat; not an official or endorsed release.

This file provides guidance when working with code in this repository.

## iOS App Overview

The iOS app is a SwiftUI application that interfaces with the Haskell core library via FFI. It shares the SimpleXChat framework with two extensions: Notification Service Extension (NSE) for push notifications and Share Extension (SE) for sharing content from other apps.

## Build & Development

Open `SimpleX.xcodeproj` in Xcode. The project has five targets:
- **SimpleX (iOS)** - Main app (Bundle ID: `chat.simplex.app`)
- **SimpleXChat** - Framework containing FFI bridge and shared types
- **SimpleX NSE** - Notification Service Extension
- **SimpleX SE** - Share Extension
- **Tests iOS** - UI tests

Build and run via Xcode (Product > Build/Run). Tests run via Product > Test or:
```bash
xcodebuild test -scheme "SimpleX (iOS)" -destination 'platform=iOS Simulator,name=iPhone 15'
```

Deployment target: iOS 15.0+, Swift 5.0.

## Architecture

### Haskell Core Integration

The app calls the Haskell core library through C FFI defined in `SimpleXChat/SimpleX.h`:
- `chat_migrate_init_key()` - Initialize/migrate database
- `chat_send_cmd_retry()` - Send command to chat controller
- `chat_recv_msg_wait()` - Receive messages from controller

Swift wrappers in `SimpleXChat/API.swift`:
- `chatMigrateInit()` - Initialize chat controller
- `sendSimpleXCmd<R>()` - Send typed commands and parse responses
- `recvSimpleXMsg<R>()` - Receive typed messages

Haskell runtime initialization (`SimpleXChat/hs_init.c`) uses different memory configurations:
- Main app: 64MB heap
- NSE: 512KB heap (minimal footprint for background processing)
- SE: 1MB heap

Pre-compiled Haskell libraries are expected in ignored local `Libraries/{ios,mac,sim}/`
paths; they are not included in this checkout. Their exact build/source provenance must
be recorded before releasing a binary.

### State Management

- **ChatModel** (`Shared/Model/ChatModel.swift`) - Main singleton `ObservableObject` for app-wide state (chat list, active chat, users)
- **ItemsModel** - Manages chat items within a selected chat (similar to Kotlin's ChatsContext)
- **AppTheme** - Theme management and customization

### App Structure

Entry point: `Shared/SimpleXApp.swift`

Key directories in `Shared/`:
- `Model/` - Data models and API layer (`ChatModel.swift`, `SimpleXAPI.swift`)
- `Views/` - SwiftUI views organized by feature:
  - `ChatList/` - Chat list and user picker
  - `Chat/` - Message display and composition
  - `Call/` - VoIP call UI
  - `UserSettings/` - App settings
  - `LocalAuth/` - Passcode and biometric authentication
  - `Database/` - Database initialization and migration

### Shared Data Between Targets

All three targets share data via App Group (`group.chat.simplex.app`):
- `SimpleXChat/AppGroup.swift` - GroupDefaults wrapper for typed shared preferences
- Keychain for sensitive data: `kcDatabasePassword`, `kcAppPassword`, `kcSelfDestructPassword`

### Key Types

Types are defined in `SimpleXChat/`:
- `ChatTypes.swift` - User, Chat, Message, Group types
- `APITypes.swift` - API request/response types

Commands follow `ChatCmdProtocol` (has `cmdString` property), sent as JSON through FFI.

## Localization

31 languages supported. Localization files in `SimpleX Localizations/`.

Workflow:
- `Product > Export Localizations` - Export XLIFF files
- `Product > Import Localizations` - Import updated translations

## Sunder resources and offline notices

The optional proprietary illustration import is disabled for this fork. Existing system
symbol presentation is selected directly; setting SIMPLEX_ASSETS_DIR or SIMPLEX_ASSETS
does not restore the former illustration-import helper. The Xcode phase entry point is
retained as a no-import script. Required app icon slots are temporary plain color fields.
Other inherited graphics, wallpapers and sounds still require source/right checks.

The main target includes `Shared/SunderNotices.txt`. Regenerate it with:

```sh
python scripts/ios/generate-sunder-notices.py
python scripts/ios/generate-sunder-notices.py --check
```

Paths above are relative to the repository root. The viewer is under Settings → Help &
support → Licenses and copyright notices and uses standard SwiftUI navigation and lazy
plain-text sections. The notices work offline; the source link points to the Sunder public repository.
Read [the iOS evidence review](../../docs/fork/ios/README.md) for exact scope and open gaps.
The collection is not a resolved dependency list for a final IPA or publication clearance.

## Background Capabilities

Configured in Info.plist:
- Background modes: audio, fetch, remote-notification, voip
- URL scheme: `simplex://` for deep linking
- BGTaskScheduler: `chat.simplex.app.receive`

## Source publication cleanup

Original bundled artwork and sampled audio are removed. Preset themes retain their
IDs/colors but use a cached neutral dot texture; badges/statuses use system symbols.
Regenerate original cues with `python scripts/ios/generate-sunder-sounds.py`.
The source/support base URL is the SunderRepositoryURL key in SimpleX--iOS--Info.plist;
set the final repository URL and regenerate notices before a public binary release.
See ../../docs/fork/PUBLIC_SOURCE_EXPORT.md for a source snapshot without private history.
Signing, own Keychain/App Groups/APNs, native dependencies and device validation remain
separate binary-release requirements; no native build is claimed by these edits.

SunderSourceRef is the matching source commit/tag/branch for the configured repository.
The initial test source tag is preview-20261028-1. Set both source fields for a release
and regenerate notices; a mutable development branch is not a binary/source manifest.

## Manual test IPA build

Run the Sunder iOS test IPA workflow on GitHub Actions. It uses Xcode 26 and the locked Nix iOS core target from this source, caches the resulting archives and Swift packages, then packages an unsigned device app. Logs and checksums are retained for three days. This is an initial build pipeline, not a verified binary release; signing, shared Keychain/App Groups and push service configuration still require independent adaptation and device checks.
