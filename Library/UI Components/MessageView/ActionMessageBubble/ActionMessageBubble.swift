//  ActionMessageBubble.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class ActionMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet weak var message: UILabel!
    
    var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.clear
        }
    }
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
        contentView.isUserInteractionEnabled = false
        selectionColor = .white
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    
        // Configure the view for the selected state
    }
    
}

/*  ----------------------------------------------------------------------------------------- */
