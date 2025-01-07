//
//  StickerBubbleStyle.swift
//  
//
//  Created by Abdullah Ansari on 31/08/22.
//

import UIKit

public struct StickerBubbleStyle: BaseMessageBubbleStyle {
    
    public var backgroundColor: UIColor?
    public var backgroundDrawable: UIImage?
    public var borderWidth: CGFloat?
    public var borderColor: UIColor?
    public var cornerRadius: CometChatCornerStyle?
    public var avatarStyle: AvatarStyle?
    public var dateStyle: DateStyle?
    public var receiptStyle: ReceiptStyle?
    public var headerTextColor: UIColor?
    public var headerTextFont: UIFont?
    public var threadedIndicatorTextFont: UIFont?
    public var threadedIndicatorTextColor: UIColor?
    public var threadedIndicatorImageTint: UIColor?
    public var reactionsStyle: ReactionsStyle?
    
    private var styleType: BubbleStyleType = .incoming
 
    
    public init() { }
    internal init(styleType: BubbleStyleType) { // for default values according to the bubble type
        backgroundColor = .clear
        
        var dateStyle = DateStyle()
        dateStyle.textColor = CometChatTheme.white
        dateStyle.textFont = CometChatTypography.Caption2.regular
        dateStyle.borderWidth = 0
        dateStyle.backgroundColor = CometChatTheme.black.withAlphaComponent(0.6)
        dateStyle.cornerRadius = .init(cornerRadius: CometChatSpacing.Radius.r2)
        dateStyle.textColor = CometChatTheme.white
        self.dateStyle = dateStyle
        
        self.styleType = styleType
    }

    
}
