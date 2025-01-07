//
//  AIConversationSummaryConfiguration.swift
//  
//
//  Created by SuryanshBisen on 20/10/23.
//

import Foundation
import UIKit
import CometChatSDK


public class AIConversationSummaryConfiguration: AIParentConfiguration {
    
    private(set) var title: String?
    private(set) var closeIcon: UIImage?
    private(set) var summaryStyle: AIConversationSummaryStyle?
    private(set) var customView: ((_ response: String, _ closeCallBack: @escaping () -> Void) -> UIView)?
    private(set) var unreadMessageThreshold: Int?
    private(set) var apiConfiguration: ((_ user: User?, _ group: Group?, _ configuration: ((_ configuration: [String: Any]) -> Void)) -> ())?
    
    @discardableResult
    public func set(title: String) -> Self {
        self.title = title
        return self
    }
    
    @discardableResult
    public func set(closeIcon: UIImage) -> Self {
        closeIcon.withRenderingMode(.alwaysTemplate)
        self.closeIcon = closeIcon
        return self
    }
    
    @discardableResult
    public func set(summaryStyle: AIConversationSummaryStyle) -> Self {
        self.summaryStyle = summaryStyle
        return self
    }
    
    @discardableResult
    public func set(customView: ((_ response: String, _ closeCallBack: @escaping () -> Void) -> UIView)?) -> Self {
        self.customView = customView
        return self
    }
    
    @discardableResult
    public func set(unreadMessageThreshold: Int) -> Self {
        self.unreadMessageThreshold = unreadMessageThreshold
        return self
    }
    
    @discardableResult
    public func set(apiConfiguration: ((_ user: User?, _ group: Group?, _ configuration: ((_ configuration: [String: Any]) -> Void)) -> ())?) -> Self {
        self.apiConfiguration = apiConfiguration
        return self
    }
    
}
