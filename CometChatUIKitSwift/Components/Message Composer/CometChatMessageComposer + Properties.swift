//
//  CometChatMessageComposer + Properties.swift
//  CometChatUIKitSwift
//
//  Created by Dawinder on 10/02/25.
//

import Foundation
import CometChatSDK


extension CometChatMessageComposer {
    
    //MARK: Data
    @discardableResult
    public func set(user: User) -> Self {
        viewModel.set(user: user)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.setupAuxiliaryButton()
            this.viewModel.connect()
        }
        return self
    }
    
    @discardableResult
    public func set(group: Group) -> Self {
        viewModel.set(group: group)
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            this.setupAuxiliaryButton()
            this.viewModel.connect()
        }
        return self
    }
    
    @discardableResult
    public func set(parentMessageId: Int) ->  Self {
        viewModel.parentMessageId = parentMessageId
        return self
    }
    
    @discardableResult
    public func set(attachmentOptions: @escaping ((_ user: User?, _ group: Group?, _ controller: UIViewController?) -> [CometChatMessageComposerAction])) -> Self {
        self.attachmentOptionsClosure = attachmentOptions
        return self
    }
    
    
    //MARK: Configurations
    @discardableResult
    public func set(maxLines: Int) -> Self {
        textView.maxLength = maxLines
        return self
    }
    
    @discardableResult
    public func set(onTextChangedListener: @escaping((String) -> ())) -> Self {
        self.onTextChangedListener = onTextChangedListener
        return self
    }
    
    @discardableResult
    public func set(textFormatter: [CometChatTextFormatter]) -> Self {
        viewModel.textFormatter = textFormatter
        return self
    }
    
    @discardableResult
    public func disable(soundForMessages: Bool) -> Self {
        self.disableSoundForMessages = soundForMessages
      return self
    }
    
    @discardableResult
    public func set(customSoundForMessages: URL) -> Self {
        self.customSoundForMessage = customSoundForMessages
      return self
    }
    
    
    //MARK: Events
    @discardableResult
    public func set(onSendButtonClick: @escaping ((BaseMessage) -> Void)) -> Self {
        self.onSendButtonClick = onSendButtonClick
        return self
    }
    
    @discardableResult
    public func set(onError: ((_ error : Any) -> ())?) -> Self {
        self.onError = onError
        return self
    }
    
    
    //MARK: Overrides
    @discardableResult
    public func set(headerView: UIView) -> Self {
        self.headerView.subviews.forEach({ $0.removeFromSuperview() })
        self.headerView.addArrangedSubview(headerView)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.controller?.view.layoutIfNeeded()
        }
        return self
    }
    
    @discardableResult
    public func remove(footerView: Bool) -> Self {
        if footerView {
            self.footerView.subviews.forEach({ $0.removeFromSuperview() })
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.controller?.view.layoutIfNeeded()
            }
        }
        return self
    }
    @discardableResult
    public func set(footerView: UIView) -> Self {
        self.footerView.subviews.forEach({ $0.removeFromSuperview() })
        self.footerView.addArrangedSubview(footerView)
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.controller?.view.layoutIfNeeded()
        }
        return self
    }
       
    @discardableResult
    public func remove(headerView: Bool) -> Self {
        if headerView {
            self.headerView.subviews.forEach({ $0.removeFromSuperview() })
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.controller?.view.layoutIfNeeded()
            }
        }
        return self
    }
    
    @discardableResult
    public func set(sendButtonView: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.sendButtonView = sendButtonView
        if let sendButtonView = self.sendButtonView?(viewModel.user, viewModel.group){
            primaryStackView.subviews.forEach({$0.removeFromSuperview()})
            primaryStackView.addArrangedSubview(sendButtonView)
        }
        return self
    }
    
    @discardableResult
    public func set(auxillaryButtonView: ((_ user: User?, _ group: Group?) -> UIView)?) -> Self {
        self.auxilaryButtonView = auxillaryButtonView
        return self
    }
    
    
    @discardableResult
    public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    
    @discardableResult
    public func reply(message: BaseMessage)  -> Self {
        viewModel.message = message
        self.messageComposerMode = .reply
        UIView.transition(with: messagePreview, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.messagePreview.isHidden = false
        })
        return self
    }
    
    
    @discardableResult
    public func preview(message: BaseMessage, mode: MessageComposerMode) -> Self {
        switch mode {
        case .edit: edit(message: message)
        case .reply: reply(message: message)
        default: break
        }
        return self
    }
    
    @discardableResult
    public func set(aiOptionsText: String) -> Self {
        textView.text = aiOptionsText
        textViewDidChange(textView)
        return self
    }
    
}
