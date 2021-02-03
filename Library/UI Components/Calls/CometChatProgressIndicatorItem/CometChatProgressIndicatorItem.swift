//  CometChatProgressIndicatorItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */
class CometChatProgressIndicatorItem: UITableViewCell {

    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var LoadingLabel: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
     // MARK: - Initialization of required Methods
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        activityIndicator.startAnimating()
    }

    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
