// Sunder: shared standard Apple presentation defaults.
import SwiftUI

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
        content.onAppear { visibility?(true) }.onDisappear { visibility?(false) }
    }
}
extension View {
    @ViewBuilder func sunderConversationToolbar<M: ToolbarContent, L: ToolbarContent>(
        modern: Bool, @ToolbarContentBuilder modernToolbar: () -> M,
        @ToolbarContentBuilder legacyToolbar: () -> L
    ) -> some View {
        if #available(iOS 26.0, *), modern {
            toolbarRole(.editor).toolbar(content: modernToolbar)
        } else if #available(iOS 16.0, *) {
            toolbarRole(.automatic).toolbar(content: legacyToolbar)
        } else {
            toolbar(content: legacyToolbar)
        }
    }
}
struct SunderTitleButtonStyle: ViewModifier {
    func body(content: Content) -> some View { content.buttonStyle(.plain) }
}
struct SunderAvatarToolbarButtonStyle: ViewModifier {
    func body(content: Content) -> some View { content.buttonStyle(.plain) }
}
