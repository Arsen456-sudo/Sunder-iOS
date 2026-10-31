// Modified for Sunder on 2026-10-28: neutral resources and independent support.
//
//  ChatListView.swift
//  SimpleX
//
//  Created by Evgeny Poberezkin on 27/01/2022.
//  Copyright © 2022 SimpleX Chat. All rights reserved.
//
// Spec: spec/client/chat-list.md

import SwiftUI
import UIKit
import SimpleXChat

enum UserPickerSheet: Identifiable {
    case address
    case chatPreferences
    case chatProfiles
    case currentProfile
    case useFromDesktop
    case settings

    var id: Self { self }

    var navigationTitle: LocalizedStringKey {
        switch self {
        case .address: "SimpleX address"
        case .chatPreferences: "Your preferences"
        case .chatProfiles: "Your chat profiles"
        case .currentProfile: "Your current profile"
        case .useFromDesktop: "Connect to desktop"
        case .settings: "Your settings"
        }
    }
}

// Spec: spec/client/chat-list.md#PresetTag
enum PresetTag: Int, Identifiable, CaseIterable, Equatable {
    case groupReports = 0
    case favorites = 1
    case contacts = 2
    case groups = 3
    case channels = 4
    case business = 5
    case notes = 6

    var id: Int { rawValue }
    
    var сollapse: Bool {
        self != .groupReports
    }
}

// Spec: spec/client/chat-list.md#ActiveFilter
enum ActiveFilter: Identifiable, Equatable {
    case presetTag(PresetTag)
    case userTag(ChatTag)
    case unread
    
    var id: String {
        switch self {
        case let .presetTag(tag): "preset \(tag.id)"
        case let .userTag(tag): "user \(tag.chatTagId)"
        case .unread: "unread"
        }
    }
}

class SaveableSettings: ObservableObject {
    @Published var servers: ServerSettings = ServerSettings(currUserServers: [], userServers: [], serverErrors: [], serverWarnings: [])
    var profileSave: (() -> Void)? = nil
}

struct ServerSettings {
    public var currUserServers: [UserOperatorServers]
    public var userServers: [UserOperatorServers]
    public var serverErrors: [UserServersError]
    public var serverWarnings: [UserServersWarning]
}

struct UserPickerSheetView: View {
    let sheet: UserPickerSheet
    var rootTab = false
    @EnvironmentObject var chatModel: ChatModel
    @StateObject private var ss = SaveableSettings()

    @State private var loaded = false
    @State private var ownerUserId: Int64?

    var body: some View {
        NavigationView {
            ZStack {
                if loaded, let currentUser = chatModel.currentUser {
                    switch sheet {
                    case .address:
                        UserAddressView(shareViaProfile: currentUser.addressShared)
                    case .chatPreferences:
                        PreferencesView(
                            profile: currentUser.profile,
                            preferences: currentUser.fullPreferences,
                            currentPreferences: currentUser.fullPreferences
                        )
                    case .chatProfiles:
                        UserProfilesView()
                    case .currentProfile:
                        UserProfile().if(rootTab) { $0.modifier(SunderTabRootVisibility()) }
                    case .useFromDesktop:
                        ConnectDesktopView()
                    case .settings:
                        SettingsView().if(rootTab) { $0.modifier(SunderTabRootVisibility()) }
                    }
                }
                Color.clear // Required for list background to be rendered during loading
            }
            .navigationTitle(sheet.navigationTitle)
            .navigationBarTitleDisplayMode(.large)
            .modifier(ThemedBackground(grouped: true))
        }
        .overlay {
            if let la = chatModel.laRequest {
                LocalAuthView(authRequest: la)
            }
        }
        .task {
            ownerUserId = chatModel.currentUser?.userId
            withAnimation(
                .easeOut(duration: 0.1),
                { loaded = true }
            )
        }
        .onDisappear {
            guard ownerUserId == chatModel.currentUser?.userId else { return }
            if serversCanBeSaved(
                ss.servers.currUserServers,
                ss.servers.userServers,
                ss.servers.serverErrors
            ) {
                showAlert(
                    title: NSLocalizedString("Save servers?", comment: "alert title"),
                    buttonTitle: NSLocalizedString("Save", comment: "alert button"),
                    buttonAction: { saveServers($ss.servers.currUserServers, $ss.servers.userServers) },
                    cancelButton: true
                )
            }
            if let saveProfile = ss.profileSave {
                showAlert(
                    title: NSLocalizedString("Save your profile?", comment: "alert title"),
                    message: NSLocalizedString("Your profile was changed. If you save it, the updated profile will be sent to all your contacts.", comment: "alert message"),
                    buttonTitle: NSLocalizedString("Save (and notify contacts)", comment: "alert button"),
                    buttonAction: saveProfile,
                    cancelButton: true
                )
            }
        }
        .environmentObject(ss)
    }
}

// Spec: spec/client/chat-list.md#ChatListView
struct ChatListView: View {
    @EnvironmentObject var chatModel: ChatModel
    @StateObject private var connectProgressManager = ConnectProgressManager.shared
    @EnvironmentObject var theme: AppTheme
    @Binding var activeUserPickerSheet: UserPickerSheet?
    @State private var showNewChatSheet = false
    @State private var searchMode = false
    @FocusState private var searchFocussed
    @State private var searchText = ""
    @State private var searchShowingSimplexLink = false
    @State private var searchChatFilteredBySimplexLink: Set<String> = []
    @State private var scrollToSearchBar = false
    @State private var userPickerShown: Bool = false
    @State private var pendingUserPickerSheet: UserPickerSheet?
    @State private var sheet: SomeSheet<AnyView>? = nil
    @StateObject private var chatTagsModel = ChatTagsModel.shared
    @ObservedObject var navigation: SunderMainNavigation
    @State private var scrollToItemId: ChatItem.ID? = nil

    @State private var showServersSummary = false

    @AppStorage(GROUP_DEFAULT_ONE_HAND_UI, store: groupDefaults) private var legacyOneHandUI = true
    @AppStorage(DEFAULT_ONE_HAND_UI_CARD_SHOWN) private var oneHandUICardShown = false
    @AppStorage(DEFAULT_ADDRESS_CREATION_CARD_SHOWN) private var addressCreationCardShown = false
    
    private var oneHandUI: Bool {
        if #available(iOS 26.0, *) { return false }
        return legacyOneHandUI
    }

    // Spec: spec/client/chat-list.md#body
    var body: some View {
        if #available(iOS 16.0, *) {
            viewBody.scrollDismissesKeyboard(.immediately)
        } else {
            viewBody
        }
    }
    
    private var viewBody: some View {
        ZStack(alignment: oneHandUI ? .bottomLeading : .topLeading) {
            NavStackCompat(
                isActive: Binding(
                    get: { chatModel.chatId != nil },
                    set: { active in
                        if !active { chatModel.chatId = nil }
                    }
                ),
                destination: chatView
            ) { chatListView }
        }
        .modifier(
            Sheet(isPresented: $userPickerShown, onDismiss: {
                if let pending = pendingUserPickerSheet {
                    pendingUserPickerSheet = nil
                    activeUserPickerSheet = pending
                }
            }) {
                UserPicker(userPickerShown: $userPickerShown, activeSheet: Binding(
                    get: { activeUserPickerSheet },
                    set: { selected in
                        if #available(iOS 26.0, *), selected != nil {
                            pendingUserPickerSheet = selected
                            userPickerShown = false
                        } else {
                            activeUserPickerSheet = selected
                        }
                    }
                ))
            }
        )
        .appSheet(
            item: $activeUserPickerSheet,
            onDismiss: { chatModel.laRequest = nil },
            content: { UserPickerSheetView(sheet: $0) }
        )
        .appSheet(isPresented: $showNewChatSheet) {
            NewChatSheet()
                .environment(\EnvironmentValues.refresh as! WritableKeyPath<EnvironmentValues, RefreshAction?>, nil)
        }
        .appSheet(isPresented: $showServersSummary) {
            ServersSummaryView()
                .environment(\EnvironmentValues.refresh as! WritableKeyPath<EnvironmentValues, RefreshAction?>, nil)
        }
        .onChange(of: activeUserPickerSheet) {
            if $0 != nil {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    userPickerShown = false
                }
            }
        }
        .environmentObject(chatTagsModel)
    }
    
    private var chatListView: some View {
        withToolbar {
            chatList
                .safeAreaInset(edge: .top, spacing: 0) { pinnedControls }
                .modifier(SunderChatListEdges())
                .background(theme.colors.background)
                .navigationBarTitleDisplayMode(.inline)
                .scaleEffect(x: 1, y: oneHandUI ? -1 : 1, anchor: .center)
        }
        .onDisappear {
            activeUserPickerSheet = nil
        }
        .modifier(SunderTabRootVisibility())
        .background {
            if #available(iOS 26.0, *) {
                SunderNavigationSearch(active: $navigation.searchVisible, text: $searchText, focused: Binding(get: { searchFocussed }, set: { searchFocussed = $0 }),
                                       blocked: searchShowingSimplexLink, busy: connectProgressManager.showConnectProgress != nil)
                    .frame(width: 0, height: 0)
            }
        }
        .onChange(of: navigation.searchGeneration) { _ in searchFocussed = true }
        .onChange(of: chatModel.currentUser?.userId) { _ in
            navigation.searchVisible = false
            chatTagsModel.activeFilter = nil
        }
        .onChange(of: navigation.searchVisible) { visible in
            searchMode = visible
            searchFocussed = visible
            if !visible {
                searchText = ""
                searchShowingSimplexLink = false
                searchChatFilteredBySimplexLink = []
            }
        }
        .onAppear {
            if case .presetTag = chatTagsModel.activeFilter { chatTagsModel.activeFilter = nil }
        }
        .refreshable {
            AlertManager.shared.showAlert(Alert(
                title: Text("Reconnect servers?"),
                message: Text("Reconnect all connected servers to force message delivery. It uses additional traffic."),
                primaryButton: .default(Text("Ok")) {
                    Task {
                        do {
                            try await reconnectAllServers()
                        } catch let error {
                            AlertManager.shared.showAlertMsg(title: "Error", message: "\(responseError(error))")
                        }
                    }
                },
                secondaryButton: .cancel()
            ))
        }
        .sheet(item: $sheet) { sheet in
            if #available(iOS 16.0, *) {
                sheet.content.presentationDetents([.fraction(sheet.fraction)])
            } else {
                sheet.content
            }
        }
    }
    
    private var usesIntegratedSearch: Bool {
        if #available(iOS 26.0, *) { return true }
        return false
    }

    @ViewBuilder private var pinnedControls: some View {
        VStack(spacing: 4) {
            ChatListSearchBar(searchMode: $searchMode, searchFocussed: $searchFocussed,
                                  searchText: $searchText, searchShowingSimplexLink: $searchShowingSimplexLink,
                                  searchChatFilteredBySimplexLink: $searchChatFilteredBySimplexLink, parentSheet: $sheet,
                                  close: { navigation.searchVisible = false }, showsField: !usesIntegratedSearch && navigation.searchVisible)
            if !chatTagsModel.userTags.isEmpty {
                SunderFolderSegments(titles: [NSLocalizedString("All", comment: "All chats")] + chatTagsModel.userTags.map(\.chatTagText),
                                     selected: selectedFolder) { index in
                    guard index >= 0 && index <= chatTagsModel.userTags.count else { return }
                    searchText = ""
                    chatTagsModel.activeFilter = index == 0 ? nil : .userTag(chatTagsModel.userTags[index - 1])
                }
                .frame(height: 40)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, !chatTagsModel.userTags.isEmpty || (!usesIntegratedSearch && navigation.searchVisible) ? 4 : 0)
    }

    private var selectedFolder: Int {
        guard case let .userTag(tag) = chatTagsModel.activeFilter,
              let index = chatTagsModel.userTags.firstIndex(where: { $0.chatTagId == tag.chatTagId }) else { return 0 }
        return index + 1
    }

    @ViewBuilder private func withToolbar(content: () -> some View) -> some View {
        if oneHandUI {
            if #available(iOS 26.0, *) {
                content().navigationBarHidden(true).toolbar { glassBottomToolbar }
            } else {
                content().navigationBarHidden(true).toolbar { systemBottomToolbar }
            }
        } else if #available(iOS 26.0, *) {
            content().navigationBarHidden(false).toolbar { glassTopToolbar }
        } else {
            content().navigationBarHidden(false).toolbar { systemTopToolbar }
        }
    }

    @available(iOS 26.0, *)
    @ToolbarContentBuilder private var glassTopToolbar: some ToolbarContent {
        ToolbarItem(id: "sunder.leading", placement: .navigationBarLeading) {
            NavigationLink { TagListView().navigationTitle("Chat folders") } label: { Text("Change") }
                .foregroundColor(Color(uiColor: .label))
        }
        ToolbarItem(placement: .principal) { statusButton }
            .sharedBackgroundVisibility(.hidden)
        ToolbarItem(id: "sunder.context", placement: .navigationBarTrailing) {
            Button {
                chatTagsModel.activeFilter = chatTagsModel.activeFilter == .unread ? nil : .unread
            } label: { Image(systemName: "line.3.horizontal.decrease") }
                .tint(chatTagsModel.activeFilter == .unread ? .accentColor : .primary)
                .accessibilityLabel(Text("Unread"))
                .accessibilityIdentifier("sunder.context")
                .frame(width: 44, height: 44)
                .glassEffect(.regular.interactive(), in: Circle())
        }
        .sharedBackgroundVisibility(.hidden)
        ToolbarSpacer(.fixed, placement: .navigationBarTrailing)
        ToolbarItem(id: "sunder.avatar", placement: .navigationBarTrailing) { composeButton }

    }

    @available(iOS 26.0, *)
    @ToolbarContentBuilder private var glassBottomToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            profileButton
            Spacer()
            statusButton
            Spacer()
            composeButton
        }
        .sharedBackgroundVisibility(.hidden)
    }

    @ToolbarContentBuilder private var systemTopToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) { profileButton }
        ToolbarItem(placement: .principal) { statusButton }
        ToolbarItem(placement: .navigationBarTrailing) { composeButton }
    }

    @ToolbarContentBuilder private var systemBottomToolbar: some ToolbarContent {
        ToolbarItemGroup(placement: .bottomBar) {
            profileButton
            Spacer()
            statusButton
            Spacer()
            composeButton
        }
    }

    @ViewBuilder private var statusButton: some View {
        if !shouldShowOnboarding {
            ChatListStatusButton { showServersSummary = true }
        }
    }

    @ViewBuilder private var profileButton: some View {
        if #available(iOS 26.0, *) {
            SunderCircleButton(symbol: "person.crop.circle.fill", avatar: chatModel.currentUser?.image,
                               label: NSLocalizedString("Your profile", comment: "Profile toolbar button"),
                               unread: chatModel.users.contains { !$0.user.activeUser && !$0.user.hidden && $0.unreadCount > 0 },
                               action: { userPickerShown = true })
                .frame(width: 44, height: 44)
        } else {
            legacyProfileButton
        }
    }

    private var legacyProfileButton: some View {
        Button { userPickerShown = true } label: {
            ZStack(alignment: .topTrailing) {
                ProfileImage(imageStr: chatModel.currentUser?.image, size: 28)
                if chatModel.users.contains(where: { !$0.user.activeUser && !$0.user.hidden && $0.unreadCount > 0 }) {
                    Circle().fill(theme.colors.primary).frame(width: 8, height: 8)
                }
            }
        }
        .accessibilityLabel(Text("Your profile"))
    }

    @ViewBuilder private var composeButton: some View {
        switch chatModel.chatRunning {
        case .some(true):
            if #available(iOS 26.0, *) {
                Button {
                    ConnectProgressManager.shared.cancelConnectProgress()
                    showNewChatSheet = true
                } label: { Image(systemName: "square.and.pencil") }
                    .tint(.primary)
                    .accessibilityLabel(Text("New chat"))
                    .accessibilityIdentifier("sunder.avatar")
            } else {
                NewChatMenuButton(showNewChatSheet: $showNewChatSheet)
            }
        case .some(false): chatStoppedIcon()
        case .none: EmptyView()
        }
    }

    private var shouldShowOnboarding: Bool {
        !addressCreationCardShown && !chatModel.chats.isEmpty && !hasConversations
    }

    private var hasConversations: Bool {
        chatModel.chats.contains { chat in
            switch chat.chatInfo {
            case .local: return false
            case let .direct(contact): return !contact.chatDeleted && !contact.isContactCard
            case .group: return true
            case .contactRequest: return false
            case .contactConnection: return false
            case .invalidJSON: return false
            }
        }
    }

    @ViewBuilder private var chatList: some View {
        if shouldShowOnboarding {
            VStack(spacing: 0) {
                ConnectOnboardingView()
            }
            .scaleEffect(x: 1, y: oneHandUI ? -1 : 1, anchor: .center)
            .modifier(ThemedBackground())
        } else {
            chatListContent
        }
    }

    private var chatListContent: some View {
        let cs = filteredChats()
        return ZStack {
            ScrollViewReader { scrollProxy in
                List {
                    if #available(iOS 16.0, *) {
                        ForEach(cs, id: \.viewId) { chat in
                            ChatListNavLink(chat: chat, parentSheet: $sheet)
                                .scaleEffect(x: 1, y: oneHandUI ? -1 : 1, anchor: .center)
                                .listRowInsets(EdgeInsets(top: 4, leading: 12, bottom: 4, trailing: 8))
                                .disabled(chatModel.chatRunning != true || chatModel.deletedChats.contains(chat.chatInfo.id))
                                .listRowBackground(Color.clear)
                        }
                    } else {
                        ForEach(cs, id: \.viewId) { chat in
                            ChatListNavLink(chat: chat,  parentSheet: $sheet)
                            .scaleEffect(x: 1, y: oneHandUI ? -1 : 1, anchor: .center)
                            .listRowSeparator(.hidden)
                            .listRowInsets(EdgeInsets())
                            .background { theme.colors.background } // Hides default list selection colour
                            .disabled(chatModel.chatRunning != true || chatModel.deletedChats.contains(chat.chatInfo.id))
                        }
                    }
                    if !addressCreationCardShown && hasConversations {
                        ConnectBannerCard()
                            .padding(.vertical, 6)
                            .scaleEffect(x: 1, y: oneHandUI ? -1 : 1, anchor: .center)
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                }
                .listStyle(.plain)
                .onChange(of: chatModel.chatId) { currentChatId in
                    if let chatId = chatModel.chatToTop, currentChatId != chatId {
                        chatModel.chatToTop = nil
                        chatModel.popChat(chatId)
                    }
                    stopAudioPlayer()
                }
                .onChange(of: chatModel.currentUser?.userId) { _ in
                    stopAudioPlayer()
                }
                .onChange(of: scrollToSearchBar) { scrollToSearchBar in
                    if scrollToSearchBar {
                        Task { self.scrollToSearchBar = false }
                        withAnimation { scrollProxy.scrollTo("searchBar") }
                    }
                }
            }
            if cs.isEmpty && !chatModel.chats.isEmpty {
                noChatsView()
                    .scaleEffect(x: 1, y: oneHandUI ? -1 : 1, anchor: .center)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    @ViewBuilder private func noChatsView() -> some View {
        if searchString().isEmpty {
            switch chatTagsModel.activeFilter {
            case .presetTag: Text("No filtered chats") // this should not happen
            case let .userTag(tag): Text("No chats in list \(tag.chatTagText)")
            case .unread:
                Button {
                    chatTagsModel.activeFilter = nil
                } label: {
                    HStack {
                        Image(systemName: "line.3.horizontal.decrease")
                        Text("No unread chats")
                    }
                }
            case .none: Text("No chats")
            }
        } else {
            Text("No chats found")
        }
    }

    
    @ViewBuilder private func chatView() -> some View {
        if let chatId = chatModel.chatId, let chat = chatModel.getChat(chatId) {
            let im = ItemsModel.shared
            ChatView(
                chat: chat,
                im: im,
                mergedItems: BoxedValue(MergedItems.create(im, [])),
                floatingButtonModel: FloatingButtonModel(im: im),
                scrollToItemId: $scrollToItemId
            )
        }
    }
    
    // Spec: spec/client/chat-list.md#stopAudioPlayer
    func stopAudioPlayer() {
        VoiceItemState.smallView.values.forEach { $0.audioPlayer?.stop() }
        VoiceItemState.smallView = [:]
    }
    
    // Spec: spec/client/chat-list.md#filteredChats
    private func filteredChats() -> [Chat] {
        if !searchChatFilteredBySimplexLink.isEmpty {
            return chatModel.chats.filter { searchChatFilteredBySimplexLink.contains($0.id) }
        } else {
            let s = searchString()
            return s == ""
            ? chatModel.chats.filter { chat in
                !chat.chatInfo.chatDeleted && !chat.chatInfo.contactCard && filtered(chat)
            }
            : chatModel.chats.filter { chat in
                let cInfo = chat.chatInfo
                return switch cInfo {
                case let .direct(contact):
                    !contact.chatDeleted && !chat.chatInfo.contactCard && (
                        ( viewNameContains(cInfo, s) ||
                          contact.profile.displayName.localizedLowercase.contains(s) ||
                          contact.fullName.localizedLowercase.contains(s)
                        )
                    )
                case .group: viewNameContains(cInfo, s)
                case .local: viewNameContains(cInfo, s)
                case .contactRequest: viewNameContains(cInfo, s)
                case let .contactConnection(conn): conn.localAlias.localizedLowercase.contains(s)
                case .invalidJSON: false
                }
            }
        }
        
        func filtered(_ chat: Chat) -> Bool {
            switch chatTagsModel.activeFilter {
            case let .presetTag(tag): presetTagMatchesChat(tag, chat.chatInfo, chat.chatStats)
            case let .userTag(tag): chat.chatInfo.chatTags?.contains(tag.chatTagId) == true
            case .unread: chat.unreadTag
            case .none: true
            }
        }
        
        func viewNameContains(_ cInfo: ChatInfo, _ s: String) -> Bool {
            cInfo.chatViewName.localizedLowercase.contains(s)
        }
    }
    
    // Spec: spec/client/chat-list.md#searchString
    func searchString() -> String {
        searchShowingSimplexLink ? "" : searchText.trimmingCharacters(in: .whitespaces).localizedLowercase
    }
}

// Spec: spec/client/chat-list.md#ChatListSearchBar
struct ChatListSearchBar: View {
    @EnvironmentObject var m: ChatModel
    @EnvironmentObject var theme: AppTheme
    @EnvironmentObject var chatTagsModel: ChatTagsModel
    @StateObject private var connectProgressManager = ConnectProgressManager.shared
    @Binding var searchMode: Bool
    @FocusState.Binding var searchFocussed: Bool
    @Binding var searchText: String
    @Binding var searchShowingSimplexLink: Bool
    @Binding var searchChatFilteredBySimplexLink: Set<String>
    @Binding var parentSheet: SomeSheet<AnyView>?
    @AppStorage(GROUP_DEFAULT_ONE_HAND_UI, store: groupDefaults) private var oneHandUI = true
    @State private var ignoreSearchTextChange = false
    // when the search text is a SimpleX name, the string to connect to (with @/# preserved); nil otherwise
    @State private var connectNameCandidate: String? = nil
    @State private var nameSearchTask: Task<Void, Never>? = nil

    var close: () -> Void
    var showsField = true

    var body: some View {
        VStack(spacing: 8) {
            if showsField {
                HStack(spacing: 8) {
                    ChatListNativeSearch(text: $searchText,
                        focused: Binding(get: { searchFocussed }, set: { searchFocussed = $0 }),
                        linking: searchShowingSimplexLink, busy: connectProgressManager.showConnectProgress != nil,
                        tint: .label, allowsCancel: false)
                        .frame(height: 52)
                    SunderCircleButton(symbol: "xmark", label: NSLocalizedString("Close", comment: "Close search")) {
                        nameSearchTask?.cancel()
                        connectProgressManager.cancelConnectProgress()
                        searchText = ""
                        searchFocussed = false
                        close()
                    }.frame(width: 44, height: 44)
                }
            }
            if let candidate = connectNameCandidate {
                ConnectByNameRow(name: candidate, searchText: $searchText,
                                 connectNameCandidate: $connectNameCandidate,
                                 searchFocussed: $searchFocussed, dismiss: false)
            }
        }
        .onDisappear { nameSearchTask?.cancel() }
        .onChange(of: searchText) { t in
            if ignoreSearchTextChange {
                ignoreSearchTextChange = false
            } else {
                let s = t.trimmingCharacters(in: .whitespaces)
                switch strConnectTarget(s) {
                case let .link(text, _, linkText):
                    nameSearchTask?.cancel()
                    nameSearchTask = nil
                    searchFocussed = false
                    ignoreSearchTextChange = true
                    searchText = linkText
                    searchShowingSimplexLink = true
                    searchChatFilteredBySimplexLink = []
                    connectNameCandidate = nil
                    connect(text)
                default:
                    // not a link: a recognized SimpleX name shows the connect-by-name row (in place of the
                    // list tags) and, debounced, resolves locally per keystroke to narrow the list to the
                    // matching known chat(s); tapping the row connects online. Clear the filter immediately so
                    // the list falls back to text search until the search returns.
                    let candidate = nameSearchCandidate(s)
                    connectNameCandidate = candidate
                    searchShowingSimplexLink = false
                    searchChatFilteredBySimplexLink = []
                    nameSearchTask?.cancel()
                    nameSearchTask = nil
                    if let candidate = candidate {
                        nameSearchTask = Task { @MainActor in
                            try? await Task.sleep(nanoseconds: 300_000_000)
                            if Task.isCancelled { return }
                            // a bare name can be a contact or a channel: search both and keep every match
                            let targets = candidate.hasPrefix("@") || candidate.hasPrefix("#") ? [candidate] : ["@\(candidate)", "#\(candidate)"]
                            var ids: [String] = []
                            for name in targets {
                                let plan = await apiConnectPlan(connLink: name, resolveMode: .never, inProgress: BoxedValue(false))
                                if Task.isCancelled { return }
                                if let id = knownChatId(plan) { ids.append(id) }
                            }
                            searchChatFilteredBySimplexLink = Set(ids)
                            // drop the row only when every searched type is already known locally
                            if ids.count == targets.count { connectNameCandidate = nil }
                        }
                    } else if t != "" {
                        searchFocussed = true
                    } else {
                        ConnectProgressManager.shared.cancelConnectProgress()
                    }
                }
            }
        }
        .onChange(of: chatTagsModel.activeFilter) { _ in
            searchText = ""
        }
    }

    private func toggleFilterButton() -> some View {
        let showUnread = chatTagsModel.activeFilter == .unread
        return ChatListUnreadButton(selected: showUnread, tint: UIColor(theme.colors.primary)) {
            chatTagsModel.activeFilter = showUnread ? nil : .unread
        }
    }

    private func connect(_ link: String) {
        planAndConnect(
            link,
            theme: theme,
            dismiss: false,
            cleanup: {
                searchText = ""
                searchFocussed = false
            },
            filterKnownContact: { searchChatFilteredBySimplexLink = [$0.id] },
            filterKnownGroup: { searchChatFilteredBySimplexLink = [$0.id] }
        )
    }
}

// Row shown when the search text is a SimpleX name — in place of the list tags in the chat list, below
// the search field in the new chat sheet. The @ icon marks a contact name, the tag icon a channel/other
// name; tapping hides the keyboard, connects online, and clears the field.
struct ConnectByNameRow: View {
    @EnvironmentObject var theme: AppTheme
    var name: String
    @Binding var searchText: String
    @Binding var connectNameCandidate: String?
    @FocusState.Binding var searchFocussed: Bool
    var dismiss: Bool

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: name.hasPrefix("@") ? "at" : "number")
                .foregroundColor(theme.colors.primary)
            Text(String.localizedStringWithFormat(NSLocalizedString("Connect to %@", comment: "new chat action"), name))
                .foregroundColor(theme.colors.primary)
            Spacer()
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
            searchFocussed = false
            planAndConnect(
                name,
                theme: theme,
                dismiss: dismiss,
                cleanup: {
                    searchText = ""
                    connectNameCandidate = nil
                }
            )
        }
    }
}

// Default top-level part used to complete a bare name typed in the search field (search field only;
// the message parser and the wire format are unchanged).
private let DEFAULT_NAME_TLD = "testing"
// Shortest name that offers the button, so it is discoverable but does not flash on short prefixes.
private let MIN_NAME_LENGTH = 5

private func isNameLabel(_ s: String) -> Bool {
    s.count >= 1 && s.count <= 63 && s.range(of: "^[a-zA-Z0-9]+(-[a-zA-Z0-9]+)*$", options: .regularExpression) != nil
}

// On-device candidate for connecting by SimpleX name: the string sent to the core to resolve it.
// The chat id a local (.never) search resolved to — a contact, business, or channel — or nil on a miss.
// A name-resolved chat may be prepared in the store but not yet listed, so add it so the filter can surface it.
@MainActor
func knownChatId(_ result: ConnectionPlanResult?) -> String? {
    guard let plan = result?.connectionPlan else { return nil }
    let m = ChatModel.shared
    switch plan {
    case let .contactAddress(contactAddressPlan):
        if case let .known(contact) = contactAddressPlan {
            if m.getContactChat(contact.contactId) == nil {
                m.addChat(Chat(chatInfo: .direct(contact: contact), chatItems: []))
            }
            return contact.id
        }
        return nil
    case let .groupLink(groupLinkPlan):
        switch groupLinkPlan {
        case .known(let groupInfo), .ownLink(let groupInfo):
            if m.getGroupChat(groupInfo.groupId) == nil {
                m.addChat(Chat(chatInfo: .group(groupInfo: groupInfo, groupChatScope: nil), chatItems: []))
            }
            return groupInfo.id
        default:
            return nil
        }
    default:
        return nil
    }
}

// Mirrors the domain grammar (nameLabelP/mkDomain in SimplexName.hs): an optional @/# prefix, then
// dot-separated ASCII labels; a dotless word is completed with the default top-level part. Returns
// the string to send (keeping @/# so the type is preserved), or nil when the text is not a name.
func nameSearchCandidate(_ str: String) -> String? {
    let text = str.trimmingCharacters(in: .whitespaces)
    let prefix: Character? = text.first.flatMap { $0 == "@" || $0 == "#" ? $0 : nil }
    let core = prefix != nil ? String(text.dropFirst()) : text
    if core.isEmpty { return nil }
    let labels = core.split(separator: ".", omittingEmptySubsequences: false)
    if labels.contains(where: { !isNameLabel(String($0)) }) { return nil }
    if labels.count > 1 {
        return text                                            // already has a top-level part
    } else if core.count >= MIN_NAME_LENGTH {
        return "\(prefix.map(String.init) ?? "")\(core).\(DEFAULT_NAME_TLD)"
    } else {
        return nil
    }
}

struct TagsView: View {
    @EnvironmentObject var chatTagsModel: ChatTagsModel
    @EnvironmentObject var chatModel: ChatModel
    @EnvironmentObject var theme: AppTheme
    @Binding var parentSheet: SomeSheet<AnyView>?
    @Binding var searchText: String

    var body: some View {
        HStack {
            tagsView()
        }
    }
    
    @ViewBuilder private func tagsView() -> some View {
        if chatTagsModel.presetTags.count > 1 {
            if chatTagsModel.presetTags.count + chatTagsModel.userTags.count <= 3 {
                expandedPresetTagsFiltersView()
            } else {
                collapsedTagsFilterView()
                ForEach(PresetTag.allCases, id: \.id) { (tag: PresetTag) in
                    if !tag.сollapse && (chatTagsModel.presetTags[tag] ?? 0) > 0 {
                        expandedTagFilterView(tag)
                    }
                }
            }
        }
        let selectedTag: ChatTag? = if case let .userTag(tag) = chatTagsModel.activeFilter {
            tag
        } else {
            nil
        }
        ForEach(chatTagsModel.userTags, id: \.id) { tag in
            let current = tag == selectedTag
            Button { setActiveFilter(filter: .userTag(tag)) } label: {
                HStack(spacing: 4) {
                    if let emoji = tag.chatTagEmoji { Text(emoji) }
                    else { Image(systemName: "tag") }
                    Text(tag.chatTagText).fontWeight(current ? .semibold : .regular)
                    if (chatTagsModel.unreadTags[tag.chatTagId] ?? 0) > 0 {
                        Circle().fill(theme.colors.primary).frame(width: 6, height: 6)
                    }
                }
            }
            .buttonStyle(.bordered)
            .tint(current ? .accentColor : .secondary)
            .contextMenu {
                Button("Edit") { presentTagLists() }
            }
        }

        Button {
            parentSheet = SomeSheet(
                content: {
                    AnyView(
                        NavigationView {
                            TagListEditor()
                        }
                    )
                },
                id: "tag create"
            )
        } label: {
            if chatTagsModel.userTags.isEmpty {
                HStack(spacing: 4) {
                    Image(systemName: "plus")
                    Text("Add list")
                }
            } else {
                Image(systemName: "plus")
            }
        }
        .buttonStyle(.bordered)
        .tint(.secondary)
    }

    @ViewBuilder private func expandedTagFilterView(_ tag: PresetTag) -> some View {
        let selectedPresetTag: PresetTag? = if case let .presetTag(tag) = chatTagsModel.activeFilter {
            tag
        } else {
            nil
        }
        let active = tag == selectedPresetTag
        let (icon, menuIcon, text) = presetTagLabel(tag: tag, active: active)
        let color: Color = active ? .accentColor : .secondary

        Button { setActiveFilter(filter: .presetTag(tag)) } label: {
            HStack {
                Image(systemName: menuIcon ?? icon)
                Text(text).fontWeight(active ? .semibold : .regular)
            }
        }
        .buttonStyle(.bordered)
        .tint(color)
    }

    private func expandedPresetTagsFiltersView() -> some View {
        ForEach(PresetTag.allCases, id: \.id) { tag in
            if (chatTagsModel.presetTags[tag] ?? 0) > 0 {
                expandedTagFilterView(tag)
            }
        }
    }
    
    @ViewBuilder private func collapsedTagsFilterView() -> some View {
        let selectedPresetTag: PresetTag? = if case let .presetTag(tag) = chatTagsModel.activeFilter {
            tag
        } else {
            nil
        }
        Menu {
            if chatTagsModel.activeFilter != nil || !searchText.isEmpty {
                Button {
                    chatTagsModel.activeFilter = nil
                    searchText = ""
                } label: {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("All")
                    }
                }
            }
            ForEach(PresetTag.allCases, id: \.id) { tag in
                if (chatTagsModel.presetTags[tag] ?? 0) > 0 && tag.сollapse {
                    Button {
                        setActiveFilter(filter: .presetTag(tag))
                    } label: {
                        let (icon, _, text) = presetTagLabel(tag: tag, active: tag == selectedPresetTag)
                        HStack {
                            Image(systemName: icon)
                            Text(text)
                        }
                    }
                }
            }
        } label: {
            if let tag = selectedPresetTag, tag.сollapse {
                let (icon, menuIcon, _) = presetTagLabel(tag: tag, active: true)
                Image(systemName: menuIcon ?? icon)
                    .foregroundColor(.accentColor)
            } else {
                Image(systemName: "list.bullet")
                    .foregroundColor(.secondary)
            }
        }
        .buttonStyle(.bordered)
    }
    
    private func presentTagLists() {
        let reservedSpace: Double = 4 * 44
        let tagsSpace = Double(max(chatTagsModel.userTags.count, 3)) * 44
        let fraction = min((reservedSpace + tagsSpace) / UIScreen.main.bounds.height, 0.62)
        parentSheet = SomeSheet(
            content: {
                AnyView(NavigationView {
                    TagListView(chat: nil).modifier(ThemedBackground(grouped: true))
                })
            },
            id: "tag list",
            fraction: fraction
        )
    }

    private func presetTagLabel(tag: PresetTag, active: Bool) -> (item: String, menu: String?, label: LocalizedStringKey) {
        switch tag {
        case .groupReports: (item: active ? "flag.fill" : "flag", menu: nil, label: "Reports")
        case .favorites: (item: active ? "star.fill" : "star", menu: nil, label: "Favorites")
        case .contacts: (item: active ? "person.fill" : "person", menu: nil, label: "Contacts")
        case .groups: (item: active ? "person.2.fill" : "person.2", menu: nil, label: "Groups")
        case .channels: (item: active ? "antenna.radiowaves.left.and.right.circle.fill" : "antenna.radiowaves.left.and.right", menu: "antenna.radiowaves.left.and.right", label: "Channels")
        case .business: (item: active ? "briefcase.fill" : "briefcase", menu: nil, label: "Businesses")
        case .notes: (item: active ? "folder.fill" : "folder", menu: nil, label: "Notes")
        }
    }

    // Spec: spec/client/chat-list.md#setActiveFilter
    private func setActiveFilter(filter: ActiveFilter) {
        if filter != chatTagsModel.activeFilter {
            chatTagsModel.activeFilter = filter
        } else {
            chatTagsModel.activeFilter = nil
        }
    }
}

func chatStoppedIcon() -> some View {
    Button {
        AlertManager.shared.showAlertMsg(
            title: "Chat is stopped",
            message: "You can start chat via app Settings / Database or by restarting the app"
        )
    } label: {
        Image(systemName: "exclamationmark.octagon.fill").foregroundColor(.red)
    }
}

// Spec: spec/client/chat-list.md#presetTagMatchesChat
func presetTagMatchesChat(_ tag: PresetTag, _ chatInfo: ChatInfo, _ chatStats: ChatStats) -> Bool {
    switch tag {
    case .groupReports:
        chatStats.reportsCount > 0
    case .favorites:
        chatInfo.chatSettings?.favorite == true
    case .contacts:
        switch chatInfo {
        case let .direct(contact): !contact.isContactCard && !contact.chatDeleted
        case .contactRequest: true
        case .contactConnection: true
        case let .group(groupInfo, _): groupInfo.businessChat?.chatType == .customer
        default: false
        }
    case .groups:
        switch chatInfo {
        case let .group(groupInfo, _): groupInfo.businessChat == nil && !groupInfo.isChannel
        default: false
        }
    case .channels:
        switch chatInfo {
        case let .group(groupInfo, _): groupInfo.isChannel
        default: false
        }
    case .business:
        chatInfo.groupInfo?.businessChat?.chatType == .business
    case .notes:
        switch chatInfo {
        case .local: true
        default: false
        }
    }
}

struct ChatListView_Previews: PreviewProvider {
    @State static var userPickerSheet: UserPickerSheet? = .none

    static var previews: some View {
        let chatModel = ChatModel()
        chatModel.updateChats([
            ChatData(
                chatInfo: ChatInfo.sampleData.direct,
                chatItems: [ChatItem.getSample(1, .directSnd, .now, "hello")]
            ),
            ChatData(
                chatInfo: ChatInfo.sampleData.group,
                chatItems: [ChatItem.getSample(1, .directSnd, .now, "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.")]
            ),
            ChatData(
                chatInfo: ChatInfo.sampleData.contactRequest,
                chatItems: []
            )

        ])
        return Group {
            ChatListView(activeUserPickerSheet: $userPickerSheet, navigation: SunderMainNavigation())
                .environmentObject(chatModel)
            ChatListView(activeUserPickerSheet: $userPickerSheet, navigation: SunderMainNavigation())
                .environmentObject(ChatModel())
        }
    }
}
