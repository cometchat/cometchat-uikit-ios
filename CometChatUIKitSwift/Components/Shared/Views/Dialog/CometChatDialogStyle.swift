//
//  CometChatDialogStyle.swift
 
//
//  Created by Abdullah Ansari on 30/05/22.
//

import Foundation
import UIKit

class CometChatDialogStyle {
    
    /// Not applied: nothing reads this type; `CometChatDialog` takes its colours and fonts through its own `set(...)` methods.
    let titleFont: UIFont?
    /// Not applied: nothing reads this type; `CometChatDialog` takes its colours and fonts through its own `set(...)` methods.
    let titleColor: UIColor?
    /// Not applied: nothing reads this type; `CometChatDialog` takes its colours and fonts through its own `set(...)` methods.
    let messageTextFont: UIFont?
    /// Not applied: nothing reads this type; `CometChatDialog` takes its colours and fonts through its own `set(...)` methods.
    let messageTextColor: UIColor?
    /// Not applied: nothing reads this type; `CometChatDialog` takes its colours and fonts through its own `set(...)` methods.
    let confirmTextFont: UIFont?
    /// Not applied: nothing reads this type; `CometChatDialog` takes its colours and fonts through its own `set(...)` methods.
    let confirmTextColor: UIColor?
    /// Not applied: nothing reads this type; `CometChatDialog` takes its colours and fonts through its own `set(...)` methods.
    let cancelTextFont: UIFont?
    /// Not applied: nothing reads this type; `CometChatDialog` takes its colours and fonts through its own `set(...)` methods.
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
