//
//  DeleteBubbleStyle.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 25/05/22.
//

import Foundation
import UIKit

public class DeleteBubbleStyle {
    
    let titleFont: UIFont?
    let titleColor: UIColor?
    
    init(titleColor: UIColor? = .gray, titleFont: UIFont? = CometChatTheme.typography?.Body ?? UIFont.systemFont(ofSize: 15, weight: .regular)) {
        self.titleColor = titleColor
        self.titleFont = titleFont
    }
}
