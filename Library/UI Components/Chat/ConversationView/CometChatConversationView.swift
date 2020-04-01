
//  CometChatConversationView.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

CometChatConversationView: This component will be the class of UITableViewCell with components such as avatar(Avatar), name(UILabel), message(UILabel).

>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatConversationView: UITableViewCell {
    
     // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var status: StatusIndicator!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var unreadBadgeCount: BadgeCount!
    @IBOutlet weak var read: UIImageView!
    @IBOutlet weak var typing: UILabel!
    
    // MARK: - Declaration of Variables
    
    var searchedText: String = ""
    let normalTitlefont = UIFont(name: "SFProDisplay-Medium", size: 17)
    let boldTitlefont = UIFont(name: "SFProDisplay-Bold", size: 17)
    let normalSubtitlefont = UIFont(name: "SFProDisplay-Regular", size: 15)
    let boldSubtitlefont = UIFont(name: "SFProDisplay-Bold", size: 15)
    var conversation: Conversation! {
        didSet {
            if conversation.lastMessage != nil {
                switch conversation.conversationType {
                case .user:
                    guard let user =  conversation.conversationWith as? User else {
                        return
                    }
                    name.attributedText = addBoldText(fullString: user.name! as NSString, boldPartOfString: searchedText as NSString, font: normalTitlefont, boldFont: boldTitlefont)
                    avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                    status.isHidden = false
                    status.set(status: user.status)
                case .group:
                    guard let group =  conversation.conversationWith as? Group else {
                        return
                    }
                    name.attributedText = addBoldText(fullString: group.name! as NSString, boldPartOfString: searchedText as NSString, font: normalTitlefont, boldFont: boldTitlefont)
                    avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    status.isHidden = true
                case .none:
                    break
                @unknown default:
                    break
                }
                
                let senderName = conversation.lastMessage?.sender?.name
                switch conversation.lastMessage!.messageCategory {
                case .message:
                    switch conversation.lastMessage?.messageType {
                    case .text where conversation.conversationType == .user:
                        
                        if  let text = (conversation.lastMessage as? TextMessage)?.text as NSString? {
                            message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                        }
                        
                    case .text where conversation.conversationType == .group:

                        if  let text = senderName! + ":  " + (conversation.lastMessage as? TextMessage)!.text as NSString? {
                            message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                        }
                        
                    case .image where conversation.conversationType == .user:
                        message.text = NSLocalizedString("HAS_SENT_AN_IMAGE", comment: "")
                    case .image where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + NSLocalizedString("HAS_SENT_AN_IMAGE", comment: "")
                    case .video  where conversation.conversationType == .user:
                        message.text = NSLocalizedString("HAS_SENT_A_VIDEO", comment: "")
                    case .video  where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + NSLocalizedString("HAS_SENT_A_VIDEO", comment: "")
                    case .audio  where conversation.conversationType == .user:
                        message.text = NSLocalizedString("HAS_SENT_A_AUDIO", comment: "")
                    case .audio  where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + NSLocalizedString("HAS_SENT_A_AUDIO", comment: "")
                    case .file  where conversation.conversationType == .user:
                        message.text = NSLocalizedString("HAS_SENT_A_FILE", comment: "")
                    case .file  where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + NSLocalizedString("HAS_SENT_A_FILE", comment: "")
                    case .custom where conversation.conversationType == .user:
                        message.text = NSLocalizedString("HAS_SENT_A_CUSTOM_MESSAGE", comment: "")
                    case .custom where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + NSLocalizedString("HAS_SENT_A_CUSTOM_MESSAGE", comment: "")
                        
                    case .groupMember:break
                    case .none:break
                    case .some(_):break
                    }
                case .action:
                    if conversation.conversationType == .user {
                        if  let text = (conversation.lastMessage as? ActionMessage)?.message as NSString? {
                            message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                        }
                    }
                    if conversation.conversationType == .group {
                        if  let text = ((conversation.lastMessage as? ActionMessage)?.message ?? "") as NSString? {
                            message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                        }
                    }
                case .call:
                    message.text = NSLocalizedString("HAS_SENT_A_CALL", comment: "")
                case .custom:
                    message.text = NSLocalizedString("HAS_SENT_A_CUSTOM_MESSAGE", comment: "")
                @unknown default:
                    break
                }
                timeStamp.text = String().setConversationsTime(time: Int(conversation.updatedAt))
                if let readAt = conversation.lastMessage?.readAt, readAt > 0.0  {
                    read.isHidden = false
                }else{
                    read.isHidden = true
                }
                unreadBadgeCount.set(count: conversation.unreadMessageCount)
            }
        }
    }
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
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
    private func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedString.Key.font:font!]
        let boldFontAttribute = [NSAttributedString.Key.font:boldFont!]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartOfString as String, options: .caseInsensitive))
        return boldString
    }
}

/*  ----------------------------------------------------------------------------------------- */
