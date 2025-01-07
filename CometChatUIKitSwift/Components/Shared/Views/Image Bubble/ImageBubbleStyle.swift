//
//  ImageBubbleStyle.swift
//
//
//  Created by Abdullah Ansari on 31/08/22.
//

import UIKit

public struct ImageBubbleStyle: BaseMessageBubbleStyle {
    
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
    
    public var imageBorderWidth: CGFloat = CometChatSpacing.Padding.p1
    public var imageBorderCornerRadius: CometChatCornerStyle = .init(cornerRadius: CometChatSpacing.Radius.r2)
    public var imageBorderColor: UIColor = .clear
    
    private var styleType: BubbleStyleType = .incoming
    
    public var reactionsStyle: ReactionsStyle?
 
    
    public init() { }
    internal init(styleType: BubbleStyleType) { // for default values according to the bubble type
        self.styleType = styleType
    }
}
