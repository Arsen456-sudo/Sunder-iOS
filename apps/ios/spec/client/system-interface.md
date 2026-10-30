# Shared system interface policy

**Product:** [Settings](../../product/views/settings.md), [Chat list](../../product/views/chat-list.md), [Chat](../../product/views/chat.md), [Onboarding](../../product/views/onboarding.md), [Calls](../../product/views/call.md).

## Reference and boundaries
AppearanceSettings uses standard Apple controls. SunderSystemInterface installs
native contextual controls, inset-grouped list/grouped-form defaults and automatic
system toolbar/scroll-edge styles on iOS 26+. Explicit specialized descendant
styles remain intact. It is installed at SimpleXApp's content root, ThemedBackground,
both appSheet overloads and the share-extension root. Older OS defaults remain.
The shared implementation is compiled in both the app and share-extension targets.

## Presentation and control exceptions
Sheet uses native presentationDetents/drag indicator on iOS 26, with scrollable
content and large-only accessibility detent. It applies the same PrivacySensitive
modifier as appSheet. Older OS versions retain SheetRepresentable. ChatListView
queues the selected UserPickerSheet until native sheet dismissal completes, then
opens the original destination; hidden-profile and account-switching logic remains.

OnboardingButtonStyle delegates original configuration trigger/role into native
glassProminent buttons on iOS 26; isDisabled stays an appearance flag and existing
outer disabled checks remain authoritative. Legacy appearance is retained below
26. BackButton keeps action/disabled state and uses the native compact icon label.
SunderSystemDetailNavigation restores member/connection navigation and provides a
modal close action only where required. Profile data and child routes are preserved.

SunderCommandSurface replaces old material backings for command/action strips on
iOS 26, retaining materials on older versions. Main message content is unaffected.
ContactsListSearchBar reuses native search/filter adapters without changing name/
link resolution or filtering callbacks. Call surfaces retain all actions and red
end-call styling. FullScreenMediaView keeps gestures and player behavior. The
OpenChatAlertViewController uses native glass contentView containment; profile data,
buttons, dividers and callbacks remain unchanged. Passcode buttons get native style
without changing submit guards. ShareView keeps search, password and send logic.

## Coverage and validation
See [system UI adoption report](../../../../docs/fork/ios/SYSTEM_UI_ADOPTION.md)
and [source inventory](../../../../docs/fork/ios/SYSTEM_UI_INVENTORY.json).
The inventory is lexical coverage, not proof that every screen is a settings form
or that every route was visually tested. CI checks it before compiling the IPA.

## Changed source entry points

### Shared/SimpleXApp.swift

- [`var body: some Scene`](../../Shared/SimpleXApp.swift#L39)

### Shared/Theme/Theme.swift

- [`func body(content: Content) -> some View`](../../Shared/Theme/Theme.swift#L62)

### Shared/Views/Call/ActiveCallView.swift

- [`private func controlButton(_ call: Call, _ imageName: String, padding: CGFloat, _ perform: @escaping () -> Void) -> some View`](../../Shared/Views/Call/ActiveCallView.swift#L485)
- [`private func audioDevicePickerButton() -> some View`](../../Shared/Views/Call/ActiveCallView.swift#L489)
- [`private func callButton(_ imageName: String, _ background: Color, padding: CGFloat, glass: Bool = false, _ perform: @escaping () -> Void) -> some View`](../../Shared/Views/Call/ActiveCallView.swift#L499)

### Shared/Views/Call/IncomingCallView.swift

- [`private func callButton(_ text: LocalizedStringKey, _ image: String, _ color: Color, action: @escaping () -> Void) -> some View`](../../Shared/Views/Call/IncomingCallView.swift#L72)

### Shared/Views/Chat/ChatItem/FullScreenMediaView.swift

- [`var body: some View`](../../Shared/Views/Chat/ChatItem/FullScreenMediaView.swift#L32)

### Shared/Views/Chat/ChatView.swift

- [`private func connectInProgressView(_ s: String) -> some View`](../../Shared/Views/Chat/ChatView.swift#L489)
- [`private func userMemberKnockingTitleBar() -> some View`](../../Shared/Views/Chat/ChatView.swift#L729)
- [`private func searchToolbar() -> some View`](../../Shared/Views/Chat/ChatView.swift#L864)

### Shared/Views/Chat/ComposeMessage/ComposeView.swift

- [`private func contextSendMessageToConnect(_ s: LocalizedStringKey) -> some View`](../../Shared/Views/Chat/ComposeMessage/ComposeView.swift#L1395)

### Shared/Views/Chat/ComposeMessage/ContextContactRequestActionsView.swift

- [`var body: some View`](../../Shared/Views/Chat/ComposeMessage/ContextContactRequestActionsView.swift#L19)

### Shared/Views/Chat/ComposeMessage/ContextMemberContactActionsView.swift

- [`var body: some View`](../../Shared/Views/Chat/ComposeMessage/ContextMemberContactActionsView.swift#L20)

### Shared/Views/Chat/ComposeMessage/ContextPendingMemberActionsView.swift

- [`var body: some View`](../../Shared/Views/Chat/ComposeMessage/ContextPendingMemberActionsView.swift#L19)

### Shared/Views/Chat/Group/GroupMemberInfoView.swift

- [`private func groupMemberInfoView() -> some View`](../../Shared/Views/Chat/Group/GroupMemberInfoView.swift#L104)
- [`func infoActionButtons(_ member: GroupMember) -> some View`](../../Shared/Views/Chat/Group/GroupMemberInfoView.swift#L368)

### Shared/Views/ChatList/ChatListNativeControls.swift

- [`@objc func clearText()`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L285)
- [`func updateUIView(_ button: UIButton, context: Context)`](../../Shared/Views/ChatList/ChatListNativeControls.swift#L302)

### Shared/Views/ChatList/ChatListView.swift

- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L88)
- [`var body: some View`](../../Shared/Views/ChatList/ChatListView.swift#L183)

### Shared/Views/ChatList/ContactConnectionInfo.swift

- [`var body: some View`](../../Shared/Views/ChatList/ContactConnectionInfo.swift#L35)

### Shared/Views/ChatList/OneHandUICard.swift

- [`var body: some View`](../../Shared/Views/ChatList/OneHandUICard.swift#L19)

### Shared/Views/ChatList/SunderGlassDesign.swift

- [`@objc private func choose(_ button: UIButton)`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L175)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L186)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L207)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L232)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/ChatList/SunderGlassDesign.swift#L245)

### Shared/Views/Helpers/AppSheet.swift

- [`func appSheet<Content>(`](../../Shared/Views/Helpers/AppSheet.swift#L33)
- [`func appSheet<T, Content>(`](../../Shared/Views/Helpers/AppSheet.swift#L43)
- [`func sunderPrivateSheet() -> some View`](../../Shared/Views/Helpers/AppSheet.swift#L56)

### Shared/Views/Helpers/ShareSheet.swift

- [`override func viewDidLoad()`](../../Shared/Views/Helpers/ShareSheet.swift#L186)

### Shared/Views/Helpers/SheetRepresentable.swift

- [`init(isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil, @ViewBuilder sheetContent: @escaping () -> SheetContent)`](../../Shared/Views/Helpers/SheetRepresentable.swift#L25)
- [`@ViewBuilder func body(content: Content) -> some View`](../../Shared/Views/Helpers/SheetRepresentable.swift#L31)

### Shared/Views/LocalAuth/PasscodeView.swift

- [`@ViewBuilder private func buttonsView() -> some View`](../../Shared/Views/LocalAuth/PasscodeView.swift#L73)

### Shared/Views/NewChat/NewChatMenuButton.swift

- [`var body: some View`](../../Shared/Views/NewChat/NewChatMenuButton.swift#L346)
- [`private func toggleFilterButton() -> some View`](../../Shared/Views/NewChat/NewChatMenuButton.swift#L399)

### Shared/Views/NewChat/NewChatView.swift

- [`var body: some View`](../../Shared/Views/NewChat/NewChatView.swift#L804)

### Shared/Views/Onboarding/ChooseServerOperators.swift

- [`@ViewBuilder func makeBody(configuration: Configuration) -> some View`](../../Shared/Views/Onboarding/ChooseServerOperators.swift#L20)

### Shared/Views/UserSettings/NetworkAndServers/ProtocolServerView.swift

- [`func body(content: Content) -> some View`](../../Shared/Views/UserSettings/NetworkAndServers/ProtocolServerView.swift#L184)

### SimpleX SE/ShareView.swift

- [`var body: some View`](../../SimpleX SE/ShareView.swift#L18)
- [`private func compose(isLoading: Bool) -> some View`](../../SimpleX SE/ShareView.swift#L88)

