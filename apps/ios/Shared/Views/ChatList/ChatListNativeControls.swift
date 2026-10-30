// Sunder: standard Apple controls with existing chat-list bindings.
import SwiftUI
import UIKit
import SimpleXChat

// UIKit owns search-field metrics, clear/cancel controls and accessibility.
struct ChatListNativeSearch: UIViewRepresentable {
    @Binding var text: String
    @Binding var focused: Bool
    var linking: Bool
    var busy: Bool
    var tint: UIColor
    var placeholder = NSLocalizedString("Search or paste SimpleX link", comment: "Search placeholder")
    var onCancel: (() -> Void)? = nil

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UISearchBar {
        let bar = UISearchBar()
        context.coordinator.searchIcon = bar.searchTextField.leftView
        bar.searchBarStyle = .minimal
        bar.autocapitalizationType = .none
        bar.autocorrectionType = .no
        bar.delegate = context.coordinator
        bar.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        return bar
    }

    func updateUIView(_ bar: UISearchBar, context: Context) {
        context.coordinator.parent = self
        if bar.text != text { bar.text = text }
        bar.placeholder = placeholder
        bar.tintColor = tint
        bar.isUserInteractionEnabled = !linking
        bar.setShowsCancelButton(focused && !linking, animated: !UIAccessibility.isReduceMotionEnabled)
        let field = bar.searchTextField
        if busy {
            context.coordinator.spinner.startAnimating()
            field.leftView = context.coordinator.spinner
        } else {
            context.coordinator.spinner.stopAnimating()
            field.leftView = context.coordinator.searchIcon
        }
        // Focus changes must occur after SwiftUI's update, including initial presentation.
        let requestedFocus = focused && !linking
        DispatchQueue.main.async { [weak bar, weak coordinator = context.coordinator] in
            guard let bar, let coordinator,
                  requestedFocus == (coordinator.parent.focused && !coordinator.parent.linking) else { return }
            if requestedFocus && bar.window != nil && !bar.isFirstResponder { bar.becomeFirstResponder() }
            else if !requestedFocus && bar.isFirstResponder { bar.resignFirstResponder() }
        }
    }

    static func dismantleUIView(_ bar: UISearchBar, coordinator: Coordinator) {
        bar.delegate = nil
        bar.resignFirstResponder()
    }

    class Coordinator: NSObject, UISearchBarDelegate {
        var parent: ChatListNativeSearch
        let spinner = UIActivityIndicatorView(style: .medium)
        var searchIcon: UIView?

        init(_ parent: ChatListNativeSearch) {
            self.parent = parent
        }

        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
            parent.text = searchText
        }
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { parent.focused = true }
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { parent.focused = false }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            parent.text = ""
            parent.focused = false
            searchBar.resignFirstResponder()
            parent.onCancel?()
        }
    }
}

struct SunderCircleButton: UIViewRepresentable {
    var symbol: String
    var avatar: String? = nil
    var label: String
    var selected = false
    var unread = false
    var action: () -> Void
    @Environment(\.isEnabled) private var enabled

    func makeCoordinator() -> Coordinator { Coordinator(action) }

    func makeUIView(context: Context) -> UIButton {
        let button = CircleControl(frame: .zero)
        button.addTarget(context.coordinator, action: #selector(Coordinator.activate), for: .touchUpInside)
        button.setContentHuggingPriority(.required, for: .horizontal)
        button.setContentHuggingPriority(.required, for: .vertical)
        return button
    }

    func updateUIView(_ button: UIButton, context: Context) {
        context.coordinator.action = action
        var config: UIButton.Configuration
        if #available(iOS 26.0, *) {
            config = selected ? .prominentGlass() : .glass()
        } else {
            config = selected ? .filled() : .gray()
        }
        config.cornerStyle = .capsule
        config.contentInsets = .zero
        config.baseForegroundColor = selected ? .white : .label
        config.image = context.coordinator.avatarImage(avatar, unread: unread) ?? UIImage(systemName: symbol,
            withConfiguration: UIImage.SymbolConfiguration(pointSize: 20, weight: .regular))
        if avatar == nil {
            let foreground: UIColor = selected ? .white : .label
            config.imageColorTransformer = UIConfigurationColorTransformer { _ in foreground }
        }
        button.configuration = config
        if let marker = button.viewWithTag(991) { marker.isHidden = !unread }
        else {
            let marker = UIView()
            marker.tag = 991
            marker.backgroundColor = .systemBlue
            marker.layer.cornerRadius = 3.5
            marker.isUserInteractionEnabled = false
            marker.isHidden = !unread
            marker.translatesAutoresizingMaskIntoConstraints = false
            button.addSubview(marker)
            NSLayoutConstraint.activate([
                marker.widthAnchor.constraint(equalToConstant: 7),
                marker.heightAnchor.constraint(equalToConstant: 7),
                marker.topAnchor.constraint(equalTo: button.topAnchor, constant: 7),
                marker.trailingAnchor.constraint(equalTo: button.trailingAnchor, constant: -7)
            ])
        }
        button.isEnabled = enabled
        button.accessibilityLabel = label
        button.accessibilityValue = unread ? NSLocalizedString("Unread", comment: "Unread chats") : nil
        button.accessibilityTraits = selected ? [.button, .selected] : .button
    }

    class CircleControl: UIButton {
        override var intrinsicContentSize: CGSize { CGSize(width: 44, height: 44) }
    }

    class Coordinator: NSObject {
        var action: () -> Void
        init(_ action: @escaping () -> Void) { self.action = action }
        private var imageSource: String?
        private var imageUnread = false
        private var image: UIImage?

        func avatarImage(_ source: String?, unread: Bool) -> UIImage? {
            guard let source else { imageSource = nil; image = nil; return nil }
            if source != imageSource || unread != imageUnread {
                imageSource = source
                imageUnread = unread
                guard let original = imageFromBase64(source), original.size.width > 0, original.size.height > 0 else { image = nil; return nil }
                image = UIGraphicsImageRenderer(size: CGSize(width: 28, height: 28)).image { context in
                    context.cgContext.saveGState()
                    UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: 28, height: 28)).addClip()
                    let scale = max(28 / original.size.width, 28 / original.size.height)
                    let size = CGSize(width: original.size.width * scale, height: original.size.height * scale)
                    original.draw(in: CGRect(x: (28 - size.width) / 2, y: (28 - size.height) / 2, width: size.width, height: size.height))
                    context.cgContext.restoreGState()
                }.withRenderingMode(.alwaysOriginal)
            }
            return image
        }

        @objc func activate() { action() }
    }
}

struct ChatListUnreadButton: View {
    var selected: Bool
    var tint: UIColor
    var label = NSLocalizedString("Unread", comment: "Unread chats filter")
    var action: () -> Void

    var body: some View {
        SunderCircleButton(symbol: "line.3.horizontal.decrease", label: label,
                           selected: selected, action: action)
            .frame(width: 44, height: 44)
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
