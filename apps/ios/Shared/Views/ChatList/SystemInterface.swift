// Sunder: shared standard Apple presentation defaults.
import SwiftUI
import UIKit

// Shared defaults match AppearanceSettings. Descendants retain explicit styles.
struct SunderSystemInterface: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .listStyle(.insetGrouped)
                .formStyle(.grouped)
                .buttonStyle(.automatic)
                .pickerStyle(.automatic)
                .toggleStyle(.automatic)
                .toolbarBackground(.automatic, for: .navigationBar, .bottomBar)
                .scrollEdgeEffectStyle(.automatic, for: [.top, .bottom])
        } else {
            content
        }
    }
}

struct SunderSystemDetailNavigation: ViewModifier {
    let title: String
    var modal = false
    var close: () -> Void

    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content
                .navigationBarHidden(false)
                .navigationTitle(title)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    if modal {
                        ToolbarItem(placement: .confirmationAction) {
                            Button(action: close) { Image(systemName: "xmark") }
                                .accessibilityLabel(Text("Close"))
                        }
                    }
                }
        } else {
            content.navigationBarHidden(true)
        }
    }
}


struct SunderCommandSurface: ViewModifier {
    let legacyMaterial: Material
    var inset: CGFloat = 10

    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.background(.bar)
        } else {
            content.background(legacyMaterial)
        }
    }
}


struct SunderSystemActionButtons: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.bordered).controlSize(.large)
        } else {
            content
        }
    }
}


extension View {
    @ViewBuilder func ifAvailableHideScrollBackground() -> some View {
        if #available(iOS 16.0, *) { scrollContentBackground(.hidden) }
        else { self }
    }
}

struct SunderComposeButton: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glass).buttonBorderShape(.circle).controlSize(.large)
        } else {
            content.buttonStyle(.bordered)
        }
    }
}

struct SunderComposeActionInset: ViewModifier {
    var floating: Bool
    var horizontal = false
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *), floating {
            content.frame(minWidth: 44, minHeight: 44).contentShape(Circle())
        } else {
            content.padding(horizontal ? [.bottom, .horizontal] : [.bottom, .trailing], 4)
        }
    }
}

struct SunderComposePreviewSurface: ViewModifier {
    var visible: Bool
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *), visible {
            content.glassEffect(.regular, in: RoundedRectangle(cornerRadius: 24))
                .padding(.horizontal, 12)
                .padding(.top, 6)
        } else { content }
    }
}

struct SunderSelectionSurface: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.glassEffect(.regular, in: Capsule())
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
        } else { content.background(.thinMaterial) }
    }
}

struct SunderComposeBarBackground: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content }
        else { content.background(.bar) }
    }
}

struct SunderConversationBottomInset<Bottom: View>: ViewModifier {
    var bottom: Bottom
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.safeAreaInset(edge: .bottom, spacing: 0) { bottom }
        } else {
            VStack(spacing: 0) { content; bottom }
        }
    }
}

@available(iOS 26.0, *)
struct SunderComposeEdge: UIViewRepresentable {
    var scrollView: UIScrollView
    func makeUIView(context: Context) -> EdgeView { EdgeView(scrollView: scrollView) }
    func updateUIView(_ view: EdgeView, context: Context) { view.bind(scrollView) }
    static func dismantleUIView(_ view: EdgeView, coordinator: ()) { view.interaction.scrollView = nil }

    final class EdgeView: UIView {
        let interaction = UIScrollEdgeElementContainerInteraction()
        init(scrollView: UIScrollView) {
            super.init(frame: .zero)
            isUserInteractionEnabled = false
            interaction.edge = .bottom
            addInteraction(interaction)
            bind(scrollView)
        }
        required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
        func bind(_ scrollView: UIScrollView) {
            if interaction.scrollView !== scrollView { interaction.scrollView = scrollView }
            if scrollView.bottomEdgeEffect.style != .soft { scrollView.bottomEdgeEffect.style = .soft }
            if scrollView.bottomEdgeEffect.isHidden { scrollView.bottomEdgeEffect.isHidden = false }
        }
    }
}

struct SunderConversationScrollExtent: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.ignoresSafeArea(.container, edges: .top)
        } else {
            content
        }
    }
}

struct SunderChatListEdges: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.scrollEdgeEffectStyle(.soft, for: [.top, .bottom]) }
        else { content }
    }
}

private struct SunderRootVisibilityKey: EnvironmentKey {
    static let defaultValue: ((Bool) -> Void)? = nil
}
extension EnvironmentValues {
    var sunderRootVisibility: ((Bool) -> Void)? {
        get { self[SunderRootVisibilityKey.self] }
        set { self[SunderRootVisibilityKey.self] = newValue }
    }
}
struct SunderTabRootVisibility: ViewModifier {
    @Environment(\.sunderRootVisibility) private var visibility
    func body(content: Content) -> some View {
        content.background(SunderRootLifecycle(visibility: visibility).frame(width: 0, height: 0))
    }
}

private struct SunderRootLifecycle: UIViewControllerRepresentable {
    var visibility: ((Bool) -> Void)?
    func makeUIViewController(context: Context) -> Controller { Controller(visibility) }
    func updateUIViewController(_ controller: Controller, context: Context) { controller.visibility = visibility }
    class Controller: UIViewController {
        var visibility: ((Bool) -> Void)?
        private var visibilityRevision = 0
        private func publishVisibility(_ visible: Bool) {
            visibilityRevision += 1
            let revision = visibilityRevision
            DispatchQueue.main.async { [weak self] in
                guard let self, self.visibilityRevision == revision else { return }
                self.visibility?(visible)
            }
        }
        init(_ visibility: ((Bool) -> Void)?) { self.visibility = visibility; super.init(nibName: nil, bundle: nil) }
        required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
        override func loadView() { view = UIView(); view.isUserInteractionEnabled = false }
        private var navigationOwner: UIViewController? {
            var candidate = parent
            while let current = candidate {
                if let nav = current.navigationController, nav.viewControllers.first === current { return current }
                candidate = current.parent
            }
            return nil
        }
        override func viewWillAppear(_ animated: Bool) {
            super.viewWillAppear(animated)
            guard let owner = navigationOwner else { publishVisibility(true); return }
            let nav = owner.navigationController
            let returningToRoot = nav?.topViewController === owner || nav?.transitionCoordinator?.viewController(forKey: .to) === owner
            guard returningToRoot else { return }
            update(visible: true, owner: owner)
        }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            guard let owner = navigationOwner, let nav = owner.navigationController else { publishVisibility(false); return }
            let destination = nav.transitionCoordinator?.viewController(forKey: .to)
            let pushesWithinStack = destination != nil && destination !== owner && destination?.navigationController === nav
            guard nav.viewControllers.count > 1 || pushesWithinStack else { return }
            update(visible: false, owner: owner)
        }
        private func update(visible: Bool, owner: UIViewController) {
            if !visible, let tabs = owner.tabBarController {
                if #available(iOS 18.0, *) { tabs.setTabBarHidden(true, animated: false) }
                else { tabs.tabBar.isHidden = true }
            }
            publishVisibility(visible)
        }
    }
}

extension View {
    @ViewBuilder func sunderConversationToolbar<M: ToolbarContent, L: ToolbarContent>(
        modern: Bool, @ToolbarContentBuilder modernToolbar: () -> M,
        @ToolbarContentBuilder legacyToolbar: () -> L
    ) -> some View {
        if #available(iOS 26.0, *), modern {
            toolbarRole(.automatic).toolbar(content: modernToolbar)
        } else if #available(iOS 16.0, *) {
            toolbarRole(.automatic).toolbar(content: legacyToolbar)
        } else {
            toolbar(content: legacyToolbar)
        }
    }
}
struct SunderAvatarToolbarButtonStyle: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) { content.buttonStyle(.plain).buttonBorderShape(.circle) }
        else { content.buttonStyle(.plain) }
    }
}

struct SunderTitleSurface: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.plain)
                .padding(.horizontal, 12)
                .frame(height: 44)
                .glassEffect(.regular.interactive(), in: Capsule())
        } else { content }
    }
}

private struct SunderProfileCloseKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension EnvironmentValues {
    var sunderProfileClose: (() -> Void)? {
        get { self[SunderProfileCloseKey.self] }
        set { self[SunderProfileCloseKey.self] = newValue }
    }
}

extension View {
    func sunderFullScreenProfile<D: View>(
        isPresented: Binding<Bool>, onDismiss: (() -> Void)? = nil,
        @ViewBuilder content: @escaping () -> D
    ) -> some View {
        background(SunderSideProfile(isPresented: isPresented, onDismiss: onDismiss, content: content)
            .frame(width: 0, height: 0))
    }
}

private struct SunderSideProfile<D: View>: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onDismiss: (() -> Void)?
    var content: () -> D

    func makeUIViewController(context: Context) -> Controller { Controller(self) }
    func updateUIViewController(_ controller: Controller, context: Context) {
        controller.state = self
        controller.scheduleUpdate()
    }
    static func dismantleUIViewController(_ controller: Controller, coordinator: ()) {
        controller.tearDown()
    }

    final class Controller: UIViewController, UINavigationControllerDelegate, UIGestureRecognizerDelegate {
        var state: SunderSideProfile
        private var ownedNavigation: UINavigationController?
        private var profileController: UIViewController?
        private var pushStarted = false
        private var transitioning = false
        private var closeRequested = false
        private var updateScheduled = false
        private var closing = false
        private var dismantled = false

        init(_ state: SunderSideProfile) { self.state = state; super.init(nibName: nil, bundle: nil) }
        required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }
        override func loadView() { view = UIView(); view.isUserInteractionEnabled = false }
        override func viewDidAppear(_ animated: Bool) { super.viewDidAppear(animated); scheduleUpdate() }

        func scheduleUpdate() {
            guard !updateScheduled, !dismantled else { return }
            updateScheduled = true
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
                self.updateScheduled = false
                self.reconcile()
            }
        }

        private func reconcile() {
            guard !dismantled else { return }
            if let navigation = ownedNavigation {
                if !state.isPresented || closeRequested { close(navigation) }
                return
            }
            guard state.isPresented, viewIfLoaded?.window != nil, presentedViewController == nil else { return }
            let root = UIViewController()
            root.view.backgroundColor = .clear
            let navigation = UINavigationController(rootViewController: root)
            navigation.setNavigationBarHidden(true, animated: false)
            navigation.view.backgroundColor = .clear
            navigation.modalPresentationStyle = .overFullScreen
            navigation.delegate = self
            let profile = UIHostingController(rootView: state.content()
                .environment(\.sunderProfileClose, { [weak self] in
                    self?.closeRequested = true
                    self?.scheduleUpdate()
                }))
            ownedNavigation = navigation
            profileController = profile
            transitioning = true
            // Only the native navigation push animates; the transparent container does not.
            present(navigation, animated: false) { [weak self, weak navigation, weak profile] in
                guard let self, let navigation, let profile, !self.dismantled else { return }
                self.pushStarted = true
                navigation.interactivePopGestureRecognizer?.delegate = self
                navigation.interactivePopGestureRecognizer?.isEnabled = true
                navigation.pushViewController(profile, animated: !UIAccessibility.isReduceMotionEnabled)
            }
        }

        private func close(_ navigation: UINavigationController) {
            guard pushStarted, !transitioning, !closing else { return }
            closeRequested = true
            transitioning = true
            navigation.popToRootViewController(animated: !UIAccessibility.isReduceMotionEnabled)
        }

        func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
            if navigationController === ownedNavigation, pushStarted { transitioning = true }
        }

        func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
            guard navigationController === ownedNavigation, pushStarted, !closing else { return }
            transitioning = false
            if viewController === profileController {
                scheduleUpdate()
            } else if viewController === navigationController.viewControllers.first {
                closing = true
                navigationController.dismiss(animated: false) { [weak self] in self?.finish() }
            }
        }

        func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
            guard !transitioning, !closing, let navigation = ownedNavigation,
                  navigation.topViewController === profileController else { return false }
            func hasNestedRoute(_ controller: UIViewController) -> Bool {
                if let nested = controller as? UINavigationController, nested.viewControllers.count > 1 { return true }
                return controller.children.contains(where: hasNestedRoute)
            }
            return profileController.map { !hasNestedRoute($0) && $0.presentedViewController == nil } ?? false
        }

        private func finish() {
            guard ownedNavigation != nil else { return }
            ownedNavigation?.delegate = nil
            ownedNavigation = nil
            profileController = nil
            pushStarted = false
            transitioning = false
            closing = false
            closeRequested = false
            state.isPresented = false
            state.onDismiss?()
        }

        func tearDown() {
            dismantled = true
            guard let navigation = ownedNavigation else { return }
            navigation.delegate = nil
            navigation.dismiss(animated: false) { [self] in finish() }
        }
    }
}
