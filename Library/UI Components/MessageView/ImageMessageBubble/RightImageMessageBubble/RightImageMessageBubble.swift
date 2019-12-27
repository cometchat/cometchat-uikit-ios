//
//  TextBubble.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 16/10/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class RightImageMessageBubble: UITableViewCell {
    
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var activityIndicator: CCActivityIndicator!
    @IBOutlet weak var receipt: UIImageView!
    
    
    var mediaMessage: MediaMessage! {
        didSet {
            self.selectionStyle = .none
            timeStamp.isHidden = true
            heightConstraint.constant = 0
            if mediaMessage.sentAt == 0 {
                timeStamp.text = "Sending..."
                activityIndicator.isHidden = false
                activityIndicator.startAnimating()
            }else{
                activityIndicator.isHidden = true
                activityIndicator.stopAnimating()
                timeStamp.text = String().setMessageTime(time: mediaMessage.sentAt)
            }
            let url = URL(string: mediaMessage.attachment?.fileUrl ?? "")
            imageMessage.kf.setImage(with: url)
            
            if mediaMessage.readAt > 0 {
            receipt.image = #imageLiteral(resourceName: "read")
            timeStamp.text = String().setMessageTime(time: Int(mediaMessage?.readAt ?? 0))
            }else if mediaMessage.deliveredAt > 0 {
            receipt.image = #imageLiteral(resourceName: "delivered")
            timeStamp.text = String().setMessageTime(time: Int(mediaMessage?.deliveredAt ?? 0))
            }else if mediaMessage.sentAt > 0 {
            receipt.image = #imageLiteral(resourceName: "sent")
            timeStamp.text = String().setMessageTime(time: Int(mediaMessage?.sentAt ?? 0))
            }else if mediaMessage.sentAt == 0 {
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
    
    public func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.kf.setImage(with: url)
    }
    
}
