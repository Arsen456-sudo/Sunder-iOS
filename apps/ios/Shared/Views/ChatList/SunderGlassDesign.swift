// Sunder, 2026-10-30. Shared native glass presentation; no messaging state.
import SwiftUI
import UIKit

final class SunderGlassEffectView: UIVisualEffectView {
    var radius: CGFloat = 22 { didSet { setNeedsLayout() } }
    var interactive = false { didSet { updateMaterial() } }
    private var observers: [NSObjectProtocol] = []

    init(radius: CGFloat = 22) {
        super.init(effect: nil)
        self.radius = radius
        for name in [UIAccessibility.reduceTransparencyStatusDidChangeNotification,
                     UIAccessibility.reduceMotionStatusDidChangeNotification] {
            observers.append(NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main) {
                [weak self] _ in self?.updateMaterial()
            })
        }
        updateMaterial()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Programmatic view") }

    private func updateMaterial() {
        if UIAccessibility.isReduceTransparencyEnabled {
            effect = nil
            backgroundColor = .secondarySystemBackground
        } else if #available(iOS 26.0, *) {
            let glass = UIGlassEffect(style: .regular)
            glass.isInteractive = interactive && !UIAccessibility.isReduceMotionEnabled
            effect = glass
            backgroundColor = .clear
        } else {
            effect = UIBlurEffect(style: .systemMaterial)
            backgroundColor = .clear
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let resolvedRadius = min(radius, bounds.height / 2)
        if #available(iOS 26.0, *) {
            let configuration = UICornerConfiguration.corners(radius: .fixed(Double(resolvedRadius)))
            if cornerConfiguration != configuration { cornerConfiguration = configuration }
        } else {
            layer.cornerRadius = resolvedRadius
            layer.cornerCurve = .continuous
        }
        clipsToBounds = true
    }

    deinit { for observer in observers { NotificationCenter.default.removeObserver(observer) } }
}

struct SunderGlassSurface: UIViewRepresentable {
    var radius: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func makeUIView(context: Context) -> SunderGlassEffectView {
        let view = SunderGlassEffectView()
        view.isUserInteractionEnabled = false
        view.accessibilityElementsHidden = true
        return view
    }
    func updateUIView(_ view: SunderGlassEffectView, context: Context) {
        view.radius = radius
        view.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
    }
}

extension View {
    @ViewBuilder func ifAvailableHideScrollBackground() -> some View {
        if #available(iOS 16.0, *) { scrollContentBackground(.hidden) }
        else { self }
    }

    func sunderGlass(cornerRadius: CGFloat = 22) -> some View {
        background(SunderGlassSurface(radius: cornerRadius).allowsHitTesting(false))
    }
}

struct SunderGlassSelector: UIViewRepresentable {
    var titles: [String]
    @Binding var selection: Int
    var label: String
    var tint: UIColor
    @Environment(\.colorScheme) private var colorScheme

    func makeCoordinator() -> Coordinator { Coordinator(self) }
    func makeUIView(context: Context) -> Control {
        let control = Control(titles: titles)
        control.addTarget(context.coordinator, action: #selector(Coordinator.select(_:)), for: .valueChanged)
        return control
    }
    func updateUIView(_ control: Control, context: Context) {
        context.coordinator.parent = self
        control.overrideUserInterfaceStyle = colorScheme == .dark ? .dark : .light
        control.accessibilityLabel = label
        control.update(titles: titles, selection: selection, tint: tint)
    }

    @MainActor final class Coordinator: NSObject {
        var parent: SunderGlassSelector
        init(_ parent: SunderGlassSelector) { self.parent = parent }
        @objc func select(_ control: Control) { parent.selection = control.selection }
    }

    final class Control: UIControl {
        private let glass = SunderGlassEffectView()
        private let stack = UIStackView()
        private let indicator = UIView()
        private var buttons: [UIButton] = []
        private(set) var selection = 0

        init(titles: [String]) {
            super.init(frame: .zero)
            glass.interactive = true
            glass.translatesAutoresizingMaskIntoConstraints = false
            addSubview(glass)
            NSLayoutConstraint.activate([
                glass.leadingAnchor.constraint(equalTo: leadingAnchor),
                glass.trailingAnchor.constraint(equalTo: trailingAnchor),
                glass.topAnchor.constraint(equalTo: topAnchor),
                glass.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
            glass.contentView.addSubview(indicator)
            stack.distribution = .fillEqually
            stack.translatesAutoresizingMaskIntoConstraints = false
            glass.contentView.addSubview(stack)
            NSLayoutConstraint.activate([
                stack.leadingAnchor.constraint(equalTo: glass.contentView.leadingAnchor, constant: 4),
                stack.trailingAnchor.constraint(equalTo: glass.contentView.trailingAnchor, constant: -4),
                stack.topAnchor.constraint(equalTo: glass.contentView.topAnchor, constant: 4),
                stack.bottomAnchor.constraint(equalTo: glass.contentView.bottomAnchor, constant: -4)
            ])
            for (index, title) in titles.enumerated() {
                let button = UIButton(type: .system)
                button.tag = index
                button.setTitle(title, for: .normal)
                button.addTarget(self, action: #selector(choose(_:)), for: .touchUpInside)
                button.titleLabel?.font = .preferredFont(forTextStyle: .subheadline)
                button.titleLabel?.adjustsFontForContentSizeCategory = true
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.titleLabel?.minimumScaleFactor = 0.75
                buttons.append(button)
                stack.addArrangedSubview(button)
            }
        }

        @available(*, unavailable)
        required init?(coder: NSCoder) { fatalError("Programmatic control") }

        func update(titles: [String], selection: Int, tint: UIColor) {
            self.selection = min(max(selection, 0), max(buttons.count - 1, 0))
            indicator.backgroundColor = .secondarySystemFill
            for (index, button) in buttons.enumerated() {
                button.setTitle(titles[index], for: .normal)
                button.setTitleColor(index == self.selection ? .label : .secondaryLabel, for: .normal)
                button.isSelected = index == self.selection
                button.accessibilityTraits = index == self.selection ? [.button, .selected] : .button
            }
            setNeedsLayout()
        }

        override func layoutSubviews() {
            super.layoutSubviews()
            glass.layoutIfNeeded()
            stack.layoutIfNeeded()
            guard buttons.indices.contains(selection) else { return }
            indicator.frame = buttons[selection].convert(buttons[selection].bounds, to: glass.contentView)
            indicator.layer.cornerRadius = indicator.bounds.height / 2
        }

        @objc private func choose(_ button: UIButton) {
            guard button.tag != selection else { return }
            selection = button.tag
            sendActions(for: .valueChanged)
        }
    }
}


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
            content.sunderGlass(cornerRadius: 24)
                .padding(.horizontal, inset)
                .padding(.vertical, 4)
        } else {
            content.background(legacyMaterial)
        }
    }
}


struct SunderSystemActionButtons: ViewModifier {
    @ViewBuilder func body(content: Content) -> some View {
        if #available(iOS 26.0, *) {
            content.buttonStyle(.glass).controlSize(.large).buttonBorderShape(.capsule)
        } else {
            content
        }
    }
}
