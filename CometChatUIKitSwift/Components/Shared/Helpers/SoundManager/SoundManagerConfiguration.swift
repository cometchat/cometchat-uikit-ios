//
//  SoundManagerConfiguration.swift
//  
//
//  Created by Abdullah Ansari on 05/09/22.
//

import UIKit

class SoundManagerConfiguration  {

    private(set) var incomingCall: String?
    private(set) var incomingMessage: String?
    private(set) var incomingMessageFromOther: String?
    private(set) var outgoingCall: String?
    private(set) var outgoingMessage: String?
    
    @discardableResult
    public func set(incomingCall: String) -> Self {
        self.incomingCall = incomingCall
        return self
    }
    
    @discardableResult
    public func set(incomingMessage: String) -> Self {
        self.incomingMessage = incomingMessage
        return self
    }
    
    @discardableResult
    public func set(outgoingCall: String) -> Self {
        self.outgoingCall = outgoingCall
        return self
    }
    
    @discardableResult
    public func set(outgoingMessage: String) -> Self {
        self.outgoingMessage = outgoingMessage
        return self
    }
    
    @discardableResult
    public func set(incomingMessageFromOther: String) -> Self {
        self.incomingMessageFromOther = incomingMessageFromOther
        return self
    }
  
}
