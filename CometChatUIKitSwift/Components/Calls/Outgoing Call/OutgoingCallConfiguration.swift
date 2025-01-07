//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 19/04/23.
//

#if canImport(CometChatCallsSDK)

import CometChatCallsSDK
import Foundation
import UIKit
import CometChatSDK

public final class OutgoingCallConfiguration {
    
    private(set) var call: Call?
    private(set) var onDeclineButtonClicked:(() -> Void)?
    private(set) var onError:(() -> Void)?
    private(set) var declineButtonIcon: UIImage?
    private(set) var disableSoundForCalls: Bool?
    private(set) var customSoundForCalls: URL?
    private(set) var avatarStyle: AvatarStyle?
    private(set) var buttonStyle: ButtonStyle?
    private(set) var outgoingCallStyle: OutgoingCallStyle?
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
    public func set(call: Call?) -> Self {
        self.call = call
        return self
    }
    
    @discardableResult
    public func setOnDeclineButtonClicked(onDeclineButtonClicked: @escaping (() -> Void)) -> Self {
        self.onDeclineButtonClicked = onDeclineButtonClicked
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping (() -> Void)) -> Self {
        self.onError = onError
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
    public func set(buttonStyle: ButtonStyle?) -> Self {
        self.buttonStyle = buttonStyle
        return self
    }
    
    @discardableResult
    public func set(outgoingCallStyle: OutgoingCallStyle?) -> Self {
        self.outgoingCallStyle = outgoingCallStyle
        return self
    }
    
    
}

#endif
