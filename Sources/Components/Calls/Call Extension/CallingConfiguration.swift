//
//  CallingConfiguration.swift
//  
//
//  Created by Pushpsen Airekar on 15/03/23.
//

import Foundation

class CallingConfiguration {
    
    var callButtonConfiguration: CallButtonConfiguration?
    var callBubbleConfiguration: CallBubbleConfiguration?
    var incomingCallConfiguration: IncomingCallConfiguration?
    var outgoingCallConfiguration: OutgoingCallConfiguration?
    
    public init() { }
    
    @discardableResult
    public func set(callButtonConfiguration: CallButtonConfiguration) -> Self {
        self.callButtonConfiguration = callButtonConfiguration
        return self
    }
    
    @discardableResult
    public func set(callBubbleConfiguration: CallBubbleConfiguration) -> Self {
        self.callBubbleConfiguration = callBubbleConfiguration
        return self
    }
    
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
    
}
