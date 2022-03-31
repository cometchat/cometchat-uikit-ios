
//  CometChatConversationListItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/20.
//  Copyright ©  2022 CometChat Inc. All rights reserved

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatConversationListItem: This component will be the class of UITableViewCell with components such as avatar(Avatar), name(UILabel), message(UILabel).
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro
import AVFAudio

/* -------------------------------------------------------------------- */

/**
 The `CometChatConversationListItem` is a subclass of `UITableViewCell` which user can reuse in `CometChatConversationList`.  `CometChatConversationListItem` is tightly coupled with  SDK's `Conversation` object
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
@IBDesignable public class CometChatConversationListItem: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var statusIndicator: CometChatStatusIndicator!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var time: UILabel!
    @IBOutlet weak var unreadCount: CometChatBadgeCount!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var typingIndicator: UILabel!
    @IBOutlet weak var threadIndicator: UILabel!
    @IBOutlet weak var avatarWidthConstant: NSLayoutConstraint!
    
    var isTypingIndicatorEnabled: Bool = false
    var isThreadIndicatorEnabled: Bool = false
    var isHideDeletedMessages: Bool = false
    var hideUnreadCount: Bool = false
    var hideTime: Bool = false
    
    // MARK: - Declaration of Variables
    lazy var searchedText: String = ""
    let normalTitlefont = CometChatTheme.typography?.Name2 ?? UIFont.systemFont(ofSize: 17, weight: .medium)
    let boldTitlefont =   CometChatTheme.typography?.Name2 ?? UIFont.systemFont(ofSize: 17, weight: .medium)
    let normalSubtitlefont = CometChatTheme.typography?.Subtitle1 ?? UIFont.systemFont(ofSize: 15, weight: .regular)
    let boldSubtitlefont = CometChatTheme.typography?.Subtitle1 ?? UIFont.systemFont(ofSize: 15, weight: .regular)
    var configurations: [CometChatConfiguration]?
    // MARK: - public instance Method
    
    
    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatConversationListItem {
        self.configurations = configurations
        configureConversationListItem()
        return self
    }
    
    /**
     This method will set the `Conversation` object used in the `ConversationListItem` for all sub-components.
     - Parameters:
     - `conversation`: This specifies a `Conversation` which is being used used in the `ConversationListItem` for all sub-components.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult public func set(conversation: Conversation?) ->  CometChatConversationListItem {
        if let conversation = conversation {
            self.conversation = conversation
        }
        return self
    }
    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatListBase`.
     - Parameters:
     - background: This method will set the background color for CometChatListBase, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [Any]?) ->  CometChatConversationListItem {
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
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(title: String?) -> CometChatConversationListItem {
        self.title.text = title
        return self
    }
    
    /**
     This method will set the title with attributed text for `ConversationListItem`.
     - Parameters:
     - titleWithAttributedText: This method will set the title with attributed text for ConversationListItem.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleWithAttributedText: NSAttributedString) -> CometChatConversationListItem {
        self.title.attributedText = titleWithAttributedText
        return self
    }
    
    /**
     This method will set the title color for `CometChatConversationListItem`
     - Parameters:
     - titleColor: This method will set the title color for ConversationListItem
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatConversationListItem {
        self.title.textColor = titleColor
        return self
    }
    
    /**
     This method will set the title font for `CometChatConversationListItem`
     - Parameters:
     - titleFont: This method will set the title font for ConversationListItem
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatConversationListItem{
        self.title.font = titleFont
        return self
    }
    
    
    /**
     The SubTitle is a UILabel that specifies a subTitle for  `CometChatConversationListItem`.
     - Parameters:
     - subTitle: This method will set the subtitle for ConversationListItem.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitle: String?) -> CometChatConversationListItem {
        self.subTitle.text = subTitle
        return self
    }
    
    /**
     This method will set the subtitle with attributed text for  `CometChatConversationListItem`.
     - Parameters:
     - subTitleWithAttributedText: This method will set the subtitle with attributed text for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleWithAttributedText: NSAttributedString) -> CometChatConversationListItem {
        self.subTitle.attributedText = subTitleWithAttributedText
        return self
    }
    
    /**
     This method will set the subtitle color for  `CometChatConversationListItem`.
     - Parameters:
     - subTitleColor: This method will set the subtitle color for ConversationListItem
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> CometChatConversationListItem{
        self.subTitle.textColor = subTitleColor
        return self
    }
    
    /**
     This method will set the subtitle font for  `CometChatConversationListItem`.
     - Parameters:
     - subTitleFont:This method will set the subtitle font for ConversationListItem
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> CometChatConversationListItem{
        self.subTitle.font = subTitleFont
        return self
    }
    
    /**
     The avatar is a UIImageView that specifies an avatar for  `CometChatConversationListItem`.
     - Parameters:
     - avatar:This method will set the avatar for ConversationListItem.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> CometChatConversationListItem {
        self.avatar = avatar
        return self
    }
    
    /**
     This method will hide the avatar for `CometChatConversationListItem`.
     - Parameters:
     - avatar:This method will hide the avatar for ConversationListItem.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func hide(avatar: Bool) -> CometChatConversationListItem {
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
    
    /**
     The receipt icon is a CometChatMessageReceipt that specifies an image for a receipt for  `CometChatConversationListItem`.
     - Parameters:
     - receipt:This method will set the receipt image for ConversationListItem as per the message receipt status.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> CometChatConversationListItem {
        self.receipt.isHidden = false
        self.receipt  = receipt
        return self
    }
    
    /**
     This method will hide the receipt icon for  `CometChatConversationListItem`.
     - Parameters:
     - receipt:This method will hide the receipt icon for  `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func hide(receipt: Bool) -> CometChatConversationListItem {
        self.receipt.isHidden = receipt
        return self
    }
    
    /**
     The time is a UILabel that specifies a time for a conversation for   `CometChatConversationListItem`.
     - Parameters:
     - time:This method will set the time for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(time: Int) -> CometChatConversationListItem {
        if hideTime == false {
            self.time.text = String().setConversationsTime(time: time)
        }else{
            self.time.isHidden = true
        }
        return self
    }
    
    @discardableResult
    @objc public func hide(time: Bool) -> CometChatConversationListItem {
        self.hideTime = time
        return self
    }
    /**
     This method will set the time font for `CometChatConversationListItem`.
     - Parameters:
     - timeFont:This method will set the time font for`CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(timeFont: UIFont) -> CometChatConversationListItem{
        self.time.font = timeFont
        return self
    }
    
    /**
     This method will set the time color for `CometChatConversationListItem`.
     - Parameters:
     - timeColor:This method will set the time color for`CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(timeColor: UIColor) -> CometChatConversationListItem {
        self.time.textColor = timeColor
        return self
    }
    
    /**
     The unread count is a CometChatBadgeCount that specifies an unread count for a conversation for `CometChatConversationListItem`.
     - Parameters:
     - unreadCount:This method will set the unread badge count for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(unreadCount: CometChatBadgeCount) -> CometChatConversationListItem {
        if hideUnreadCount == true {
            self.unreadCount.isHidden = true
        }else{
            self.unreadCount  = unreadCount
        }
        return self
    }
    
    /**
     This method will hide the unread badge count for `CometChatConversationListItem`.
     - Parameters:
     - unreadCount:This method will hide the unread badge count for  `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func hide(unreadCount: Bool) -> CometChatConversationListItem {
        self.hideUnreadCount = unreadCount
        return self
    }
    
    /**
     The status indicator is a CometChatStatusIndicator that specifies a user status for a conversation for  `CometChatConversationListItem`.
     - Parameters:
     - statusIndicator: This method will set the status indicator for   `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(statusIndicator: CometChatPro.CometChat.UserStatus) -> CometChatConversationListItem {
        self.statusIndicator.isHidden = false
        self.statusIndicator.set(status: statusIndicator)
        
        return self
    }
    
    /**
     This method will hide the status indicator for `CometChatConversationListItem`.
     - Parameters:
     - statusIndicator : This method will hide the status indicator for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func hide(statusIndicator: Bool) -> CometChatConversationListItem {
        self.statusIndicator.isHidden = statusIndicator
        return self
    }
    
    /**
     The typing indicator is a UILabel that specifies a text when the user is typing for a conversation in  `CometChatConversationListItem`.
     - Parameters:
     - typingIndicatorText :This method will set the typing indicator text for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(typingIndicatorText: String) -> CometChatConversationListItem {
        if isTypingIndicatorEnabled == true {
            self.typingIndicator.text = typingIndicatorText
            self.typingIndicator.isHidden = false
        }else{
            self.typingIndicator.text = ""
            self.typingIndicator.isHidden = true
        }
        return self
    }
    
    /**
     This method will hide/show typing indicator  for `CometChatConversationListItem`.
     - Parameters:
     - typingIndicator :This method will hide/show typing indicator  for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    //    @discardableResult
    //    public func show(typingIndicator: Bool) -> CometChatConversationListItem {
    //        self.typingIndicator.isHidden = !typingIndicator
    //        return self
    //    }
    
    
    /**
     This method will set the typing indicator font   for `CometChatConversationListItem`.
     - Parameters:
     - typingIndicatorFont :This method will set the typing indicator font   for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(typingIndicatorFont: UIFont) -> CometChatConversationListItem {
        self.typingIndicator.font = typingIndicatorFont
        return self
    }
    
    
    /**
     This method will set the typing indicator color  for `CometChatConversationListItem`.
     - Parameters:
     - typingIndicatorColor :This method will set the typing indicator font   for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(typingIndicatorColor: UIColor?) -> CometChatConversationListItem{
        self.typingIndicator.textColor = typingIndicatorColor ?? #colorLiteral(red: 0.6039215686, green: 0.8039215686, blue: 0.1960784314, alpha: 1)
        return self
    }
    
    /**
     This method will hide/show typing indicator  for `CometChatConversationListItem`.
     - Parameters:
     - typingIndicator: This method will hide/show typing indicator  for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func show(typingIndicator: Bool) -> CometChatConversationListItem {
        self.isTypingIndicatorEnabled = typingIndicator
        return self
    }
    
    /**
     The thread indicator is a UILabel that specifies a text when the last message is a type of thread conversation in `CometChatConversationListItem`.
     - Parameters:
     - threadIndicatorText: This method will set the thread indicator text  `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(threadIndicatorText: String) -> CometChatConversationListItem {
        if isThreadIndicatorEnabled == true {
            self.threadIndicator.text = threadIndicatorText
        }else{
            self.threadIndicator.text = ""
        }
        return self
    }
    
    /**
     This method will set the thread indicator font for `CometChatConversationListItem`.
     - Parameters:
     - threadIndicatorFont: This method will set the thread indicator font for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(threadIndicatorFont: UIFont) -> CometChatConversationListItem {
        self.threadIndicator.font = threadIndicatorFont
        return self
    }
    
    /**
     This method will set the thread indicator color for `CometChatConversationListItem`.
     - Parameters:
     - threadIndicatorColor: This method will set the thread indicator color  `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(threadIndicatorColor: UIColor?) -> CometChatConversationListItem{
        self.threadIndicator.textColor = threadIndicatorColor ?? #colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1)
        return self
    }
    
    /**
     This method will hide/show thread indicator  for`CometChatConversationListItem`.
     - Parameters:
     - threadIndicator: This method will hide/show thread indicator  for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func hide(threadIndicator: Bool) -> CometChatConversationListItem {
        isThreadIndicatorEnabled = !threadIndicator
        return self
    }
    
    /**
     This method will show/Hide group-related actions such as group member joined, left, etc for `CometChatConversationListItem`. When this method is enabled then it will show the sub-title as empty text.
     - Parameters:
     - groupActions: This method will show/Hide group related actions such as group member joined, left etc for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func show(groupActions: Bool) -> CometChatConversationListItem {
        if groupActions == false && ((conversation?.lastMessage as? ActionMessage) != nil) {
            set(subTitle: "")
        }
        return self
    }
    
    /**
     This method will show/Hide deleted messages for `CometChatConversationListItem`. When this method is enabled then it will show the sub-title as empty text.
     - Parameters:
     - deletedMessages:  This method will show/Hide deleted messages   for `CometChatConversationListItem`.
     - Returns: This method will return `CometChatConversationListItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func show(deletedMessages: Bool) -> CometChatConversationListItem {
        if deletedMessages == false && (conversation?.lastMessage?.deletedAt ?? 0.0 > 0.0) {
            set(subTitle: "")
        }
        return self
    }
    
  
    
    @discardableResult
    public func set(inputData: InputData) -> CometChatConversationListItem {
        self.set(titleWithAttributedText: addBoldText(fullString: inputData.title! as NSString, boldPartOfString: searchedText as NSString, font: normalTitlefont, boldFont: boldTitlefont))
        self.avatar.setAvatar(avatarUrl: inputData.thumbnail ?? "", with: inputData.title ?? "").set(backgroundColor: CometChatTheme.palatte?.accent500 ?? UIColor.gray)
        if let userStatus = inputData.userStatus {
            self.set(statusIndicator: userStatus)
            self.statusIndicator.set(borderWidth: 2).set(borderColor: CometChatTheme.palatte?.background ?? UIColor.systemBackground)
        }
        if let groupType = inputData.groupType {
            
            switch groupType {
            case .public:
                statusIndicator.isHidden = true
                statusIndicator.set(borderWidth: 0)
            case .private:
                statusIndicator.isHidden = false
                statusIndicator.set(borderWidth: 0).set(backgroundColor: #colorLiteral(red: 0, green: 0.7843137255, blue: 0.4352941176, alpha: 1))
                let  image = UIImage(named: "chats-shield", in: CometChatUIKit.bundle, compatibleWith: nil)
                statusIndicator.set(icon:  image ?? UIImage(), with: .white)
                statusIndicator.set(borderWidth: 0)
            case .password:
                statusIndicator.isHidden = false
                statusIndicator.set(borderWidth: 0).set(backgroundColor: #colorLiteral(red: 0.968627451, green: 0.6470588235, blue: 0, alpha: 1))
                let image = UIImage(named: "chats-lock", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage()
                statusIndicator.set(icon:  image, with: .white)
                @unknown default: break }
        }
        return self
    }
    
    
    @discardableResult
    public func set(style: Style) -> CometChatConversationListItem {
        if let background = style.background?.cgColor {
            set(background: [background])
        }
        if let titleColor = style.titleColor {
            set(titleColor: titleColor)
        }
        if let titleFont = style.titleFont {
            set(titleFont: titleFont)
        }
        if let subTitleColor = style.subTitleColor {
            set(subTitleColor: subTitleColor)
        }
        if let subTitleFont = style.subTitleFont {
            set(subTitleFont: subTitleFont)
        }
        if let cornerRadius = style.cornerRadius {
            avatar.set(cornerRadius: cornerRadius)
        }
        if let borderWidth = style.border {
            avatar.set(borderWidth: borderWidth)
        }
        if let typingIndicatorFont = style.typingIndicatorTextFont {
            set(typingIndicatorFont: typingIndicatorFont)
        }
        if let typingIndicatorColor = style.typingIndicatorTextColor {
            set(typingIndicatorColor: typingIndicatorColor)
        }
        if let threadIndicatorTextFont = style.threadIndicatorTextFont {
            set(threadIndicatorFont: threadIndicatorTextFont)
        }
        if let threadIndicatorTextColor = style.threadIndicatorTextColor {
            set(threadIndicatorColor: threadIndicatorTextColor)
        }
        return self
    }
    
    weak var conversation: Conversation? {
        didSet {
            if let currentConversation = conversation {
                
                switch currentConversation.conversationType {
                case .user:
                    guard let user =  currentConversation.conversationWith as? User else {
                        return
                    }
                    
                    let inputData = InputData(id: user.uid ?? "", thumbnail: user.avatar, userStatus: user.status, title: user.name, subTitle: "")
                    
                    self.set(inputData: inputData)
                    
                case .group:
                    guard let group =  currentConversation.conversationWith as? Group else { return  }
                    
                    let inputData = InputData(id: group.guid, thumbnail: group.icon,  groupType: group.groupType, title: group.name, subTitle: "")
                    
                    self.set(inputData: inputData)
                    
                case .none: break
                @unknown default:  break
                }
                
                
                
                if let currentMessage = currentConversation.lastMessage {
                    let senderName = currentMessage.sender?.name
                    switch currentMessage.messageCategory {
                    case .message:
                        if currentMessage.deletedAt > 0.0 {
                            if isHideDeletedMessages {
                                self.set(subTitle: "")
                            }else {
                                self.set(subTitle: "THIS_MESSAGE_DELETED".localize())
                            }
                        }else {
                            switch currentMessage.messageType {
                            case .text where currentConversation.conversationType == .user:
                                
                                if let textMessage = currentConversation.lastMessage as? TextMessage {
                                    self.parseProfanityFilter(forMessage: textMessage)
                                    self.parseMaskedData(forMessage: textMessage)
                                    self.parseSentimentAnalysis(forMessage: textMessage)
                                }
                                
                            case .text where currentConversation.conversationType == .group:
                                
                                if let textMessage = currentConversation.lastMessage as? TextMessage {
                                    self.parseProfanityFilter(forMessage: textMessage)
                                    self.parseMaskedData(forMessage: textMessage)
                                    self.parseSentimentAnalysis(forMessage: textMessage)
                                }
                                
                            case .image where currentConversation.conversationType == .user:
                                self.set(subTitle: "MESSAGE_IMAGE".localize())
                            case .image where currentConversation.conversationType == .group:
                                self.set(subTitle: senderName! + ":  " + "MESSAGE_IMAGE".localize())
                            case .video  where currentConversation.conversationType == .user:
                                self.set(subTitle: "MESSAGE_VIDEO".localize())
                            case .video  where currentConversation.conversationType == .group:
                                self.set(subTitle: senderName! + ":  " + "MESSAGE_VIDEO".localize())
                            case .audio  where currentConversation.conversationType == .user:
                                self.set(subTitle: "MESSAGE_AUDIO".localize())
                            case .audio  where currentConversation.conversationType == .group:
                                self.set(subTitle: senderName! + ":  " + "MESSAGE_AUDIO".localize())
                            case .file  where currentConversation.conversationType == .user:
                                self.set(subTitle: "MESSAGE_FILE".localize())
                            case .file  where currentConversation.conversationType == .group:
                                self.set(subTitle: senderName! + ":  " + "MESSAGE_FILE".localize())
                            case .custom where currentConversation.conversationType == .user:
                                
                                if let customMessage = currentConversation.lastMessage as? CustomMessage {
                                    if customMessage.type == "location" {
                                        self.set(subTitle: "CUSTOM_MESSAGE_LOCATION".localize())
                                    }else if customMessage.type == "extension_poll" {
                                        self.set(subTitle: "CUSTOM_MESSAGE_POLL".localize())
                                    }else if customMessage.type == "extension_sticker" {
                                        self.set(subTitle: "CUSTOM_MESSAGE_STICKER".localize())
                                    }else if customMessage.type == "extension_whiteboard" {
                                        self.set(subTitle: "CUSTOM_MESSAGE_WHITEBOARD".localize())
                                    }else if customMessage.type == "extension_document" {
                                        self.set(subTitle: "CUSTOM_MESSAGE_DOCUMENT".localize())
                                    }else if customMessage.type == "meeting" {
                                        self.set(subTitle: "HAS_INITIATED_GROUP_AUDIO_CALL".localize())
                                    }
                                    
                                }else{
                                    self.set(subTitle: "CUSTOM_MESSAGE".localize())
                                }
                                
                            case .custom where currentConversation.conversationType == .group:
                                if let customMessage = currentConversation.lastMessage as? CustomMessage {
                                    if customMessage.type == "location" {
                                        self.set(subTitle: senderName! + ":  " + "CUSTOM_MESSAGE_LOCATION".localize())
                                    }else if customMessage.type == "extension_poll" {
                                        self.set(subTitle: senderName! + ":  " + "CUSTOM_MESSAGE_POLL".localize())
                                    }else if customMessage.type == "extension_sticker" {
                                        self.set(subTitle:  senderName! + ":  " + "CUSTOM_MESSAGE_STICKER".localize())
                                    }else if customMessage.type == "extension_whiteboard" {
                                        self.set(subTitle: senderName! + ":  " + "CUSTOM_MESSAGE_WHITEBOARD".localize())
                                    }else if customMessage.type == "extension_document" {
                                        self.set(subTitle: senderName! + ":  " + "CUSTOM_MESSAGE_DOCUMENT".localize())
                                    }else if customMessage.type == "meeting" {
                                        self.set(subTitle: senderName! + ":  " + "HAS_INITIATED_GROUP_AUDIO_CALL".localize())
                                    }
                                }else{
                                    self.set(subTitle: senderName! +  ":  " +  "CUSTOM_MESSAGE".localize())
                                }
                            case .groupMember, .text, .image, .video,.audio, .file,.custom: break
                            @unknown default: break
                            }
                        }
                    case .action:
                        if currentConversation.conversationType == .user {
                            if  let text = (currentConversation.lastMessage as? ActionMessage)?.message as NSString? {
                                
                                self.set(subTitleWithAttributedText: addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                                
                            }
                        }
                        if currentConversation.conversationType == .group {
                            if  let text = ((currentConversation.lastMessage as? ActionMessage)?.message ?? "") as NSString? {
                                
                                self.set(subTitleWithAttributedText: addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                                
                            }
                        }
                    case .call:
                        self.set(subTitle: "HAS_SENT_A_CALL".localize())
                    case .custom where currentConversation.conversationType == .user:
                        
                        if let customMessage = currentConversation.lastMessage as? CustomMessage {
                            if customMessage.type == "location" {
                                self.set(subTitle: "CUSTOM_MESSAGE_LOCATION".localize())
                            }else if customMessage.type == "extension_poll" {
                                self.set(subTitle: "CUSTOM_MESSAGE_POLL".localize())
                            }else if customMessage.type == "extension_sticker" {
                                self.set(subTitle:   "CUSTOM_MESSAGE_STICKER".localize())
                            }else if customMessage.type == "extension_whiteboard" {
                                self.set(subTitle: "CUSTOM_MESSAGE_WHITEBOARD".localize())
                            }else if customMessage.type == "extension_document" {
                                self.set(subTitle: "CUSTOM_MESSAGE_DOCUMENT".localize())
                            }else if customMessage.type == "meeting" {
                                self.set(subTitle: "HAS_INITIATED_GROUP_AUDIO_CALL".localize())
                            }else{
                                self.set(subTitle: "\(customMessage.customData)")
                            }
                        }
                        
                    case .custom where currentConversation.conversationType == .group:
                        if let customMessage = currentConversation.lastMessage as? CustomMessage {
                            if customMessage.type == "location" {
                                self.set(subTitle: senderName! + ":  " + "CUSTOM_MESSAGE_LOCATION".localize())
                            }else if customMessage.type == "extension_poll" {
                                self.set(subTitle: senderName! + ":  " + "CUSTOM_MESSAGE_POLL".localize())
                            }else if customMessage.type == "extension_sticker" {
                                self.set(subTitle:  senderName! + ":  " + "CUSTOM_MESSAGE_STICKER".localize())
                            }else if customMessage.type == "extension_whiteboard" {
                                self.set(subTitle: senderName! + ":  " + "CUSTOM_MESSAGE_WHITEBOARD".localize())
                            }else if customMessage.type == "extension_document" {
                                self.set(subTitle: senderName! + ":  " + "CUSTOM_MESSAGE_DOCUMENT".localize())
                            }else if customMessage.type == "meeting" {
                                self.set(subTitle: senderName! + ":  " + "HAS_INITIATED_GROUP_AUDIO_CALL".localize())
                            }
                        }
                    case .custom: break
                    @unknown default: break
                    }
                    
                    self.set(receipt: receipt.set(receipt: currentMessage))
                    
                    if currentMessage.parentMessageId != 0 {
                        self.set(threadIndicatorText: "In a thread  ⤵").hide(threadIndicator: false)
                    }else {
                        self.set(threadIndicatorText: "").hide(threadIndicator: true)
                    }
                }else{
                    set(subTitle: "Tap to start conversation")
                    receipt.isHidden = true
                }
                
                self.set(time: Int(currentConversation.updatedAt))
                self.set(unreadCount: unreadCount.set(backgroundColor: CometChatTheme.palatte?.primary ?? UIColor.clear).set(count: currentConversation.unreadMessageCount))
                
                // Setting colors
                self.set(background: [UIColor.clear.cgColor])
                self.set(titleColor: CometChatTheme.palatte?.accent ?? UIColor.clear)
                self.set(subTitleColor:  CometChatTheme.palatte?.accent700 ?? UIColor.clear)
                
                self.show(groupActions: CometChatStore.conversations.hideGroupActions)
                self.show(deletedMessages: CometChatStore.conversations.hideDeletedMessages)
            }
            self.hide(avatar: false)
            self.addLongPress()
            
            let style = Style(background: CometChatTheme.palatte?.background, border: 1, cornerRadius: 25, titleColor: CometChatTheme.palatte?.accent, titleFont: CometChatTheme.typography?.Name2, subTitleColor: CometChatTheme.palatte?.accent500, subTitleFont: CometChatTheme.typography?.Subtitle1, typingIndicatorTextColor: CometChatTheme.palatte?.accent500, typingIndicatorTextFont: CometChatTheme.typography?.Subtitle1, threadIndicatorTextColor: CometChatTheme.palatte?.accent500, threadIndicatorTextFont: CometChatTheme.typography?.Subtitle1)
            
            set(style: style)
            configureConversationListItem()
        }
    }
    
    private func addLongPress() {
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(onItemLongClick))
        self.background.addGestureRecognizer(longPressRecognizer)
        self.background.isUserInteractionEnabled = true
    }
    
    @objc func onItemLongClick(sender: UITapGestureRecognizer){
        if sender.state == .began {
            if let conversation = conversation {
                CometChatConversations.comethatConversationsDelegate?.onItemLongClick?(conversation: conversation)
            }
        }
    }
    
    private func configureConversationListItem() {
        
        if let configurations = configurations {
            
            let conversationListItemConfiguration = configurations.filter{ $0 is ConversationListItemConfiguration }
            if let configuration = conversationListItemConfiguration.last as? ConversationListItemConfiguration {
                set(background: configuration.background)
                hide(avatar: configuration.hideAvatar)
                hide(statusIndicator: configuration.hideStatusIndicator)
                hide(receipt: configuration.hideReceipt)
                hide(unreadCount: configuration.hideUnreadCount)
                hide(threadIndicator: configuration.hideThreadIndicator)
                set(threadIndicatorText: configuration.threadIndicatorText)
                show(typingIndicator: configuration.showTypingIndicator)
                show(deletedMessages: !configuration.hideDeletedMessages)
                show(groupActions: !configuration.hideGroupActionMessages)
                hide(time: configuration.hideTime)
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
            
            let messageReceiptConfiguration = configurations.filter{ $0 is MessageReceiptConfiguration }
            if let configuration = messageReceiptConfiguration.last as? MessageReceiptConfiguration {
                
                receipt.set(messageInProgressIcon: configuration.getProgressIcon())
                    .set(messageReadIcon: configuration.getReadIcon())
                    .set(messageDeliveredIcon: configuration.getDeliveredIcon())
                    .set(messageErrorIcon: configuration.getFailureIcon())
                    .set(messageSentIcon: configuration.getSentIcon())
                
                set(receipt: receipt)
            }
            
            let badgeCountConfiguration = configurations.filter{ $0 is BadgeCountConfiguration }
            if let configuration = badgeCountConfiguration.last as? BadgeCountConfiguration {
                
                unreadCount.set(cornerRadius: configuration.cornerRadius)
                set(unreadCount: unreadCount)
            }
        }
    }
    
    
    
    public override func prepareForReuse() {
        conversation = nil
        searchedText = ""
    }
    
    // MARK: - Initialization of required Methods
    
    public override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    public override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Private Instance Methods
    
    /// This method bold the text which is added in Search bar.
    /// - Parameters:
    ///   - fullString: Contains full string
    ///   - boldPartOfString: contains searched text string
    ///   - font: normal font
    ///   - boldFont: bold font
    func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont, boldFont: UIFont) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedString.Key.font:font]
        let boldFontAttribute = [NSAttributedString.Key.font:boldFont]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartOfString as String, options: .caseInsensitive))
        return boldString
    }
    
    
    /*  ----------------------------------------------------------------------------------------- */
    
    
    func parseProfanityFilter(forMessage: TextMessage){
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let profanityFilterDictionary = cometChatExtension["profanity-filter"] as? [String : Any] {
            
            if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {
                
                if profanity == "yes" {
                    switch forMessage.messageType {
                    case .text where forMessage.receiverType == .user:
                        
                        if  let text = filteredMessage as NSString? {
                            self.set(subTitleWithAttributedText:  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                        }
                        
                    case .text where forMessage.receiverType == .group:
                        let senderName = forMessage.sender?.name
                        if  let text = senderName! + ":  " + filteredMessage as NSString? {
                            self.set(subTitleWithAttributedText:  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                        }
                        
                    case .text, .image, .video, .audio, .file, .custom,.groupMember: break
                    @unknown default: break
                    }
                }else{
                    switch forMessage.messageType {
                    case .text where forMessage.receiverType == .user:
                        self.set(subTitleWithAttributedText: addBoldText(fullString: forMessage.text as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                    case .text where forMessage.receiverType == .group:
                        let senderName = forMessage.sender?.name
                        if  let text = senderName! + ":  " + filteredMessage as NSString? {
                            self.set(subTitleWithAttributedText:  addBoldText(fullString: forMessage.text as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                        }
                    case .text, .image, .video, .audio, .file, .custom,.groupMember: break
                    }
                }
            }else{
                switch forMessage.messageType {
                case .text where forMessage.receiverType == .user:
                    self.set(subTitleWithAttributedText:  addBoldText(fullString: forMessage.text as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                case .text where forMessage.receiverType == .group:
                    let senderName = forMessage.sender?.name
                    if  let text = senderName! + ":  " + forMessage.text as NSString? {
                        self.set(subTitleWithAttributedText:  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                    }
                case .text, .image, .video, .audio, .file, .custom,.groupMember: break
                }
            }
        }else{
            switch forMessage.messageType {
            case .text where forMessage.receiverType == .user:
                self.set(subTitleWithAttributedText: addBoldText(fullString: forMessage.text as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
            case .text where forMessage.receiverType == .group:
                let senderName = forMessage.sender?.name
                if  let text = senderName! + ":  " + forMessage.text as NSString? {
                    self.set(subTitleWithAttributedText:  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                }
            case .text, .image, .video, .audio, .file, .custom,.groupMember: break
            }
        }
    }
    
    func parseMaskedData(forMessage: TextMessage){
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let dataMaskingDictionary = cometChatExtension["data-masking"] as? [String : Any] {
            
            if let data = dataMaskingDictionary["data"] as? [String:Any], let sensitiveData = data["sensitive_data"] as? String {
                
                if sensitiveData == "yes" {
                    if let maskedMessage = data["message_masked"] as? String {
                        
                        switch forMessage.messageType {
                        case .text where forMessage.receiverType == .user:
                            
                            if  let text = maskedMessage as NSString? {
                                self.set(subTitleWithAttributedText:  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                            }
                            
                        case .text where forMessage.receiverType == .group:
                            let senderName = forMessage.sender?.name
                            if  let text = senderName! + ":  " + maskedMessage as NSString? {
                                self.set(subTitleWithAttributedText:  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                            }
                            
                        case .text, .image, .video, .audio, .file, .custom,.groupMember: break
                        @unknown default: break
                        }
                        
                    }else{
                        self.parseProfanityFilter(forMessage: forMessage)
                    }
                }else{
                    self.parseProfanityFilter(forMessage: forMessage)
                }
            }else{
                self.parseProfanityFilter(forMessage: forMessage)
            }
        }else{
            self.parseProfanityFilter(forMessage: forMessage)
        }
    }
    
    func parseSentimentAnalysis(forMessage: TextMessage){
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let sentimentAnalysisDictionary = cometChatExtension["sentiment-analysis"] as? [String : Any] {
            if let sentiment = sentimentAnalysisDictionary["sentiment"] as? String {
                if sentiment == "negative" {
                    
                    self.set(subTitleWithAttributedText:  addBoldText(fullString: "MAY_CONTAIN_NEGATIVE_SENTIMENT".localize() as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont))
                    
                }else{
                    self.parseProfanityFilter(forMessage: forMessage)
                    self.parseMaskedData(forMessage: forMessage)
                }
            }else{
                self.parseProfanityFilter(forMessage: forMessage)
                self.parseMaskedData(forMessage: forMessage)
            }
        }else{
            
            self.parseProfanityFilter(forMessage: forMessage)
            self.parseMaskedData(forMessage: forMessage)
        }
    }
    
}
