//
//  TextBubble.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 16/10/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class LeftImageMessageBubble: UITableViewCell {
    
   
    @IBOutlet weak var avtar: Avtar!
    @IBOutlet weak var imageMessage: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    
    
    var mediaMessage: MediaMessage!{
           didSet {
                self.selectionStyle = .none
            self.timeStamp.isHidden = true
            self.heightConstraint.constant = 0
                timeStamp.text = String().setMessageTime(time: mediaMessage.sentAt)
                imageMessage.kf.setImage(with: URL(string: mediaMessage.attachment?.fileUrl ?? ""))
                avtar.kf.setImage(with: URL(string: mediaMessage.sender?.avatar ?? ""))
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
