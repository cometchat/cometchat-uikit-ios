//
//  UserView.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class CometChatConversationView: UITableViewCell {
    
    @IBOutlet weak var avtar: Avtar!
    @IBOutlet weak var status: StatusIndicator!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var unreadBadgeCount: BadgeCount!
    @IBOutlet weak var read: UIImageView!
    @IBOutlet weak var typing: UILabel!
    
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
                    avtar.set(image: user.avatar ?? "")
                    status.isHidden = false
                    status.set(status: user.status)
                case .group:
                    guard let group =  conversation.conversationWith as? Group else {
                        return
                    }
                    name.attributedText = addBoldText(fullString: group.name! as NSString, boldPartOfString: searchedText as NSString, font: normalTitlefont, boldFont: boldTitlefont)
                    
                    avtar.set(image: group.icon ?? "")
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
                        message.text = "📷 has sent an image."
                    case .image where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + "📷 has sent an image."
                    case .video  where conversation.conversationType == .user:
                        message.text = "📹 has sent a video."
                    case .video  where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + "📹 has sent a video."
                    case .audio  where conversation.conversationType == .user:
                        message.text = "🎵 has sent a audio."
                    case .audio  where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + "🎵 has sent a audio."
                    case .file  where conversation.conversationType == .user:
                        message.text = "📁 has sent a file."
                    case .file  where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + "📁 has sent a file."
                    case .custom where conversation.conversationType == .user:
                        message.text = "has sent a custom message."
                    case .custom where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + "has sent a custom message."
                        
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
                    message.text = "has sent a call."
                case .custom:
                    message.text = "has sent a custom message."
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
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedString.Key.font:font!]
        let boldFontAttribute = [NSAttributedString.Key.font:boldFont!]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartOfString as String, options: .caseInsensitive))
        return boldString
    }
}

