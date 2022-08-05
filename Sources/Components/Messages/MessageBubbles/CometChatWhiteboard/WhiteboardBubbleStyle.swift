//
//  WhiteboardBubbleStyle.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 19/05/22.
//

import Foundation
import UIKit

class WhiteboardBubbleStyle {
    
    let titleColor: UIColor?
    let titleFont: UIFont?
    let subTitleColor: UIColor?
    let subTitleFont: UIFont?
    let iconColor: UIColor?
    let whiteboardButtonTitleFont: UIFont?
    let whiteboardButtonTitleColor: UIColor?
    let lineColor: UIColor?
    let buttonColor: UIColor?
    let buttonFont: UIFont?
    
    init(titleColor: UIColor? = .gray, titleFont: UIFont? = UIFont.systemFont(ofSize: 15, weight: .regular), subTitleColor: UIColor? = .gray, subTitleFont: UIFont? = UIFont.systemFont(ofSize: 13, weight: .regular), iconColor: UIColor? = .white, whiteboardButtonTitleColor: UIColor? = .blue, whiteboardButtonTitleFont: UIFont? = UIFont.systemFont(ofSize: 17, weight: .regular), lineColor: UIColor? = .gray, buttonColor: UIColor? = .systemBlue, buttonFont: UIFont? = UIFont.systemFont(ofSize: 17, weight: .regular)) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.subTitleColor = subTitleColor
        self.subTitleFont = subTitleFont
        self.iconColor = iconColor
        self.whiteboardButtonTitleColor = whiteboardButtonTitleColor
        self.whiteboardButtonTitleFont = whiteboardButtonTitleFont
        self.lineColor = lineColor
        self.buttonColor = buttonColor
        self.buttonFont = buttonFont
        
    }
}
