//
//  ReceiverTextBubble.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 16/10/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class LeftTextMessageBubble: UITableViewCell {
    
    @IBOutlet weak var avtar: Avtar!
    @IBOutlet weak var message: ChattingBubble!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    var textMessage: TextMessage! {
        didSet {
            self.selectionStyle = .none
            message.text = textMessage.text
            timeStamp.isHidden = true
            heightConstraint.constant = 0
            if let avtarURL = textMessage.sender?.avatar  {
                avtar.set(image: avtarURL)
            }
            timeStamp.text = String().setMessageTime(time: textMessage.sentAt)
            
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
    
    public func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.kf.setImage(with: url)
        }
    }
    




