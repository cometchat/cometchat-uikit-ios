//
//  AIConversationStartersConfiguration.swift
//  
//
//  Created by SuryanshBisen on 14/09/23.
//

import Foundation
import UIKit
import CometChatSDK


public class AIConversationStartersConfiguration: AIParentConfiguration {
    
    var customView: ((_ reply: [String]) -> UIView?)?
    var style: AIConversationStartersStyle?
    var onLoad: ((_ user: User?, _ group: Group?) -> UIView?)?
    
    @discardableResult
    @objc public func set(customView: ((_ reply: [String]) -> UIView?)?) -> Self {
        self.customView = customView
        return self
    }
    
    @discardableResult
    @objc public func set(style: AIConversationStartersStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    @objc public func set(onLoad: ((_ user: User?, _ group: Group?) -> UIView?)?) -> Self {
        self.onLoad = onLoad
        return self
    }

    
}
