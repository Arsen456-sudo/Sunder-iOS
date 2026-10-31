# Chat View (Conversation)

> **Related spec:** [spec/client/chat-view.md](../../spec/client/chat-view.md) | [spec/client/compose.md](../../spec/client/compose.md)

## Purpose

Full conversation view for displaying and interacting with messages in a direct contact chat, group chat, or note-to-self. Supports text messaging with markdown, media attachments, voice messages, E2E encrypted calls, message reactions, replies, forwarding, and content search/filtering.

## Route / Navigation

- **Entry point**: Tap a chat row in `ChatListView`
- **Presented by**: `NavStackCompat` destination from `ChatListView`, bound to `chatModel.chatId`
- **Back navigation**: Dismiss sets `chatModel.chatId = nil`, returning to chat list
- **Sub-navigation**: Info button navigates to `ChatInfoView` (contact) or `GroupChatInfoView` (group); member avatars navigate to `GroupMemberInfoView`

## Page Sections

### Navigation Bar

Custom toolbar overlaying the chat with themed material background:

| Element | Description |
|---|---|
| Back button | Returns to chat list |
| Contact/Group avatar | Small profile image |
| Chat name | Display name; tappable to open info sheet |
| Encryption badge | Shows PQ (post-quantum) or standard E2E status |
| Call buttons | Audio and video call icons (direct chats only) |
| Search button | Toggles in-chat message search |
| Info button | Opens `ChatInfoView` or `GroupChatInfoView` |

### Message List

Rendered by `EndlessScrollView<MergedItem>` with lazy loading and pagination:

| Feature | Description |
|---|---|
| Scroll direction | Bottom-to-top (newest messages at bottom) |
| Pagination | Loads more items on scroll to top (`loadingTopItems`) and bottom (`loadingBottomItems`) |
| Merged items | Adjacent messages from the same sender are visually merged via `MergedItems` |
| Floating buttons | Scroll-to-bottom button with unread count; scroll-to-first-unread button |
| Date separators | Sticky date headers between messages from different days |
| Wallpaper | Themed background image with tint and opacity from `theme.wallpaper` |
| Content filter | Filter messages by type: `.images`, `.files`, `.links` |

### Message Types

Each type has a dedicated view in `Shared/Views/Chat/ChatItem/`:

| Type | View | Description |
|---|---|---|
| Text | `MsgContentView` | Rendered with markdown (bold, italic, code, links, mentions) |
| Image | `CIImageView` | Thumbnail with tap-to-fullscreen via `FullScreenMediaView` |
| Video | `CIVideoView` | Video thumbnail with play button; inline playback |
| Voice | `CIVoiceView` / `FramedCIVoiceView` | Waveform visualization with playback controls and duration |
| File | `CIFileView` | File icon, name, size; download/open actions |
| Link preview | `CILinkView` | URL preview card with title, description, image |
| Emoji-only | `EmojiItemView` | Large emoji rendering without message bubble |
| Call event | `CICallItemView` | Call status (missed, ended, duration) |
| Group event | `CIEventView` | Member joined/left, role changes, group updates |
| E2EE info | `CIChatFeatureView` | Encryption status and feature change notifications |
| Group invitation | `CIGroupInvitationView` | Inline group join invitation card |
| Deleted | `DeletedItemView` / `MarkedDeletedItemView` | Placeholder for deleted messages |
| Decryption error | `CIRcvDecryptionError` | Error with ratchet sync suggestion |
| Invalid JSON | `CIInvalidJSONView` | Developer fallback for malformed items |
| Integrity error | `IntegrityErrorItemView` | Message integrity/gap warnings |

### Message Interactions

Long-press context menu on any message:

| Action | Description |
|---|---|
| Reply | Sets compose bar to reply mode with quoted message |
| Forward | Opens `forwardedChatItems` sheet to pick destination chat |
| Copy | Copies message text to clipboard |
| Edit | Enters edit mode in compose bar (own messages, within edit window) |
| Delete | Delete for self or delete for everyone (with confirmation) |
| React | Opens emoji reaction picker |
| Select multiple | Enters multi-select mode (`selectedChatItems`) with bulk delete/forward |
| Info | Shows delivery status and timestamps |

Emoji reactions bar displayed below messages with reaction counts.

### Compose Bar (`ComposeView`)

| Element | Description |
|---|---|
| Text input | `NativeTextEditor` with markdown support and auto-growing height |
| Attachment button | Opens picker for images, videos, files, camera |
| Send button | Sends composed message; changes to voice record button when empty |
| Voice record | Hold-to-record with waveform preview; swipe-to-cancel |
| Reply quote | Shows quoted message above input when replying |
| Edit indicator | Shows "editing" label when editing a previous message |
| Link preview | Auto-generated preview card for detected URLs (`ComposeLinkView`) |
| Image/Video preview | Thumbnail strip for selected media (`ComposeImageView`) |
| File preview | File name and size for attached file (`ComposeFileView`) |
| Voice preview | Waveform of recorded voice message (`ComposeVoiceView`) |
| Live message | Real-time typing broadcast (optional, with alert on first use) |
| Context actions | `ContextContactRequestActionsView` for accepting/rejecting contact requests; `ContextPendingMemberActionsView` for pending group member actions |
| Commands menu | `CommandsMenuView` for bot/menu commands in chats with `menuCommands` |
| Group mentions | `GroupMentionsView` autocomplete popup when typing `@` in groups |
| Profile picker | `ContextProfilePickerView` for choosing incognito/main profile |

### Channel Messages

In channel conversations (`groupInfo.useRelays == true`), received messages (`.channelRcv` direction) display with:
- The **channel icon** (`antenna.radiowaves.left.and.right`) instead of the standard group icon
- The **channel name** as sender, with "channel" as the role label
- The **group profile image** as the avatar (tapping opens group info, not member info)
- Consecutive channel messages are grouped without repeating the avatar
- Channel messages cannot be moderated per-member (no member identity)

### Member Support Chat (Groups)

For groups with member support enabled:
- `MemberSupportView` and `MemberSupportChatToolbar` shown as secondary chat within group
- `SecondaryChatView` for scoped group chat views (reports, member support)
- User knocking state: `userMemberKnockingTitleBar()` shown when user is pending admission

## Loading / Error States

| State | Behavior |
|---|---|
| Initial load | Messages load from `ItemsModel` with merged items; `allowLoadMoreItems` throttles pagination |
| Loading more (top) | `loadingTopItems` spinner at top of scroll view |
| Loading more (bottom) | `loadingBottomItems` spinner at bottom |
| Connection in progress | `ConnectProgressManager` shows connecting text below compose bar |
| Connecting text | "connecting..." label shown below message list when chat not yet ready |
| Send disabled | Compose bar shows `disabledText` reason when `userCantSendReason` is set |
| Empty chat | No messages placeholder (implicit -- empty scroll view) |

## Related Specs

- `spec/client/chat-view.md` -- Chat view feature specification
- `spec/client/compose.md` -- Compose bar specification
- [Chat List](chat-list.md) -- Parent navigation
- [Contact Info](contact-info.md) -- Info sheet for direct chats
- [Group Info](group-info.md) -- Info sheet for group chats
- [Call](call.md) -- Audio/video calls initiated from toolbar

## Source Files

- `Shared/Views/Chat/ChatView.swift` -- Main chat view, message list, navigation, state management
- `Shared/Views/Chat/ChatItemView.swift` -- Individual message item rendering dispatcher
- `Shared/Views/Chat/ComposeMessage/ComposeView.swift` -- Compose bar container
- `Shared/Views/Chat/ComposeMessage/SendMessageView.swift` -- Send button and voice record
- `Shared/Views/Chat/ComposeMessage/NativeTextEditor.swift` -- Text input with markdown
- `Shared/Views/Chat/ComposeMessage/ComposeImageView.swift` -- Image attachment preview
- `Shared/Views/Chat/ComposeMessage/ComposeFileView.swift` -- File attachment preview
- `Shared/Views/Chat/ComposeMessage/ComposeVoiceView.swift` -- Voice recording preview
- `Shared/Views/Chat/ComposeMessage/ComposeLinkView.swift` -- Link preview generation
- `Shared/Views/Chat/ComposeMessage/ContextItemView.swift` -- Reply/edit context display
- `Shared/Views/Chat/ComposeMessage/ContextContactRequestActionsView.swift` -- Contact request accept/reject
- `Shared/Views/Chat/ComposeMessage/ContextPendingMemberActionsView.swift` -- Pending member actions
- `Shared/Views/Chat/ComposeMessage/ContextProfilePickerView.swift` -- Profile picker for incognito
- `Shared/Views/Chat/ChatItem/FramedItemView.swift` -- Framed message bubble rendering
- `Shared/Views/Chat/ChatItem/MsgContentView.swift` -- Text message content with markdown
- `Shared/Views/Chat/ChatItem/CIImageView.swift` -- Image message view
- `Shared/Views/Chat/ChatItem/CIVideoView.swift` -- Video message view
- `Shared/Views/Chat/ChatItem/CIVoiceView.swift` -- Voice message view
- `Shared/Views/Chat/ChatItem/CIFileView.swift` -- File message view
- `Shared/Views/Chat/ChatItem/CILinkView.swift` -- Link preview view
- `Shared/Views/Chat/ChatItem/EmojiItemView.swift` -- Large emoji view
- `Shared/Views/Chat/ChatItem/CICallItemView.swift` -- Call event view
- `Shared/Views/Chat/ChatItem/CIEventView.swift` -- Group/system event view
- `Shared/Views/Chat/ChatItem/CIChatFeatureView.swift` -- Feature change notification
- `Shared/Views/Chat/ChatItem/CIMetaView.swift` -- Timestamp and delivery status
- `Shared/Views/Chat/ChatItem/FullScreenMediaView.swift` -- Fullscreen image/video viewer
- `Shared/Views/Chat/ChatItem/AnimatedImageView.swift` -- Animated GIF rendering
- `Shared/Views/Chat/Group/GroupMentions.swift` -- @mention autocomplete
- `Shared/Views/Chat/Group/MemberSupportView.swift` -- Member support scoped chat
- `Shared/Views/Chat/Group/MemberSupportChatToolbar.swift` -- Support chat toolbar
- `Shared/Views/Chat/Group/SecondaryChatView.swift` -- Secondary scoped chat view

## Sunder logo removal — 2026-10-28

Concealed spoiler text retains its transparent foreground, opaque background and tap-to-reveal state. Only the tiled logo decoration is removed; concealment does not depend on the watermark.

See [logo-removal specification](../../spec/client/navigation.md#sunder-temporary-logo-removal--2026-10-28).

## Sunder resource cleanup — 2026-10-28

Sent and delivered status meanings/colors remain, rendered with checkmark and checkmark.circle.fill. Original sample preview images use a new neutral PNG; user-provided media and decoders are unchanged.

See [preparation scope](../../spec/client/navigation.md#sunder-publication-preparation--2026-10-28).

### Standard conversation controls (2026-10-30)
Chat keeps the system navigation toolbar and uses the system bar material for
search and compose areas. Attachment, command, profile and folder actions use
standard buttons. The fixed 220-point chat-title width and bespoke glass backings
are removed. Native text editing, messages, voice/send gestures, previews, call
menus and pagination remain intact; they are not rewritten into settings forms.

### Native geometry correction (2026-10-30)
Conversation search and member searches use the shared UISearchBar adapter. Ordinary compose controls use neutral adaptive colors. The top background/content extends beneath the native navigation bar without a forced opaque band; message layout/pagination and recording gestures remain unchanged.

## Native navigation integration follow-up (2026-10-30)

For ordinary direct/group/channel chats on iOS 26, the title and avatar are
separate native toolbar items. Tapping either opens the existing profile route;
long-pressing the avatar exposes retained call, search, notification, membership
and media-filter actions. Verified/incognito/status text and report indicators
remain; note chats and message-selection toolbars keep their original behavior.
UIKit bar item identifiers match main leading/context/avatar roles during push/pop.

## Three-island navigation correction (2026-10-31)

Normal iOS 26 chat navigation has native back, one centered title island, and one
trailing avatar island. The ordinary navigation title is suppressed at its source;
there is no duplicate unboxed title. A single UIKit fixed center item group owns
the title, with the avatar alone in its trailing group. Notes, selection and
secondary chats retain their prior toolbars. Avatar chrome contains only the photo;
existing profile and context actions remain attached.

## Independent header and immediate tabs (2026-10-31)

This supersedes the attempted post-layout centerItemGroups migration on compact
phones. The title is declared in the native principal slot and avatar in trailing.
Each uses its own official glass button style; shared toolbar backings are hidden,
so they cannot share the trailing capsule. The group-migration controller is removed.
Normal navigation title remains empty; notes, selection, profile and context actions
are unchanged. All rendering and transitions remain standard Apple behavior.

Navigation push/pop animations must remain enabled. Immediate tab-bar hiding is
scoped to the tab bar and must not disable upper-toolbar or navigation transitions.
Exact cross-placement item morphing is a device acceptance check, not established
by principal placement or matching SwiftUI item IDs alone.

## Native matched header (2026-10-31)
The ordinary iOS26 title is now owned directly by UIKit as a center bar item, not
a SwiftUI principal titleView. Its identifier matches the list unread control.
Native bar backing owns glass and push/pop animation; the hosted existing profile
action has a 44pt height. Avatar artwork is 32pt, with its existing profile/context
actions retained. This supersedes the principal-slot implementation above. Notes,
selection and secondary routes retain their original toolbar. Device checks must
verify centering, matched transitions in both directions and long/localized names.

## Restore compact-phone title (2026-10-31)
Device feedback reports the centerItemGroups implementation absent on compact iPhone.
It is removed. The title returns to the native principal slot with one separate
44pt system glassEffect capsule; no shared backing or duplicate title is added.
Avatar/back remain separate. Existing title/profile actions and navigation animations
are retained. This supersedes the source-owned native center-item implementation.

## Avatar-only toolbar and compatibility fix (2026-10-31)
The modern avatar control explicitly hides its menu indicator; the photo is its
only visible label. Long-press profile actions remain available. The removed editor
center-group implementation is not restored. Availability selection is now outside
the toolbar builder so iOS15 fallback continues to compile.

## Full-page profiles and small avatar increase (2026-10-31)
The chat avatar artwork grows from 32 to 34pt without changing its island, action,
context menu or the other toolbar placements/materials. Title and avatar taps open
the existing contact/group/channel profile content as a full pushed destination,
with native back navigation. Profile subpages and all existing actions remain.
Normal list taps no longer enqueue an extra MainActor Task before route selection.
No measured timing gain is claimed and navigation animations remain enabled.
The requested unread-filter-to-title morph remains unresolved; the stable principal
title is retained rather than repeating the failed center-group implementation.

## Profile-navigation stabilization (2026-10-31)
The chat stack now retains its own path rather than rebuilding it from the chat-open
Boolean on every update. Pushing/popping the existing profile and its child routes
must not reset the chat route. Native interactive back and explicit chat close remain.
The avatar's actual UIKit bar-item identifier is assigned again without moving or
regrouping items. Existing header appearance/materials remain unchanged. A native
center identifier is assigned only if UIKit exposes one actual center bar item;
principal titleView matching remains unproven. Device validation is required.

## USB-reproduced profile update storm (2026-10-31)
A user-reproduced profile hang was captured over USB. The log contains one SwiftUI
state-during-update fault and sustained repeated action-label evaluation after the
profile tap. The route now constructs an independent ChatProfileDestination with
explicit model/binding captures, not the entire ChatView/DismissAction environment.
Profile contents, native back, search return, permissions and privacy stay unchanged.
This targets the observed update storm; disappearance of the hang is not yet device
verified. Native header item lookup now includes actual trailingItemGroups rather
than relying on the empty legacy array seen on the phone. Exact title morph remains
unproven because the runtime title is a titleView with zero native center items.

## Build24 symbolicated reproduction (2026-10-31)
The installed build24 tag was verified and the user reproduced the hang. Main-thread
samples show SwiftUI/AttributeGraph update work and DeprecatedAlertBridge environment
updates, rather than a sampled core/network wait. Main contact/group profile views
now avoid a DismissAction property captured by legacy alert closures; native back and
all existing profile content/actions remain. Unread native background sharing is
disabled once per resolved item to target merging without changing other islands.
Exact filter-to-title morph is still not implemented/verified and must not be implied.

## Full-screen profile recovery (2026-10-31)
Disk IPA and phone source tags were verified equal to build25; replacement was not
the cause of the unchanged failure. The faulty profile push is removed. The existing
profile content again owns its original independent NavigationView and is presented
on the whole screen with a leading back action. Chat toolbar and messages are not
redesigned. Native fullScreenCover supplies presentation/dismissal; this is a separate
full-screen menu rather than a navigation push. Profile cleanup/theme refresh is
performed after cover dismissal. Native filter-to-title matching remains unresolved.

## Profile side navigation (2026-10-31)
Profile content keeps an independent navigation context; a separate owned UIKit
container supplies native side push/pop over chat. No snapshots/custom animator are
used. Native edge back is enabled at profile root, not over deeper profile routes.
Cleanup occurs after completed closing, not during an interactive/cancelled pop.
