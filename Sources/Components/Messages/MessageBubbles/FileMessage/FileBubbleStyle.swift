//
//  FileBubbleStyle.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 23/05/22.
//

import Foundation
import UIKit

class FileBubbleStyle {
    
    let titleColor: UIColor?
    let titleFont: UIFont?
    let subTitleColor: UIColor?
    let subTitleFont: UIFont?
    let thumbnailColor: UIColor?
    
    init(titleColor: UIColor? = .gray, titleFont: UIFont? = UIFont.systemFont(ofSize: 15, weight: .regular), subTitleColor: UIColor? = .gray, subTitleFont: UIFont? = UIFont.systemFont(ofSize: 13, weight: .regular), thumbnailColor: UIColor? = CometChatTheme.palatte?.primary) {
        self.titleColor = titleColor
        self.titleFont = titleFont
        self.subTitleColor = subTitleColor
        self.subTitleFont = subTitleFont
        self.thumbnailColor = thumbnailColor
    }
}
