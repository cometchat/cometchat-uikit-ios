//
//  CometChatSettings.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 28/12/21.
//

import Foundation
import UIKit

public class  MessageHeaderConfiguration: CometChatConfiguration {
  
    lazy var hideBackButton: Bool = false
    lazy var hideVideoCallButton: Bool = true
    lazy var hideVoiceCallButton: Bool = true
    lazy var hideInfoButton: Bool = false
    var avatarConfiguration: AvatarConfiguration?
    var inputData: InputData?
    var statusIndicatorConfiguration: StatusIndicatorConfiguration?
    
    
    public func set(inputData: InputData) -> Self {
        self.inputData = inputData
        return self
    }
    
    public func hide(backButton: Bool) -> Self {
        self.hideBackButton = backButton
        return self
    }
    
    public func hide(videoCall: Bool) -> Self {
        self.hideVideoCallButton = videoCall
        return self
    }
    
    public func hide(audioCall: Bool) -> Self {
        self.hideVoiceCallButton = audioCall
        return self
    }
    
    public func hide(info: Bool) -> Self {
        self.hideInfoButton = info
        return self
    }
    
    
    public func set(avatarConfiguration: AvatarConfiguration) -> Self {
        self.avatarConfiguration = avatarConfiguration
        return self
    }
    
    public func set(statusIndicatorConfiguration: StatusIndicatorConfiguration) -> Self {
        self.statusIndicatorConfiguration = statusIndicatorConfiguration
        return self
    }
    
}

