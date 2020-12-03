
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
    
    lazy var searchedText: String = ""
    
    let normalTitlefont = UIFont.systemFont(ofSize: 17, weight: .medium)
    let boldTitlefont = UIFont.systemFont(ofSize: 17, weight: .bold)
    let normalSubtitlefont = UIFont.systemFont(ofSize: 15, weight: .regular)
    let boldSubtitlefont = UIFont.systemFont(ofSize: 15, weight: .bold)
    
    
    weak var conversation: Conversation? {
        didSet {
            if let currentConversation = conversation {
                switch currentConversation.conversationType {
                case .user:
                    guard let user =  currentConversation.conversationWith as? User else {
                        return
                    }
                    name.attributedText = addBoldText(fullString: user.name! as NSString, boldPartOfString: searchedText as NSString, font: normalTitlefont, boldFont: boldTitlefont)
                    avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                    status.isHidden = false
                    status.set(status: user.status)
                    
                    if UIKitSettings.showUserPresence == .disabled {
                        status.isHidden = true
                    }else{
                        status.isHidden = false
                    }
                case .group:
                    guard let group =  currentConversation.conversationWith as? Group else {
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
                
                let senderName = currentConversation.lastMessage?.sender?.name
                switch currentConversation.lastMessage!.messageCategory {
                case .message:
                    switch currentConversation.lastMessage?.messageType {
                    case .text where currentConversation.conversationType == .user:
                        
                        if  let text = (currentConversation.lastMessage as? TextMessage)?.text as NSString? {
                            message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                        }
                        
                    case .text where currentConversation.conversationType == .group:
                        
                        if  let text = senderName! + ":  " + (currentConversation.lastMessage as? TextMessage)!.text as NSString? {
                            message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                        }
                        
                    case .image where currentConversation.conversationType == .user:
                        message.text = NSLocalizedString("HAS_SENT_AN_IMAGE", bundle: UIKitSettings.bundle, comment: "")
                    case .image where currentConversation.conversationType == .group:
                        message.text = senderName! + ":  " + NSLocalizedString("HAS_SENT_AN_IMAGE", bundle: UIKitSettings.bundle, comment: "")
                    case .video  where currentConversation.conversationType == .user:
                        message.text = NSLocalizedString("HAS_SENT_A_VIDEO", bundle: UIKitSettings.bundle, comment: "")
                    case .video  where currentConversation.conversationType == .group:
                        message.text = senderName! + ":  " + NSLocalizedString("HAS_SENT_A_VIDEO", bundle: UIKitSettings.bundle, comment: "")
                    case .audio  where currentConversation.conversationType == .user:
                        message.text = NSLocalizedString("HAS_SENT_A_AUDIO", bundle: UIKitSettings.bundle, comment: "")
                    case .audio  where currentConversation.conversationType == .group:
                        message.text = senderName! + ":  " + NSLocalizedString("HAS_SENT_A_AUDIO", bundle: UIKitSettings.bundle, comment: "")
                    case .file  where currentConversation.conversationType == .user:
                        message.text = NSLocalizedString("HAS_SENT_A_FILE", bundle: UIKitSettings.bundle, comment: "")
                    case .file  where currentConversation.conversationType == .group:
                        message.text = senderName! + ":  " + NSLocalizedString("HAS_SENT_A_FILE", bundle: UIKitSettings.bundle, comment: "")
                    case .custom where currentConversation.conversationType == .user:
                        
                        if let customMessage = currentConversation.lastMessage as? CustomMessage {
                            if customMessage.type == "location" {
                                message.text = "📍 has shared location"
                            }else if customMessage.type == "extension_poll" {
                                message.text = "📊 has added new poll"
                            }else if customMessage.type == "extension_sticker" {
                                message.text = "💟 has sent sticker"
                            }else if customMessage.type == "extension_whiteboard" {
                                message.text = "📝 has shared whiteboard"
                            }else if customMessage.type == "extension_document" {
                                message.text = "📃 has shared document"
                            }
                        }else{
                            message.text = NSLocalizedString("HAS_SENT_A_CUSTOM_MESSAGE",  bundle: UIKitSettings.bundle, comment: "")
                        }
                       
                    case .custom where currentConversation.conversationType == .group:
                        if let customMessage = currentConversation.lastMessage as? CustomMessage {
                            if customMessage.type == "location" {
                                message.text = senderName! + ":  " + "📍 has shared location"
                            }else if customMessage.type == "extension_poll" {
                                message.text = senderName! + ":  " + "📊 has added new poll"
                            }else if customMessage.type == "extension_sticker" {
                                message.text =  senderName! + ":  " + "💟 has sent sticker"
                           }else if customMessage.type == "extension_whiteboard" {
                            message.text = senderName! + ":  " + "📝 has shared whiteboard"
                        }else if customMessage.type == "extension_document" {
                            message.text = senderName! + ":  " + "📃 has shared document"
                        }
                        }else{
                            message.text = senderName! +  ":  " +  NSLocalizedString("HAS_SENT_A_CUSTOM_MESSAGE",  bundle: UIKitSettings.bundle, comment: "")
                        }
                    case .groupMember:break
                    case .none:break
                    case .some(_):break
                    }
                case .action:
                    if currentConversation.conversationType == .user {
                        if  let text = (currentConversation.lastMessage as? ActionMessage)?.message as NSString? {
                            message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                        }
                    }
                    if currentConversation.conversationType == .group {
                        if  let text = ((currentConversation.lastMessage as? ActionMessage)?.message ?? "") as NSString? {
                            message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                        }
                    }
                case .call:
                    message.text = NSLocalizedString("HAS_SENT_A_CALL", bundle: UIKitSettings.bundle, comment: "")
                case .custom where currentConversation.conversationType == .user:
                    
                    if let customMessage = currentConversation.lastMessage as? CustomMessage {
                        if customMessage.type == "location" {
                            message.text = "📍 has shared location"
                        }else if customMessage.type == "extension_poll" {
                            message.text = "📊 has added new poll"
                        }else if customMessage.type == "extension_sticker" {
                            message.text =   "💟 has sent sticker"
                       }else if customMessage.type == "extension_whiteboard" {
                        message.text = "📝 has shared whiteboard"
                    }else if customMessage.type == "extension_document" {
                        message.text = "📃 has shared document"
                    }
                    }
                    
                case .custom where currentConversation.conversationType == .group:
                    if let customMessage = currentConversation.lastMessage as? CustomMessage {
                        if customMessage.type == "location" {
                            message.text = senderName! + ":  " + "📍 has shared location"
                        }else if customMessage.type == "extension_poll" {
                            message.text = senderName! + ":  " + "📊 has added new poll"
                        }else if customMessage.type == "extension_sticker" {
                            message.text =  senderName! + ":  " + "💟 has sent sticker"
                       }else if customMessage.type == "extension_whiteboard" {
                        message.text = senderName! + ":  " + "📝 has shared whiteboard"
                    }else if customMessage.type == "extension_document" {
                        message.text = senderName! + ":  " + "📃 has shared document"
                    }
                    }
                @unknown default:
                    break
                }
                timeStamp.text = String().setConversationsTime(time: Int(currentConversation.updatedAt))
                if let readAt = currentConversation.lastMessage?.readAt, readAt > 0.0  {
                    read.isHidden = false
                }else{
                    read.isHidden = true
                }
                unreadBadgeCount.set(count: currentConversation.unreadMessageCount)
            }
        }
    }
    
    override func prepareForReuse() {
        conversation = nil
        searchedText = ""
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
