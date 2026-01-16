//
//  CollaborativeWhiteBoardStyle.swift
 
//
//  Created by Abdullah Ansari on 19/05/22.
//

import Foundation
import UIKit

public struct CollaborativeBubbleStyle: BaseMessageBubbleStyle {
    
    public var messagePreviewStyle: MessagePreviewStyle?
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
    
    private var _iconTint: UIColor?
    public var iconTint: UIColor {
        get { return _iconTint ?? CometChatTheme.primaryColor }
        set { _iconTint = newValue }
    }
    
    public var buttonTextFont = CometChatTypography.Body.medium
    
    private var _buttonTextColor: UIColor?
    public var buttonTextColor: UIColor {
        get { return _buttonTextColor ?? CometChatTheme.primaryColor }
        set { _buttonTextColor = newValue }
    }
    
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
            // Don't set backing variables for incoming - let them use computed properties
            // which will fetch CometChatTheme.primaryColor dynamically
            _buttonTextColor = nil
            _iconTint = nil
        case .outgoing:
            titleColor = CometChatTheme.white
            subTitleColor = CometChatTheme.white
            _buttonTextColor = CometChatTheme.white
            _iconTint = CometChatTheme.white
        }
    }
    
}
