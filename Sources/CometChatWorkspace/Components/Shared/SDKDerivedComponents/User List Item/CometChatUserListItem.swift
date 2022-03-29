//
//  CometChatUserListItem.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 11/12/21.
//

import UIKit
import CometChatPro
class CometChatUserListItem: UITableViewCell {
    
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var statusIndicator: CometChatStatusIndicator!
    @IBOutlet weak var avatarWidthConstant: NSLayoutConstraint!
    
    // MARK: - public instance Method
    
    /**
     This method will set the `User` object used in the `UserListItem` for all sub-components.
     - Parameters:
     - `User`: This specifies a `User` which is being used used in the `UserListItem` for all sub-components.
     - Returns: This method will return `CometChatUserListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult public func set(user: User?) ->  CometChatUserListItem {
        if let user = user {
            self.user = user
        }
        return self
        
    }
    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatListBase`.
     - Parameters:
     - background: This method will set the background color for CometChatListBase, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatUserListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [Any]?) ->  CometChatUserListItem {
        if let backgroundColors = background as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: backgroundColors)
            }
        }
        return self
    }
    
    /**
     The title is a UILabel which specifies a title for  `UserListItem`.
     - Parameters:
     - title: This method will set the title for UserListItem.
     - Returns: This method will return `CometChatUserListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(title: String?) -> CometChatUserListItem {
        self.title.text = title
        return self
    }
    
    /**
     This method will set the title with attributed text for `UserListItem`.
     - Parameters:
     - titleWithAttributedText: This method will set the title with attributed text for UserListItem.
     - Returns: This method will return `CometChatUserListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleWithAttributedText: NSAttributedString) -> CometChatUserListItem {
        self.title.attributedText = titleWithAttributedText
        return self
    }
    
    /**
     This method will set the title color for `CometChatUserListItem`
     - Parameters:
     - titleColor: This method will set the title color for UserListItem
     - Returns: This method will return `CometChatUserListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatUserListItem {
        self.title.textColor = titleColor
        return self
    }
    
    /**
     This method will set the title font for `CometChatUserListItem`
     - Parameters:
     - titleFont: This method will set the title font for UserListItem
     - Returns: This method will return `CometChatUserListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatUserListItem{
        self.title.font = titleFont
        return self
    }
    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatUserListItem {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func hide(avatar: Bool) -> CometChatUserListItem {
        if avatar == true {
            self.avatar.isHidden = true
            self.avatarWidthConstant.constant = 0
            self.statusIndicator.isHidden = true
            self.preservesSuperviewLayoutMargins = false
            self.separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 15)
            self.layoutMargins = UIEdgeInsets.zero
        }
        return self
    }
    
    @discardableResult
    @objc public func set(statusIndicator: CometChatPro.CometChat.UserStatus) -> CometChatUserListItem {
        if statusIndicator == .offline {
            self.statusIndicator.isHidden = true
        }else{
            self.statusIndicator.isHidden = false
            self.statusIndicator.set(status: statusIndicator)
        }
        return self
    }
    
    
    @discardableResult
    public func set(data: InputData) -> CometChatUserListItem {
        self.set(title: data.title)
        self.set(avatar: avatar.setAvatar(avatarUrl: data.thumbnail ?? "", with: data.title ?? "").set(backgroundColor: CometChatTheme.palatte?.accent800 ?? UIColor.gray))
        self.set(statusIndicator: data.userStatus ?? .offline)
        return self
    }
    
    @discardableResult
    public func set(style: Style) -> CometChatUserListItem {
        self.set(background: [style.background?.cgColor])
        self.set(titleColor: style.titleColor ?? UIColor.gray)
        self.set(titleFont: style.titleFont ?? UIFont.systemFont(ofSize: 20, weight: .regular))
        self.avatar.set(cornerRadius: style.cornerRadius ?? 0.0).set(borderWidth: style.border ?? 0.0)
        return self
    }
    
    private func addLongPress() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onItemLongClick))
        self.background.addGestureRecognizer(longPressRecognizer)
        self.background.isUserInteractionEnabled = true
    }
    
    @objc func onItemLongClick(sender: UITapGestureRecognizer){
        if sender.state == .began {
            if let user = user {
                CometChatUsers.comethatUsersDelegate?.onItemLongClick?(user: user)
            }
        }
    }
    
    var user: User? {
        didSet {
            if let user = user {
                
                let data = InputData(id: user.uid ?? "", thumbnail: user.avatar, userStatus: user.status, groupType: nil, title: user.name, subTitle: "")
                
                set(data: data)
                
                let style = Style(background: CometChatTheme.palatte?.background, border: 1, cornerRadius: 19.0, titleColor: CometChatTheme.palatte?.accent, titleFont: CometChatTheme.typography?.Name2, subTitleColor: nil, subTitleFont:nil)
               
                set(style: style)
                hide(avatar: false)
                addLongPress()
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        for view in subviews where view != contentView {
            view.removeFromSuperview()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
       
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

       
    }
    
}
