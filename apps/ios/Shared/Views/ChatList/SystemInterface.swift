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
            content.buttonStyle(.glass).buttonBorderShape(.circle)
        } else {
            content.buttonStyle(.bordered)
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
            guard let owner = navigationOwner else { visibility?(true); return }
            let nav = owner.navigationController
            let returningToRoot = nav?.topViewController === owner || nav?.transitionCoordinator?.viewController(forKey: .to) === owner
            guard returningToRoot else { return }
            update(visible: true, owner: owner)
        }
        override func viewWillDisappear(_ animated: Bool) {
            super.viewWillDisappear(animated)
            guard let owner = navigationOwner, let nav = owner.navigationController else { visibility?(false); return }
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
            visibility?(visible)
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

struct SunderProfileNavigation<Content: View>: View {
    var pushed: Bool
    @ViewBuilder var content: () -> Content
    @ViewBuilder var body: some View {
        if pushed { content() }
        else { NavigationView { content() } }
    }
}

extension View {
    @ViewBuilder func sunderProfileDestination<D: View>(
        isPresented: Binding<Bool>, @ViewBuilder destination: @escaping () -> D
    ) -> some View {
        if #available(iOS 16.0, *) {
            navigationDestination(isPresented: isPresented, destination: destination)
        } else {
            background(NavigationLink(destination: destination(), isActive: isPresented) { EmptyView() }.hidden())
        }
    }
}
