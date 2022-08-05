//
//  DocumentBubbleStyle.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 19/05/22.
//

import Foundation
import UIKit

class DocumentBubbleStyle {
    
    let titleColor: UIColor?
    let titleFont: UIFont?
    let subTitleColor: UIColor?
    let subTitleFont: UIFont?
    let iconColor: UIColor?
    let documentButtonTitleFont: UIFont?
    let documentButtonTitleColor: UIColor?
    let lineColor: UIColor?
    
    init(titleColor: UIColor? = .gray, titleFont: UIFont? = UIFont.systemFont(ofSize: 15, weight: .regular), subTitleColor: UIColor? = .gray, subTitleFont: UIFont? = UIFont.systemFont(ofSize: 13, weight: .regular), iconColor: UIColor? = .white, documentButtonTitleColor: UIColor? = .blue, documentButtonTitleFont: UIFont? = UIFont.systemFont(ofSize: 17, weight: .regular), lineColor: UIColor? = .gray) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.subTitleColor = subTitleColor
        self.subTitleFont = subTitleFont
        self.iconColor = iconColor
        self.documentButtonTitleColor = documentButtonTitleColor
        self.documentButtonTitleFont = documentButtonTitleFont
        self.lineColor = lineColor
    }
}


