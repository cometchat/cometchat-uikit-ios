//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 19/04/23.
//

import Foundation
import UIKit
import CometChatPro

public final class OutgoingCallConfiguration {
    
    private(set) var declineButtonIcon: UIImage?
    private(set) var disableSoundForCalls: Bool?
    private(set) var customSoundForCalls: URL?
    private(set) var avatarStyle: AvatarStyle?
    private(set) var buttonStyle: ButtonStyle?
    private(set) var outgoingCallStyle: OutgoingCallStyle?
    
    public init() {}
    
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
