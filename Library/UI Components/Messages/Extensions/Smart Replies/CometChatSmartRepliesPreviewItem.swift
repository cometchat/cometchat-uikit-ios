
//  CometChatSmartRepliesPreviewItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

// MARK: - Importing Protocols.

protocol CometChatSmartRepliesPreviewItemDelegate: class {
    func didSendButtonPressed(title: String, sender: UIButton)
}

/*  ----------------------------------------------------------------------------------------- */

class CometChatSmartRepliesPreviewItem: UICollectionViewCell {
    
    // MARK: - Declaration of IBOutlets
    @IBOutlet weak var smartReplyButton: UIButton!
    @IBOutlet weak var smartRepliesButtonView: UIView!

    // MARK: - Declaration of Variables
    weak var smartrepliespreviewitemdelegate: CometChatSmartRepliesPreviewItemDelegate?
    
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        smartRepliesButtonView.layer.masksToBounds = false
        smartRepliesButtonView.layer.shadowColor = UIColor.gray.cgColor
        smartRepliesButtonView.layer.shadowOpacity = 0.3
        smartRepliesButtonView.layer.shadowOffset = CGSize.zero
        smartRepliesButtonView.layer.shadowRadius = 3
        smartRepliesButtonView.layer.shouldRasterize = true
        smartRepliesButtonView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    
    /// This method will trigger when user pressed button on smart reply cell.
    /// - Parameter sender: specifies a sender of the button.
    @IBAction func sendButtonPressed(_ sender: UIButton) {
        smartrepliespreviewitemdelegate?.didSendButtonPressed(title: smartReplyButton.titleLabel?.text ?? "", sender: sender)
     }
}

/*  ----------------------------------------------------------------------------------------- */
