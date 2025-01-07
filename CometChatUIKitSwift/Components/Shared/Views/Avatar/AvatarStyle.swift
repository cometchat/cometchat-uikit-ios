//
//  AvatarStyle.swift
//  
//
//  Created by Abdullah Ansari on 27/09/22.
//

import UIKit

public struct AvatarStyle {

    public var backgroundColor: UIColor = CometChatTheme.extendedPrimaryColor500
    public var borderColor: UIColor = .clear
    public var borderWidth: CGFloat = 0
    public var cornerRadius: CometChatCornerStyle? = nil
    public var textFont = CometChatTypography.Heading2.bold
    public var textColor: UIColor = CometChatTheme.white
    
    public init() {  }
    
}
