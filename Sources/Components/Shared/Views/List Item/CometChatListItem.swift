//
//  CometChatListItem.swift
//  
//
//  Created by Pushpsen Airekar on 17/11/22.
//

import UIKit

@MainActor
open class CometChatListItem: UITableViewCell {
    
    @IBOutlet weak var tailViewWidth: NSLayoutConstraint!
    @IBOutlet weak var checkContainer: UIView!
    @IBOutlet weak var check: UIImageView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var containerStack: UIStackView!
    @IBOutlet var containerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tailView: UIStackView!
    @IBOutlet weak var subTitleView: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var statusIndicator: CometChatStatusIndicator!
    
    // MARK: - Properties
    private var id: String?
    private var title: String?
    private var avatarURL: String?
    private var avatarName: String?
    private var statusIndicatorColor: UIColor = UIColor.clear
    private var statusIndicatorIconTint: UIColor = UIColor.green
    private var statusIndicatorIcon: UIImage = UIImage()
    private var options: [ListItemOption]?
    private var tail: UIView?
    private var subtitle: UIView?
    private var customView: UIView?
    private var listItemConfiguration: ListItemConfiguration?
    private var listItemStyle = ListItemStyle()
    private var avatarStyle = AvatarStyle()
    private var statusIndicatorStyle = StatusIndicatorStyle()
    private var imageRequest: Cancellable?
    private var controller: UIViewController?
    private var allowSelection: Bool = false
    private lazy var imageService = ImageService()
    var onItemLongClick: (() -> Void)?
    
    static let identifier = "CometChatListItem"
    
    @MainActor open override func awakeFromNib() {
        super.awakeFromNib()
       // self.selectionStyle = .default
        addLongPress()
    }

    private func addLongPress() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressed))
        self.background.addGestureRecognizer(longPressRecognizer)
        self.background.isUserInteractionEnabled = true
    }
    
    @objc private func longPressed() {
        onItemLongClick?()
    }
    
    @discardableResult
    public func set(avatarURL: String) -> Self {
        self.avatarURL = avatarURL
        return self
    }
    
    @discardableResult
    public func set(avatarName: String) -> Self {
        self.avatarName = avatarName
        return self
    }
    
    @discardableResult
    public func hide(statusIndicator: Bool) -> Self {
        self.statusIndicator.isHidden = statusIndicator
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorColor: UIColor) -> Self {
        self.statusIndicatorColor = statusIndicatorColor
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorIcon: UIImage) -> Self {
        self.statusIndicatorIcon = statusIndicatorIcon
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorIconTint: UIColor) -> Self {
        self.statusIndicatorIconTint = statusIndicatorIconTint
        return self
    }
    
    @discardableResult
    public func set(title: String) -> Self {
        self.title = title
        return self
    }
    
    @discardableResult
    public func set(subtitle: UIView) -> Self {
        subTitleView.subviews.forEach({ $0.removeFromSuperview() })
        self.subtitle = subtitle
        return self
    }
    
    @discardableResult
    public func set(tail: UIView) -> Self {
        tailView.subviews.forEach({ $0.removeFromSuperview() })
        self.tail = tail
        return self
    }
    
    @discardableResult
    public func set(customView: UIView) -> Self {
        self.customView = customView
        return self
    }
    
    @discardableResult
    public func set(options: [ListItemOption]) -> Self {
        self.options = options
        return self
    }
    
    @discardableResult
    public func set(listItemStyle: ListItemStyle) -> Self {
        self.listItemStyle = listItemStyle
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> Self {
        self.statusIndicatorStyle = statusIndicatorStyle
        return self
    }
    
    @discardableResult  public func allow(selection: Bool) ->  Self {
        allowSelection = selection
        return self
    }
    
    func getTail() -> UIStackView? {
        return tailView
    }
    
    func getSubTitle() -> UIStackView? {
        return subTitleView
    }
    
    public func build() {
        // Configuring background
        self.background.backgroundColor = listItemStyle.background
        self.background.borderColor(color: listItemStyle.borderColor)
        self.background.borderWith(width: listItemStyle.borderWidth)
        self.background.roundViewCorners(corner: listItemStyle.cornerRadius)
        
        self.backgroundColor = .clear
        self.selectionStyle = .none

        
        // Configuring title
        self.titleLabel.text = title
        self.titleLabel.font = listItemStyle.titleFont
        self.titleLabel.textColor = listItemStyle.titleColor
        // Configuring avatar
        self.avatar.setAvatar(avatarUrl: avatarURL, with: title)
        self.avatar.set(backgroundColor: avatarStyle.background)
        self.avatar.set(font: avatarStyle.textFont)
        self.avatar.set(fontColor: avatarStyle.textColor)
        self.avatar.set(borderColor: avatarStyle.borderColor)
        self.avatar.set(borderWidth: avatarStyle.borderWidth)
        self.avatar.set(cornerRadius: avatarStyle.cornerRadius)
        // Configuring statusIndicator
        self.statusIndicator.set(backgroundColor: statusIndicatorColor)
        self.statusIndicator.set(icon: statusIndicatorIcon, with: statusIndicatorIconTint)
        self.statusIndicator.set(cornerRadius: statusIndicatorStyle.cornerRadius)
        self.statusIndicator.set(borderWidth: statusIndicatorStyle.borderWidth)
        self.statusIndicator.set(borderColor: statusIndicatorStyle.borderColor)

//         Configuring subtitle
        if let subtitle = subtitle {
            
            self.subTitleView.isHidden = false
            self.subTitleView.addArrangedSubview(subtitle)
        } else {
            self.subTitleView.isHidden = true
        }
        // Configuring tail
        if let tail = tail {
            self.tailView.addArrangedSubview(tail)
            tail.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
            // Need to refactor, it should be without fixing the height
            tail.heightAnchor.constraint(equalToConstant: 45).isActive = true
        }
        // Configuring customView
        if let customView = customView {
            self.background.isHidden = true
            self.containerStack.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                customView.leadingAnchor.constraint(equalTo: self.containerStack.leadingAnchor, constant: 0),
                customView.topAnchor.constraint(equalTo: self.containerStack.topAnchor, constant: 0),
                customView.bottomAnchor.constraint(equalTo: self.containerStack.bottomAnchor),
                customView.trailingAnchor.constraint(equalTo: self.containerStack.trailingAnchor, constant: 0),
                customView.widthAnchor.constraint(equalToConstant: customView.frame.width),
                customView.heightAnchor.constraint(equalToConstant: customView.frame.height)
            ])
        }
        switch allowSelection {
        case true:  self.checkContainer.isHidden = false
        case false: self.checkContainer.isHidden = true
        }
    }
    
    open override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected{
            check.image = UIImage(named:"groups-check-active", in: CometChatUIKit.bundle, compatibleWith: nil)?.withTintColor(listItemStyle.selectionIconTint)
         } else {
             check.image = UIImage(named:"groups-check-normal", in: CometChatUIKit.bundle, compatibleWith: nil)
        }
    }
    
    open override func prepareForReuse() {
        id = nil
        title = nil
        avatarURL = nil
        avatarName = nil
        options = nil
        tail = nil
        subtitle = nil
        customView = nil
        imageRequest = nil
        controller = nil
        avatar.subviews.forEach({ $0.removeFromSuperview() })
        tailView.subviews.forEach( { $0.removeFromSuperview() })
        subTitleView.subviews.forEach({ $0.removeFromSuperview() })
        tailView.subviews.forEach({ $0.removeFromSuperview() })
    }
}
