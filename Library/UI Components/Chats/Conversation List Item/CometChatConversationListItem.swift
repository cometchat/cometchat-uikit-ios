
//  CometChatConversationListItem.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatConversationListItem: This component will be the class of UITableViewCell with components such as avatar(Avatar), name(UILabel), message(UILabel).
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */


// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatConversationListItem: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var status: CometChatStatusIndicator!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var message: UILabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var unreadBadgeCount: CometChatBadgeCount!
    @IBOutlet weak var read: UIImageView!
    @IBOutlet weak var typing: UILabel!
    @IBOutlet weak var isThread: UILabel!
    
    // MARK: - Declaration of Variables
    
    lazy var searchedText: String = ""
    
    let normalTitlefont = UIFont.systemFont(ofSize: 17, weight: .medium)
    let boldTitlefont = UIFont.systemFont(ofSize: 17, weight: .bold)
    let normalSubtitlefont = UIFont.systemFont(ofSize: 15, weight: .regular)
    let boldSubtitlefont = UIFont.systemFont(ofSize: 15, weight: .bold)
    
    
    weak var conversation: Conversation? {
        didSet {
            if let currentConversation = conversation {

               
                unreadBadgeCount.backgroundColor = UIKitSettings.primaryColor
                switch currentConversation.conversationType {
                case .user:
                    guard let user =  currentConversation.conversationWith as? User else {
                        return
                    }
                    name.attributedText = addBoldText(fullString: user.name! as NSString, boldPartOfString: searchedText as NSString, font: normalTitlefont, boldFont: boldTitlefont)
                    avatar.set(image: user.avatar ?? "", with: user.name ?? "")
                    status.isHidden = false
                    status.set(status: user.status)
                    
                    FeatureRestriction.isUserPresenceEnabled { (success) in
                        switch success {
                        case .enabled:  self.status.isHidden = false
                        case .disabled: self.status.isHidden = true
                        }
                    }
                case .group:
                    guard let group =  currentConversation.conversationWith as? Group else {
                        return
                    }
                    name.attributedText = addBoldText(fullString: group.name! as NSString, boldPartOfString: searchedText as NSString, font: normalTitlefont, boldFont: boldTitlefont)
                    avatar.set(image: group.icon ?? "", with: group.name ?? "")
                    status.isHidden = true
                case .none:
                    break
                @unknown default:
                    break
                }

                if let currentMessage = currentConversation.lastMessage {
                    let senderName = currentMessage.sender?.name
                    switch currentMessage.messageCategory {
                    case .message:
                        
                        if currentMessage.deletedAt > 0.0 {
                            FeatureRestriction.isHideDeletedMessagesEnabled { (success) in
                                switch success {
                                case .enabled:
                                    self.message.text = ""
                                case .disabled:
                                    self.message.text = "THIS_MESSAGE_DELETED".localized()
                                }
                            }
                        }else {
                            switch currentMessage.messageType {
                            case .text where currentConversation.conversationType == .user:
                                
                                if let textMessage = currentConversation.lastMessage as? TextMessage {
                                    self.parseProfanityFilter(forMessage: textMessage)
                                    self.parseMaskedData(forMessage: textMessage)
                                    self.parseSentimentAnalysis(forMessage: textMessage)
                                }
                                
                            case .text where currentConversation.conversationType == .group:
                                
                                if let textMessage = currentConversation.lastMessage as? TextMessage {
                                    self.parseProfanityFilter(forMessage: textMessage)
                                    self.parseMaskedData(forMessage: textMessage)
                                    self.parseSentimentAnalysis(forMessage: textMessage)
                                }
                                
                            case .image where currentConversation.conversationType == .user:
                                message.text = "MESSAGE_IMAGE".localized()
                            case .image where currentConversation.conversationType == .group:
                                message.text = senderName! + ":  " + "MESSAGE_IMAGE".localized()
                            case .video  where currentConversation.conversationType == .user:
                                message.text = "MESSAGE_VIDEO".localized()
                            case .video  where currentConversation.conversationType == .group:
                                message.text = senderName! + ":  " + "MESSAGE_VIDEO".localized()
                            case .audio  where currentConversation.conversationType == .user:
                                message.text = "MESSAGE_AUDIO".localized()
                            case .audio  where currentConversation.conversationType == .group:
                                message.text = senderName! + ":  " + "MESSAGE_AUDIO".localized()
                            case .file  where currentConversation.conversationType == .user:
                                message.text = "MESSAGE_FILE".localized()
                            case .file  where currentConversation.conversationType == .group:
                                message.text = senderName! + ":  " + "MESSAGE_FILE".localized()
                            case .custom where currentConversation.conversationType == .user:
                                
                                if let customMessage = currentConversation.lastMessage as? CustomMessage {
                                    if customMessage.type == "location" {
                                        message.text = "CUSTOM_MESSAGE_LOCATION".localized()
                                    }else if customMessage.type == "extension_poll" {
                                        message.text = "CUSTOM_MESSAGE_POLL".localized()
                                    }else if customMessage.type == "extension_sticker" {
                                        message.text = "CUSTOM_MESSAGE_STICKER".localized()
                                    }else if customMessage.type == "extension_whiteboard" {
                                        message.text = "CUSTOM_MESSAGE_WHITEBOARD".localized()
                                    }else if customMessage.type == "extension_document" {
                                        message.text = "CUSTOM_MESSAGE_DOCUMENT".localized()
                                    }else if customMessage.type == "meeting" {
                                        message.text = "HAS_INITIATED_GROUP_AUDIO_CALL".localized()
                                    }
                                    
                                }else{
                                    message.text = "CUSTOM_MESSAGE".localized()
                                }
                                
                            case .custom where currentConversation.conversationType == .group:
                                if let customMessage = currentConversation.lastMessage as? CustomMessage {
                                    if customMessage.type == "location" {
                                        message.text = senderName! + ":  " + "CUSTOM_MESSAGE_LOCATION".localized()
                                    }else if customMessage.type == "extension_poll" {
                                        message.text = senderName! + ":  " + "CUSTOM_MESSAGE_POLL".localized()
                                    }else if customMessage.type == "extension_sticker" {
                                        message.text =  senderName! + ":  " + "CUSTOM_MESSAGE_STICKER".localized()
                                    }else if customMessage.type == "extension_whiteboard" {
                                        message.text = senderName! + ":  " + "CUSTOM_MESSAGE_WHITEBOARD".localized()
                                    }else if customMessage.type == "extension_document" {
                                        message.text = senderName! + ":  " + "CUSTOM_MESSAGE_DOCUMENT".localized()
                                    }else if customMessage.type == "meeting" {
                                        message.text = senderName! + ":  " + "HAS_INITIATED_GROUP_AUDIO_CALL".localized()
                                    }
                                }else{
                                    message.text = senderName! +  ":  " +  "CUSTOM_MESSAGE".localized()
                                }
                            case .groupMember, .text, .image, .video,.audio, .file,.custom: break
                            @unknown default: break
                            }
                        }
                    case .action:
                        if currentConversation.conversationType == .user {
                            if  let text = (currentConversation.lastMessage as? ActionMessage)?.message as NSString? {
                                message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                            }
                        }
                        if currentConversation.conversationType == .group {
                            if  let text = ((currentConversation.lastMessage as? ActionMessage)?.message ?? "") as NSString? {
                                message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                            }
                        }
                        if #available(iOS 13.0, *) {
                            message.textColor = .label
                        } else {
                            message.textColor = .black
                        }
                    case .call:
                        message.text = "HAS_SENT_A_CALL".localized()
                    case .custom where currentConversation.conversationType == .user:
                        
                        if let customMessage = currentConversation.lastMessage as? CustomMessage {
                            if customMessage.type == "location" {
                                message.text = "CUSTOM_MESSAGE_LOCATION".localized()
                            }else if customMessage.type == "extension_poll" {
                                message.text = "CUSTOM_MESSAGE_POLL".localized()
                            }else if customMessage.type == "extension_sticker" {
                                message.text =   "CUSTOM_MESSAGE_STICKER".localized()
                           }else if customMessage.type == "extension_whiteboard" {
                            message.text = "CUSTOM_MESSAGE_WHITEBOARD".localized()
                        }else if customMessage.type == "extension_document" {
                            message.text = "CUSTOM_MESSAGE_DOCUMENT".localized()
                        }else if customMessage.type == "meeting" {
                            message.text = "HAS_INITIATED_GROUP_AUDIO_CALL".localized()
                        }
                        }
                        
                    case .custom where currentConversation.conversationType == .group:
                        if let customMessage = currentConversation.lastMessage as? CustomMessage {
                            if customMessage.type == "location" {
                                message.text = senderName! + ":  " + "CUSTOM_MESSAGE_LOCATION".localized()
                            }else if customMessage.type == "extension_poll" {
                                message.text = senderName! + ":  " + "CUSTOM_MESSAGE_POLL".localized()
                            }else if customMessage.type == "extension_sticker" {
                                message.text =  senderName! + ":  " + "CUSTOM_MESSAGE_STICKER".localized()
                           }else if customMessage.type == "extension_whiteboard" {
                            message.text = senderName! + ":  " + "CUSTOM_MESSAGE_WHITEBOARD".localized()
                        }else if customMessage.type == "extension_document" {
                            message.text = senderName! + ":  " + "CUSTOM_MESSAGE_DOCUMENT".localized()
                        }else if customMessage.type == "meeting" {
                            message.text = senderName! + ":  " + "HAS_INITIATED_GROUP_AUDIO_CALL".localized()
                        }
                        }
                    @unknown default:
                        break
                    }
                    
                    if currentMessage.readAt > 0.0  {
                        read.image = UIImage(named: "message-read", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        read.isHidden = false
                        read.tintColor = UIKitSettings.primaryColor
                    }else if currentMessage.deliveredAt > 0.0  {
                        read.image = UIImage(named: "message-delivered", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        read.isHidden = false
                        read.tintColor = UIKitSettings.secondaryColor
                    }else if currentMessage.sentAt > 0  {
                        read.image = UIImage(named: "message-sent", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
                        read.isHidden = false
                        read.tintColor = UIKitSettings.secondaryColor
                    }else{
                        read.isHidden = true
                    }
                    if currentMessage.parentMessageId != 0 {
                        isThread.isHidden = false
                    }else {
                        isThread.isHidden = true
                    }
                }else{
                    read.isHidden = true
                }
                if #available(iOS 13.0, *) {
                    message.textColor = .label
                } else {
                    message.textColor = .black
                }
                timeStamp.text = String().setConversationsTime(time: Int(currentConversation.updatedAt))
                
                unreadBadgeCount.set(count: currentConversation.unreadMessageCount)
            }
        }
    }
    
    override func prepareForReuse() {
        conversation = nil
        searchedText = ""
    }
    
    // MARK: - Initialization of required Methods
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    // MARK: - Private Instance Methods
    
    /// This method bold the text which is added in Search bar.
    /// - Parameters:
    ///   - fullString: Contains full string
    ///   - boldPartOfString: contains searched text string
    ///   - font: normal font
    ///   - boldFont: bold font
     func addBoldText(fullString: NSString, boldPartOfString: NSString, font: UIFont!, boldFont: UIFont!) -> NSAttributedString {
        let nonBoldFontAttribute = [NSAttributedString.Key.font:font!]
        let boldFontAttribute = [NSAttributedString.Key.font:boldFont!]
        let boldString = NSMutableAttributedString(string: fullString as String, attributes:nonBoldFontAttribute)
        boldString.addAttributes(boldFontAttribute, range: fullString.range(of: boldPartOfString as String, options: .caseInsensitive))
        return boldString
    }


/*  ----------------------------------------------------------------------------------------- */


func parseProfanityFilter(forMessage: TextMessage){
    if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let profanityFilterDictionary = cometChatExtension["profanity-filter"] as? [String : Any] {
        
        if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {
            
            if profanity == "yes" {
                switch forMessage.messageType {
                case .text where forMessage.receiverType == .user:
                    
                    if  let text = filteredMessage as NSString? {
                        message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                    }
                    
                case .text where forMessage.receiverType == .group:
                    let senderName = forMessage.sender?.name
                    if  let text = senderName! + ":  " + filteredMessage as NSString? {
                        message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                    }
                    
                case .text, .image, .video, .audio, .file, .custom,.groupMember: break
                @unknown default: break
                }
            }else{
                switch forMessage.messageType {
                case .text where forMessage.receiverType == .user:
                    message.attributedText =  addBoldText(fullString: forMessage.text as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                case .text where forMessage.receiverType == .group:
                    let senderName = forMessage.sender?.name
                    if  let text = senderName! + ":  " + filteredMessage as NSString? {
                        message.attributedText =  addBoldText(fullString: forMessage.text as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                    }
                case .text, .image, .video, .audio, .file, .custom,.groupMember: break
                }
            }
        }else{
            switch forMessage.messageType {
            case .text where forMessage.receiverType == .user:
                message.attributedText =  addBoldText(fullString: forMessage.text as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
            case .text where forMessage.receiverType == .group:
                let senderName = forMessage.sender?.name
                if  let text = senderName! + ":  " + forMessage.text as NSString? {
                    message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                }
            case .text, .image, .video, .audio, .file, .custom,.groupMember: break
            }
        }
    }else{
        switch forMessage.messageType {
        case .text where forMessage.receiverType == .user:
            message.attributedText =  addBoldText(fullString: forMessage.text as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
        case .text where forMessage.receiverType == .group:
            let senderName = forMessage.sender?.name
            if  let text = senderName! + ":  " + forMessage.text as NSString? {
                message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
            }
        case .text, .image, .video, .audio, .file, .custom,.groupMember: break
        }
    }
}

func parseMaskedData(forMessage: TextMessage){
 if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let dataMaskingDictionary = cometChatExtension["data-masking"] as? [String : Any] {
    
     if let data = dataMaskingDictionary["data"] as? [String:Any], let sensitiveData = data["sensitive_data"] as? String {
         
         if sensitiveData == "yes" {
             if let maskedMessage = data["message_masked"] as? String {
                
                switch forMessage.messageType {
                case .text where forMessage.receiverType == .user:
                    
                    if  let text = maskedMessage as NSString? {
                        message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                    }
                    
                case .text where forMessage.receiverType == .group:
                    let senderName = forMessage.sender?.name
                    if  let text = senderName! + ":  " + maskedMessage as NSString? {
                        message.attributedText =  addBoldText(fullString: text, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
                    }
                    
                case .text, .image, .video, .audio, .file, .custom,.groupMember: break
                @unknown default: break
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
 }else{
    self.parseProfanityFilter(forMessage: forMessage)
 }
}

 func parseSentimentAnalysis(forMessage: TextMessage){
    if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let sentimentAnalysisDictionary = cometChatExtension["sentiment-analysis"] as? [String : Any] {
        if let sentiment = sentimentAnalysisDictionary["sentiment"] as? String {
            if sentiment == "negative" {
               
                message.attributedText =  addBoldText(fullString: "MAY_CONTAIN_NEGATIVE_SENTIMENT".localized() as NSString, boldPartOfString: searchedText as NSString, font: normalSubtitlefont, boldFont: boldSubtitlefont)
               
            }else{
                self.parseProfanityFilter(forMessage: forMessage)
                self.parseMaskedData(forMessage: forMessage)
            }
        }else{
            self.parseProfanityFilter(forMessage: forMessage)
            self.parseMaskedData(forMessage: forMessage)
        }
    }else{
        if #available(iOS 13.0, *) {
            message.textColor = .label
        } else {
            message.textColor = .black
        }
        message.font =  UIFont.systemFont(ofSize: 17, weight: .regular)
      
        self.parseProfanityFilter(forMessage: forMessage)
        self.parseMaskedData(forMessage: forMessage)
    }
}
    
}
