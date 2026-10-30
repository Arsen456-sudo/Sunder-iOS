# Chat List (Home Screen)

> **Related spec:** [spec/client/chat-list.md](../../spec/client/chat-list.md)

## Purpose

Main screen of the SimpleX Chat app. Displays all conversations sorted by last activity, serves as the navigation root, and provides access to user profiles, settings, and new chat creation.

## Route / Navigation

- **Entry point**: App launch (root view), or back-navigation from any chat
- **Presented by**: `ContentView` as the default view when `chatModel.chatId == nil`
- **Navigation stack**: `NavStackCompat` wrapping `chatListView` with destination `chatView`
- **UserPicker sheet**: Triggered by tapping the user avatar in the toolbar; presents `UserPicker` as a custom sheet, which links to `UserPickerSheetView` sub-sheets (address, preferences, profiles, current profile, use from desktop, settings)

## Page Sections

### Toolbar

| Element | Location | Behavior |
|---|---|---|
| User avatar button | Leading | Opens `UserPicker` sheet (profile switcher, address, settings, preferences, connect to desktop) |
| Connection status indicator | Center (native status button) | Shows server subscription status; taps navigate to `ServersSummaryView` |
| New chat button (pencil icon) | Trailing | Opens `NewChatSheet` modal |

The toolbar supports two layout modes:
- **Standard (top)**: Three floating UIKit glass islands in the root list top safe area: circular avatar, plain tappable Chats/status text and circular compose action. Existing avatar, localized Chats/status control and new-chat actions are retained. Search hides this bar; pushed screens own their navigation bars.
- **One-hand UI (bottom)**: Floating avatar and compose buttons share a native glass container, with plain tappable Chats/status text between them, inset 10 points from the screen edges. Only the list is vertically flipped; controls remain upright. iOS 26 uses interactive system Liquid Glass. Older versions use system materials; Reduce Transparency uses opaque accessible surfaces.

### Search Bar

- Native UIKit search bar with magnifying glass, clear and cancel controls; a separate native unread-filter button
- When active, `searchMode = true` hides the navigation bar and shows inline search
- Filters chat list in real-time by contact/group name and message content
- Detects pasted SimpleX links (`searchShowingSimplexLink`) and offers to connect

### Chat Filter Tabs (Tags)

Managed by `ChatTagsModel` and `TagListView`:

| Filter | PresetTag | Description |
|---|---|---|
| All | (none) | No filter, shows all chats |
| Unread | `.unread` | Chats with unread messages |
| Favorites | `.favorites` | User-favorited chats |
| Groups | `.groups` | Group conversations only |
| Contacts | `.contacts` | Direct contacts only |
| Business | `.business` | Business chat conversations |
| Notes | `.notes` | Notes to self |
| Group Reports | `.groupReports` | Moderation reports (non-collapsible) |
| Custom tags | `.userTag(ChatTag)` | User-created tags with custom names |

### Chat Preview Rows

Each row rendered by `ChatPreviewView` inside `ChatListNavLink`:

| Element | Description |
|---|---|
| Avatar | Profile image or colored initials circle; online status indicator for contacts |
| Chat name | Display name (contact, group, or note-to-self) |
| Last message preview | Truncated text of most recent message; supports markdown rendering |
| Timestamp | Relative time of last activity (e.g., "2m", "1h", "Yesterday") |
| Unread badge | Numeric count badge for unread messages; distinct styling for mentions |
| Muted indicator | Bell-slash icon when notifications are muted |
| Pinned indicator | Pin icon for pinned chats |
| Incognito indicator | Shows when connected via incognito profile |
| Connection status | Shows connecting/pending state for incomplete connections |

### Channel Adaptations

When a group has `groupInfo.useRelays == true` (channel):

| Element | Channel behavior |
|---|---|
| Chat icon | Antenna icon (`antenna.radiowaves.left.and.right.circle.fill`) instead of group icon |
| Swipe "Leave" | Hidden for channel owners (`useRelays && isOwner`) |
| Context menu "Leave" | Hidden for channel owners |
| Delete alert | "Delete channel?" (not "Delete group?") |
| Leave alert title | "Leave channel?" (not "Leave group?") |
| Leave alert message | "You will stop receiving messages from this channel. Chat history will be preserved." |

### Relay URL Handling

When a relay address link (`/r` path) is opened via URL deep link, `ContentView.connectViaUrl_()` intercepts it and shows an alert: "Relay address" / "This is a chat relay address, it cannot be used to connect." The link is not processed further.

### Swipe Actions

- **Trailing swipe**: Mute/unmute, pin/unpin, tag management
- **Leading swipe**: Mark as read/unread
- **Context menu** (long press): Full set of actions including delete, clear chat, toggle favorite

### Floating Elements

- **One-hand UI card** (`OneHandUICard`): Dismissible card shown to introduce bottom toolbar mode
- **Address creation card** (`AddressCreationCard`): Prompts user to create a SimpleX address
- Sunder omits the upstream crowdfunding banner and investment sheet; functional onboarding cards remain.

### Pull-to-Refresh

Triggers `reconnectAllServers()` after user confirmation alert ("Reconnect servers?"). Uses additional traffic to force message delivery.

## Loading / Error States

| State | Behavior |
|---|---|
| Chat database not started | Settings row shows exclamation icon; chat running == false disables interactions |
| No conversations yet | `ConnectOnboardingView` pages replace the list |
| Connection in progress | `ConnectProgressManager` overlay with connecting text |
| Search with no results | Empty list with no special empty-state view |

## Related Specs

- `spec/client/chat-list.md` -- Chat list feature specification
- `spec/state.md` -- Application state management
- [User Profiles](user-profiles.md) -- Profile switching from UserPicker
- [Settings](settings.md) -- Settings accessed via UserPicker
- [New Chat](new-chat.md) -- New chat sheet triggered from toolbar
- [Chat](chat.md) -- Navigated to when tapping a chat row

## Source Files

- `Shared/Views/ChatList/ChatListView.swift` -- Main view, toolbar, search, filter logic
- `Shared/Views/ChatList/ChatPreviewView.swift` -- Individual chat row rendering
- `Shared/Views/ChatList/ChatListNavLink.swift` -- Navigation link wrapper with swipe actions
- `Shared/Views/ChatList/TagListView.swift` -- Filter tab bar (preset + custom tags)
- `Shared/Views/ChatList/UserPicker.swift` -- User profile picker sheet
- `Shared/Views/ChatList/ChatHelp.swift` -- Empty-state help view
- `Shared/Views/ChatList/ContactRequestView.swift` -- Contact request row rendering
- `Shared/Views/ChatList/ContactConnectionView.swift` -- Pending connection row rendering
- `Shared/Views/ChatList/OneHandUICard.swift` -- One-hand UI introduction card
- `Shared/Views/ChatList/GetStakeBanner.swift` -- Shared banner card chrome; upstream promotion removed
- `Shared/Views/ChatList/ServersSummaryView.swift` -- Server subscription summary

## Sunder resource cleanup — 2026-10-28

The investment banner/sheet and country-gated promotion are removed. Search, onboarding, one-hand cards, chat ordering and ordinary list actions retain their behavior.

See [preparation scope](../../spec/client/navigation.md#sunder-publication-preparation--2026-10-28).

### Scoped UIKit redesign (2026-10-29)

Only the chat-list controls are redesigned. Chat rows, tags, onboarding, profile
switcher and modal content retain their existing SwiftUI implementation and actions.
The root list uses the system soft scroll-edge effect behind its controls on iOS 26;
the effect detaches when leaving this screen. No conversation or settings UI changes.

The app-level `UIDesignRequiresCompatibility` flag is false, enabling the OS's
current UI design. This prerequisite is global: system-owned bars, sheets and
controls elsewhere may also adopt the current appearance, although only the
chat-list layout is redesigned. Explicit glass stays availability-guarded.

### Compact controls and server information (2026-10-29)
The avatar/compose circles are 44 points at the default text size, with a 28-point
avatar. Chats has no material or outline and remains tappable over the system
scroll-edge effect. Header height remains Dynamic Type-aware.

Tapping Chats opens Servers info with the same compact glass close/share buttons
and plain centered title. Native profile and Messages/Files segmented selectors
remain above the grouped scrolling statistics. Sharing stays disabled until data
is available. Reconnect/reset confirmations, percentage setting, server details
and all statistics are preserved. Detail pages keep system back navigation.

### Shared native glass controls (2026-10-30)
Folder filters (preset, custom, collapsed menu and Add list) now use individual
system-glass surfaces while retaining all tap/long-press routes. Main header action
symbols use adaptive label color: white in dark appearance, dark in light appearance.
The avatar menu has rounded glass profile cards and one grouped glass action panel;
its account switching, hidden-profile rules and theme gestures remain unchanged.
Servers info uses a black background and dark appearance. Its profile and Messages /
Files selectors use actual UIKit glass with equally sized buttons and a separate
active capsule. Statistics, sharing, confirmations and detail routes are unchanged.

### Native presentation boundaries (2026-10-30)
The avatar menu uses the iOS 26 system sheet with a grabber and scrollable content;
accessibility sizes start at the large detent. Selecting a menu destination closes
this sheet first, then opens the original destination. Account switching and hidden
profile behavior are retained. New-chat/contacts/deleted-chat search uses the same
native field/filter controls as the main list, with existing resolution logic.
