//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 19/04/23.
//

import Foundation
import UIKit
import CometChatSDK

public final class CallButtonConfiguration {
    
    private(set) var voiceCallIcon: UIImage?
    private(set) var videoCallIcon: UIImage?
    private(set) var hideVoiceCall: Bool?
    private(set) var hideVideoCall: Bool?
    private(set) var callButtonsStyle: ButtonStyle?
    private(set) var onVoiceCallClick: ((_ user: User?, _ group: Group?) -> Void)?
    private(set) var onVideoCallClick: ((_ user: User?, _ group: Group?) -> Void)?
    private(set) var onError: ((_ error: CometChatException?) -> Void)?
    
    public init() {}
    
    @discardableResult
    public func set(voiceCallIcon: UIImage?) -> Self {
        self.voiceCallIcon = voiceCallIcon
        return self
    }
    
    @discardableResult
    public func set(videoCallIcon: UIImage?) -> Self {
        self.videoCallIcon = videoCallIcon
        return self
    }
    
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
    
}
