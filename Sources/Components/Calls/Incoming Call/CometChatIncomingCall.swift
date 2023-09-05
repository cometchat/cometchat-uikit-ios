//
//  CometChatOutgoingCall.swift
//
//
//  Created by Pushpsen Airekar on 08/03/23.
//

import UIKit
import CometChatSDK

#if canImport(CometChatCallsSDK)
public class CometChatIncomingCall: UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var declineButton: UIStackView!
    @IBOutlet weak var acceptButton: UIStackView!
    
    private (set) var call: Call?
    private (set) var user: User?
    private (set) var group: Group?
    private (set) var declineButtonText: String = "decline".localize()
    private (set) var declineButtonIcon: UIImage = UIImage(systemName: "xmark") ?? UIImage()
    private (set) var acceptButtonText: String = "accept".localize()
    private (set) var acceptButtonIcon: UIImage = UIImage(named: "voice-call", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    private (set) var fullscreenView: UIView?
    private (set) var acceptButtonStyle = ButtonStyle()
    private (set) var declineButtonStyle = ButtonStyle()
    private (set) var incomingCallStyle = IncomingCallStyle()
    private (set) var avatarStyle: AvatarStyle?
    private (set) var disableSoundForCalls: Bool = false
    private (set) var customSoundForCalls: URL?
    private (set) var onCancelClick: ((_ call: Call?, _ controller: UIViewController?) -> Void)?
    private (set) var onAcceptClick: ((_ call: Call?, _ controller: UIViewController?) -> Void)?
    private (set) var viewModel =  IncomingCallViewModel()
    
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setupAppearance()
        if !disableSoundForCalls {
            CometChatSoundManager().play(sound: .incomingCall, customSound: customSoundForCalls)
        }
        let ongoingCall = CometChatOngoingCall()
        ongoingCall.modalPresentationStyle = .fullScreen
        
        viewModel.onCallAccepted = { call in
            DispatchQueue.main.async {
                ongoingCall.set(sessionId: call.sessionID ?? "")
                let callSettingsBuilder = CallingDefaultBuilder.callSettingsBuilder
                callSettingsBuilder.setIsAudioOnly(call.callType == .audio)
                ongoingCall.set(callSettingsBuilder: callSettingsBuilder)
                ongoingCall.set(callWorkFlow: .defaultCalling)
                CometChatSoundManager().pause()
                weak var pvc = self.presentingViewController
                self.dismiss(animated: false, completion: {
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
        
        viewModel.onIncomingCallCancelled = { _ in
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
    
    open override func viewWillAppear(_ animated: Bool) {
        viewModel.connect()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        viewModel.disconnect()
    }
    
    private func setupAppearance() {
        if let user = call?.sender as? User {
            titleLabel.text = user.name?.capitalized
            titleLabel.textColor = incomingCallStyle.titleColor
            titleLabel.font = incomingCallStyle.titleFont
            avatar.setAvatar(avatarUrl: user.avatar, with: user.name)
        }
        
        if let group = group {
            titleLabel.text = group.name?.capitalized
            titleLabel.textColor = incomingCallStyle.titleColor
            titleLabel.font = incomingCallStyle.titleFont
            avatar.setAvatar(avatarUrl: group.icon, with: group.name)
        }
        
        if let user = user {
            titleLabel.text = user.name?.capitalized
            titleLabel.textColor = incomingCallStyle.titleColor
            titleLabel.font = incomingCallStyle.titleFont
            avatar.setAvatar(avatarUrl: user.avatar, with: user.name)
        }
        
        if let avatarStyle = avatarStyle {
            avatar.set(backgroundColor: avatarStyle.background)
            avatar.set(font: avatarStyle.textFont)
            avatar.set(fontColor: avatarStyle.textColor)
            avatar.set(borderColor: avatarStyle.borderColor)
            avatar.set(borderWidth: avatarStyle.borderWidth)
            avatar.set(cornerRadius: avatarStyle.cornerRadius)
        }
        
        if let call = call {
            subtitle.text = viewModel.getSubtitle(call: call)
            subtitle.textColor = incomingCallStyle.subtitleColor
            subtitle.font = incomingCallStyle.subtitleFont
        }
        
        let rejectButton = CometChatButton(width: 200, height:200)
        rejectButton.set(icon: declineButtonIcon)
        rejectButton.set(text: declineButtonText)
        declineButtonStyle.set(iconBackground: CometChatTheme.palatte.error)
            .set(iconTint: .white)
            .set(textColor: CometChatTheme.palatte.accent700)
            .set(textFont: CometChatTheme.typography.caption1)
            .set(iconCornerRadius: 30)
        rejectButton.set(style: declineButtonStyle)
        self.declineButton.addArrangedSubview(rejectButton)

        rejectButton.setOnClick {
            self.onCancelClick?(self.call, self)
            if let call = self.call {
                self.viewModel.rejectCall(call: call)
            }
        }

        let acceptButton = CometChatButton(width: 200, height:200)
        acceptButton.set(icon: acceptButtonIcon)
        acceptButton.set(text: acceptButtonText)
        acceptButtonStyle.set(iconBackground: CometChatTheme.palatte.primary)
            .set(iconTint: .white)
            .set(textColor: CometChatTheme.palatte.accent700)
            .set(textFont: CometChatTheme.typography.caption1)
            .set(iconCornerRadius: 30)
        acceptButton.set(style: acceptButtonStyle)
        self.acceptButton.addArrangedSubview(acceptButton)
        
        acceptButton.setOnClick {
            self.onAcceptClick?(self.call, self)
            if let call = self.call {
                self.viewModel.acceptCall(call: call)
            }
        }
    }
}

extension CometChatIncomingCall {
    
    @discardableResult
    public func set(user: User) -> Self {
        self.user = user
        return self
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        self.group = group
        return self
    }
    
    @discardableResult
    public func set(call: Call) -> Self {
        self.call = call
        return self
    }
    
    @discardableResult
    public func set(acceptButtonIcon: UIImage) -> Self {
        self.acceptButtonIcon = acceptButtonIcon
        return self
    }
    
    @discardableResult
    public func set(declineButtonIcon: UIImage) -> Self {
        self.declineButtonIcon = declineButtonIcon
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
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(acceptButtonStyle: ButtonStyle) -> Self {
        self.acceptButtonStyle = acceptButtonStyle
        return self
    }
    
    @discardableResult
    public func set(declineButtonStyle: ButtonStyle) -> Self {
        self.declineButtonStyle = declineButtonStyle
        return self
    }
    
    @discardableResult
    public func set(incomingCallStyle: IncomingCallStyle) -> Self {
        self.incomingCallStyle = incomingCallStyle
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
}
#endif
