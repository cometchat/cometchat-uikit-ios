//
//  AISmartRepliesConfiguration.swift
//  
//
//  Created by SuryanshBisen on 14/09/23.
//

import Foundation
import UIKit
import CometChatSDK

public class AISmartRepliesConfiguration: AIParentConfiguration {
    
    var customView: ((_ reply: [String: String]) -> UIView?)?
    var style: AISmartRepliesStyle?
    var onClick: ((_ user: User?, _ group: Group?) -> UIView?)?
    
    @discardableResult
    @objc public func set(customView: ((_ reply: [String: String]) -> UIView?)?) -> Self {
        self.customView = customView
        return self
    }
    
    @discardableResult
    @objc public func set(style: AISmartRepliesStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    @objc public func set(onClick: ((_ user: User?, _ group: Group?) -> UIView?)?) -> Self {
        self.onClick = onClick
        return self
    }
}
