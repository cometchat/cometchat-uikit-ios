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

enum  MessageStatus {
    case inProgress
    case success
}

enum MessageComposerMode {
    case draft
    case edit
    case reply
}

protocol CometChatMessageComposerDelegate: NSObject {
    
    func onMessageSent(message: BaseMessage, status: MessageStatus)
    func onEditTextMessage(message: TextMessage, status: MessageStatus)
    func onLiveReaction(message: TransientMessage)
    func onMessageError(message: BaseMessage, error: CometChatException)
}

@objc @IBDesignable class CometChatMessageComposer: UIView , NibLoadable {
    
    // MARK: - Declaration of IBInspectable
    
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var attachment: UIButton!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var microphone: UIButton!
    @IBOutlet weak var liveReaction: UIButton!
    @IBOutlet weak var heightConstant: NSLayoutConstraint!
    @IBOutlet weak var liveReactionButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var attachmentButtonWidth: NSLayoutConstraint!
    @IBOutlet weak var replyToMessageView: UIView!
    @IBOutlet weak var liveReactionButtonLeadingSpace: NSLayoutConstraint!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    
    // MARK: - Declaration of Variables
    var typingIndicator: TypingIndicator?
    var templates = [CometChatMessageTemplate]()
    var currentUser: User?
    var currentGroup: Group?
    var currentMessage: BaseMessage?
    var curentLocation: CLLocation?
    let locationManager = CLLocationManager()
    var actionItems: [ActionItem] = [ActionItem]()
    weak var controller: UIViewController?
    var messageComposerMode: MessageComposerMode =  .draft
    
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    struct CometChatMessageActionsGroup: CometChatActionPresentable {
        let string: String = "MessageActions Group"
        let rowVC: PanModalPresentable.LayoutType = CometChatActionSheet()
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
    @objc public func hide(attachment: Bool) -> CometChatMessageComposer {
        self.attachment.isHidden = attachment
        return self
    }
    
    @discardableResult
    @objc public func hide(microphone: Bool) -> CometChatMessageComposer {
        self.microphone.isHidden = microphone
        return self
    }
    
    
    
    @discardableResult
    @objc public func set(user: User) -> CometChatMessageComposer {
        self.currentUser = user
        typingIndicator = TypingIndicator(receiverID: currentUser?.uid ?? "", receiverType: .user)
        return self
    }
    
    @discardableResult
    @objc public func set(group: Group) -> CometChatMessageComposer {
        self.currentGroup = group
        typingIndicator = TypingIndicator(receiverID: currentGroup?.guid ?? "", receiverType: .group)
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
        self.replyToMessageView.isHidden = true
        return self
    }
    
    @discardableResult
    public func edit(message: BaseMessage) -> CometChatMessageComposer{
        if let message = message as? TextMessage {
            self.currentMessage = message
            self.messageComposerMode = .edit
            self.replyToMessageView.isHidden = false
            title.text = "EDIT_MESSAGE".localize()
            subtitle.text = message.text
            textView.text = message.text
        }
        return self
    }
    
    @discardableResult
    public func reply(message: BaseMessage)  -> CometChatMessageComposer{
        if let message = message as? TextMessage {
            self.currentMessage = message
            self.messageComposerMode = .reply
            self.replyToMessageView.isHidden = false
            title.text = "EDIT_MESSAGE".localize()
            subtitle.text = message.text
            textView.text = message.text
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
        
        let nib = UINib(nibName: "CometChatMessageComposer", bundle: Bundle.module)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
       // self.contentView.  = view
        
        addSubview(view)
//        Bundle.module.loadNibNamed("CometChatMessageComposer", owner: self, options: nil)
//        addSubview(contentView)
//        contentView.frame = bounds
//        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        configureMessageComposer()
        locationAuthStatus()
        setupDelegates()
        CometChatActionSheet.actionsSheetDelegate = self
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
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.placeholder = NSAttributedString(string:  "TYPE_A_MESSAGE".localize(), attributes: [.foregroundColor: UIColor.lightGray, .font:  UIFont.systemFont(ofSize: 17) as Any])
        textView.maxNumberOfLines = 5
        textView.delegate = self
        send.isHidden = true
        
        if #available(iOS 13.0, *) {
            let sendImage = UIImage(named: "send-message-filled.png", in: Bundle.module, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            send.setImage(sendImage, for: .normal)
            send.tintColor = CometChatTheme.style.primaryIconColor
        } else {}
        setMessageFilter(templates: templates)
    }
    
    @discardableResult
    public func set(backgroundColor: [Any]?) ->  CometChatMessageComposer {
        if let backgroundColors = backgroundColor as? [CGColor] {
            if backgroundColors.count == 1 {
                background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                background.set(backgroundColorWithGradient: backgroundColor)
            }
        }
        return self
    }
    
    @discardableResult
    @objc public func setMessageFilter(templates: [CometChatMessageTemplate]?) -> CometChatMessageComposer {
        if let messageTemplates = templates {
            
            let  filteredMessageTemplates = messageTemplates.filter { (template: CometChatMessageTemplate) -> Bool in
                return template.icon != nil && template.name != nil
            }
            
            if !filteredMessageTemplates.isEmpty {
                
                for template in filteredMessageTemplates {
                    
                    let actionItem = ActionItem(id: template.id, title: template.name ?? "", icon: template.icon ?? UIImage())
                    self.actionItems.append(actionItem)
                }
                attachment.isHidden = false
                attachmentButtonWidth.constant = 30
            }else{
                attachment.isHidden = true
                attachmentButtonWidth.constant = 0
            }
        }else {
            attachment.isHidden = true
            attachmentButtonWidth.constant = 0
        }
        return self
    }
    
    @IBAction func onAttachmentClick(_ sender: Any) {
        
        AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
        let group: CometChatActionPresentable = CometChatMessageActionsGroup()
        
        (group.rowVC as? CometChatActionSheet)?.set(layoutMode: .listMode).set(actionItems: actionItems)
        if let controller = controller {
            controller.presentPanModal(group.rowVC)
        }
        
    }
    
    
    @IBAction func didMessageSendPressed(_ sender: Any) {
        
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
            
            let liveReaction = TransientMessage(receiverID: currentUser.uid ?? "", receiverType: .user, data: ["type":"live_reaction", "reaction": "heart"])
            
            CometChat.sendTransientMessage(message: liveReaction)
            CometChatMessageComposer.messageComposerDelegate?.onLiveReaction(message: liveReaction)
            
        }else if let currentGroup = currentGroup {
            
            let liveReaction = TransientMessage(receiverID: currentGroup.guid , receiverType: .user, data: ["type":"live_reaction", "reaction": "heart"])
            
            CometChat.sendTransientMessage(message: liveReaction)
            CometChatMessageComposer.messageComposerDelegate?.onLiveReaction(message: liveReaction)
            
        }
    }
    
    @IBAction func didClosePressed(_ sender: Any) {
        
        self.replyToMessageView.isHidden = true
        
    }
    
    
    
}
extension CometChatMessageComposer: GrowingTextViewDelegate {
    
    public func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat) {
        
        heightConstant.constant = height
    }
    
    public func growingTextView(_ growingTextView: GrowingTextView, didChangeHeight height: CGFloat, difference: CGFloat) {
        
    }
    
    
    public func growingTextViewDidChange(_ growingTextView: GrowingTextView) {
        guard let indicator = typingIndicator else {
            return
        }
        if growingTextView.text?.count == 0 {
            CometChat.endTyping(indicator: indicator)
            self.liveReaction.isHidden = false
            self.liveReactionButtonWidth.constant = 30
            self.liveReactionButtonLeadingSpace.constant = 15
            
            self.microphone.isHidden = false
            send.isHidden = true
            
        }else{
            microphone.isHidden = true
            send.isHidden = false
            send.isHidden = false
            liveReactionButtonLeadingSpace.constant = 0
            liveReactionButtonWidth.constant = 0
        }
        CometChat.startTyping(indicator: indicator)
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
            textMessage?.senderUid = CometChatMessages.loggedInUser?.uid ?? ""
            textMessage?.sender = CometChatMessages.loggedInUser
            
            if let textMessage = textMessage {
                CometChatSoundManager().play(sound: .outgoingMessage)
                
                CometChatMessageComposer.messageComposerDelegate?.onMessageSent(message: textMessage, status: .inProgress)
                
                textView.text = ""
                send.isEnabled = false
                CometChat.sendTextMessage(message: textMessage) { updatedTextMessage in
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.send.isEnabled = true
                        CometChatMessageComposer.messageComposerDelegate?.onMessageSent(message: textMessage, status: .success)
                        
                    }
                } onError: { error in
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.send.isEnabled = true
                        if let error = error {
                            CometChatMessageComposer.messageComposerDelegate?.onMessageError(message: textMessage, error: error)
                        }
                    }
                }
            }
        }
    }
    
    public func editTextMessage(textMessage: TextMessage) {
        let message:String = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if !message.isEmpty {
            CometChatSoundManager().play(sound: .outgoingMessage)
            textMessage.text = message
            
            CometChatMessageComposer.messageComposerDelegate?.onEditTextMessage(message: textMessage, status: .inProgress)
            
            send.isEnabled = false
            CometChat.edit(message: textMessage) { updatedTextMessage in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.send.isEnabled = true
                    strongSelf.textView.text = ""
                    strongSelf.replyToMessageView.isHidden = true
                    if let updatedTextMessage = updatedTextMessage as? TextMessage {
                        CometChatMessageComposer.messageComposerDelegate?.onEditTextMessage(message: updatedTextMessage, status: .success)
                        
                    }
                    
                }
            } onError: { error in
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.send.isEnabled = true
                    CometChatMessageComposer.messageComposerDelegate?.onMessageError(message: textMessage, error: error)
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
        mediaMessage?.sender = CometChatMessages.loggedInUser
        mediaMessage?.metaData = ["fileURL": url]
        mediaMessage?.senderUid = CometChatMessages.loggedInUser?.uid ?? ""
        
        if let mediaMessage = mediaMessage {
            CometChatMessageComposer.messageComposerDelegate?.onMessageSent(message: mediaMessage, status: .inProgress)
            CometChat.sendMediaMessage(message: mediaMessage) { updatedMediaMessage in
                CometChatMessageComposer.messageComposerDelegate?.onMessageSent(message: updatedMediaMessage, status: .success)
            } onError: { error in
                if let error = error {
                    CometChatMessageComposer.messageComposerDelegate?.onMessageError(message: mediaMessage, error: error)
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
        customMessage?.sender = CometChatMessages.loggedInUser
        customMessage?.senderUid = CometChatMessages.loggedInUser?.uid ?? ""
        customMessage?.metaData = ["pushNotification": pushNotificationTitle, "incrementUnreadCount":true]
        
        if let customMessage = customMessage {
            CometChatMessageComposer.messageComposerDelegate?.onMessageSent(message: customMessage, status: .inProgress)
            CometChat.sendCustomMessage(message: customMessage) { updatedCustomMessage in
                CometChatMessageComposer.messageComposerDelegate?.onMessageSent(message: updatedCustomMessage, status: .success)
            } onError: { error in
                if let error = error {
                    CometChatMessageComposer.messageComposerDelegate?.onMessageError(message: customMessage, error: error)
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


extension CometChatMessageComposer {
    static var messageComposerDelegate: CometChatMessageComposerDelegate?
}
























