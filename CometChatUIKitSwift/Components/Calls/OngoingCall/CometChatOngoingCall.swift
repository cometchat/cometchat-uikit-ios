//
//  CometChatOngoingCall.swift
//  
//
//  Created by Pushpsen Airekar on 07/03/23.
//


#if canImport(CometChatCallsSDK)
import UIKit
import CometChatSDK
import CometChatCallsSDK

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
                self.dismiss(animated: true)
            }
        }
        viewModel.onError = {  _ in
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
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
    public func setOnCallEnded(onCallEnded: @escaping ((_ call: Call) -> Void)) -> Self {
        self.onCallEnded = onCallEnded
        return self
    }
}
#endif
