//
//  AIComposer.swift
//
//
//  Created by SuryanshBisen on 07/11/23.
//

import UIKit
import CometChatSDK

class AIMessageComposer: UIView {

    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var textFiled: GrowingTextView!
    @IBOutlet weak var textFiledContainerView: UIView!
    @IBOutlet weak var textFiledHeightConstraint: NSLayoutConstraint!
    private(set) var placeholderText: String = "TYPE_A_MESSAGE".localize()
    private(set) var onSendButtonClicked: ((BaseMessage) -> Void)?
    @IBOutlet weak var mainContainerStackView: UIStackView!
    private(set) var user: User?
    private var style: MessageInputStyle?
    
    private var sendIcon = UIImage(named: "message-composer-send.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        let loadedNib = CometChatUIKit.bundle.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = self.bounds
            self.addSubview(contentView)
        }
        
        buildUI()
    }
    
    func buildUI() {
        sendButton.setImage(sendIcon, for: .normal)
        sendButton.tintColor = CometChatTheme_v4.palatte.accent700
        sendButton.setTitle("", for: .normal)
        
        textFiled.delegate = self
        textFiled.attributedPlaceholder = NSAttributedString(string: self.placeholderText, attributes: [.foregroundColor: style?.placeHolderTextColor ?? CometChatTheme_v4.palatte.accent500, .font: style?.placeHolderTextFont ??  CometChatTheme_v4.typography.text1])
        textFiled.font = style?.textFont ?? CometChatTheme_v4.typography.text1
        textFiled.textColor = style?.textColor ?? CometChatTheme_v4.palatte.accent
        textFiled.backgroundColor = style?.inputBackground ?? CometChatTheme_v4.palatte.background
//        textFiled.maxNumberOfLines = 3
        
        textFiledContainerView.borderWith(width: style?.borderWidth ?? 1)
        textFiledContainerView.borderColor(color: style?.borderColor ?? CometChatTheme_v4.palatte.accent700)
        textFiledContainerView.roundViewCorners(corner: style?.cornerRadius ?? CometChatCornerStyle(cornerRadius: 20))
    }
    
    @IBAction func onSendButtonClicked(_ sender: Any) {
        if let textFiled = textFiled, let messageText = textFiled.text?.trimmingCharacters(in: .whitespacesAndNewlines), messageText != "" {
            let textMessage = TextMessage(receiverUid: user?.uid ?? "", text: messageText, receiverType: .user)
            onSendButtonClicked?(textMessage)
            textFiled.text = ""
        }
    }
}


extension AIMessageComposer: GrowingTextViewDelegate {
    
    public func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat) {
        self.textFiledHeightConstraint.constant = height
    }
    
    func growingTextViewShouldBeginEditing(_ growingTextView: GrowingTextView) -> Bool {
        return true
    }
    
    func growingTextViewShouldEndEditing(_ growingTextView: GrowingTextView) -> Bool {
        return true
    }
    
    public func growingTextViewDidChange(_ growingTextView: GrowingTextView) {
    }
}

extension AIMessageComposer {
    
    @discardableResult
    public func set(user: User?) -> Self {
        self.user = user
        return self
    }
    
    @discardableResult
    public func set(onMessageSent: ((BaseMessage) -> Void)?) -> Self {
        self.onSendButtonClicked = onMessageSent
        return self
    }
    
    @discardableResult
    public func set(sendIcon: UIImage) -> Self {
        self.sendIcon = sendIcon
        return self
    }
    
    @discardableResult
    public func set(sendIconTint: UIColor) -> Self {
        self.sendIcon.withTintColor(sendIconTint)
        return self
    }
    
    @discardableResult
    public func set(messageInputStyle: MessageInputStyle) -> Self {
        self.style = messageInputStyle
        return self
    }
    
}

