// Sunder: standard Apple controls with existing chat-list bindings.
import SwiftUI
import UIKit
import SimpleXChat

struct ChatListNativeSearch: View {
    @Binding var text: String
    @Binding var focused: Bool
    var linking: Bool
    var busy: Bool
    var tint: UIColor
    @FocusState private var editing: Bool

    var body: some View {
        HStack {
            TextField("Search or paste SimpleX link", text: $text)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .disableAutocorrection(true)
                .focused($editing)
                .disabled(linking)
            if busy { ProgressView() }
            if !text.isEmpty {
                Button { text = "" } label: { Image(systemName: "xmark.circle.fill") }
                    .accessibilityLabel(Text("Clear"))
            }
            if focused {
                Button("Cancel") { text = ""; focused = false; editing = false }
            }
        }
        .tint(Color(tint))
        .onAppear { editing = focused && !linking }
        .onChange(of: focused) { editing = $0 && !linking }
        .onChange(of: editing) { focused = $0 }
        .onChange(of: linking) { if $0 { editing = false } }
    }
}

struct ChatListUnreadButton: View {
    var selected: Bool
    var tint: UIColor
    var label = NSLocalizedString("Unread", comment: "Unread chats filter")
    var action: () -> Void

    var body: some View {
        let button = Button(action: action) {
            Image(systemName: "line.3.horizontal.decrease")
        }
        .accessibilityLabel(Text(label))
        .accessibilityAddTraits(selected ? .isSelected : [])
        Group {
            if selected { button.buttonStyle(.borderedProminent) }
            else { button.buttonStyle(.bordered) }
        }
        .tint(Color(tint))
    }
}

struct ChatListStatusButton: View {
    @EnvironmentObject var model: ChatModel
    @State private var subs = SMPServerSubs.newSMPServerSubs
    @State private var hasSession = false
    @AppStorage(DEFAULT_SHOW_SUBSCRIPTION_PERCENTAGE) private var showPercentage = false
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Text("Chats").font(.headline).foregroundStyle(.primary)
                SubscriptionStatusIndicatorView(subs: subs, hasSess: hasSession)
                if showPercentage { SubscriptionStatusPercentageView(subs: subs, hasSess: hasSession) }
            }
        }
        .disabled(model.chatRunning != true)
        .task(id: model.currentUser?.userId) {
            while !Task.isCancelled {
                if AppChatState.shared.value == .active, model.chatRunning == true {
                    do {
                        let result = try await getAgentSubsTotal()
                        guard !Task.isCancelled else { return }
                        subs = result.0
                        hasSession = result.1
                    } catch {
                        if !Task.isCancelled { logger.error("Chat-list subscription status unavailable") }
                    }
                }
                do { try await Task.sleep(nanoseconds: 1_000_000_000) } catch { return }
            }
        }
    }
}
