//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 19/04/23.
//

import UIKit
import Foundation
import UIKit
import CometChatSDK

#if canImport(CometChatCallsSDK)

public final class CallButtonConfiguration {
    
    private(set) var hideVoiceCall: Bool?
    private(set) var hideVideoCall: Bool?
    private(set) var callButtonsStyle: ButtonStyle?
    private(set) var onVoiceCallClick: ((_ user: User?, _ group: Group?) -> Void)?
    private(set) var onVideoCallClick: ((_ user: User?, _ group: Group?) -> Void)?
    private(set) var onError: ((_ error: CometChatException?) -> Void)?
    private(set) var callSettingsBuilder: ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)?
    private(set) var outgoingCallConfiguration : OutgoingCallConfiguration?

    
    public init() {}
    
    @discardableResult
    public func hide(voiceCall: Bool?) -> Self {
        self.hideVoiceCall = voiceCall
        return self
    }
    
    @discardableResult
    public func hide(videoCall: Bool?) -> Self {
        self.hideVideoCall = videoCall
        return self
    }
    
    @discardableResult
    public func set(callButtonsStyle: ButtonStyle?) -> Self {
        self.callButtonsStyle = callButtonsStyle
        return self
    }
    
    @discardableResult
    public func setOnVoiceCallClick(onVoiceCallClick: @escaping ((_ user: User?, _ group: Group?) -> Void)) -> Self {
        self.onVoiceCallClick = onVoiceCallClick
        return self
    }
    
    @discardableResult
    public func setOnVideoCallClick(onVideoCallClick: @escaping ((_ user: User?, _ group: Group?) -> Void)) -> Self {
        self.onVideoCallClick = onVideoCallClick
        return self
    }
    
    @discardableResult
    public func setOnError(onError: @escaping ((_ error: CometChatException?) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    @discardableResult
    public func set(outgoingCallConfiguration: OutgoingCallConfiguration?) -> Self {
        self.outgoingCallConfiguration = outgoingCallConfiguration
        return self
    }
    
    /// Configures the settings for calls initiated via CallButton by providing a callback function.
    /// This function takes a callback that is invoked every time a call is initiated via CallButton, either on a User or a Group.
    /// The callback allows customization of the CallSettingsBuilder based on the User, Group, and whether the call is audio-only.
    /// - Parameter callSettingBuilder: A callback function that provides a User (optional), a Group, and a Boolean indicating if the call is audio-only. The callback returns a CallSettingsBuilder object configured with the desired settings.
    /// - Returns: The current instance of CallingConfiguration for declarative coding, allowing further method chaining.
    /// - Note: Ensure that the returned object from the callback is of type CallSettingsBuilder to apply the custom settings.
    @discardableResult public func set(callSettingsBuilder: @escaping ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)) -> Self {
        self.callSettingsBuilder = callSettingsBuilder
        return self
    }
    
}

#endif
