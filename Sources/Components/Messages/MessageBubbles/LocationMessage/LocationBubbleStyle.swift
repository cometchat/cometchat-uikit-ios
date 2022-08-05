//
//  LocationBubbleStyle.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 19/05/22.
//

import Foundation
import UIKit

class LocationBubbleStyle {
    
    let titleFont: UIFont?
    let titleColor: UIColor?
    let subTitleFont: UIFont?
    let subTitleColor: UIColor?
    let descriptionViewBackgroundColor: UIColor?
    
    init(titleColor: UIColor? = .gray, titleFont: UIFont? = UIFont.systemFont(ofSize: 15, weight: .regular), subTitleColor: UIColor? = .gray, subTitleFont: UIFont? = UIFont.systemFont(ofSize: 13, weight: .regular), descriptionViewBackgroundColor: UIColor? = .systemFill) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.subTitleFont = subTitleFont
        self.subTitleColor = subTitleColor
        self.descriptionViewBackgroundColor = descriptionViewBackgroundColor
    }
}
