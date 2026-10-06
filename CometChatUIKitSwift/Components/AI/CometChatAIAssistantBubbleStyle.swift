//
//  CometChatAIAssistantBubbleStyle.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 13/10/25.
//

import Foundation
import UIKit

public struct AIAssistantBubbleStyle: BaseMessageBubbleStyle {
    /// Not applied: assistant bubbles have no reply-preview view. Kept for source compatibility.
    public var messagePreviewStyle: MessagePreviewStyle?
    /// Not applied: assistant bubbles do not draw a background image. Kept for source compatibility.
    public var backgroundDrawable: UIImage?
    
    public var cornerRadius: CometChatCornerStyle?
    
    public var avatarStyle: AvatarStyle?
    
    /// Not applied: the assistant bubble has no date view of its own. Kept for source compatibility.
    public var dateStyle: DateStyle?
    
    /// Not applied: assistant messages have no receipt. Kept for source compatibility.
    public var receiptStyle: ReceiptStyle?
    
    /// Not applied: assistant bubbles have no header view. Kept for source compatibility.
    public var headerTextColor: UIColor?
    
    /// Not applied: assistant bubbles have no header view. Kept for source compatibility.
    public var headerTextFont: UIFont?
    
    /// Not applied: assistant bubbles have no thread indicator. Kept for source compatibility.
    public var threadedIndicatorTextFont: UIFont?
    
    /// Not applied: assistant bubbles have no thread indicator. Kept for source compatibility.
    public var threadedIndicatorTextColor: UIColor?
    
    /// Not applied: assistant bubbles have no thread indicator. Kept for source compatibility.
    public var threadedIndicatorImageTint: UIColor?
    
    /// Not applied: assistant bubbles have no reactions row of their own. Kept for source compatibility.
    public var reactionsStyle: ReactionsStyle?
    
        
    public var textFont: UIFont? = CometChatTypography.Body.regular
    public var textColor: UIColor? = CometChatTheme.textColorPrimary
    
    public var borderColor: UIColor? = CometChatTheme.neutralColor200
    public var borderWidth: CGFloat? = 0
    
    /// Default changed to `.clear`: assistant bubbles paint no background of their own.
    public var backgroundColor: UIColor? = .clear
    
    public init() { }
}
