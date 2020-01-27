//  ChattingBubble.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import Foundation
import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

@IBDesignable class ChattingBubble: UILabel {

    // MARK: - Declaration of IBInspectable
    
    @IBInspectable var topInset: CGFloat = 10.0
    @IBInspectable var bottomInset: CGFloat = 10.0
    @IBInspectable var leftInset: CGFloat = 10.0
    @IBInspectable var rightInset: CGFloat = 10.0
    @IBInspectable var radius: CGFloat = 10
    @IBInspectable var borderWidth: CGFloat = 0
    @IBInspectable var borderColor: UIColor? {
        didSet {
            layer.borderColor = borderColor?.cgColor
        }
    }

    // MARK: - Initialization of required Methods
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(top: topInset, left: leftInset, bottom: bottomInset, right: rightInset)
        super.drawText(in: rect.inset(by: insets))
        self.layer.cornerRadius = 18
        self.layer.masksToBounds = true
        self.layer.borderWidth = borderWidth
        self.numberOfLines = 0
        self.baselineAdjustment = .alignBaselines
        self.adjustsFontSizeToFitWidth = true
        self.lineBreakMode = NSLineBreakMode.byWordWrapping
        self.addConstraint(self.widthAnchor.constraint(lessThanOrEqualToConstant:250))
    }

    
    override var intrinsicContentSize : CGSize {
        var intrinsicSuperViewContentSize = super.intrinsicContentSize
        intrinsicSuperViewContentSize.height += topInset + bottomInset
        intrinsicSuperViewContentSize.width += leftInset + rightInset
        return intrinsicSuperViewContentSize
    }
}


/*  ----------------------------------------------------------------------------------------- */




