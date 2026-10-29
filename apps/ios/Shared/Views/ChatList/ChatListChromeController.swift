// Sunder, 2026-10-29. Native chrome for the chat-list screen.
import UIKit

struct ChatListChromeState {
    var avatar: UIImage?
    var unreadProfiles = false
    var title: String
    var statusImage: UIImage?
    var statusColor: UIColor = .secondaryLabel
    var percentage: String?
    var showsStatus = true
    var running: Bool?
    var tint: UIColor = .systemBlue
    var interfaceStyle: UIUserInterfaceStyle = .unspecified
}

final class ChatListChromeController: UIViewController, UIGestureRecognizerDelegate {
    let floating: Bool
    var profileAction: (() -> Void)?
    var composeAction: (() -> Void)?
    var statusAction: (() -> Void)?
    var searchAction: (() -> Void)?
    var visibilityChanged: ((Bool) -> Void)?
    private(set) var visible = false

    private let avatarButton = UIButton(type: .system)
    private let statusButton = UIButton(type: .system)
    private let composeButton = UIButton(type: .system)
    private let unreadDot = UIView()
    private let glassContainer = UIVisualEffectView()
    private let stack = UIStackView()
    private var islands: [UIVisualEffectView] = []
    private var state = ChatListChromeState(title: "")
    private weak var boundScrollView: UIScrollView?
    private var detachEdge: (() -> Void)?
    private var accessibilityObservers: [NSObjectProtocol] = []

    init(floating: Bool) {
        self.floating = floating
        super.init(nibName: nil, bundle: nil)
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("Programmatic controller") }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        avatarButton.addTarget(self, action: #selector(openProfile), for: .touchUpInside)
        statusButton.addTarget(self, action: #selector(openStatus), for: .touchUpInside)
        composeButton.addTarget(self, action: #selector(openCompose), for: .touchUpInside)
        avatarButton.accessibilityLabel = NSLocalizedString("Your profile", comment: "Chat-list profile button")
        composeButton.accessibilityLabel = NSLocalizedString("New chat", comment: "Chat-list compose button")
        unreadDot.backgroundColor = .systemBlue
        unreadDot.isUserInteractionEnabled = false
        unreadDot.layer.cornerRadius = 5
        unreadDot.layer.borderWidth = 1.5
        unreadDot.translatesAutoresizingMaskIntoConstraints = false
        avatarButton.addSubview(unreadDot)
        NSLayoutConstraint.activate([
            unreadDot.widthAnchor.constraint(equalToConstant: 10),
            unreadDot.heightAnchor.constraint(equalToConstant: 10),
            unreadDot.topAnchor.constraint(equalTo: avatarButton.topAnchor, constant: 5),
            unreadDot.trailingAnchor.constraint(equalTo: avatarButton.trailingAnchor, constant: -5)
        ])

        installFloatingBar()
        for notification in [UIAccessibility.reduceMotionStatusDidChangeNotification,
                             UIAccessibility.reduceTransparencyStatusDidChangeNotification] {
            accessibilityObservers.append(NotificationCenter.default.addObserver(
                forName: notification, object: nil, queue: .main
            ) { [weak self] _ in self?.updateMaterials() })
        }
        render()
    }

    private func installFloatingBar() {
        glassContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(glassContainer)
        NSLayoutConstraint.activate([
            glassContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            glassContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            glassContainer.topAnchor.constraint(equalTo: view.topAnchor, constant: 8),
            glassContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8)
        ])
        stack.axis = .horizontal
        stack.spacing = 12
        stack.alignment = .fill
        stack.translatesAutoresizingMaskIntoConstraints = false
        glassContainer.contentView.addSubview(stack)
        NSLayoutConstraint.activate([
            stack.leadingAnchor.constraint(equalTo: glassContainer.contentView.leadingAnchor),
            stack.trailingAnchor.constraint(equalTo: glassContainer.contentView.trailingAnchor),
            stack.topAnchor.constraint(equalTo: glassContainer.contentView.topAnchor),
            stack.bottomAnchor.constraint(equalTo: glassContainer.contentView.bottomAnchor)
        ])
        for button in [avatarButton, statusButton, composeButton] {
            let island = UIVisualEffectView()
            island.translatesAutoresizingMaskIntoConstraints = false
            button.translatesAutoresizingMaskIntoConstraints = false
            island.contentView.addSubview(button)
            NSLayoutConstraint.activate([
                button.leadingAnchor.constraint(equalTo: island.contentView.leadingAnchor),
                button.trailingAnchor.constraint(equalTo: island.contentView.trailingAnchor),
                button.topAnchor.constraint(equalTo: island.contentView.topAnchor),
                button.bottomAnchor.constraint(equalTo: island.contentView.bottomAnchor)
            ])
            if button !== statusButton {
                let square = island.widthAnchor.constraint(equalTo: island.heightAnchor)
                square.priority = UILayoutPriority(999)
                square.isActive = true
            }
            islands.append(island)
            stack.addArrangedSubview(island)
        }
        statusButton.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        let tap = UITapGestureRecognizer(target: self, action: #selector(openSearch))
        tap.delegate = self
        view.addGestureRecognizer(tap)
        updateMaterials()
    }

    private func updateMaterials() {
        if #available(iOS 26.0, *), !UIAccessibility.isReduceTransparencyEnabled {
            let containerEffect = UIGlassContainerEffect()
            containerEffect.spacing = 8
            glassContainer.effect = containerEffect
            for (index, island) in islands.enumerated() {
                if index == 1 && !state.showsStatus {
                    island.effect = nil
                    island.backgroundColor = .clear
                    continue
                }
                let effect = UIGlassEffect(style: .regular)
                effect.isInteractive = !UIAccessibility.isReduceMotionEnabled
                island.effect = effect
                island.backgroundColor = .clear
                island.cornerConfiguration = .capsule()
            }
        } else {
            glassContainer.effect = nil
            for (index, island) in islands.enumerated() {
                if index == 1 && !state.showsStatus {
                    island.effect = nil
                    island.backgroundColor = .clear
                    continue
                }
                island.effect = UIAccessibility.isReduceTransparencyEnabled
                    ? nil : UIBlurEffect(style: .systemMaterial)
                island.backgroundColor = UIAccessibility.isReduceTransparencyEnabled
                    ? .secondarySystemBackground : .clear
                island.layer.cornerCurve = .continuous
                island.clipsToBounds = true
            }
        }
        view.setNeedsLayout()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        unreadDot.layer.borderColor = UIColor.systemBackground.cgColor
        if #available(iOS 26.0, *), !UIAccessibility.isReduceTransparencyEnabled {} else {
            for island in islands { island.layer.cornerRadius = island.bounds.height / 2 }
        }
    }

    func update(_ state: ChatListChromeState) {
        let statusVisibilityChanged = self.state.showsStatus != state.showsStatus
        self.state = state
        if isViewLoaded {
            render()
            if statusVisibilityChanged { updateMaterials() }
        }
    }

    private func render() {
        overrideUserInterfaceStyle = state.interfaceStyle
        var avatarConfig = UIButton.Configuration.plain()
        avatarConfig.image = state.avatar ?? UIImage(systemName: "person.crop.circle.fill")
        avatarConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 32)
        avatarConfig.baseForegroundColor = .secondaryLabel
        avatarConfig.contentInsets = NSDirectionalEdgeInsets(top: 6, leading: 6, bottom: 6, trailing: 6)
        avatarButton.configuration = avatarConfig
        unreadDot.isHidden = !state.unreadProfiles
        avatarButton.accessibilityValue = state.unreadProfiles
            ? NSLocalizedString("Unread messages", comment: "Other profiles have unread messages") : nil

        var titleConfig = UIButton.Configuration.plain()
        titleConfig.title = state.title
        if let percentage = state.percentage {
            if floating { titleConfig.subtitle = percentage }
            else { titleConfig.title = state.title + " " + percentage }
        }
        titleConfig.titleAlignment = .center
        titleConfig.imagePlacement = .trailing
        titleConfig.imagePadding = 5
        titleConfig.image = state.statusImage?.withTintColor(state.statusColor, renderingMode: .alwaysOriginal)
        titleConfig.baseForegroundColor = .label
        titleConfig.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var result = attributes
            result.font = UIFont.preferredFont(forTextStyle: .headline)
            return result
        }
        titleConfig.subtitleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attributes in
            var result = attributes
            result.font = UIFont.preferredFont(forTextStyle: .caption2)
            result.foregroundColor = UIColor.secondaryLabel
            return result
        }
        statusButton.configuration = titleConfig
        statusButton.isEnabled = state.running == true
        statusButton.isHidden = !state.showsStatus
        statusButton.accessibilityLabel = state.title
        statusButton.accessibilityValue = state.percentage
        var composeConfig = UIButton.Configuration.plain()
        composeConfig.image = UIImage(systemName: state.running == false ? "exclamationmark.octagon.fill" : "square.and.pencil")
        composeConfig.preferredSymbolConfigurationForImage = UIImage.SymbolConfiguration(pointSize: 22)
        composeConfig.baseForegroundColor = state.running == false ? .systemRed : state.tint
        composeButton.configuration = composeConfig
        islands[2].isHidden = state.running == nil
        view.setNeedsLayout()
    }

    // The original one-hand list is vertically inverted: its logical top is the
    // physical bottom. Both layouts therefore attach chrome to its logical top.
    func bindScrollView(_ scrollView: UIScrollView) {
        guard visible, boundScrollView !== scrollView else { return }
        unbindScrollView()
        guard #available(iOS 26.0, *) else { return }
        let previousStyle = scrollView.topEdgeEffect.style
        let previousHidden = scrollView.topEdgeEffect.isHidden
        let interaction = UIScrollEdgeElementContainerInteraction()
        interaction.scrollView = scrollView
        interaction.edge = .top
        view.addInteraction(interaction)
        scrollView.topEdgeEffect.style = .soft
        scrollView.topEdgeEffect.isHidden = false
        boundScrollView = scrollView
        detachEdge = { [weak scrollView, weak view] in
            view?.removeInteraction(interaction)
            scrollView?.topEdgeEffect.style = previousStyle
            scrollView?.topEdgeEffect.isHidden = previousHidden
        }
    }

    func unbindScrollView() {
        detachEdge?()
        detachEdge = nil
        boundScrollView = nil
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        visible = true
        visibilityChanged?(true)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        visible = false
        unbindScrollView()
        visibilityChanged?(false)
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        var current = touch.view
        while let candidate = current, candidate !== view {
            if candidate is UIControl { return false }
            current = candidate.superview
        }
        return true
    }

    @objc private func openProfile() { profileAction?() }
    @objc private func openStatus() { statusAction?() }
    @objc private func openCompose() { composeAction?() }
    @objc private func openSearch() { searchAction?() }

    deinit {
        detachEdge?()
        for observer in accessibilityObservers { NotificationCenter.default.removeObserver(observer) }
    }
}
