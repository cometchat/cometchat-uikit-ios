//
//  CollaborativeWhiteBoardStyle.swift
 
//
//  Created by Abdullah Ansari on 19/05/22.
//

import Foundation
import UIKit

public struct CollaborativeBubbleStyle: BaseMessageBubbleStyle {
    
    public var headerTextColor: UIColor?
    public var headerTextFont: UIFont?
    public var backgroundColor: UIColor?
    public var backgroundDrawable: UIImage?
    public var borderWidth: CGFloat?
    public var borderColor: UIColor?
    public var cornerRadius: CometChatCornerStyle?
    public var avatarStyle: AvatarStyle?
    public var dateStyle: DateStyle?
    public var receiptStyle: ReceiptStyle?
    
    /// The text font for the thread count in the collaborative bubble.
    public var threadedIndicatorTextFont: UIFont?
    
    /// The text color for the thread count in the collaborative bubble.
    public var threadedIndicatorTextColor: UIColor?
    
    /// The icon tint for the thread count in the collaborative bubble.
    public var threadedIndicatorImageTint: UIColor?
    
    public var titleFont = CometChatTypography.Body.medium
    public var titleColor = CometChatTheme.white
    public var subTitleFont = CometChatTypography.Caption2.regular
    public var subTitleColor = CometChatTheme.white
    public var iconTint = CometChatTheme.white
    public var buttonTextFont = CometChatTypography.Body.medium
    public var buttonTextColor = CometChatTheme.white
    public var dividerTint = CometChatTheme.neutralColor100
    
    public var reactionsStyle: ReactionsStyle?
    
    private var styleType: BubbleStyleType = .incoming
    
    public init() {  }
    
    internal init(styleType: BubbleStyleType) { // for default values according to the bubble type
        self.styleType = styleType
        
        switch styleType {
        case .incoming:
            titleColor = CometChatTheme.neutralColor900
            subTitleColor = CometChatTheme.neutralColor600
            buttonTextColor = CometChatTheme.primaryColor
            iconTint = CometChatTheme.primaryColor
        case .outgoing:
            titleColor = CometChatTheme.white
            subTitleColor = CometChatTheme.white
            buttonTextColor = CometChatTheme.white
            iconTint = CometChatTheme.white
        }
    }
    
}
