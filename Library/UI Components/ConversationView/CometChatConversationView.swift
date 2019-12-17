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
    
    var conversation: Conversation! {
        didSet {
            if conversation.lastMessage != nil {
                switch conversation.conversationType {
                    
                case .user:
                    guard let user =  conversation.conversationWith as? User else {
                        return
                    }
                    name.text = user.name
                    avtar.set(image: user.avatar ?? "")
                    status.isHidden = false
                    status.set(status: user.status)
                    
                case .group:
                    guard let group =  conversation.conversationWith as? Group else {
                        return
                    }
                    name.text = group.name
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
                        message.text = (conversation.lastMessage as? TextMessage)?.text
                    case .text where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + (conversation.lastMessage as? TextMessage)!.text
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
                    case .video  where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + "🎵 has sent a audio."
                    case .file  where conversation.conversationType == .user:
                        message.text = "📁 has sent a file."
                    case .video  where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + "📁 has sent a file."
                    case .custom where conversation.conversationType == .group:
                        message.text = senderName! + ":  " + "has sent a custom message."
                    case .custom where conversation.conversationType == .user:
                        message.text = "has sent a custom message."
                    case .groupMember:break
                    case .none:break
                    case .some(_):break
                    }
                case .action:
                    if conversation.conversationType == .user {
                        message.text = (conversation.lastMessage as? ActionMessage)?.message
                    }
                    if conversation.conversationType == .group {
                        message.text = ((conversation.lastMessage as? ActionMessage)?.message ?? "")
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
    
}
