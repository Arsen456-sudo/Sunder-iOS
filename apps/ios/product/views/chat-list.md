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
- **Standard (top)**: Native navigation-bar toolbar items for the avatar, tappable Chats/status and compose action. Existing avatar, localized Chats/status control and new-chat actions are retained. Search hides this bar; pushed screens own their navigation bars.
- **One-hand UI (bottom)**: Native bottom-toolbar items for avatar, status and compose. The existing one-hand list inversion is retained; the toolbar stays upright. The OS owns material, spacing and accessibility behavior.

### Search Bar

- Standard TextField with clear/cancel Buttons and a standard unread-filter Button
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

### Standard Apple components (2026-10-30)
The avatar menu uses NavigationView, List, Section, Label and Button just like
AppearanceSettings. It has one scrolling List, a system large title and Done
button. Profile rows, account switching, badge/unread display, disabled states
and original settings destinations are preserved. Appearance mode is chosen via
a standard Menu with System/Light/Dark options. Native presentation is large and
has no extra ScrollView wrapping the List; destinations open after dismissal.

Main-list controls use standard toolbar items in the top or reachable bottom
placement. Chats remains a tappable status button opening server information;
status polling is cancellable. Folder filters use standard bordered Buttons and
Menu, and native Edit context menus retain the tag-management destination.
Servers info uses a native large title, Done/share toolbar items and standard
Picker rows in a Section. Its black appearance and statistics are retained.

### Native geometry correction (2026-10-30)
Main controls use fixed-size circular UIKit glass buttons, a circular avatar and a shared native UISearchBar. UIKit owns search/cancel metrics; link handling, filters, unread state and account routes remain unchanged.

## Native main navigation and folders (2026-10-30)

The main area uses a UIKit tab controller: Chats, Settings and Your profile are
independent persistent roots. A native search action at the trailing end selects
Chats and opens the top search field; Close clears/hides it. Top Edit opens folder
management, while compose and unread retain their actions. Search is above the
pinned folder control, not a scrolling row. Only user-created folders are shown;
computed type categories no longer appear automatically. One UISegmentedControl
contains All and the folder names. Ordinary chat rows are smaller; accessibility
metrics remain at the original sizes. Tabs hide while a conversation is open.

## Native navigation integration follow-up (2026-10-30)

Folder editors expose a destructive Delete action with confirmation; removing a
folder keeps its chats/messages. The pinned system segment is 40 points high,
with 4-point vertical spacing. Its UIKit scroll-edge interaction references the
owning vertical list, so the native soft edge includes the folder container.
Search is integrated in UINavigationItem via UISearchController on iOS 26, with
native Close and stable toolbar identifiers; older OS versions retain a field.
Native SF Symbol toolbar items replace manually resized compose/filter images.

## Three-island navigation correction (2026-10-31)

The leading action now uses the existing localized Change text (Ukrainian:
Zminyty). Unread and compose are separated by a native fixed ToolbarSpacer, so they
are separate glass groups. Stable UIKit leading/context/avatar identifiers retain
native push/pop matching with back, centered chat title and avatar respectively.

## Independent header and immediate tabs (2026-10-31)

The tab bar uses immediate native visibility updates at root navigation boundaries
and tab selection; it does not wait for a hide animation after the transition.
The existing Change/filter/compose controls and search behavior are unchanged.

## Native list corrections (2026-10-31)
Folders use a real system glass capsule behind the existing segmented control.
The list's bottom soft scroll-edge effect is explicitly bound to the native tab
bar. Search reserves its cancel control through UISearchController itself, rather
than competing with an unrelated trailing button; cancelling clears text, link and
connection progress through existing state handlers. UIKit controls its layout.
Ordinary list taps select the chat route immediately after clearing prior message
state, without the old 250ms navigation timeout. Messages load asynchronously;
other callback-based navigation entry points retain their existing semantics.
No navigation animation is disabled. Performance and visual acceptance on iPhone
are still required; removing a deliberate wait is not a measured 1-2 second gain.

## Shared tab bottom-edge registration (2026-10-31)
The native tab controller now registers the selected root's visible main vertical
scroll view for the bottom edge. Chats, Settings and Profile share this behavior
whenever the tab bar is visible, independently of search/folders. Hidden/deeper
routes clear registration; tab changes register the new selected content.
This replaces the ineffective search-owned bottom interaction. Device verification
must cover short/long lists, all three roots, switching tabs and returning from chat.
