//
//  CometChatGroupListItem.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 24/02/22.
//

import UIKit
import CometChatPro

class CometChatGroupListItem: UITableViewCell {

    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var statusIndicator: CometChatStatusIndicator!
    @IBOutlet weak var avatarWidthconstant: NSLayoutConstraint!
    
    
    @discardableResult public func set(group: Group?) ->  CometChatGroupListItem {
        if let group = group {
            self.group = group
        }
        return self
    }
   
    @discardableResult
    public func set(background: [Any]?) ->  CometChatGroupListItem {
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
     The title is a UILabel which specifies a title for  `ConversationListItem`.
     - Parameters:
     - title: This method will set the title for ConversationListItem.
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(title: String?) -> CometChatGroupListItem {
        self.title.text = title
        return self
    }
    
    /**
     This method will set the title with attributed text for `ConversationListItem`.
     - Parameters:
     - titleWithAttributedText: This method will set the title with attributed text for ConversationListItem.
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleWithAttributedText: NSAttributedString) -> CometChatGroupListItem {
        self.title.attributedText = titleWithAttributedText
        return self
    }
    
    /**
     This method will set the title color for `CometChatGroupListItem`
     - Parameters:
     - titleColor: This method will set the title color for ConversationListItem
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatGroupListItem {
        self.title.textColor = titleColor
        return self
    }
    
    /**
     This method will set the title font for `CometChatGroupListItem`
     - Parameters:
     - titleFont: This method will set the title font for ConversationListItem
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatGroupListItem{
        self.title.font = titleFont
        return self
    }
    
    
    /**
     The SubTitle is a UILabel that specifies a subTitle for  `CometChatGroupListItem`.
     - Parameters:
     - subTitle: This method will set the subtitle for ConversationListItem.
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitle: String?) -> CometChatGroupListItem {
        self.subtitle.text = subTitle
        return self
    }
    
    /**
     This method will set the subtitle with attributed text for  `CometChatGroupListItem`.
     - Parameters:
     - subTitleWithAttributedText: This method will set the subtitle with attributed text for `CometChatGroupListItem`.
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleWithAttributedText: NSAttributedString) -> CometChatGroupListItem {
        self.subtitle.attributedText = subTitleWithAttributedText
        return self
    }
    
    /**
     This method will set the subtitle color for  `CometChatGroupListItem`.
     - Parameters:
     - subTitleColor: This method will set the subtitle color for ConversationListItem
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> CometChatGroupListItem{
        self.subtitle.textColor = subTitleColor
        return self
    }
    
    /**
     This method will set the subtitle font for  `CometChatGroupListItem`.
     - Parameters:
     - subTitleFont:This method will set the subtitle font for ConversationListItem
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> CometChatGroupListItem{
        self.subtitle.font = subTitleFont
        return self
    }
    
    /**
     The avatar is a UIImageView that specifies an avatar for  `CometChatGroupListItem`.
     - Parameters:
     - avatar:This method will set the avatar for ConversationListItem.
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatGroupListItem {
        self.avatar = avatar
        return self
    }
    
    /**
     This method will hide the avatar for `CometChatGroupListItem`.
     - Parameters:
     - avatar:This method will hide the avatar for ConversationListItem.
     - Returns: This method will return `CometChatGroupListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func hide(avatar: Bool) -> CometChatGroupListItem {
        if avatar == true {
            self.avatar.isHidden = true
            self.avatarWidthconstant.constant = 0
            self.statusIndicator.isHidden = true
            self.preservesSuperviewLayoutMargins = false
            self.separatorInset = UIEdgeInsets(top: 0, left: 30, bottom: 0, right: 15)
            self.layoutMargins = UIEdgeInsets.zero
        }
        return self
    }
    
    @discardableResult
    @objc public func set(statusIndicator: CometChatPro.CometChat.UserStatus) -> CometChatGroupListItem {
        self.statusIndicator.isHidden = false
        self.statusIndicator.set(status: statusIndicator)
        return self
    }
    
    @discardableResult
    public func hide(statusIndicator: Bool) -> CometChatGroupListItem {
        self.statusIndicator.isHidden = statusIndicator
        return self
    }
    
    
    @discardableResult
    public func set(data: InputData) -> CometChatGroupListItem {
        
        self.set(title: data.title)
        self.set(subTitle: data.subTitle)
        self.set(avatar: avatar.setAvatar(avatarUrl: data.thumbnail ?? "", with: data.title ?? ""))
        self.set(subTitle: data.subTitle)
        
        if let groupType = data.groupType {
            switch groupType {
            case .public:
                statusIndicator.isHidden = true
                statusIndicator.set(borderWidth: 0)
            case .private:
                statusIndicator.isHidden = false
                statusIndicator.set(borderWidth: 0).set(backgroundColor:   #colorLiteral(red: 0, green: 0.7843137255, blue: 0.4352941176, alpha: 1))
               
                let image = UIImage(named: "groups-shield", in: CometChatUIKit.bundle, compatibleWith: nil)
                
                statusIndicator.set(icon:  image ?? UIImage(), with: .white)
                statusIndicator.set(borderWidth: 0)
            case .password:
                statusIndicator.isHidden = false
                statusIndicator.set(borderWidth: 0).set(backgroundColor: #colorLiteral(red: 0.968627451, green: 0.6470588235, blue: 0, alpha: 1))
                let image = UIImage(named: "groups-lock", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
                statusIndicator.set(icon:  image, with: .white)
            @unknown default:
                break
            }
        }
        return self
    }
    
    @discardableResult
    public func set(style: Style) -> CometChatGroupListItem {
        self.set(background: [style.background?.cgColor])
        self.set(titleColor: style.titleColor ?? UIColor.gray)
        self.set(titleFont: style.titleFont ?? UIFont.systemFont(ofSize: 20, weight: .regular))
        self.set(subTitleColor: style.subTitleColor ?? UIColor.gray)
        self.set(subTitleFont:  style.subTitleFont ?? UIFont.systemFont(ofSize: 20, weight: .regular))
        self.avatar.set(cornerRadius: style.cornerRadius ?? 0.0).set(borderWidth: style.border ?? 0.0).set(backgroundColor: style.subTitleColor ?? .gray)
        return self
    }
    
    private func addLongPress() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onItemLongClick))
        self.background.addGestureRecognizer(longPressRecognizer)
        self.background.isUserInteractionEnabled = true
    }
    
    @objc func onItemLongClick(sender: UITapGestureRecognizer){
        if sender.state == .began {
            if let group = group {
                CometChatGroups.comethatGroupsDelegate?.onItemLongClick?(group: group)
            }
        }
    }
    
    
    weak var group: Group? {
        didSet {
            if let group = group {
                
                let data = InputData(id: group.guid, thumbnail: group.icon, userStatus: nil, groupType: group.groupType, title: group.name, subTitle: "\(group.membersCount) " + "MEMBERS".localize())
                set(data: data)
                
                let style = Style(background: CometChatTheme.palatte?.background, border: 1, cornerRadius: 24.0, titleColor: CometChatTheme.palatte?.accent, titleFont: CometChatTheme.typography?.Name2, subTitleColor: CometChatTheme.palatte?.accent600, subTitleFont: CometChatTheme.typography?.Subtitle1)
                
                set(style: style)
                addLongPress()
             }
        }
    }
    
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
