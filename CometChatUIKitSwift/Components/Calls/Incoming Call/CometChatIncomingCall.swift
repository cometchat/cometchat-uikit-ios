//
//  CometChatOutgoingCall.swift
//
//
//  Created by Pushpsen Airekar on 08/03/23.
//

#if canImport(CometChatCallsSDK)

import UIKit
import CometChatSDK
import CometChatCallsSDK

public class CometChatIncomingCall: UIViewController {
    
    public lazy var containerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.pin(anchors: [.height], to: 90)
        return view
    }()
    
    public lazy var nameLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()
    
    public lazy var callLabel: UILabel = {
        let label = UILabel().withoutAutoresizingMaskConstraints()
        return label
    }()
    
    public lazy var avatar: CometChatAvatar = {
        let avatar = CometChatAvatar(image: nil).withoutAutoresizingMaskConstraints()
        avatar.style = avatarStyle
        avatar.pin(anchors: [.height, .width], to: 48)
        return avatar
    }()
    
    public lazy var acceptButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(onAcceptButtonTapped), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 48)
        button.roundViewCorners(corner: .init(cornerRadius: 24))
        return button
    }()
    
    public lazy var declineButton: UIButton = {
        let button = UIButton().withoutAutoresizingMaskConstraints()
        button.addTarget(self, action: #selector(onRejectButtonTapped), for: .primaryActionTriggered)
        button.pin(anchors: [.height, .width], to: 48)
        button.roundViewCorners(corner: .init(cornerRadius: 24))
        return button
    }()
    
    public static var style = IncomingCallStyle()
    public static var avatarStyle = CometChatAvatar.style
    public lazy var style = CometChatIncomingCall.style
    public lazy var avatarStyle = CometChatIncomingCall.avatarStyle
    
    public var callSettingsBuilder: CallSettingsBuilder?
    public var disableSoundForCalls = false
    public var customSoundForCalls: URL?
    var viewModel = IncomingCallViewModel()
    public var onCancelClick: ((_ call: Call?, _ controller: UIViewController?) -> Void)?
    public var onAcceptClick: ((_ call: Call?, _ controller: UIViewController?) -> Void)?

    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if !disableSoundForCalls {
            CometChatSoundManager().play(sound: .incomingCall, customSound: customSoundForCalls)
        }
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        setupViewModel()
        buildUI()
        setupData()
        setupStyle()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        viewModel.connect()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        viewModel.disconnect()
    }
    
    func setupViewModel() {
                
        viewModel.onCallAccepted = { [weak self] call in
            DispatchQueue.main.async {
                guard let this = self else { return }
                let ongoingCall = CometChatOngoingCall()
                ongoingCall.modalPresentationStyle = .fullScreen
                ongoingCall.set(sessionId: call.sessionID ?? "")
                
                let callSettingsBuilder = this.callSettingsBuilder ?? CometChatCallsSDK.CallSettingsBuilder()
                    .setIsAudioOnly(call.callType == .audio)
                    .setDefaultAudioMode(call.callType == .audio ? "EARPIECE" : "SPEAKER")
                
                ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
                ongoingCall.set(callWorkFlow: .defaultCalling)
                CometChatSoundManager().pause()
                weak var pvc = this.presentingViewController
                this.dismiss(animated: false, completion: {
                    pvc?.present(ongoingCall, animated: false, completion: nil)
                })
            }
        }
        
        viewModel.onCallRejected = { call in
            CometChatSoundManager().pause()
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
        viewModel.onError = { _ in
            CometChatSoundManager().pause()
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
        viewModel.dismissIncomingCallView = { _ in
            CometChatSoundManager().pause()
            DispatchQueue.main.async {
                self.dismiss(animated: true)
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 45) {
            CometChatSoundManager().pause()
            self.dismiss(animated:true, completion: nil)
        }
    }
    
    open func buildUI() {
        
        var constraintsToActive = [NSLayoutConstraint]()
        
        view.addSubview(containerView)
        constraintsToActive += [
            containerView.topAnchor.pin(equalTo: view.safeAreaLayoutGuide.topAnchor),
            containerView.leadingAnchor.pin(equalTo: view.leadingAnchor, constant: 8),
            containerView.trailingAnchor.pin(equalTo: view.trailingAnchor, constant: -8),
        ]
        
        containerView.addSubview(avatar)
        constraintsToActive += [
            avatar.centerYAnchor.pin(equalTo: containerView.centerYAnchor),
            avatar.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: CometChatSpacing.Margin.m5),
        ]
        
        containerView.addSubview(callLabel)
        constraintsToActive += [
            callLabel.leadingAnchor.pin(equalTo: avatar.trailingAnchor, constant: CometChatSpacing.Padding.p3),
            callLabel.topAnchor.pin(equalTo: avatar.topAnchor)
        ]
        
        containerView.addSubview(nameLabel)
        constraintsToActive += [
            nameLabel.leadingAnchor.pin(equalTo: avatar.trailingAnchor, constant: CometChatSpacing.Padding.p3),
            nameLabel.bottomAnchor.pin(equalTo: avatar.bottomAnchor)
        ]
        
        containerView.addSubview(acceptButton)
        constraintsToActive += [
            acceptButton.trailingAnchor.pin(equalTo: containerView.trailingAnchor, constant: -CometChatSpacing.Margin.m5),
            acceptButton.centerYAnchor.pin(equalTo: containerView.centerYAnchor)
        ]
        
        containerView.addSubview(declineButton)
        constraintsToActive += [
            declineButton.trailingAnchor.pin(equalTo: acceptButton.leadingAnchor, constant: -CometChatSpacing.Padding.p3),
            declineButton.centerYAnchor.pin(equalTo: containerView.centerYAnchor),
            declineButton.leadingAnchor.pin(equalTo: nameLabel.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraintsToActive)
    }
    
    open func setupData() {
        if let callByUser = (viewModel.call?.sender as? User) {
            avatar.setAvatar(avatarUrl: callByUser.avatar, with: callByUser.name)
            nameLabel.text = callByUser.name
            callLabel.text = viewModel.call?.callType == .audio ?  "Voice Call" : "Video Call"
        }
    }
    
    open func setupStyle() {
        view.backgroundColor = style.overlayBackgroundColor
        
        containerView.backgroundColor = style.backgroundColor
        containerView.borderWith(width: style.borderWidth)
        containerView.borderColor(color: style.borderColor)
        containerView.roundViewCorners(corner: style.cornerRadius ?? .init(cornerRadius: 45))
        
        acceptButton.backgroundColor = style.acceptButtonBackgroundColor
        declineButton.backgroundColor = style.rejectButtonBackgroundColor
        acceptButton.tintColor = style.acceptButtonTintColor
        declineButton.tintColor = style.rejectButtonTintColor
        acceptButton.setImage(style.acceptButtonImage, for: .normal)
        declineButton.setImage(style.rejectButtonImage, for: .normal)
        if let acceptButtonCornerRadius = style.acceptButtonCornerRadius{
            acceptButton.roundViewCorners(corner: acceptButtonCornerRadius)
        }
        if let declineButtonCornerRadius = style.rejectButtonCornerRadius{
            declineButton.roundViewCorners(corner: declineButtonCornerRadius)
        }
        acceptButton.borderWith(width: style.acceptButtonBorderWidth)
        declineButton.borderWith(width: style.rejectButtonBorderWidth)
        acceptButton.borderColor(color: style.acceptButtonBorderColor)
        declineButton.borderColor(color: style.rejectButtonBorderColor)
        
        nameLabel.font = style.nameLabelFont
        nameLabel.textColor = style.nameLabelColor
        
        callLabel.font = style.callLabelFont
        callLabel.textColor = style.callLabelColor
        
        containerView.backgroundColor = style.backgroundColor
        containerView.borderWith(width: style.borderWidth)
        containerView.borderColor(color: style.borderColor)
    }
    
    @objc open func onAcceptButtonTapped() {
        if let onAcceptClick = onAcceptClick {
            onAcceptClick(viewModel.call, self)
        } else if let call = viewModel.call {
            viewModel.acceptCall(call: call)
        }
    }
    
    @objc open func onRejectButtonTapped() {
        if let onCancelClick = onCancelClick {
            onCancelClick(viewModel.call, self)
        } else if let call = viewModel.call {
            viewModel.rejectCall(call: call)
        }
    }
}

extension CometChatIncomingCall {
    
    @discardableResult
    public func set(call: Call) -> Self {
        self.viewModel.call = call
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
    
    @discardableResult
    public func setOnAcceptClick(onAcceptClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
        self.onAcceptClick = onAcceptClick
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
