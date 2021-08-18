
//  CometChatSenderTextMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */


class CometChatSenderReplyMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBInspectable
    
    @IBOutlet weak var replyMessageView: UIView!
    @IBOutlet weak var replyMessage: UILabel!
    @IBOutlet weak var replyMessageUserName: UILabel!
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var message: HyperlinkLabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var thumbnailViewWidth: NSLayoutConstraint!
    @IBOutlet weak var thumbnailViewHeight: NSLayoutConstraint!
    @IBOutlet weak var thumbnailViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnaikViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnail: UIImageView!
  
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    let systemLanguage = Locale.preferredLanguages.first
    weak var hyperlinkdelegate: HyperLinkDelegate?
    weak var selectionColor: UIColor? {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.clear
        }
    }
    
    weak var textMessage: TextMessage? {
        didSet {
            if let textmessage  = textMessage {
                self.parseProfanityFilter(forMessage: textmessage)
                self.parseMaskedData(forMessage: textmessage)
                self.reactionView.parseMessageReactionForMessage(message: textmessage) { (success) in
                    if success == true {
                        self.reactionView.isHidden = false
                    }else{
                        self.reactionView.isHidden = true
                    }
                }
               
                if let metaData = textmessage.metaData, let replyToMessage = metaData["reply-message"] as? [String:Any], let baseMessage = CometChat.processMessage(replyToMessage).0 {
                    if let name = baseMessage.sender?.name {
                    self.replyMessageUserName.text = name.capitalized
                    }
                    switch baseMessage.messageCategory {
                   
                    case .message:
                        switch baseMessage.messageType {
                        case .text:
                            if let textMessage = baseMessage as? TextMessage {
                                self.hidethumbnailView(bool: true)
                                self.parseProfanityFilter(forReplyMessage: textmessage)
                                self.parseMaskedData(forReplyMessage: textMessage)
                            }
                        case .image:
                            self.hidethumbnailView(bool: true)
                            self.replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                            self.replyMessage.text = "MESSAGE_IMAGE".localized()
                        case .video:
                            self.hidethumbnailView(bool: true)
                            self.replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                            self.replyMessage.text = "MESSAGE_VIDEO".localized()
                        case .audio:
                            self.hidethumbnailView(bool: true)
                            self.replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                            self.replyMessage.text = "MESSAGE_AUDIO".localized()
                        case .file:
                            self.hidethumbnailView(bool: true)
                            self.replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                            self.replyMessage.text = "MESSAGE_FILE".localized()
                        case .custom:
                            if let customMessage = baseMessage as? CustomMessage {
                                self.replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                                if customMessage.type == "location" {
                                   
                                    
                                    if let data = customMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double{
                                        
                                        if let url = self.getMapFromLocatLon(from: latitude, and: longitude, googleApiKey: UIKitSettings.googleApiKey) {
                                            thumbnail.cf.setImage(with: url, placeholder: UIImage(named: "location-map.png", in: UIKitSettings.bundle, compatibleWith: nil))
                                        }else{
                                        }
                                    }
                                    self.hidethumbnailView(bool: false)
                                    replyMessage.text = "CUSTOM_MESSAGE_LOCATION".localized()
                                }else if customMessage.type == "extension_poll" {
                                    self.hidethumbnailView(bool: true)
                                    replyMessage.text = "CUSTOM_MESSAGE_POLL".localized()
                                }else if customMessage.type == "extension_sticker" {
                                    self.hidethumbnailView(bool: true)
                                    replyMessage.text = "CUSTOM_MESSAGE_STICKER".localized()
                                }else if customMessage.type == "extension_whiteboard" {
                                    self.hidethumbnailView(bool: true)
                                    replyMessage.text = "CUSTOM_MESSAGE_WHITEBOARD".localized()
                                }else if customMessage.type == "extension_document" {
                                    self.hidethumbnailView(bool: true)
                                    replyMessage.text = "CUSTOM_MESSAGE_DOCUMENT".localized()
                                }else if customMessage.type == "meeting" {
                                    self.hidethumbnailView(bool: true)
                                    replyMessage.text = "CUSTOM_MESSAGE_GROUP_CALL".localized()
                                }
                            }
                        case .groupMember: break
                        @unknown default: break
                        }
                    case .action: break
                    case .call: break
                    case .custom:
                        if let customMessage = baseMessage as? CustomMessage {
                            self.replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                            if customMessage.type == "location" {
                                self.thumbnailView.isHidden = false
                                self.thumbnailViewWidth.constant = 40
                                self.thumbnailViewLeadingConstraint.constant = 15
                                self.thumbnaikViewTrailingConstraint.constant = 8
                                
                                if let data = customMessage.customData , let latitude = data["latitude"] as? Double, let longitude =  data["longitude"] as? Double{
                                    
                                    if let url = self.getMapFromLocatLon(from: latitude, and: longitude, googleApiKey: UIKitSettings.googleApiKey) {
                                        thumbnail.cf.setImage(with: url, placeholder: UIImage(named: "location-map.png", in: UIKitSettings.bundle, compatibleWith: nil))
                                    }else{
                                    }
                                }
                                self.hidethumbnailView(bool: false)
                                replyMessage.text = "CUSTOM_MESSAGE_LOCATION".localized()
                            }else if customMessage.type == "extension_poll" {
                                self.hidethumbnailView(bool: true)
                                replyMessage.text = "CUSTOM_MESSAGE_POLL".localized()
                            }else if customMessage.type == "extension_sticker" {
                                self.hidethumbnailView(bool: true)
                                replyMessage.text =   "CUSTOM_MESSAGE_STICKER".localized()
                            }else if customMessage.type == "extension_whiteboard" {
                                self.hidethumbnailView(bool: true)
                                replyMessage.text = "CUSTOM_MESSAGE_WHITEBOARD".localized()
                            }else if customMessage.type == "extension_document" {
                                self.hidethumbnailView(bool: true)
                                replyMessage.text = "CUSTOM_MESSAGE_DOCUMENT".localized()
                            }else if customMessage.type == "meeting" {
                                self.hidethumbnailView(bool: true)
                                replyMessage.text = "CUSTOM_MESSAGE_GROUP_CALL".localized()
                            }
                        }
                    @unknown default: break
                    }
                }
                if textmessage.readAt > 0 {
                    receipt.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.readAt ?? 0))
                }else if textmessage.deliveredAt > 0 {
                    receipt.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.deliveredAt ?? 0))
                }else if textmessage.sentAt > 0 {
                    receipt.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.sentAt ?? 0))
                }else if textmessage.sentAt == 0 {
                    receipt.image = UIImage(named: "messages-wait", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
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
            messageView.tintColor = UIKitSettings.primaryColor
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
            switch deletedMessage?.messageType {
            case .text:  message.text = "YOU_DELETED_THIS_MESSAGE".localized()
            case .image: message.text = "YOU_DELETED_THIS_IMAGE".localized()
            case .video: message.text = "YOU_DELETED_THIS_VIDEO".localized()
            case .audio: message.text =  "YOU_DELETED_THIS_AUDIO".localized()
            case .file:  message.text = "YOU_DELETED_THIS_FILE".localized()
            case .custom: message.text = "YOU_DELETED_THIS_CUSTOM_MESSAGE".localized()
            case .groupMember: break
            @unknown default: break }
            message.textColor = .darkGray
            message.font = UIFont.italicSystemFont(ofSize: 17)
            timeStamp.text = String().setMessageTime(time: Int(deletedMessage?.sentAt ?? 0))
        }
    }
    
    private func hidethumbnailView(bool: Bool) {
        if bool == true {
            self.thumbnailView.isHidden = true
            self.thumbnailViewWidth.constant = 0
            self.thumbnailViewLeadingConstraint.constant = 10
            self.thumbnaikViewTrailingConstraint.constant = 0
        } else {
            self.thumbnailView.isHidden = false
            self.thumbnailViewWidth.constant = 40
            self.thumbnailViewLeadingConstraint.constant = 15
            self.thumbnaikViewTrailingConstraint.constant = 8
        }
    }
    
     func parseProfanityFilter(forMessage: TextMessage){
        if let metaData = textMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let profanityFilterDictionary = cometChatExtension["profanity-filter"] as? [String : Any] {
            
            if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {
                
                if profanity == "yes" {
                    message.text = filteredMessage
                }else{
                    message.text = forMessage.text
                }
            }else{
                message.text = forMessage.text
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
                        message.text = forMessage.text
                    }
                }else{
                    message.text = forMessage.text
                }
            }else{
                message.text = forMessage.text
            }
        }else{
            
            if forMessage.text.containsOnlyEmojis() {
                if forMessage.text.count == 1 {
                    message.font =  UIFont.systemFont(ofSize: 51, weight: .regular)
                }else if forMessage.text.count == 2 {
                    message.font =  UIFont.systemFont(ofSize: 34, weight: .regular)
                }else if forMessage.text.count == 3{
                    message.font =  UIFont.systemFont(ofSize: 25, weight: .regular)
                }else{
                    message.font =  UIFont.systemFont(ofSize: 17, weight: .regular)
                }
            }else{
                message.font =  UIFont.systemFont(ofSize: 17, weight: .regular)
            }
            self.message.text = forMessage.text
        }
    }
    
    func getMapFromLocatLon(from latitude: Double ,and longitude: Double, googleApiKey: String) -> URL? {
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&markers=color:red%7Clabel:S%7C\(latitude),\(longitude)&zoom=14&size=230x150&key=\(googleApiKey.trimmingCharacters(in: .whitespacesAndNewlines))")
        
        return url
    }
    
    
    func parseProfanityFilter(forReplyMessage: TextMessage){
       if let metaData = textMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let profanityFilterDictionary = cometChatExtension["profanity-filter"] as? [String : Any] {
           
           if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {
               
               if profanity == "yes" {
                replyMessage.text = filteredMessage
               }else{
                replyMessage.text = forReplyMessage.text
               }
           }else{
            replyMessage.text = forReplyMessage.text
           }
       }else{
           
           FeatureRestriction.isLargerSizeEmojisEnabled { (success) in
               if success == .enabled && forReplyMessage.text.containsOnlyEmojis() {
                if forReplyMessage.text.count == 1 {
                    self.replyMessage.font =  UIFont.systemFont(ofSize: 47, weight: .regular)
                }else if forReplyMessage.text.count == 2 {
                    self.replyMessage.font =  UIFont.systemFont(ofSize: 30, weight: .regular)
                }else if forReplyMessage.text.count == 3{
                    self.replyMessage.font =  UIFont.systemFont(ofSize: 21, weight: .regular)
                }else{
                    self.replyMessage.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                }
               }else{
                   self.replyMessage.font = UIFont.systemFont(ofSize: 13, weight: .regular)
               }
           }
           self.replyMessage.text = forReplyMessage.text
       }
   }
   
   func parseMaskedData(forReplyMessage: TextMessage){
       if let metaData = forReplyMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let dataMaskingDictionary = cometChatExtension["data-masking"] as? [String : Any] {
         
           if let data = dataMaskingDictionary["data"] as? [String:Any], let sensitiveData = data["sensitive_data"] as? String {
               
               if sensitiveData == "yes" {
                   if let maskedMessage = data["message_masked"] as? String {
                    replyMessage.text = maskedMessage
                   }else{
                    replyMessage.text = forReplyMessage.text
                   }
               }else{
                replyMessage.text = forReplyMessage.text
               }
           }else{
            replyMessage.text = forReplyMessage.text
           }
       }else{
           
           if forReplyMessage.text.containsOnlyEmojis() {
            if forReplyMessage.text.count == 1 {
                self.replyMessage.font =  UIFont.systemFont(ofSize: 47, weight: .regular)
            }else if forReplyMessage.text.count == 2 {
                self.replyMessage.font =  UIFont.systemFont(ofSize: 30, weight: .regular)
            }else if forReplyMessage.text.count == 3{
                self.replyMessage.font =  UIFont.systemFont(ofSize: 21, weight: .regular)
            }else{
                self.replyMessage.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            }
           }else{
            self.replyMessage.font =  UIFont.systemFont(ofSize: 12, weight: .regular)
           }
           self.replyMessage.text = forReplyMessage.text
       }
   }
  
    
    // MARK: - Initialization of required Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
             if let message = textMessage, let indexpath = indexPath {
                 CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
             }

         }
    
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
    
}

/*  ----------------------------------------------------------------------------------------- */
