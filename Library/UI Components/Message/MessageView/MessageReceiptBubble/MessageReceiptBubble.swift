//
//  MessageReceiptCell.swift
//  CometChatPro-swift-sampleApp
//
//  Created by MacMini-03 on 12/09/19.
//  Copyright © 2019 Admin1. All rights reserved.
//

import UIKit
import CometChatPro

class MessageReceiptBubble: UITableViewCell {

    @IBOutlet weak var avtar: Avatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var readAt: UILabel!
    @IBOutlet weak var deliveredAt: UILabel!
    
    var receipt: MessageReceipt? {
        didSet{
        
            name.text = receipt?.sender?.name ?? ""
            if let avatarURL = receipt?.sender?.avatar  {
                self.avtar.set(image: avatarURL, with: receipt?.sender?.name ?? "")
            }
            if let receiptReadAt = receipt?.readAt {
                if receiptReadAt != 0.0 {
                    readAt.text = String().setMessageTime(time: Int(receiptReadAt))
                }else{
                    readAt.text = "--"
                }
            }else{
                readAt.text = "--"
            }
            
            if let receiptDeliveredAt = receipt?.deliveredAt {
                if receiptDeliveredAt != 0.0 {
                    deliveredAt.text = String().setMessageTime(time: Int(receiptDeliveredAt))
                }else{
                    deliveredAt.text = "--"
                }
            }else{
                deliveredAt.text = "--"
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
