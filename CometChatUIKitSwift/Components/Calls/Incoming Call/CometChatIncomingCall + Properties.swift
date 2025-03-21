//
//  CometChatIncomingCall + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import Foundation
import CometChatSDK

#if canImport(CometChatCallsSDK)

extension CometChatIncomingCall {
    
    //MARK: Data
    @discardableResult
    public func set(call: Call) -> Self {
        self.viewModel.call = call
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
    public func set(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(onCancelClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
        self.onCancelClick = onCancelClick
        return self
    }
    
    @discardableResult
    public func set(onAcceptClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
        self.onAcceptClick = onAcceptClick
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
    public func set(trailView: ((_ call: Call) -> UIView)?) -> Self {
        self.trailView = trailView
        return self
    }
    
    @discardableResult
    public func set(titleView: ((_ call: Call) -> UIView)?) -> Self {
        self.titleView = titleView
        return self
    }
    
    @discardableResult
    public func set(listItemView: ((_ call: Call) -> UIView)?) -> Self {
        self.listItemView = listItemView
        return self
    }
    
    @discardableResult
    public func set(leadingView: ((_ call: Call) -> UIView)?) -> Self {
        self.leadingView = leadingView
        return self
    }
    
}
#endif
