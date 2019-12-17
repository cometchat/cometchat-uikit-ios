//
//  TextBubble.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 16/10/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class RightTextMessageBubble: UITableViewCell {
    
    @IBOutlet weak var message: ChattingBubble!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var textMessage: TextMessage! {
        didSet {
            self.selectionStyle = .none
            message.text = textMessage.text
            if textMessage.readAt > 0 {
            receipt.image = #imageLiteral(resourceName: "read")
            timeStamp.text = String().setMessageTime(time: Int(textMessage?.readAt ?? 0))
            }else if textMessage.deliveredAt > 0 {
            receipt.image = #imageLiteral(resourceName: "delivered")
            timeStamp.text = String().setMessageTime(time: Int(textMessage?.deliveredAt ?? 0))
            }else if textMessage.sentAt > 0 {
            receipt.image = #imageLiteral(resourceName: "sent")
            timeStamp.text = String().setMessageTime(time: Int(textMessage?.sentAt ?? 0))
            }else if textMessage.sentAt == 0 {
               receipt.image = #imageLiteral(resourceName: "wait")
               timeStamp.text = "Sending..."
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
