
//  CometChatReceiverLinkPreviewBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import WebKit
import CometChatPro

// MARK: - Importing Protocols.

 protocol LinkPreviewDelegate {
    func didVisitButtonPressed(link: String,sender: UIButton)
    func didPlayButtonPressed(link: String,sender: UIButton)
}

/*  ----------------------------------------------------------------------------------------- */

class CometChatReceiverLinkPreviewBubble: UITableViewCell, WKNavigationDelegate {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: CometChatMessageReactions!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var linkDescription: UILabel!
    @IBOutlet weak var visitButton: UIButton!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var messageStack: UIStackView!
    @IBOutlet weak var message: HyperlinkLabel!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var playbutton: UIButton!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var nameView: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var tintedView: UIView!
    @IBOutlet weak var replyButton: UIButton!
    
    // MARK: - Declaration of Variables
    var indexPath: IndexPath?
    var selectionColor: UIColor {
        set {
            let view = UIView()
            view.backgroundColor = newValue
            self.selectedBackgroundView = view
        }
        get {
            return self.selectedBackgroundView?.backgroundColor ?? UIColor.clear
        }
    }
    
    var url:String?
    var linkPreviewDelegate: LinkPreviewDelegate?
    weak var hyperlinkdelegate: HyperLinkDelegate?
    var linkPreviewMessage: TextMessage! {
        didSet{
            self.reactionView.parseMessageReactionForMessage(message: linkPreviewMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if let avatarURL = linkPreviewMessage.sender?.avatar  {
                avatar.set(image: avatarURL, with: linkPreviewMessage.sender?.name ?? "")
            }else{
                avatar.set(image: "", with: linkPreviewMessage.sender?.name ?? "")
            }
            if let userName = linkPreviewMessage.sender?.name {
                name.text = userName + ":"
            }
            if linkPreviewMessage.receiverType == .group {
              nameView.isHidden = false
            }else {
                nameView.isHidden = true
            }
            receiptStack.isHidden = true
            message.text = linkPreviewMessage.text
            parseLinkPreviewForMessage(message: linkPreviewMessage)
            parseMaskedData(forMessage: linkPreviewMessage)
            if let url = url {
                if url.contains("youtube")  ||  url.contains("youtu.be") {
                    visitButton.setTitle("VIEW_ON_YOUTUBE".localized(), for: .normal)
                    playbutton.isHidden = false
                }else{
                    visitButton.setTitle("Visit".localized(), for: .normal)
                    playbutton.isHidden = true
                }
            }
            if message.text?.count == 0 {
                messageStack.isHidden = true
            }else{
                messageStack.isHidden = false
            }
            timeStamp.text = String().setMessageTime(time: linkPreviewMessage.sentAt)
            if message.text?.count == 0 { messageStack.isHidden = true
            }else{ messageStack.isHidden = false }
            icon.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 15)
            iconView.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 15)
            visitButton.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: 15)
            
            FeatureRestriction.isThreadedMessagesEnabled { (success) in
                switch success {
                case .enabled where self.linkPreviewMessage.replyCount != 0 :
                    self.replyButton.isHidden = false
                    if self.linkPreviewMessage.replyCount == 1 {
                        self.replyButton.setTitle("ONE_REPLY".localized(), for: .normal)
                    }else{
                        if let replies = self.linkPreviewMessage.replyCount as? Int {
                            self.replyButton.setTitle("\(replies) replies", for: .normal)
                        }
                    }
                case .disabled, .enabled : self.replyButton.isHidden = true
                }
            }
            replyButton.tintColor = UIKitSettings.primaryColor
            
            
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
    
    var linkPreviewMessageInThread: TextMessage! {
          didSet{
              receiptStack.isHidden = true
            
            if let userName = linkPreviewMessageInThread.sender?.name {
                name.text = userName + ":"
            }
            if let avatarURL = linkPreviewMessageInThread.sender?.avatar  {
                avatar.set(image: avatarURL, with: linkPreviewMessageInThread.sender?.name ?? "")
            }else{
                avatar.set(image: "", with: linkPreviewMessageInThread.sender?.name ?? "")
            }
            self.reactionView.parseMessageReactionForMessage(message: linkPreviewMessageInThread) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
              parseLinkPreviewForMessage(message: linkPreviewMessageInThread)
              parseMaskedData(forMessage: linkPreviewMessageInThread)
              if let url = url {
                  if url.contains("youtube")  ||  url.contains("youtu.be") {
                      visitButton.setTitle("VIEW_ON_YOUTUBE".localized(), for: .normal)
                      playbutton.isHidden = false
                  }else{
                      visitButton.setTitle("Visit".localized(), for: .normal)
                      playbutton.isHidden = true
                  }
              }
              if message.text?.count == 0 {
                  messageStack.isHidden = true
              }else{
                  messageStack.isHidden = false
              }
              message.text = linkPreviewMessageInThread.text
              
              icon.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 15)
              iconView.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 15)
              visitButton.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: 15)
              if linkPreviewMessageInThread.readAt > 0 {
                  timeStamp.text = String().setMessageTime(time: Int(linkPreviewMessageInThread?.readAt ?? 0))
              }else if linkPreviewMessageInThread.deliveredAt > 0 {
                  timeStamp.text = String().setMessageTime(time: Int(linkPreviewMessageInThread?.deliveredAt ?? 0))
              }else if linkPreviewMessageInThread.sentAt > 0 {
                  timeStamp.text = String().setMessageTime(time: Int(linkPreviewMessageInThread?.sentAt ?? 0))
              }else if linkPreviewMessageInThread.sentAt == 0 {
                  timeStamp.text = "SENDING".localized()
                  name.text = LoggedInUser.name.capitalized + ":"
              }
               nameView.isHidden = false
              replyButton.isHidden = true
            
            
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
    
     // MARK: - Private Instance Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
             if let message = linkPreviewMessage, let indexpath = indexPath {
                 CometChatThreadedMessageList.threadDelegate?.startThread(forMessage: message, indexPath: indexpath)
             }

         }
    /**
    This method used to parse the linkPreview data from TextMessage Object
     - Parameter message: This specifies `TextMessage` Object.
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
      */
    private func parseLinkPreviewForMessage(message: TextMessage){
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String : Any], let linkArray = linkPreviewDictionary["links"] as? [[String: Any]] {
            
            guard let linkPreview = linkArray[safe: 0] else {
              return
            }
            
            if let linkTitle = linkPreview["title"] as? String {
                title.text = linkTitle
            }

            if let description = linkPreview["description"] as? String {
                linkDescription.text = description
            }
            
            if let thumbnail = linkPreview["image"] as? String {
                let url = URL(string: thumbnail)
                icon.cf.setImage(with: url, placeholder: UIImage(named: "default-image.png", in: UIKitSettings.bundle, compatibleWith: nil))
            }
            
            if let linkURL = linkPreview["url"] as? String {
                self.url = linkURL
            }
        }
    }
    
    /**
    This method will trigger when user pressed on visit button.
     - Parameter sender: This specifies an user who is pressing this button
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
      */
    @IBAction func visitButtonPressed(_ sender: Any) {
        if let url = url {
            linkPreviewDelegate?.didVisitButtonPressed(link: url,sender: sender as! UIButton)
        }
    }
    
    /**
    This method will trigger when user pressed on play button.
     - Parameter sender: This specifies an user who is pressing this button
    - Author: CometChat Team
    - Copyright:  ©  2020 CometChat Inc.
      */
    @IBAction func didPlaybuttonPressed(_ sender: Any) {
        if let url = url {
            linkPreviewDelegate?.didPlayButtonPressed(link: url, sender: sender as! UIButton)
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
    
}



/*  ----------------------------------------------------------------------------------------- */
