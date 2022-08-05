//
//  CometChatDialogStyle.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 30/05/22.
//

import Foundation
import UIKit

class CometChatDialogStyle {
    
    let titleFont: UIFont?
    let titleColor: UIColor?
    let messageTextFont: UIFont?
    let messageTextColor: UIColor?
    let confirmTextFont: UIFont?
    let confirmTextColor: UIColor?
    let cancelTextFont: UIFont?
    let cancelTextColor: UIColor?
    // let background: UIColor?
    
    init(titleColor: UIColor? = .black, titleFont: UIFont? = CometChatTheme.typography?.Name2,
         messageTextColor: UIColor? = .gray, messageTextFont: UIFont? = CometChatTheme.typography?.Subtitle2,
         confirmTextColor: UIColor? = CometChatTheme.palatte?.primary, confirmTextFont: UIFont? = CometChatTheme.typography?.Name2,
         cancelTextColor: UIColor? = CometChatTheme.palatte?.primary, cancelTextFont: UIFont? = CometChatTheme.typography?.Name2) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.messageTextColor = messageTextColor
        self.messageTextFont = messageTextFont
        self.confirmTextColor = confirmTextColor
        self.confirmTextFont = confirmTextFont
        self.cancelTextColor = cancelTextColor
        self.cancelTextFont = cancelTextFont
    }
}
