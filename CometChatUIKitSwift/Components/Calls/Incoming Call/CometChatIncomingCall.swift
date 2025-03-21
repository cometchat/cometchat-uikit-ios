//
//  CometChatOutgoingCall.swift
//
//
//  Created by Pushpsen Airekar on 08/03/23.
//

#if canImport(CometChatCallsSDK)

import UIKit
import CometChatSDK

public class CometChatIncomingCall: UIViewController {
    
    public lazy var containerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.pin(anchors: [.height], to: 90)
        return view
    }()
    
    public lazy var titleContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    public lazy var subtitleContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    public lazy var trailingView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .clear
        return view
    }()
    
    public lazy var leadingContainerView: UIView = {
        let view = UIView().withoutAutoresizingMaskConstraints()
        view.backgroundColor = .clear
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
    
    var callSettingsBuilder: CallSettingsBuilder?
    public var disableSoundForCalls = false
    public var customSoundForCalls: URL?
    var viewModel = IncomingCallViewModel()
    var onCancelClick: ((_ call: Call?, _ controller: UIViewController?) -> Void)?
    var onAcceptClick: ((_ call: Call?, _ controller: UIViewController?) -> Void)?
    
    var listItemView: ((_ call: Call) -> UIView)?
    var trailView: ((_ call: Call) -> UIView)?
    var titleView: ((_ call: Call) -> UIView)?
    var subtitleView: ((_ call: Call) -> UIView)?
    var leadingView: ((_ call: Call) -> UIView)?
    var onError: ((_ error: CometChatException) -> Void)?

    
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
        
        viewModel.onError = { error in
            CometChatSoundManager().pause()
            DispatchQueue.main.async {
                self.onError?(error)
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
        
        containerView.addSubview(leadingContainerView)
        leadingContainerView.embed(avatar)
        
        constraintsToActive += [
            leadingContainerView.centerYAnchor.pin(equalTo: containerView.centerYAnchor),
            leadingContainerView.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: CometChatSpacing.Margin.m5),
        ]
        
        constraintsToActive += [
            avatar.centerYAnchor.pin(equalTo: leadingContainerView.centerYAnchor),
            avatar.centerXAnchor.pin(equalTo: leadingContainerView.centerXAnchor)
        ]
        
        containerView.addSubview(subtitleContainerView)
        subtitleContainerView.embed(callLabel)
        
        constraintsToActive += [
            subtitleContainerView.leadingAnchor.pin(equalTo: leadingContainerView.trailingAnchor, constant: CometChatSpacing.Padding.p3),
            subtitleContainerView.topAnchor.pin(equalTo: leadingContainerView.topAnchor)
        ]
        
        containerView.addSubview(titleContainerView)
        titleContainerView.embed(nameLabel)
        
        constraintsToActive += [
            titleContainerView.leadingAnchor.pin(equalTo: leadingContainerView.trailingAnchor, constant: CometChatSpacing.Padding.p3),
            titleContainerView.bottomAnchor.pin(equalTo: leadingContainerView.bottomAnchor)
        ]
        
        
        containerView.addSubview(trailingView)
        constraintsToActive += [
            trailingView.trailingAnchor.pin(equalTo: containerView.trailingAnchor, constant: 0),
            trailingView.centerYAnchor.pin(equalTo: trailingView.centerYAnchor),
            trailingView.leadingAnchor.pin(equalTo: titleContainerView.leadingAnchor, constant: CometChatSpacing.Padding.p3),
            trailingView.topAnchor.pin(equalTo: containerView.topAnchor, constant: 0),
            trailingView.bottomAnchor.pin(equalTo: containerView.bottomAnchor, constant: 0)
        ]
        
        trailingView.addSubview(acceptButton)
        constraintsToActive += [
            acceptButton.trailingAnchor.pin(equalTo: trailingView.trailingAnchor, constant: -CometChatSpacing.Margin.m5),
            acceptButton.centerYAnchor.pin(equalTo: trailingView.centerYAnchor)
        ]
        
        trailingView.addSubview(declineButton)
        constraintsToActive += [
            declineButton.trailingAnchor.pin(equalTo: acceptButton.leadingAnchor, constant: -CometChatSpacing.Padding.p3),
            declineButton.centerYAnchor.pin(equalTo: trailingView.centerYAnchor),
            declineButton.leadingAnchor.pin(equalTo: nameLabel.trailingAnchor)
        ]
        
        NSLayoutConstraint.activate(constraintsToActive)
        
        
        if let call = viewModel.call, let leadingView = leadingView?(call){
            leadingContainerView.subviews.forEach({$0.removeFromSuperview()})
            leadingContainerView.pin(anchors: [.width, .height], to: 60)
            leadingContainerView.embed(leadingView)
        }
        if let call = viewModel.call, let trailView = trailView?(call){
            trailingView.subviews.forEach({$0.removeFromSuperview()})
            trailingView.embed(trailView)
        }
        if let call = viewModel.call, let titleView = titleView?(call){
            titleContainerView.subviews.forEach({$0.removeFromSuperview()})
            titleContainerView.embed(titleView)
        }
        if let call = viewModel.call, let subtitleView = subtitleView?(call){
            subtitleContainerView.subviews.forEach({$0.removeFromSuperview()})
            subtitleContainerView.embed(subtitleView)
        }
        if let call = viewModel.call, let listItemView = listItemView?(call){
            containerView.subviews.forEach({$0.removeFromSuperview()})
            containerView.embed(listItemView)
        }
        
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
            self.dismiss(animated: true) {
                onAcceptClick(self.viewModel.call, self)
            }
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

#endif
