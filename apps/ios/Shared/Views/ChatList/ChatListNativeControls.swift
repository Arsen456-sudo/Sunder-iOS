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
    var allowsCancel = true

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
        bar.setShowsCancelButton(allowsCancel && focused && !linking, animated: !UIAccessibility.isReduceMotionEnabled)
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
        button.contentHorizontalAlignment = .center
        button.contentVerticalAlignment = .center
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
        override func layoutSubviews() {
            super.layoutSubviews()
            guard let imageView else { return }
            let side: CGFloat = configuration?.image?.renderingMode == .alwaysOriginal ? 28 : 24
            imageView.contentMode = .scaleAspectFit
            imageView.bounds = CGRect(x: 0, y: 0, width: side, height: side)
            imageView.center = CGPoint(x: bounds.midX, y: bounds.midY)
        }
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

final class SunderMainNavigation: ObservableObject {
    @Published var selected = 0
    @Published var searchVisible = false
    @Published var savingFolder = false
    @Published var searchGeneration = 0
    @Published var hiddenRoots: [Int: Bool] = [:]
}

private final class SunderTabsController: UITabBarController {
    var bottomEdgeEnabled = true
    private weak var registeredRoot: UIViewController?
    private weak var registeredScroll: UIScrollView?
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        refreshBottomEdge()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        refreshBottomEdge()
    }
    func refreshBottomEdge() {
        guard #available(iOS 26.0, *) else { return }
        guard bottomEdgeEnabled, !tabBar.isHidden, let root = selectedViewController,
              root.isViewLoaded, root.view.window != nil else {
            clearBottomEdge()
            return
        }
        if registeredRoot !== root { clearBottomEdge() }
        if let scroll = registeredScroll, scroll.window != nil, !scroll.isHidden,
           scroll.isDescendant(of: root.view) { return }
        var candidates: [UIScrollView] = []
        func collect(_ view: UIView) {
            guard !view.isHidden, view.alpha > 0.01 else { return }
            if let scroll = view as? UIScrollView,
               scroll.bounds.width >= root.view.bounds.width * 0.5,
               scroll.bounds.height > 100,
               scroll.contentSize.width <= scroll.bounds.width + 1 {
                candidates.append(scroll)
            }
            for child in view.subviews { collect(child) }
        }
        collect(root.view)
        guard let scroll = candidates.max(by: {
            $0.bounds.width * $0.bounds.height < $1.bounds.width * $1.bounds.height
        }) else { return }
        registeredRoot = root
        registeredScroll = scroll
        scroll.bottomEdgeEffect.style = .soft
        scroll.bottomEdgeEffect.isHidden = false
        root.setContentScrollView(scroll, for: .bottom)
        setContentScrollView(scroll, for: .bottom)
    }
    private func clearBottomEdge() {
        guard #available(iOS 26.0, *) else { return }
        if registeredRoot != nil {
            registeredRoot?.setContentScrollView(nil, for: .bottom)
            setContentScrollView(nil, for: .bottom)
        }
        registeredRoot = nil
        registeredScroll = nil
    }
}

struct SunderMainTabs: UIViewControllerRepresentable {
    @ObservedObject var navigation: SunderMainNavigation
    var roots: [AnyView]
    var avatar: String?
    var conversationOpen: Bool

    func makeCoordinator() -> Coordinator { Coordinator(navigation) }

    func makeUIViewController(context: Context) -> UITabBarController {
        let controller = SunderTabsController()
        let hosts = roots.map { UIHostingController(rootView: $0) }
        context.coordinator.hosts = hosts
        let titles = [NSLocalizedString("Chats", comment: "Tab"), NSLocalizedString("Settings", comment: "Tab"), NSLocalizedString("Profile", comment: "Tab")]
        let symbols = ["bubble.left.and.bubble.right", "gearshape", "person.crop.circle"]
        let search = UIViewController()
        context.coordinator.search = search
        if #available(iOS 26.0, *) {
            var tabs = hosts.enumerated().map { index, host in
                UITab(title: titles[index], image: UIImage(systemName: symbols[index]), identifier: "sunder.\(index)") { _ in host }
            }
            let searchTab = UISearchTab { _ in search }
            context.coordinator.searchIdentifier = searchTab.identifier
            tabs.append(searchTab)
            controller.tabs = tabs
        } else {
            for (index, host) in hosts.enumerated() {
                host.tabBarItem = UITabBarItem(title: titles[index], image: UIImage(systemName: symbols[index]), tag: index)
            }
            search.tabBarItem = UITabBarItem(tabBarSystemItem: .search, tag: 3)
            controller.setViewControllers(hosts + [search], animated: false)
        }
        controller.delegate = context.coordinator
        return controller
    }

    func updateUIViewController(_ controller: UITabBarController, context: Context) {
        context.coordinator.navigation = navigation
        for (host, root) in zip(context.coordinator.hosts, roots) { host.rootView = root }
        controller.tabBar.isUserInteractionEnabled = !navigation.savingFolder
        if controller.selectedIndex != navigation.selected { controller.selectedIndex = navigation.selected }
        if context.coordinator.avatarSource != avatar {
            context.coordinator.avatarSource = avatar
            let image = SunderCircleButton.Coordinator({}).avatarImage(avatar, unread: false)
                ?? UIImage(systemName: "person.crop.circle")
            context.coordinator.hosts.last?.tabBarItem.image = image
            context.coordinator.hosts.last?.tabBarItem.selectedImage = image
            if #available(iOS 26.0, *), controller.tabs.count > 2 { controller.tabs[2].image = image }
        }
        let hideBar = conversationOpen || navigation.hiddenRoots[navigation.selected] == true
        (controller as? SunderTabsController)?.bottomEdgeEnabled = !hideBar
        if context.coordinator.barHidden != hideBar {
            context.coordinator.barHidden = hideBar
            if #available(iOS 18.0, *) { controller.setTabBarHidden(hideBar, animated: false) }
            else { controller.tabBar.isHidden = hideBar }
        }
        (controller as? SunderTabsController)?.refreshBottomEdge()
    }

    class Coordinator: NSObject, UITabBarControllerDelegate {
        var navigation: SunderMainNavigation
        var hosts: [UIHostingController<AnyView>] = []
        var search: UIViewController?
        var avatarSource: String?
        var searchIdentifier: String?
        var barHidden = false
        init(_ navigation: SunderMainNavigation) { self.navigation = navigation }
        func tabBarController(_ controller: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
            guard !navigation.savingFolder else { return false }
            if viewController === search { requestSearch(controller); return false }
            if let index = hosts.firstIndex(where: { $0 === viewController }) { select(index, controller: controller) }
            return true
        }
        private func select(_ index: Int, controller: UITabBarController) {
            navigation.selected = index
            let hidden = navigation.hiddenRoots[index] == true
            barHidden = hidden
            (controller as? SunderTabsController)?.bottomEdgeEnabled = !hidden
            if #available(iOS 18.0, *) { controller.setTabBarHidden(hidden, animated: false) }
            else { controller.tabBar.isHidden = hidden }
        }
        private func requestSearch(_ controller: UITabBarController) {
            select(0, controller: controller)
            navigation.searchVisible = true
            navigation.searchGeneration += 1
            controller.selectedIndex = 0
        }
        @available(iOS 18.0, *)
        func tabBarController(_ controller: UITabBarController, shouldSelectTab tab: UITab) -> Bool {
            guard !navigation.savingFolder else { return false }
            if tab.identifier == searchIdentifier { requestSearch(controller); return false }
            if let index = controller.tabs.firstIndex(where: { $0.identifier == tab.identifier }), index < hosts.count { select(index, controller: controller) }
            return true
        }
        @available(iOS 18.0, *)
        func tabBarController(_ controller: UITabBarController, didSelectTab selectedTab: UITab, previousTab: UITab?) {
            if let index = controller.tabs.firstIndex(where: { $0.identifier == selectedTab.identifier }), index < hosts.count {
                navigation.selected = index
                (controller as? SunderTabsController)?.refreshBottomEdge()
            }
        }
        func tabBarController(_ controller: UITabBarController, didSelect viewController: UIViewController) {
            if let index = hosts.firstIndex(where: { $0 === viewController }) { navigation.selected = index }
            (controller as? SunderTabsController)?.refreshBottomEdge()
        }
    }
}

struct SunderFolderSegments: UIViewRepresentable {
    var titles: [String]
    var selected: Int
    var changed: (Int) -> Void
    func makeCoordinator() -> Coordinator { Coordinator(changed) }
    func makeUIView(context: Context) -> FolderControl {
        let view = FolderControl()
        view.control.addTarget(context.coordinator, action: #selector(Coordinator.select(_:)), for: .valueChanged)
        return view
    }
    func updateUIView(_ view: FolderControl, context: Context) {
        context.coordinator.changed = changed
        if view.titles != titles {
            view.titles = titles
            view.control.removeAllSegments()
            for (index, title) in titles.enumerated() { view.control.insertSegment(withTitle: title, at: index, animated: false) }
            view.width.constant = CGFloat(titles.count) * 90
        }
        view.control.selectedSegmentIndex = selected
    }
    class FolderControl: UIView {
        let control = UISegmentedControl()
        let scroll = UIScrollView()
        var titles: [String] = []
        var width: NSLayoutConstraint!
        private var edgeBinding: AnyObject?
        override func didMoveToWindow() {
            super.didMoveToWindow()
            setNeedsLayout()
        }
        override func layoutSubviews() {
            super.layoutSubviews()
            if #available(iOS 26.0, *) {
                if edgeBinding == nil { edgeBinding = SunderScrollEdgeBinding(container: self) }
                (edgeBinding as? SunderScrollEdgeBinding)?.bind(from: self)
            }
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            scroll.showsHorizontalScrollIndicator = false
            scroll.translatesAutoresizingMaskIntoConstraints = false
            control.translatesAutoresizingMaskIntoConstraints = false
            control.apportionsSegmentWidthsByContent = false
            if #available(iOS 26.0, *) {
                let glass = UIGlassEffect(style: .regular)
                let surface = UIVisualEffectView(effect: glass)
                surface.translatesAutoresizingMaskIntoConstraints = false
                surface.layer.cornerRadius = 20
                surface.layer.cornerCurve = .continuous
                surface.clipsToBounds = true
                addSubview(surface)
                surface.contentView.addSubview(scroll)
                NSLayoutConstraint.activate([
                    surface.leadingAnchor.constraint(equalTo: leadingAnchor), surface.trailingAnchor.constraint(equalTo: trailingAnchor),
                    surface.topAnchor.constraint(equalTo: topAnchor), surface.bottomAnchor.constraint(equalTo: bottomAnchor)
                ])
            } else { addSubview(scroll) }
            scroll.addSubview(control)
            width = control.widthAnchor.constraint(greaterThanOrEqualToConstant: 0)
            NSLayoutConstraint.activate([
                scroll.topAnchor.constraint(equalTo: topAnchor), scroll.bottomAnchor.constraint(equalTo: bottomAnchor),
                scroll.leadingAnchor.constraint(equalTo: leadingAnchor), scroll.trailingAnchor.constraint(equalTo: trailingAnchor),
                control.topAnchor.constraint(equalTo: scroll.contentLayoutGuide.topAnchor),
                control.bottomAnchor.constraint(equalTo: scroll.contentLayoutGuide.bottomAnchor),
                control.leadingAnchor.constraint(equalTo: scroll.contentLayoutGuide.leadingAnchor),
                control.trailingAnchor.constraint(equalTo: scroll.contentLayoutGuide.trailingAnchor),
                control.heightAnchor.constraint(equalTo: scroll.frameLayoutGuide.heightAnchor),
                control.widthAnchor.constraint(greaterThanOrEqualTo: scroll.frameLayoutGuide.widthAnchor), width
            ])
            let ideal = control.widthAnchor.constraint(equalTo: scroll.frameLayoutGuide.widthAnchor)
            ideal.priority = .defaultHigh
            ideal.isActive = true
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
    }
    class Coordinator: NSObject {
        var changed: (Int) -> Void
        init(_ changed: @escaping (Int) -> Void) { self.changed = changed }
        @objc func select(_ control: UISegmentedControl) { changed(control.selectedSegmentIndex) }
    }
}

private struct SunderFolderSaveKey: EnvironmentKey {
    static let defaultValue = Binding.constant(false)
}
extension EnvironmentValues {
    var sunderFolderSaveBusy: Binding<Bool> {
        get { self[SunderFolderSaveKey.self] }
        set { self[SunderFolderSaveKey.self] = newValue }
    }
}

@MainActor private func sunderNavigationOwner(_ controller: UIViewController?) -> UIViewController? {
    var current = controller
    while let candidate = current {
        if let nav = candidate.navigationController, nav.viewControllers.contains(where: { $0 === candidate }) { return candidate }
        current = candidate.parent
    }
    return nil
}

@available(iOS 26.0, *)
@MainActor private final class SunderScrollEdgeBinding {
    let interaction = UIScrollEdgeElementContainerInteraction()
    let edge: UIRectEdge
    init(container: UIView, edge: UIRectEdge = .top) {
        self.edge = edge
        interaction.edge = edge
        container.addInteraction(interaction)
    }
    func bind(from view: UIView) {
        var responder: UIResponder? = view
        while let current = responder, !(current is UIViewController) { responder = current.next }
        guard let owner = sunderNavigationOwner(responder as? UIViewController) else { return }
        func verticalList(_ root: UIView) -> UIScrollView? {
            if let scroll = root as? UIScrollView, (scroll is UITableView || scroll is UICollectionView),
               (scroll.alwaysBounceVertical || scroll is UITableView), scroll.window != nil { return scroll }
            for child in root.subviews {
                if let found = verticalList(child) { return found }
            }
            return nil
        }
        guard let list = verticalList(owner.view) else { return }
        if interaction.scrollView !== list { interaction.scrollView = list }
        if edge == .bottom {
            if list.bottomEdgeEffect.style != .soft { list.bottomEdgeEffect.style = .soft }
        } else if list.topEdgeEffect.style != .soft { list.topEdgeEffect.style = .soft }
    }
}

@available(iOS 26.0, *)
@MainActor private func sunderTrailingBarItems(_ item: UINavigationItem) -> [UIBarButtonItem] {
    var seen = Set<ObjectIdentifier>()
    return (item.trailingItemGroups.flatMap(\.barButtonItems) + (item.rightBarButtonItems ?? []))
        .filter { seen.insert(ObjectIdentifier($0)).inserted }
}

@available(iOS 26.0, *)
@MainActor private func sunderMatchingBarItem(_ items: [UIBarButtonItem], id: String, label: String) -> UIBarButtonItem? {
    func matches(_ view: UIView) -> Bool {
        if view.accessibilityIdentifier == id || view.accessibilityLabel == label { return true }
        return view.subviews.contains(where: matches)
    }
    return items.first {
        $0.identifier == id || $0.accessibilityIdentifier == id || $0.accessibilityLabel == label
            || $0.customView.map(matches) == true
    }
}

@available(iOS 26.0, *)
struct SunderConversationIdentity: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> Controller { Controller() }
    func updateUIViewController(_ controller: Controller, context: Context) { controller.apply() }
    class Controller: UIViewController {
        private var reported = false
        override func loadView() { view = UIView(); view.isUserInteractionEnabled = false }
        override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); apply() }
        override func viewWillLayoutSubviews() { super.viewWillLayoutSubviews(); apply() }
        override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); apply(); report() }
        func apply() {
            guard let owner = sunderNavigationOwner(parent), owner.navigationController?.topViewController === owner else { return }
            let item = owner.navigationItem
            let trailing = sunderTrailingBarItems(item)
            if let avatar = trailing.count == 1 ? trailing.first : sunderMatchingBarItem(trailing, id: "sunder.avatar", label: NSLocalizedString("Profile", comment: "Profile")) {
                if avatar.identifier != "sunder.avatar" { avatar.identifier = "sunder.avatar" }
            }
            let center = item.centerItemGroups.flatMap(\.barButtonItems)
            if center.count == 1, let title = center.first {
                if title.identifier != "sunder.context" { title.identifier = "sunder.context" }
            }
        }
        private func report() {
            guard !reported, let owner = sunderNavigationOwner(parent) else { return }
            reported = true
            let item = owner.navigationItem
            logger.debug("Sunder header structure v2: topOwner=\(owner.navigationController?.topViewController === owner), titleView=\(item.titleView != nil), centerItems=\(item.centerItemGroups.flatMap(\.barButtonItems).count), trailingGroups=\(item.trailingItemGroups.count), trailingItems=\(sunderTrailingBarItems(item).count)")
        }
    }
}

struct SunderNavigationSearch: UIViewControllerRepresentable {
    @Binding var active: Bool
    @Binding var text: String
    @Binding var focused: Bool
    var blocked: Bool
    var busy: Bool
    func makeUIViewController(context: Context) -> Controller { Controller(self) }
    func updateUIViewController(_ controller: Controller, context: Context) { controller.state = self; controller.apply() }
    static func dismantleUIViewController(_ controller: Controller, coordinator: ()) {
        controller.detach()
    }

    class Controller: UIViewController, UISearchResultsUpdating, UISearchControllerDelegate, UISearchBarDelegate {
        var state: SunderNavigationSearch
        let search = UISearchController(searchResultsController: nil)
        private weak var owner: UIViewController?
        private var savedLeft: [UIBarButtonItem]?
        private var savedRight: [UIBarButtonItem]?
        private var savedLeadingGroups: [UIBarButtonItemGroup] = []
        private var savedTrailingGroups: [UIBarButtonItemGroup] = []
        private var installed = false
        private var applying = false
        private let spinner = UIActivityIndicatorView(style: .medium)
        private var originalSearchIcon: UIView?
        private var visible = false
        private var sourceIdentityReport: String?
        private weak var independentUnreadItem: UIBarButtonItem?


        init(_ state: SunderNavigationSearch) { self.state = state; super.init(nibName: nil, bundle: nil) }
        required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
        override func loadView() {
            view = UIView()
            view.isUserInteractionEnabled = false
            search.obscuresBackgroundDuringPresentation = false
            search.hidesNavigationBarDuringPresentation = false
            search.automaticallyShowsCancelButton = true
            search.searchResultsUpdater = self
            search.delegate = self
            search.searchBar.delegate = self
            search.searchBar.autocapitalizationType = .none
            search.searchBar.autocorrectionType = .no
            search.searchBar.placeholder = NSLocalizedString("Search or paste SimpleX link", comment: "Search")
            originalSearchIcon = search.searchBar.searchTextField.leftView
        }
        override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated); visible = true; apply() }
        override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); apply() }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            visible = false
        }
        override func viewDidLayoutSubviews() { super.viewDidLayoutSubviews(); apply() }
        func apply() {
            guard #available(iOS 26.0, *), visible, !applying, isViewLoaded, view.window != nil,
                  let current = sunderNavigationOwner(parent), current.navigationController?.topViewController === current else { return }
            applying = true
            defer { applying = false }
            owner = current
            let item = current.navigationItem
            if state.active {
                if !installed {
                    savedLeft = item.leftBarButtonItems
                    savedRight = item.rightBarButtonItems
                    savedLeadingGroups = item.leadingItemGroups
                    savedTrailingGroups = item.trailingItemGroups
                    current.definesPresentationContext = true
                    item.searchController = search
                    item.preferredSearchBarPlacement = .integrated
                    item.searchBarPlacementAllowsToolbarIntegration = false
                    item.searchBarPlacementAllowsExternalIntegration = false
                    item.hidesSearchBarWhenScrolling = false
                    item.searchBarPlacementBarButtonItem.identifier = "sunder.leading"
                    item.setLeftBarButtonItems([], animated: true)
                    item.setRightBarButtonItems([], animated: true)
                    installed = true
                    search.isActive = true
                }
                if search.searchBar.text != state.text { search.searchBar.text = state.text }
                search.searchBar.searchTextField.isEnabled = !state.blocked
                if state.busy {
                    spinner.startAnimating()
                    search.searchBar.searchTextField.leftView = spinner
                } else {
                    spinner.stopAnimating()
                    search.searchBar.searchTextField.leftView = originalSearchIcon
                }
            } else {
                if installed { detach() }
                item.leftBarButtonItems?.first?.identifier = "sunder.leading"
                if item.backBarButtonItem?.identifier != "sunder.leading" {
                    item.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
                    item.backBarButtonItem?.identifier = "sunder.leading"
                }
                if item.backButtonDisplayMode != .minimal { item.backButtonDisplayMode = .minimal }
                let trailing = sunderTrailingBarItems(item)
                let compose = sunderMatchingBarItem(trailing, id: "sunder.avatar", label: NSLocalizedString("New chat", comment: "New chat"))
                let unread = sunderMatchingBarItem(trailing, id: "sunder.context", label: NSLocalizedString("Unread", comment: "Unread"))
                if let compose, compose.identifier != "sunder.avatar" { compose.identifier = "sunder.avatar" }
                if let unread {
                    if unread.identifier != "sunder.context" { unread.identifier = "sunder.context" }
                    if independentUnreadItem !== unread {
                        unread.sharesBackground = false
                        independentUnreadItem = unread
                    }
                }
                let unreadGroupSize = item.trailingItemGroups.first(where: { group in
                    group.barButtonItems.contains(where: { $0 === unread })
                })?.barButtonItems.count ?? 0
                let status = "groups=\(item.trailingItemGroups.count), items=\(trailing.count), compose=\(compose != nil), unread=\(unread != nil), unreadGroupSize=\(unreadGroupSize)"
                if sourceIdentityReport != status {
                    sourceIdentityReport = status
                    logger.debug("Sunder source header identity v3: groups=\(item.trailingItemGroups.count), items=\(trailing.count), compose=\(compose != nil), unread=\(unread != nil), unreadGroupSize=\(unreadGroupSize)")
                }
            }
        }
        func detach() {
            guard installed else { return }
            installed = false
            search.isActive = false
            if owner?.navigationItem.searchController === search {
                owner?.navigationItem.searchController = nil
                if #available(iOS 26.0, *), !savedLeadingGroups.isEmpty {
                    owner?.navigationItem.leadingItemGroups = savedLeadingGroups
                } else { owner?.navigationItem.setLeftBarButtonItems(savedLeft, animated: true) }
                if #available(iOS 26.0, *), !savedTrailingGroups.isEmpty {
                    owner?.navigationItem.trailingItemGroups = savedTrailingGroups
                } else { owner?.navigationItem.setRightBarButtonItems(savedRight, animated: true) }
            }
            savedLeft = nil
            savedRight = nil
            savedLeadingGroups = []
            savedTrailingGroups = []
        }
        func updateSearchResults(for searchController: UISearchController) {
            let value = searchController.searchBar.text ?? ""
            if value != state.text { state.text = value }
        }
        func didPresentSearchController(_ searchController: UISearchController) { searchController.searchBar.becomeFirstResponder() }
        func didDismissSearchController(_ searchController: UISearchController) {
            if state.active { state.active = false }
        }
        func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
            ConnectProgressManager.shared.cancelConnectProgress()
            state.text = ""
            state.focused = false
            state.active = false
            detach()
        }
        func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) { if !state.focused { state.focused = true } }
        func searchBarTextDidEndEditing(_ searchBar: UISearchBar) { if state.focused { state.focused = false } }
    }
}
