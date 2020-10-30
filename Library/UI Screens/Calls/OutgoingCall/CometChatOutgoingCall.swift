
//  CometChatOutgoingCall.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro
import  AVFoundation

/*  ----------------------------------------------------------------------------------------- */

@objc  public class CometChatOutgoingCall: UIViewController {
    
      // MARK: - Declaration of Outlets
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var endButton: UIButton!
    
     // MARK: - Declaration of Variables
    var currentUser: User?
    var currentGroup: Group?
    var currentCall: Call?
    var callSetting: CallSettings?
     // MARK: - View controller lifecycle methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        CometChatSoundManager().play(sound: .outgoingCall, bool: true)
         
    }
    
    public override func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatOutgoingCall", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            if let user = self.currentUser { self.setupAppearance(forEntity: user) }
            if let group = self.currentGroup { self.setupAppearance(forEntity: group) }
        }
        CometChatCallManager.outgoingCallDelegate = self
    }
    
    
    // MARK: - Public Instance methods
    
    
       /**
        This method makesCall to the particular user or group
        - Parameter group: This specifies `Group` Object.
        - Author: CometChat Team
        - Copyright:  ©  2020 CometChat Inc.
        */
    public func makeCall(call: CometChat.CallType , to: AppEntity) {
        if let user = (to as? User), let name = user.name {
            self.currentUser = user
            let call = Call(receiverId: user.uid ?? "", callType: call, receiverType: .user)
            CometChat.initiateCall(call: call, onSuccess: { (ongoingCall) in
                self.currentCall = ongoingCall
                
                DispatchQueue.main.async {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Calling \(name)", duration: .short)
                    snackbar.show()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                    }
                }
            }
        }
        if let group = (to as? Group) , let name = group.name {
            self.currentGroup = group
            let call = Call(receiverId: group.guid , callType: call, receiverType: .group)
            CometChat.initiateCall(call: call, onSuccess: { (ongoingCall) in
                self.currentCall = ongoingCall
                DispatchQueue.main.async {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Calling \(name)", duration: .short)
                    snackbar.show()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                    }
                }
            }
        }
    }
    
    
    /**
    This method setup Appearance for CometChatOutgoingCall.
    - Parameter forEntity: This specifies `AppEntity` Object.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    private func setupAppearance(forEntity: AppEntity){
        if let user = forEntity as? User { avatar.set(entity: user) }
        if let group = forEntity as? Group { avatar.set(entity: group) }
    }
    
    /**
       This method dismiss the CometChatOutgoingCall controller when triggers..
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       */
    private func dismiss(){
        CometChatSoundManager().play(sound: .outgoingCall, bool: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
    This method triggfers when user presses end call button in the CometChatOutgoingCall .
     /// - Parameter sender:  Sender specifies the user who pressed the button
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @IBAction func didEndButtonPressed(_ sender: Any) {
        if currentCall != nil {
            if let session = currentCall?.sessionID {
                CometChat.rejectCall(sessionID: session, status: .cancelled, onSuccess: {(cancelledCall) in
                    DispatchQueue.main.async {
                        self.dismiss()
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Ended.", duration: .short)
                        snackbar.show()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.dismiss()
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Ended.", duration: .short)
                        snackbar.show()
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                self.dismiss()
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Ended.", duration: .short)
                snackbar.show()
            }
        }
    }
}


/*  ----------------------------------------------------------------------------------------- */

// MARK: - OutgoingCallDelegate methods

extension CometChatOutgoingCall: OutgoingCallDelegate {
    
    
    /**
    This method triggers when outgoing call accepted from User or group.
     - Parameters:
      - acceptedCall: Specifies a Call Object
        - error:  triggers when error occurs
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    public func onOutgoingCallAccepted(acceptedCall: Call, error: CometChatException?) {
        CometChatSoundManager().play(sound: .outgoingCall, bool: false)
        if acceptedCall != nil {
            if let session = acceptedCall.sessionID {
                 DispatchQueue.main.async {
                    
                    if acceptedCall.receiverType == .user {
                        
                        self.callSetting = CallSettings.CallSettingsBuilder(callView: self.view, sessionId: session).setMode(mode: .MODE_SINGLE).build()
                    }else {
                        
                        self.callSetting = CallSettings.CallSettingsBuilder(callView: self.view, sessionId: session).build()
                    }
            
                    CometChat.startCall(callSettings: self.callSetting!) { (userJoined) in
                        DispatchQueue.main.async {
                            if let name = userJoined?.name {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "\(name) joined.", duration: .short)
                                snackbar.show()
                            }
                        }
                    } userLeft: { (userLeft) in
                        DispatchQueue.main.async {
                            if let name = userLeft?.name {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "\(name) left.", duration: .short)
                                snackbar.show()
                            }
                        }
                    } onError: { (error) in
                        DispatchQueue.main.async {
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Unable to start call.", duration: .short)
                            snackbar.show()
                        }
                    } callEnded: { (ended) in
                        DispatchQueue.main.async {
                            self.dismiss()
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Ended.", duration: .short)
                            snackbar.show()
                        }
                    }
                }
            }
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
    public func onOutgoingCallRejected(rejectedCall: Call, error: CometChatException?) {
        
        if rejectedCall != nil {
            if let session = rejectedCall.sessionID {
                CometChat.rejectCall(sessionID: session, status: .ended, onSuccess: {(cancelledCall) in
                    DispatchQueue.main.async {
                        self.dismiss()
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Rejected.", duration: .short)
                        snackbar.show()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.dismiss()
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Rejected.", duration: .short)
                        snackbar.show()
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                self.dismiss()
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Rejected.", duration: .short)
                snackbar.show()
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

