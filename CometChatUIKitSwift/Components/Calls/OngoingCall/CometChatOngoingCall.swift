//
//  CometChatOngoingCall.swift
//  
//
//  Created by Pushpsen Airekar on 07/03/23.
//


#if canImport(CometChatCallsSDK)
import UIKit
import CometChatSDK

public enum CallWorkFlow {
    case defaultCalling
    case directCalling
}

open class CometChatOngoingCall: UIViewController {
    
    public lazy var containerView: UIView = {
        let containerView = UIView().withoutAutoresizingMaskConstraints()
        containerView.backgroundColor = CometChatTheme.backgroundColor03
        return containerView
    }()
    
    var viewModel : OngoingCallViewModel?
    var onCallEnded: ((_ call: Call) -> Void)?
    var sessionId: String?
    /// The call this screen is showing, handed to `onCallEnded` when it ends.
    var call: Call?
    private var callSettingsBuilder: Any?
    private var callWorkFlow: CallWorkFlow?
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        buildUI()
        startCall()
    }
    
    open func buildUI() {
        view.embed(containerView)
    }
    
    private func handleCall() {
        
        guard let viewModel = viewModel else { return }
        viewModel.onCallEnded = {
            DispatchQueue.main.async {
                self.onCallEnded?(self.endedCall())
                self.dismiss(animated: true)
            }
        }
        viewModel.onError = {  _ in
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
    }
    
    /// The call to report as ended: the one handed to this screen, or — for a session
    /// started without one, such as a group meeting — a call carrying the session id.
    private func endedCall() -> Call {
        if let call = call {
            return call
        }
        let call = Call(receiverId: "", callType: .audio, receiverType: .user)
        call.sessionID = sessionId
        call.callStatus = .ended
        return call
    }

    private func startCall() {
        guard let sessionId = sessionId else { return }
        viewModel = OngoingCallViewModel(callView: containerView, sessionId: sessionId)
        if let callWorkFlow = callWorkFlow {
            viewModel?.set(callWorkFlow: callWorkFlow)
        }
        if let callSettingsBuilder = callSettingsBuilder as? CometChatCallsSDK.CallSettingsBuilder {
            viewModel?.set(callSettingsBuilder: callSettingsBuilder)
        } else {
            viewModel?.set(callSettingsBuilder: CallingDefaultBuilder.callSettingsBuilder as! CallSettingsBuilder)
        }
        handleCall()
        viewModel?.startCall()
    }
}

extension CometChatOngoingCall {
    
    @discardableResult
    public func set(sessionId: String) -> Self {
        self.sessionId = sessionId
        return self
    }
    
    @discardableResult
    public func set(callSettingsBuilder: Any?) -> Self {
        self.callSettingsBuilder = callSettingsBuilder
        return self
    }
    
    @discardableResult
    public func set(callWorkFlow: CallWorkFlow) -> Self {
        self.callWorkFlow = callWorkFlow
        return self
    }
    
    @discardableResult
    public func set(call: Call) -> Self {
        self.call = call
        return self
    }

    @discardableResult
    public func setOnCallEnded(onCallEnded: @escaping ((_ call: Call) -> Void)) -> Self {
        self.onCallEnded = onCallEnded
        return self
    }
}
#endif
