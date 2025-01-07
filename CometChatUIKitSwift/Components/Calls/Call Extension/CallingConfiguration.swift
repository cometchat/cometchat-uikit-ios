//
//  CallingConfiguration.swift
//  
//
//  Created by Pushpsen Airekar on 15/03/23.
//

import UIKit
import Foundation
import CometChatSDK

#if canImport(CometChatCallsSDK)

public class CallingConfiguration {
    
    var incomingCallConfiguration: IncomingCallConfiguration?
    var outgoingCallConfiguration: OutgoingCallConfiguration?
    var callBubbleConfiguration: CallBubbleConfiguration?
    var callButtonConfiguration: CallButtonConfiguration?
    var groupCallSettingsBuilder: ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)?
    
    public init() { }
    
    @discardableResult
    public func set(incomingCallConfiguration: IncomingCallConfiguration) -> Self {
        self.incomingCallConfiguration = incomingCallConfiguration
        return self
    }
    
    @discardableResult
    public func set(outgoingCallConfiguration: OutgoingCallConfiguration) -> Self {
        self.outgoingCallConfiguration = outgoingCallConfiguration
        return self
    }
    
    /// Configures the settings for group calls by providing a callback function.
    /// This function takes a callback that is invoked every time a group call is initiated, either on a User or a Group.
    /// The callback allows customization of the CallSettingsBuilder based on the User, Group, and whether the call is audio-only.
    /// - Parameter groupCallSettingBuilder: A callback function that provides a User (optional), a Group, and a Boolean indicating if the call is audio-only. The callback returns a CallSettingsBuilder object configured with the desired settings.
    /// - Returns: The current instance of CallingConfiguration for declarative coding, allowing further method chaining.
    /// - Note: Ensure that the returned object from the callback is of type CallSettingsBuilder to apply the custom settings.
    @discardableResult public func set(groupCallSettingsBuilder: @escaping ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)) -> Self {
        self.groupCallSettingsBuilder = groupCallSettingsBuilder
        return self
    }
    
    @discardableResult
    public func set(callBubbleConfiguration: CallBubbleConfiguration) -> Self {
        self.callBubbleConfiguration = callBubbleConfiguration
        return self
    }
    
    @discardableResult
    public func set(callButtonConfiguration: CallButtonConfiguration) -> Self {
        self.callButtonConfiguration = callButtonConfiguration
        return self
    }
    
}

#endif
