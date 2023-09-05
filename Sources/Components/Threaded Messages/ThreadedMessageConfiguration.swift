//
//  ThreadedMessageConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 02/02/23.
//

import Foundation
import UIKit
import CometChatSDK

public class ThreadedMessageConfiguration {
    
    var backIcon: UIImage?
    var messageActionView: ((_ message: BaseMessage) -> UIView)?
    var messageListConfiguration: MessageListConfiguration?
    var messageComposerConfiguration: MessageComposerConfiguration?
    
    public init() {}
    
    @discardableResult
    public func set(backIcon: UIImage) -> Self {
        self.backIcon = backIcon
        return self
    }
    
    @discardableResult
    public func setMessageActionView(messageActionView: ((_ message: BaseMessage) -> UIView)?) -> Self {
        self.messageActionView = messageActionView
        return self
    }
    
    @discardableResult
    public func set(messageListConfiguration: MessageListConfiguration) -> Self {
        self.messageListConfiguration = messageListConfiguration
        return self
    }
    
    @discardableResult
    public func set(messageComposerConfiguration: MessageComposerConfiguration) -> Self {
        self.messageComposerConfiguration = messageComposerConfiguration
        return self
    }
}
