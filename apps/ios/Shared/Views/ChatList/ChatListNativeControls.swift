// Sunder, 2026-10-29. Bind existing chat-list state to native controls.
import SwiftUI
import UIKit
import SimpleXChat

@MainActor final class ChatListChromeScope: ObservableObject {
    weak var controller: ChatListChromeController?
    weak var scrollView: UIScrollView?

    func bind() {
        if let scrollView, scrollView.window != nil { controller?.bindScrollView(scrollView) }
    }
}

struct ChatListNativeChrome: UIViewControllerRepresentable {
    var floating: Bool
    var avatar: String?
    var unreadProfiles: Bool
    var running: Bool?
    var showsStatus: Bool
    var primary: Color
    var online: Bool
    var scope: ChatListChromeScope
    var profileAction: () -> Void
    var composeAction: () -> Void
    var statusAction: () -> Void
    var searchAction: () -> Void
    @Environment(\.colorScheme) private var colorScheme
    @AppStorage(DEFAULT_SHOW_SUBSCRIPTION_PERCENTAGE) private var showPercentage = false

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> ChatListChromeController {
        let controller = ChatListChromeController(floating: floating)
        scope.controller?.unbindScrollView()
        scope.controller = controller
        context.coordinator.controller = controller
        controller.visibilityChanged = { [weak coordinator = context.coordinator] visible in
            if visible { coordinator?.start() } else { coordinator?.stop() }
        }
        return controller
    }

    func updateUIViewController(_ controller: ChatListChromeController, context: Context) {
        context.coordinator.parent = self
        controller.profileAction = profileAction
        controller.composeAction = composeAction
        controller.statusAction = statusAction
        controller.searchAction = searchAction
        context.coordinator.render()
        scope.bind()
    }

    static func dismantleUIViewController(_ controller: ChatListChromeController, coordinator: Coordinator) {
        coordinator.stop()
        controller.unbindScrollView()
        controller.visibilityChanged = nil
    }

    @MainActor final class Coordinator {
        var parent: ChatListNativeChrome
        weak var controller: ChatListChromeController?
        private var task: Task<Void, Never>?
        private var subs = SMPServerSubs.newSMPServerSubs
        private var hasSession = false
        private var avatarSource: String?
        private var avatarImage: UIImage?

        init(_ parent: ChatListNativeChrome) { self.parent = parent }

        func render() {
            if avatarSource != parent.avatar {
                avatarSource = parent.avatar
                avatarImage = imageFromBase64(parent.avatar).map { image in
                    let size = CGSize(width: 32, height: 32)
                    return UIGraphicsImageRenderer(size: size).image { context in
                        context.cgContext.addEllipse(in: CGRect(origin: .zero, size: size))
                        context.cgContext.clip()
                        let scale = max(size.width / max(image.size.width, 1), size.height / max(image.size.height, 1))
                        let drawn = CGSize(width: image.size.width * scale, height: image.size.height * scale)
                        image.draw(in: CGRect(x: (32 - drawn.width) / 2, y: (32 - drawn.height) / 2,
                                              width: drawn.width, height: drawn.height))
                    }
                }
            }
            let usesProxy = networkUseOnionHostsGroupDefault.get() != .no
                || groupDefaults.string(forKey: GROUP_DEFAULT_NETWORK_SOCKS_PROXY) != nil
            let (color, variableValue, opacity) = subscriptionStatusInfo(
                online: parent.online, usesProxy: usesProxy, subs: subs,
                hasSess: hasSession, primaryColor: parent.primary
            )
            let statusImage: UIImage?
            let statusColor: UIColor
            if #available(iOS 16.0, *) {
                statusImage = UIImage(systemName: "dot.radiowaves.up.forward", variableValue: variableValue)
                statusColor = UIColor(color)
            } else {
                statusImage = UIImage(systemName: "dot.radiowaves.up.forward")
                statusColor = UIColor(color.opacity(opacity))
            }
            let percent = subscriptionStatusPercent(online: parent.online, subs: subs, hasSess: hasSession)
            let percentage = parent.showPercentage
                ? (subs.total > 0 || hasSession ? "\(Int(floor(percent * 100)))%" : "%") : nil
            controller?.update(ChatListChromeState(
                avatar: avatarImage, unreadProfiles: parent.unreadProfiles,
                title: NSLocalizedString("Chats", comment: "Chat-list title"), statusImage: statusImage,
                statusColor: statusColor, percentage: percentage,
                showsStatus: parent.showsStatus, running: parent.running, tint: UIColor(parent.primary),
                interfaceStyle: parent.colorScheme == .dark ? .dark : .light
            ))
        }

        func start() {
            guard task == nil else { return }
            parent.scope.bind()
            task = Task { @MainActor [weak self] in
                while !Task.isCancelled {
                    guard let self else { return }
                    if AppChatState.shared.value == .active, self.parent.running == true, self.parent.showsStatus {
                        do {
                            let (subs, hasSession) = try await getAgentSubsTotal()
                            guard !Task.isCancelled else { return }
                            self.subs = subs
                            self.hasSession = hasSession
                            self.render()
                        } catch {
                            if !Task.isCancelled { logger.error("Chat-list subscription status unavailable") }
                        }
                    }
                    do { try await Task.sleep(nanoseconds: 1_000_000_000) } catch { return }
                }
            }
        }

        func stop() {
            task?.cancel()
            task = nil
        }
    }
}

struct ChatListScrollProbe: UIViewRepresentable {
    let scope: ChatListChromeScope

    func makeUIView(context: Context) -> Probe { Probe(scope: scope) }
    func updateUIView(_ view: Probe, context: Context) { view.resolve() }

    final class Probe: UIView {
        private weak var scope: ChatListChromeScope?
        private var resolutionPending = false

        init(scope: ChatListChromeScope) {
            self.scope = scope
            super.init(frame: .zero)
            isUserInteractionEnabled = false
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("Programmatic view") }

        override func didMoveToWindow() { super.didMoveToWindow(); resolve() }
        override func layoutSubviews() { super.layoutSubviews(); resolve() }

        func resolve() {
            guard #available(iOS 26.0, *) else { return }
            guard window != nil, !resolutionPending else { return }
            if let scrollView = scope?.scrollView, scrollView.window === window {
                scope?.bind()
                return
            }
            resolutionPending = true
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.resolutionPending = false
                guard let window = self.window, self.bounds.height > 100 else { return }
                let rect = self.convert(self.bounds, to: window)
                var ancestor = self.superview
                // Stop within the local SwiftUI list hierarchy, never search the window.
                for _ in 0..<8 {
                    guard let root = ancestor, !(root is UIWindow) else { return }
                    if let scrollView = self.findList(in: root, rect: rect, window: window) {
                        self.scope?.scrollView = scrollView
                        self.scope?.bind()
                        return
                    }
                    ancestor = root.superview
                }
            }
        }

        private func findList(in root: UIView, rect: CGRect, window: UIWindow) -> UIScrollView? {
            guard !root.isHidden, root.alpha > 0, root.window === window else { return nil }
            if let scrollView = root as? UIScrollView,
               scrollView is UITableView || scrollView is UICollectionView {
                let intersection = scrollView.convert(scrollView.bounds, to: window).intersection(rect)
                return intersection.width * intersection.height >= rect.width * rect.height * 0.75
                    ? scrollView : nil
            }
            for child in root.subviews {
                if let match = findList(in: child, rect: rect, window: window) { return match }
            }
            return nil
        }
    }
}

struct ChatListNativeSearch: UIViewRepresentable {
    @Binding var text: String
    @Binding var focused: Bool
    var linking: Bool
    var busy: Bool
    var tint: UIColor
    @Environment(\.colorScheme) private var colorScheme

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> UISearchBar {
        let search = UISearchBar()
        search.searchBarStyle = .minimal
        search.placeholder = NSLocalizedString("Search or paste SimpleX link", comment: "Chat-list search")
        search.delegate = context.coordinator
        search.autocapitalizationType = .none
        search.autocorrectionType = .no
        search.searchTextField.clearButtonMode = .never
        let controls = UIStackView(arrangedSubviews: [context.coordinator.spinner, context.coordinator.clear])
        controls.spacing = 6
        controls.alignment = .center
        search.searchTextField.rightView = controls
        search.searchTextField.rightViewMode = .always
        context.coordinator.clear.addTarget(context.coordinator, action: #selector(Coordinator.clearText), for: .touchUpInside)
        return search
    }

    func updateUIView(_ search: UISearchBar, context: Context) {
        let coordinator = context.coordinator
        coordinator.parent = self
        coordinator.search = search
        search.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        search.searchTextField.textColor = linking ? .secondaryLabel : .label
        search.tintColor = tint
        if search.text != text { search.text = text }
        search.setShowsCancelButton(focused, animated: !UIAccessibility.isReduceMotionEnabled)
        coordinator.clear.isHidden = text.isEmpty
        coordinator.spinner.isHidden = !busy
        if busy { coordinator.spinner.startAnimating() } else { coordinator.spinner.stopAnimating() }
        let width: CGFloat = (busy ? 20 : 0) + (text.isEmpty ? 0 : 24) + (busy && !text.isEmpty ? 6 : 0)
        search.searchTextField.rightView?.frame.size = CGSize(width: width, height: 28)
        if focused != search.searchTextField.isFirstResponder {
            DispatchQueue.main.async { [weak search, weak coordinator] in
                guard let search, let coordinator, search.window != nil else { return }
                if coordinator.parent.focused && !coordinator.parent.linking { search.searchTextField.becomeFirstResponder() }
                else { search.searchTextField.resignFirstResponder() }
            }
        }
    }

    @MainActor final class Coordinator: NSObject, UISearchBarDelegate {
        var parent: ChatListNativeSearch
        weak var search: UISearchBar?
        let spinner = UIActivityIndicatorView(style: .medium)
        let clear = UIButton(type: .system)

        init(_ parent: ChatListNativeSearch) {
            self.parent = parent
            super.init()
            clear.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
            clear.tintColor = .secondaryLabel
            clear.accessibilityLabel = NSLocalizedString("Clear", comment: "Clear chat-list search")
            let clearWidth = clear.widthAnchor.constraint(equalToConstant: 24)
            clearWidth.priority = UILayoutPriority(999)
            clearWidth.isActive = true
            clear.heightAnchor.constraint(equalToConstant: 28).isActive = true
        }

        func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool { !parent.linking }
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { if !parent.focused { parent.focused = true } }
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { if parent.focused { parent.focused = false } }
        func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) { parent.text = searchText }
        func searchBarSearchButtonClicked(_ searchBar: UISearchBar) { searchBar.searchTextField.resignFirstResponder() }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            parent.text = ""
            parent.focused = false
            searchBar.searchTextField.resignFirstResponder()
        }
        @objc func clearText() { search?.text = ""; parent.text = "" }
    }
}

struct ChatListUnreadButton: UIViewRepresentable {
    var selected: Bool
    var tint: UIColor
    var action: () -> Void
    @Environment(\.colorScheme) private var colorScheme

    func makeCoordinator() -> Coordinator { Coordinator(action) }
    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.addTarget(context.coordinator, action: #selector(Coordinator.tap), for: .touchUpInside)
        return button
    }
    func updateUIView(_ button: UIButton, context: Context) {
        context.coordinator.action = action
        var config: UIButton.Configuration
        if #available(iOS 26.0, *) { config = selected ? .prominentGlass() : .glass() }
        else { config = .gray() }
        config.image = UIImage(systemName: "line.3.horizontal.decrease")
        config.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 19)
        config.baseForegroundColor = selected ? tint : .secondaryLabel
        config.baseBackgroundColor = selected ? tint : nil
        config.cornerStyle = .capsule
        button.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        button.configuration = config
        button.isSelected = selected
        button.accessibilityLabel = NSLocalizedString("Unread", comment: "Unread chats filter")
        button.accessibilityTraits = selected ? [.button, .selected] : .button
    }
    @MainActor final class Coordinator: NSObject {
        var action: () -> Void
        init(_ action: @escaping () -> Void) { self.action = action }
        @objc func tap() { action() }
    }
}
