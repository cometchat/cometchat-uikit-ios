//
//  CometChatOutgoingCall + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import Foundation
import CometChatSDK

#if canImport(CometChatCallsSDK)

extension CometChatOutgoingCall {
    
    //MARK: Data
    @discardableResult
    public func set(call: Call) -> Self {
        self.call = call
        return self
    }
    
    @discardableResult public func set(callSettingsBuilder: Any) -> Self {
        if let callSettingsBuilder = callSettingsBuilder as? CallSettingsBuilder {
            self.callSettingsBuilder = callSettingsBuilder
        }
        return self
    }
    
    
    //MARK: Events
    @discardableResult
    public func set(onCancelClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
        self.onCancelClick = onCancelClick
        return self
    }
    
    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    
    @discardableResult
    public func set(user: User) -> Self {
        self.user = user
        return self
    }
    
    
    //MARK: Configuration
    @discardableResult
    public func disable(soundForCalls: Bool) -> Self {
        self.disableSoundForCalls = soundForCalls
        return self
    }
    
    @discardableResult
    public func set(customSoundForCalls: URL?) -> Self {
        self.customSoundForCalls = customSoundForCalls
        return self
    }
    
    
    //MARK: Overrides
    @discardableResult
    public func set(subtitleView: ((_ call: Call) -> UIView)?) -> Self {
        self.subtitleView = subtitleView
        return self
    }
    
    @discardableResult
    public func set(titleView: ((_ call: Call) -> UIView)?) -> Self {
        self.titleView = titleView
        return self
    }
    
    @discardableResult
    public func set(avatarView: ((_ call: Call) -> UIView)?) -> Self {
        self.avatarView = avatarView
        return self
    }
    
    @discardableResult
    public func set(cancelView: ((_ call: Call) -> UIView)?) -> Self {
        self.cancelView = cancelView
        return self
    }
    
}
#endif
