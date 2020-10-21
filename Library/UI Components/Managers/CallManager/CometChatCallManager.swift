//  CometChatCallManager.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import Foundation
import  UIKit
import  AVFoundation
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

@objc public class CometChatCallManager : NSObject {
    
     // MARK: - Declaration of Variables
    
    @objc static weak var incomingCallDelegate: IncomingCallDelegate?
    @objc static weak var outgoingCallDelegate: OutgoingCallDelegate?
    
    
    
   /**
    This method register all real time events needs to be perform for calls.
     - Parameter application: This specifies an application class.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc public func registerForCalls(application: UIResponder){
        CometChat.calldelegate = application as? CometChatCallDelegate
    }
    
    
    /**
    This method opens CometChatOutgoingCall screen, and send call request to the particular user or group.
     - Parameters:
       - call: This specifies call type i.e audio or video
       - to: This specifies an entity such as user or group
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc public func makeCall(call: CometChat.CallType, to: AppEntity){
        if let user = to as? User {
            if user.blockedByMe == true {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Kindly, unblock the user to make a call.", duration: .short)
                    snackbar.show()
            }else{
                DispatchQueue.main.async { 
                    let outgoingCall = CometChatOutgoingCall()
                    outgoingCall.makeCall(call: call, to: user)
                    outgoingCall.modalPresentationStyle = .fullScreen
                    if let window = UIApplication.shared.windows.first , let rootViewController = window.rootViewController {
                        var currentController = rootViewController
                        while let presentedController = currentController.presentedViewController {
                            currentController = presentedController
                        }
                        currentController.present(outgoingCall, animated: true, completion: nil)
                    }
                }
            }
        }
        if let group = to as? Group {
            DispatchQueue.main.async {
                let outgoingCall = CometChatOutgoingCall()
                outgoingCall.makeCall(call: call, to: group)
                outgoingCall.modalPresentationStyle = .fullScreen
                if let window = UIApplication.shared.windows.first , let rootViewController = window.rootViewController {
                    var currentController = rootViewController
                    while let presentedController = currentController.presentedViewController {
                        currentController = presentedController
                    }
                    currentController.present(outgoingCall, animated: true, completion: nil)
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

 // MARK: - Declaration of Protocols

@objc  protocol IncomingCallDelegate: AnyObject {
    @objc func onIncomingCallReceived(incomingCall: Call, error: CometChatException?)
    @objc func onIncomingCallCancelled(canceledCall: Call, error: CometChatException?)
}

@objc  protocol OutgoingCallDelegate: AnyObject {
    @objc func onOutgoingCallAccepted(acceptedCall: Call, error: CometChatException?)
    @objc func onOutgoingCallRejected(rejectedCall: Call, error: CometChatException?)
}

///*  ----------------------------------------------------------------------------------------- */

//  MARK: - CometChatCallDelegate Methods (For Swift Project)
//
//  Since, Objective C dosen't extend Appdelegate, kindly register for `CometChatCallDelegate` in AppDelegate and add those methods in AppDelegate.


extension AppDelegate : CometChatCallDelegate {

    /**
    This method triggers when incoming call received from Server.
     - Parameters:
      - incomingCall: Specifies a Call Object
        - error:  triggers when error occurs
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    func onIncomingCallReceived(incomingCall: Call?, error: CometChatException?) {
        print(#function)
        if let currentCall = incomingCall {
            DispatchQueue.main.async {
                let call = CometChatIncomingCall()
                call.modalPresentationStyle = .custom
                call.setCall(call: currentCall)
                if let window = self.window, let rootViewController = window.rootViewController {
                    var currentController = rootViewController
                    while let presentedController = currentController.presentedViewController {
                        currentController = presentedController
                    }
                    currentController.present(call, animated: true, completion: nil)
                }
                if let call = incomingCall {
                    CometChatCallManager.incomingCallDelegate?.onIncomingCallReceived(incomingCall: call, error: error)
                }
            }
        }

    }

    /**
    This method triggers when outgoing call accepted from User or group.
     - Parameters:
      - acceptedCall: Specifies a Call Object
        - error:  triggers when error occurs
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    func onOutgoingCallAccepted(acceptedCall: Call?, error: CometChatException?) {
        print(#function)
        if let call = acceptedCall {
            CometChatCallManager.outgoingCallDelegate?.onOutgoingCallAccepted(acceptedCall: call, error: error)
        }
    }

    /**
    This method triggers when ourgoing call rejected from User or group.
     - Parameters:
      - rejectedCall: Specifies a Call Object
        - error:  triggers when error occurs
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    func onOutgoingCallRejected(rejectedCall: Call?, error: CometChatException?) {
        print(#function)
        if let call = rejectedCall {
            CometChatCallManager.outgoingCallDelegate?.onOutgoingCallRejected(rejectedCall: call, error: error)
        }
    }

    /**
    This method triggers when incoming call cancelled from User or group.
     - Parameters:
      - rejectedCall: Specifies a Call Object
        - error:  triggers when error occurs
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    func onIncomingCallCancelled(canceledCall: Call?, error: CometChatException?) {
        print(#function)
        if let call = canceledCall {
            CometChatCallManager.incomingCallDelegate?.onIncomingCallCancelled(canceledCall: call, error: error)
        }
    }
}

///*  ----------------------------------------------------------------------------------------- */
//
//// //  MARK: - CometChatCallDelegate Methods (For Objective C Project)
////
//extension CometChatUnified : CometChatCallDelegate {
//
//    /**
//    This method triggers when incoming call received from Server.
//     - Parameters:
//      - incomingCall: Specifies a Call Object
//        - error:  triggers when error occurs
//    - Author: CometChat Team
//    - Copyright:  ©  2020 CometChat Inc.
//    */
//    public func onIncomingCallReceived(incomingCall: Call?, error: CometChatException?) {
//
//        if let currentCall = incomingCall {
//            DispatchQueue.main.async {
//                let call = CometChatIncomingCall()
//                call.modalPresentationStyle = .custom
//                call.setCall(call: currentCall)
//                self.present(call, animated: true, completion: nil)
//                }
//                if let call = incomingCall {
//                    CometChatCallManager.incomingCallDelegate?.onIncomingCallReceived(incomingCall: call, error: error)
//                }
//            }
//        }
//
//    /**
//    This method triggers when outgoing call accepted from User or group.
//     - Parameters:
//      - acceptedCall: Specifies a Call Object
//        - error:  triggers when error occurs
//    - Author: CometChat Team
//    - Copyright:  ©  2020 CometChat Inc.
//    */
//    public func onOutgoingCallAccepted(acceptedCall: Call?, error: CometChatException?) {
//
//        if let call = acceptedCall {
//            CometChatCallManager.outgoingCallDelegate?.onOutgoingCallAccepted(acceptedCall: call, error: error)
//        }
//    }
//
//    /**
//    This method triggers when ourgoing call rejected from User or group.
//     - Parameters:
//      - rejectedCall: Specifies a Call Object
//        - error:  triggers when error occurs
//    - Author: CometChat Team
//    - Copyright:  ©  2020 CometChat Inc.
//    */
//    public func onOutgoingCallRejected(rejectedCall: Call?, error: CometChatException?) {
//
//        if let call = rejectedCall {
//            CometChatCallManager.outgoingCallDelegate?.onOutgoingCallRejected(rejectedCall: call, error: error)
//        }
//    }
//
//    /**
//    This method triggers when incoming call cancelled from User or group.
//     - Parameters:
//      - rejectedCall: Specifies a Call Object
//        - error:  triggers when error occurs
//    - Author: CometChat Team
//    - Copyright:  ©  2020 CometChat Inc.
//    */
//    public func onIncomingCallCancelled(canceledCall: Call?, error: CometChatException?) {
//
//        if let call = canceledCall {
//            CometChatCallManager.incomingCallDelegate?.onIncomingCallCancelled(canceledCall: call, error: error)
//        }
//    }
//}
////
////
/////*  ----------------------------------------------------------------------------------------- */
