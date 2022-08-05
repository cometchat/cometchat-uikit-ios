//
//  CometChatDataItem.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 24/02/22.
//

import UIKit
import CometChatPro

protocol  CometChatDataItemDelegate {
    
    func onItemClick(user: User)
    func onItemClick(group: Group)
    func onItemLongClick(user: User)
    func onItemLongClick(group: Group)

}

class CometChatDataItem: UITableViewCell {

    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var statusIndicator: CometChatStatusIndicator!
    @IBOutlet weak var avatarWidthconstant: NSLayoutConstraint!
    @IBOutlet weak var tailView: UIView!
    @IBOutlet weak var scopeChangeButton: UIButton!
    @IBOutlet weak var check: UIImageView!
    
    var inputData: InputData?
    var configurations: [CometChatConfiguration]?
    var parentGroup: Group?
    var menu: UIMenu?
    var allowSelection: Bool = false
    var allowPramoteDemoteModerators: Bool = false
    
    @discardableResult public func set(user: User?) ->  CometChatDataItem {
        if let user = user {
            self.user = user
            configureDataItem()
        }
        return self
    }
    
    @discardableResult public func set(groupMember: GroupMember?) ->  CometChatDataItem {
        if let groupMember = groupMember {
            self.groupMember = groupMember
        }
        return self
    }
    
    @discardableResult public func set(bannedGroupMember: GroupMember?) ->  CometChatDataItem {
        if let bannedGroupMember = bannedGroupMember {
            self.bannedGroupMember = bannedGroupMember
        }
        return self
    }
    
    
    @discardableResult public func set(group: Group?) ->  CometChatDataItem {
        if let group = group {
            self.group = group
        }
        return self
    }
    
    @discardableResult public func set(parentGroup: Group?) ->  CometChatDataItem {
        if let parentGroup = parentGroup {
            self.parentGroup = parentGroup
        }
        return self
    }
    
    @discardableResult public func allow(pramoteDemoteModerators: Bool?) ->  CometChatDataItem {
        if let pramoteDemoteModerators = pramoteDemoteModerators {
            allowPramoteDemoteModerators = pramoteDemoteModerators
            if pramoteDemoteModerators == false {
                self.scopeChangeButton.isEnabled = false
            }
        }
        return self
    }
        
    @discardableResult  public func allow(selection: Bool?) ->  CometChatDataItem {
        if let selction = selection {
            allowSelection = selction
            if selction == true {
                self.check.isHidden = false
            }
        }
        return self
    }
    
    
    @discardableResult
    public func set(background: [Any]?) ->  CometChatDataItem {
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
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(title: String?) -> CometChatDataItem {
        self.title.text = title
        return self
    }
    
    /**
     This method will set the title with attributed text for `ConversationListItem`.
     - Parameters:
     - titleWithAttributedText: This method will set the title with attributed text for ConversationListItem.
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleWithAttributedText: NSAttributedString) -> CometChatDataItem {
        self.title.attributedText = titleWithAttributedText
        return self
    }
    
    /**
     This method will set the title color for `CometChatDataItem`
     - Parameters:
     - titleColor: This method will set the title color for ConversationListItem
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatDataItem {
        self.title.textColor = titleColor
        return self
    }
    
    /**
     This method will set the title font for `CometChatDataItem`
     - Parameters:
     - titleFont: This method will set the title font for ConversationListItem
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatDataItem{
        self.title.font = titleFont
        return self
    }
    
    
    /**
     The SubTitle is a UILabel that specifies a subTitle for  `CometChatDataItem`.
     - Parameters:
     - subTitle: This method will set the subtitle for ConversationListItem.
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitle: String?) -> CometChatDataItem {
        self.subtitle.text = subTitle
        return self
    }
    
    /**
     This method will set the subtitle with attributed text for  `CometChatDataItem`.
     - Parameters:
     - subTitleWithAttributedText: This method will set the subtitle with attributed text for `CometChatDataItem`.
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleWithAttributedText: NSAttributedString) -> CometChatDataItem {
        self.subtitle.attributedText = subTitleWithAttributedText
        return self
    }
    
    /**
     This method will set the subtitle color for  `CometChatDataItem`.
     - Parameters:
     - subTitleColor: This method will set the subtitle color for ConversationListItem
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> CometChatDataItem{
        self.subtitle.textColor = subTitleColor
        return self
    }
    
    /**
     This method will set the subtitle font for  `CometChatDataItem`.
     - Parameters:
     - subTitleFont:This method will set the subtitle font for ConversationListItem
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> CometChatDataItem{
        self.subtitle.font = subTitleFont
        return self
    }
    
    /**
     The avatar is a UIImageView that specifies an avatar for  `CometChatDataItem`.
     - Parameters:
     - avatar:This method will set the avatar for ConversationListItem.
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatDataItem {
       // self.avatar = avatar
        return self
    }

    
    @discardableResult
    @objc public func set(statusIndicator: CometChatPro.CometChat.UserStatus) -> CometChatDataItem {
        self.statusIndicator.isHidden = false
        self.statusIndicator.set(status: statusIndicator)
        return self
    }
    
    
    /**
     This method will hide the avatar for `CometChatDataItem`.
     - Parameters:
     - avatar:This method will hide the avatar for ConversationListItem.
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func hide(avatar: Bool) -> CometChatDataItem {
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
    public func hide(title: Bool) -> CometChatDataItem {
        self.title.isHidden = title
     return self
    }
    
    @discardableResult
    public func hide(subtitle: Bool) -> CometChatDataItem {
        self.subtitle.isHidden = subtitle
     return self
    }
    
    
    @discardableResult
    public func hide(statusIndicator: Bool) -> CometChatDataItem {
        self.statusIndicator.isHidden = statusIndicator
     return self
    }
    
    @discardableResult
    public func set(tailView: UIView?) -> CometChatDataItem {
        if let tailView = tailView {
            self.tailView.addSubview(tailView)
        }
     return self
    }

    
    @discardableResult
    public func set(inputData: InputData?) -> CometChatDataItem {
        if let inputData = inputData {
            self.inputData = inputData
        }
        return self
    }

    
    @discardableResult
    public func set(style: Style) -> CometChatDataItem {
        self.set(background: [style.background?.cgColor])
        self.set(titleColor: style.titleColor ?? UIColor.gray)
        self.set(titleFont: style.titleFont ?? UIFont.systemFont(ofSize: 20, weight: .regular))
        self.set(subTitleColor: style.subTitleColor ?? UIColor.gray)
        self.set(subTitleFont:  style.subTitleFont ?? UIFont.systemFont(ofSize: 20, weight: .regular))
        self.avatar.set(cornerRadius: style.cornerRadius ?? 0.0).set(borderWidth: style.border ?? 0.0).set(backgroundColor: style.subTitleColor ?? .gray)
        return self
    }

    
    
    @discardableResult
    @objc public func set(configuration: CometChatConfiguration?) -> CometChatDataItem {
    
        return self
    }
    
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatDataItem {
        self.configurations = configurations
        configureDataItem()
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
                CometChatUserEvents.emitOnItemLongClick(user: user, index: nil)
            }
            if let group = group {
                CometChatGroupEvents.emitOnItemLongClick(group: group, index: nil)
            }
        }
    }
    
    weak var user: User? {
        didSet {
            if let user = user {
                
                if let name = user.name?.capitalized {
                    self.set(title: name)
                }
             
                self.set(statusIndicator: user.status)
               self.set(avatar: avatar.setAvatar(avatarUrl: user.avatar ?? "", with: user.name ?? ""))
                
                inputData = InputData(title: true, thumbnail: true, status: false, subtitle: nil)
                configureDataItem()
                
                
                if let title = inputData?.title {
                    self.hide(title: !title)
                }
                
                if let status = inputData?.status {
                    self.hide(statusIndicator: !status)
                }
                
                if let thumbnail = inputData?.thumbnail {
                    self.hide(avatar: !thumbnail)
                }
                
                if let subtitle = inputData?.subtitle {
                    if !subtitle(user).isEmpty {
                        self.hide(subtitle: false)
                        self.set(subTitle:  subtitle(user))
                    }else{
                        self.hide(subtitle: true)
                    }
                }else{
                    self.hide(subtitle: true)
                }

                
                // Style
                
                let style = Style(background: CometChatTheme.palatte?.background, border: 1, cornerRadius: 20.0, titleColor: CometChatTheme.palatte?.accent, titleFont: CometChatTheme.typography?.Name2, subTitleColor: CometChatTheme.palatte?.accent600, subTitleFont: CometChatTheme.typography?.Subtitle2)
                
                set(style: style)
                
                addLongPress()

                if allowSelection {
                    self.scopeChangeButton.isHidden = true
                    self.tailView.isHidden = false
                    self.check.isHidden = false
                }
            }
        }
    }
    
   
    
    weak var group: Group? {
        didSet {
            if let group = group {
                
                
                // Data Population
                
                if let name = group.name {
                    self.set(title: name)
                }
                
                self.set(avatar: avatar.setAvatar(avatarUrl: group.icon ?? "", with: group.name ?? ""))
              
                switch group.groupType {
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
                
                inputData = InputData(title: true, thumbnail: true, status: true, subtitle: { group in
                    if let memberCount = group.membersCount {
                        if group.membersCount < 1 {
                            return String(memberCount) + " " + "MEMBER".localize()
                        }else{
                            return String(memberCount) + " " + "MEMBERS".localize()
                        }
                    }
                   return ""
                })
                
                configureDataItem()
                // Input Data
                
                if let title = inputData?.title {
                    self.hide(title: !title)
                }
                
                if let status = inputData?.status {
                    if group.groupType != .public {
                        self.hide(statusIndicator: !status)
                    }
                }
                
                if let thumbnail = inputData?.thumbnail {
                    self.hide(avatar: !thumbnail)
                }
                
                if let subtitle = inputData?.subtitle {
                    if !subtitle(group).isEmpty {
                        self.hide(subtitle: false)
                        self.set(subTitle:  subtitle(group))
                    }else{
                        self.hide(subtitle: true)
                    }
                }else{
                    self.hide(subtitle: true)
                }
                // Style
                
                let style = Style(background: CometChatTheme.palatte?.background, border: 1, cornerRadius: 20.0, titleColor: CometChatTheme.palatte?.accent, titleFont: CometChatTheme.typography?.Name2, subTitleColor: CometChatTheme.palatte?.accent600, subTitleFont: CometChatTheme.typography?.Subtitle1)
                
                set(style: style)
                addLongPress()
               
             }
        }
    }
    
    weak var groupMember: GroupMember? {
        didSet {
            if let groupMember = groupMember {
                
                if let name = groupMember.name?.capitalized {
                    if groupMember.uid == CometChat.getLoggedInUser()?.uid {
                        self.set(title: "YOU".localize())
                        self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0);
                        self.scopeChangeButton.isEnabled = false
                    }else{
                        self.set(title: name)
                    }
                }
                
                self.set(statusIndicator: groupMember.status)
                self.set(avatar: avatar.setAvatar(avatarUrl: groupMember.avatar ?? "", with: groupMember.name ?? ""))
            
                inputData = InputData(title: true, thumbnail: true, status: true, subtitle: nil)
                
                configureDataItem()
                
                if let title = inputData?.title {
                    self.hide(title: !title)
                }
                
                if let subtitle = inputData?.subtitle {
                    if !subtitle(groupMember).isEmpty {
                        self.hide(subtitle: false)
                        self.set(subTitle:  subtitle(groupMember))
                    }else{
                        self.hide(subtitle: true)
                    }
                }else{
                    self.hide(subtitle: true)
                }
                
                if let status = inputData?.status {
                    self.hide(statusIndicator: !status)
                }
                
                if let thumbnail = inputData?.thumbnail {
                    self.hide(avatar: !thumbnail)
                }
                
                // Style
                
                let style = Style(background: CometChatTheme.palatte?.background, border: 1, cornerRadius: 20, titleColor: CometChatTheme.palatte?.accent, titleFont: CometChatTheme.typography?.Name2, subTitleColor: CometChatTheme.palatte?.accent600, subTitleFont: CometChatTheme.typography?.Subtitle1)
                
                set(style: style)
                
                addLongPress()
                
                configureTailView(groupMember: groupMember)
            }
        }
    }
    
    weak var bannedGroupMember: GroupMember? {
        didSet {
            if let bannedGroupMember = bannedGroupMember {
                
                if let name = bannedGroupMember.name?.capitalized {
                    self.set(title: name)
                }
                
                self.set(statusIndicator: bannedGroupMember.status)
                self.set(avatar: avatar.setAvatar(avatarUrl: bannedGroupMember.avatar ?? "", with: bannedGroupMember.name ?? ""))
            
                inputData = InputData(title: true, thumbnail: true, status: true, subtitle: nil)
                
                configureDataItem()
                configureTailView(bannedGroupMember: bannedGroupMember)
                if let title = inputData?.title {
                    self.hide(title: !title)
                }
                
                if let subtitle = inputData?.subtitle {
                    if !subtitle(bannedGroupMember).isEmpty {
                        self.hide(subtitle: false)
                        self.set(subTitle:  subtitle(bannedGroupMember))
                    }else{
                        self.hide(subtitle: true)
                    }
                }else{
                    self.hide(subtitle: true)
                }
                
                if let status = inputData?.status {
                    self.hide(statusIndicator: !status)
                }
                
                if let thumbnail = inputData?.thumbnail {
                    self.hide(avatar: !thumbnail)
                }
                
                // Style
                
                let style = Style(background: CometChatTheme.palatte?.background, border: 1, cornerRadius: 20, titleColor: CometChatTheme.palatte?.accent, titleFont: CometChatTheme.typography?.Name2, subTitleColor: CometChatTheme.palatte?.accent600, subTitleFont: CometChatTheme.typography?.Subtitle1)
                
                set(style: style)
                
                addLongPress()
                
               configureTailView(bannedGroupMember: bannedGroupMember)
            
            }
        }
    }
    
    private func configureDataItem() {
        
        if let configurations = configurations {
            
            let dataItemConfiguration = configurations.filter{ $0 is DataItemConfiguration }
            if let configuration = dataItemConfiguration.last as? DataItemConfiguration {
                set(background: configuration.background)
                set(inputData: configuration.inputData)
            }
            
            let avatarConfiguration = configurations.filter{ $0 is AvatarConfiguration }
            if let configuration = avatarConfiguration.last as? AvatarConfiguration {

                avatar.set(cornerRadius: configuration.cornerRadius)
                avatar.set(borderWidth: configuration.borderWidth)
                if configuration.outerViewWidth != 0 {
                    avatar.set(outerView: true)
                    avatar.set(borderWidth: configuration.outerViewWidth)
                }
                self.set(avatar: avatar)
            }
            
            let statusIndicatorConfiguration = configurations.filter{ $0 is StatusIndicatorConfiguration }
            if let configuration = statusIndicatorConfiguration.last as? StatusIndicatorConfiguration {
                statusIndicator.set(cornerRadius: configuration.cornerRadius)
                statusIndicator.set(borderWidth: configuration.borderWidth)
                statusIndicator.set(status: .online, backgroundColor: configuration.backgroundColorForOnlineState)
                statusIndicator.set(status: .offline, backgroundColor: configuration.backgroundColorForOfflineState)
            }
        }
    }
    
    
    
    @IBAction func onClick(_ sender: Any) {
        if #available(iOS 14.0, *) {
            scopeChangeButton.menu = menu
            scopeChangeButton.showsMenuAsPrimaryAction = true
        } else {
           
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        if selected{
            check.image = UIImage(named:"groups-check-active", in: CometChatUIKit.bundle, compatibleWith: nil)
        }else{
            check.image = UIImage(named:"groups-check-normal", in: CometChatUIKit.bundle, compatibleWith: nil)
            
        }
    }
    
    override func prepareForReuse() {
        
    }
    

    private func configureTailView(groupMember: GroupMember) {
        
        self.tailView.isHidden = false
        self.scopeChangeButton.titleLabel?.font = CometChatTheme.typography?.Subtitle1
        self.scopeChangeButton.titleLabel?.textColor = CometChatTheme.palatte?.accent600
        self.scopeChangeButton.isHidden = false
        
        if let parentGroup = parentGroup {
            switch parentGroup.scope {
            case .admin:
                if allowPramoteDemoteModerators {
                scopeChangeButton.isEnabled = true
                }else{
                    self.scopeChangeButton.isEnabled = false
                    self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
                }
              
                let menuItems =  [ UIAction(title: "ADMIN".localize(), image: nil, handler: { (_) in
                    self.changeScope(for: groupMember, scope: .admin)
                }),  UIAction(title: "PARTICIPANT".localize(), image: nil, handler: { (_) in
                    self.changeScope(for: groupMember, scope: .participant)
                }), UIAction(title: "MODERATOR".localize(), image:nil, handler: { (_) in
                    self.changeScope(for: groupMember, scope: .moderator)
                })]
                menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
                
            case .moderator:
                if allowPramoteDemoteModerators {
                scopeChangeButton.isEnabled = true
                }else{
                    self.scopeChangeButton.isEnabled = false
                    self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
                }
                let menuItems = [ UIAction(title: "MODERATOR".localize(), image:nil, handler: { (_) in
                    self.changeScope(for: groupMember, scope: .moderator)
                })]
                menu = UIMenu(title: "", image: nil, identifier: nil, options: [], children: menuItems)
                
            case .participant:
                scopeChangeButton.isEnabled = false
            @unknown default: break
            }
            
            switch parentGroup.scope {
            case .admin where groupMember.scope == .admin:
                self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.accent600, for: .normal)
                self.scopeChangeButton.isEnabled = false
                self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
                
                if parentGroup.owner == groupMember.uid {
                    self.scopeChangeButton.setTitle("OWNER".localize()  + "  " , for: .normal)
                }else{
                    self.scopeChangeButton.setTitle("ADMIN".localize()  + "  " , for: .normal)
                }
                
            case .admin where groupMember.scope == .moderator:
                self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.primary, for: .normal)
                self.scopeChangeButton.setTitle("MODERATOR".localize()  + "  " , for: .normal)
                
            case .admin where groupMember.scope == .participant:
                self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.primary, for: .normal)
                self.scopeChangeButton.setTitle("PARTICIPANT".localize()  + "  ", for: .normal)
                
            case .moderator where groupMember.scope == .admin:
                self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.accent600, for: .normal)
                self.scopeChangeButton.isEnabled = false
                self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
                if parentGroup.owner == groupMember.uid {
                    self.scopeChangeButton.setTitle("OWNER".localize()  + "  " , for: .normal)
                }else{
                    self.scopeChangeButton.setTitle("ADMIN".localize()  + "  " , for: .normal)
                }
                
            case .moderator where groupMember.scope == .moderator:
                self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.accent600, for: .normal)
                self.scopeChangeButton.isEnabled = false
                self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
                self.scopeChangeButton.setTitle("MODERATOR".localize()  + "  " , for: .normal)
                
            case .moderator where groupMember.scope == .participant:
                self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.primary, for: .normal)
                self.scopeChangeButton.setTitle("PARTICIPANT".localize()  + "  " , for: .normal)
                
            case .participant where groupMember.scope == .admin:
                self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.accent600, for: .normal)
                self.scopeChangeButton.isEnabled = false
                self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
                if parentGroup.owner == groupMember.uid {
                    self.scopeChangeButton.setTitle("OWNER".localize()  + "  " , for: .normal)
                }else{
                    self.scopeChangeButton.setTitle("ADMIN".localize()  + "  " , for: .normal)
                }
                
            case .participant where groupMember.scope == .moderator:
                self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.accent600, for: .normal)
                self.scopeChangeButton.isEnabled = false
                self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
                self.scopeChangeButton.setTitle("MODERATOR".localize() + "  ", for: .normal)
                
            case .participant where groupMember.scope == .participant:
                self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.accent600, for: .normal)
                self.scopeChangeButton.isEnabled = false
                self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0)
                self.scopeChangeButton.setTitle("PARTICIPANT".localize() + "  ", for: .normal)
               
            case .admin: break
            case .moderator: break
            case .participant: break
            @unknown default: break
            }
            if allowSelection {
                self.check.isHidden = false
            }
        }
    }
    
    private func changeScope(for member: GroupMember, scope: CometChat.MemberScope) {
        CometChat.updateGroupMemberScope(UID: member.uid ?? "", GUID: parentGroup?.guid ?? "", scope: scope) { scopeChangeSuccess in
            var groupMember: GroupMember?
            DispatchQueue.main.async { [weak self] in
                switch scope {
                case .admin:
                    groupMember = GroupMember(UID: member.uid ?? "", groupMemberScope: .admin)
                case .moderator:
                    groupMember = GroupMember(UID: member.uid ?? "", groupMemberScope: .moderator)
                case .participant:
                    groupMember = GroupMember(UID: member.uid ?? "", groupMemberScope: .participant)
                @unknown default: break
                }
                groupMember?.avatar = member.avatar
                groupMember?.name = member.name
                self?.set(groupMember: groupMember)
                self?.reloadInputViews()
            }
        } onError: { error in
            
        }
    }
    
    private func configureTailView(bannedGroupMember: GroupMember) {
        self.tailView.isHidden = false
        self.scopeChangeButton.imageView?.layer.transform = CATransform3DMakeScale(0, 0, 0);
        self.scopeChangeButton.isEnabled = false
        self.scopeChangeButton.setTitle("BANNED".localize(), for: .normal)
        self.scopeChangeButton.setTitleColor(CometChatTheme.palatte?.accent600, for: .normal)
    }
    
}
