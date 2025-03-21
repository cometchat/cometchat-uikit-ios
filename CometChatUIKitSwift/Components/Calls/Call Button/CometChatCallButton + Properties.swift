//
//  CometChatCallButton + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 09/02/25.
//

import Foundation
import UIKit
import CometChatSDK

#if canImport(CometChatCallsSDK)

extension CometChatCallButtons {
    
    //MARK: Data
    @discardableResult
    public func set(user: User) -> Self {
        self.user = user
        buildButton(forUser: user)
        return self
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        self.group = group
        buildButton(forGroup: group)
        return self
    }
    
    @discardableResult public func set(callSettingsBuilder: @escaping ((_ user: User?, _ group: Group?, _ isAudioOnly: Bool) -> Any)) -> Self {
        self.callSettingsBuilderCallBack = callSettingsBuilder
        return self
    }
    
    
    //MARK: Events
    @discardableResult
    public func set(onError: @escaping ((_ error: CometChatException?) -> Void)) -> Self {
        self.onError = onError
        return self
    }
    
    
    //MARK: Congiguration
    @discardableResult
    public func set(outgoingCallConfiguration: OutgoingCallConfiguration?) -> Self {
        self.outgoingCallConfiguration = outgoingCallConfiguration
        return self
    }
        
    @discardableResult
    public func set(controller: UIViewController?) -> Self {
        self.controller = controller
        return self
    }    
}
#endif
