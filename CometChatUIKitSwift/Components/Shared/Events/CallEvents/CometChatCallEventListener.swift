//
//  CometChatUserEvents.swift
 
//
//  Created by Pushpsen Airekar on 13/05/22.
//

import UIKit
import CometChatSDK
import Foundation


public protocol CometChatCallEventListener {
    
    ///[ccOutgoingCall] is used to inform the listeners that an outgoing call is initiated by the logged-in user.
    func ccOutgoingCall(call: Call)

    ///[ccCallAccepted] is used to inform the listeners that a call is accepted by the logged-in user.
    func ccCallAccepted(call: Call)

    ///[ccCallRejected] is used to inform the listeners that a call is rejected by the logged-in user.
    func ccCallRejected(call: Call)

    ///[ccCallEnded] is used to inform the listeners that a call is ended by either the logged-in user.
    func ccCallEnded(call: Call)
    
    @available(*, deprecated, message: "Use `ccCallAccepted(call: Call)` instead")
    func onIncomingCallAccepted(call: Call)
    
    @available(*, deprecated, message: "Use `ccCallRejected(call: Call)` instead")
    func onIncomingCallRejected(call: Call)
    
    @available(*, deprecated, message: "Use `ccCallEnded(call: Call)` instead")
    func onCallEnded(call: Call)
    
    @available(*, deprecated, message: "Use `ccOutgoingCall(call: Call)` instead")
    func onCallInitiated(call: Call)
    
    @available(*, deprecated, message: "Use `ccCallAccepted(call: Call)` instead")
    func onOutgoingCallAccepted(call: Call)
    
    @available(*, deprecated, message: "Use `ccCallRejected(call: Call)` instead")
    func onOutgoingCallRejected(call: Call)
}

//Making Functions optional
public extension CometChatCallEventListener {
    
    func ccOutgoingCall(call: Call) {}
    func ccCallAccepted(call: Call) {}
    func ccCallRejected(call: Call) {}
    func ccCallEnded(call: Call) {}
    
    func onIncomingCallAccepted(call: Call) {}
    func onIncomingCallRejected(call: Call) {}
    func onCallEnded(call: Call) {}
    func onCallInitiated(call: Call) {}
    func onOutgoingCallAccepted(call: Call) {}
    func onOutgoingCallRejected(call: Call) {}
}
