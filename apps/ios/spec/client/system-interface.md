# Standard Apple interface components

**Reference:** [AppearanceSettings](../../Shared/Views/UserSettings/AppearanceSettings.swift).
**Products:** [Settings](../../product/views/settings.md), [chat list](../../product/views/chat-list.md), [conversation](../../product/views/chat.md), [profiles](../../product/views/contact-info.md).

## Construction
Use the same NavigationView/List/Section/Picker/Toggle/Button/toolbar construction
as the reference. Shared SystemInterface.swift installs system defaults; it does
not draw navigation panels or glass. Explicit specialized content stays in charge.
The custom glass controller, modal chrome, scroll probe and selector implementation
are removed. UIKit bridges for media rendering and the message editor remain.

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
- [`func makeCoordinator() -> Coordinator`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L16)
- [`func makeUIView(context: Context) -> UISearchBar`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L18)
- [`func updateUIView(_ bar: UISearchBar, context: Context)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L29)
- [`static func dismantleUIView(_ bar: UISearchBar, coordinator: Coordinator)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L54)
- [`struct SunderCircleButton: UIViewRepresentable`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L82)
- [`func makeCoordinator() -> Coordinator`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L91)
- [`func makeUIView(context: Context) -> UIButton`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L93)
- [`func updateUIView(_ button: UIButton, context: Context)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L101)
- [`func avatarImage(_ source: String?, unread: Bool) -> UIImage?`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L153)
- [`struct ChatListUnreadButton: View`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L175)
- [`struct ChatListStatusButton: View`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L188)

### Shared/Views/ChatList/SystemInterface.swift

- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SystemInterface.swift#L6)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SystemInterface.swift#L27)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SystemInterface.swift#L52)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SystemInterface.swift#L63)

### Shared/Views/ChatList/ChatListView.swift

- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L88)
- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L181)
- [`@ViewBuilder private func withToolbar(content: () -> some View) -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L279)
- [`@ViewBuilder private func noChatsView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L490)
- [`@ViewBuilder private func chatView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L512)
- [`func stopAudioPlayer()`](../../Shared/Views/ChatList/ChatListView.swift#L526)
- [`private func filteredChats() -> [Chat]`](../../Shared/Views/ChatList/ChatListView.swift#L532)
- [`func filtered(_ chat: Chat) -> Bool`](../../Shared/Views/ChatList/ChatListView.swift#L560)
- [`func viewNameContains(_ cInfo: ChatInfo, _ s: String) -> Bool`](../../Shared/Views/ChatList/ChatListView.swift#L569)
- [`func searchString() -> String`](../../Shared/Views/ChatList/ChatListView.swift#L575)
- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L598)
- [`private func toggleFilterButton() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L695)
- [`private func connect(_ link: String)`](../../Shared/Views/ChatList/ChatListView.swift#L702)
- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L728)
- [`private func isNameLabel(_ s: String) -> Bool`](../../Shared/Views/ChatList/ChatListView.swift#L759)
- [`func knownChatId(_ result: ConnectionPlanResult?) -> String?`](../../Shared/Views/ChatList/ChatListView.swift#L767)
- [`func nameSearchCandidate(_ str: String) -> String?`](../../Shared/Views/ChatList/ChatListView.swift#L797)
- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L820)
- [`@ViewBuilder private func tagsView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L826)
- [`@ViewBuilder private func expandedTagFilterView(_ tag: PresetTag) -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L888)
- [`private func expandedPresetTagsFiltersView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L908)
- [`@ViewBuilder private func collapsedTagsFilterView() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L916)
- [`private func presentTagLists()`](../../Shared/Views/ChatList/ChatListView.swift#L960)
- [`private func presetTagLabel(tag: PresetTag, active: Bool) -> (item: String, menu: String?, label: LocalizedStringKey)`](../../Shared/Views/ChatList/ChatListView.swift#L975)
- [`private func setActiveFilter(filter: ActiveFilter)`](../../Shared/Views/ChatList/ChatListView.swift#L988)
- [`func chatStoppedIcon() -> some View`](../../Shared/Views/ChatList/ChatListView.swift#L997)
- [`func presetTagMatchesChat(_ tag: PresetTag, _ chatInfo: ChatInfo, _ chatStats: ChatStats) -> Bool`](../../Shared/Views/ChatList/ChatListView.swift#L1009)

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
- [`func showShareSheet(items: [Any], completed: (() -> Void)? = nil)`](../../Shared/Views/Helpers/ShareSheet.swift#L26)
- [`func showAlert(`](../../Shared/Views/Helpers/ShareSheet.swift#L38)
- [`func showAlert(_ a: (title: String, message: String?))`](../../Shared/Views/Helpers/ShareSheet.swift#L57)
- [`func showAlert(`](../../Shared/Views/Helpers/ShareSheet.swift#L61)
- [`func showSheet(`](../../Shared/Views/Helpers/ShareSheet.swift#L73)
- [`func openExternalLink(_ url: URL)`](../../Shared/Views/Helpers/ShareSheet.swift#L94)
- [`var body: some View`](../../Shared/Views/Helpers/ShareSheet.swift#L123)
- [`override func viewDidLoad()`](../../Shared/Views/Helpers/ShareSheet.swift#L186)
- [`@objc private func cancelTapped()`](../../Shared/Views/Helpers/ShareSheet.swift#L402)
- [`@objc private func confirmTapped()`](../../Shared/Views/Helpers/ShareSheet.swift#L408)
- [`@objc private func secondTapped()`](../../Shared/Views/Helpers/ShareSheet.swift#L414)
- [`func showOpenChatAlert<Content: View>(`](../../Shared/Views/Helpers/ShareSheet.swift#L422)
- [`func close(_ completion: (() -> Void)?)`](../../Shared/Views/Helpers/ShareSheet.swift#L487)
- [`var body: some View`](../../Shared/Views/Helpers/ShareSheet.swift#L508)


## Build compatibility repair
ChatListView.withToolbar chooses separately typed systemTopToolbar and
systemBottomToolbar properties; statusButton isolates the conditional status view
from ToolbarContent inference. Preset-filter weight applies to Text, not Label's
View-level iOS 16 modifier. SystemInterface provides the guarded scroll-background
helper used by ServersSummaryView. The deployment target remains iOS 15 and the
system presentation/actions remain the same.

- [`@ToolbarContentBuilder private var systemTopToolbar: some ToolbarContent`](../../Shared/Views/ChatList/ChatListView.swift#L317)
- [`@ToolbarContentBuilder private var systemBottomToolbar: some ToolbarContent`](../../Shared/Views/ChatList/ChatListView.swift#L323)
- [`@ViewBuilder private var statusButton: some View`](../../Shared/Views/ChatList/ChatListView.swift#L333)
- [`ifAvailableHideScrollBackground()`](../../Shared/Views/ChatList/SystemInterface.swift#L74)

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
