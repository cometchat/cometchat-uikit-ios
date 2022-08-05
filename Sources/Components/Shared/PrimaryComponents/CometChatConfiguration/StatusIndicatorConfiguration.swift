//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import CometChatPro
import UIKit

public class StatusIndicatorConfiguration: CometChatConfiguration {
  
    var cornerRadius: CGFloat = 0
    var borderWidth: CGFloat = 0
    var backgroundColorForOnlineState: UIColor = #colorLiteral(red: 0.231372549, green: 0.8745098039, blue: 0.1843137255, alpha: 1)
    var backgroundColorForOfflineState: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    
    public func set(cornerRadius: CGFloat) -> StatusIndicatorConfiguration {
        self.cornerRadius = cornerRadius
        return self
    }
    
    public func set(borderWidth: CGFloat) -> StatusIndicatorConfiguration {
        self.borderWidth = borderWidth
        return self
    }
    
    public func set(backgroundColor: UIColor, forStatus: CometChat.UserStatus) -> StatusIndicatorConfiguration {
        switch forStatus {
        case .online:
            self.backgroundColorForOnlineState = backgroundColor
        case .offline:
            self.backgroundColorForOfflineState = backgroundColor
        case .available:
            self.backgroundColorForOfflineState = backgroundColor
        @unknown default:
            self.backgroundColorForOfflineState = backgroundColor
        }
        return self
    }

   
}
