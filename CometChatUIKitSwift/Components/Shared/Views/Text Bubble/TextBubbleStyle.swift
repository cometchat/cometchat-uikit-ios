//
//  TextBubbleStyle.swift
 
//
//  Created by Abdullah Ansari on 20/05/22.
//

import Foundation
import UIKit

public struct TextBubbleStyle: BaseMessageBubbleStyle {
    
    public var avatarStyle: AvatarStyle?
    public var dateStyle: DateStyle?
    public var receiptStyle: ReceiptStyle?
    public var backgroundColor: UIColor?
    public var backgroundDrawable: UIImage?
    public var cornerRadius: CometChatCornerStyle?
    public var borderWidth: CGFloat?
    public var borderColor: UIColor?
    public var headerTextColor: UIColor?
    public var headerTextFont: UIFont?
    public var threadedIndicatorTextFont: UIFont?
    public var threadedIndicatorTextColor: UIColor?
    public var threadedIndicatorImageTint: UIColor?
    
    public var textFont: UIFont = CometChatTypography.Body.regular
    public var textColor: UIColor = CometChatTheme.white
    public var textHighlightColor: UIColor = #colorLiteral(red: 0.01568627451, green: 0.1965779049, blue: 1, alpha: 1)
    
    public var reactionsStyle: ReactionsStyle?
    
    init() {
        
    }
    
    //for default values according to the bubble type
    internal init(styleType: BubbleStyleType) {
        switch styleType {
        case .incoming:
            textColor = CometChatTheme.neutralColor900
            textHighlightColor = CometChatTheme.infoColor
        case .outgoing:
            textColor = CometChatTheme.white
            textHighlightColor = CometChatTheme.white
        }
    }
    
}
