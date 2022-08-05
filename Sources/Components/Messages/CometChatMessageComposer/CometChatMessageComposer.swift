//
//  CometChatMessageComposer.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 08/11/21.
//  Copyright © 2021 MacMini-03. All rights reserved.
//

import Foundation
import UIKit
import CometChatPro
import AudioToolbox
import AVFoundation
import CoreLocation
import CoreLocationUI


enum MessageComposerMode {
    case draft
    case edit
    case reply
}

@objc @IBDesignable class CometChatMessageComposer: UIView  {

    // MARK: - Declaration of IBInspectable
    @IBOutlet weak var messagePreview: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var close: UIButton!

    @IBOutlet weak var seperator: UIView!
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var topView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var attachment: UIButton!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var sticker: UIButton!
    @IBOutlet weak var emoji: UIButton!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var liveReaction: UIButton!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!


    // MARK: - Declaration of Variables
    var currentTypingIndicator: TypingIndicator?
    var templates = [CometChatMessageTemplate]()
    var currentUser: User?
    var currentGroup: Group?
    var currentMessage: BaseMessage?
    var curentLocation: CLLocation?
    let locationManager = CLLocationManager()
    var actionItems: [ActionItem] = [ActionItem]()
    weak var controller: UIViewController?
    var enableTypingIndicator: Bool = true
    var placeholderText: String = "TYPE_A_MESSAGE".localize()
    var placeholderFont: UIFont =  CometChatTheme.typography?.Name2 ?? UIFont.systemFont(ofSize: 17)
    var placeholderColor: UIColor =  CometChatTheme.palatte?.accent500 ?? UIColor.gray
    var hideAttachment: Bool = false
    var plusIcon = UIImage(named: "message-composer-plus", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var attachmentIcon = UIImage(named: "message-composer-attachment", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)  ?? UIImage()
    var stickerIcon = UIImage(named: "message-composer-sticker", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)  ?? UIImage()
    var liveReactionIcon: UIImage = UIImage(named: "message-composer-heart.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var sendIcon: UIImage = UIImage(named: "message-composer-send.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()
    var closeIcon: UIImage = UIImage(named: "message-composer-close.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate) ?? UIImage()

    var hideLiveReaction: Bool = false
    var hideEmoji: Bool = false
    var hideSticker: Bool = false
    var showSendButton: Bool = true
    var messageTypes: [CometChatMessageTemplate] = []
    var excludeMessageTypes: [CometChatMessageTemplate] = []
    var customOutgoingMessageSound: URL?
    var enableSoundForMessages: Bool = true
    var messageComposerMode: MessageComposerMode =  .draft
    var configuration: CometChatConfiguration?
    var configurations: [CometChatConfiguration]?
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)

    struct CometChatMessageActionsGroup: CometChatActionPresentable {
        let string: String = "MessageActions Group"
        let rowVC: PanModalPresentable.LayoutType = CometChatActionSheet()
    }


    @discardableResult
    @objc public func set(messageTypes: [CometChatMessageTemplate]?) -> Self {
        if let messageTypes = messageTypes {
            if !messageTypes.isEmpty {
                self.messageTypes = messageTypes
            }
        }
        return self
    }


    @discardableResult
    @objc public func set(configuration: CometChatConfiguration) -> Self {
        self.configuration = configuration
        configureMessageComposer()
        return self
    }

    @discardableResult
    public func set(configurations: [CometChatConfiguration]) ->  Self {
        self.configurations = configurations
        configureMessageComposer()
        return self
    }

    struct CometChatEmojiKeyboardGroup: CometChatEmojiKeyboardPresentable {
        let string: String = "Select Emoji"
        let rowVC: PanModalPresentable.LayoutType = CometChatEmojiKeyboard()
    }


    @discardableResult
    @objc public func set(user: User) -> CometChatMessageComposer {
        self.currentUser = user
        return self
    }

    @discardableResult
    @objc public func set(group: Group) -> CometChatMessageComposer {
        self.currentGroup = group
        return self
    }

    @discardableResult
    @objc public func set(maxLines: Int) -> CometChatMessageComposer {
        self.textView.maxNumberOfLines = maxLines
        return self
    }

    @discardableResult
    @objc public func enable(typingIndicator: Bool) -> CometChatMessageComposer {
        if let currentUser = currentUser {
            currentTypingIndicator = TypingIndicator(receiverID: currentUser.uid ?? "", receiverType: .user)
        }
        if let currentGroup = currentGroup {
            currentTypingIndicator = TypingIndicator(receiverID: currentGroup.guid , receiverType: .group)
        }
        return self
    }

    @discardableResult
    public func set(background: [Any]?) ->  CometChatMessageComposer {
        if let backgroundColors = background as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: backgroundColors)
            }
        }
        return self
    }

    @discardableResult
    public func set(placeholderText: String) ->  CometChatMessageComposer {
        textView.placeholder = NSAttributedString(string:  placeholderText, attributes: [.foregroundColor: placeholderColor , .font:  placeholderFont])
        return self
    }

    @discardableResult
    public func set(placeholderFont: UIFont) ->  CometChatMessageComposer {
        self.placeholderFont = placeholderFont
        return self
    }

    @discardableResult
    public func set(placeholderColor: UIColor) ->  CometChatMessageComposer {
        self.placeholderColor = placeholderColor
        return self
    }
    
    @discardableResult
    public func set(text: String) ->  CometChatMessageComposer {
        textView.text = text
        return self
    }

    @discardableResult
    public func set(textFont: UIFont) ->  CometChatMessageComposer {
        self.textView.font = textFont
        return self
    }

    @discardableResult
    public func set(textColor: UIColor) ->  CometChatMessageComposer {
        self.textView.textColor = textColor
        return self
    }

    @discardableResult
    public func hide(attachment: Bool) ->  CometChatMessageComposer {
        self.hideAttachment = attachment
        return self
    }

    @discardableResult
    public func hide(liveReaction: Bool) ->  CometChatMessageComposer {
        self.hideLiveReaction = liveReaction
        return self
    }

    @discardableResult
    public func hide(sticker: Bool) ->  CometChatMessageComposer {
        self.hideSticker = sticker
        return self
    }

    @discardableResult
    public func enable(soundForMessages: Bool) ->  CometChatMessageComposer {
        self.enableSoundForMessages = soundForMessages
        return self
    }

    @discardableResult
    public func set(customOutgoingMessageSound: URL) ->  CometChatMessageComposer {
        self.customOutgoingMessageSound = customOutgoingMessageSound
        return self
    }

    @discardableResult
    public func show(sendButton: Bool) ->  CometChatMessageComposer {
        self.showSendButton = sendButton
        return self
    }

    @discardableResult
    public func hide(emoji: Bool) ->  CometChatMessageComposer {
        self.hideEmoji = emoji
        return self
    }
   

    @discardableResult
    public func set(excludeMessageTypes: [CometChatMessageTemplate]) -> Self {
        self.excludeMessageTypes = excludeMessageTypes
        return self
    }

    @discardableResult
    @objc public func set(plusIcon: UIImage) -> CometChatMessageComposer {
        self.plusIcon = plusIcon.withRenderingMode(.alwaysTemplate)
        self.attachment.setImage(plusIcon, for: .normal)
        return self
    }

    @discardableResult
    @objc public func set(attachmentIcon: UIImage) -> CometChatMessageComposer {
        self.attachmentIcon = attachmentIcon.withRenderingMode(.alwaysTemplate)
        self.attachment.setImage(attachmentIcon, for: .normal)
        return self
    }

    @discardableResult
    @objc public func set(stickerIcon: UIImage) -> CometChatMessageComposer {
        self.stickerIcon = stickerIcon.withRenderingMode(.alwaysTemplate)
        self.sticker.setImage(stickerIcon, for: .normal)
        return self
    }

    @discardableResult
    @objc public func set(liveReactionIcon: UIImage) -> CometChatMessageComposer {
        self.liveReactionIcon = liveReactionIcon.withRenderingMode(.alwaysTemplate)
        self.liveReaction.setImage(liveReactionIcon, for: .normal)
        return self
    }


    @discardableResult
    @objc public func set(sendIcon: UIImage) -> CometChatMessageComposer {
        self.sendIcon = sendIcon.withRenderingMode(.alwaysTemplate)
        self.send.setImage(sendIcon, for: .normal)
        return self
    }

    @discardableResult
    @objc public func set(plusIconTint: UIColor) -> CometChatMessageComposer {
        self.attachment.tintColor = plusIconTint
        return self
    }

    @discardableResult
    @objc public func set(attachmentIconTint: UIColor) -> CometChatMessageComposer {
        self.attachment.tintColor = attachmentIconTint
        return self
    }

    @discardableResult
    @objc public func set(stickerIconTint: UIColor) -> CometChatMessageComposer {
        self.sticker.tintColor = stickerIconTint
        return self
    }

    @discardableResult
    @objc public func set(liveReactionIconTint: UIColor) -> CometChatMessageComposer {
        self.liveReaction.tintColor = liveReactionIconTint
        return self
    }


    @discardableResult
    @objc public func set(sendIconTint: UIColor) -> CometChatMessageComposer {
        self.send.tintColor = sendIconTint
        return self
    }

    /**
     The title is a UILabel which specifies a title for  `ConversationListItem`.
     - Parameters:
     - title: This method will set the title for ConversationListItem.
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(title: String?) -> CometChatMessageComposer {
        self.title.text = title
        return self
    }

    /**
     This method will set the title with attributed text for `ConversationListItem`.
     - Parameters:
     - titleWithAttributedText: This method will set the title with attributed text for ConversationListItem.
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleWithAttributedText: NSAttributedString) -> CometChatMessageComposer {
        self.title.attributedText = titleWithAttributedText
        return self
    }

    /**
     This method will set the title color for `CometChatDataItem`
     - Parameters:
     - titleColor: This method will set the title color for ConversationListItem
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleColor: UIColor) -> CometChatMessageComposer {
        self.title.textColor = titleColor
        return self
    }

    /**
     This method will set the title font for `CometChatDataItem`
     - Parameters:
     - titleFont: This method will set the title font for ConversationListItem
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(titleFont: UIFont) -> CometChatMessageComposer {
        self.title.font = titleFont
        return self
    }


    /**
     The SubTitle is a UILabel that specifies a subTitle for  `CometChatDataItem`.
     - Parameters:
     - subTitle: This method will set the subtitle for ConversationListItem.
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitle: String?) -> CometChatMessageComposer {
        self.subtitle.text = subTitle
        return self
    }

    /**
     This method will set the subtitle with attributed text for  `CometChatDataItem`.
     - Parameters:
     - subTitleWithAttributedText: This method will set the subtitle with attributed text for `CometChatDataItem`.
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleWithAttributedText: NSAttributedString) -> CometChatMessageComposer {
        self.subtitle.attributedText = subTitleWithAttributedText
        return self
    }

    /**
     This method will set the subtitle color for  `CometChatDataItem`.
     - Parameters:
     - subTitleColor: This method will set the subtitle color for ConversationListItem
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleColor: UIColor) -> CometChatMessageComposer {
        self.subtitle.textColor = subTitleColor
        return self
    }

    /**
     This method will set the subtitle font for  `CometChatDataItem`.
     - Parameters:
     - subTitleFont:This method will set the subtitle font for ConversationListItem
     - Returns: This method will return `CometChatDataItem`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(subTitleFont: UIFont) -> CometChatMessageComposer {
        self.subtitle.font = subTitleFont
        return self
    }

    @discardableResult
    @objc public func set(closeButtonIcon: UIImage) -> CometChatMessageComposer {
        self.close.setImage(closeButtonIcon, for: .normal)
        return self
    }

    @discardableResult
    @objc public func set(closeButtonTint: UIColor) -> CometChatMessageComposer {
        self.close.tintColor = closeButtonTint
        return self
    }

    @discardableResult
    public func preview(message: BaseMessage, mode: MessageComposerMode) -> CometChatMessageComposer {
        switch mode {
        case .edit: edit(message: message)
        case .reply: reply(message: message)
        default: break
        }
        return self
    }



    @discardableResult
    @objc public func hide(messageComposer: Bool) -> CometChatMessageComposer {
        self.isHidden = messageComposer
        return self
    }



    @discardableResult
    @objc public func set(controller: UIViewController) -> CometChatMessageComposer {
        self.controller = controller
        return self
    }

    @discardableResult
    @objc public func set(templates: [CometChatMessageTemplate]) -> CometChatMessageComposer {
        self.templates = templates
        return self
    }

    @discardableResult
    public func draft(message: String) -> CometChatMessageComposer{
        self.messagePreview.isHidden = true
        return self
    }

    @discardableResult
    private func edit(message: BaseMessage) -> CometChatMessageComposer {
        if let message = message as? TextMessage {
            self.currentMessage = message
            self.messageComposerMode = .edit
            set(title: "EDIT_MESSAGE".localize())
            set(subTitle: message.text)
            set(text: message.text)

            UIView.transition(with: messagePreview, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: {
                self.messagePreview.isHidden = false
            })
        }
        return self
    }

    @discardableResult
    private func reply(message: BaseMessage)  -> CometChatMessageComposer {
        self.currentMessage = message
        self.messageComposerMode = .reply
        UIView.transition(with: messagePreview, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.messagePreview.isHidden = false
        })

        if let name = message.sender?.name {
            set(subTitle: name.capitalized)
        }
        switch message.messageType {
        case .text:
            if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let dataMaskingDictionary = cometChatExtension[ExtensionConstants.dataMasking] as? [String : Any] {
                if let data = dataMaskingDictionary["data"] as? [String:Any], let sensitiveData = data["sensitive_data"] as? String {

                    if sensitiveData == "yes" {
                        if let maskedMessage = data["message_masked"] as? String {
                            set(subTitle: maskedMessage)
                        }else{
                            set(subTitle: (message as? TextMessage)?.text)
                        }
                    }else{
                        set(subTitle: (message as? TextMessage)?.text)
                    }
                }else{
                    set(subTitle: (message as? TextMessage)?.text)
                }
            }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected[ExtensionConstants.extensions] as? [String : Any], let profanityFilterDictionary = cometChatExtension[ExtensionConstants.profanityFilter] as? [String : Any] {

                if let profanity = profanityFilterDictionary["profanity"] as? String, let filteredMessage = profanityFilterDictionary["message_clean"] as? String {

                    if profanity == "yes" {
                        set(subTitle: filteredMessage)
                    }else{
                        set(subTitle: (message as? TextMessage)?.text)
                    }
                }else{
                    set(subTitle: (message as? TextMessage)?.text)
                }
            }else{
                set(subTitle: (message as? TextMessage)?.text)
            }

        case .image:  set(subTitle: "MESSAGE_IMAGE".localize())
        case .video:  set(subTitle: "MESSAGE_VIDEO".localize())
        case .audio:  set(subTitle: "MESSAGE_AUDIO".localize())
        case .file:  set(subTitle: "MESSAGE_FILE".localize())
        case .custom:
            if let type = (message as? CustomMessage)?.type {
                if type == UIKitConstants.MessageTypeConstants.location {
                    set(subTitle: "CUSTOM_MESSAGE_LOCATION".localize())
                }else if type == UIKitConstants.MessageTypeConstants.poll {
                    set(subTitle: "CUSTOM_MESSAGE_POLL".localize())
                }else if type == UIKitConstants.MessageTypeConstants.sticker {
                    set(subTitle: "CUSTOM_MESSAGE_STICKER".localize())
                }else if type == UIKitConstants.MessageTypeConstants.whiteboard {
                    set(subTitle: "CUSTOM_MESSAGE_WHITEBOARD".localize())
                }else if type == UIKitConstants.MessageTypeConstants.document {
                    set(subTitle: "CUSTOM_MESSAGE_DOCUMENT".localize())
                }else if type == UIKitConstants.MessageTypeConstants.meeting {
                    set(subTitle: "CUSTOM_MESSAGE_GROUP_CALL".localize())
                }
            }
        case .groupMember: break
        @unknown default: break
        }
        return self
    }


    // MARK: - Initialization of required Methods

    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
        configureMessageComposer()
        locationAuthStatus()
        setupDelegates()
        setupAppearace()
        CometChatActionSheet.actionsSheetDelegate = self
    }


    private func setupAppearace() {
        set(plusIcon: plusIcon)
        set(stickerIcon: stickerIcon)
        set(liveReactionIcon: liveReactionIcon)
        set(sendIcon: sendIcon)

        set(plusIconTint: CometChatTheme.palatte?.accent700 ?? UIColor.clear)
        set(stickerIconTint: CometChatTheme.palatte?.accent700 ?? UIColor.clear)
        set(sendIconTint: CometChatTheme.palatte?.accent700 ?? UIColor.clear)
        set(liveReactionIconTint: CometChatTheme.palatte?.error ?? UIColor.clear)

        topView.roundViewCorners([.layerMinXMinYCorner,.layerMaxXMinYCorner], radius: 18)
        bottomView.roundViewCorners([.layerMinXMaxYCorner,.layerMaxXMaxYCorner], radius: 18)
        topView.backgroundColor = CometChatTheme.palatte?.accent100
        bottomView.backgroundColor = CometChatTheme.palatte?.accent100
        seperator.backgroundColor = CometChatTheme.palatte?.accent200

        set(titleFont: CometChatTheme.typography?.Caption1 ?? UIFont.systemFont(ofSize: 13))
        set(titleColor: CometChatTheme.palatte?.accent600 ?? UIColor.gray)
        set(subTitleFont: CometChatTheme.typography?.Subtitle2 ?? UIFont.systemFont(ofSize: 13))
        set(subTitleColor: CometChatTheme.palatte?.accent600 ?? UIColor.gray)
        set(closeButtonIcon: closeIcon)
        set(closeButtonTint: CometChatTheme.palatte?.accent600 ?? UIColor.gray)
        self.set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])

    }

    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            curentLocation = locationManager.location
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }


    fileprivate func setupDelegates() {
        documentPicker.delegate = self
        CometChatStickerKeyboard.stickerDelegate = self
    }

    fileprivate func configureMessageComposer() {

        textView.layer.cornerRadius = 20
        textView.delegate = self
        send.isHidden = true
        set(textFont: CometChatTheme.typography?.Body ?? UIFont.systemFont(ofSize: 17))
        set(textColor: CometChatTheme.palatte?.accent ?? .black)

        if #available(iOS 13.0, *) {
            let sendImage = UIImage(named: "message-composer-send.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            send.setImage(sendImage, for: .normal)
            send.tintColor = CometChatTheme.palatte?.primary
        } else {}

        print("excludeMessageTypes 111: \(excludeMessageTypes)")
        if let configurations = configurations {
            if let messageComposerConfiguration = configurations.filter({ $0 is MessageComposerConfiguration}).last as? MessageComposerConfiguration {

                hide(messageComposer: messageComposerConfiguration.hideMessageComposer)
                set(maxLines: messageComposerConfiguration.getMaxLines())
                set(placeholderText: messageComposerConfiguration.getPlaceholderText())
                hide(liveReaction: messageComposerConfiguration.isLiveReactionHidden())
                show(sendButton: !messageComposerConfiguration.isSendButtonHidden())
                hide(attachment: messageComposerConfiguration.isAttachmentHidden())
                hide(sticker: messageComposerConfiguration.isStickerHidden())
                enable(typingIndicator: messageComposerConfiguration.isTypingIndicatorEnabled())
                hide(emoji: messageComposerConfiguration.isEmojiHidden())
                set(messageTypes: messageComposerConfiguration.messageTypes ?? [])
                set(excludeMessageTypes: messageComposerConfiguration.excludeMessageTypes ?? [])
                enable(soundForMessages: messageComposerConfiguration.isSoundEnabled())
            }
        }else{
            set(messageTypes: [CometChatMessageTemplate(type: .imageFromCamera), CometChatMessageTemplate(type: .imageFromGallery), CometChatMessageTemplate(type: .file), CometChatMessageTemplate(type: .collaborativeWhiteboard), CometChatMessageTemplate(type: .collaborativeDocument), CometChatMessageTemplate(type: .poll)])
            set(maxLines: 5)
            set(placeholderText: placeholderText)
        }

        setMessageFilter(templates: messageTypes)

        self.sticker.isHidden = hideSticker
        self.liveReaction.isHidden = hideLiveReaction
        self.attachment.isHidden = hideAttachment
    }

    @discardableResult
    @objc public func setMessageFilter(templates: [CometChatMessageTemplate]?) -> CometChatMessageComposer {
        if let messageTemplates = templates {

            print("excludeMessageTypes: \(excludeMessageTypes)")

            var  filteredMessageTemplates = messageTemplates.filter { (template: CometChatMessageTemplate) -> Bool in
                return template.icon != nil && template.name != nil
            }

            if !filteredMessageTemplates.isEmpty {

                for template in excludeMessageTypes {
                    filteredMessageTemplates =  filteredMessageTemplates.filter { $0.type != template.type }
                    print("filteredMessageTemplates: \(filteredMessageTemplates)")
                }
                for template in filteredMessageTemplates {

                    let actionItem = ActionItem(id: template.type, text: template.name ?? "", icon: template.icon ?? UIImage(), textColor: CometChatTheme.palatte?.accent, textFont: CometChatTheme.typography?.Name2, startIconTint: CometChatTheme.palatte?.accent700)
                    self.actionItems.append(actionItem)
                }
                attachment.isHidden = false
            }
        }
        return self
    }

    @IBAction func onStickerClick(_ sender: Any) {

        let sticker = ActionItem(id: UIKitConstants.MessageTypeConstants.sticker, text: "SEND_STICKER".localize(), icon: UIImage(named: "messages-stickers.png", in: CometChatUIKit.bundle, compatibleWith: nil) ?? UIImage(), textColor: CometChatTheme.palatte?.accent, textFont: CometChatTheme.typography?.Subtitle1, startIconTint: CometChatTheme.palatte?.accent700)
        CometChatActionSheet.actionsSheetDelegate?.onActionItemClick(item: sticker)
    }

    @IBAction func onEmojiClick(_ sender: UIButton) {
        let emojiKeyboard = CometChatEmojiKeyboard()
        controller?.presentPanModal(emojiKeyboard, backgroundColor: CometChatTheme.palatte?.background)
    }


    @IBAction func onAttachmentClick(_ sender: Any) {
        self.actionItems.removeAll()
        setMessageFilter(templates: messageTypes)

        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let group: CometChatActionPresentable = CometChatMessageActionsGroup()

        (group.rowVC as? CometChatActionSheet)?.set(layoutMode: .listMode).set(actionItems: actionItems)
        if let controller = controller {
            controller.presentPanModal(group.rowVC, backgroundColor:  CometChatTheme.palatte?.secondary)
        }
        self.actionItems.removeAll()
    }


    @IBAction func onSendClick(_ sender: Any) {

        switch messageComposerMode {
        case .draft:
            if let currentUser = currentUser {
                sendTextMessage(currentUser)
            }else if let currentGroup = currentGroup {
                sendTextMessage(currentGroup)
            }
        case .edit:
            if let currentMessage = currentMessage as? TextMessage {
                editTextMessage(textMessage: currentMessage)
            }
        case .reply: break

        }
    }

    @IBAction func onMicrophoneClick(_ sender: Any) {

    }

    @IBAction func onLiveReactionClick(_ sender: Any) {

        if let currentUser = currentUser {

            let liveReaction = TransientMessage(receiverID: currentUser.uid ?? "", receiverType: .user, data: ["type":UIKitConstants.MetadataConstants.liveReaction, "reaction": "heart"])

            CometChat.sendTransientMessage(message: liveReaction)
            CometChatMessageEvents.emitOnLiveReaction(reaction: liveReaction)

        }else if let currentGroup = currentGroup {

            let liveReaction = TransientMessage(receiverID: currentGroup.guid , receiverType: .user, data: ["type":UIKitConstants.MetadataConstants.liveReaction, "reaction": "heart"])

            CometChat.sendTransientMessage(message: liveReaction)
            CometChatMessageEvents.emitOnLiveReaction(reaction: liveReaction)

        }
    }

    @IBAction func onCloseClick(_ sender: Any) {
        UIView.transition(with: messagePreview, duration: 0.4,
                          options: .transitionCrossDissolve,
                          animations: {
            self.messagePreview.isHidden = true
            self.textView.text = ""
            self.messageComposerMode = .draft
            self.heightConstant.constant = 100
        })

    }

}

extension CometChatMessageComposer: GrowingTextViewDelegate {

    public func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat) {
        self.heightConstant.constant = height
    }

    public func growingTextView(_ growingTextView: GrowingTextView, didChangeHeight height: CGFloat, difference: CGFloat) {

    }


    public func growingTextViewDidChange(_ growingTextView: GrowingTextView) {
        if enableTypingIndicator {
            if let indicator = currentTypingIndicator {
                CometChat.startTyping(indicator: indicator)
            }
        }
        if growingTextView.text?.count == 0 {
            if enableTypingIndicator {
                if let indicator = currentTypingIndicator  {
                    CometChat.endTyping(indicator: indicator)
                }
            }
            if hideLiveReaction == false {
                self.liveReaction.isHidden = false
            }
            send.isHidden = true
        }else{
            if hideLiveReaction == false {
                self.liveReaction.isHidden = true
            }
            if showSendButton {
                send.isHidden = false
            }
        }
    }

    public func growingTextViewDidBeginEditing(_ growingTextView: GrowingTextView) {
    }

    public func growingTextViewDidEndEditing(_ growingTextView: GrowingTextView) {
    }
}


extension CometChatMessageComposer {

    public func sendTextMessage(_ forEntity: AppEntity) {
        let message:String = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !message.isEmpty {
            var textMessage: TextMessage?
            if let uid = (forEntity as? User)?.uid {
                textMessage =  TextMessage(receiverUid: uid, text: message, receiverType: .user)
            }else if  let guid = (forEntity as? Group)?.guid {
                textMessage =  TextMessage(receiverUid: guid, text: message, receiverType: .group)
            }
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            textMessage?.sender = CometChat.getLoggedInUser()

            if let textMessage = textMessage {
                if enableSoundForMessages {
                    CometChatSoundManager().play(sound: .outgoingMessage, customSound: customOutgoingMessageSound)
                }
                CometChatMessageEvents.emitOnMessageSent(message: textMessage, status: .inProgress)
                
                textView.text = ""
                send.isEnabled = false
                CometChat.sendTextMessage(message: textMessage) { updatedTextMessage in
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.send.isEnabled = true
                        CometChatMessageEvents.emitOnMessageSent(message: updatedTextMessage, status: .success)


                    }
                } onError: { error in
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.send.isEnabled = true
                        if let error = error {
                            textMessage.metaData = ["error": true]
                            CometChatMessageEvents.emitOnError(message: textMessage, error: error)
                        }
                    }
                }
            }
        }
    }

    public func editTextMessage(textMessage: TextMessage) {
        let message:String = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !message.isEmpty {
            textMessage.text = message
            if enableSoundForMessages {
                CometChatSoundManager().play(sound: .outgoingMessage, customSound: customOutgoingMessageSound)
            }
            CometChatMessageEvents.emitOnMessageEdit(message: textMessage, status: .inProgress)
            send.isEnabled = false
            CometChat.edit(message: textMessage) { updatedTextMessage in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.send.isEnabled = true
                    strongSelf.textView.text = ""
                    strongSelf.messagePreview.isHidden = true
                    strongSelf.messageComposerMode = .draft
                    if let updatedTextMessage = updatedTextMessage as? TextMessage {
                        CometChatMessageEvents.emitOnMessageEdit(message: updatedTextMessage, status: .success)
                    }
                }
            } onError: { error in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.send.isEnabled = true
                    textMessage.metaData = ["error": true]
                    strongSelf.messageComposerMode = .draft
                    strongSelf.messagePreview.isHidden = true
                    CometChatMessageEvents.emitOnError(message: textMessage, error: error)
                }
            }
        }
    }



    public func sendMediaMessage(url: String, type: CometChat.MessageType ,_ forEntity: AppEntity) {

        var mediaMessage : MediaMessage?

        if let uid = (forEntity as? User)?.uid {
            mediaMessage = MediaMessage(receiverUid: uid, fileurl: url, messageType: type, receiverType: .user)
        }else if  let guid = (forEntity as? Group)?.guid {
            mediaMessage = MediaMessage(receiverUid: guid, fileurl: url, messageType: type, receiverType: .group)
        }

        mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
        mediaMessage?.sender = CometChat.getLoggedInUser()
        mediaMessage?.metaData = ["fileURL": url]
        mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
        if enableSoundForMessages {
            CometChatSoundManager().play(sound: .outgoingMessage, customSound: customOutgoingMessageSound)
        }
        if let mediaMessage = mediaMessage {
            CometChatMessageEvents.emitOnMessageSent(message: mediaMessage, status: .inProgress)
            CometChat.sendMediaMessage(message: mediaMessage) { updatedMediaMessage in
                if mediaMessage.messageType == .video && updatedMediaMessage.metaData != nil {
                    CometChatMessageEvents.emitOnMessageSent(message: updatedMediaMessage, status: .success)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                        CometChatMessageEvents.emitOnMessageSent(message: updatedMediaMessage, status: .success)
                    }
                }else{
                    CometChatMessageEvents.emitOnMessageSent(message: updatedMediaMessage, status: .success)
                }

            } onError: { error in
                if let error = error {
                    mediaMessage.metaData = ["error": true]
                    CometChatMessageEvents.emitOnError(message: mediaMessage, error: error)
                }
            }
        }
    }

    public func sendCustomMessage(data: [String: Any], pushNotificationTitle: String, type: String ,_ forEntity: AppEntity) {
        var customMessage : CustomMessage?
        if let uid = (forEntity as? User)?.uid {
            customMessage = CustomMessage(receiverUid: uid , receiverType: .user, customData: data, type: type)
        }else if  let guid = (forEntity as? Group)?.guid {
            customMessage = CustomMessage(receiverUid: guid , receiverType: .group, customData: data, type: type)
        }
        customMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
        customMessage?.sender = CometChat.getLoggedInUser()
        customMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
        customMessage?.metaData = ["pushNotification": pushNotificationTitle, "incrementUnreadCount":true]

        if let customMessage = customMessage {
            if enableSoundForMessages {
                CometChatSoundManager().play(sound: .outgoingMessage, customSound: customOutgoingMessageSound)
            }
            CometChatMessageEvents.emitOnMessageSent(message: customMessage, status: .inProgress)
            CometChat.sendCustomMessage(message: customMessage) { updatedCustomMessage in
                CometChatMessageEvents.emitOnMessageSent(message: updatedCustomMessage, status: .success)
            } onError: { error in
                if let error = error {
                    customMessage.metaData = ["error": true]
                    CometChatMessageEvents.emitOnError(message: customMessage, error: error)
                }
            }
        }
    }
}



extension CometChatMessageComposer: UIDocumentPickerDelegate {

    /// This method triggers when we open document menu to send the message of type `File`.
    /// - Parameters:
    ///   - controller: A view controller that provides access to documents or destinations outside your app’s sandbox.
    ///   - urls: A value that identifies the location of a resource, such as an item on a remote server or the path to a local file.
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            if let user = self.currentUser {
                self.sendMediaMessage(url:  urls[0].absoluteString, type: .file, user)
            }else if let group = self.currentGroup {
                self.sendMediaMessage(url:  urls[0].absoluteString, type: .file, group)
            }
        }
    }

}

extension CometChatMessageComposer: CometChatEmojiKeyboardDelegate {

    func onEmojiClick(emoji: CometChatEmoji, message: BaseMessage?) {
        textView.text?.append(emoji.emoji)
        send.isHidden = false
        liveReaction.isHidden = true
    }
}

