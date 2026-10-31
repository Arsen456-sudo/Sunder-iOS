# SimpleX Chat iOS -- Chat List Module

> Technical specification for the conversation list, filtering, search, swipe actions, and user picker.
>
> Related specs: [Chat View](chat-view.md) | [Navigation](navigation.md) | [State Management](../state.md) | [README](../README.md)
> Related product: [Chat List View](../../product/views/chat-list.md)

**Source:** [`ChatListView.swift`](../../Shared/Views/ChatList/ChatListView.swift)

---

## Table of Contents

1. [Overview](#1-overview)
2. [ChatListView](#2-chatlistview)
3. [ChatPreviewView](#3-chatpreviewview)
4. [ChatListNavLink](#4-chatlistnavlink)
5. [Filtering & Tags](#5-filtering--tags)
6. [Search](#6-search)
7. [Swipe Actions](#7-swipe-actions)
8. [UserPicker](#8-userpicker)
9. [Floating Action Button](#9-floating-action-button)
10. [Shared banner chrome](#10-crowdfunding-banner)

---

## 1. Overview

The chat list is the main screen of the app, displaying all conversations for the current user. It provides:

- Conversation previews with unread badges
- Filter tabs (All, Unread, Favorites, Groups, Contacts, Business, user-defined tags)
- Search across chat names and message content
- Swipe actions for quick operations
- User profile switcher
- Floating action button for new conversations

```
ChatListView
├── Navigation Bar
│   ├── User avatar (tap → UserPicker)
│   └── Filter tabs (TagListView)
├── Search bar (on pull-down or tap)
├── Chat List (List/LazyVStack)
│   └── ChatListNavLink (per conversation)
│       └── ChatPreviewView
│           ├── Avatar
│           ├── Chat name + last message preview
│           ├── Timestamp
│           └── Unread badge
├── FAB (New Chat button)
└── Pending connection cards
```

---

## 2. [`ChatListView`](../../Shared/Views/ChatList/ChatListView.swift#L157) {#2-chatlistview}

**File**: `Shared/Views/ChatList/ChatListView.swift`

The root list view. Key responsibilities:

### Data Source
- Reads `ChatModel.shared.chats` (all conversations)
- Applies active filter from `ChatTagsModel.shared.activeFilter`
- Applies search query filtering via [`filteredChats()`](../../Shared/Views/ChatList/ChatListView.swift#L582)
- Sorts by last activity (most recent first), with pinned chats at top

### Layout
- Uses SwiftUI `List` with `ForEach` over filtered chats
- Each row is a `ChatListNavLink` wrapping a `ChatPreviewView`
- Pull-to-refresh confirms and invokes `reconnectAllServers()`
- Empty state: `ChatHelp` view with getting-started guidance

### Connection Cards
- Pending contact connections (`ChatInfo.contactConnection`) shown as cards
- Contact requests (`ChatInfo.contactRequest`) shown with accept/reject UI via `ContactRequestView`

### Key Functions

| Function | Line | Description |
|----------|------|-------------|
| [`body`](../../Shared/Views/ChatList/ChatListView.swift#L89) | See link | Main view body |
| [`filteredChats()`](../../Shared/Views/ChatList/ChatListView.swift#L582) | See link | Applies active filter and search to chat list |
| [`searchString()`](../../Shared/Views/ChatList/ChatListView.swift#L625) | See link | Normalizes search text for comparison |
| [`stopAudioPlayer()`](../../Shared/Views/ChatList/ChatListView.swift#L576) | See link | Stops any playing voice message |

---

## 3. [`ChatPreviewView`](../../Shared/Views/ChatList/ChatPreviewView.swift#L13) {#3-chatpreviewview}

**File**: `Shared/Views/ChatList/ChatPreviewView.swift`

Renders a single row in the chat list. Shows:

| Element | Source | Description |
|---------|--------|-------------|
| Avatar | `chatInfo.image` | Profile image or default icon |
| Chat name | `chatInfo.displayName` | Contact name, group name, or connection label |
| Last message | `chat.chatItems.last` | Preview text of most recent message |
| Timestamp | `chat.chatItems.last?.timestampText` | Relative time of last message |
| Unread badge | `chat.chatStats.unreadCount` | Circular badge with unread count |
| Mute icon | `chatInfo.chatSettings?.enableNtfs` | Bell-slash icon if notifications muted |
| Pin icon | -- | Pin indicator for pinned chats |
| Incognito icon | Contact.contactConnIncognito | Incognito mode indicator |
| Delivery status | Last sent item's `meta.itemStatus` | Check marks for delivery confirmation |

### Preview Text Rendering
- Text messages: first line of message content
- Images: camera icon + caption (if any)
- Files: paperclip icon + filename
- Voice: microphone icon + duration
- Calls: phone icon + call status
- Group events: system event description
- Encrypted/deleted: placeholder text

---

## 4. [`ChatListNavLink`](../../Shared/Views/ChatList/ChatListNavLink.swift#L44) {#4-chatlistnavlink}

**File**: `Shared/Views/ChatList/ChatListNavLink.swift`

Wraps `ChatPreviewView` in a navigation link with tap and swipe behavior:

### Tap Behavior
- Direct chat: navigates to `ChatView` via `ItemsModel.loadOpenChat(chatId)` -- [`contactNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L98) L93
- Group chat: navigates to `ChatView` -- [`groupNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L220) L214
- Contact request: shows `ContactRequestView` with accept/reject -- [`contactRequestNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L498) L486
- Contact connection: shows `ContactConnectionInfo` -- [`contactConnectionNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L533) L520
- Notes folder: navigates to `ChatView` -- [`noteFolderNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L305) L298

### Navigation
- Uses `NavigationLink` (iOS 15) or programmatic navigation (iOS 16+)
- Sets `ChatModel.chatId` to trigger navigation
- `ItemsModel.loadOpenChat()` loads messages with a 250ms navigation delay for smooth animation

### Channel Adaptations in ChatListNavLink

When `groupInfo.useRelays == true`:

| Change | Behavior |
|--------|----------|
| Swipe "Leave" | Hidden when `useRelays && isOwner` |
| Context menu "Leave" | Hidden under same condition |
| `deleteGroupAlert` label | "Delete channel?" |
| `leaveGroupAlert` title | "Leave channel?" |
| `leaveGroupAlert` message | "You will stop receiving messages from this channel. Chat history will be preserved." |

### ServerSettings

`ServerSettings` struct (defined in `ChatListView.swift`) includes `serverWarnings: [UserServersWarning]` field, initialized to `[]`. This field stores validation warnings from `validateServers` and is consumed by NetworkAndServers views.

---

## 5. Filtering & Tags

### Filter Tabs ([`TagListView`](../../Shared/Views/ChatList/TagListView.swift#L20))

**File**: `Shared/Views/ChatList/TagListView.swift`

Horizontal scrolling tab bar below the navigation bar. Tabs:

| Tab | Filter | Shows |
|-----|--------|-------|
| All | `nil` | All conversations |
| Unread | `.unread` | Conversations with unread messages |
| Favorites | `.presetTag(.favorites)` | Favorited conversations |
| Groups | `.presetTag(.groups)` | Group conversations |
| Contacts | `.presetTag(.contacts)` | Direct conversations |
| Business | `.presetTag(.business)` | Business conversations |
| Group Reports | `.presetTag(.groupReports)` | Groups with pending reports |
| User tags | `.userTag(ChatTag)` | User-defined custom tags |

Filter matching is handled by [`presetTagMatchesChat()`](../../Shared/Views/ChatList/ChatListView.swift#L1035) and the in-view [`TagsView`](../../Shared/Views/ChatList/ChatListView.swift#L850) struct.

### ChatTagsModel State

Filtering state is managed by [`ChatTagsModel`](../../Shared/Model/ChatModel.swift#L189) (`ChatModel.swift` L183):

```swift
class ChatTagsModel: ObservableObject {
    @Published var userTags: [ChatTag] = []
    @Published var activeFilter: ActiveFilter? = nil
    @Published var presetTags: [PresetTag: Int] = [:]   // count per preset tag
    @Published var unreadTags: [Int64: Int] = [:]        // unread count per user tag
}
```

- `presetTags` counts are updated whenever `chats` changes via [`updateChatTags()`](../../Shared/Model/ChatModel.swift#L197) (L197)
- Tags with zero matching chats are auto-hidden
- Active filter is auto-cleared when its tag has no matching chats

### Supporting Types

| Type | File | Line | Description |
|------|------|------|-------------|
| [`PresetTag`](../../Shared/Views/ChatList/ChatListView.swift#L38) | ChatListView.swift | 36 | Enum of built-in filter categories |
| [`ActiveFilter`](../../Shared/Views/ChatList/ChatListView.swift#L55) | ChatListView.swift | 53 | Enum wrapping preset, user-tag, or unread filter |
| [`setActiveFilter()`](../../Shared/Views/ChatList/ChatListView.swift#L1016) | ChatListView.swift | 1113 | Applies a filter and persists selection |

### Tag Management Commands
- `apiCreateChatTag(tag: ChatTagData)` -- create tag
- `apiSetChatTags(type:, id:, tagIds:)` -- assign tags to a chat
- `apiDeleteChatTag(tagId:)` -- delete tag
- `apiUpdateChatTag(tagId:, tagData:)` -- rename tag
- `apiReorderChatTags(tagIds:)` -- reorder tags

---

## 6. Search

Search is available via pull-down gesture or search button in the navigation bar.

**Search bar UI:** [`ChatListSearchBar`](../../Shared/Views/ChatList/ChatListView.swift#L631)

### Filtering Logic
- Filters `ChatModel.chats` by matching search text against:
  - `chatInfo.displayName` (contact/group name)
  - `chatInfo.localAlias` (local alias)
  - `chatInfo.fullName` (full name)
- For deeper message content search, uses `apiGetChat(chatId:, search:)` parameter
- Core logic in [`filteredChats()`](../../Shared/Views/ChatList/ChatListView.swift#L582) and [`searchString()`](../../Shared/Views/ChatList/ChatListView.swift#L625)

### Search Results
- Matching chats are displayed in the same list format
- Results update as the user types (debounced)
- Clearing search restores the full filtered list

---

## 7. Swipe Actions

`ChatListNavLink` provides swipe actions on each row:

### Leading Swipe (left-to-right)

| Action | Icon | Handler | Line | API | Condition |
|--------|------|---------|------|-----|-----------|
| Pin / Unpin | pin | [`toggleFavoriteButton()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L356) | 347 | `apiSetChatSettings` (favorite) | Always |
| Read / Unread | envelope | [`markReadButton()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L336) | 328 | `apiChatRead` / `apiChatUnread` | Always |

### Trailing Swipe (right-to-left)

| Action | Icon | Handler | Line | API | Condition |
|--------|------|---------|------|-----|-----------|
| Mute / Unmute | bell.slash | [`toggleNtfsButton()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L375) | 365 | `apiSetChatSettings` (enableNtfs) | Always |
| Clear | trash | [`clearChatButton()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L396) | 385 | `apiClearChat` | Has messages |
| Delete | trash.fill | -- | -- | `apiDeleteChat` | Not active chat |
| Tag | tag | -- | -- | `apiSetChatTags` | Always |

---

## 8. [`UserPicker`](../../Shared/Views/ChatList/UserPicker.swift#L10) {#8-userpicker}

**File**: `Shared/Views/ChatList/UserPicker.swift`

Triggered by tapping the user avatar in the navigation bar. Presented as a sheet with:

| Section | Contents |
|---------|----------|
| User list | All non-hidden users with unread counts |
| Active user | Highlighted with checkmark |
| Actions | Settings, Your SimpleX address, User profiles |

### User Switching
- Tapping a different user calls `apiSetActiveUser(userId:)`
- Triggers `apiGetChats` for the new user
- `ChatModel.currentUser` updates, causing full UI refresh
- Hidden users are not shown (require password entry via settings)

---

## 9. Floating Action Button

The FAB (floating action button) in the bottom-right corner opens the new chat flow:

- Tap: opens `NewChatView` sheet for creating a new contact connection or group
- Shows options: Create link, Scan QR code, Paste link, Create group

---

## 10. Shared banner chrome {#10-crowdfunding-banner}

Sunder removes the upstream investment banner, its sheet, state and country gate.
No chat/onboarding crowdfunding placement remains. Original persisted hint keys may
remain in defaults for compatibility but do not restore a promotion.

[`BannerCard`](../../Shared/Views/ChatList/GetStakeBanner.swift) and `BannerDismissButton`
remain for functional onboarding/one-hand cards: scaled minimum height, gradient,
padding, rounding and dismissal behavior are retained. No replacement donation is added.

---

## Source Files

| File | Path | Key struct | Line |
|------|------|------------|------|
| Chat list view | [`ChatListView.swift`](../../Shared/Views/ChatList/ChatListView.swift) | `ChatListView` | [154](../../Shared/Views/ChatList/ChatListView.swift#L157) |
| Chat preview row | [`ChatPreviewView.swift`](../../Shared/Views/ChatList/ChatPreviewView.swift) | `ChatPreviewView` | [12](../../Shared/Views/ChatList/ChatPreviewView.swift#L13) |
| Navigation link wrapper | [`ChatListNavLink.swift`](../../Shared/Views/ChatList/ChatListNavLink.swift) | `ChatListNavLink` | [43](../../Shared/Views/ChatList/ChatListNavLink.swift#L44) |
| Tag filter tabs | [`TagListView.swift`](../../Shared/Views/ChatList/TagListView.swift) | `TagListView` | [19](../../Shared/Views/ChatList/TagListView.swift#L20) |
| User picker sheet | [`UserPicker.swift`](../../Shared/Views/ChatList/UserPicker.swift) | `UserPicker` | [9](../../Shared/Views/ChatList/UserPicker.swift#L10) |
| Getting started help | [`ChatHelp.swift`](../../Shared/Views/ChatList/ChatHelp.swift) | | |
| Contact request view | [`ContactRequestView.swift`](../../Shared/Views/ChatList/ContactRequestView.swift) | | |
| Contact connection info | [`ContactConnectionInfo.swift`](../../Shared/Views/ChatList/ContactConnectionInfo.swift) | | |
| Contact connection view | [`ContactConnectionView.swift`](../../Shared/Views/ChatList/ContactConnectionView.swift) | | |
| Server summary | [`ServersSummaryView.swift`](../../Shared/Views/ChatList/ServersSummaryView.swift) | | |
| One-hand UI card | [`OneHandUICard.swift`](../../Shared/Views/ChatList/OneHandUICard.swift) | | |
| Shared card chrome | [`GetStakeBanner.swift`](../../Shared/Views/ChatList/GetStakeBanner.swift) | `BannerCard`, `BannerDismissButton` | |

## 11. Standard Apple component implementation

The reference is AppearanceSettings, using NavigationView, List, Section, Picker,
Toggle, Button and toolbar. ChatListView.withToolbar now uses ToolbarItem/Group in
the requested top/bottom placement; it no longer embeds a custom UINavigationBar
or glass controller. ChatListStatusButton preserves subscription info/percentage
and uses a cancellable task scoped to the current profile. The scroll probe and
manual glass-capture/binding layer have been removed.

UserPicker.systemMenu is a NavigationView with one List. Legacy layout remains only
below iOS 26. Shared account-loading logic and switchProfile preserve original API,
visibility filtering, unread/badge display and disabled state. Native menu choices
provide System/Light/Dark appearance actions. Sheet content is presented directly
at the large detent; no vertical ScrollView encloses the List. Queued destination
routing still waits for onDismiss, and privacy redaction remains in place.

Server filters are standard Picker rows, statistics remain unchanged, and standard
Done/share toolbar items replace custom modal chrome. ChatListNativeSearch is a
standard TextField/Buttons adapter preserving focus/link/progress bindings;
ChatListUnreadButton uses standard bordered/prominent button styles. TagsView uses
native Buttons and an Edit context menu to open the original tag-management sheet.
See [system-interface.md](system-interface.md) for the source index and boundaries.

## Native control correction (2026-10-30)
See [adoption and validation limits](../../../../docs/fork/ios/SYSTEM_UI_ADOPTION.md#maintainer-design-constraint-and-control-correction-2026-10-30).
UIKit UISearchBar preserves text/focus/progress/link and cancellation bindings.
Circular UIKit glass toolbar controls own their backgrounds on iOS 26; stock
SwiftUI toolbar shared backgrounds are suppressed only for those controls.
Neutral settings/compose foregrounds do not replace semantic action colors.
Conversation uses automatic system navigation background and extends under its
top safe area; virtualized scrolling and message/voice handlers are unchanged.

## Native tabs and explicit folders (2026-10-30)
ContentView.mainTabs embeds SunderMainTabs (UITabBarController) below the unchanged
authentication/call gates. Three persistent UIHostingControllers receive model,
theme, scene, tags, folder-save binding and privacy redaction explicitly. UIKit
UITab/UISearchTab delegates drive selection and search without an empty search
screen; older systems use standard tab items. Conversation opens select Chats and
hide the tab bar using the system API; repeated layout updates do not restart it.

ChatListView.pinnedControls uses safeAreaInset: optional search/Close first, then
one SunderFolderSegments UIKit UISegmentedControl if custom folders exist. Native
soft scroll-edge effects follow the resulting inset. Automatic preset counts stay
internal for existing unread/report logic; they do not create/render folders.
Edit is localized using the existing Edit resource and opens TagListView. Main-list
reachable inversion is disabled on iOS 26 with the new tab/navigation composition.

SunderFolderEditor uses the existing create/update/set-tag APIs and preserves
other tag IDs on every membership write. Folder ID survives a partial failure so
retry updates the same folder. Successful writes update the existing chat model;
errors refresh counts and remain visible. Saving blocks tab switching and back
navigation; profile changes dismiss the editor and stop subsequent writes. Folder
names are localized in all 17 app locale resources; user names remain user data.

ShareSheet.getTopViewController now descends through selected tabs, visible native
navigation and visible children as well as presentations, preserving modal routes.
No cryptographic, transport, database-schema or notification implementation changes.
Source checks and CI compilation are distinct from pending device visual checks.

## Native navigation integration follow-up (2026-10-30)
SunderNavigationSearch attaches UISearchController to the actual owning navigation
item on iOS 26: integrated placement, no external/toolbar placement, and native
bar-item updates. The leading/context/avatar UIKit identifiers connect Edit to
system back/search, unread to title/Close, and compose to avatar transitions.
Existing search-text/link handling stays mounted without rendering a duplicate
field; older systems keep the field. The compose symbol now uses the standard
SF Symbol toolbar size without imageView frame changes.

SunderScrollEdgeBinding adds UIScrollEdgeElementContainerInteraction to the actual
folder UIKit container, finds its owning table/vertical collection through public
view/controller relationships, and binds the native .top/.soft effect. There is
one interaction per container, no custom blur/shader/timer, and a smaller 40-point
segment with 4-point spacing. No cross-screen top-controller lookup is used.

Root visibility callbacks are injected per hosting root. Only the selected root's
push/pop visibility changes its tab-hidden flag. Explicit rootTab marking avoids
modal settings/profile routes modifying main-tab depth. Grouped iOS 26 settings
use systemGroupedBackground with native list/section/picker/toggle/button defaults.

Non-note primary chat toolbar content separates title and avatar and sets native
item sharing off, avoiding a second glass backing. Existing profile sheets remain
attached to the title action; avatar action uses the same group-load/profile route.
Avatar context actions preserve call permission checks, mute/search/filter/member
commands. Notes, secondary chats and message selection keep the legacy toolbar.
SunderFolderEditor confirms deletion, uses the existing delete-tag API and clears
only folder metadata/selection/counts. List swipe deletion now reports API errors.
Compile and on-device animation/layout checks are separate; iOS 27 is not verified.

## Three-island navigation correction (2026-10-31)
ChatView suppresses the default navigationTitle directly for usesModernAvatarToolbar;
the helper no longer adds a competing outer title preference. SunderToolbarIdentity
moves the existing title bar item into centerItemGroups with the native editor
item style, and avatar into its own trailing fixed group. Context/avatar identifiers
remain unchanged. Groups are cached by item identity to avoid layout churn; removing
the attachment for selection restores its original center/style only on its owner.
The native back item and navigation controller delegate are not replaced.

ChatListView.glassTopToolbar inserts ToolbarSpacer(.fixed) between unread and compose.
sharesBackground alone was ignored inside the prior multi-item group. Change reuses
the existing resource in all 17 locales; the Ukrainian verb is corrected. UIKit owns
all transition rendering: no snapshots, gesture/animation engine or timers are added.
Note/selection/secondary routes and existing profile/context handlers are retained.
Compilation and actual device centering/transition acceptance are separate checks.
