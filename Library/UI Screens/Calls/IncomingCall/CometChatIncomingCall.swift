
//  CometChatIncomingCall.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

public class CometChatIncomingCall: UIViewController {
    
     // MARK: - Declaration of Outlets
    
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var callStatus: UILabel!
    @IBOutlet weak var callStatusIcon: UIImageView!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var incomingCallView: UIView!
    @IBOutlet weak var declineButton: UIButton!
    @IBOutlet weak var acceptButton: UIButton!
    
    // MARK: - Declaration of Variables
    
    var currentCall: Call?
    var callSetting: CallSettings?
    
    // MARK: - View controller lifecycle methods
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        if let call = currentCall {
            setupAppearance(forCall: call)
        }
    }
    
    public override func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatIncomingCall", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        CometChatCallManager.incomingCallDelegate = self
    }
    
     // MARK: - Public Instance methods
    
    /**
    This method sets' call Object to start call.
    - Parameter group: This specifies `Group` Object.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @objc public func setCall(call: Call){
        currentCall = call
    }
    
    // MARK: - Private Instance methods
    
    /**
       This method setup Appearance for CometChatIncomingCall.
       - Parameter forEntity: This specifies `AppEntity` Object.
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       */
    private func setupAppearance(forCall: Call?) {
        CometChatSoundManager().play(sound: .incomingCall, bool: true)
        DispatchQueue.main.async {
            self.incomingCallView.dropShadow()
        if let call = forCall {
            switch call.receiverType {
            case .user where call.callType == .audio:
                if let user = call.callInitiator as? User {
                    self.set(name: user.name?.capitalized ?? "", avatarURL: user.avatar ?? "", callStatus: "Incoming Audio Call", callStatusIcon: UIImage(named: "incomingAudio", in: UIKitSettings.bundle, compatibleWith: nil)!)
                }
            case .user where call.callType == .video:
                if let user = call.callInitiator as? User {
                    self.set(name: user.name?.capitalized ?? "", avatarURL: user.avatar ?? "", callStatus: "Incoming Video Call", callStatusIcon: UIImage(named: "incomingVideo", in: UIKitSettings.bundle, compatibleWith: nil)!)
                }
            case .group where call.callType == .audio:
                if let group = call.callReceiver as? Group {
                    self.set(name: group.name?.capitalized ?? "", avatarURL: group.icon ?? "", callStatus: "Incoming Audio Call", callStatusIcon: UIImage(named: "incomingAudio", in: UIKitSettings.bundle, compatibleWith: nil)!)
                }
            case .group where call.callType == .video:
                if let group = call.callReceiver as? Group {
                    self.set(name: group.name?.capitalized ?? "", avatarURL: group.icon ?? "", callStatus: "Incoming Video Call", callStatusIcon: UIImage(named: "incomingVideo", in: UIKitSettings.bundle, compatibleWith: nil)!)
                }
            case .user:  break
            case .group: break
            @unknown default:
                break
            }
        }
    }
    }
    
    /**
    This method dismiss the CometChatIncomingCall controller when triggers..
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    private func dismiss(){
        CometChatSoundManager().play(sound: .incomingCall, bool: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    /**
    This method dismiss the CometChatIncomingCall controller when triggers..
      - Parameters:
        - name: name of the user or group
        - avatarURL: avatar of the user or group
       - callStatus: type of call for  user or group
       - callStatusIcon: icon for the type of call for  user or group
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    fileprivate func set(name: String, avatarURL: String, callStatus: String, callStatusIcon: UIImage){
        self.name.text = name
        self.avatar.set(image: avatarURL, with: name)
        self.callStatus.text = callStatus
        self.callStatusIcon.image = callStatusIcon
    }
    
    /**
    This method triggers when user pressed accept button in  CometChatIncomingCall Screen.
      - Parameter sender: specifies the user who pressed the button
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    @IBAction func didAcceptButtonPressed(_ sender: Any) {
        if let call = currentCall  {
            CometChatSoundManager().play(sound: .incomingCall, bool: false)
            CometChat.acceptCall(sessionID: call.sessionID ?? "", onSuccess: { (acceptedCall) in
                if acceptedCall != nil {
                    
                    DispatchQueue.main.async {
                        
                        if acceptedCall?.receiverType == .user {
                            
                            self.callSetting = CallSettings.CallSettingsBuilder(callView: self.view, sessionId: call.sessionID ?? "").setMode(mode: .MODE_SINGLE).build()
                        }else {
                            
                            self.callSetting = CallSettings.CallSettingsBuilder(callView: self.view, sessionId: call.sessionID ?? "").build()
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
                        } callEnded: { (callEnded) in
                            DispatchQueue.main.async {
                                self.dismiss()
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Ended.", duration: .short)
                                snackbar.show()
                            }
                        }
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Unable to accept call.", duration: .short)
                    snackbar.show()
                }
            }
        }
    }
    
    /**
      This method triggfers when user presses decline button in the CometChatIncomingCall .
       /// - Parameter sender:  Sender specifies the user who pressed the button
      - Author: CometChat Team
      - Copyright:  ©  2020 CometChat Inc.
      */
    @IBAction func didDeclineButtonPressed(_ sender: Any) {
        if currentCall != nil {
            if let session = currentCall?.sessionID {
                CometChat.rejectCall(sessionID: session, status: .rejected, onSuccess: {(rejectedCall) in
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

// MARK: - IncomingCallDelegate methods

extension CometChatIncomingCall: IncomingCallDelegate {
    
    /**
    This method triggers when incoming call received from Server.
     - Parameters:
      - incomingCall: Specifies a Call Object
        - error:  triggers when error occurs
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
    */
    public func onIncomingCallReceived(incomingCall: Call, error: CometChatException?) {
        self.setupAppearance(forCall: incomingCall)
    }
    
    /**
       This method triggers when incoming call cancelled from User or group.
        - Parameters:
         - rejectedCall: Specifies a Call Object
           - error:  triggers when error occurs
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       */
    public func onIncomingCallCancelled(canceledCall: Call, error: CometChatException?) {
        if canceledCall != nil {
            if let session = canceledCall.sessionID {
                CometChat.rejectCall(sessionID: session, status: .cancelled, onSuccess: {(cancelledCall) in
                    DispatchQueue.main.async {
                        self.dismiss()
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Cancelled.", duration: .short)
                        snackbar.show()
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        self.dismiss()
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Cancelled.", duration: .short)
                        snackbar.show()
                    }
                }
            }
        }else{
            DispatchQueue.main.async {
                self.dismiss()
                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Call Cancelled.", duration: .short)
                snackbar.show()
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */
