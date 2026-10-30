# SimpleX Chat iOS -- Navigation Architecture

> Technical specification for the navigation stack, deep linking, sheet presentation, and call overlay.
>
> Related specs: [Chat List](chat-list.md) | [Chat View](chat-view.md) | [State Management](../state.md) | [README](../README.md)
> Related product: [Product Overview](../../product/README.md)

**Source:** [`ContentView.swift`](../../Shared/ContentView.swift) | [`NewChatView.swift`](../../Shared/Views/NewChat/NewChatView.swift) | [`SettingsView.swift`](../../Shared/Views/UserSettings/SettingsView.swift) | [`OnboardingView.swift`](../../Shared/Views/Onboarding/OnboardingView.swift) | [`UserProfilesView.swift`](../../Shared/Views/UserSettings/UserProfilesView.swift)

---

## Table of Contents

1. [Overview](#1-overview)
2. [Root View -- ContentView](#2-root-view)
3. [Navigation Stack](#3-navigation-stack)
4. [Sheet Presentation](#4-sheet-presentation)
5. [Deep Linking](#5-deep-linking)
6. [Call Overlay](#6-call-overlay)
7. [Authentication Gate](#7-authentication-gate)
8. [Onboarding Flow](#8-onboarding-flow)

---

## 1. Overview

The app's navigation follows a hierarchical model with a single navigation stack rooted in `ContentView`. Modal sheets and full-screen overlays augment the primary navigation path.

```
SimpleXApp
└── ContentView (root)
    ├── Authentication gate (LocalAuthView / SetAppPasscodeView)
    ├── Onboarding flow (if first launch / migration)
    ├── Main content
    │   └── NavigationStack / NavigationView
    │       ├── ChatListView (root of stack)
    │       │   ├── ChatView (pushed)
    │       │   │   ├── ChatInfoView / GroupChatInfoView (pushed)
    │       │   │   └── ChatItemInfoView (pushed)
    │       │   └── ContactConnectionInfo (pushed)
    │       └── Settings views (pushed)
    ├── Sheets (modal)
    │   ├── UserPicker
    │   ├── NewChatView
    │   ├── WhatsNew / Notices
    │   └── Settings sub-views
    └── Overlays (always on top)
        ├── Active call banner (when call active)
        └── ActiveCallView (full-screen call)
```

---

## 2. Root View -- [`ContentView`](../../Shared/ContentView.swift#L24)

**File**: [`Shared/ContentView.swift`](../../Shared/ContentView.swift)

`ContentView` is the root view injected by `SimpleXApp`. It manages:

### [Environment](../../Shared/ContentView.swift#L25-L37)
- `@EnvironmentObject var chatModel: ChatModel`
- `@EnvironmentObject var theme: AppTheme`
- `@Environment(\.scenePhase) var scenePhase`

### [Key State](../../Shared/ContentView.swift#L35-L52)
| Property | Type | Purpose |
|----------|------|---------|
| [`contentAccessAuthenticationExtended`](../../Shared/ContentView.swift#L35) | `Bool` | Passed at init to avoid re-render timing issues |
| [`automaticAuthenticationAttempted`](../../Shared/ContentView.swift#L38) | `Bool` | Whether biometric auth was auto-attempted |
| [`waitingForOrPassedAuth`](../../Shared/ContentView.swift#L51) | `Bool` | Whether auth gate should show |
| [`chatListUserPickerSheet`](../../Shared/ContentView.swift#L52) | `UserPickerSheet?` | Active user picker sheet |

### [View Selection Logic](../../Shared/ContentView.swift#L60-L80)

```swift
// Simplified decision tree in ContentView.body:
if !prefPerformLA || accessAuthenticated {
    contentView()   // Main app content
} else {
    lockButton()    // Authentication required
}
```

The [`contentView()`](../../Shared/ContentView.swift#L169) function further decides:
- If `chatModel.onboardingStage != .onboardingComplete`: show [onboarding](../../Shared/ContentView.swift#L174)
- If `chatModel.migrationState != nil`: show migration UI
- Otherwise: show `ChatListView` in a navigation container

---

## 3. Navigation Stack

### iOS Version Compatibility

**File**: [`Shared/Views/Helpers/NavStackCompat.swift`](../../Shared/Views/Helpers/NavStackCompat.swift)

The app supports iOS 15+ and uses a compatibility wrapper ([`NavStackCompat`](../../Shared/Views/Helpers/NavStackCompat.swift#L11)):

```swift
// NavStackCompat provides:
// - NavigationStack (iOS 16+): programmatic navigation via NavigationPath
// - NavigationView (iOS 15): classic NavigationLink-based navigation
```

### Primary Navigation Path

```
ChatListView
    │
    ├─[tap chat]─→ ChatView
    │                  │
    │                  ├─[tap info]─→ ChatInfoView (direct)
    │                  │              └─→ VerifyCodeView, etc.
    │                  │
    │                  ├─[tap info]─→ GroupChatInfoView (group)
    │                  │              ├─→ GroupMemberInfoView
    │                  │              ├─→ GroupProfileView
    │                  │              └─→ GroupLinkView
    │                  │
    │                  └─[tap message info]─→ ChatItemInfoView
    │
    ├─[tap connection]─→ ContactConnectionInfo
    │
    └─[settings]─→ SettingsView
                       ├─→ NotificationsView
                       ├─→ NetworkAndServers
                       ├─→ AppearanceSettings
                       ├─→ PrivacySettings
                       ├─→ DatabaseView
                       └─→ UserProfilesView
```

### Navigation Trigger

Chat navigation is triggered by setting `ChatModel.chatId`:

```swift
// In ChatListNavLink:
ItemsModel.shared.loadOpenChat(chatId) {
    // This sets ChatModel.chatId = chatId after a 250ms delay
    // allowing navigation animation to start smoothly
}
```

---

## 4. Sheet Presentation

Sheets are presented modally on top of the navigation stack:

| Sheet | Trigger | Content |
|-------|---------|---------|
| UserPicker | Tap user avatar in nav bar | User list, settings shortcuts |
| [`NewChatView`](../../Shared/Views/NewChat/NewChatView.swift#L79) | Tap FAB / "+" button | Create link, scan QR, paste link, new group |
| WhatsNew | App update detected | Release notes |
| AddGroupView | "New Group" action | Group creation wizard |
| ConnectDesktopView | Settings > Desktop | Remote desktop pairing |
| MigrateFromDevice | Settings > Migration | Device export |
| MigrateToDevice | Onboarding migration | Device import |
| [LocalAuthView](../../Shared/ContentView.swift#L95) | App foreground after background | Biometric/passcode auth |

### Sheet Management

Sheets use SwiftUI `.sheet(item:)` or `.sheet(isPresented:)` modifiers on `ContentView` and `ChatListView`. Some sheets use the centralized [`AppSheetState.shared`](../../Shared/ContentView.swift#L29) observable for coordination:

```swift
class AppSheetState: ObservableObject {
    static let shared = AppSheetState()
    var scenePhaseActive: Bool = false
    // ... sheet state coordination
}
```

---

## 5. Deep Linking

### Notification Deep Link

When the user taps a notification:

1. `NtfManager.processNotificationResponse()` extracts the `chatId` from notification payload
2. If a different user: calls `changeActiveUser(userId:)`
3. Sets `ChatModel.chatId = chatId` to navigate to the conversation
4. If the app was in background: the notification response is stored in `ChatModel.notificationResponse` and processed when the app becomes active

### [URL Deep Link](../../Shared/ContentView.swift#L281)

SimpleX links (`simplex:/chat#...`) are handled via [`connectViaUrl()`](../../Shared/ContentView.swift#L439):

```swift
.onOpenURL { url in
    if AppChatState.shared.value == .active {
        chatModel.appOpenUrl = url      // Process immediately
    } else {
        chatModel.appOpenUrlLater = url // Process when active
    }
}
```

URL processing routes to the appropriate connection flow (join group, add contact, etc.) via [`planAndConnect()`](../../Shared/Views/NewChat/NewChatView.swift#L1301).

### Call Deep Link

Call invitations from notifications:
1. `NtfManager` detects `ntfActionAcceptCall` action
2. Sets `ChatModel.ntfCallInvitationAction = (chatId, .accept)`
3. `ContentView` picks up the pending action and initiates the call

---

## 6. Call Overlay

The call UI overlays the entire app when a call is active:

### [Call Banner](../../Shared/ContentView.swift#L203)

When `ChatModel.activeCall != nil` and call is in connecting/active state:
- A banner appears at the top of ContentView (height: [`callTopPadding = 40`](../../Shared/ContentView.swift#L54))
- Shows contact name, call duration, tap to return to full-screen call
- Main content is padded down to accommodate the banner

### [Full-Screen Call View](../../Shared/ContentView.swift#L185)

When `ChatModel.showCallView == true`:
- `ActiveCallView` covers the entire screen as a ZStack overlay
- Contains local/remote video, controls (mute, camera, speaker, end)
- PiP mode: `ChatModel.activeCallViewIsCollapsed` collapses to mini view
- Call view is always rendered on top of navigation and sheets

```swift
// In ContentView.allViews():
ZStack {
    contentView()
        .padding(.top, showCallArea ? callTopPadding : 0)

    if showCallArea, let call = chatModel.activeCall {
        VStack {
            activeCallInteractiveArea(call)
            Spacer()
        }
    }

    if chatModel.showCallView, let call = chatModel.activeCall {
        callView(call)  // Full screen overlay
    }
}
```

---

## 7. Authentication Gate

### [Local Authentication](../../Shared/ContentView.swift#L359)

When [`DEFAULT_PERFORM_LA`](../../Shared/ContentView.swift#L44) is enabled:

1. App enters background: `chatModel.contentViewAccessAuthenticated = false`
2. App returns to foreground: `ContentView` shows [`lockButton()`](../../Shared/ContentView.swift#L238) instead of content
3. User taps lock button: [`LocalAuthView`](../../Shared/ContentView.swift#L95) presented
4. On successful auth: `chatModel.contentViewAccessAuthenticated = true`, content revealed

### Authentication Methods
- Face ID / Touch ID (via `LocalAuthentication` framework)
- Custom numeric passcode
- Custom alphanumeric passcode

### [Extended Authentication](../../Shared/ContentView.swift#L351)
- After successful auth, a grace period prevents re-auth for brief background/foreground cycles ([`unlockedRecently()`](../../Shared/ContentView.swift#L351))
- [`contentAccessAuthenticationExtended`](../../Shared/ContentView.swift#L35) is computed at `ContentView.init` to avoid render-time race conditions
- The `enteredBackgroundAuthenticated` timestamp tracks when the app was last authenticated in background

---

## 8. [Onboarding Flow](../../Shared/Views/Onboarding/OnboardingView.swift#L13)

First-launch experience controlled by [`ChatModel.onboardingStage`](../../Shared/Views/Onboarding/OnboardingView.swift#L46):

```swift
enum OnboardingStage: String, Identifiable {
    case step1_SimpleXInfo              // Welcome screen
    case step2_CreateProfile            // deprecated
    case step3_CreateSimpleXAddress     // deprecated
    case step3_ChooseServerOperators    // Choose server operators
    case step4_SetNotificationsMode     // Set notification preferences
    case onboardingComplete             // Normal operation
}
```

Each stage is a dedicated view presented in place of `ChatListView` within [`ContentView`](../../Shared/ContentView.swift#L174).

Migration state (`ChatModel.migrationState != nil`) takes precedence over onboarding.

---

## 9. Channel Creation Flow (`AddChannelView`)

**Source:** [`Shared/Views/NewChat/AddChannelView.swift`](../../Shared/Views/NewChat/AddChannelView.swift)

### Entry Point

`NewChatMenuButton` includes a NavigationLink "Create public channel" with antenna icon, navigating to `AddChannelView`.

### Three-Step Wizard

| Step | Function | Description |
|------|----------|-------------|
| 1. Profile | `profileStepView()` | Channel name input (`channelNameTextField()`), profile image picker. "Configure relays" link to `NetworkAndServers`. Validates via `canCreateProfile()` (non-empty + valid display name) and `checkHasRelays()`. |
| 2. Progress | `progressStepView(_:)` | Relay connection progress with `RelayProgressIndicator` (circular active/total or spinner). Expandable relay list with `relayStatusIndicator(_:)` (green/red/orange dots). Cancel via `cancelChannelCreation(_:)` which calls `apiDeleteChat`. |
| 3. Link | `linkStepView(_:)` | Wraps `GroupLinkView(isChannel: true)` for channel link sharing. |

### Key Functions

| Function | Scope | Description |
|----------|-------|-------------|
| `createChannel()` | private | Calls `apiNewPublicGroup(incognito:relayIds:groupProfile:)`, sets `ChannelRelaysModel` |
| `getEnabledRelays()` | private | Filters enabled/non-deleted relays, selects random 3 |
| `checkHasRelays()` | private | Validates at least one relay exists |
| `relayDisplayName(_:)` | module | name > domain > link host > fallback |
| `relayStatusIndicator(_:)` | module | Green/red/orange dot + status text |
| `RelayProgressIndicator` | module | Circular progress (active/total) or spinner |

## 10. Relay URL Interception

**Source:** [`Shared/ContentView.swift`](../../Shared/ContentView.swift#L454)

In `connectViaUrl_()`, relay address links (URL path `/r`) are intercepted before processing:

```swift
if path == "/r" {
    showAlert(NSLocalizedString("Relay address", ...),
              message: NSLocalizedString("This is a chat relay address, it cannot be used to connect.", ...))
    return
}
```

Similarly, in `planAndConnect()` (`NewChatView.swift`), `.simplexLink(_, .relay, _, _)` patterns trigger the same alert and block connection.

## 11. Channel-Specific NewChatView Behavior

**Source:** [`Shared/Views/NewChat/NewChatView.swift`](../../Shared/Views/NewChat/NewChatView.swift)

### Prepared Group Alert (`showPrepareGroupAlert`)

When `groupShortLinkInfo?.direct == false` (channel relay link), the prepare alert uses:
- Channel icon: `antenna.radiowaves.left.and.right.circle.fill`
- Title: "Open new channel"
- Error: "Error opening channel"
- `apiPrepareGroup` call passes `directLink: false`
- Stores `groupShortLinkInfo.groupRelays` in `ChatModel.shared.channelRelayHostnames`

### Own Link Confirmation (`showOwnGroupLinkConfirmConnectSheet`)

For channels: shows "This is your link for channel" with only "Open channel" + "Cancel" buttons. No incognito or profile selection options.

### Known Group Alert (`showOpenKnownGroupAlert`)

For channels (`groupInfo.useRelays`): titles become "Open channel" / "Open new channel".

---

## Source Files

| File | Path |
|------|------|
| Root view | [`Shared/ContentView.swift`](../../Shared/ContentView.swift) |
| App entry point | `Shared/SimpleXApp.swift` |
| Navigation compat | [`Shared/Views/Helpers/NavStackCompat.swift`](../../Shared/Views/Helpers/NavStackCompat.swift) |
| Chat list (nav root) | `Shared/Views/ChatList/ChatListView.swift` |
| Nav link wrapper | `Shared/Views/ChatList/ChatListNavLink.swift` |
| User picker | `Shared/Views/ChatList/UserPicker.swift` |
| New chat view | [`Shared/Views/NewChat/NewChatView.swift`](../../Shared/Views/NewChat/NewChatView.swift) |
| Channel creation | [`Shared/Views/NewChat/AddChannelView.swift`](../../Shared/Views/NewChat/AddChannelView.swift) |
| New chat menu | [`Shared/Views/NewChat/NewChatMenuButton.swift`](../../Shared/Views/NewChat/NewChatMenuButton.swift) |
| Settings view | [`Shared/Views/UserSettings/SettingsView.swift`](../../Shared/Views/UserSettings/SettingsView.swift) |
| User profiles | [`Shared/Views/UserSettings/UserProfilesView.swift`](../../Shared/Views/UserSettings/UserProfilesView.swift) |
| Onboarding view | [`Shared/Views/Onboarding/OnboardingView.swift`](../../Shared/Views/Onboarding/OnboardingView.swift) |
| Active call view | `Shared/Views/Call/ActiveCallView.swift` |
| Local auth view | `Shared/Views/LocalAuth/LocalAuthView.swift` |
| Notification manager | `Shared/Model/NtfManager.swift` |

## Sunder presentation preparation — 2026-10-28

This scoped change does not replace navigation or add/remove chat operations. The 17
`SIMPLEX_ASSETS` conditions are resolved to their existing fallback branches (or removed
where they contained decorative-only content). No new function is introduced.
`SimpleXInfo.body` uses Sunder text and independent network attribution. `SettingsView.settingsView()`
omits the upstream investment section; `helpAndSupportView` uses existing settings rows
and ExternalLink for private fork source/issues, AGPL, notices and original `conditionsURL`.
Those development links are not an immutable public release-source manifest.

Sources (internal names preserved):
- [`Onboarding/SimpleXInfo.swift`](../../Shared/Views/Onboarding/SimpleXInfo.swift)
- [`Onboarding/YourNetwork.swift`](../../Shared/Views/Onboarding/YourNetwork.swift)
- [`Onboarding/CreateProfile.swift`](../../Shared/Views/Onboarding/CreateProfile.swift)
- [`Onboarding/ChooseServerOperators.swift`](../../Shared/Views/Onboarding/ChooseServerOperators.swift)
- [`Onboarding/WhatsNewView.swift`](../../Shared/Views/Onboarding/WhatsNewView.swift)
- [`Onboarding/ConnectBannerCard.swift`](../../Shared/Views/Onboarding/ConnectBannerCard.swift)
- [`NewChat/NewChatView.swift`](../../Shared/Views/NewChat/NewChatView.swift)
- [`NewChat/OnboardingCards.swift`](../../Shared/Views/NewChat/OnboardingCards.swift)
- [`NewChat/AddGroupView.swift`](../../Shared/Views/NewChat/AddGroupView.swift)
- [`NewChat/AddChannelView.swift`](../../Shared/Views/NewChat/AddChannelView.swift)
- [`UserSettings/UserAddressView.swift`](../../Shared/Views/UserSettings/UserAddressView.swift)
- [`UserSettings/SettingsView.swift`](../../Shared/Views/UserSettings/SettingsView.swift)

iOS CFBundleDisplayName is Sunder, including localized overrides. Bundle IDs, App Groups,
signing, database, networking and operator acceptance handlers are unchanged.
`scripts/ios/copy-assets.sh` retains its Xcode build-phase entry point as a no-import helper.
Products: [onboarding](../../product/views/onboarding.md), [new chat](../../product/views/new-chat.md),
[settings](../../product/views/settings.md), [group information](../../product/views/group-info.md).

## Sunder temporary logo removal — 2026-10-28

[`QRCode.body`](../../Shared/Views/NewChat/QRCode.swift) no longer covers QR modules with
an Image/background overlay. GeometryReader sizing, generation, screenshots and share
callbacks are retained. The withLogo compatibility parameter has no rendering effect.
[`ChooseServerOperators`](../../Shared/Views/Onboarding/ChooseServerOperators.swift),
[`YourNetwork`](../../Shared/Views/Onboarding/YourNetwork.swift),
[`NetworkAndServers`](../../Shared/Views/UserSettings/NetworkAndServers/NetworkAndServers.swift)
and [`OperatorView`](../../Shared/Views/UserSettings/NetworkAndServers/OperatorView.swift)
replace logo rendering with native network symbols/provider text. Selection/acceptance
handlers remain unchanged. [`NewOperatorsView`](../../Shared/Views/Onboarding/WhatsNewView.swift)
uses Flux text rather than artwork. Provider/model metadata names remain compatible.

Required AppIcon/DarkAppIcon and appearance-preview PNG slots retain exact dimensions
as plain opaque color fields. Unused logo, Flux, watermark and CallKit image sets are removed.
No changes to bundle IDs, App Groups, entitlements or launch behavior are intended.
See product views: [new chat](../../product/views/new-chat.md),
[settings](../../product/views/settings.md), [onboarding](../../product/views/onboarding.md).

## Sunder offline notices — 2026-10-28

[`SettingsView.legalNoticesView`](../../Shared/Views/UserSettings/SettingsView.swift#L475) is a
standard NavigationLink destination from Help & support. [`legalNoticeSections`](../../Shared/Views/UserSettings/SettingsView.swift#L310) caches
the parsed text for the settings view lifetime. The destination's task resolves the main
bundle resource URL, reads UTF-8 in a utility detached task, splits form-feed sections and
publishes state only if the view task was not cancelled. Missing/invalid resources produce
a plain-text packaging error. A LazyVStack presents selectable `Text(verbatim:)` sections,
avoiding Markdown, HTML or automatic remote execution. No new custom navigation system.

`Shared/SunderNotices.txt` is explicitly wired into the main app Resources phase and is
generated by scripts/ios/generate-sunder-notices.py. NOTICES_INPUTS.json records LF-normalized
input/output hashes. No notice is claimed to establish a complete binary dependency closure.
The two earlier external legal rows are replaced by this offline destination; private
source/issues and original operator conditions remain unchanged.

Product: [settings](../../product/views/settings.md).

## Sunder publication preparation — 2026-10-28

`sunderRepositoryURL` validates the HTTPS URL from Info.plist, falling back to the private
development repository; `sunderIssuesURL` derives its issues destination. Settings, Developer,
OldHowItWorks and migration-failure reporting use these values. Edit SunderRepositoryURL
and regenerate notices when the final public repository exists. Operator conditions,
upstream component commit attribution and protocol links are not renamed.

WhatsNew drops investment features/views and crowdfunding post links, while retaining
ordinary upstream feature history. ChatListView drops investment state, banners, callbacks
and sheet; shared BannerCard/BannerDismissButton remain for other cards.
No database/network/identity or operator-acceptance flow changes.

`sunderSourceURL` derives the configured SunderSourceRef under the repository's tree
route (default main; development value codex/private-preparation). This keeps source
navigation on the actual development branch rather than the original default branch.
The issue destination remains rooted at the repository. The final binary must name its
corresponding immutable source ref. Visible extension and permission captions use Sunder;
original copyright strings, bundle IDs, entitlements and signing remain unchanged.

### Native system design compatibility (2026-10-29)
The application Info.plist sets `UIDesignRequiresCompatibility` to false. The OS
can render its current system chrome. This is an app-wide UIKit prerequisite;
no other screen's layout or navigation route is rewritten by the chat-list change.

### Application-wide system presentation (2026-10-30)
See [system-interface.md](system-interface.md) for app/theme/sheet scope, native
avatar-sheet dismissal ordering, contextual controls and member/connection
navigation. Both appSheet overloads retain PrivacySensitive redaction.

## Native control correction (2026-10-30)
See [adoption and validation limits](../../../../docs/fork/ios/SYSTEM_UI_ADOPTION.md#maintainer-design-constraint-and-control-correction-2026-10-30).
UIKit UISearchBar preserves text/focus/progress/link and cancellation bindings.
Circular UIKit glass toolbar controls own their backgrounds on iOS 26; stock
SwiftUI toolbar shared backgrounds are suppressed only for those controls.
Neutral settings/compose foregrounds do not replace semantic action colors.
Conversation uses automatic system navigation background and extends under its
top safe area; virtualized scrolling and message/voice handlers are unchanged.
