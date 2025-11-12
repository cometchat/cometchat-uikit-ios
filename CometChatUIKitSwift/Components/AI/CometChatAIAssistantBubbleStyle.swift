//
//  CometChatAIAssistantBubbleStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 13/10/25.
//

import Foundation
import UIKit

public struct AIAssistantBubbleStyle: BaseMessageBubbleStyle {
    public var backgroundDrawable: UIImage?
    
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
    
        
    public var textFont: UIFont? = CometChatTypography.Body.regular
    public var textColor: UIColor? = CometChatTheme.textColorPrimary
    
    public var borderColor: UIColor? = CometChatTheme.neutralColor200
    public var borderWidth: CGFloat? = 0
    
    public var backgroundColor: UIColor? = CometChatTheme.backgroundColor01
    
    public init() { }
}
