
//  RightLinkPreviewBubble.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class RightLinkPreviewBubble: UITableViewCell {
    
    // MARK: - Declaration of IBOutlets
    
    @IBOutlet weak var reactionView: ReactionView!
    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var linkDescription: UILabel!
    @IBOutlet weak var visitButton: UIButton!
    @IBOutlet weak var timeStamp: UILabel!
    @IBOutlet weak var receipt: UIImageView!
    @IBOutlet weak var message: HyperlinkLabel!
    @IBOutlet weak var messageStack: UIStackView!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var playbutton: UIButton!
    @IBOutlet weak var iconView: UIView!
    @IBOutlet weak var replybutton: UIButton!
    
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
            receiptStack.isHidden = true
            parseLinkPreviewForMessage(message: linkPreviewMessage)
            parseMaskedData(forMessage: linkPreviewMessage)
            self.reactionView.parseMessageReactionForMessage(message: linkPreviewMessage) { (success) in
                if success == true {
                    self.reactionView.isHidden = false
                }else{
                    self.reactionView.isHidden = true
                }
            }
            if let url = url {
                if url.contains("youtube")  ||  url.contains("youtu.be") {
                    visitButton.setTitle(NSLocalizedString("VIEW_ON_YOUTUBE", bundle: UIKitSettings.bundle, comment: ""), for: .normal)
                    playbutton.isHidden = false
                }else{
                    visitButton.setTitle(NSLocalizedString("Visit", bundle: UIKitSettings.bundle, comment: ""), for: .normal)
                    playbutton.isHidden = true
                }
            }
            if message.text?.count == 0 {
                messageStack.isHidden = true
            }else{
                messageStack.isHidden = false
            }
            message.text = linkPreviewMessage.text
            
            icon.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 15)
            iconView.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 15)
            visitButton.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: 15)
            if linkPreviewMessage.readAt > 0 {
                receipt.image = UIImage(named: "read", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(linkPreviewMessage?.readAt ?? 0))
            }else if linkPreviewMessage.deliveredAt > 0 {
                receipt.image = UIImage(named: "delivered", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(linkPreviewMessage?.deliveredAt ?? 0))
            }else if linkPreviewMessage.sentAt > 0 {
                receipt.image = UIImage(named: "sent", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = String().setMessageTime(time: Int(linkPreviewMessage?.sentAt ?? 0))
            }else if linkPreviewMessage.sentAt == 0 {
                receipt.image = UIImage(named: "wait", in: UIKitSettings.bundle, compatibleWith: nil)
                timeStamp.text = NSLocalizedString("SENDING", bundle: UIKitSettings.bundle, comment: "")
            }
            replybutton.tintColor = UIKitSettings.primaryColor
            if linkPreviewMessage?.replyCount != 0 &&  UIKitSettings.threadedChats == .enabled {
                replybutton.isHidden = false
                if linkPreviewMessage?.replyCount == 1 {
                    replybutton.setTitle("1 reply", for: .normal)
                }else{
                    if let replies = linkPreviewMessage?.replyCount {
                        replybutton.setTitle("\(replies) replies", for: .normal)
                    }
                }
            }else{
                replybutton.isHidden = true
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
    
    // MARK: - Private Instance Methods
    
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
    
    /**
     This method will trigger when user pressed on visit button.
     - Parameter sender: This specifies an user who is pressing this button
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @IBAction func didVisitButtonPressed(_ sender: Any) {
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
    @IBAction func didPlayButtonPressed(_ sender: Any) {
        if let url = url {
            linkPreviewDelegate?.didPlayButtonPressed(link: url, sender: sender as! UIButton)
        }
    }
    
    // MARK: - Initialization of required Methods
    @IBAction func didReplyButtonPressed(_ sender: Any) {
             if let message = linkPreviewMessage, let indexpath = indexPath {
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
    
     override func setSelected(_ selected: Bool, animated: Bool) {
           super.setSelected(selected, animated: animated)
       }
    
    
}

/*  ----------------------------------------------------------------------------------------- */
