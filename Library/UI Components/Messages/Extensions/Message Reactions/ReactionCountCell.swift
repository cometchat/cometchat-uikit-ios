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
        self.reactionCountView.layer.cornerRadius = 12
        if #available(iOS 13.0, *) {
            addReactionsIcon.backgroundColor = .systemBackground
        } else {
            addReactionsIcon.backgroundColor = .white
        }
        addReactionsIcon.image = addReactionsIcon.image?.withRenderingMode(.alwaysTemplate)
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
            reactionCountView.layer.borderColor = UIKitSettings.primaryColor.cgColor
            if let title = reaction?.title, let count = reaction?.reactors?.count {
                reactionLabel.text = "\(title) \(count)"
            }
        }
    }
    
    @discardableResult
    public func set(addReactionIconTint: UIColor) -> Self {
        self.addReactionsIcon.tintColor = addReactionIconTint
        return self
    }
    
    @discardableResult
    public func set(addReactionIconbackground: UIColor) -> Self {
        self.addReactionsIcon.backgroundColor = addReactionIconbackground
        return self
    }
    
    @discardableResult
    public func set(textColor: UIColor) -> Self {
        self.reactionLabel.textColor = textColor
        return self
    }
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        self.reactionLabel.font = textFont
        return self
    }
    
    @discardableResult
    public func set(background: UIColor) -> Self {
        self.contentView.backgroundColor = background
        return self
    }
    
    @discardableResult
    public func set(borderColor: UIColor) -> Self {
        self.contentView.layer.borderColor = borderColor.cgColor
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.contentView.layer.borderWidth = borderWidth
        return self
    }

}
