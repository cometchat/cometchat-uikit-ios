//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 19/04/23.
//

import Foundation
import UIKit
import CometChatPro

public final class IncomingCallConfiguration {
    
    private(set) var declineButtonIcon: UIImage?
    private(set) var acceptButtonIcon: UIImage?
    private(set) var disableSoundForCalls: Bool?
    private(set) var customSoundForCalls: URL?
    private(set) var avatarStyle: AvatarStyle?
    private(set) var acceptButtonStyle: ButtonStyle?
    private(set) var declineButtonStyle: ButtonStyle?
    private(set) var incomingCallStyle: IncomingCallStyle?
    
    public init() {}
    
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
