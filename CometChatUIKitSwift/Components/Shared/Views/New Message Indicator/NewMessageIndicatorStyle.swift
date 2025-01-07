
//  NewMessageIndicatorStyle.swift
//  Created by admin on 15/09/22.
//

import Foundation
import UIKit

public struct NewMessageIndicatorStyle {
    
    public var textFont: UIFont = CometChatTypography.Body.medium
    public var textColor: UIColor = CometChatTheme.white
    public var textBackgroundColor: UIColor = CometChatTheme.primaryColor
    public var imageTint: UIColor = CometChatTheme.iconColorSecondary
    public var backgroundColor: UIColor = CometChatTheme.backgroundColor03
    public var cornerRadius: CometChatCornerStyle?
    public var borderWidth: CGFloat = 1
    public var borderColor: UIColor = CometChatTheme.borderColorDefault
    public var iconImage = UIImage(systemName: "chevron.down")
    
    public init() { }
}
