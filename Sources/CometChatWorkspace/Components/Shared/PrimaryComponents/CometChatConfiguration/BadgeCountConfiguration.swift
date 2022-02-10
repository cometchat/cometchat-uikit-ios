//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public class BadgeCountConfiguration: CometChatConfiguration {
  
    var cornerRadius: CGFloat = 0
    
    public func set(cornerRadius: CGFloat) -> BadgeCountConfiguration {
        self.cornerRadius = cornerRadius
        return self
    }
}


