//
//  File.swift
//  
//
//  Created by Ajay Verma on 13/01/23.
//

import UIKit

public struct ReceiptStyle {
    
    public var waitImage : UIImage = UIImage(named: "messages-wait", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var sentImage : UIImage = UIImage(named: "messages-sent", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var deliveredImage : UIImage = UIImage(named: "messages-delivered", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var readImage : UIImage = UIImage(named: "messages-read", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    public var errorImage : UIImage = UIImage(named: "messages-error", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysOriginal) ?? UIImage()
    
    public var waitImageTintColor : UIColor = CometChatTheme.iconColorSecondary
    public var sentImageTintColor : UIColor = CometChatTheme.iconColorSecondary
    public var deliveredImageTintColor : UIColor = CometChatTheme.iconColorSecondary
    public var readImageTintColor : UIColor = CometChatTheme.messageReadColor
    public var errorImageTintColor : UIColor = CometChatTheme.iconColorSecondary
    
    public init() {}

}
