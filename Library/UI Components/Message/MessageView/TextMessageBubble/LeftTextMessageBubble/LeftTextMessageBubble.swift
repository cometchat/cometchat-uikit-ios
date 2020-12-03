
//  LeftTextMessageBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

protocol LeftTextMessageBubbleDelegate: AnyObject {
    func didTapOnSentimentAnalysisViewForLeftBubble(indexPath: IndexPath)
}



/*  ----------------------------------------------------------------------------------------- */

class LeftTextMessageBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var replybutton: UIButton!
    @IBOutlet weak var messageView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var avatar: Avatar!
    @IBOutlet weak var message: HyperlinkLabel!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var messageStack: UIStackView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var topConstraint: NSLayoutConstraint!
    @IBOutlet weak var sentimentAnalysisView: UIView!
    @IBOutlet weak var spaceConstraint: NSLayoutConstraint!
    @IBOutlet weak var widthconstraint: NSLayoutConstraint!
    
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    weak var delegate: LeftTextMessageBubbleDelegate?
    weak var hyperlinkdelegate: HyperLinkDelegate?
    let systemLanguage = Locale.preferredLanguages.first
    unowned var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.white
        }
    }
    
    
    weak var textMessage: TextMessage? {
        didSet {
            if let currentMessage = textMessage {
                receiptStack.isHidden = true
                if let userName = currentMessage.sender?.name {
                    name.text = userName + ":"
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
                if textMessage?.replyCount != 0 && UIKitSettings.threadedChats == .enabled {
                    replybutton.isHidden = false
                    if textMessage?.replyCount == 1 {
                        replybutton.setTitle("1 reply", for: .normal)
                    }else{
                        if let replies = textMessage?.replyCount {
                            replybutton.setTitle("\(replies) replies", for: .normal)
                        }
                    }
                }else{
                    replybutton.isHidden = true
                }
                
                if currentMessage.receiverType == .group {
                    nameView.isHidden = false
                }else {
                    nameView.isHidden = true
                }
                if let avatarURL = currentMessage.sender?.avatar  {
                    avatar.set(image: avatarURL, with: currentMessage.sender?.name ?? "")
                }
                timeStamp.text = String().setMessageTime(time: currentMessage.sentAt)
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
    }
    
    weak var textMessageInThread: TextMessage? {
        didSet {
            if let textmessage  = textMessageInThread {
                self.reactionView.parseMessageReactionForMessage(message: textmessage) { (success) in
                    if success == true {
                        self.reactionView.isHidden = false
                    }else{
                        self.reactionView.isHidden = true
                    }
                }
                self.receiptStack.isHidden = true
                self.parseProfanityFilter(forMessage: textmessage)
                self.parseSentimentAnalysis(forMessage: textmessage)
                self.parseMaskedData(forMessage: textmessage)
                if textmessage.readAt > 0 {
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.readAt ?? 0))
                }else if textmessage.deliveredAt > 0 {
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.deliveredAt ?? 0))
                }else if textmessage.sentAt > 0 {
                    timeStamp.text = String().setMessageTime(time: Int(textMessage?.sentAt ?? 0))
                }else if textmessage.sentAt == 0 {
                    timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
                    name.text = LoggedInUser.name.capitalized + ":"
                }
            }
            receiptStack.isHidden = true
            if #available(iOS 13.0, *) {
                message.textColor = .label
            } else {
                message.textColor = .black
            }
            nameView.isHidden = false
            replybutton.isHidden = true
            if let userName = textMessageInThread?.sender?.name {
                name.text = userName + ":"
            }
            if let avatarURL = textMessageInThread?.sender?.avatar  {
                avatar.set(image: avatarURL, with: textMessageInThread?.sender?.name ?? "")
            }
            
            
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
            self.replybutton.isHidden = true
            sentimentAnalysisView.isHidden = true
            spaceConstraint.constant = 0
            widthconstraint.constant = 0
            if let currentMessage = deletedMessage {
                if let userName = currentMessage.sender?.name {
                    name.text = userName + ":"
                }
                
                if (currentMessage.sender?.name) != nil {
                    switch currentMessage.messageCategory {
                    case .message:
                        switch currentMessage.messageType {
                        case .text:  message.text =  NSLocalizedString("THIS_MESSAGE_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        case .image: message.text = NSLocalizedString("THIS_IMAGE_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        case .video: message.text = NSLocalizedString("THIS_VIDEO_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        case .audio: message.text =  NSLocalizedString("THIS_AUDIO_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        case .file:  message.text = NSLocalizedString("THIS_FILE_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        case .custom: message.text = NSLocalizedString("THIS_CUSTOM_MESSAGE_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        case .groupMember: break
                        @unknown default: break }
                    case .action: break
                    case .call: break
                    case .custom:
                    if let customMessage = currentMessage as? CustomMessage {
                        if customMessage.type == "location" {
                            message.text =  NSLocalizedString("THIS_LOCATION_MESSAGE_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        }else if customMessage.type == "extension_poll" {
                            message.text =  NSLocalizedString("THIS_POLL_MESSAGE_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        }else if customMessage.type == "extension_sticker" {
                            message.text =  NSLocalizedString("THIS_STICKER_MESSAGE_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        }else{
                            message.text = NSLocalizedString("THIS_CUSTOM_MESSAGE_DELETED", bundle: UIKitSettings.bundle, comment: "")
                        }
                    }
                    @unknown default: break
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
                }
                timeStamp.text = String().setMessageTime(time: Int(currentMessage.sentAt))
                if #available(iOS 13.0, *) {
                    message.textColor = .label
                } else {
                    message.textColor = .black
                }
                message.font = UIFont.italicSystemFont(ofSize: 17)
            }
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        textMessage = nil
        deletedMessage = nil
    }
    
    @IBAction func didViewButtonPressed(_ sender: Any) {
        if let indexPAth = indexPath {
            delegate?.didTapOnSentimentAnalysisViewForLeftBubble(indexPath: indexPAth)
        }
    }
    
    
    @IBAction func didReplyButtonPressed(_ sender: Any) {
        if let message = textMessage, let indexpath = indexPath {
            CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
        }
    }
    
      override func setHighlighted(_ highlighted: Bool, animated: Bool) {
                  super.setHighlighted(highlighted, animated: animated)
                  if #available(iOS 13.0, *) {
                      
                  } else {
                   messageView.backgroundColor =  .lightGray
                  }
                  
              }

              override func setSelected(_ selected: Bool, animated: Bool) {
                  super.setSelected(selected, animated: animated)
                  if #available(iOS 13.0, *) {
                      
                  } else {
                     messageView.backgroundColor =  .lightGray
                  }
              }
    
    /**
     This method used to set the image for LeftTextMessageBubble class
     - Parameter image: This specifies a `URL` for  the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
     func set(Image: UIImageView, forURL url: String) {
        let url = URL(string: url)
        Image.cf.setImage(with: url)
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
                       message.font =  UIFont.systemFont(ofSize: 17, weight: .regular)
                   }
                 
               }else{
                   message.font =  UIFont.systemFont(ofSize: 17, weight: .regular)
               }
               self.message.text = forMessage.text
           }
       }
    
    func parseMaskedData(forMessage: TextMessage){
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let dataMaskingDictionary = cometChatExtension["data-masking"] as? [String : Any] {
            print("forMessage: \(forMessage.stringValue())")
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
                       message.text = NSLocalizedString("MAY_CONTAIN_NEGATIVE_SENTIMENT", bundle: UIKitSettings.bundle, comment: "")
                       spaceConstraint.constant = 10
                       widthconstraint.constant = 45
                   }else{
                       if #available(iOS 13.0, *) {
                           message.textColor = .label
                       } else {
                           message.textColor = .black
                       }
                       message.font = UIFont.systemFont(ofSize: 17, weight: .regular)
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
    
}


/*  ----------------------------------------------------------------------------------------- */


