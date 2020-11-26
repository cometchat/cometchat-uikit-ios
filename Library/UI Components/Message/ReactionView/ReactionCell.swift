
//  SmartReplyCell.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

// MARK: - Importing Protocols.

protocol ReactionCellDelegate: class {
    func didAddNewReactionPressed(reaction: String)
}

/*  ----------------------------------------------------------------------------------------- */

class ReactionCell: UICollectionViewCell {
    
    // MARK: - Declaration of IBOutlets
    @IBOutlet weak var reactionBtn: UIButton!
    @IBOutlet weak var buttonView: UIView!
    // MARK: - Declaration of Variables
    weak var delegate: ReactionCellDelegate?
    
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        buttonView.layer.masksToBounds = false
        buttonView.layer.shadowColor = UIColor.gray.cgColor
        buttonView.layer.shadowOpacity = 0.3
        buttonView.layer.shadowOffset = CGSize.zero
        buttonView.layer.shadowRadius = 3
        buttonView.layer.shouldRasterize = true
        buttonView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    
    /// This method will trigger when user pressed button on smart reply cell.
    /// - Parameter sender: specifies a sender of the button.
    @IBAction func didReactionButtonPressed(_ sender: UIButton) {
        delegate?.didAddNewReactionPressed(reaction: reactionBtn.titleLabel?.text ?? "")
     }
}

/*  ----------------------------------------------------------------------------------------- */
