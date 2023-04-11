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
        self.reactionCountView.backgroundColor = CometChatTheme.palatte.secondary
        addReactionsIcon.backgroundColor = CometChatTheme.palatte.background
        addReactionsIcon.image = addReactionsIcon.image?.withRenderingMode(.alwaysTemplate)
        set(style: MessageReactionStyle())
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
            reactionCountView.layer.borderColor = CometChatTheme.palatte.primary.cgColor
            if let title = reaction?.title, let count = reaction?.reactors?.count {
                reactionLabel.text = "\(title) \(count)"
            }
        }
    }
    
    func set(style: MessageReactionStyle) {
        set(addReactionIconTint: style.addReactionIconTint)
        set(addReactionIconbackground: style.addReactionIconbackground)
        set(textFont: style.textFont)
        set(textColor: style.textColor)
        set(borderColor: style.borderColor)
        set(borderWidth: style.borderWidth)
        set(background: style.background)
        set(corner: style.cornerRadius)
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
        self.contentView.backgroundColor = .clear
        return self
    }
    
    @discardableResult
    public func set(corner: CometChatCornerStyle) -> Self {
        self.contentView.roundViewCorners(corner: corner)
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
