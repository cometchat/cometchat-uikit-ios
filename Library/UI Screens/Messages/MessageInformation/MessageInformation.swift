//
//  MessageInformation.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit
import MapKit
import CometChatPro

class MessageInformation: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var message: BaseMessage?
    var refreshControl = UIRefreshControl()
    var receipts: [MessageReceipt] = [MessageReceipt]()
    var activityIndicator:UIActivityIndicatorView?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        self.setupTableView()
        
    }
    
    override func loadView() {
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "MessageInformation", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentMessage = message {
            self.get(messageInformation: currentMessage)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.tableView.reloadData()
            }
        }
    }
    
    
    public func set(message: BaseMessage) {
        self.message = message
    }
    
    private func setupTableView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.registerCells()
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = NSLocalizedString("REFRESHING", comment: "")
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshMessageInformation(sender:)),
                                     for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }
    
    @objc private func refreshMessageInformation(sender: UIRefreshControl) {
        if let currentMessage = message {
            self.get(messageInformation: currentMessage)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.tableView.reloadData()
            }
        }
        sender.endRefreshing()
    }
    
    
    fileprivate func get(messageInformation forMessage: BaseMessage){
        if let messageID = forMessage.id as? Int {
            print("messageID is: \(messageID)")
            CometChat.getMessageReceipts(messageID, onSuccess: { (fetchedReceipts) in
                print("Receipts are: \(fetchedReceipts)")
                self.receipts = fetchedReceipts
                DispatchQueue.main.async { self.tableView.reloadData() }
            }) { (error) in
                print("getMessageReceipts error is: \(String(describing: error?.errorDescription))")
            }
        }
    }
    
    private func didExtensionDetected(message: BaseMessage) -> CometChatExtension {
        var detectedExtension: CometChatExtension?
        
        if let metaData = message.metaData , let type = metaData["type"] as? String {
            if type == "reply" {
                detectedExtension = .reply
            }else{
                detectedExtension = .none
            }
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String : Any], let linkArray = linkPreviewDictionary["links"] as? [[String: Any]], let _ = linkArray[safe: 0] {
            
            detectedExtension = .linkPreview
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["smart-reply"] as? [String : Any] {
            
            detectedExtension = .smartReply
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["message-translation"] as? [String : Any] {
            
            detectedExtension = .messageTranslation
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["thumbnail-generation"] as? [String : Any] {
            
            detectedExtension = .thumbnailGeneration
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["image-moderation"] as? [String : Any] {
            
            detectedExtension = .imageModeration
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["profanity-filter"] as? [String : Any] {
            
            detectedExtension = .profanityFilter
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["sentiment-analysis"] as? [String : Any] {
            
            detectedExtension = .profanityFilter
        }
        
        return detectedExtension ?? .none
    }
    
    private func registerCells(){
        
        let leftTextMessageBubble  = UINib.init(nibName: "LeftTextMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftTextMessageBubble, forCellReuseIdentifier: "leftTextMessageBubble")
        
        let rightTextMessageBubble  = UINib.init(nibName: "RightTextMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightTextMessageBubble, forCellReuseIdentifier: "rightTextMessageBubble")
        
        let leftImageMessageBubble  = UINib.init(nibName: "LeftImageMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftImageMessageBubble, forCellReuseIdentifier: "leftImageMessageBubble")
        
        let rightImageMessageBubble  = UINib.init(nibName: "RightImageMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightImageMessageBubble, forCellReuseIdentifier: "rightImageMessageBubble")
        
        let leftVideoMessageBubble  = UINib.init(nibName: "LeftVideoMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftVideoMessageBubble, forCellReuseIdentifier: "leftVideoMessageBubble")
        
        let rightVideoMessageBubble  = UINib.init(nibName: "RightVideoMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightVideoMessageBubble, forCellReuseIdentifier: "rightVideoMessageBubble")
        
        let leftFileMessageBubble  = UINib.init(nibName: "LeftFileMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftFileMessageBubble, forCellReuseIdentifier: "leftFileMessageBubble")
        
        let rightFileMessageBubble  = UINib.init(nibName: "RightFileMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightFileMessageBubble, forCellReuseIdentifier: "rightFileMessageBubble")
        
        let leftAudioMessageBubble  = UINib.init(nibName: "LeftAudioMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftAudioMessageBubble, forCellReuseIdentifier: "leftAudioMessageBubble")
        
        let rightAudioMessageBubble  = UINib.init(nibName: "RightAudioMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightAudioMessageBubble, forCellReuseIdentifier: "rightAudioMessageBubble")
        
        let actionMessageBubble  = UINib.init(nibName: "ActionMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(actionMessageBubble, forCellReuseIdentifier: "actionMessageBubble")
        
        let leftLinkPreviewBubble = UINib.init(nibName: "LeftLinkPreviewBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftLinkPreviewBubble, forCellReuseIdentifier: "leftLinkPreviewBubble")
        
        let rightLinkPreviewBubble = UINib.init(nibName: "RightLinkPreviewBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightLinkPreviewBubble, forCellReuseIdentifier: "rightLinkPreviewBubble")
        
        let leftReplyMessageBubble = UINib.init(nibName: "LeftReplyMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftReplyMessageBubble, forCellReuseIdentifier: "leftReplyMessageBubble")
        
        
        let rightReplyMessageBubble = UINib.init(nibName: "RightReplyMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightReplyMessageBubble, forCellReuseIdentifier: "rightReplyMessageBubble")
        
        let messageReceiptBubble = UINib.init(nibName: "MessageReceiptBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(messageReceiptBubble, forCellReuseIdentifier: "messageReceiptBubble")
        
        let leftLocationMessageBubble = UINib.init(nibName: "LeftLocationMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftLocationMessageBubble, forCellReuseIdentifier: "leftLocationMessageBubble")
        
        let rightLocationMessageBubble = UINib.init(nibName: "RightLocationMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightLocationMessageBubble, forCellReuseIdentifier: "rightLocationMessageBubble")
        
        let leftPollMessageBubble = UINib.init(nibName: "LeftPollMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftPollMessageBubble, forCellReuseIdentifier: "leftPollMessageBubble")
        
        let rightPollMessageBubble = UINib.init(nibName: "RightPollMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightPollMessageBubble, forCellReuseIdentifier: "rightPollMessageBubble")
        
        let leftStickerMessageBubble = UINib.init(nibName: "LeftStickerMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftStickerMessageBubble, forCellReuseIdentifier: "leftStickerMessageBubble")
        
        let rightStickerMessageBubble = UINib.init(nibName: "RightStickerMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightStickerMessageBubble, forCellReuseIdentifier: "rightStickerMessageBubble")
        
        let leftCollaborativeMessageBubble  = UINib.init(nibName: "LeftCollaborativeMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(leftCollaborativeMessageBubble, forCellReuseIdentifier: "leftCollaborativeMessageBubble")
        
        let rightCollaborativeMessageBubble  = UINib.init(nibName: "RightCollaborativeMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(rightCollaborativeMessageBubble, forCellReuseIdentifier: "rightCollaborativeMessageBubble")
    }
}

extension MessageInformation: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Message"
        }else{
            return NSLocalizedString("Receipt Information", comment: "")
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if (section == 0) {
            return 1
        }else{
            return receipts.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell()
        
        if  indexPath.section == 0 && indexPath.row == 0 {
            if let message = message {
                if message.messageCategory == .message {
                    if message.deletedAt > 0.0 && message.senderUid != LoggedInUser.uid {
                        let  deletedCell = tableView.dequeueReusableCell(withIdentifier: "leftTextMessageBubble", for: indexPath) as! LeftTextMessageBubble
                        deletedCell.deletedMessage = message
                        deletedCell.receiptStack.isHidden = false
                        deletedCell.indexPath = indexPath
                        return deletedCell
                        
                    }else if message.deletedAt > 0.0 && message.senderUid == LoggedInUser.uid {
                        
                        let deletedCell = tableView.dequeueReusableCell(withIdentifier: "rightTextMessageBubble", for: indexPath) as! RightTextMessageBubble
                        deletedCell.deletedMessage = message
                        deletedCell.indexPath = indexPath
                        deletedCell.receiptStack.isHidden = false
                        return deletedCell
                    }else{
                        switch message.messageType {
                        case .text where message.senderUid != LoggedInUser.uid:
                            if let textMessage = message as? TextMessage {
                                let isContainsExtension = didExtensionDetected(message: textMessage)
                                switch isContainsExtension {
                                case .linkPreview:
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftLinkPreviewBubble", for: indexPath) as! LeftLinkPreviewBubble
                                    let linkPreviewMessage = message as? TextMessage
                                    receiverCell.linkPreviewMessage = linkPreviewMessage
                                    receiverCell.indexPath = indexPath
                                    receiverCell.receiptStack.isHidden = false
                                    //receiverCell.linkPreviewDelegate = self
                                    return receiverCell
                                case .reply:
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftReplyMessageBubble", for: indexPath) as! LeftReplyMessageBubble
                                    receiverCell.indexPath = indexPath
                                    // receiverCell.delegate = self
                                    receiverCell.receiptStack.isHidden = false
                                    receiverCell.textMessage = textMessage
                                    return receiverCell
                                case .smartReply,.messageTranslation, .profanityFilter, .sentimentAnalysis, .none, .sticker:
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftTextMessageBubble", for: indexPath) as! LeftTextMessageBubble
                                    receiverCell.indexPath = indexPath
                                    receiverCell.receiptStack.isHidden = false
                                    //  receiverCell.delegate = self
                                    receiverCell.textMessage = textMessage
                                    return receiverCell
                                    
                                case .thumbnailGeneration, .imageModeration: break
                                    
                                }
                            }
                        case .text where message.senderUid == LoggedInUser.uid:
                            if let textMessage = message as? TextMessage {
                                let isContainsExtension = didExtensionDetected(message: textMessage)
                                switch isContainsExtension {
                                case .linkPreview:
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightLinkPreviewBubble", for: indexPath) as! RightLinkPreviewBubble
                                    let linkPreviewMessage = message as? TextMessage
                                    senderCell.linkPreviewMessage = linkPreviewMessage
                                    // senderCell.linkPreviewDelegate = self
                                    senderCell.receiptStack.isHidden = false
                                    senderCell.indexPath = indexPath
                                    return senderCell
                                case .reply:
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightReplyMessageBubble", for: indexPath) as! RightReplyMessageBubble
                                    senderCell.textMessage = textMessage
                                    senderCell.receiptStack.isHidden = false
                                    senderCell.indexPath = indexPath
                                    return senderCell
                                    
                                case .smartReply,.messageTranslation, .profanityFilter, .sentimentAnalysis, .none:
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightTextMessageBubble", for: indexPath) as! RightTextMessageBubble
                                    senderCell.receiptStack.isHidden = false
                                    senderCell.textMessage = textMessage
                                    senderCell.indexPath = indexPath
                                    return senderCell
                                    
                                case .thumbnailGeneration, .imageModeration, .sticker: break
                                    
                                }
                            }
                        case .image where message.senderUid != LoggedInUser.uid:
                            
                            if let imageMessage = message as? MediaMessage {
                                let isContainsExtension = didExtensionDetected(message: imageMessage)
                                switch isContainsExtension {
                                case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .reply, .sticker: break
                                    
                                case .thumbnailGeneration, .imageModeration,.none:
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftImageMessageBubble", for: indexPath) as! LeftImageMessageBubble
                                    receiverCell.mediaMessage = imageMessage
                                    receiverCell.indexPath = indexPath
                                    receiverCell.receiptStack.isHidden = false
                                    return receiverCell
                                }
                            }
                            
                        case .image where message.senderUid == LoggedInUser.uid:
                            
                            if let imageMessage = message as? MediaMessage {
                                let isContainsExtension = didExtensionDetected(message: imageMessage)
                                switch isContainsExtension {
                                case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .reply: break
                                    
                                case .sticker:
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightStickerMessageBubble", for: indexPath) as! RightImageMessageBubble
                                    senderCell.mediaMessage = imageMessage
                                    senderCell.indexPath = indexPath
                                    senderCell.receiptStack.isHidden = false
                                    return senderCell
                                    
                                case .thumbnailGeneration, .imageModeration,.none:
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightImageMessageBubble", for: indexPath) as! RightImageMessageBubble
                                    senderCell.mediaMessage = imageMessage
                                    senderCell.indexPath = indexPath
                                    senderCell.receiptStack.isHidden = false
                                    return senderCell
                                }
                            }
                        case .video where message.senderUid != LoggedInUser.uid:
                            if let videoMessage = message as? MediaMessage {
                                let isContainsExtension = didExtensionDetected(message: videoMessage)
                                switch isContainsExtension {
                                case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .imageModeration, .reply, .sticker: break
                                case .thumbnailGeneration,.none:
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftVideoMessageBubble", for: indexPath) as! LeftVideoMessageBubble
                                    receiverCell.mediaMessage = videoMessage
                                    receiverCell.indexPath = indexPath
                                    receiverCell.receiptStack.isHidden = false
                                    return receiverCell
                                }
                            }
                        case .video where message.senderUid == LoggedInUser.uid:
                            if let videoMessage = message as? MediaMessage {
                                let isContainsExtension = didExtensionDetected(message: videoMessage)
                                switch isContainsExtension {
                                case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .imageModeration, .reply, .sticker: break
                                case .thumbnailGeneration,.none:
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightVideoMessageBubble", for: indexPath) as! RightVideoMessageBubble
                                    senderCell.mediaMessage = videoMessage
                                    senderCell.indexPath = indexPath
                                    senderCell.receiptStack.isHidden = false
                                    return senderCell
                                }
                            }
                        case .audio where message.senderUid != LoggedInUser.uid:
                            
                            if let audioMessage = message as? MediaMessage {
                                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftAudioMessageBubble", for: indexPath) as! LeftAudioMessageBubble
                                receiverCell.audioMessage = audioMessage
                                receiverCell.indexPath = indexPath
                                receiverCell.receiptStack.isHidden = false
                                return receiverCell
                            }
                        case .audio where message.senderUid == LoggedInUser.uid:
                            if let audioMessage = message as? MediaMessage {
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightAudioMessageBubble", for: indexPath) as! RightAudioMessageBubble
                                senderCell.audioMessage = audioMessage
                                senderCell.indexPath = indexPath
                                senderCell.receiptStack.isHidden = false
                                return senderCell
                            }
                        case .file where message.senderUid != LoggedInUser.uid:
                            if let fileMessage = message as? MediaMessage {
                                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftFileMessageBubble", for: indexPath) as! LeftFileMessageBubble
                                receiverCell.fileMessage = fileMessage
                                receiverCell.indexPath = indexPath
                                receiverCell.receiptStack.isHidden = false
                                return receiverCell
                            }
                        case .file where message.senderUid == LoggedInUser.uid:
                            if let fileMessage = message as? MediaMessage {
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightFileMessageBubble", for: indexPath) as! RightFileMessageBubble
                                senderCell.fileMessage = fileMessage
                                senderCell.indexPath = indexPath
                                senderCell.receiptStack.isHidden = false
                                return senderCell
                            }
                        case .custom: break
                        case .groupMember:  break
                        case .image: break
                        case .text: break
                        case .file: break
                        case .video: break
                        case .audio: break
                        @unknown default: fatalError()
                        }
                    }
                }else if message.messageCategory == .action {
                    //  ActionMessage Cell
                    let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                    let actionMessage = message as? ActionMessage
                    actionMessageCell.message.text = actionMessage?.message
                    return actionMessageCell
                }else if message.messageCategory == .call {
                    //  CallMessage Cell
                    if let call = message as? Call {
                        let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                        actionMessageCell.call = call
                        return actionMessageCell
                    }else{
                        let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                        actionMessageCell.message.text = "Action Message"
                        return actionMessageCell
                    }
                    
                }else if message.messageCategory == .custom {
                    
                    if let type = (message as? CustomMessage)?.type {
                        if type == "location" {
                            if message.senderUid != LoggedInUser.uid {
                                if let locationMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftLocationMessageBubble", for: indexPath) as! LeftLocationMessageBubble
                                    receiverCell.locationMessage = locationMessage
                            
                                    return receiverCell
                                }
                            }else{
                                if let locationMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightLocationMessageBubble", for: indexPath) as! RightLocationMessageBubble
                                    senderCell.locationMessage = locationMessage
                                    return senderCell
                                }
                            }
                        }else if type == "extension_poll" {
                            if message.senderUid != LoggedInUser.uid {
                                if let pollMesage = message as? CustomMessage {
                                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftPollMessageBubble", for: indexPath) as! LeftPollMessageBubble
                                receiverCell.pollMessage = pollMesage
    
                                return receiverCell
                                }
                            }else{
                                if let pollMesage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightPollMessageBubble", for: indexPath) as! RightPollMessageBubble
                                    senderCell.pollMessage = pollMesage
                                    return senderCell
                                }
                            }
                        }else if type == "extension_sticker" {
                            if message.senderUid != LoggedInUser.uid {
                                if let stickerMessage = message as? CustomMessage {
                                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftStickerMessageBubble", for: indexPath) as! LeftStickerMessageBubble
                                receiverCell.stickerMessage = stickerMessage
    
                                return receiverCell
                                }
                            }else{
                                if let stickerMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightStickerMessageBubble", for: indexPath) as! RightStickerMessageBubble
                                    senderCell.stickerMessage = stickerMessage
                                    return senderCell
                                }
                            }
                        }else if type == "extension_whiteboard" {
                            
                            if message.senderUid != LoggedInUser.uid {
                                if let whiteboardMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftCollaborativeMessageBubble", for: indexPath) as! LeftCollaborativeMessageBubble
                                    receiverCell.whiteboardMessage = whiteboardMessage
                                
                                    return receiverCell
                                }
                            }else{
                                if let whiteboardMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightCollaborativeMessageBubble", for: indexPath) as! RightCollaborativeMessageBubble
                                   
                                    
                                    senderCell.whiteboardMessage = whiteboardMessage
                                   
                                    return senderCell
                                }
                            }
                        }else if type == "extension_document" {
                            
                            if message.senderUid != LoggedInUser.uid {
                                if let writeboardMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftCollaborativeMessageBubble", for: indexPath) as! LeftCollaborativeMessageBubble
                                    receiverCell.indexPath = indexPath
                                    receiverCell.writeboardMessage = writeboardMessage
                                   
                                    return receiverCell
                                }
                            }else{
                                if let writeboardMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightCollaborativeMessageBubble", for: indexPath) as! RightCollaborativeMessageBubble
                                  
                                    senderCell.writeboardMessage = writeboardMessage
                                   
                                   
                                    return senderCell
                                }
                            }
                        }else{
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                            let customMessage = message as? CustomMessage
                            receiverCell.message.text = NSLocalizedString("CUSTOM_MESSAGE", bundle: UIKitSettings.bundle, comment: "") +  "\(String(describing: customMessage?.customData))"
                            return receiverCell
                        }
                    }
                }
            }
        }else{
            let receipt = receipts[indexPath.row]
            
            let receiptBubble =  tableView.dequeueReusableCell(withIdentifier: "messageReceiptBubble", for: indexPath) as! MessageReceiptBubble
            receiptBubble.receipt = receipt
            return receiptBubble
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 && indexPath.row == 0 {
            return UITableView.automaticDimension
        }else{
            return 80
        }
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightTextMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftTextMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftReplyMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightReplyMessageBubble{
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if let selectedCell = tableView.cellForRow(at: indexPath) as? LeftVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftStickerMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightStickerMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightCollaborativeMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftCollaborativeMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
        },completion: nil)
        tableView.endUpdates()
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightTextMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftTextMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftReplyMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightReplyMessageBubble{
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightImageMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightVideoMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftImageMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if let selectedCell = tableView.cellForRow(at: indexPath) as? LeftVideoMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightFileMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftFileMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightAudioMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftAudioMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftStickerMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightStickerMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightCollaborativeMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftCollaborativeMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
        },completion: nil)
        tableView.endUpdates()
    }
}


extension MessageInformation: LocationCellDelegate {
    
 
    
    func didPressedOnLocation(latitude: Double, longitude: Double, name: String) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Open in Apple Maps", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.openMapsForPlace(latitude: latitude, longitude: longitude, name: name)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Open in Google Maps", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.openGoogleMapsForPlace(latitude: String(latitude), longitude: String(longitude))
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    func openMapsForPlace(latitude: CLLocationDegrees, longitude: CLLocationDegrees, name: String) {
        
        let latitude: CLLocationDegrees = 37.2
        let longitude: CLLocationDegrees = 22.9
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = name
        mapItem.openInMaps(launchOptions: options)
    }
    
    func openGoogleMapsForPlace(latitude: String, longitude: String) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
          UIApplication.shared.openURL(URL(string:
            "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic")!)
        } else {
        }
    }
}
