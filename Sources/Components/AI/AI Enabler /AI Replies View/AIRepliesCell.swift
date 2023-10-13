//
//  AIRepliesCell.swift
//  
//
//  Created by SuryanshBisen on 17/09/23.
//

import UIKit

class AIRepliesCell: UITableViewCell {

    @IBOutlet weak var uiButton: UIButton!
    @IBOutlet weak var contanierView: UIView!
    
    var smartRepliesStyle: AISmartRepliesStyle?
    var conversationStartersStyle: AIConversationStartersStyle?
    var onButtonClicked: ((String) -> Void)?
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        uiButton.tintColor = CometChatTheme.palatte.accent
        uiButton.borderColor(color: CometChatTheme.palatte.accent700)
        self.backgroundColor = .clear
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func applyShadow() {
        contanierView.layer.masksToBounds = false
        contanierView.layer.shadowColor = CometChatTheme.palatte.accent300.cgColor
        contanierView.layer.shadowOpacity = 0.8
        contanierView.layer.shadowOffset = CGSize.zero
        contanierView.layer.shadowRadius = 2
        contanierView.layer.shouldRasterize = true
        contanierView.layer.rasterizationScale = UIScreen.main.scale
    }
    
    @IBAction func onReplieButtonTapped(_ sender: Any) {
        onButtonClicked?(uiButton.titleLabel?.text ?? "0[po0")
    }
    
    @discardableResult
    public func set(style: AIParentRepliesStyle?) -> Self {
        
        if let textFont = style?.repliesTextFont {
            uiButton.titleLabel?.font = textFont
        }
        
        if let repliesTextColor = style?.repliesTextColor {
            uiButton.tintColor = repliesTextColor
        }
        
        if let repliesTextBackground = style?.repliesTextBackground {
            contanierView.backgroundColor = repliesTextBackground
        }
        
        if let repliesTextBorder = style?.repliesTextBorder {
            uiButton.layer.borderWidth = repliesTextBorder
        }
        
        if let repliesTextBorderRadius = style?.repliesTextBorderRadius {
            uiButton.layer.cornerRadius = repliesTextBorderRadius
        }
        
        return self
    }

    
    @discardableResult
    public func applyDefaultShadow(bool: Bool?) -> Self {
        applyShadow()
        return self
    }
    
    @discardableResult
    public func set(onButtonClick: ((String) -> Void)?) -> Self {
        self.onButtonClicked = onButtonClick
        return self
    }
    
    @discardableResult
    public func set(title: String?) -> Self {
        uiButton.setTitle(title, for: .normal)
        return self
    }
    
    @discardableResult
    public func set(background: UIColor) -> Self {
        contanierView.backgroundColor = background
        return self
    }
    
    @discardableResult
    public func set(shadowColor: UIColor) -> Self {
        contanierView.layer.shadowColor = shadowColor.cgColor
        return self
    }
    
    @discardableResult
    public func set(buttonBackground: UIColor) -> Self {
        uiButton.backgroundColor = buttonBackground
        return self
    }
    
    @discardableResult
    public func set(corner: CometChatCornerStyle) -> Self {
        uiButton.roundViewCorners(corner: corner)
        return self
    }
    
    @discardableResult
    public func set(textFont: UIFont) -> Self {
        uiButton.titleLabel?.font = textFont
        return self
    }
    
    @discardableResult
    public func set(titleColor: UIColor) -> Self {
        uiButton.setTitleColor(titleColor, for: .normal)
        return self
    }
    
    @discardableResult func set(textBackground: UIColor) -> Self {
        uiButton.backgroundColor = textBackground
        return self
    }
    
    @discardableResult
    public func set(buttonBorder: CGFloat) -> Self {
        uiButton.layer.borderWidth = buttonBorder
        return self
    }
    
    @discardableResult
    public func set(buttonBorderColor: CGColor) -> Self {
        uiButton.layer.borderColor = buttonBorderColor
        return self
    }
    
}
