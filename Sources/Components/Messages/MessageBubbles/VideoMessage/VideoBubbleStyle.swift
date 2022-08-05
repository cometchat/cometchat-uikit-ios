//
//  VideoBubbleStyle.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 23/05/22.
//

import Foundation
import UIKit

class VideoBubbleStyle {
    
    let playColor: UIColor?
    
    init(playColor: UIColor? = CometChatTheme.palatte?.primary) {
        self.playColor = playColor
    }
}
