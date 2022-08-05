//
//  CometChatTextBubble.swift
//  CometChatUIKit
//
//  Created by Abdullah Ansari on 13/05/22.
//

import UIKit
import CometChatPro

protocol CometChatTextBubbleProtocol: AnyObject {
    func onClick()
}

class CometChatTextBubble: UIView {
    
    // MARK: - Properties
    
    // TODO: - Replace UILabel with HyperLinkLabel.
    //  @IBOutlet weak var message: HyperlinkLabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var containerView: UIView!
    
    // MARK: - Initializer
    // Call when using customView through the code.
    override init(frame: CGRect) {
        super.init(frame: frame)
        customInit()
    }
    
    convenience init(frame: CGRect, message: TextMessage, isStandard: Bool) {
        self.init(frame: frame)
        if let translatedMessage = message.metaData?["translated-message"] as? String {
            
            let translatedText = NSMutableAttributedString(string: "\(translatedMessage.lowercased())\n\n",
                                                           attributes: [NSAttributedString.Key.foregroundColor: CometChatTheme.palatte!.background!.withAlphaComponent(0.9), NSAttributedString.Key.font: CometChatTheme.typography!.Body])
            let messageText = NSMutableAttributedString(string: "\(message.text)\n\n",
                                                        attributes: [NSAttributedString.Key.foregroundColor: CometChatTheme.palatte!.background!.withAlphaComponent(0.8), NSAttributedString.Key.font: CometChatTheme.typography!.Subtitle2])
            let translatedString = NSMutableAttributedString(string: "TRANSLATED_MESSAGE".localize(),
                                                             attributes: [NSAttributedString.Key.foregroundColor: CometChatTheme.palatte!.background!.withAlphaComponent(0.6), NSAttributedString.Key.font: CometChatTheme.typography!.Caption2])
            translatedText.append(messageText)
            translatedText.append(translatedString)
            self.set(attributedText: translatedText)
        }else{
            self.parseProfanityFilter(forMessage: message)
            self.parseMaskedData(forMessage: message)
            
        }
        setupStyle(isStandard: isStandard)
    }
    
    // Call when using customView in IB
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    // MARK: - Helpers
    
    private func setupStyle(isStandard: Bool) {
        let textStyle = TextBubbleStyle(titleColor: isStandard ? CometChatTheme.palatte?.background : CometChatTheme.palatte?.accent900, titleFont: CometChatTheme.typography?.Body)
        set(style: textStyle)
    }
    
    private func customInit() {
        CometChatUIKit.bundle.loadNibNamed("CometChatTextBubble", owner: self, options:  nil)
        addSubview(containerView)
        containerView.frame = bounds
        containerView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    }
    
    @discardableResult
    public func set(style: TextBubbleStyle) -> Self {
        self.set(textColor: style.titleColor!)
        self.set(textFont: style.titleFont!)
        return self
    }
    
    // MARK: - Method's for TextMessage.
    
    /// Set the text
    @discardableResult
    @objc public func set(text: String) -> Self {
        self.message.text = text
        return self
    }
    
    /// Set the text font.
    @discardableResult
    @objc public func set(textFont: UIFont) -> Self {
        self.message.font = textFont
        return self
    }
    
    /// Set the text color.
    @discardableResult
    @objc public func set(textColor: UIColor) -> Self {
        self.message.textColor = textColor
        return self
    }
    
    @discardableResult
    @objc public func set(attributedText: NSMutableAttributedString) -> Self {
        DispatchQueue.main.async {
            self.message.attributedText = attributedText
        }
        return self
    }
    
    
    private func parseProfanityFilter(forMessage: TextMessage) {
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let profanityFilterDictionary = cometChatExtension[ExtensionConstants.profanityFilter] as? [String : Any] {
            
            if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {
                
                if profanity == "yes" {
                    let messageText = NSMutableAttributedString(string: "\(filteredMessage)\n\n",
                                                                attributes: [NSAttributedString.Key.font: applyLargeSizeEmoji(forMessage: forMessage)])
                    set(attributedText: messageText)
                }else{
                    
                    let messageText = NSMutableAttributedString(string: "\(forMessage.text)\n\n",
                                                                attributes: [NSAttributedString.Key.font: applyLargeSizeEmoji(forMessage: forMessage)])
                    set(attributedText: messageText)
                }
            }else{
                let messageText = NSMutableAttributedString(string: "\(forMessage.text)\n\n",
                                                            attributes: [NSAttributedString.Key.font: applyLargeSizeEmoji(forMessage: forMessage)])
                set(attributedText: messageText)
            }
        }else{
            let messageText = NSMutableAttributedString(string: "\(forMessage.text)\n\n",
                                                        attributes: [NSAttributedString.Key.font: applyLargeSizeEmoji(forMessage: forMessage)])
            set(attributedText: messageText)
        }
    }
    
    private func parseMaskedData(forMessage: TextMessage){
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let dataMaskingDictionary = cometChatExtension[ExtensionConstants.dataMasking] as? [String : Any] {
            
            if let data = dataMaskingDictionary["data"] as? [String:Any], let sensitiveData = data["sensitive_data"] as? String {
                
                if sensitiveData == "yes" {
                    if let maskedMessage = data["message_masked"] as? String {
                        let messageText = NSMutableAttributedString(string: "\(maskedMessage)\n\n",
                                                                    attributes: [NSAttributedString.Key.font: CometChatTheme.typography!.Body])
                        set(attributedText: messageText)
                    }else{
                        let messageText = NSMutableAttributedString(string: "\(forMessage.text)\n\n",
                                                                    attributes: [NSAttributedString.Key.font: CometChatTheme.typography!.Body])
                        set(attributedText: messageText)
                    }
                }else{
                    self.parseProfanityFilter(forMessage: forMessage)
                }
            }else{
                self.parseProfanityFilter(forMessage: forMessage)
            }
        }else{
            self.parseProfanityFilter(forMessage: forMessage)
        }
    }
    
    
    
    private func applyLargeSizeEmoji(forMessage: TextMessage) -> UIFont {
        if forMessage.text.containsOnlyEmojis() {
            if forMessage.text.count == 1 {
                return UIFont.systemFont(ofSize: 51, weight: .regular)
            }else if forMessage.text.count == 2 {
                return  UIFont.systemFont(ofSize: 34, weight: .regular)
            }else if forMessage.text.count == 3 {
                return UIFont.systemFont(ofSize: 25, weight: .regular)
            }else{
                return UIFont.systemFont(ofSize: 17, weight: .regular)
            }
        }else{
            return UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
    
}
