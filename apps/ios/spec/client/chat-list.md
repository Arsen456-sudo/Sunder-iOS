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

## 2. [`ChatListView`](../../Shared/Views/ChatList/ChatListView.swift#L156) {#2-chatlistview}

**File**: `Shared/Views/ChatList/ChatListView.swift`

The root list view. Key responsibilities:

### Data Source
- Reads `ChatModel.shared.chats` (all conversations)
- Applies active filter from `ChatTagsModel.shared.activeFilter`
- Applies search query filtering via [`filteredChats()`](../../Shared/Views/ChatList/ChatListView.swift#L453)
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
| [`body`](../../Shared/Views/ChatList/ChatListView.swift#L88) | See link | Main view body |
| [`filteredChats()`](../../Shared/Views/ChatList/ChatListView.swift#L453) | See link | Applies active filter and search to chat list |
| [`searchString()`](../../Shared/Views/ChatList/ChatListView.swift#L496) | See link | Normalizes search text for comparison |
| [`stopAudioPlayer()`](../../Shared/Views/ChatList/ChatListView.swift#L447) | See link | Stops any playing voice message |

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
- Direct chat: navigates to `ChatView` via `ItemsModel.loadOpenChat(chatId)` -- [`contactNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L95) L93
- Group chat: navigates to `ChatView` -- [`groupNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L217) L214
- Contact request: shows `ContactRequestView` with accept/reject -- [`contactRequestNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L495) L486
- Contact connection: shows `ContactConnectionInfo` -- [`contactConnectionNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L530) L520
- Notes folder: navigates to `ChatView` -- [`noteFolderNavLink()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L302) L298

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

Filter matching is handled by [`presetTagMatchesChat()`](../../Shared/Views/ChatList/ChatListView.swift#L940) and the in-view [`TagsView`](../../Shared/Views/ChatList/ChatListView.swift#L734) struct.

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
| [`setActiveFilter()`](../../Shared/Views/ChatList/ChatListView.swift#L921) | ChatListView.swift | 1113 | Applies a filter and persists selection |

### Tag Management Commands
- `apiCreateChatTag(tag: ChatTagData)` -- create tag
- `apiSetChatTags(type:, id:, tagIds:)` -- assign tags to a chat
- `apiDeleteChatTag(tagId:)` -- delete tag
- `apiUpdateChatTag(tagId:, tagData:)` -- rename tag
- `apiReorderChatTags(tagIds:)` -- reorder tags

---

## 6. Search

Search is available via pull-down gesture or search button in the navigation bar.

**Search bar UI:** [`ChatListSearchBar`](../../Shared/Views/ChatList/ChatListView.swift#L502)

### Filtering Logic
- Filters `ChatModel.chats` by matching search text against:
  - `chatInfo.displayName` (contact/group name)
  - `chatInfo.localAlias` (local alias)
  - `chatInfo.fullName` (full name)
- For deeper message content search, uses `apiGetChat(chatId:, search:)` parameter
- Core logic in [`filteredChats()`](../../Shared/Views/ChatList/ChatListView.swift#L453) and [`searchString()`](../../Shared/Views/ChatList/ChatListView.swift#L496)

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
| Pin / Unpin | pin | [`toggleFavoriteButton()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L353) | 347 | `apiSetChatSettings` (favorite) | Always |
| Read / Unread | envelope | [`markReadButton()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L333) | 328 | `apiChatRead` / `apiChatUnread` | Always |

### Trailing Swipe (right-to-left)

| Action | Icon | Handler | Line | API | Condition |
|--------|------|---------|------|-----|-----------|
| Mute / Unmute | bell.slash | [`toggleNtfsButton()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L372) | 365 | `apiSetChatSettings` (enableNtfs) | Always |
| Clear | trash | [`clearChatButton()`](../../Shared/Views/ChatList/ChatListNavLink.swift#L393) | 385 | `apiClearChat` | Has messages |
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
| Chat list view | [`ChatListView.swift`](../../Shared/Views/ChatList/ChatListView.swift) | `ChatListView` | [154](../../Shared/Views/ChatList/ChatListView.swift#L156) |
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

## 11. Sunder UIKit top bar

### Native chat-list controls (2026-10-29)

`withToolbar` inserts native chrome outside the list inversion, using the existing
one-hand preference. `ChatListChromeState` carries only display data. UIKit owns
buttons, constraints, image rendering and accessibility; closures preserve all
existing profile, compose, stopped-chat and server-summary actions.

Both top and one-hand modes use `UIGlassContainerEffect` with two
circular `UIGlassEffect` children and a transparent central title area. The placement preference changes only
the safe-area edge, not whether islands are installed. Each side control is
44 points high at the default text size; 8-point vertical gaps keep it floating. Only controls use glass, not rows.
Native search delegates update the original bindings, retaining link/name resolution,
debounce, cancellation and filters. The unread button uses native glass configuration.

`ChatListChromeScope` weakly connects the screen's List to its controller. The probe
checks geometry and UITableView/UICollectionView type within the local hierarchy,
never searches the entire window, and caches the match. The controller attaches one
`UIScrollEdgeElementContainerInteraction`, setting logical top `.soft` (physical
bottom for the inverted one-hand list), and restores the previous edge on detach.
Subscription polling is visibility-scoped, cancellable, and preserves existing
formatting/proxy colors. Avatar decoding/cropping is cached by image string.

All iOS 26 APIs have availability guards; deployment target remains iOS 15.
Reduce Motion disables interactive bounce; Reduce Transparency uses opaque fallback.
SwiftUI still owns list rows, swipes, tags, onboarding, routes and modal contents.
This is not a full-application UIKit migration. Device appearance needs verification.


The app-level `UIDesignRequiresCompatibility` flag is false, enabling the OS's
current UI design. This prerequisite is global: system-owned bars, sheets and
controls elsewhere may also adopt the current appearance, although only the
chat-list layout is redesigned. Explicit glass stays availability-guarded.

## 11. Compact native chrome and server information

The native controller renders the central area with a nil effect and clear
background in every OS/accessibility path. Chats remains a UIButton with the
existing action; the server-screen title is static accessibility text. Display-only
state fields provide leading/trailing symbols, labels and share enablement.
The default toolbar is 60 points, including 8-point top/bottom gaps and 44-point
circles. Avatar rasterization is cached at 28 points. A missing compose action
retains transparent layout space, preventing the title from shifting.

ServersSummaryView retains NavigationView and its four data branches. Root chrome
is replaced by SunderModalChrome; dismiss uses the modal presentation
binding, and shareSummary exports the same JSON via the existing share sheet.
summaryFilters binds native glass-selector indexes to the existing enums.
Selectors sit in the root safe-area inset, statistics use insetGrouped List, and
ChatListScrollProbe binds only that modal's own scope. Child SMP/XFTP pages explicitly
restore their navigation bars. Statistics, networking, timer, reset/reconnect alerts
and detail destinations remain unchanged. Statistics/rows are still SwiftUI.


## 12. Shared native glass presentation

SunderGlassDesign.swift provides the native UIVisualEffectView material and a
UIViewRepresentable background. UIGlassEffect and UICornerConfiguration are guarded
by iOS 26 availability; older systems use systemMaterial, and Reduce Transparency
uses an opaque surface. Background surfaces ignore interaction and accessibility.
The native selector contains equal-width UIKit buttons, one glass material and a
separate nonglass selection indicator. It preserves bindings and selected traits.

ServersSummarySegment aliases SunderGlassSelector; SunderModalChrome is shared by
server/contact/group roots. Server selectors are 44 points high over a black root
background with dark appearance; scrollContentBackground is hidden locally on
iOS 16+, without global appearance changes. Main action symbols use label color.

Folder filter presentation adds glass around existing views without replacing tap
or long-press actions. UserPicker's ListRow has a default-false transparent flag;
only the glass-backed picker rows enable it. Other ListRow callers keep the old
background. Account loading, switching, hidden-profile checks and theme actions
remain unchanged. See [chat-view.md](chat-view.md) and [compose.md](compose.md) for
conversation/profile usage; their rows and business state remain SwiftUI.

### Native source entry points

- [`init(radius: CGFloat = 22)`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L10)
- [`private func updateMaterial()`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L25)
- [`override func layoutSubviews()`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L40)
- [`deinit`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L53)
- [`func makeUIView(context: Context) -> SunderGlassEffectView`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L60)
- [`func updateUIView(_ view: SunderGlassEffectView, context: Context)`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L66)
- [`@ViewBuilder func ifAvailableHideScrollBackground() -> some View`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L73)
- [`func sunderGlass(cornerRadius: CGFloat = 22) -> some View`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L78)
- [`func makeCoordinator() -> Coordinator`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L90)
- [`func makeUIView(context: Context) -> Control`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L91)
- [`func updateUIView(_ control: Control, context: Context)`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L96)
- [`init(_ parent: SunderGlassSelector)`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L105)
- [`@objc func select(_ control: Control)`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L106)
- [`init(titles: [String])`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L116)
- [`func update(titles: [String], selection: Int, tint: UIColor)`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L154)
- [`override func layoutSubviews()`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L166)
- [`@objc private func choose(_ button: UIButton)`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L175)
- [`init(floating: Bool)`](../../Shared/Views/ChatList/ChatListChromeController.swift#L44)
- [`override func viewDidLoad()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L52)
- [`private func installFloatingBar()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L83)
- [`private func updateMaterials()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L129)
- [`override func viewDidLayoutSubviews()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L165)
- [`func update(_ state: ChatListChromeState)`](../../Shared/Views/ChatList/ChatListChromeController.swift#L173)
- [`private func render()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L182)
- [`func bindScrollView(_ scrollView: UIScrollView)`](../../Shared/Views/ChatList/ChatListChromeController.swift#L237)
- [`func unbindScrollView()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L257)
- [`override func viewDidAppear(_ animated: Bool)`](../../Shared/Views/ChatList/ChatListChromeController.swift#L263)
- [`override func viewWillDisappear(_ animated: Bool)`](../../Shared/Views/ChatList/ChatListChromeController.swift#L269)
- [`func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool`](../../Shared/Views/ChatList/ChatListChromeController.swift#L276)
- [`@objc private func openProfile()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L285)
- [`@objc private func openStatus()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L286)
- [`@objc private func openCompose()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L287)
- [`@objc private func openSearch()`](../../Shared/Views/ChatList/ChatListChromeController.swift#L288)
- [`deinit`](../../Shared/Views/ChatList/ChatListChromeController.swift#L290)
- [`func bind()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L10)
- [`func makeCoordinator() -> Coordinator`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L31)
- [`func makeUIViewController(context: Context) -> ChatListChromeController`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L33)
- [`func updateUIViewController(_ controller: ChatListChromeController, context: Context)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L44)
- [`static func dismantleUIViewController(_ controller: ChatListChromeController, coordinator: Coordinator)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L54)
- [`init(_ parent: ChatListNativeChrome)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L69)
- [`func render()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L71)
- [`func start()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L113)
- [`func stop()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L135)
- [`func makeUIView(context: Context) -> Probe`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L145)
- [`func updateUIView(_ view: Probe, context: Context)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L146)
- [`init(scope: ChatListChromeScope)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L152)
- [`override func didMoveToWindow()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L161)
- [`override func layoutSubviews()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L162)
- [`func resolve()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L164)
- [`private func findList(in root: UIView, rect: CGRect, window: UIWindow) -> UIScrollView?`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L191)
- [`func makeCoordinator() -> Coordinator`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L215)
- [`func makeUIView(context: Context) -> UISearchBar`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L217)
- [`func updateUIView(_ search: UISearchBar, context: Context)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L234)
- [`init(_ parent: ChatListNativeSearch)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L263)
- [`func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L275)
- [`func searchBarTextDidBeginEditing(_ searchBar: UISearchBar)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L276)
- [`func searchBarTextDidEndEditing(_ searchBar: UISearchBar)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L277)
- [`func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L278)
- [`func searchBarSearchButtonClicked(_ searchBar: UISearchBar)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L279)
- [`func searchBarCancelButtonClicked(_ searchBar: UISearchBar)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L280)
- [`@objc func clearText()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L285)
- [`func makeCoordinator() -> Coordinator`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L295)
- [`func makeUIView(context: Context) -> UIButton`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L296)
- [`func updateUIView(_ button: UIButton, context: Context)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L301)
- [`init(_ action: @escaping () -> Void)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L319)
- [`@objc func tap()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L320)
- [`func makeUIViewController(context: Context) -> ChatListChromeController`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L335)
- [`func updateUIViewController(_ controller: ChatListChromeController, context: Context)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L344)
- [`static func dismantleUIViewController(_ controller: ChatListChromeController, coordinator: ())`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L362)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L39)
- [`private var summaryFilters: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L101)
- [`@ViewBuilder private func viewBody() -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L131)
- [`var body: some View`](../../Shared/Views/ChatList/UserPicker.swift#L31)
- [`private func openSheetOnTap(_ icon: String, title: LocalizedStringKey, sheet: UserPickerSheet, showDivider: Bool = true, disabled: Bool = false) -> some View`](../../Shared/Views/ChatList/UserPicker.swift#L162)
- [`init(transparent: Bool = false, action: @escaping () -> Void)`](../../Shared/Views/ChatList/UserPicker.swift#L210)
- [`func body(content: Content) -> some View`](../../Shared/Views/ChatList/UserPicker.swift#L215)
- [`struct TagsView: View`](../../Shared/Views/ChatList/ChatListView.swift#L734)
- [`@ViewBuilder private func expandedTagFilterView(_ tag: PresetTag) -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L836)
- [`@ViewBuilder private func collapsedTagsFilterView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L871)
