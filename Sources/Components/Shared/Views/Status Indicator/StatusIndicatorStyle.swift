//
//  StatusIndicatorStyle.swift
//  
//
//  Created by Abdullah Ansari on 05/09/22.
//

import UIKit

public final class StatusIndicatorStyle: BaseStyle {
    
    override var cornerRadius: CometChatCornerStyle {
        
        get {
            return CometChatCornerStyle(cornerRadius: 10.0)
        }
        
        set {}
    }
}
