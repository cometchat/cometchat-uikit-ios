//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 19/04/23.
//

import Foundation
import UIKit
import CometChatSDK

#if canImport(CometChatCallsSDK)
import CometChatCallsSDK

public final class IncomingCallConfiguration {
    
    private(set) var onAccept: ((BaseMessage) -> Void)?
    private(set) var onDecline: ((BaseMessage) -> Void)?
    private(set) var onError: ((_ error: CometChatException) -> Void)?
    private(set) var call: Call?
    private(set) var declineButtonIcon: UIImage?
    private(set) var acceptButtonIcon: UIImage?
    private(set) var disableSoundForCalls: Bool?
    private(set) var customSoundForCalls: URL?
    private(set) var avatarStyle: AvatarStyle?
    private(set) var acceptButtonStyle: ButtonStyle?
    private(set) var declineButtonStyle: ButtonStyle?
    private(set) var incomingCallStyle: IncomingCallStyle?
    private(set) var callSettingsBuilder: CallSettingsBuilder?
    
    public init() {}
    
    /// Configures the outgoing call settings using a custom CallSettingsBuilder.
    /// This property applies the specified custom CallSettingsBuilder to all outgoing calls.
    /// - Parameter callSettingBuilder: An instance of a custom CallSettingsBuilder. The object must conform to the CallSettingsBuilder type.
    /// - Returns: The current instance of OutgoingCallConfiguration for declarative coding, allowing further method chaining.
    /// - Note: Ensure that the provided callSettingBuilder is of type CallSettingsBuilder, otherwise it will be ignored.
    @discardableResult public func set(callSettingsBuilder: Any) -> Self {
        if let callSettingsBuilder = callSettingsBuilder as? CallSettingsBuilder {
            self.callSettingsBuilder = callSettingsBuilder
        }
        return self
    }
    
    @discardableResult
    public func setOnAccept(onAccept: @escaping ((BaseMessage) -> Void)) -> Self {
        self.onAccept = onAccept
        return self
    }
    
    @discardableResult
    public func setOnDecline(onDecline: @escaping ((BaseMessage) -> Void)) -> Self {
        self.onDecline = onDecline
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(call: Call?) -> Self {
        self.call = call
        return self
    }
    
    @discardableResult
    public func set(acceptButtonIcon: UIImage?) -> Self {
        self.acceptButtonIcon = acceptButtonIcon
        return self
    }
    
    @discardableResult
    public func set(declineButtonIcon: UIImage?) -> Self {
        self.declineButtonIcon = declineButtonIcon
        return self
    }
    
    @discardableResult
    public func disable(soundForCalls: Bool?) -> Self {
        self.disableSoundForCalls = soundForCalls
        return self
    }
    
    @discardableResult
    public func set(customSoundForCalls: URL?) -> Self {
        self.customSoundForCalls = customSoundForCalls
        return self
    }
    
    @discardableResult
    public func set(avatarStyle: AvatarStyle?) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(acceptButtonStyle: ButtonStyle?) -> Self {
        self.acceptButtonStyle = acceptButtonStyle
        return self
    }
    
    @discardableResult
    public func set(declineButtonStyle: ButtonStyle?) -> Self {
        self.declineButtonStyle = declineButtonStyle
        return self
    }
    
    @discardableResult
    public func set(incomingCallStyle: IncomingCallStyle?) -> Self {
        self.incomingCallStyle = incomingCallStyle
        return self
    }
    
    
}

#endif
