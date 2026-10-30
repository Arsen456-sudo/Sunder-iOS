# System presentation adoption

The visual reference is `Shared/Views/UserSettings/AppearanceSettings.swift`:
standard Apple List, Section, Picker, Toggle, fields and navigation. It remains
unchanged. The project still uses SwiftUI and UIKit together; this work does not
claim that every SwiftUI screen was rewritten into a UIViewController.

## Common coverage

`SunderSystemInterface` installs grouped list/form defaults, contextual automatic
controls and system toolbar/scroll-edge presentation on iOS 26+. It is applied at
the main app root, ThemedBackground, both appSheet overloads, native avatar-sheet
content, and the share-extension root. Explicit specialized descendant styles
remain in charge. No global UIKit appearance mutation is added.

`SYSTEM_UI_INVENTORY.json` records all 187 source files in this scope, including
content components and non-UI helpers. It is a lexical inventory, not 187 distinct
screens or proof of runtime coverage. Regenerate with:

```sh
python3 scripts/ios/audit-system-ui.py
python3 scripts/ios/audit-system-ui.py --check
```

CI checks the inventory before compiling the IPA. Hashes normalize line endings.

## Screen families

| Family | System presentation / explicit treatment |
|---|---|
| Settings and every settings destination | Common native list/form/picker/toggle defaults via root and themed screen scope |
| Main chat list and folders | Previously adapted native chrome/search/glass controls; explicit plain chat list retained |
| Avatar menu and profile switching | Native iOS 26 sheet, accessible large detent, scrollable content; nested destinations open after dismissal |
| New chat, contacts and deleted chats | Shared native search/filter controls, original link and name-resolution bindings |
| Chat, selection and pending-contact/member states | Native bars plus shared command surfaces; original editor/renderer/gestures and permission actions retained |
| Contact/group/channel profiles | Previously adapted compact native chrome and grouped information |
| Group member profiles | System navigation restored, close action for modal use, original pushed back action retained |
| Connection/invitation information | System title/close on iOS 26; original QR, sharing, alias-save and deletion paths retained |
| Onboarding, conditions, database recovery | Shared native prominent action styling; original consent/validation and recovery logic |
| Database, migration, remote access | Common system form/navigation defaults; original state transitions and confirmations |
| Authentication and passcode | Native action styling only; password entry, submission guards and redaction unchanged |
| Calls | Native glass control surfaces, original red end-call button and camera/mic/audio-routing actions |
| Full-screen media | Dark system presentation; original zoom, swipe, player and close gestures |
| Profile-confirmation popup | UIKit glass container on iOS 26, original labels, profile data and callbacks |
| OS alerts, sharing, pickers, web/video bridges | System-owned controllers retain native behavior; no private API or content interception |
| Share extension | Same system policy and glass comment field; original passphrase, destination and send logic |

## Intentionally hidden navigation

- Chat-list, contact/group profile and server-summary roots have their own existing
  native headers. Adding another navigation bar would duplicate controls.
- Welcome, server-consent and network onboarding stages retain their full-page
  flow and controlled progression. Their actions now use system styling.
- The hidden bar in ContactConnectionInfo and SunderSystemDetailNavigation is an
  older-OS fallback. iOS 26 uses native navigation there.
- Search may hide a title bar while the native search field is active.
- Media/call/security canvases retain their specialized layouts; they are not
  converted into settings forms and their content is not covered with glass.

## Validation limits

Source checks cover registration, availability guards, scope propagation, privacy
redaction, sheet routing, action/state preservation and inventory freshness.
Compilation and on-device UI validation must be recorded separately. A successful
build cannot establish visual correctness of every destination, Dynamic Type size,
iPad layout, accessibility setting or rapid presentation/dismissal sequence.
