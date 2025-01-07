//  CometChatBadge.swift
 
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatBadge: This component will be the class of UILabel which is customizable to display the unread message count for conversations.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import CometChatSDK

/*  ----------------------------------------------------------------------------------------- */

@objc @IBDesignable public final class CometChatBadge: UILabel {
    
    public static var style = BadgeStyle() // global styling
    public lazy var style = CometChatBadge.style // component level styling
    
    private let padding = UIEdgeInsets(top: CometChatSpacing.Padding.p,
                                       left: CometChatSpacing.Padding.p1,
                                       bottom: CometChatSpacing.Padding.p,
                                       right: CometChatSpacing.Padding.p1)
    
    var getCount: Int {
        return Int(self.text ?? "0") ?? 0
    }
    
    // MARK: - Initialization
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    public override func drawText(in rect: CGRect) {
        // Adjust the text drawing rect by the padding
        let paddedRect = rect.inset(by: padding)
        super.drawText(in: paddedRect)
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        updateAppearance()
    }

    private func updateAppearance() {
        self.textColor = style.textColor
        self.font = style.textFont
        self.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: 10))
        self.layer.borderColor = style.borderColor
        self.layer.borderWidth = style.borderWidth
        self.backgroundColor = style.backgroundColor
        self.clipsToBounds = true
        self.textAlignment = .center
        self.setContentHuggingPriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.setContentCompressionResistancePriority(.required, for: .vertical)
        self.numberOfLines = 1
        self.lineBreakMode = .byTruncatingTail
        self.adjustsFontSizeToFitWidth = true
        self.minimumScaleFactor = 0.5
        self.textAlignment = .center
    }

    @discardableResult
    public func set(count: Int) -> Self {
        switch count {
        case 1..<999:
            self.isHidden = false
            self.text = "\(count)"
        case 999...:
            self.isHidden = false
            self.text = "999+"
        default:
            self.isHidden = true
        }
        // Update size after setting the count
        invalidateIntrinsicContentSize()
        return self
    }
    
    @discardableResult
    public func incrementCount() -> Self {
        let currentCount = self.getCount
        self.set(count: currentCount + 1)
        return self
    }
    
    @discardableResult
    public func removeCount() -> Self {
        self.set(count: 0)
        return self
    }
    
    // MARK: - Dynamic size calculation
    public override var intrinsicContentSize: CGSize {
        let textSize = self.intrinsicTextSize()
        let widthWithPadding = textSize.width + padding.left + padding.right
        let heightWithPadding = textSize.height + padding.top + padding.bottom
        let minWidth: CGFloat = 20 // minimum width required
        let height: CGFloat = 20 // fixed height

        let calculatedWidth = max(minWidth, widthWithPadding)
        return CGSize(width: calculatedWidth, height: max(height, heightWithPadding))
    }
    
    private func intrinsicTextSize() -> CGSize {
        guard let text = self.text else { return .zero }
        return (text as NSString).size(withAttributes: [.font: style.textFont])
    }
}
