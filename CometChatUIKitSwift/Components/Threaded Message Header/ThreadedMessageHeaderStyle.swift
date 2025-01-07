//
//  ThreadedMessageHeaderStyle.swift
//  CometChatUIKitSwift
//
//  Created by Suryansh on 16/10/24.
//

import UIKit
import Foundation

public struct ThreadedMessageHeaderStyle {
    
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor03
    public var borderColor: UIColor = UIColor.clear
    public var borderWith: CGFloat = 0
    public var cornerRadius: CometChatCornerStyle?
    
    public var bubbleContainerBackgroundColor: UIColor = UIColor.clear
    public var bubbleContainerBorderColor: UIColor = UIColor.clear
    public var bubbleContainerBorderWidth: CGFloat = 0
    public var bubbleContainerCornerRadius: CometChatCornerStyle?
    
    public var dividerTintColor: UIColor = CometChatTheme.extendedPrimaryColor100
    public var countTextColor: UIColor = CometChatTheme.textColorSecondary
    public var countTextFont: UIFont = CometChatTypography.Body.regular
    
}
