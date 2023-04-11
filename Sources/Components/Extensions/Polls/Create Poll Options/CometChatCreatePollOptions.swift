//
//  CometChatCreatePollOptions.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 16/09/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit

class CometChatCreatePollOptions: UITableViewCell {

    @IBOutlet weak var options: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = CometChatTheme.palatte.background
        options.font = CometChatTheme.typography.text1
        options.textColor = CometChatTheme.palatte.accent
        options.attributedPlaceholder =  NSAttributedString(
            string: "Answer",
            attributes: [NSAttributedString.Key.foregroundColor: CometChatTheme.palatte.accent500])
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
