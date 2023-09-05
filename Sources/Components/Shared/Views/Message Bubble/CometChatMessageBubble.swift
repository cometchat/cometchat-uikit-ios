//
//  CoemtChatMessageBubble.swift
//  
//
//  Created by Abdullah Ansari on 13/12/22.
//

import UIKit
import CometChatSDK

public class CometChatMessageBubble: UITableViewCell {

    @IBOutlet weak var bubbleContainerView: UIStackView!
    @IBOutlet weak var bubbleView: UIStackView!
    
    @IBOutlet weak var topStackView: UIStackView!
    @IBOutlet weak var headerViewSpacer: UIView!
    @IBOutlet weak var headerView: UIStackView!
    
    @IBOutlet weak var middleStackView: UIStackView!
    @IBOutlet weak var avatarContainerView: UIStackView!
    @IBOutlet weak var avatarSpacer: UIView!
    @IBOutlet weak var avatar: CometChatAvatar!
    
    @IBOutlet weak var background: UIStackView!
    
    @IBOutlet weak var replyView: UIStackView!
    @IBOutlet weak var containerView: UIStackView!
    @IBOutlet weak var viewReplies: UIStackView!
    
    @IBOutlet weak var bottomStackView: UIStackView!
    @IBOutlet weak var footerViewSpacer: UIView!
    @IBOutlet weak var footerView: UIStackView!
    
    @IBOutlet weak var trailingSpacer: UIView!
    @IBOutlet weak var leadingSpacer: UIView!
    
    var alignment: MessageBubbleAlignment = .right
    static let identifier = "CometChatMessageBubble"
    private var controller: UIViewController?
    private var avatarURL: String?
    private var avatarName: String?
    private var avatarStyle = AvatarStyle()
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        background.roundViewCorners(corner: CometChatCornerStyle(cornerRadius: 12))
    }
    
    public func set(bubbleAlignment: MessageBubbleAlignment) {
        self.alignment = bubbleAlignment
        
        switch alignment {
        case .left:
            avatar.isHidden = false
            leadingSpacer.isHidden = true
            trailingSpacer.isHidden = false
            middleStackView.alignment = .leading
            bubbleView.alignment = .leading
            bottomStackView.alignment = .leading
        case .right:
            avatar.isHidden = true
            leadingSpacer.isHidden = false
            trailingSpacer.isHidden = true
            middleStackView.alignment = .trailing
            bubbleView.alignment = .trailing
            bottomStackView.alignment = .trailing
        case .center:
            avatar.isHidden = true
            leadingSpacer.isHidden = false
            trailingSpacer.isHidden = true
            middleStackView.alignment = .center
            bottomStackView.alignment = .center
            bubbleView.alignment = .center
        }
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
    public func hide(avatar: Bool) -> Self {
        self.avatarContainerView.isHidden = avatar
        self.headerViewSpacer.isHidden = avatar
        self.footerViewSpacer.isHidden = avatar
        return self
    }
    
    @discardableResult
    public func hide(headerView: Bool) -> Self {
        self.topStackView.isHidden = headerView
        return self
    }
    
    @discardableResult
    public func hide(footerView: Bool) -> Self {
        self.bottomStackView.isHidden = footerView
        return self
    }
    @discardableResult
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
 
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(bubbleView: UIStackView?) -> Self {
        if let bubbleView = bubbleView {
            self.topStackView.isHidden = true
            self.bottomStackView.isHidden = true
            self.middleStackView.isHidden = true
            self.bubbleContainerView.isHidden = false
            self.bubbleContainerView.addArrangedSubview(bubbleView)
        } else {
            self.topStackView.isHidden = false
            self.bottomStackView.isHidden = false
            self.middleStackView.isHidden = false
            self.bubbleContainerView.isHidden = true
        }
        return self
    }
    
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    private func setupAppearance() {
        let messageBubbleStyle = MessageBubbleStyle()
        self.backgroundColor = messageBubbleStyle.background
    }


    func set(backgroundColor: UIColor) {
        background.backgroundColor = backgroundColor
    }
    
    func set(cornerRadius: CometChatCornerStyle) {
        roundViewCorners(corner: cornerRadius)
        background.roundViewCorners(corner: cornerRadius)
    }
    
    func set(borderWidth: CGFloat) {
        self.borderWith(width: borderWidth)
    }
    
    func set(borderColor: UIColor) {
        self.borderColor(color: borderColor)
    }
    
    func set(style: MessageBubbleStyle = MessageBubbleStyle()) {
        set(borderColor: style.borderColor)
        set(borderWidth: style.borderWidth)
        set(backgroundColor: style.background)
        set(cornerRadius: style.cornerRadius)
        
    }

    public override func prepareForReuse() {
        self.containerView.subviews.forEach({ $0.removeFromSuperview() })
        self.headerView.subviews.forEach( { $0.removeFromSuperview() })
        self.footerView.subviews.forEach( { $0.removeFromSuperview() })
        self.viewReplies.subviews.forEach({ $0.removeFromSuperview() })
        self.replyView.subviews.forEach({ $0.removeFromSuperview() })
        self.bubbleContainerView.subviews.forEach( { $0.removeFromSuperview() })
      }
    
    public func build() {
        // Configuring avatar
        self.avatar.setAvatar(avatarUrl: avatarURL, with: avatarName)
        self.avatar.set(backgroundColor: avatarStyle.background)
        self.avatar.set(font: avatarStyle.textFont)
        self.avatar.set(fontColor: avatarStyle.textColor)
        self.avatar.set(borderColor: avatarStyle.borderColor)
        self.avatar.set(borderWidth: avatarStyle.borderWidth)
        self.avatar.set(cornerRadius: avatarStyle.cornerRadius)
        
        //Cell background color appearance
        setupAppearance()
    }
}
