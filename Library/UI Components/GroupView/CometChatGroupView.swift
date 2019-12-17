//
//  GroupView.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class CometChatGroupView: UITableViewCell {

    @IBOutlet weak var groupAvtar: Avtar!
    @IBOutlet weak var groupName: UILabel!
    @IBOutlet weak var groupDetails: UILabel!
    @IBOutlet weak var typing: UILabel!
    
    var group: Group! {
        didSet {
            groupName.text = group.name
            switch group.groupType {
            case .public:
                 groupDetails.text = "Public"
            case .private:
                groupDetails.text = "Private"
            case .password:
                groupDetails.text = "Password Protected"
            @unknown default:
                break
            }
            groupAvtar.set(image: group.icon ?? "")
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
      
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
