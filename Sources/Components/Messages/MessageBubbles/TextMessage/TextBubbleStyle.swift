//
//  TextBubbleStyle.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 20/05/22.
//

import Foundation
import UIKit

class TextBubbleStyle {
    
    let titleFont: UIFont?
    let titleColor: UIColor?
    let subTitleFont: UIFont?
    let subTitleColor: UIColor?
    let messageTextFont: UIFont?
    let messageTextColor: UIColor?
    let linkPreviewMessageFont: UIFont?
    let linkPreviewMessageColor: UIColor?
    
    
    init(titleColor: UIColor? = .gray, titleFont: UIFont? = UIFont.systemFont(ofSize: 15, weight: .regular), subTitleFont: UIFont? = UIFont.systemFont(ofSize: 13, weight: .regular), subTitleColor: UIColor? = .gray, messageTextFont: UIFont? = UIFont.systemFont(ofSize: 17, weight: .regular), messageTextColor: UIColor? = .gray, linkPreviewMessageFont: UIFont? = .systemFont(ofSize: 15), linkPreviewMessageColor: UIColor? = .gray) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.subTitleFont = subTitleFont
        self.subTitleColor = subTitleColor
        self.messageTextFont = messageTextFont
        self.messageTextColor = messageTextColor
        self.linkPreviewMessageFont = linkPreviewMessageFont
        self.linkPreviewMessageColor = linkPreviewMessageColor
    }
}
