//
//  MessageBubbleStyle.swift
//  
//
//  Created by Abdullah Ansari on 24/08/22.
//

import UIKit

final public class MessageBubbleStyle: BaseStyle {
 
    override var background: UIColor {
        get {
            return .clear
        }
        set {
            super.background = newValue
        }
    }
    
    override var cornerRadius: CometChatCornerStyle {
        
        get {
            return CometChatCornerStyle(cornerRadius: 12)
        }
        set {
            super.cornerRadius = newValue
        }
    }
}
