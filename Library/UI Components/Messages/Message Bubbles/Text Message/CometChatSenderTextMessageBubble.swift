
//  CometChatSenderTextMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro



/*  ----------------------------------------------------------------------------------------- */

class CometChatSenderTextMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var tintedView: UIView!
    @IBOutlet weak var message: HyperlinkLabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
   
    
    // MARK: - Declaration of Variables
    let systemLanguage = Locale.preferredLanguages.first
    weak var hyperlinkdelegate: HyperLinkDelegate?
    weak var selectionColor: UIColor? {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.white
        }
    }
    var indexPath: IndexPath?
    weak var textMessage: TextMessage? {
        didSet {
            if let textmessage  = textMessage {
                self.receiptStack.isHidden = true
                self.receipt.isHidden = true
//                self.parseProfanityFilter(forMessage: textmessage)
//                self.parseMaskedData(forMessage: textmessage)
                
                FeatureRestriction.isLargerSizeEmojisEnabled { (success) in
                    if success == .enabled && textmessage.text.containsOnlyEmojis() {
                        if textmessage.text.count == 1 {
                            self.message.font = UIFont.systemFont(ofSize: 51, weight: .regular)
                        }else if textmessage.text.count == 2 {
                            self.message.font = UIFont.systemFont(ofSize: 34, weight: .regular)
                        }else if textmessage.text.count == 3{
                            self.message.font = UIFont.systemFont(ofSize: 25, weight: .regular)
                        }else{
                            self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                        }
                    }else{
                        self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                    }
                }
                self.message.text = textmessage.text
                
                self.reactionView.parseMessageReactionForMessage(message: textmessage) { (success) in
                    if success == true {
                        self.reactionView.isHidden = false
                    }else{
                        self.reactionView.isHidden = true
                    }
                }
                if textmessage.readAt > 0 {
                    receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    receipt.tintColor = UIKitSettings.primaryColor
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.readAt ?? 0))
                }else if textmessage.deliveredAt > 0 {
                    receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    receipt.tintColor = UIKitSettings.secondaryColor
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.deliveredAt ?? 0))
                }else if textmessage.sentAt > 0 {
                    receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    receipt.tintColor = UIKitSettings.secondaryColor
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.sentAt ?? 0))
                }else if textmessage.sentAt == 0 {
                    receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    receipt.tintColor = UIKitSettings.secondaryColor
                    timeStamp.text = "SENDING".localized()
                }
                FeatureRestriction.isDeliveryReceiptsEnabled { (success) in
                    switch success {
                    case .enabled: self.receipt.isHidden = false
                    case .disabled: self.receipt.isHidden = true
                    }
                }
                FeatureRestriction.isThreadedMessagesEnabled { (success) in
                    switch success {
                    case .enabled where textmessage.replyCount != 0 :
                        self.replybutton.isHidden = false
                        if textmessage.replyCount == 1 {
                            self.replybutton.setTitle("ONE_REPLY".localized(), for: .normal)
                        }else{
                            if let replies = textmessage.replyCount as? Int {
                                self.replybutton.setTitle("\(replies) replies", for: .normal)
                            }
                        }
                    case .disabled, .enabled : self.replybutton.isHidden = true
                    }
                }
                
            }
            messageView.backgroundColor = UIKitSettings.primaryColor
            replybutton.tintColor = UIKitSettings.primaryColor
            receipt.contentMode = .scaleAspectFit
            message.textColor = .white

           
            
             let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
             let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
             let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)
             
             message.enabledTypes.append(phoneParser1)
             message.enabledTypes.append(phoneParser2)
             message.enabledTypes.append(emailParser)
             
             message.handleURLTap { self.hyperlinkdelegate?.didTapOnURL(url: $0.absoluteString) }
             
             message.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern1)) { (number) in
                 self.hyperlinkdelegate?.didTapOnPhoneNumber(number: number)
             }
             
             message.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern2)) { (number) in
                 self.hyperlinkdelegate?.didTapOnPhoneNumber(number: number)
             }
             
             message.handleCustomTap(for: .custom(pattern: RegexParser.emailPattern)) { (emailID) in
                 self.hyperlinkdelegate?.didTapOnEmail(email: emailID)
             }
             
            message.customize { label in
                label.URLColor = UIKitSettings.URLColor
                label.URLSelectedColor  = UIKitSettings.URLSelectedColor
                label.customColor[phoneParser1] = UIKitSettings.PhoneNumberColor
                label.customSelectedColor[phoneParser1] = UIKitSettings.PhoneNumberSelectedColor
                label.customColor[phoneParser2] = UIKitSettings.PhoneNumberColor
                label.customSelectedColor[phoneParser2] = UIKitSettings.PhoneNumberSelectedColor
                label.customColor[emailParser] = UIKitSettings.EmailIDColor
                label.customSelectedColor[emailParser] = UIKitSettings.EmailIDColor
            }
        }
    }
    
    weak var deletedMessage: BaseMessage? {
        didSet {
            self.replybutton.isHidden = true
            
            if let deletedMessage = deletedMessage {
                switch deletedMessage.messageCategory {
                
                case .message:
                    switch deletedMessage.messageType {
                    case .text:  message.text = "YOU_DELETED_THIS_MESSAGE".localized()
                    case .image: message.text = "YOU_DELETED_THIS_MESSAGE".localized()
                    case .video: message.text = "YOU_DELETED_THIS_MESSAGE".localized()
                    case .audio: message.text =  "YOU_DELETED_THIS_MESSAGE".localized()
                    case .file:  message.text = "YOU_DELETED_THIS_MESSAGE".localized()
                    case .custom: message.text = "YOU_DELETED_THIS_MESSAGE".localized()
                    case .groupMember: break
                    @unknown default: break }
                case .action: break
                case .call: break
                case .custom:
                if let customMessage = deletedMessage as? CustomMessage {
                    if customMessage.type == "location" {
                        message.text = "YOU_DELETED_THIS_MESSAGE".localized()
                    }else if customMessage.type == "extension_poll" {
                        message.text = "YOU_DELETED_THIS_MESSAGE".localized()
                    }else if customMessage.type == "extension_sticker" {
                        message.text = "YOU_DELETED_THIS_MESSAGE".localized()
                    }else{
                        message.text = "YOU_DELETED_THIS_MESSAGE".localized()
                    }
                }
                @unknown default:
                    break
                }
            }
            
            
            message.textColor = .white
            UIFont.italicSystemFont(ofSize: 17)
            message.font = UIFont.italicSystemFont(ofSize: 17)
            timeStamp.text = String().setMessageTime(time: Int(deletedMessage?.sentAt ?? 0))
            messageView.backgroundColor = UIKitSettings.primaryColor
            replybutton.tintColor = UIKitSettings.primaryColor
            receipt.isHidden = true
            reactionView.isHidden = true
        }
    }
    
    
     func parseProfanityFilter(forMessage: TextMessage){
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let profanityFilterDictionary = cometChatExtension["profanity-filter"] as? [String : Any] {
            
            if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {
                
                if profanity == "yes" {
                    message.text = filteredMessage
                }else{
                    FeatureRestriction.isLargerSizeEmojisEnabled { (success) in
                        if success == .enabled && forMessage.text.containsOnlyEmojis() {
                            if forMessage.text.count == 1 {
                                self.message.font = UIFont.systemFont(ofSize: 51, weight: .regular)
                            }else if forMessage.text.count == 2 {
                                self.message.font = UIFont.systemFont(ofSize: 34, weight: .regular)
                            }else if forMessage.text.count == 3{
                                self.message.font = UIFont.systemFont(ofSize: 25, weight: .regular)
                            }else{
                                self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                            }
                        }else{
                            self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                        }
                    }
                    self.message.text = forMessage.text
                }
            }else{
                FeatureRestriction.isLargerSizeEmojisEnabled { (success) in
                    if success == .enabled && forMessage.text.containsOnlyEmojis() {
                        if forMessage.text.count == 1 {
                            self.message.font = UIFont.systemFont(ofSize: 51, weight: .regular)
                        }else if forMessage.text.count == 2 {
                            self.message.font = UIFont.systemFont(ofSize: 34, weight: .regular)
                        }else if forMessage.text.count == 3{
                            self.message.font = UIFont.systemFont(ofSize: 25, weight: .regular)
                        }else{
                            self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                        }
                    }else{
                        self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                    }
                }
                self.message.text = forMessage.text
            }
        }else{
            
            FeatureRestriction.isLargerSizeEmojisEnabled { (success) in
                if success == .enabled && forMessage.text.containsOnlyEmojis() {
                    if forMessage.text.count == 1 {
                        self.message.font = UIFont.systemFont(ofSize: 51, weight: .regular)
                    }else if forMessage.text.count == 2 {
                        self.message.font = UIFont.systemFont(ofSize: 34, weight: .regular)
                    }else if forMessage.text.count == 3{
                        self.message.font = UIFont.systemFont(ofSize: 25, weight: .regular)
                    }else{
                        self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                    }
                }else{
                    self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                }
            }
            self.message.text = forMessage.text
        }
    }
    
    func parseMaskedData(forMessage: TextMessage){
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let dataMaskingDictionary = cometChatExtension["data-masking"] as? [String : Any] {
          
            if let data = dataMaskingDictionary["data"] as? [String:Any], let sensitiveData = data["sensitive_data"] as? String {
                
                if sensitiveData == "yes" {
                    if let maskedMessage = data["message_masked"] as? String {
                        message.text = maskedMessage
                    }else{
                        FeatureRestriction.isLargerSizeEmojisEnabled { (success) in
                            if success == .enabled && forMessage.text.containsOnlyEmojis() {
                                if forMessage.text.count == 1 {
                                    self.message.font = UIFont.systemFont(ofSize: 51, weight: .regular)
                                }else if forMessage.text.count == 2 {
                                    self.message.font = UIFont.systemFont(ofSize: 34, weight: .regular)
                                }else if forMessage.text.count == 3{
                                    self.message.font = UIFont.systemFont(ofSize: 25, weight: .regular)
                                }else{
                                    self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                                }
                            }else{
                                self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                            }
                        }
                        self.message.text = forMessage.text
                    }
                }else{
                    FeatureRestriction.isLargerSizeEmojisEnabled { (success) in
                        if success == .enabled && forMessage.text.containsOnlyEmojis() {
                            if forMessage.text.count == 1 {
                                self.message.font = UIFont.systemFont(ofSize: 51, weight: .regular)
                            }else if forMessage.text.count == 2 {
                                self.message.font = UIFont.systemFont(ofSize: 34, weight: .regular)
                            }else if forMessage.text.count == 3{
                                self.message.font = UIFont.systemFont(ofSize: 25, weight: .regular)
                            }else{
                                self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                            }
                        }else{
                            self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                        }
                    }
                    self.message.text = forMessage.text
                }
            }else{
                FeatureRestriction.isLargerSizeEmojisEnabled { (success) in
                    if success == .enabled && forMessage.text.containsOnlyEmojis() {
                        if forMessage.text.count == 1 {
                            self.message.font = UIFont.systemFont(ofSize: 51, weight: .regular)
                        }else if forMessage.text.count == 2 {
                            self.message.font = UIFont.systemFont(ofSize: 34, weight: .regular)
                        }else if forMessage.text.count == 3{
                            self.message.font = UIFont.systemFont(ofSize: 25, weight: .regular)
                        }else{
                            self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                        }
                    }else{
                        self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                    }
                }
                self.message.text = forMessage.text
            }
        }else{
            
            FeatureRestriction.isLargerSizeEmojisEnabled { (success) in
                if success == .enabled && forMessage.text.containsOnlyEmojis() {
                    if forMessage.text.count == 1 {
                        self.message.font = UIFont.systemFont(ofSize: 51, weight: .regular)
                    }else if forMessage.text.count == 2 {
                        self.message.font = UIFont.systemFont(ofSize: 34, weight: .regular)
                    }else if forMessage.text.count == 3{
                        self.message.font = UIFont.systemFont(ofSize: 25, weight: .regular)
                    }else{
                        self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                    }
                }else{
                    self.message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                }
            }
            self.message.text = forMessage.text
            self.parseProfanityFilter(forMessage: forMessage)
        }
    }

    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if #available(iOS 13.0, *) {
            selectionColor = .systemBackground
        } else {
            selectionColor = .white
        }
    }
    
     override func setHighlighted(_ highlighted: Bool, animated: Bool) {
          super.setHighlighted(highlighted, animated: animated)
          if #available(iOS 13.0, *) {
              
          } else {
              messageView.backgroundColor =  UIKitSettings.primaryColor
          }
          
      }
      
      override func setSelected(_ selected: Bool, animated: Bool) {
          super.setSelected(selected, animated: animated)
          if #available(iOS 13.0, *) {
              
          } else {
              messageView.backgroundColor =  UIKitSettings.primaryColor
          }
          
      }
    
    @IBAction func didReplyButtonPressed(_ sender: Any) {
         if let message = textMessage, let indexpath = indexPath {
             CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
         }
     }
    
}

/*  ----------------------------------------------------------------------------------------- */
