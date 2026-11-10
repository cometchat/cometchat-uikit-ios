import UIKit

// The compact composer's Add Link / Edit Link dialog: the Kit's own view, drawn as iOS 26's
// system alert (ENG-39659). These dialogs were a `UIAlertController` with two text fields; on
// iOS 26 that alert aborts the app in `-[_UIFlowLayoutInfo setSizes:forItemsAtIndexPaths:]`
// when the text size changes while one of its fields is editing (its fields are a private
// collection view), and on iOS 26.5 the same change collapses its two fields onto one row.
// This dialog has no collection view: plain text fields in a scroll view, which keep their
// text, focus and caret through a text-size change.
//
// Ported from UI Kit v6 (`Sources/CometChatUIKit/MessageComposer/ComposerLinkDialog.swift`,
// cometchat-team/uikit-ios#1038). v5 differences: iOS 15.1 deployment target, so the
// text-size observation falls back to `traitCollectionDidChange` before iOS 17 and the
// arrival uses the damping spring.
//
// The shape is `UIAlertController`'s (`addTextField`, `addAction`, `preferredAction`,
// `textFields`, `actions`), so the builders read as the alert code did; the behaviour is the
// alert's, measured on iOS 26.5:
// - the first field takes the focus as the dialog arrives; Return in a field moves to the
//   next one, and in the last field runs the return action — the preferred action, else the
//   one action that is not Cancel — enabled or not (`-[UIAlertController _handleReturn]`);
// - a button's handler runs once the dialog has gone; Escape (a hardware keyboard, or the
//   VoiceOver escape gesture) runs Cancel;
// - a tap on the dimmed backdrop runs `onTapOutside`, when set (the composer's
//   `presentAlertWithDismissGesture`).
//
// The look, measured from the system alert on iOS 26.5 (iPhone SE and 17 Pro, light and
// dark, default and AX sizes):
// - the backdrop: black at 20 % (light) / 48 % (dark), `_alertControllerDimmingViewColor`;
//   the tint behind it dimmed (`tintAdjustmentMode`);
// - the card: 320 wide (at the accessibility sizes, the screen less 18 each side), corner
//   34 continuous, Liquid Glass (`UIGlassEffect`, regular); centred in the safe area above
//   the keyboard, 8 clear of either edge, its content scrolling when it does not fit;
// - the title: body, regular, `label`, centred, 30 in from each side, 23.5 from the top;
// - the fields: one group 15 in from the card, 14 below the title, each row 48 high on
//   `tertiarySystemFill` with the group's corners 24, the field 15 in, body, `label`,
//   `placeholderText`; a 1-pt `quaternaryLabel` rule between rows, 15 in;
// - the buttons: 16 in from the card and 20 below the fields, 48 high (at least), 8 apart,
//   side by side while both titles fit and the size is not an accessibility size — else
//   stacked, Cancel last; corner 24; body 17 medium (the preferred action bold), `label` on
//   `tertiarySystemFill`; the preferred action white on the accent when enabled; a disabled
//   one the alert's lighter `tertiaryLabel` (`Metrics.disabledTitle`). The fills and the
//   rule sit in the glass, which treats them as the alert's; the text sits above it.
//
// The typeface and the accent are the Kit's, as everywhere else in the composer: the text is
// `CometChatTypography`'s typeface (the system font unless the integrator set one) at the
// alert's sizes, and the accent is `CometChatTheme.primaryColor`, not the tint.
//
// Before iOS 26 the card is a system material (`UIBlurEffect(.systemThickMaterial)`) in the
// same geometry. Under Reduce Transparency both materials turn opaque by themselves.

/// One of the dialog's buttons — `UIAlertAction`'s shape.
@MainActor
final class ComposerLinkDialogAction {
    let title: String
    let style: UIAlertAction.Style
    let handler: (() -> Void)?
    /// A disabled button takes no tap; Return in the last field still runs the return action,
    /// as the system alert's does.
    var isEnabled = true { didSet { if isEnabled != oldValue { onChange?() } } }
    fileprivate var onChange: (() -> Void)?

    init(title: String, style: UIAlertAction.Style, handler: (() -> Void)? = nil) {
        self.title = title
        self.style = style
        self.handler = handler
    }
}

/// The Add / Edit Link dialog. Presented over full screen; see the file comment.
@MainActor
final class ComposerLinkDialog: UIViewController, UITextFieldDelegate, UIViewControllerTransitioningDelegate {

    // MARK: Metrics (iOS 26.5's alert)

    enum Metrics {
        static let width: CGFloat = 320
        static let accessibilityMargin: CGFloat = 18
        static let screenMargin: CGFloat = 8
        static let cornerRadius: CGFloat = 34
        static let titleTop: CGFloat = 23.5
        static let titleInset: CGFloat = 30
        static let titleToFields: CGFloat = 14
        static let fieldsInset: CGFloat = 15
        static let rowHeight: CGFloat = 48
        static let rowCornerRadius: CGFloat = 24
        static let fieldInset: CGFloat = 15
        static let fieldToButtons: CGFloat = 20
        static let buttonsInset: CGFloat = 16
        static let buttonHeight: CGFloat = 48
        static let buttonSpacing: CGFloat = 8
        static let buttonCornerRadius: CGFloat = 24
        static let buttonTitleInset: CGFloat = 12
        /// The alert's text size: the title, the fields and the buttons.
        static let textSize: CGFloat = 17
        static let dimming = UIColor { $0.userInterfaceStyle == .dark
            ? UIColor(white: 0, alpha: 0.48) : UIColor(white: 0, alpha: 0.2) }
        /// A disabled title: the alert's action label follows its tint, a `tertiaryLabel`
        /// lighter than the named colour (measured: gray 0.237 at 23.8 % in light; 25.5 % of
        /// `tertiaryLabel`'s dark value in dark).
        static let disabledTitle = UIColor { $0.userInterfaceStyle == .dark
            ? UIColor.tertiaryLabel.resolvedColor(with: $0).withAlphaComponent(0.255)
            : UIColor(white: 0.237, alpha: 0.238) }
    }

    // MARK: The alert's shape

    private var fields: [UITextField] = []
    /// The text fields, in the order added (`UIAlertController.textFields`).
    var textFields: [UITextField]? { fields }
    private(set) var actions: [ComposerLinkDialogAction] = []
    /// Drawn bold, white on `CometChatTheme.primaryColor` while enabled, and run by Return in
    /// the last field.
    var preferredAction: ComposerLinkDialogAction? { didSet { buttons.forEach { $0.refresh() } } }
    /// A tap on the backdrop, outside the card: the dialog goes, then this runs. `nil`: the
    /// tap does nothing.
    var onTapOutside: (() -> Void)?

    // MARK: Views

    let dimmingView = UIView()
    /// The card — the alert's box, identified as `UIAlertController.view` was.
    let cardView = UIView()
    /// The card's material. The fills of the rows and buttons sit in its `contentView`, where
    /// the glass treats them as the system alert's are treated (`tertiarySystemFill` comes out
    /// darker in light, lighter and neutral in dark); the text sits above it, untreated, as the
    /// alert's does.
    let materialView: UIVisualEffectView = ComposerLinkDialog.makeMaterial()
    /// The rows' fills, in `materialView.contentView`.
    private(set) var rowFills: [UIView] = []
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    let titleLabel = UILabel()
    let fieldGroup = UIStackView()
    let buttonStack = UIStackView()
    private(set) var buttons: [ComposerLinkDialogButton] = []
    private var cardWidth: NSLayoutConstraint?
    private var finished = false
    private var focusedOnArrival = false
    /// What an action or a tap outside asked to run while the dialog was still arriving.
    private var leaveOnArrival: (() -> Void)?
    /// An input landed during the arrival: the dialog leaves once it has arrived.
    var leavesOnArrival: Bool { leaveOnArrival != nil }

    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
        modalPresentationStyle = .overFullScreen
        transitioningDelegate = self
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    /// Adds a text field (`UIAlertController.addTextField(configurationHandler:)`).
    func addTextField(configurationHandler: ((UITextField) -> Void)? = nil) {
        let field = UITextField()
        field.font = Self.font(CometChatTypography.Body.regular, weight: .regular)
        field.adjustsFontForContentSizeCategory = CometChatTypography.isDynamicTypeEnabled
        field.textColor = .label
        field.borderStyle = .none
        field.backgroundColor = .clear
        field.delegate = self
        configurationHandler?(field)
        fields.append(field)
        if isViewLoaded { rebuildFields() }
    }

    /// Adds a button (`UIAlertController.addAction(_:)`).
    func addAction(_ action: ComposerLinkDialogAction) {
        actions.append(action)
        action.onChange = { [weak self] in self?.buttons.forEach { $0.refresh() } }
        if isViewLoaded { rebuildButtons() }
    }

    /// Runs `action` as a tap on its button would: the dialog goes, then the handler runs
    /// (at once when the dialog is not on screen). Once only.
    func perform(_ action: ComposerLinkDialogAction) {
        guard !finished else { return }
        finished = true
        if isViewLoaded { view.endEditing(true) }
        leave { action.handler?() }
    }

    /// The dialog goes, then `then` runs — at once when the dialog is not presented. The
    /// dialog is held until `then` has run: a handler reads the fields through a weak
    /// reference, as a `UIAlertAction`'s does.
    private func leave(then: @escaping () -> Void) {
        guard presentingViewController != nil else { then(); return }
        guard !isBeingPresented else {
            // Still arriving: the 0.4-s spring takes touches and raises the keyboard, and a
            // hardware Return or Escape can land at any time. A dismiss now relies on UIKit to
            // hold it to the end of the arrival. iOS 18.2 and 26.5 do, but a refused dismiss
            // drops its completion: the handler would never run, every later input would be
            // spent, and the dialog would stay up. So leave once it has arrived instead.
            leaveOnArrival = then
            return
        }
        dismiss(animated: true) { [self] in withExtendedLifetime(self) { then() } }
    }

    /// What Return in the last field runs: the preferred action, else the one action that is
    /// not Cancel (`-[UIAlertController _actionForReturnKey]`).
    var returnKeyAction: ComposerLinkDialogAction? {
        if let preferredAction { return preferredAction }
        let others = actions.filter { $0.style != .cancel }
        return others.count == 1 ? others[0] : nil
    }

    /// Cancel — Escape's action.
    var cancelAction: ComposerLinkDialogAction? { actions.first { $0.style == .cancel } }

    // MARK: Lifecycle

    override func loadView() {
        let root = ComposerLinkDialogRootView()
        root.onEscape = { [weak self] in self?.escape() ?? false }
        view = root
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear

        dimmingView.backgroundColor = Metrics.dimming
        dimmingView.translatesAutoresizingMaskIntoConstraints = false
        dimmingView.isAccessibilityElement = false
        dimmingView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tappedBackdrop)))
        view.addSubview(dimmingView)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = Metrics.cornerRadius
        cardView.layer.cornerCurve = .continuous
        cardView.accessibilityViewIsModal = true
        view.addSubview(cardView)
        materialView.translatesAutoresizingMaskIntoConstraints = false
        materialView.isUserInteractionEnabled = false
        if #available(iOS 26.0, *) {
            materialView.cornerConfiguration = .uniformCorners(radius: .fixed(Double(Metrics.cornerRadius)))
        } else {
            materialView.layer.cornerRadius = Metrics.cornerRadius
            materialView.layer.cornerCurve = .continuous
            materialView.clipsToBounds = true
        }
        cardView.addSubview(materialView)

        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.alwaysBounceVertical = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.keyboardDismissMode = .none
        scrollView.backgroundColor = .clear
        cardView.addSubview(scrollView)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.addSubview(contentView)

        titleLabel.text = title
        titleLabel.font = Self.font(CometChatTypography.Body.regular, weight: .regular)
        titleLabel.adjustsFontForContentSizeCategory = CometChatTypography.isDynamicTypeEnabled
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)

        fieldGroup.axis = .vertical
        fieldGroup.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(fieldGroup)

        buttonStack.spacing = Metrics.buttonSpacing
        buttonStack.distribution = .fillEqually
        buttonStack.alignment = .fill
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(buttonStack)

        layOut()
        rebuildFields()
        rebuildButtons()
        applySize()

        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (dialog: ComposerLinkDialog, _: UITraitCollection) in
                dialog.applySize()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardMoved),
                                               name: UIResponder.keyboardDidChangeFrameNotification, object: nil)
    }

    /// Before iOS 17 (no `registerForTraitChanges`): a text-size change re-derives the layout.
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        guard #unavailable(iOS 17.0), isViewLoaded,
              previousTraitCollection?.preferredContentSizeCategory != traitCollection.preferredContentSizeCategory
        else { return }
        applySize()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let then = leaveOnArrival {
            leaveOnArrival = nil
            // On the next turn: the presentation is still completing while this runs.
            DispatchQueue.main.async { [self] in leave(then: then) }
            return
        }
        focusOnArrival()
    }

    /// As the system alert: the first field edits as the dialog arrives, the keyboard rising
    /// with it — called by the transition once the dialog is in the window, and on appearing.
    func focusOnArrival() {
        guard !focusedOnArrival, !finished, view.window != nil, let first = fields.first else { return }
        focusedOnArrival = first.becomeFirstResponder()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        applyWidth()
    }

    override var keyCommands: [UIKeyCommand]? {
        let escape = UIKeyCommand(input: UIKeyCommand.inputEscape, modifierFlags: [], action: #selector(escapeKey))
        escape.wantsPriorityOverSystemBehavior = true
        return [escape]
    }

    // MARK: Layout

    private func layOut() {
        let safe = view.safeAreaLayoutGuide
        let keyboard = view.keyboardLayoutGuide
        let area = UILayoutGuide()
        view.addLayoutGuide(area)
        // The card is its content's height — below every content priority, so a card that
        // does not fit scrolls its content rather than squeezing it.
        let fitted = cardView.heightAnchor.constraint(equalTo: contentView.heightAnchor)
        fitted.priority = UILayoutPriority(700)
        let width = cardView.widthAnchor.constraint(equalToConstant: Metrics.width)
        cardWidth = width
        let buttonTop = buttonStack.topAnchor.constraint(equalTo: fieldGroup.bottomAnchor, constant: Metrics.fieldToButtons)
        NSLayoutConstraint.activate([
            dimmingView.topAnchor.constraint(equalTo: view.topAnchor),
            dimmingView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            dimmingView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            dimmingView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // The safe area above the keyboard, 8 clear of either edge.
            area.topAnchor.constraint(equalTo: safe.topAnchor, constant: Metrics.screenMargin),
            area.bottomAnchor.constraint(equalTo: keyboard.topAnchor, constant: -Metrics.screenMargin),
            area.bottomAnchor.constraint(lessThanOrEqualTo: safe.bottomAnchor, constant: -Metrics.screenMargin),
            area.leadingAnchor.constraint(equalTo: safe.leadingAnchor),
            area.trailingAnchor.constraint(equalTo: safe.trailingAnchor),

            cardView.centerXAnchor.constraint(equalTo: area.centerXAnchor),
            cardView.centerYAnchor.constraint(equalTo: area.centerYAnchor),
            cardView.topAnchor.constraint(greaterThanOrEqualTo: area.topAnchor),
            cardView.bottomAnchor.constraint(lessThanOrEqualTo: area.bottomAnchor),
            width,
            fitted,

            materialView.topAnchor.constraint(equalTo: cardView.topAnchor),
            materialView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            materialView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            materialView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: cardView.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),

            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Metrics.titleTop),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.titleInset),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.titleInset),

            fieldGroup.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: Metrics.titleToFields),
            fieldGroup.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.fieldsInset),
            fieldGroup.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.fieldsInset),

            buttonTop,
            buttonStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Metrics.buttonsInset),
            buttonStack.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -Metrics.buttonsInset),
            buttonStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -Metrics.buttonsInset),
        ])
    }

    private func rebuildFields() {
        fieldGroup.arrangedSubviews.forEach { $0.removeFromSuperview() }
        rowFills.forEach { $0.removeFromSuperview() }
        rowFills = []
        for (index, field) in fields.enumerated() {
            let row = UIView()
            let fill = UIView()
            fill.backgroundColor = .tertiarySystemFill
            fill.layer.cornerRadius = Metrics.rowCornerRadius
            var corners: CACornerMask = []
            if index == 0 { corners.formUnion([.layerMinXMinYCorner, .layerMaxXMinYCorner]) }
            if index == fields.count - 1 { corners.formUnion([.layerMinXMaxYCorner, .layerMaxXMaxYCorner]) }
            fill.layer.maskedCorners = corners
            fill.isUserInteractionEnabled = false
            rowFills.append(fill)
            field.translatesAutoresizingMaskIntoConstraints = false
            row.addSubview(field)
            let minimum = row.heightAnchor.constraint(greaterThanOrEqualToConstant: Metrics.rowHeight)
            NSLayoutConstraint.activate([
                minimum,
                field.leadingAnchor.constraint(equalTo: row.leadingAnchor, constant: Metrics.fieldInset),
                field.trailingAnchor.constraint(equalTo: row.trailingAnchor, constant: -Metrics.fieldInset),
                // Half a point low, as the alert's 35-pt field sits 7 into its 48-pt row.
                field.centerYAnchor.constraint(equalTo: row.centerYAnchor, constant: 0.5),
                field.topAnchor.constraint(greaterThanOrEqualTo: row.topAnchor, constant: 6),
            ])
            // Rows as short as they may be: 48, or the field's line when it is taller.
            let hug = row.heightAnchor.constraint(equalToConstant: Metrics.rowHeight)
            hug.priority = .defaultLow
            hug.isActive = true
            fieldGroup.addArrangedSubview(row)
            track(row, with: fill)
            if index < fields.count - 1 {
                // The rule between rows, in the material too.
                let rule = UIView()
                rule.backgroundColor = .quaternaryLabel
                rule.isUserInteractionEnabled = false
                rule.translatesAutoresizingMaskIntoConstraints = false
                fill.addSubview(rule)
                NSLayoutConstraint.activate([
                    rule.heightAnchor.constraint(equalToConstant: 1),
                    rule.bottomAnchor.constraint(equalTo: fill.bottomAnchor),
                    rule.leadingAnchor.constraint(equalTo: fill.leadingAnchor, constant: Metrics.fieldInset),
                    rule.trailingAnchor.constraint(equalTo: fill.trailingAnchor, constant: -Metrics.fieldInset),
                ])
            }
        }
    }

    /// Puts `fill` in the material, over `view`'s frame wherever it moves.
    private func track(_ view: UIView, with fill: UIView) {
        fill.translatesAutoresizingMaskIntoConstraints = false
        materialView.contentView.addSubview(fill)
        NSLayoutConstraint.activate([
            fill.topAnchor.constraint(equalTo: view.topAnchor),
            fill.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            fill.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fill.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }

    private func rebuildButtons() {
        buttons.forEach { $0.removeFromSuperview(); $0.fill.removeFromSuperview() }
        buttons = actions.map { action in
            let button = ComposerLinkDialogButton(action: action, dialog: self)
            button.addTarget(self, action: #selector(tapped(_:)), for: .touchUpInside)
            return button
        }
        arrangeButtons()
        buttons.forEach { track($0, with: $0.fill) }
    }

    /// Side by side while both titles fit and the size is not an accessibility size;
    /// stacked otherwise, Cancel last. Cancel leads in a row (the system alert's order).
    private func arrangeButtons() {
        buttonStack.arrangedSubviews.forEach { buttonStack.removeArrangedSubview($0) }
        let cancelFirst = buttons.sorted { a, b in a.action.style == .cancel && b.action.style != .cancel }
        let stacked = shouldStack
        buttonStack.axis = stacked ? .vertical : .horizontal
        let ordered = stacked ? cancelFirst.filter { $0.action.style != .cancel } + cancelFirst.filter { $0.action.style == .cancel }
                              : cancelFirst
        ordered.forEach { buttonStack.addArrangedSubview($0) }
    }

    private var isAccessibilitySize: Bool { traitCollection.preferredContentSizeCategory.isAccessibilityCategory }

    private var shouldStack: Bool {
        if isAccessibilitySize || buttons.count > 2 { return true }
        let width = currentCardWidth
        let slot = (width - 2 * Metrics.buttonsInset - Metrics.buttonSpacing * CGFloat(max(buttons.count - 1, 0)))
            / CGFloat(max(buttons.count, 1))
        return buttons.contains { $0.naturalTitleWidth + 2 * Metrics.buttonTitleInset > slot }
    }

    private var currentCardWidth: CGFloat {
        let available = (view.window?.bounds.width ?? view.bounds.width) - 2 * Metrics.accessibilityMargin
        guard available > 0 else { return Metrics.width }
        return isAccessibilitySize ? available : min(Metrics.width, available)
    }

    private func applyWidth() {
        let width = currentCardWidth
        if cardWidth?.constant != width {
            cardWidth?.constant = width
            arrangeButtons()
        }
    }

    /// A text-size change: fonts follow by themselves; the card's width, the buttons' axis
    /// and the scroll position are re-derived. The editing field keeps its text, focus and caret.
    private func applySize() {
        buttons.forEach { $0.refresh() }
        cardWidth?.constant = currentCardWidth
        arrangeButtons()
        view.setNeedsLayout()
        view.layoutIfNeeded()
        revealEditingField()
    }

    /// Keeps the editing field in view when the card scrolls.
    private func revealEditingField() {
        guard let field = fields.first(where: { $0.isFirstResponder }), let row = field.superview else { return }
        scrollView.layoutIfNeeded()
        let frame = row.convert(row.bounds, to: scrollView)
        scrollView.scrollRectToVisible(frame.insetBy(dx: 0, dy: -Metrics.fieldsInset), animated: false)
    }

    // MARK: Events

    @objc private func tapped(_ sender: ComposerLinkDialogButton) {
        guard sender.action.isEnabled else { return }
        perform(sender.action)
    }

    @objc private func tappedBackdrop(_ gesture: UITapGestureRecognizer) {
        guard !cardView.bounds.contains(gesture.location(in: cardView)) else { return }
        tapOutside()
    }

    /// A tap on the backdrop: with `onTapOutside` set, the dialog goes, then it runs. Once only.
    func tapOutside() {
        guard let onTapOutside, !finished else { return }
        finished = true
        view.endEditing(true)
        leave(then: onTapOutside)
    }

    @objc private func keyboardMoved() {
        guard isViewLoaded, view.window != nil else { return }
        view.layoutIfNeeded()
        revealEditingField()
    }

    @objc private func escapeKey() { _ = escape() }

    private func escape() -> Bool {
        guard let cancelAction else { return false }
        perform(cancelAction)
        return true
    }

    // MARK: UITextFieldDelegate

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        guard let index = fields.firstIndex(of: textField) else { return true }
        if index + 1 < fields.count {
            fields[index + 1].becomeFirstResponder()
        } else if let action = returnKeyAction {
            perform(action)
        }
        return false
    }

    func textFieldDidBeginEditing(_ textField: UITextField) { revealEditingField() }

    // MARK: Transition

    func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                             source: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        ComposerLinkDialogTransition(presenting: true)
    }

    func animationController(forDismissed dismissed: UIViewController) -> (any UIViewControllerAnimatedTransitioning)? {
        ComposerLinkDialogTransition(presenting: false)
    }

    fileprivate var transitionViews: (dimming: UIView, card: UIView) { (dimmingView, cardView) }
    /// The tint mode of the screen behind, put back when the dialog goes.
    fileprivate var tintModeBehind: UIView.TintAdjustmentMode?

    /// `typography`'s typeface (an integrator's `CometChatTypography.setFont(name:)` or
    /// override; else the system font at `weight`) at the alert's 17 pt, scaled with the text
    /// size as the alert's text is, unless the integrator turned the Kit's Dynamic Type off.
    static func font(_ typography: UIFont, weight: UIFont.Weight,
                     compatibleWith traits: UITraitCollection? = nil) -> UIFont {
        // The system font's name is private (".SFUI-…"): it cannot be looked up by name.
        let named = typography.familyName.hasPrefix(".") ? nil : UIFont(name: typography.fontName, size: Metrics.textSize)
        let base = named ?? .systemFont(ofSize: Metrics.textSize, weight: weight)
        guard CometChatTypography.isDynamicTypeEnabled else { return base }
        return UIFontMetrics(forTextStyle: .body).scaledFont(for: base, compatibleWith: traits)
    }

    private static func makeMaterial() -> UIVisualEffectView {
        if #available(iOS 26.0, *) {
            return UIVisualEffectView(effect: UIGlassEffect(style: .regular))
        }
        return UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
    }
}

/// The dialog's root view: Escape from VoiceOver (the two-finger scrub) runs Cancel.
private final class ComposerLinkDialogRootView: UIView {
    var onEscape: (() -> Bool)?
    override func accessibilityPerformEscape() -> Bool { onEscape?() ?? false }
}

/// A button of the dialog — the system alert's capsule: body text, bold when preferred,
/// on `tertiarySystemFill`, or white on `CometChatTheme.primaryColor` for an enabled
/// preferred action.
@MainActor
final class ComposerLinkDialogButton: UIControl {
    let action: ComposerLinkDialogAction
    private weak var dialog: ComposerLinkDialog?
    let label = UILabel()
    private var titleTop: NSLayoutConstraint?
    /// The capsule — placed by the dialog in its material, over this button.
    let fill = UIView()

    init(action: ComposerLinkDialogAction, dialog: ComposerLinkDialog) {
        self.action = action
        self.dialog = dialog
        super.init(frame: .zero)
        fill.isUserInteractionEnabled = false
        fill.layer.cornerRadius = ComposerLinkDialog.Metrics.buttonCornerRadius
        fill.layer.cornerCurve = .continuous
        label.text = action.title
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontForContentSizeCategory = CometChatTypography.isDynamicTypeEnabled
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)
        let inset = ComposerLinkDialog.Metrics.buttonTitleInset
        let top = label.topAnchor.constraint(greaterThanOrEqualTo: topAnchor, constant: inset)
        titleTop = top
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: ComposerLinkDialog.Metrics.buttonHeight),
            // Half a point low: the alert's title sits in a 24.5-pt line box 12 from the top.
            label.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 0.5),
            top,
            label.leadingAnchor.constraint(greaterThanOrEqualTo: leadingAnchor, constant: inset),
            label.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -inset),
            label.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
        // Buttons as short as they may be: 48, or the title's lines when they are taller —
        // without this a button keeps an accessibility size's height when the text shrinks
        // back (v6 lacks it).
        let hug = heightAnchor.constraint(equalToConstant: ComposerLinkDialog.Metrics.buttonHeight)
        hug.priority = .defaultLow
        hug.isActive = true
        isAccessibilityElement = true
        accessibilityLabel = action.title
        showsLargeContentViewer = true
        largeContentTitle = action.title
        addInteraction(UILargeContentViewerInteraction())
        refresh()
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError("init(coder:) is not supported") }

    var isPreferred: Bool { dialog?.preferredAction === action }

    /// The title's width on one line, for the side-by-side decision.
    var naturalTitleWidth: CGFloat {
        (action.title as NSString).size(withAttributes: [.font: titleFont]).width.rounded(.up)
    }

    /// The text size to draw at: the dialog's, which is current when it re-derives the layout
    /// on a text-size change — a button's own traits can still be the previous size then, which
    /// left the buttons stacked and tall after a return from an accessibility size (v6 reads
    /// the button's own).
    private var sizeTraits: UITraitCollection { dialog?.traitCollection ?? traitCollection }

    private var titleFont: UIFont {
        isPreferred ? ComposerLinkDialog.font(CometChatTypography.Body.bold, weight: .bold, compatibleWith: sizeTraits)
            : ComposerLinkDialog.font(CometChatTypography.Body.medium, weight: .medium, compatibleWith: sizeTraits)
    }

    override var isHighlighted: Bool { didSet { refresh() } }

    override var accessibilityTraits: UIAccessibilityTraits {
        get { action.isEnabled ? .button : [.button, .notEnabled] }
        set {}
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        refresh()
    }

    /// Re-derives the colours and font from the action's state.
    func refresh() {
        let enabled = action.isEnabled
        if isEnabled != enabled { isEnabled = enabled }
        let filled = isPreferred && enabled
        label.font = titleFont
        // The alert's 12-pt title inset grows with the text size — to 31 at AX5, as `title2`
        // scales (measured on iOS 26.5).
        titleTop?.constant = UIFontMetrics(forTextStyle: .title2)
            .scaledValue(for: ComposerLinkDialog.Metrics.buttonTitleInset, compatibleWith: sizeTraits)
        label.textColor = !enabled ? ComposerLinkDialog.Metrics.disabledTitle
            : filled ? .white
            : action.style == .destructive ? .systemRed : .label
        let pressed = isHighlighted && enabled
        let accent = CometChatTheme.primaryColor
        fill.backgroundColor = filled ? (pressed ? accent.withAlphaComponent(0.75) : accent)
            : (pressed ? .secondarySystemFill : .tertiarySystemFill)
    }
}

/// The alert's arrival — the backdrop fades in as the card grows from 1.1× into place — and
/// its exit, a fade.
@MainActor
private final class ComposerLinkDialogTransition: NSObject, UIViewControllerAnimatedTransitioning {
    let presenting: Bool

    init(presenting: Bool) { self.presenting = presenting }

    func transitionDuration(using context: (any UIViewControllerContextTransitioning)?) -> TimeInterval {
        presenting ? 0.4 : 0.2
    }

    func animateTransition(using context: any UIViewControllerContextTransitioning) {
        let key: UITransitionContextViewControllerKey = presenting ? .to : .from
        guard let dialog = context.viewController(forKey: key) as? ComposerLinkDialog else {
            context.completeTransition(!context.transitionWasCancelled)
            return
        }
        let (dimming, card) = dialog.transitionViews
        // As behind the system alert, the screen's tint dims while the dialog is up.
        let behind = context.containerView.window?.rootViewController?.view
        if presenting {
            dialog.view.frame = context.finalFrame(for: dialog)
            context.containerView.addSubview(dialog.view)
            dialog.view.layoutIfNeeded()
            dialog.focusOnArrival()
            dialog.tintModeBehind = behind?.tintAdjustmentMode
            behind?.tintAdjustmentMode = .dimmed
        } else if let mode = dialog.tintModeBehind {
            behind?.tintAdjustmentMode = mode
        }
        let finish = { context.completeTransition(!context.transitionWasCancelled) }
        guard context.isAnimated else {
            if !presenting { dialog.view.removeFromSuperview() }
            finish()
            return
        }
        if presenting {
            dimming.alpha = 0
            card.alpha = 0
            if !UIAccessibility.isReduceMotionEnabled { card.transform = CGAffineTransform(scaleX: 1.1, y: 1.1) }
            // v6's `animate(springDuration:bounce: 0.15)` is iOS 17+; this damping spring is
            // the same curve on iOS 15.
            UIView.animate(withDuration: transitionDuration(using: context), delay: 0, usingSpringWithDamping: 0.85,
                           initialSpringVelocity: 0, options: [.allowUserInteraction]) {
                dimming.alpha = 1
                card.alpha = 1
                card.transform = .identity
            } completion: { _ in finish() }
        } else {
            UIView.animate(withDuration: transitionDuration(using: context), delay: 0, options: [.curveEaseOut]) {
                dimming.alpha = 0
                card.alpha = 0
            } completion: { _ in
                dialog.view.removeFromSuperview()
                finish()
            }
        }
    }
}
