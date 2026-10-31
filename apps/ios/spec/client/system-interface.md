# Standard Apple interface components

**Reference:** [AppearanceSettings](../../Shared/Views/UserSettings/AppearanceSettings.swift).
**Products:** [Settings](../../product/views/settings.md), [chat list](../../product/views/chat-list.md), [conversation](../../product/views/chat.md), [profiles](../../product/views/contact-info.md).

## Construction
Use the same NavigationView/List/Section/Picker/Toggle/Button/toolbar construction
as the reference. Shared SystemInterface.swift installs system defaults; it does
not draw navigation panels or glass. Explicit specialized content stays in charge.
The earlier custom rendering/capture layer remains removed. Native navigation
attachments now configure UIKit search, item identifiers and scroll-edge interactions. UIKit bridges for media rendering and the message editor remain.

Avatar-menu scrolling belongs to List. Its standard Done action and profile/settings
rows replace nested stacks and glass surfaces. iOS 26 Sheet presents the content
directly at the large detent, with the original privacy modifier and queued route
selection after dismissal. Profile switching uses the unchanged API/error flow.

Main, contact/group profile and server roots use native toolbar items, including
all original status/compose/share/close actions. Server selectors are native Picker
rows. Settings routes keep the shared policy and unchanged reference screen. Search
uses native fields/buttons; tag editing is reached through the native context menu.
Profile and call controls use native bordered/prominent styles. Command/composer
backgrounds use the standard bar material. The specialized text/voice input keeps
its original editor/state/gestures. No new renderer, network or storage API is used.

Profile confirmations use a standard NavigationView/List presented as a system sheet
on iOS 26. Image, badge, names, information and all choices are retained. A weak
presentation holder dismisses first, then invokes the original selected callback,
once. Interactive dismissal is disabled for this confirmation to preserve explicit
choice semantics. The old UIKit popup remains only as an older-OS fallback.

## Validation boundary
Source inventory is lexical coverage, not every-route visual proof. The exact build
must compile before device validation. See [adoption report](../../../../docs/fork/ios/SYSTEM_UI_ADOPTION.md).

## Source entry points

### Shared/Views/ChatList/UserPicker.swift

- [`var body: some View`](../../Shared/Views/ChatList/UserPicker.swift#L31)
- [`private var systemMenu: some View`](../../Shared/Views/ChatList/UserPicker.swift#L131)
- [`private func systemMenuRow(_ icon: String, title: LocalizedStringKey, sheet: UserPickerSheet, disabled: Bool = false) -> some View`](../../Shared/Views/ChatList/UserPicker.swift#L197)
- [`private func userView(_ u: UserInfo, size: CGFloat) -> some View`](../../Shared/Views/ChatList/UserPicker.swift#L204)
- [`private func switchProfile(_ u: UserInfo)`](../../Shared/Views/ChatList/UserPicker.swift#L223)
- [`private func openSheetOnTap(_ icon: String, title: LocalizedStringKey, sheet: UserPickerSheet, showDivider: Bool = true, disabled: Bool = false) -> some View`](../../Shared/Views/ChatList/UserPicker.swift#L244)
- [`func userUnreadBadge(_ userInfo: UserInfo, theme: AppTheme) -> some View`](../../Shared/Views/ChatList/UserPicker.swift#L262)
- [`var body: some View`](../../Shared/Views/ChatList/UserPicker.swift#L274)
- [`func body(content: Content) -> some View`](../../Shared/Views/ChatList/UserPicker.swift#L297)
- [`func makeUIView(context: Context) -> TouchView`](../../Shared/Views/ChatList/UserPicker.swift#L317)
- [`func updateUIView(_ touchView: TouchView, context: Context)`](../../Shared/Views/ChatList/UserPicker.swift#L329)
- [`func longPress(gesture: UILongPressGestureRecognizer)`](../../Shared/Views/ChatList/UserPicker.swift#L339)
- [`func gestureRecognizer(`](../../Shared/Views/ChatList/UserPicker.swift#L369)

### Shared/Views/ChatList/ChatListNativeControls.swift

- [`struct ChatListNativeSearch: UIViewRepresentable`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L7)
- [`struct SunderCircleButton: UIViewRepresentable`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L83)
- [`struct ChatListUnreadButton: View`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L186)
- [`struct ChatListStatusButton: View`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L199)
- [`final class SunderMainNavigation: ObservableObject`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L233)
- [`struct SunderMainTabs: UIViewControllerRepresentable`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L296)
- [`struct SunderFolderSegments: UIViewRepresentable`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L403)
- [`@MainActor private func sunderNavigationOwner(_ controller: UIViewController?) -> UIViewController?`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L495)
- [`@MainActor private final class SunderScrollEdgeBinding`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L505)
- [`struct SunderNavigationSearch: UIViewControllerRepresentable`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L583)

### Shared/Views/ChatList/SystemInterface.swift

- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SystemInterface.swift#L7)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SystemInterface.swift#L28)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SystemInterface.swift#L53)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SystemInterface.swift#L64)

### Shared/Views/ChatList/ChatListView.swift

- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L89)
- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L188)
- [`@ViewBuilder private func withToolbar(content: () -> some View) -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L344)
- [`@ViewBuilder private func noChatsView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L542)
- [`@ViewBuilder private func chatView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L564)
- [`func stopAudioPlayer()`](../../Shared/Views/ChatList/ChatListView.swift#L578)
- [`private func filteredChats() -> [Chat]`](../../Shared/Views/ChatList/ChatListView.swift#L584)
- [`func filtered(_ chat: Chat) -> Bool`](../../Shared/Views/ChatList/ChatListView.swift#L612)
- [`func viewNameContains(_ cInfo: ChatInfo, _ s: String) -> Bool`](../../Shared/Views/ChatList/ChatListView.swift#L621)
- [`func searchString() -> String`](../../Shared/Views/ChatList/ChatListView.swift#L627)
- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L652)
- [`private func toggleFilterButton() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L734)
- [`private func connect(_ link: String)`](../../Shared/Views/ChatList/ChatListView.swift#L741)
- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L767)
- [`private func isNameLabel(_ s: String) -> Bool`](../../Shared/Views/ChatList/ChatListView.swift#L798)
- [`func knownChatId(_ result: ConnectionPlanResult?) -> String?`](../../Shared/Views/ChatList/ChatListView.swift#L806)
- [`func nameSearchCandidate(_ str: String) -> String?`](../../Shared/Views/ChatList/ChatListView.swift#L836)
- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L859)
- [`@ViewBuilder private func tagsView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L865)
- [`@ViewBuilder private func expandedTagFilterView(_ tag: PresetTag) -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L927)
- [`private func expandedPresetTagsFiltersView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L947)
- [`@ViewBuilder private func collapsedTagsFilterView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L955)
- [`private func presentTagLists()`](../../Shared/Views/ChatList/ChatListView.swift#L999)
- [`private func presetTagLabel(tag: PresetTag, active: Bool) -> (item: String, menu: String?, label: LocalizedStringKey)`](../../Shared/Views/ChatList/ChatListView.swift#L1014)
- [`private func setActiveFilter(filter: ActiveFilter)`](../../Shared/Views/ChatList/ChatListView.swift#L1027)
- [`func chatStoppedIcon() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L1036)
- [`func presetTagMatchesChat(_ tag: PresetTag, _ chatInfo: ChatInfo, _ chatStats: ChatStats) -> Bool`](../../Shared/Views/ChatList/ChatListView.swift#L1048)

### Shared/Views/ChatList/ServersSummaryView.swift

- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L37)
- [`private func startTimer()`](../../Shared/Views/ChatList/ServersSummaryView.swift#L69)
- [`private func getServersSummary()`](../../Shared/Views/ChatList/ServersSummaryView.swift#L77)
- [`private func stopTimer()`](../../Shared/Views/ChatList/ServersSummaryView.swift#L85)
- [`private func shareSummary()`](../../Shared/Views/ChatList/ServersSummaryView.swift#L90)
- [`public func encodePrettyPrinted<T: Encodable>(_ value: T) -> String`](../../Shared/Views/ChatList/ServersSummaryView.swift#L109)
- [`@ViewBuilder private func viewBody() -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L116)
- [`private func smpSubsSection(_ totals: SMPTotals) -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L204)
- [`private func reconnectAllButton() -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L220)
- [`private func smpServersListView(`](../../Shared/Views/ChatList/ServersSummaryView.swift#L250)
- [`private func smpServerView(_ srvSumm: SMPServerSummary, _ statsStartedAt: Date) -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L276)
- [`private func serverAddress(_ server: String) -> String`](../../Shared/Views/ChatList/ServersSummaryView.swift#L306)
- [`private func sessIconColor(_ sess: ServerSessions) -> Color`](../../Shared/Views/ChatList/ServersSummaryView.swift#L310)
- [`private func xftpServersListView(`](../../Shared/Views/ChatList/ServersSummaryView.swift#L324)
- [`private func xftpServerView(_ srvSumm: XFTPServerSummary, _ statsStartedAt: Date) -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L346)
- [`private func inProgressIcon(_ srvSumm: XFTPServerSummary) -> String?`](../../Shared/Views/ChatList/ServersSummaryView.swift#L370)
- [`private func resetStatsButton() -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L380)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L418)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L441)
- [`func subscriptionStatusInfo(online: Bool, usesProxy: Bool, subs: SMPServerSubs, hasSess: Bool, primaryColor: Color) -> (Color, Double, Double)`](../../Shared/Views/ChatList/ServersSummaryView.swift#L450)
- [`func roundedToQuarter(_ n: Double) -> Double`](../../Shared/Views/ChatList/ServersSummaryView.swift#L451)
- [`func subscriptionStatusPercent(online: Bool, subs: SMPServerSubs, hasSess: Bool) -> Double`](../../Shared/Views/ChatList/ServersSummaryView.swift#L476)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L489)
- [`private func smpSubsSection(_ subs: SMPServerSubs) -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L511)
- [`private func reconnectButton() -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L528)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L562)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L575)
- [`private func numOrDash(_ n: Int) -> String`](../../Shared/Views/ChatList/ServersSummaryView.swift#L595)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L603)
- [`private func infoRowTwoValues(_ title: LocalizedStringKey, _ title2: LocalizedStringKey, _ value: Int, _ value2: Int) -> some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L649)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L668)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L691)
- [`private func prettySize(_ sizeInKB: Int64) -> String`](../../Shared/Views/ChatList/ServersSummaryView.swift#L711)
- [`var body: some View`](../../Shared/Views/ChatList/ServersSummaryView.swift#L720)

### Shared/Views/Helpers/SheetRepresentable.swift

- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/Helpers/SheetRepresentable.swift#L30)
- [`func makeUIViewController(context: Context) -> Controller<Content>`](../../Shared/Views/Helpers/SheetRepresentable.swift#L53)
- [`func updateUIViewController(_ sheetController: Controller<Content>, context: Context)`](../../Shared/Views/Helpers/SheetRepresentable.swift#L57)
- [`func animate(isPresented: Bool)`](../../Shared/Views/Helpers/SheetRepresentable.swift#L86)
- [`func handleVisibility()`](../../Shared/Views/Helpers/SheetRepresentable.swift#L108)
- [`override func viewDidLoad()`](../../Shared/Views/Helpers/SheetRepresentable.swift#L124)
- [`override func viewDidAppear(_ animated: Bool)`](../../Shared/Views/Helpers/SheetRepresentable.swift#L148)
- [`func pan(gesture: UIPanGestureRecognizer)`](../../Shared/Views/Helpers/SheetRepresentable.swift#L170)
- [`func tap(gesture: UITapGestureRecognizer)`](../../Shared/Views/Helpers/SheetRepresentable.swift#L194)

### Shared/Views/Helpers/ShareSheet.swift

- [`func getTopViewController() -> UIViewController?`](../../Shared/Views/Helpers/ShareSheet.swift#L12)
- [`func showShareSheet(items: [Any], completed: (() -> Void)? = nil)`](../../Shared/Views/Helpers/ShareSheet.swift#L33)
- [`func showAlert(`](../../Shared/Views/Helpers/ShareSheet.swift#L45)
- [`func showAlert(_ a: (title: String, message: String?))`](../../Shared/Views/Helpers/ShareSheet.swift#L64)
- [`func showAlert(`](../../Shared/Views/Helpers/ShareSheet.swift#L68)
- [`func showSheet(`](../../Shared/Views/Helpers/ShareSheet.swift#L80)
- [`func openExternalLink(_ url: URL)`](../../Shared/Views/Helpers/ShareSheet.swift#L101)
- [`var body: some View`](../../Shared/Views/Helpers/ShareSheet.swift#L130)
- [`override func viewDidLoad()`](../../Shared/Views/Helpers/ShareSheet.swift#L193)
- [`@objc private func cancelTapped()`](../../Shared/Views/Helpers/ShareSheet.swift#L409)
- [`@objc private func confirmTapped()`](../../Shared/Views/Helpers/ShareSheet.swift#L415)
- [`@objc private func secondTapped()`](../../Shared/Views/Helpers/ShareSheet.swift#L421)
- [`func showOpenChatAlert<Content: View>(`](../../Shared/Views/Helpers/ShareSheet.swift#L429)
- [`func close(_ completion: (() -> Void)?)`](../../Shared/Views/Helpers/ShareSheet.swift#L494)
- [`var body: some View`](../../Shared/Views/Helpers/ShareSheet.swift#L515)


## Build compatibility repair
ChatListView.withToolbar chooses separately typed systemTopToolbar and
systemBottomToolbar properties; statusButton isolates the conditional status view
from ToolbarContent inference. Preset-filter weight applies to Text, not Label's
View-level iOS 16 modifier. SystemInterface provides the guarded scroll-background
helper used by ServersSummaryView. The deployment target remains iOS 15 and the
system presentation/actions remain the same.

- [`@ToolbarContentBuilder private var systemTopToolbar: some ToolbarContent`](../../Shared/Views/ChatList/ChatListView.swift#L391)
- [`@ToolbarContentBuilder private var systemBottomToolbar: some ToolbarContent`](../../Shared/Views/ChatList/ChatListView.swift#L397)
- [`@ViewBuilder private var statusButton: some View`](../../Shared/Views/ChatList/ChatListView.swift#L407)
- [`ifAvailableHideScrollBackground()`](../../Shared/Views/ChatList/SystemInterface.swift#L75)

The toolbar definitions are unconditional for iOS 15 compatibility. withToolbar's
ViewBuilder selects bottom, search-hidden or top presentation; it does not use
ToolbarContentBuilder.buildIf (introduced in iOS 16). Search visibility, actions and
appearance remain unchanged.

## Native control correction (2026-10-30)
See [adoption and validation limits](../../../../docs/fork/ios/SYSTEM_UI_ADOPTION.md#maintainer-design-constraint-and-control-correction-2026-10-30).
UIKit UISearchBar preserves text/focus/progress/link and cancellation bindings.
Circular UIKit glass toolbar controls own their backgrounds on iOS 26; stock
SwiftUI toolbar shared backgrounds are suppressed only for those controls.
Neutral settings/compose foregrounds do not replace semantic action colors.
Conversation uses automatic system navigation background and extends under its
top safe area; virtualized scrolling and message/voice handlers are unchanged.

Safe-area review: only the message-list layer extends under the top navigation
bar. Composer, search inset and overlay controls retain their safe-area layout.

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

The modern toolbar role is editor to agree with native center-group ownership;
legacy/selection routes use automatic role on iOS 16+ and the old fallback on 15.

## Independent header and immediate tabs (2026-10-31)
The attempted SunderToolbarIdentity post-layout group migration is removed. On iOS
26 the modern title ToolbarItem uses principal placement, avatar uses trailing, and
the role is automatic. Their official glass button styles provide separate capsule
and circular materials; sharedBackgroundVisibility(.hidden) removes the default
shared backing for these modern items. The title remains cleared at its source.
Notes/selection/secondary and all original profile/context handlers are preserved.

SunderTabRootVisibility now embeds SunderRootLifecycle. Native will callbacks update
the owned root's visibility before transition configuration. Within-stack pushes
hide the native tab bar synchronously with animated:false; root returns show it,
and cancelled interactive returns hide it again. Tab selection also applies the
destination's saved root visibility immediately. A missing navigation-owner lookup
still reports the early will callback to the existing scoped state closure.
No navigation delegate, animation engine, delay/timer or network/storage changes.
The environment-only callback keeps the helper usable in shared/extension sources.
Actual phone centering and transition cancellation still require device validation.

Navigation push/pop animations must remain enabled. Immediate tab-bar hiding is
scoped to the tab bar and must not disable upper-toolbar or navigation transitions.
Exact cross-placement item morphing is a device acceptance check, not established
by principal placement or matching SwiftUI item IDs alone.

## Source-owned native center item (2026-10-31)
This supersedes principal placement: SunderConversationCenter owns a UIKit fixed
centerItemGroups entry directly. There is no SwiftUI principal/trailing title to
reinsert or relocate. The group uses sunder.context and the native editor role;
the existing title/profile action is hosted with forwarded environment and a 44pt
height, bounded to available navigation width. Sizing is invalidated by content
or width changes, not repeated on every layout pass. Reentrancy is guarded.
The trailing avatar retains sunder.avatar and separate native glass backing; its
image is 32pt. Shared glass button overlays are removed from this toolbar only.
SunderTitleButtonStyle is removed; compose controls elsewhere are unchanged.
The helper detaches only its own center group. No custom transition is added.

FolderControl adds UIGlassEffect(.regular) in a clipped capsule surface on iOS26.
SunderScrollEdgeBinding supports top or bottom UIRectEdge; bottom binding is attached
to the actual UITabBar and the owned main-list scrollView, using .soft. It is removed
when the main list disappears or its adapter is dismantled.
SunderNavigationSearch uses automaticallyShowsCancelButton and no competing trailing
Close item. searchBarCancelButtonClicked cancels connection progress, clears text,
focus/active state, and restores saved toolbar items. Its native cancel control owns
width reservation, including narrow screens and accessibility sizes.

Source entry points: [SunderScrollEdgeBinding](../../Shared/Views/ChatList/ChatListNativeControls.swift#L505) | [SunderNavigationSearch](../../Shared/Views/ChatList/ChatListNativeControls.swift#L583)

## Compact-title and tab-edge correction (2026-10-31)
SunderConversationCenter is removed after device feedback showed no title. ChatView
again declares the existing title/profile action as principal. SunderTitleSurface
uses a 44pt native interactive glassEffect capsule, plain action and 12pt horizontal
padding. Only this principal item's shared background is hidden to avoid double
glass. Avatar retains native backing and automatic toolbar role. Default plain
navigationTitle stays empty; selection/notes/secondary fallback remains intact.

SunderTabsController owns bottom registration for all selected roots. On layout,
appearance, selection and state update it finds the selected root's largest visible
vertical UIScrollView, including non-list SwiftUI scroll containers, caches the
result and calls setContentScrollView(_:for:.bottom) on root and tab controller.
The scroll's bottomEdgeEffect is visible with .soft style. Registration is cleared
when the tab bar is hidden or selected root changes; no search-specific interaction
or additional backdrop renderer remains. Main-list search cancellation is unchanged.
Native bar-item morphing from unread to the restored principal title remains a
separate unverified limitation; a restored visible title is not proof of that morph.

Source entry points: [SunderTabsController](../../Shared/Views/ChatList/ChatListNativeControls.swift#L241) | [SunderTitleSurface](../../Shared/Views/ChatList/SystemInterface.swift#L197)

## Toolbar builder compile correction (2026-10-31)
Modern toolbar availability is selected at ChatView's outer ViewBuilder, not via
an iOS15-incompatible ToolbarContentBuilder.buildIf. The iOS26-only property contains
unconditional title/avatar items. Legacy toolbar routing remains unchanged. Avatar
menu indicator is hidden without dropping context actions or reintroducing editor
center-group overflow. Shared bottom-edge registration is unchanged.

## Existing profile content in native navigation (2026-10-31)
SunderProfileNavigation wraps content in NavigationView only when pushed:false.
sunderProfileDestination uses navigationDestination(isPresented:) on iOS16+ and
an invisible NavigationLink on iOS15. The destination closure is escaping, and
availability branching is in ViewBuilder rather than ToolbarContentBuilder.
ChatView applies existing sunderPrivateSheet privacy/style modifiers to the pushed
content without introducing a new modal sheet or a nested navigation stack.
No toolbar/background/scroll-edge ownership changes accompany profile routing.


## Existing native item identity (2026-10-31)
SunderConversationIdentity attaches only to ordinary modern chat headers. It assigns
sunder.avatar to the existing trailing bar item and disables its background sharing;
it assigns sunder.context only when one existing native center item is exposed.
It never creates/moves groups, replaces titleView, changes toolbar role or uses a
custom animator/delegate. Assignment is guarded against redundant mutations.
One post-appearance debug event reports only titleView presence and bar-item counts,
not names, messages, images or account data. This is evidence collection for native
matching; principal-title morphing is not claimed established.

Source entry points: [SunderConversationIdentity](../../Shared/Views/ChatList/ChatListNativeControls.swift#L553)

## Deferred model publication and real grouped items (2026-10-31)
USB syslog: Modifying state during view update; header titleView=true, centerItems=0,
legacy rightBarButtonItems=0. SunderRootLifecycle still hides native tabs immediately,
but defers its model visibility callback to the next main-queue turn with a revision
guard. ContentView skips equal hiddenRoots assignments to avoid redundant publisher
invalidations. Fallback owner lookup uses the same safe publication path.

sunderTrailingBarItems deduplicates native trailingItemGroups and legacy arrays.
sunderMatchingBarItem resolves known semantic identifiers/accessibility labels,
including public customView descendants; no group-order heuristics or private API.
The main filter/compose and destination avatar expose stable accessibility IDs.
Destination identity assignment is scoped to the current top owner and existing
items only. Source/destination diagnostics report bounded counts/match booleans and
owner identity, not labels/chat/account data. SunderNavigationSearch saves/restores
leading/trailing groups when present, with legacy fallback. It does not discard the
actual groups just because the legacy arrays are nil. Principal morph remains a gap.

Source entry points: [sunderTrailingBarItems](../../Shared/Views/ChatList/ChatListNativeControls.swift#L534) | [sunderMatchingBarItem](../../Shared/Views/ChatList/ChatListNativeControls.swift#L541) | [publishVisibility](../../Shared/Views/ChatList/SystemInterface.swift#L131)

The group-aware identity pass changes only identifiers/accessibility metadata. It no
longer writes sharesBackground during native layout: SwiftUI ToolbarSpacer and
existing item declarations own visual separation, avoiding new layout invalidations.

## Unread background sharing and usable diagnostics (2026-10-31)
SunderNavigationSearch keeps a weak reference to the configured unread item. On a
new semantically resolved instance only, sharesBackground=false isolates its native
background. Compose/avatar/title geometry and navigation role stay unchanged. UIKit
ignores this flag for items in multi-item UIBarButtonItemGroup; do not claim an exact
morph based on the flag alone. Source diagnostics now interpolate primitive counts/
booleans, including unreadGroupSize, instead of a String redacted as private in the
actual USB log. The cached report suppresses unchanged messages.

## Remove failed profile-push adapters (2026-10-31)
SunderProfileNavigation and sunderProfileDestination are removed. Both profile views
again contain their original NavigationView directly. sunderFullScreenProfile is a
thin native fullScreenCover wrapper with onDismiss and escaping content. There is
no nested-profile navigationDestination or hidden NavigationLink registration in
the chat stack. The back-looking leading button dismisses the cover; child links
use the independent NavigationView's normal navigation. No custom animator/renderer.

Source entry point: [sunderFullScreenProfile](../../Shared/Views/ChatList/SystemInterface.swift#L209)
