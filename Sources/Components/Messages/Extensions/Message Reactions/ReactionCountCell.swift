//
//  ReactionCountCell.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 24/11/20.
//  Copyright © 2022 MacMini-03. All rights reserved.
//

import UIKit

class ReactionCountCell: UICollectionViewCell {

    @IBOutlet weak var reactionCountView: UIView!
    @IBOutlet weak var reactionLabel: UILabel!
    @IBOutlet weak var addReactionsIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.reactionCountView.layer.cornerRadius = 9
        reactionCountView.backgroundColor = CometChatTheme.palatte?.background ?? .white
        reactionLabel.font = CometChatTheme.typography?.Caption2 ?? .systemFont(ofSize: 12)
        reactionLabel.textColor = CometChatTheme.palatte?.accent700
    }
    
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
    
    var reaction: CometChatMessageReaction? {
        didSet {
            reactionCountView.layer.borderWidth = 0.5
            reactionCountView.layer.borderColor = CometChatTheme.palatte?.primary?.cgColor ?? UIColor.clear.cgColor
            if let title = reaction?.title, let count = reaction?.reactors?.count {
                reactionLabel.text = "\(title) \(count)"
            }
        }
    }

}
