//
//  MessagePopupViewController.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 28/09/24.
//

import UIKit
import CometChatSDK

class MessagePopupViewController: UIViewController {
    
    lazy var reactionView: CometChatQuickReactions = {
        let reactionView = CometChatQuickReactions()
        return reactionView
    }()
    
    lazy var emojiKeyboard : CometChatEmojiKeyboard = {
        let emojiKeyboard = CometChatEmojiKeyboard()
        return emojiKeyboard
    }()
    
    lazy var optionMenuTableView: ContextMenuTableView = {
        let contextMenuTableView = ContextMenuTableView(frame: .infinite, style: .plain)
        contextMenuTableView.didSelect = { [weak self] option in
            if let self {
                self.dismiss(animated: true) {
                    // Clear the host's menu state before the action runs, so a stale
                    // latch can never block the next long press.
                    self.notifyDismissal()
                    self.messageOptionDelegate?.onItemClick(messageOption: option, forMessage: self.baseMessage, indexPath: nil)
                }
            }
        }
        contextMenuTableView.separatorStyle = .singleLine
        contextMenuTableView.onToggleExpanded = { [weak self] in
            self?.relayoutOptionMenu(animated: true)
        }
        return contextMenuTableView
    }()
    
    lazy var blurBackgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemUltraThinMaterial)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        return blurEffectView
    }()
    
    var messageAlignment: MessageBubbleAlignment = .left
    var messageSnapShotView: UIView!
    var bubbleFrame: CGRect! {
        didSet {
            bubbleCoordinates = bubbleFrame.origin
        }
    }
    var baseMessage: BaseMessage!
    var bubbleCoordinates: CGPoint!
    var minY = CGFloat(80)
    var maxY = UIScreen.main.bounds.height - 40
    var reactionViewHeight = 40
    var spacing = 10
    weak var messageOptionDelegate: CometChatMessageOptionDelegate?
    /// Fires once the popup is actually off screen, on every dismissal path.
    /// The host clears its context-menu state here rather than in the animator,
    /// which is skipped when no animator is returned.
    var onDismissed: (() -> Void)?
    private var didNotifyDismissal = false
    /// Set before `messageOptions`, which forwards it.
    var splitsOverflow = true

    var messageOptions: [CometChatMessageOption] = [] {
        didSet {
            optionMenuTableView.splitsOverflow = splitsOverflow
            optionMenuTableView.messageOptions = messageOptions
            optionMenuTableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        blurBackgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(onViewTap)))
    }
    
    func makeViewsUnhidden() {
        reactionView.isHidden = false
        optionMenuTableView.isHidden = false
        messageSnapShotView.isHidden = false
    }
    
    func makeViewsHidden() {
        reactionView.isHidden = true
        optionMenuTableView.isHidden = true
        messageSnapShotView.isHidden = true
    }
    
    func openEmojiKeyboard() {
        //add emojiKeyboard as a childviewcontroller
        addChild(emojiKeyboard)
        self.view.addSubview(emojiKeyboard.view)
        emojiKeyboard.view.frame = view.bounds
        emojiKeyboard.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        emojiKeyboard.didMove(toParent: self)
        emojiKeyboard.hide(headerView: true)
        emojiKeyboard.view.roundViewCorners(corner: .init(cornerRadius: 20))
        emojiKeyboard.view.backgroundColor = reactionView.backgroundColor
        
        var doesBubbleViewNeedsToMove = false
        if (reactionView.frame.maxY - 300) > minY {
            emojiKeyboard.view.frame = CGRect(
                x: messageAlignment == .left ? Int(self.reactionView.frame.minX) : Int(self.reactionView.frame.maxX - 300) ,
                y: Int(reactionView.frame.maxY - 300),
                width: 300,
                height: 300
            )
        } else {
            doesBubbleViewNeedsToMove = true
            emojiKeyboard.view.frame = CGRect(
                x: messageAlignment == .left ? Int(self.reactionView.frame.minX) : Int(self.reactionView.frame.maxX - 300),
                y: Int(reactionView.frame.maxY - 300) + Int(minY - (reactionView.frame.maxY - 300) ),
                width: 300,
                height: 300
            )
        }
        
        emojiKeyboard.view.alpha = 0
        optionMenuTableView.alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            
            self.emojiKeyboard.view.alpha = 1
            self.reactionView.alpha = 0
            self.reactionView.frame = self.emojiKeyboard.view.frame
            
            if doesBubbleViewNeedsToMove {
                self.messageSnapShotView.frame = CGRect(
                    x:  self.messageSnapShotView.frame.origin.x,
                    y: (self.emojiKeyboard.view.frame.maxY + CGFloat(self.spacing)),
                    width: self.messageSnapShotView.frame.width,
                    height: self.messageSnapShotView.frame.height
                )
            }
        } completion: { _ in
            self.reactionView.isHidden = true
        }
    }
    
    func buildUI() {
        addBlurBackground()

        view.addSubview(messageSnapShotView)
        view.addSubview(reactionView)
        view.addSubview(optionMenuTableView)

        layoutOptionMenu()
    }

    /// Height the menu wants, capped to the visible band so a long list stays reachable.
    /// The row count changes at runtime once the "More" row can expand, so this is
    /// clamped rather than growing unbounded off-screen.
    private var optionMenuHeight: CGFloat {
        let contentHeight = CGFloat(optionMenuTableView.displayedOptions.count * 44)
        return min(contentHeight, maxY - minY)
    }

    /// Lays out all three views and applies the safe-area corrections. Split out of
    /// `buildUI()` so the "More" toggle can re-run it — every frame is recomputed from
    /// `bubbleCoordinates` first, because the corrections below are cumulative (`+=`/`-=`)
    /// and would drift on each toggle if applied to the previous pass's positions.
    private func layoutOptionMenu() {
        messageSnapShotView.frame = CGRect(
            x: bubbleCoordinates.x,
            y: bubbleCoordinates.y,
            width: messageSnapShotView.bounds.width,
            height: messageSnapShotView.bounds.height
        )

        reactionView.frame = CGRect(
            x: messageAlignment == .right ? Int(bubbleCoordinates.x + (messageSnapShotView.bounds.width - 238)) : Int(bubbleCoordinates.x),
            y: (Int(bubbleCoordinates.y) - reactionViewHeight - spacing),
            width: 238,
            height: reactionViewHeight
        )

        optionMenuTableView.frame = CGRect(
            x: messageAlignment == .right ? Int(bubbleCoordinates.x + (messageSnapShotView.bounds.width - 250)) : Int(bubbleCoordinates.x),
            y: (Int(bubbleCoordinates.y) + Int(messageSnapShotView.bounds.height) + spacing ),
            width: 250,
            height: Int(optionMenuHeight)
        )

        // Scrollable only when the cap actually bit.
        let isCapped = CGFloat(optionMenuTableView.displayedOptions.count * 44) > optionMenuHeight
        optionMenuTableView.isScrollEnabled = isCapped
        optionMenuTableView.alwaysBounceVertical = false

        //If there is not enough space in bottom then message bubble will shift upwards
        if optionMenuTableView.frame.maxY > maxY {
            let differenceSafeAre = optionMenuTableView.frame.maxY - maxY
            optionMenuTableView.frame.origin.y -= differenceSafeAre
            reactionView.frame.origin.y -= differenceSafeAre
            messageSnapShotView.frame.origin.y -= differenceSafeAre
        }

        if reactionView.frame.minY < minY {
            let differenceSafeAre = minY - reactionView.frame.minY
            optionMenuTableView.frame.origin.y += differenceSafeAre
            reactionView.frame.origin.y += differenceSafeAre
            messageSnapShotView.frame.origin.y += differenceSafeAre
        }

        //if bubble view is bigger and all this views are not getting fit in the screen then adjusting the optionMenuTableView's frame
        if (messageSnapShotView.frame.height + reactionView.frame.height + minY + optionMenuTableView.frame.height) > UIScreen.main.bounds.height {
            optionMenuTableView.frame.origin.y = (maxY - (optionMenuTableView.frame.height))
        }
    }

    /// Re-runs the menu layout after the row count changed. The presentation animator
    /// only touches `transform`/`alpha` and never reads this frame, so resizing after
    /// present is safe.
    func relayoutOptionMenu(animated: Bool) {
        guard animated else {
            layoutOptionMenu()
            return
        }
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut) {
            self.layoutOptionMenu()
        }
    }

    @objc func onViewTap() {
        dismiss(animated: true, completion: nil)
    }
    
    func addBlurBackground() {
        view.backgroundColor = UIColor.clear
        blurBackgroundView.frame = view.bounds
        blurBackgroundView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(blurBackgroundView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        handleThemeModeChange()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        notifyDismissal()
    }

    /// Idempotent: the option path notifies early so the host's state is clear before
    /// an action reloads the table, and `viewDidDisappear` is the backstop for every
    /// other path (tap-outside, trait change, programmatic dismiss).
    func notifyDismissal() {
        guard !didNotifyDismissal else { return }
        didNotifyDismissal = true
        onDismissed?()
    }
    
    open func handleThemeModeChange() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                self.dismiss(animated: true)
            })
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Check if the user interface style has changed
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.dismiss(animated: true)
        }
    }
    
}


class ContextMenuTableView: UITableView, UITableViewDataSource, UITableViewDelegate {

    var didSelect: ((_ option: CometChatMessageOption) -> Void)?
    /// Fired after the "More" row flips `expanded`, so the host can resize the menu.
    var onToggleExpanded: (() -> Void)?

    private(set) var primaryOptions: [CometChatMessageOption] = []
    private(set) var overflowOptions: [CometChatMessageOption] = []
    private(set) var expanded = false

    /// Off for surfaces short enough to show whole.
    var splitsOverflow = true

    var messageOptions: [CometChatMessageOption] = [] {
        didSet {
            guard splitsOverflow else {
                primaryOptions = messageOptions
                overflowOptions = []
                expanded = false
                return
            }
            let split = MessageOptionConstants.partition(messageOptions)
            primaryOptions = split.primary
            overflowOptions = split.overflow
            expanded = false
        }
    }

    private var hasOverflow: Bool { !overflowOptions.isEmpty }

    /// The "More" row is appended to whichever list is showing, so it stays reachable
    /// on both screens and toggles back — it is not a one-way push.
    private var moreOption: CometChatMessageOption {
        CometChatMessageOption(
            id: MessageOptionConstants.moreOptions,
            title: "MORE_OPTIONS".localize(),
            icon: AssetConstants.more
        )
    }

    /// Rows currently on screen. Callers must go through this rather than
    /// `messageOptions`, which is the unsplit input.
    var displayedOptions: [CometChatMessageOption] {
        guard hasOverflow else { return primaryOptions }
        return (expanded ? overflowOptions : primaryOptions) + [moreOption]
    }

    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        setUp()
    }
    
    func setUp() {
        dataSource = self
        delegate = self
        layoutMargins = UIEdgeInsets.zero
        separatorInset = UIEdgeInsets.zero
        self.register(ContextMenuTextCell.self, forCellReuseIdentifier: ContextMenuTextCell.identifier)
        
        roundViewCorners(corner: .init(cornerRadius: CometChatSpacing.Radius.r3))
        alwaysBounceVertical = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayedOptions.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ContextMenuTextCell.identifier , for: indexPath) as? ContextMenuTextCell {
            cell.layoutMargins = UIEdgeInsets.zero
            let option = displayedOptions[indexPath.row]
            cell.titleLabel.text = option.title
            cell.iconImageView.image = option.icon
            cell.style = option.style
            cell.isAccessibilityElement = true
            cell.accessibilityTraits = .button
            if option.id == MessageOptionConstants.moreOptions {
                // VoiceOver would otherwise read the ellipsis title as punctuation.
                cell.accessibilityLabel = "MORE_OPTIONS".localize()
                cell.accessibilityValue = expanded
                    ? "MORE_OPTIONS_EXPANDED".localize()
                    : "MORE_OPTIONS_COLLAPSED".localize()
            } else {
                cell.accessibilityLabel = option.title
                cell.accessibilityValue = nil
            }
            return cell
        }
        return UITableViewCell()
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let option = displayedOptions[indexPath.row]

        // Handled here rather than through the delegate: the popup dismisses itself
        // before the delegate fires, which would close the menu instead of toggling it.
        guard option.id != MessageOptionConstants.moreOptions else {
            deselectRow(at: indexPath, animated: false)
            expanded.toggle()
            reloadData()
            onToggleExpanded?()
            return
        }

        didSelect?(option)
    }

}


class ContextMenuTextCell: UITableViewCell {
    
    lazy var titleLabel: UILabel = {
        let tLabel = UILabel()
        tLabel.translatesAutoresizingMaskIntoConstraints = false
        return tLabel
    }()
    
    lazy var iconImageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.translatesAutoresizingMaskIntoConstraints = false
        imgView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        imgView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        return imgView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [titleLabel, iconImageView])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = 8
        return stackView
    }()
    
    var style = MessageOptionStyle() {
        didSet {
            setup()
        }
    }
    static var identifier = "ContextMenuTextCell"
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit() {
        
        contentView.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
        ])
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.text = nil
        iconImageView.image = nil
        
    }
    
    open func setup(){
        titleLabel.font = style.titleFont
        titleLabel.textColor = style.titleColor
        iconImageView.tintColor = style.imageTintColor
        backgroundColor = style.backgroundColor
    }
    
}

final class CustomIntensityVisualEffectView: UIVisualEffectView {
  /// Create visual effect view with given effect and its intensity
  ///
  /// - Parameters:
  ///   - effect: visual effect, eg UIBlurEffect(style: .dark)
  ///   - intensity: custom intensity from 0.0 (no effect) to 1.0 (full effect) using linear scale
  init(effect: UIVisualEffect, intensity: CGFloat) {
    theEffect = effect
    customIntensity = intensity
    super.init(effect: nil)
  }

  required init?(coder aDecoder: NSCoder) { nil }

  deinit {
    animator?.stopAnimation(true)
  }

  override func draw(_ rect: CGRect) {
    super.draw(rect)
    effect = nil
    animator?.stopAnimation(true)
    animator = UIViewPropertyAnimator(duration: 1, curve: .linear) { [unowned self] in
      self.effect = theEffect
    }
    animator?.fractionComplete = customIntensity
  }

  private let theEffect: UIVisualEffect
  private let customIntensity: CGFloat
  private var animator: UIViewPropertyAnimator?
}
