//
//  CometChatOutgoingCall.swift
//  
//
//  Created by Pushpsen Airekar on 08/03/23.
//

import UIKit
import CometChatSDK

#if canImport(CometChatCallsSDK)
import CometChatCallsSDK

@MainActor
open class CometChatOutgoingCall: UIViewController {

    public lazy var avatarView: CometChatAvatar = {
        let avatarView = CometChatAvatar(frame: .zero).withoutAutoresizingMaskConstraints()
        avatarView.pin(anchors: [.height, .width], to: 120)
        avatarView.setAvatar(avatarUrl: (call?.receiver as? User)?.avatar, with: (call?.receiver as? User)?.name)
        return avatarView
    }()
    
    public lazy var nameLabel: UILabel = {
        let nameLabel = UILabel().withoutAutoresizingMaskConstraints()
        nameLabel.textAlignment = .center
        nameLabel.text = user?.name ?? ""
        nameLabel.text = (call?.receiver as? User)?.name ?? ""
        return nameLabel
    }()
    
    public lazy var callingLabel: UILabel = {
        let callingLabel = UILabel().withoutAutoresizingMaskConstraints()
        callingLabel.textAlignment = .center
        callingLabel.text = "Calling"
        return callingLabel
    }()
    
    public lazy var declineButton: UIButton = {
        let declineButton = UIButton().withoutAutoresizingMaskConstraints()
        declineButton.pin(anchors: [.height, .width], to: 54)
        declineButton.roundViewCorners(corner: .init(cornerRadius: 27))
        declineButton.addTarget(self, action: #selector(onDeclineButtonTapped), for: .primaryActionTriggered)
        return declineButton
    }()
    
    public lazy var containerView: UIView = {
        let containerView = UIView().withoutAutoresizingMaskConstraints()
        return containerView
    }()
    
    public static var style = OutgoingCallStyle()
    public static var avatarStyle = CometChatAvatar.style
    public var avatarStyle = CometChatOutgoingCall.avatarStyle
    public var style = CometChatOutgoingCall.style
        
    private(set) var call: Call?
    private(set) var user: User?
    private(set) var declineButtonText: String = "CANCEL".localize()
    private(set) var declineButtonIcon: UIImage = UIImage(systemName: "xmark") ?? UIImage()
    private(set) var disableSoundForCalls: Bool = false
    private(set) var customSoundForCalls: URL?
    private(set) var fullscreenView: UIView?
    private(set) var buttonStyle = ButtonStyle()
    private(set) var outgoingCallStyle = OutgoingCallStyle()
    private(set) var onCancelClick: ((_ call: Call?, _ controller: UIViewController?) -> Void)?
    private(set) var viewModel =  OutgoingCallViewModel()
    private(set) var callSettingsBuilder: CallSettingsBuilder?
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        if !disableSoundForCalls {
            CometChatSoundManager().play(sound: .outgoingCall, customSound: customSoundForCalls)
        }
         
        let ongoingCall = CometChatOngoingCall()
        let callSettingsBuilder = callSettingsBuilder ?? CometChatCallsSDK.CallSettingsBuilder()
            .setDefaultAudioMode(call?.callType == .audio ? "EARPIECE" : "SPEAKER")
            .setIsAudioOnly(call?.callType == .audio)
        ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
        ongoingCall.modalPresentationStyle = .fullScreen

        viewModel.onOutgoingCallAccepted = { call in
            DispatchQueue.main.async {
                ongoingCall.set(sessionId: call.sessionID ?? "")
                ongoingCall.set(callWorkFlow: .defaultCalling)
                CometChatSoundManager().pause()
                weak var pvc = self.presentingViewController
                self.dismiss(animated: false, completion: {
                    pvc?.present(ongoingCall, animated: false, completion: nil)
                })
            }
        }
        
        viewModel.onError = { _ in
            DispatchQueue.main.async {
                CometChatSoundManager().pause()
                self.dismiss(animated: true)
            }
        }
        
        viewModel.onOutgoingCallRejected = { call in
            DispatchQueue.main.async {
                CometChatSoundManager().pause()
                self.dismiss(animated: true)
            }
        }
        
        buildUI()
        setupStyle()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        viewModel.connect()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        viewModel.disconnect()
    }
    
    open func buildUI() {
        
        var constraintsToActive = [NSLayoutConstraint]()
        
        view.addSubview(nameLabel)
        constraintsToActive += [
            nameLabel.centerXAnchor.pin(equalTo: view.centerXAnchor),
            nameLabel.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80)
        ]
        
        view.addSubview(callingLabel)
        constraintsToActive += [
            callingLabel.centerXAnchor.pin(equalTo: nameLabel.centerXAnchor),
            callingLabel.topAnchor.pin(equalTo: nameLabel.bottomAnchor, constant: 5)
        ]
        
        view.addSubview(avatarView)
        constraintsToActive += [
            avatarView.topAnchor.pin(equalTo: callingLabel.bottomAnchor, constant: CometChatSpacing.Margin.m10),
            avatarView.centerXAnchor.pin(equalTo: nameLabel.centerXAnchor)
        ]
        
        view.addSubview(declineButton)
        constraintsToActive += [
            declineButton.centerXAnchor.pin(equalTo: view.centerXAnchor),
            declineButton.bottomAnchor.pin(equalTo: view.bottomAnchor, constant: -80),
        ]
        
        NSLayoutConstraint.activate(constraintsToActive)
        
    }
    
    open func setupStyle() {
        view.backgroundColor = style.backgroundColor
        view.roundViewCorners(corner: style.cornerRadius)
        view.borderWith(width: style.borderWidth)
        view.borderColor(color: style.borderColor)
        nameLabel.textColor = style.nameTextColor
        nameLabel.font = style.nameTextFont
        callingLabel.textColor = style.callTextColor
        callingLabel.font = style.callTextFont
        declineButton.setImage(style.declineButtonIcon, for: .normal)
        declineButton.backgroundColor = style.declineButtonBackgroundColor
        declineButton.tintColor = style.declineButtonIconTint
        if let radius = style.declineButtonCornerRadius{
            declineButton.roundViewCorners(corner: radius)
        }
        declineButton.borderWith(width: style.declineButtonBorderWidth)
        declineButton.borderColor(color: style.declineButtonBorderColor)
        avatarView.style = avatarStyle
    }
    
    @objc open func onDeclineButtonTapped() {
        self.dismiss(animated: true)
        if !disableSoundForCalls {
            CometChatSoundManager().pause()
        }
        if let sessionID = call?.sessionID {
            CometChat.rejectCall(sessionID: sessionID, status: .cancelled) { call in
                if let call = call {
                    CometChatCallEvents.ccCallRejected(call: call)
                }
                print("Call Cancelled Success")
            } onError: { error in
                print("Call Cancelled Error: \(String(describing: error?.errorDescription))")
            }

        }
    }
}

extension CometChatOutgoingCall {
    
    @discardableResult
    public func set(user: User) -> Self {
        self.user = user
        return self
    }
    
    @discardableResult
    public func set(call: Call) -> Self {
        self.call = call
        return self
    }
    
    @discardableResult
    public func disable(soundForCalls: Bool) -> Self {
        self.disableSoundForCalls = soundForCalls
        return self
    }
    
    @discardableResult
    public func set(customSoundForCalls: URL?) -> Self {
        self.customSoundForCalls = customSoundForCalls
        return self
    }
    
    @discardableResult
    public func setOnCancelClick(onCancelClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
        self.onCancelClick = onCancelClick
        return self
    }
    
    /// Configures the outgoing call settings using a custom CallSettingsBuilder.
    /// This property applies the specified custom CallSettingsBuilder to all outgoing calls.
    /// - Parameter callSettingBuilder: An instance of a custom CallSettingsBuilder. The object must conform to the CallSettingsBuilder type.
    /// - Returns: The current instance of OutgoingCallConfiguration for declarative coding, allowing further method chaining.
    /// - Note: Ensure that the provided callSettingBuilder is of type CallSettingsBuilder, otherwise it will be ignored.
    @discardableResult public func set(callSettingsBuilder: Any) -> Self {
        if let callSettingsBuilder = callSettingsBuilder as? CallSettingsBuilder {
            self.callSettingsBuilder = callSettingsBuilder
        }
        return self
    }
}
#endif
