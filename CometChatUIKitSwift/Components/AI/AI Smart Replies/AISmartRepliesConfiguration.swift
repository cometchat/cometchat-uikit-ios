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
    
    private(set) var customView: ((_ reply: [String: String]) -> UIView?)?
    private(set) var apiConfiguration: ((_ user: User?, _ group: Group?, _ configuration: ((_ configuration: [String: Any]) -> ()) ) -> Void)?
    
    @discardableResult
    public func set(customView: ((_ reply: [String: String]) -> UIView?)?) -> Self {
        self.customView = customView
        return self
    }
    
    @discardableResult
    public func set(apiConfiguration: ((_ user: User?, _ group: Group?, _ configuration: ((_ configuration: [String: Any]) -> ()) ) -> Void)?) -> Self {
        self.apiConfiguration = apiConfiguration
        return self
    }
}
