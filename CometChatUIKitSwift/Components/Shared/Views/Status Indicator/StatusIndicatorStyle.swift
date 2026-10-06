//
//  StatusIndicatorStyle.swift
//  
//
//  Created by Abdullah Ansari on 05/09/22.
//

import UIKit

public struct StatusIndicatorStyle {
    
    public var borderWidth : CGFloat = 0.0
    public var borderColor : UIColor = CometChatTheme.backgroundColor01
    public var cornerRadius : CometChatCornerStyle? = nil
    public var backgroundColor : UIColor = CometChatTheme.successColor
    /// An image filling the indicator above `backgroundColor`, clipped to its shape.
    public var backgroundImage : UIImage? = nil
    
    public init() {}
    
}
