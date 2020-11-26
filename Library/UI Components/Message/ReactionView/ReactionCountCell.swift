//
//  ReactionCountCell.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 24/11/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit

class ReactionCountCell: UICollectionViewCell {

    @IBOutlet weak var reactionCountView: UIView!
    @IBOutlet weak var reactionLabel: UILabel!
    
    override var isHighlighted: Bool {
        didSet {
            if isHighlighted {
                self.contentView.alpha = 0.5
            }
            else {
                self.contentView.alpha = 1.0
            }
        }
    }
    
    var reaction: MessageReaction? {
        didSet {
            reactionCountView.layer.borderWidth = 0.5
            reactionCountView.layer.borderColor = UIKitSettings.primaryColor.cgColor
            if let title = reaction?.title, let count = reaction?.reactors?.count {
                reactionLabel.text = "\(title) \(count)"
            }
        }
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
       
    }
    


}
