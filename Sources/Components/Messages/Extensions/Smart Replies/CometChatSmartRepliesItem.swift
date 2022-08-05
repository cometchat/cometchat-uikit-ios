
//  CometChatSmartRepliesPreviewItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

// MARK: - Importing Protocols.

protocol CometChatSmartRepliesItemDelegate: class {
    func didSendButtonPressed(title: String, sender: UIButton)
}

/*  ----------------------------------------------------------------------------------------- */

class CometChatSmartRepliesItem: UICollectionViewCell {
    
    // MARK: - Declaration of IBOutlets
    @IBOutlet weak var smartReplyButton: UIButton!
    @IBOutlet weak var smartRepliesButtonView: UIView!

    // MARK: - Declaration of Variables
    weak var smartRepliesItemDelegate: CometChatSmartRepliesItemDelegate?
    
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        smartRepliesButtonView.layer.masksToBounds = false
        smartRepliesButtonView.layer.shadowColor = CometChatTheme.palatte?.accent200?.cgColor
        smartRepliesButtonView.layer.shadowOpacity = 0.3
        smartRepliesButtonView.layer.shadowOffset = CGSize.zero
        smartRepliesButtonView.layer.shadowRadius = 6
        
        smartRepliesButtonView.layer.shadowColor = CometChatTheme.palatte?.accent300?.cgColor
        smartRepliesButtonView.layer.shadowOpacity = 0.8
        smartRepliesButtonView.layer.shadowOffset = CGSize.zero
        smartRepliesButtonView.layer.shadowRadius = 2
        smartRepliesButtonView.layer.shouldRasterize = true
        smartRepliesButtonView.layer.rasterizationScale = UIScreen.main.scale
        
        smartReplyButton.titleLabel?.font = CometChatTheme.typography?.Body
        //smartReplyButton.titleLabel?.textColor = CometChatTheme.palatte?.accent
        smartReplyButton.setTitleColor(CometChatTheme.palatte?.accent400, for: .normal)
        smartReplyButton.backgroundColor = CometChatTheme.palatte?.background ?? .systemBackground
        smartRepliesButtonView.backgroundColor = CometChatTheme.palatte?.background ?? .systemBackground
    }
    
    
    /// This method will trigger when user pressed button on smart reply cell.
    /// - Parameter sender: specifies a sender of the button.
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        smartRepliesItemDelegate?.didSendButtonPressed(title: smartReplyButton.titleLabel?.text ?? "", sender: sender)
     }
}

/*  ----------------------------------------------------------------------------------------- */
