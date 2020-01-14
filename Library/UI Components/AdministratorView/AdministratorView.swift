//
//  AdministratorView.swift
//  ios-chat-uikit-app
//
//  Created by Pushpsen Airekar on 30/12/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit

class AdministratorView: UITableViewCell {

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var adminCount: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
