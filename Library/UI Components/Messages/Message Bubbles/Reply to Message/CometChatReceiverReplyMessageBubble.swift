
//  CometChatReceiverTextMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */
protocol CometChatReceiverReplyMessageBubbleDelegate: AnyObject {
    func didTapOnSentimentAnalysisViewForLeftReplyBubble(indexPath: IndexPath)
}

class CometChatReceiverReplyMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var tintedView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var message: HyperlinkLabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var sentimentAnalysisView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var replyMessage: UILabel!
    @IBOutlet weak var spaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthconstraint: NSLayoutConstraint!
    @IBOutlet weak var replyMessageView: UIView!
    @IBOutlet weak var replyMessageIndicator: UIView!
    @IBOutlet weak var replyMessageUserName: UILabel!
    @IBOutlet weak var thumbnailView: UIView!
    @IBOutlet weak var thumbnailViewWidth: NSLayoutConstraint!
    @IBOutlet weak var thumbnailViewHeight: NSLayoutConstraint!
    @IBOutlet weak var thumbnailViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnaikViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var thumbnail: UIImageView!
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    let systemLanguage = Locale.preferredLanguages.first
     weak var delegate: CometChatReceiverReplyMessageBubbleDelegate?
    weak var hyperlinkdelegate: HyperLinkDelegate?
    unowned var selectionColor: UIColor {
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
            if let currentMessage = textMessage {
                sentimentAnalysisView.dropShadow()
                if let userName = currentMessage.sender?.name {
                    name.text = userName + ":"
                }
              
                if let metaData = currentMessage.metaData, let replyToMessage = metaData["reply-message"] as? [String:Any], let baseMessage = CometChat.processMessage(replyToMessage).0 as? BaseMessage {
                    self.replyMessageIndicator.backgroundColor = UIKitSettings.primaryColor
                    self.replyMessage.isHidden = false
                    self.replyMessageUserName.isHidden = false
                    if let name = baseMessage.sender?.name {
                    self.replyMessageUserName.text = name.capitalized
                    }
                    switch baseMessage.messageCategory {
                   
                    case .message:
                        switch baseMessage.messageType {
                        case .text:
                            if let currentReplyMessage = baseMessage as? TextMessage {
                                self.hidethumbnailView(bool: true)
                                self.parseProfanityFilter(forReplyMessage: currentReplyMessage)
                                self.parseMaskedData(forReplyMessage: currentReplyMessage)
                            }
                        case .image:
                            self.replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                            self.hidethumbnailView(bool: true)
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
                }else{
                    self.replyMessage.isHidden = false
                    self.replyMessageUserName.isHidden = true
                    self.replyMessage.text = "This reply message is outdated."
                }
                self.parseProfanityFilter(forMessage: currentMessage)
                self.parseSentimentAnalysis(forMessage: currentMessage)
                self.parseMaskedData(forMessage: currentMessage)
                self.reactionView.parseMessageReactionForMessage(message: currentMessage) { (success) in
                    if success == true {
                        self.reactionView.isHidden = false
                    }else{
                        self.reactionView.isHidden = true
                    }
                }
                receiptStack.isHidden = true
                if currentMessage.receiverType == .group {
                    nameView.isHidden = false
                }else {
                    nameView.isHidden = true
                }
                if let avatarURL = currentMessage.sender?.avatar  {
                    avatar.set(image: avatarURL, with: currentMessage.sender?.name ?? "")
                }else{
                    avatar.set(image: "", with: currentMessage.sender?.name ?? "")
                }
                timeStamp.text = String().setMessageTime(time: currentMessage.sentAt)
                replybutton.isHidden = true
            }
            replybutton.tintColor = UIKitSettings.primaryColor
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
    
    weak var textMessageInThread: TextMessage? {
             didSet {
                 if let textmessage  = textMessageInThread {
                       self.parseProfanityFilter(forMessage: textmessage)
                       self.parseMaskedData(forMessage: textmessage)
                       self.parseSentimentAnalysis(forMessage: textmessage)
                     
                    if let metaData = textmessage.metaData, let replyToMessage = metaData["reply-message"] as? [String:Any], let baseMessage = CometChat.processMessage(replyToMessage).0 as? BaseMessage {
                        self.replyMessageIndicator.backgroundColor = UIKitSettings.primaryColor
                        self.replyMessage.isHidden = false
                        self.replyMessageUserName.isHidden = false
                        if let name = baseMessage.sender?.name {
                        self.replyMessageUserName.text = name.capitalized
                        }
                        switch baseMessage.messageCategory {
                       
                        case .message:
                            switch baseMessage.messageType {
                            case .text:
                                if let currentReplyMessage = baseMessage as? TextMessage {
                                    self.hidethumbnailView(bool: true)
                                    self.parseProfanityFilter(forReplyMessage: currentReplyMessage)
                                    self.parseMaskedData(forReplyMessage: currentReplyMessage)
                                }
                            case .image:
                                self.replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                                self.hidethumbnailView(bool: true)
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
                    }else{
                        self.replyMessage.isHidden = false
                        self.replyMessageUserName.isHidden = true
                        self.replyMessage.text = "This reply message is outdated."
                    }
                    self.reactionView.parseMessageReactionForMessage(message: textmessage) { (success) in
                        if success == true {
                            self.reactionView.isHidden = false
                        }else{
                            self.reactionView.isHidden = true
                        }
                    }
                     if textmessage.readAt > 0 {
                         timeStamp.text = String().setMessageTime(time: Int(textMessage?.readAt ?? 0))
                     }else if textmessage.deliveredAt > 0 {
                         timeStamp.text = String().setMessageTime(time: Int(textMessage?.deliveredAt ?? 0))
                     }else if textmessage.sentAt > 0 {
                         timeStamp.text = String().setMessageTime(time: Int(textMessage?.sentAt ?? 0))
                     }else if textmessage.sentAt == 0 {
                         timeStamp.text = "SENDING".localized()
                         name.text = LoggedInUser.name.capitalized + ":"
                     }
                    if let userName = textmessage.sender?.name {
                        name.text = userName + ":"
                    }
                    if let avatarURL = textmessage.sender?.avatar  {
                        avatar.set(image: avatarURL, with: textmessage.sender?.name ?? "")
                    }
                 }
                nameView.isHidden = false
                
                
                if #available(iOS 13.0, *) {
                    message.textColor = .label
                } else {
                    message.textColor = .black
                }
                 replybutton.isHidden = true
                
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
            // self.selectionStyle = .none
            if let currentMessage = deletedMessage {
                self.replybutton.isHidden = true
                if let userName = currentMessage.sender?.name {
                    name.text = userName + ":"
                }
                if (currentMessage.sender?.name) != nil {
                    switch currentMessage.messageType {
                    case .text:  message.text =  "THIS_MESSAGE_DELETED".localized()
                    case .image: message.text = "THIS_MESSAGE_DELETED".localized()
                    case .video: message.text = "THIS_MESSAGE_DELETED".localized()
                    case .audio: message.text =  "THIS_MESSAGE_DELETED".localized()
                    case .file:  message.text = "THIS_MESSAGE_DELETED".localized()
                    case .custom: message.text = "THIS_MESSAGE_DELETED".localized()
                    case .groupMember: break
                    @unknown default: break }}
                receiptStack.isHidden = true
                if currentMessage.receiverType == .group {
                    nameView.isHidden = false
                }else {
                    nameView.isHidden = true
                }
                if let avatarURL = currentMessage.sender?.avatar  {
                    avatar.set(image: avatarURL, with: currentMessage.sender?.name ?? "")
                }
                timeStamp.text = String().setMessageTime(time: Int(currentMessage.sentAt))
                message.textColor = .darkGray
                message.font = UIFont.italicSystemFont(ofSize: 17)
            }
        }
    }
    
    @IBAction func didReplyButtonPressed(_ sender: Any) {
             if let message = textMessage, let indexpath = indexPath {
                 CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
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
    
    @IBAction func didViewButtonPressed(_ sender: Any) {
        if let indexPAth = indexPath {
            delegate?.didTapOnSentimentAnalysisViewForLeftReplyBubble(indexPath: indexPAth)
        }
    }
    
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textMessage = nil
        deletedMessage = nil
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        switch isEditing {
        case true:
            switch selected {
            case true: self.tintedView.isHidden = false
            case false: self.tintedView.isHidden = true
            }
        case false: break
        }
    }
    
    /**
     This method used to set the image for CometChatReceiverTextMessageBubble class
     - Parameter image: This specifies a `URL` for  the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
     func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.cf.setImage(with: url)
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
    
    
    func getMapFromLocatLon(from latitude: Double ,and longitude: Double, googleApiKey: String) -> URL? {
        
        let url = URL(string: "https://maps.googleapis.com/maps/api/staticmap?center=\(latitude),\(longitude)&markers=color:red%7Clabel:S%7C\(latitude),\(longitude)&zoom=14&size=230x150&key=\(googleApiKey.trimmingCharacters(in: .whitespacesAndNewlines))")
        
        return url
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
                if forMessage.text.containsOnlyEmojis() {
                    if forMessage.text.count == 1 {
                        message.font =  UIFont.systemFont(ofSize: 51, weight: .regular)
                    }else if forMessage.text.count == 2 {
                        message.font =  UIFont.systemFont(ofSize: 34, weight: .regular)
                    }else if forMessage.text.count == 3{
                        message.font =  UIFont.systemFont(ofSize: 25, weight: .regular)
                    }else{
                        message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                    }
                  
                }else{
                    message.font =  UIFont.systemFont(ofSize: 17, weight: .regular)
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
    
            private func parseSentimentAnalysis(forMessage: TextMessage){
              if let metaData = textMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let sentimentAnalysisDictionary = cometChatExtension["sentiment-analysis"] as? [String : Any] {
                  if let sentiment = sentimentAnalysisDictionary["sentiment"] as? String {
                      if sentiment == "negative" {
                          sentimentAnalysisView.isHidden = false
                          message.textColor = UIColor.white
                          message.font =  UIFont.systemFont(ofSize: 15, weight: .regular)
                          message.text = "MAY_CONTAIN_NEGATIVE_SENTIMENT".localized()
                          spaceConstraint.constant = 10
                          widthconstraint.constant = 45
                      }else{
                          if #available(iOS 13.0, *) {
                              message.textColor = .label
                          } else {
                              message.textColor = .black
                          }
                          message.font =  UIFont.systemFont(ofSize: 17, weight: .regular)
                          sentimentAnalysisView.isHidden = true
                          spaceConstraint.constant = 0
                          widthconstraint.constant = 0
                      }
                  }else{
                      self.parseProfanityFilter(forMessage: forMessage)
                  }
              }else{
                  if #available(iOS 13.0, *) {
                      message.textColor = .label
                  } else {
                      message.textColor = .black
                  }
                  message.font =  UIFont.systemFont(ofSize: 17, weight: .regular)
                  sentimentAnalysisView.isHidden = true
                  spaceConstraint.constant = 0
                  widthconstraint.constant = 0
                  self.parseProfanityFilter(forMessage: forMessage)
              }
          }
    
    
    func parseProfanityFilter(forReplyMessage: TextMessage){
           if let metaData = forReplyMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let profanityFilterDictionary = cometChatExtension["profanity-filter"] as? [String : Any] {
               
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
               if forReplyMessage.text.containsOnlyEmojis() {
                   if forReplyMessage.text.count == 1 {
                    replyMessage.font =  UIFont.systemFont(ofSize: 47, weight: .regular)
                   }else if forReplyMessage.text.count == 2 {
                    replyMessage.font =  UIFont.systemFont(ofSize: 30, weight: .regular)
                   }else if forReplyMessage.text.count == 3{
                    replyMessage.font =  UIFont.systemFont(ofSize: 21, weight: .regular)
                   }else{
                    replyMessage.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                   }
                 
               }else{
                replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
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
             replyMessage.font =  UIFont.systemFont(ofSize: 47, weight: .regular)
            }else if forReplyMessage.text.count == 2 {
             replyMessage.font =  UIFont.systemFont(ofSize: 30, weight: .regular)
            }else if forReplyMessage.text.count == 3{
             replyMessage.font =  UIFont.systemFont(ofSize: 21, weight: .regular)
            }else{
             replyMessage.font = UIFont.systemFont(ofSize: 13, weight: .regular)
            }
           }else{
            replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
           }
           self.replyMessage.text = forReplyMessage.text
       }
   }
   
           private func parseSentimentAnalysis(forReplyMessage: TextMessage){
             if let metaData = textMessage?.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let sentimentAnalysisDictionary = cometChatExtension["sentiment-analysis"] as? [String : Any] {
                 if let sentiment = sentimentAnalysisDictionary["sentiment"] as? String {
                     if sentiment == "negative" {
                         sentimentAnalysisView.isHidden = false
                        replyMessage.textColor = UIColor.white
                        replyMessage.font =  UIFont.systemFont(ofSize: 15, weight: .regular)
                        replyMessage.text = "MAY_CONTAIN_NEGATIVE_SENTIMENT".localized()
                         spaceConstraint.constant = 10
                         widthconstraint.constant = 45
                     }else{
                         if #available(iOS 13.0, *) {
                            replyMessage.textColor = .label
                         } else {
                            replyMessage.textColor = .black
                         }
                        replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                         sentimentAnalysisView.isHidden = true
                         spaceConstraint.constant = 0
                         widthconstraint.constant = 0
                     }
                 }else{
                     self.parseProfanityFilter(forReplyMessage: forReplyMessage)
                 }
             }else{
                 if #available(iOS 13.0, *) {
                    replyMessage.textColor = .label
                 } else {
                    replyMessage.textColor = .black
                 }
                 replyMessage.font =  UIFont.systemFont(ofSize: 13, weight: .regular)
                 sentimentAnalysisView.isHidden = true
                 spaceConstraint.constant = 0
                 widthconstraint.constant = 0
                 self.parseProfanityFilter(forReplyMessage: forReplyMessage)
             }
         }
}


/*  ----------------------------------------------------------------------------------------- */


