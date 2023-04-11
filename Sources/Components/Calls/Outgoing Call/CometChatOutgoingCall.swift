//
//  CometChatOutgoingCall.swift
//  
//
//  Created by Pushpsen Airekar on 08/03/23.
//

import UIKit
import CometChatPro

@MainActor
open class CometChatOutgoingCall: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var button: UIStackView!
    
    private (set) var call: Call?
    private (set) var user: User?
    private (set) var declineButtonText: String?
    private (set) var declineButtonIcon: String?
    private (set) var fullscreenView: UIView?
    private (set) var style = OutgoingCallStyle()
    private (set) var avatarStyle: AvatarStyle?
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

        CometChatSoundManager().play(sound: .outgoingCall)
        setupAppearance()
         
        let ongoingCall = CometChatOngoingCall()
        ongoingCall.modalPresentationStyle = .fullScreen

        viewModel.onOutgoingCallAccepted = { call in
            DispatchQueue.main.async {
                ongoingCall.set(sessionId: call.sessionID ?? "")
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
            titleLabel.textColor = style.titleColor
            titleLabel.font = style.titleFont
            avatar.setAvatar(avatarUrl: user.avatar, with: user.name)
        }
        
        if let user = user {
            titleLabel.text = user.name?.capitalized
            titleLabel.textColor = style.titleColor
            titleLabel.font = style.titleFont
            avatar.setAvatar(avatarUrl: user.avatar, with: user.name)
        }
    
        subtitle.text = "CALLING".localize()
        subtitle.textColor = style.subtitleColor
        subtitle.font = style.subtitleFont
        
        let button = CometChatButton(width: 200, height:200)
        button.set(icon: UIImage(systemName: "xmark") ?? UIImage())
        button.set(text: "CANCEL".localize())
        let style = ButtonStyle()
        style.set(iconBackground: CometChatTheme.palatte.error)
            .set(iconTint: .white)
            .set(textColor: CometChatTheme.palatte.accent700)
            .set(textFont: CometChatTheme.typography.caption1)
            .set(iconCornerRadius: 30)
        button.set(style: style)
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
    public func set(avatarStyle: AvatarStyle) -> Self {
        self.avatarStyle = avatarStyle
        return self
    }
    
    @discardableResult
    public func set(style: OutgoingCallStyle) -> Self {
        self.style = style
        return self
    }
    
    @discardableResult
    public func setOnCancelClick(onCancelClick: @escaping (_ call: Call?, _ controller: UIViewController?) -> Void) -> Self {
        self.onCancelClick = onCancelClick
        return self
    }
}

