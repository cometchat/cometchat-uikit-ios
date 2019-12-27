//
//  SenderFileBubble.swift
//  CometChatUIKitDemo
//
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class RightFileMessageBubble: UITableViewCell {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var type: UILabel!
    @IBOutlet weak var size: UILabel!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!
    @IBOutlet weak var receipt: UIImageView!
    
    @IBOutlet weak var receiptStack: UIStackView!
    
    var fileMessage: MediaMessage! {
        didSet {
                   self.selectionStyle = .none
                   timeStamp.isHidden = true
                   heightConstraint.constant = 0
                   if fileMessage.sentAt == 0 {
                       timeStamp.text = "Sending..."
                       name.text = "---"
                       type.text = "---"
                       size.text = "---"
                   }else{
                       timeStamp.text = String().setMessageTime(time: fileMessage.sentAt)
                    name.text = fileMessage.attachment?.fileName.capitalized
                    type.text = fileMessage.attachment?.fileExtension.uppercased()
                    if let fileSize = fileMessage.attachment?.fileSize {
                        print(Units(bytes: Int64(fileSize)).getReadableUnit())
                        size.text = Units(bytes: Int64(fileSize)).getReadableUnit()
                    }
                   }
    
                  if fileMessage.readAt > 0 {
                       receipt.image = #imageLiteral(resourceName: "read")
                       timeStamp.text = String().setMessageTime(time: Int(fileMessage?.readAt ?? 0))
                       }else if fileMessage.deliveredAt > 0 {
                       receipt.image = #imageLiteral(resourceName: "delivered")
                       timeStamp.text = String().setMessageTime(time: Int(fileMessage?.deliveredAt ?? 0))
                       }else if fileMessage.sentAt > 0 {
                       receipt.image = #imageLiteral(resourceName: "sent")
                       timeStamp.text = String().setMessageTime(time: Int(fileMessage?.sentAt ?? 0))
                       }else if fileMessage.sentAt == 0 {
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
