//
//  CometChatSettings.swift
 
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import CometChatSDK
import UIKit

public final class StatusIndicatorConfiguration: CometChatConfiguration {
  
    private(set) var cornerRadius: CometChatCornerStyle?
    private(set) var borderWidth: CGFloat = 0
    private(set) var backgroundColorForOnlineState: UIColor = #colorLiteral(red: 0.231372549, green: 0.8745098039, blue: 0.1843137255, alpha: 1)
    private(set) var backgroundColorForOfflineState: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
    private(set) var statusIndicatorStyle: StatusIndicatorStyle?
    
    @discardableResult
    public func set(cornerRadius: CometChatCornerStyle) -> Self {
        self.cornerRadius = cornerRadius
        return self
    }
    
    @discardableResult
    public func set(borderWidth: CGFloat) -> Self {
        self.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    public func set(backgroundColor: UIColor, forStatus: CometChat.UserStatus) -> Self {
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

    @discardableResult
    public func set(statusIndicatorStyle: StatusIndicatorStyle) -> Self {
        self.statusIndicatorStyle = statusIndicatorStyle
        return self
    }
   
}
