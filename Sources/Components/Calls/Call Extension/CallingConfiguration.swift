//
//  File.swift
//  
//
//  Created by Pushpsen Airekar on 15/03/23.
//

import Foundation

public class CallingConfiguration {
    
    var callBubbleConfiguration: CallBubbleConfiguration?
    
    public init() { }
    
    @discardableResult
    public func set(callBubbleConfiguration: CallBubbleConfiguration) -> Self {
        self.callBubbleConfiguration = callBubbleConfiguration
        return self
    }
    
}
