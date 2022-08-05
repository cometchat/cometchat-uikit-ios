//
//  Self.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import UIKit
import MessageUI
import CometChatPro

class CometChatTextAutoSizeBubble: UITableViewCell, MFMailComposeViewControllerDelegate {
    
    @IBOutlet weak var alightmentStack: UIStackView!
    @IBOutlet weak var avatar: CometChatAvatar!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var sentimentAnalysisView: UIView!
    @IBOutlet weak var message: HyperlinkLabel!
    @IBOutlet weak var spacer: UIView!
    @IBOutlet weak var sentimentAnalysisButton: UIButton!
    @IBOutlet weak var sentimentAnalysisButtonLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var sentimentAnalysisButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var topTime: CometChatDate!
    @IBOutlet weak var time: CometChatDate!
    @IBOutlet weak var leadingReplyButton: UIButton!
    @IBOutlet weak var trailingReplyButton: UIButton!
    @IBOutlet weak var receipt: CometChatMessageReceipt!
    @IBOutlet weak var receiptStack: UIStackView!
    @IBOutlet weak var reactions: CometChatMessageReactions!
    @IBOutlet weak var containerStackView: UIStackView!
    @IBOutlet weak var heightReactions: NSLayoutConstraint!
    @IBOutlet var widthReactions: NSLayoutConstraint!
    @IBOutlet weak var linkPreview: UIStackView!
    @IBOutlet weak var thumbnail: UIImageView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subTitle: UILabel!
    @IBOutlet weak var textMessageStackView: UIStackView!
    @IBOutlet weak var linkPreviewMessage: HyperlinkLabel!
    @IBOutlet weak var avatarWidth: NSLayoutConstraint!
    
    //var messageListAlignment: MessageAlignment = .standard
    var indexPath: IndexPath?
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
    var configuration: CometChatConfiguration?
    var configurations: [CometChatConfiguration]?
    var sentMessageInputData: SentMessageInputData?
    var receivedMessageInputData: ReceivedMessageInputData?
    var customViews: [String: ((BaseMessage) -> (UIView))?] = [:]
    private var allMessageOptions = [String: [CometChatMessageOption]]()
    var controller: UIViewController?
    var messageListAlignment: UIKitConstants.MessageListAlignmentConstants = .standard
    var messageOptions: [CometChatMessageOption] = []
    var deleteBubble: CometChatDeleteBubble!
    var linkPreviewURL: String?
    private var imageRequest: Cancellable?
    private lazy var imageService = ImageService()
    
//    @discardableResult
//    @objc public func set(corner: CometChatCorner) -> Self {
//        switch corner.corner {
//        case .leftTop:
//            self.background.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
//        case .rightTop:
//            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
//        case .leftBottom:
//            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
//        case .rightBottom:
//            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner], radius: corner.radius)
//        case .none:
//            self.background.roundViewCorners([.layerMinXMinYCorner,.layerMinXMaxYCorner,.layerMaxXMinYCorner,.layerMaxXMaxYCorner], radius: corner.radius)
//        }
//       
//        return self
//    }
    
    @discardableResult
    @objc public func set(configuration: CometChatConfiguration) -> Self {
        self.configuration = configuration
        return self
    }
    
    @discardableResult
    public func set(configurations: [CometChatConfiguration]) ->  Self {
        self.configurations = configurations
        return self
    }
    
    @discardableResult
    public func set(allMessageOptions: [String: [CometChatMessageOption]]) -> Self {
        self.allMessageOptions = allMessageOptions
        return self
    }
    
    @discardableResult
    @objc public func set(controller: UIViewController) -> Self {
        self.controller = controller
        return self
    }
    
    @discardableResult
    public func set(messageAlignment: UIKitConstants.MessageListAlignmentConstants) -> Self {
        self.messageListAlignment = messageAlignment
        switch messageAlignment {
        case .standard:
            set(timeAlignment: .bottom)
        case .leftAligned:
            set(timeAlignment: .top)
        }
        return self
    }
    
    @discardableResult
    public func set(time: Int) -> Self {
        self.time.set(time: time, forType: .MessageBubbleDate)
        self.topTime.set(time: time, forType: .MessageBubbleDate)
        return self
    }
    
    @discardableResult
    public func set(timeAlignment: UIKitConstants.MessageBubbleTimeAlignmentConstants) -> Self {
        switch timeAlignment {
        case .top:
            self.time.isHidden = true
            self.topTime.isHidden = false
        case .bottom:
            self.time.isHidden = false
            self.topTime.isHidden = true
        }
        return self
    }
    
    @discardableResult
    @objc public func set(messageObject: TextMessage) -> Self {
        configureCell(baseMessage: messageObject)
        return self
    }
    
    @discardableResult
    @objc public func set(userName: String) -> Self {
        self.name.text = userName
        return self
    }
    
    @discardableResult
    @objc public func set(userNameFont: UIFont) -> Self {
        self.name.font = userNameFont
        return self
    }
    
    @discardableResult
    @objc public func set(userNameColor: UIColor) -> Self {
        self.name.textColor = userNameColor
        return self
    }
    
    @discardableResult
    @objc public func set(backgroundRadius: CGFloat) -> Self {
        containerStackView.layer.cornerRadius = backgroundRadius
        containerStackView.clipsToBounds = true
        return self
    }
    
    @discardableResult
    @objc public func set(reactions forMessage: BaseMessage, with alignment: UIKitConstants.MessageBubbleAlignmentConstants) -> Self {
        self.reactions.parseMessageReactionForMessage(message: forMessage) { (success) in
            if success == true {
                if alignment == .right {
                    self.reactions.collectionView.semanticContentAttribute = .forceRightToLeft
                }
                self.reactions.isHidden = false
            }else{
                self.reactions.isHidden = false
            }
        }
        return self
    }
    
    @discardableResult
    @objc public func set(sentMessageInputData: SentMessageInputData) -> Self {
        self.sentMessageInputData = sentMessageInputData
        return self
    }
    
    @discardableResult
    @objc public func set(receivedMessageInputData: ReceivedMessageInputData) -> Self {
        self.receivedMessageInputData = receivedMessageInputData
        return self
    }

    @discardableResult
    public func hide(avatar: Bool) ->  Self {
        self.avatar.isHidden = avatar
        self.avatarWidth.constant = 0
        return self
    }
    
    @discardableResult
    public func hide(time: Bool) ->  Self {
        self.time.isHidden = time
        self.topTime.isHidden = time
        return self
    }
    
    @discardableResult
    public func hide(title: Bool) ->  Self {
        self.name.isHidden = title
        return self
    }
    
    @discardableResult
    public func hide(receipt: Bool) ->  Self {
        self.receipt.isHidden = receipt
        return self
    }
    
    @discardableResult
    public func set(containerBG: UIColor) ->  Self {
        containerStackView.addBackground(color:containerBG)
        return self
    }
    
    private func configureMessageBubble(forMessage: BaseMessage) {
       
        if let configurations = configurations {
            if let messageListConfiguration = configurations.filter({ $0 is MessageListConfiguration}).last as? MessageListConfiguration , let messageBubbleConfiguration =  messageListConfiguration.messageBubbleConfiguration {
            
                if let configuration = messageBubbleConfiguration.avatarConfiguration {
                    avatar.set(cornerRadius: configuration.cornerRadius)
                    avatar.set(borderWidth: configuration.borderWidth)
                    if configuration.outerViewWidth != 0 {
                        avatar.set(outerView: true)
                        avatar.set(borderWidth: configuration.outerViewWidth)
                    }
                    self.set(avatar: avatar)
                }
                
                if let configuration = messageBubbleConfiguration.messageReceiptConfiguration {
                    self.receipt.set(messageInProgressIcon: configuration.getProgressIcon())
                    self.receipt.set(messageSentIcon: configuration.getSentIcon())
                    self.receipt.set(messageDeliveredIcon: configuration.getDeliveredIcon())
                    self.receipt.set(messageReadIcon: configuration.getReadIcon())
                    self.receipt.set(messageErrorIcon: configuration.getFailureIcon())
                }
                
                if let sentMessageInputData = messageBubbleConfiguration.sentMessageInputData {
                    self.set(sentMessageInputData: sentMessageInputData)
                }
                
                if let receivedMessageInputData = messageBubbleConfiguration.receivedMessageInputData {
                    self.set(receivedMessageInputData: receivedMessageInputData)
                }
                print(messageBubbleConfiguration.timeAlignment)
                self.set(timeAlignment: messageBubbleConfiguration.timeAlignment)
                
                if let sentMessageInputData = sentMessageInputData {
                    
                    if forMessage.sender?.uid == CometChat.getLoggedInUser()?.uid {
                        
                        if let thumbail = sentMessageInputData.thumbnail {
                            hide(avatar: !thumbail)
                        }
                        
                        if let time = sentMessageInputData.timestamp {
                            hide(time: !time)
                        }
                        
                        if let title = sentMessageInputData.title {
                            hide(title: !title)
                        }
                        
                        if let receipt = sentMessageInputData.readReceipt {
                            hide(receipt: !receipt)
                        }
                        
                    }
                }
                
                if let receivedMessageInputData = receivedMessageInputData {
                    
                    if forMessage.sender?.uid != CometChat.getLoggedInUser()?.uid {
                        
                        if let thumbail = receivedMessageInputData.thumbnail {
                            hide(avatar: !thumbail)
                        }
                        
                        if let time = receivedMessageInputData.timestamp {
                            hide(time: !time)
                        }
                        
                        if let title = receivedMessageInputData.title {
                            hide(title: !title)
                        }
                        
                        if let receipt = receivedMessageInputData.readReceipt {
                            hide(receipt: !receipt)
                        }
                    }
                }
                
            }
        }else{
            
        }
        
    }
    
    @discardableResult
    public func set(messageOptions: [CometChatMessageOption]) -> Self {
        self.messageOptions = messageOptions
        return self
    }
    
    @discardableResult
    @objc public func set(attributedText: NSMutableAttributedString) -> Self {
        DispatchQueue.main.async {
            self.message.attributedText = attributedText
        }
        return self
    }
    
    private func configureCell(baseMessage message: TextMessage) {
        messageOptions.removeAll()
        set(userNameFont: CometChatTheme.typography?.Subtitle2 ?? UIFont.systemFont(ofSize: 13))
        set(userNameColor: CometChatTheme.palatte?.accent600 ?? UIColor.gray)
        set(timeFont: CometChatTheme.typography?.Caption2 ?? UIFont.systemFont(ofSize: 11))
        set(timeColor: CometChatTheme.palatte?.accent500 ?? .gray)
        reactions.isHidden = true
        self.message.isHidden = false
        
        if let controller = controller {
            reactions.set(controller: controller).set(messageObject: message)
        }
        
        set(time: message.sentAt)
        self.heightReactions.constant = 35
        set(reactions: message, with: .left)
        let isStandard = messageListAlignment == .standard && (message.sender?.uid == CometChat.getLoggedInUser()?.uid)
        setupStyle(isStandard: isStandard)
        set(messageAlignment: isStandard ? .right : .left)
        set(avatar:self.avatar.setAvatar(avatarUrl: message.sender?.avatar ?? "", with: message.sender?.name ?? ""))
        set(userName: (message.sender?.name) ?? "")
        set(backgroundRadius: 12.0)
        // To hide & show receipt
        if !isStandard {
            self.receipt.isHidden = true
        } else {
            set(receipt: receipt.set(receipt: message))
        }
        
        /// when user send custom view that are not existing type such as payment.
        if let customView = self.customViews[MessageTypesBubble.getMessageType(message: message)], let view = customView?(message){
                background.addSubview(view)
                view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    view.centerXAnchor.constraint(equalTo: background.centerXAnchor),
                    view.centerYAnchor.constraint(equalTo: background.centerYAnchor),
                    view.leadingAnchor.constraint(equalTo: background.leadingAnchor, constant: 0),
                    view.topAnchor.constraint(equalTo: background.topAnchor, constant: 0),
                    view.bottomAnchor.constraint(equalTo: background.bottomAnchor),
                    view.trailingAnchor.constraint(equalTo: background.trailingAnchor, constant: 0)
                ])
            return
        }

        self.linkPreview.isHidden = true
        self.textMessageStackView.isHidden = false
        
        let phoneParser1 = HyperlinkType.custom(pattern: RegexParser.phonePattern1)
        let phoneParser2 = HyperlinkType.custom(pattern: RegexParser.phonePattern2)
        let emailParser = HyperlinkType.custom(pattern: RegexParser.emailPattern)
        
        if let translatedMessage = message.metaData?["translated-message"] as? String {
          

            set(text: translatedMessage + "\n\n" + message.text + "\n\n" + "TRANSLATED_MESSAGE".localize())
            set(containerBG: isStandard ? (CometChatTheme.palatte?.primary)! : CometChatTheme.palatte?.secondary! ?? UIColor.systemBackground)

        } else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let linkPreviewDictionary = cometChatExtension[ExtensionConstants.linkPreview] as? [String : Any], let linkArray = linkPreviewDictionary["links"] as? [[String: Any]], !linkArray.isEmpty {
            self.linkPreview.isHidden = false
            self.textMessageStackView.isHidden = true
            
            guard let linkPreview = linkArray[safe: 0] else {
                return
            }
            
            if let linkTitle = linkPreview["title"] as? String {
                title.text = linkTitle
            }
            
            if let description = linkPreview["description"] as? String {
                subTitle.text = description
            }
            
            if let thumbnail = linkPreview["image"] as? String , let url = URL(string: thumbnail){
                self.thumbnail.isHidden = false
                self.thumbnail.image = UIImage(named: "default-image.png", in: CometChatUIKit.bundle, compatibleWith: nil)
                imageRequest = imageService.image(for: url) { [weak self] image in
                    guard let strongSelf = self else { return }
                    // Update Thumbnail Image View
                    if let image = image {
                        strongSelf.thumbnail.image = image
                    }else{
                        strongSelf.thumbnail.isHidden = true
                    }
                }
            }
            if let linkURL = linkPreview["url"] as? String {
                self.linkPreviewURL = linkURL
            }
            self.linkPreviewMessage.text = message.text
            set(containerBG: CometChatTheme.palatte!.secondary!)
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(openLink))
            tapGesture.cancelsTouchesInView = false
            self.thumbnail.isUserInteractionEnabled = true
            self.thumbnail.addGestureRecognizer(tapGesture)
            
            linkPreviewMessage.enabledTypes.append(phoneParser1)
            linkPreviewMessage.enabledTypes.append(phoneParser2)
            linkPreviewMessage.enabledTypes.append(emailParser)
            
            linkPreviewMessage.handleURLTap { link in
                UIApplication.shared.open(link)
            }
            
            linkPreviewMessage.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern1)) { (number) in
                if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .joined() as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let url = URL(string: "tel://\(number)")!
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }
            
            linkPreviewMessage.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern2)) { (number) in
                if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .joined() as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let url = URL(string: "tel://\(number)")!
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }
            
            linkPreviewMessage.handleCustomTap(for: .custom(pattern: RegexParser.emailPattern)) { (emailID) in
                
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([emailID])
                    self.controller?.present(mail, animated: true, completion: nil)
                } else {
                    
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "OK".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    confirmDialog.set(title: "WARNING".localize())
                    confirmDialog.set(messageText: "MAIL_APP_NOT_FOUND_MESSAGE".localize())
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                        
                    })
                }
            }
        }
        else {
            if CometChat.getLoggedInUser()?.uid != message.sender?.uid {
                self.parseProfanityFilter(forMessage: message)
                self.parseMaskedData(forMessage: message)
            } else {
                set(text: message.text)
                set(textFont: applyLargeSizeEmoji(forMessage: message))
            }
            set(containerBG: isStandard ? (CometChatTheme.palatte?.primary)! : CometChatTheme.palatte!.secondary!)

            
            self.message.enabledTypes.append(phoneParser1)
            self.message.enabledTypes.append(phoneParser2)
            self.message.enabledTypes.append(emailParser)
            
            self.message.handleURLTap { link in
                UIApplication.shared.open(link)
            }
            
            self.message.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern1)) { (number) in
                if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .joined() as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let url = URL(string: "tel://\(number)")!
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }
            
            self.message.handleCustomTap(for: .custom(pattern: RegexParser.phonePattern2)) { (number) in
                if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
                    .joined() as? String {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        let url = URL(string: "tel://\(number)")!
                        UIApplication.shared.open(url, options: [:])
                    }
                }
            }
            
            self.message.handleCustomTap(for: .custom(pattern: RegexParser.emailPattern)) { (emailID) in
                
                if MFMailComposeViewController.canSendMail() {
                    let mail = MFMailComposeViewController()
                    mail.mailComposeDelegate = self
                    mail.setToRecipients([emailID])
                    self.controller?.present(mail, animated: true, completion: nil)
                } else {
                    
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "OK".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    confirmDialog.set(title: "WARNING".localize())
                    confirmDialog.set(messageText: "MAIL_APP_NOT_FOUND_MESSAGE".localize())
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                        
                    })
                }
            }
            self.message.URLSelectedColor = .link
            self.message.URLColor = .link
        }
        if allMessageOptions.isEmpty {
            let defaultOptions = [
                CometChatMessageOption(defaultOption: .reaction),
                CometChatMessageOption(defaultOption: .edit),
                CometChatMessageOption(defaultOption: .copy),
                CometChatMessageOption(defaultOption: .share),
                CometChatMessageOption(defaultOption: .translate),
                CometChatMessageOption(defaultOption: .delete)
            ]
            self.set(messageOptions: defaultOptions)
        } else {
            if let fetchedOptions = allMessageOptions[UIKitConstants.MessageTypeConstants.text] {
                self.set(messageOptions: fetchedOptions)
            }
        }
        
        if configurations != nil {
            configureMessageBubble(forMessage: message)
        }
        
        let count = reactions.reactions.count
        let widthM = message.text.capitalized.width(22, font: CometChatTheme.typography!.Body) + 30.0
        print(widthM)
        
        if widthM < 228 {
            if count >= 5 {
                widthReactions.isActive = true
                widthReactions.constant = 228
            }
            else if count < 5 && count > 0 {
                let widthR =  count * 45
                widthReactions.isActive = true
                widthReactions.constant = max(widthM, CGFloat(widthR))
            } else if count == 0 {
                widthReactions.isActive = false
            }
        } else {
            widthReactions.isActive = true
            widthReactions.constant = 228
        }
        
        let numberOfItemInARow = 5
        reactions.isHidden = false
        if reactions.reactions.count.isMultiple(of: numberOfItemInARow) && reactions.reactions.count >= 5 {
            let rows = reactions.reactions.count / numberOfItemInARow
            heightReactions.constant = CGFloat(rows * Int(heightReactions.constant))
        } else if !reactions.reactions.count.isMultiple(of: numberOfItemInARow) && reactions.reactions.count >= 6 {
            let rows = reactions.reactions.count / numberOfItemInARow + 1
            heightReactions.constant = CGFloat(rows * Int(heightReactions.constant))
        } else if !reactions.reactions.count.isMultiple(of: numberOfItemInARow) && reactions.reactions.count > 1 && reactions.reactions.count < 6 {
            let rows = reactions.reactions.count / numberOfItemInARow + 1
            heightReactions.constant = CGFloat(rows * Int(heightReactions.constant))
        } else if reactions.reactions.count == 0 {
            reactions.isHidden = true
            heightReactions.constant = 0
        }
        
    }
    
    @objc private func openLink() {
        if let linkPreviewURL = linkPreviewURL {
            guard let url = URL(string: linkPreviewURL) else { return }
            UIApplication.shared.open(url)
        }
    }
    
    private func setupStyle(isStandard: Bool) {
        let textStyle = TextBubbleStyle(titleColor: CometChatTheme.palatte?.accent900, titleFont: CometChatTheme.typography?.Subtitle1, subTitleFont: CometChatTheme.typography?.Subtitle2, subTitleColor: CometChatTheme.palatte?.accent700, messageTextFont: CometChatTheme.typography?.Body, messageTextColor: isStandard ? CometChatTheme.palatte?.background : CometChatTheme.palatte?.accent900, linkPreviewMessageFont: CometChatTheme.typography?.Subtitle1, linkPreviewMessageColor: CometChatTheme.palatte?.accent900)
        set(style: textStyle)
    }
    
    @discardableResult
    public func set(style: TextBubbleStyle) -> Self {
        self.set(textColor: style.messageTextColor!)
        self.set(textFont: style.messageTextFont!)
        self.set(titleFont: style.titleFont!)
        self.set(titleColor: style.titleColor!)
        self.set(subTitleFont: style.subTitleFont!)
        self.set(subTitleColor: style.subTitleColor!)
        self.set(linkPreviewMessageFont: style.linkPreviewMessageFont!)
        self.set(linkPreviewMessageColor: style.linkPreviewMessageColor!)
        return self
    }
    
    @discardableResult
    public func set(backgroundColor: [Any]?) ->  Self {
        if let backgroundColors = backgroundColor as? [CGColor] {
            if backgroundColors.count == 1 {
                self.containerStackView.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: backgroundColor)
            }
        }
        return self
    }
    
    @discardableResult
    @objc public func set(avatar: CometChatAvatar) -> Self {
        self.avatar = avatar
        return self
    }
    
    @discardableResult
    @objc public func set(text: String) -> Self {
        self.message.text = text
        return self
    }
    
    @discardableResult
    @objc public func set(textFont: UIFont) -> Self {
        self.message.font = textFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(textColor: UIColor) -> Self {
        self.message.textColor = textColor
        return self
    }
    
    @discardableResult
    @objc public func set(titleFont: UIFont) -> Self {
        self.title.font = titleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(titleColor: UIColor) -> Self {
        self.title.textColor = titleColor
        return self
    }
    
    @discardableResult
    @objc public func set(linkPreviewMessageFont: UIFont) -> Self {
        self.linkPreviewMessage.font = linkPreviewMessageFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(linkPreviewMessageColor: UIColor) -> Self {
        self.linkPreviewMessage.textColor = linkPreviewMessageColor
        return self
    }
    
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> Self {
        self.subTitle.font = subTitleFont
        return self
    }
    
    
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> Self {
        self.subTitle.textColor = subTitleColor
        return self
    }
    
    @discardableResult
    @objc func set(borderColor : UIColor) -> Self {
        self.background.layer.borderColor = borderColor.cgColor
        return self
    }

    @discardableResult
    @objc func set(borderWidth : CGFloat) -> Self {
        self.background.layer.borderWidth = borderWidth
        return self
    }
    
    @discardableResult
    @objc public func set(receipt: CometChatMessageReceipt) -> Self {
        self.receipt = receipt
        return self
    }
    
    @discardableResult
    public func set(timeFont: UIFont) -> Self {
        self.time.font = timeFont
        self.topTime.font = timeFont
        return self
    }
    
    @discardableResult
    public func set(timeColor: UIColor) -> Self {
        self.time.textColor = timeColor
        self.topTime.textColor = timeColor
        return self
    }

    @discardableResult
    @objc public func set(messageAlignment: UIKitConstants.MessageBubbleAlignmentConstants) -> Self {
        let leftAligment = messageAlignment == .left
        name.isHidden = leftAligment ? false : true
        alightmentStack.alignment = leftAligment ? .leading : .trailing
        spacer.isHidden = leftAligment ? false : true
        avatar.isHidden = leftAligment ? false : true
        receipt.isHidden = true
        leadingReplyButton.isHidden = leftAligment ? true : true
        trailingReplyButton.isHidden = leftAligment ? true : true
        return self
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        selectionColor = CometChatTheme.palatte?.background ?? .systemBackground
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        containerStackView.subviews.forEach({ $0.backgroundColor = .clear })
        reactions.reactions.removeAll()
    }
    
    private func parseProfanityFilter(forMessage: TextMessage) {
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let profanityFilterDictionary = cometChatExtension[ExtensionConstants.profanityFilter] as? [String : Any] {
            
            if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {
                
                if profanity == "yes" {
                    let _ = NSMutableAttributedString(string: "\(filteredMessage)\n\n",
                                                                attributes: [NSAttributedString.Key.font: applyLargeSizeEmoji(forMessage: forMessage)])
                   // set(attributedText: messageText)
                   set(text: filteredMessage)
                    layoutIfNeeded()
                } else {
                    /// No profanity
                    let _ = NSMutableAttributedString(string: "\(forMessage.text)\n\n",
                                                                attributes: [NSAttributedString.Key.font: applyLargeSizeEmoji(forMessage: forMessage)])
                   // set(attributedText: messageText)
                    set(text: forMessage.text)
                    set(textFont: applyLargeSizeEmoji(forMessage: forMessage))
                }
            } else {
                /// No Profanity
                let _ = NSMutableAttributedString(string: "\(forMessage.text)\n\n",
                                                            attributes: [NSAttributedString.Key.font: applyLargeSizeEmoji(forMessage: forMessage)])
              //  set(attributedText: messageText)
                set(text: forMessage.text)
                set(textFont: applyLargeSizeEmoji(forMessage: forMessage))
            }
        } else {
            /// Simple text.
            let _ = NSMutableAttributedString(string: "\(forMessage.text)\n\n",
                                                        attributes: [NSAttributedString.Key.font: applyLargeSizeEmoji(forMessage: forMessage)])
           // set(attributedText: messageText)
            set(text: forMessage.text)
            set(textFont: applyLargeSizeEmoji(forMessage: forMessage))
        }
    }
    
    private func parseMaskedData(forMessage: TextMessage) {
        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let dataMaskingDictionary = cometChatExtension[ExtensionConstants.dataMasking] as? [String : Any] {
            
            if let data = dataMaskingDictionary["data"] as? [String:Any], let sensitiveData = data["sensitive_data"] as? String {
                
                if sensitiveData == "yes" {
                    if let maskedMessage = data["message_masked"] as? String {
                        let _ = NSMutableAttributedString(string: "\(maskedMessage)\n\n",
                                                                    attributes: [NSAttributedString.Key.font: CometChatTheme.typography!.Body])
                      //  set(attributedText: messageText)
                       set(text: maskedMessage)
                        layoutIfNeeded()
                    } else {
                        /// No Masked
                        let _ = NSMutableAttributedString(string: "\(forMessage.text)\n\n",
                                                                    attributes: [NSAttributedString.Key.font: CometChatTheme.typography!.Body])
                       // set(attributedText: messageText)
                        set(text: forMessage.text)
                        set(textFont: applyLargeSizeEmoji(forMessage: forMessage))
                    }
                } else {
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
            } else {
                return CometChatTheme.typography?.Body ?? UIFont.systemFont(ofSize: 17, weight: .regular)
            }
        }else{
            return CometChatTheme.typography?.Body ?? UIFont.systemFont(ofSize: 17, weight: .regular)
        }
    }
}
