//
//  AIConversationStarterConfiguration.swift
//  
//
//  Created by SuryanshBisen on 14/09/23.
//

import Foundation
import UIKit
import CometChatSDK


public class AIConversationStarterConfiguration: AIParentConfiguration {
    
    private(set) var customView: ((_ reply: [String]) -> UIView?)?
    private(set) var style: AIConversationStarterStyle = AIConversationStarterStyle()
    private(set) var apiConfiguration: ((_ user: User?, _ group: Group?,  _ configuration: ((_ configuration: [String: Any]) -> Void)) -> Void)?
    
    @discardableResult
    public func set(customView: ((_ reply: [String]) -> UIView?)?) -> Self {
        self.customView = customView
        return self
    }
    
    @discardableResult
    public func set(style: AIConversationStarterStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func set(apiConfiguration: ((_ user: User?, _ group: Group?,  _ configuration: ((_ configuration: [String: Any]) -> Void)) -> Void)?) -> Self {
        self.apiConfiguration = apiConfiguration
        return self
    }

    
}
