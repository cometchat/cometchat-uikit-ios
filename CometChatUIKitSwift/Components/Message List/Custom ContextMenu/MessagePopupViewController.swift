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
                    self.messageOptionDelegate?.onItemClick(messageOption: option, forMessage: self.baseMessage, indexPath: nil)
                }
            }
        }
        contextMenuTableView.separatorStyle = .singleLine
        return contextMenuTableView
    }()
    
    lazy var blurBackgroundView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .systemChromeMaterial)
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
    var messageOptions: [CometChatMessageOption] = [] {
        didSet {
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
        
        messageSnapShotView.frame = CGRect(
            x: bubbleCoordinates.x,
            y: bubbleCoordinates.y,
            width: messageSnapShotView.bounds.width,
            height: messageSnapShotView.bounds.height
        )
        view.addSubview(messageSnapShotView)
        
        reactionView.frame = CGRect(
            x: messageAlignment == .right ? Int(bubbleCoordinates.x + (messageSnapShotView.bounds.width - 238)) : Int(bubbleCoordinates.x),
            y: (Int(bubbleCoordinates.y) - reactionViewHeight - spacing),
            width: 238,
            height: reactionViewHeight
        )
        view.addSubview(reactionView)
        
        optionMenuTableView.frame = CGRect(
            x: messageAlignment == .right ? Int(bubbleCoordinates.x + (messageSnapShotView.bounds.width - 250)) : Int(bubbleCoordinates.x),
            y: (Int(bubbleCoordinates.y) + Int(messageSnapShotView.bounds.height) + spacing ),
            width: 250,
            height: Int(messageOptions.count * 44)
        )
        view.addSubview(optionMenuTableView)
        
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
    
    var messageOptions: [CometChatMessageOption] = []
    var didSelect: ((_ option: CometChatMessageOption) -> Void)?
    
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
        return messageOptions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: ContextMenuTextCell.identifier , for: indexPath) as? ContextMenuTextCell {
            cell.layoutMargins = UIEdgeInsets.zero
            let option = messageOptions[indexPath.row]
            cell.titleLabel.text = option.title
            cell.iconImageView.image = option.icon
            cell.style = option.style
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        didSelect?(messageOptions[indexPath.row])
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
