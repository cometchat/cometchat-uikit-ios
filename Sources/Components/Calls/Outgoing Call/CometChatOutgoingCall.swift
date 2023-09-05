//
//  CometChatOutgoingCall.swift
//  
//
//  Created by Pushpsen Airekar on 08/03/23.
//

import UIKit
import CometChatSDK

#if canImport(CometChatCallsSDK)
@MainActor
open class CometChatOutgoingCall: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var button: UIStackView!
    
    private (set) var call: Call?
    private (set) var user: User?
    private (set) var declineButtonText: String = "CANCEL".localize()
    private (set) var declineButtonIcon: UIImage = UIImage(systemName: "xmark") ?? UIImage()
    private (set) var disableSoundForCalls: Bool = false
    private (set) var customSoundForCalls: URL?
    private (set) var fullscreenView: UIView?
    private (set) var avatarStyle: AvatarStyle?
    private (set) var buttonStyle = ButtonStyle()
    private (set) var outgoingCallStyle = OutgoingCallStyle()
    private (set) var onCancelClick: ((_ call: Call?, _ controller: UIViewController?) -> Void)?
    private (set) var viewModel =  OutgoingCallViewModel()
    
    public override func loadView() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            self.view  = contentView
        }
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()

        if !disableSoundForCalls {
            CometChatSoundManager().play(sound: .outgoingCall, customSound: customSoundForCalls)
        }
        setupAppearance()
         
        let ongoingCall = CometChatOngoingCall()
        let callSettingsBuilder = CallingDefaultBuilder.callSettingsBuilder
        callSettingsBuilder.setIsAudioOnly(call?.callType == .audio)
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
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        viewModel.connect()
    }
    
    open override func viewWillDisappear(_ animated: Bool) {
        viewModel.disconnect()
    }

    private func setupAppearance() {
        
        if let user = call?.callReceiver as? User {
            titleLabel.text = user.name?.capitalized
            titleLabel.textColor = outgoingCallStyle.titleColor
            titleLabel.font = outgoingCallStyle.titleFont
            avatar.setAvatar(avatarUrl: user.avatar, with: user.name)
        }
        
        if let user = user {
            titleLabel.text = user.name?.capitalized
            titleLabel.textColor = outgoingCallStyle.titleColor
            titleLabel.font = outgoingCallStyle.titleFont
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
    
        subtitle.text = "CALLING".localize()
        subtitle.textColor = outgoingCallStyle.subtitleColor
        subtitle.font = outgoingCallStyle.subtitleFont
        
        let button = CometChatButton(width: 200, height:200)
        button.set(icon: declineButtonIcon)
        button.set(text: declineButtonText)
        
        buttonStyle.set(iconBackground: CometChatTheme.palatte.error)
            .set(iconTint: .white)
            .set(textColor: CometChatTheme.palatte.accent700)
            .set(textFont: CometChatTheme.typography.caption1)
            .set(iconCornerRadius: 30)
        button.set(style: buttonStyle)
        
        self.button.addArrangedSubview(button)
        
        button.setOnClick {
            CometChatSoundManager().pause()
            self.onCancelClick?(self.call, self)
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
    public func set(buttonStyle: ButtonStyle) -> Self {
        self.buttonStyle = buttonStyle
        return self
    }
    
    @discardableResult
    public func set(outgoingCallStyle: OutgoingCallStyle) -> Self {
        self.outgoingCallStyle = outgoingCallStyle
        return self
    }
    
    @discardableResult
    public func setOnCancelClick(onCancelClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
        self.onCancelClick = onCancelClick
        return self
    }
}
#endif
