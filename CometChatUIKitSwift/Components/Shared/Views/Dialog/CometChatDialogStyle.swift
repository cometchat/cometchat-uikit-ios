//
//  CometChatDialogStyle.swift
 
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
    
    init(titleColor: UIColor? = .black, titleFont: UIFont? = CometChatTheme_v4.typography.text1,
         messageTextColor: UIColor? = .gray, messageTextFont: UIFont? = CometChatTheme_v4.typography.subtitle2,
         confirmTextColor: UIColor? = CometChatTheme_v4.palatte.primary, confirmTextFont: UIFont? = CometChatTheme_v4.typography.text1,
         cancelTextColor: UIColor? = CometChatTheme_v4.palatte.primary, cancelTextFont: UIFont? = CometChatTheme_v4.typography.text1) {
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
