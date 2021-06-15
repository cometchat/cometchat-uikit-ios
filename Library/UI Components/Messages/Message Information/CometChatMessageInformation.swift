//
//  CometChatMessageInformation.swift
//  CometChatSwift
//
//  Created by Pushpsen Airekar on 27/08/20.
//  Copyright © 2020 MacMini-03. All rights reserved.
//

import UIKit
import MapKit
import CometChatPro

class CometChatMessageInformation: UIViewController {
    
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
        let nib = UINib(nibName: "CometChatMessageInformation", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        if let currentMessage = message {
            self.get(CometChatMessageInformation: currentMessage)
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
            let title = "REFRESHING".localized()
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshCometChatMessageInformation(sender:)),
                                     for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }
    
    @objc private func refreshCometChatMessageInformation(sender: UIRefreshControl) {
        if let currentMessage = message {
            self.get(CometChatMessageInformation: currentMessage)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.tableView.reloadData()
            }
        }
        sender.endRefreshing()
    }
    
    
    fileprivate func get(CometChatMessageInformation forMessage: BaseMessage){
        if let messageID = forMessage.id as? Int {
          
            CometChat.getMessageReceipts(messageID, onSuccess: { (fetchedReceipts) in
              
                self.receipts = fetchedReceipts
                DispatchQueue.main.async { self.tableView.reloadData() }
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
    
    private func didExtensionDetected(message: BaseMessage) -> CometChatExtension {
        var detectedExtension: CometChatExtension?
        
        if let metaData = message.metaData {
            if metaData["reply-message"] as? [String : Any] != nil {
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
        
        let CometChatReceiverTextMessageBubble  = UINib.init(nibName: "CometChatReceiverTextMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverTextMessageBubble, forCellReuseIdentifier: "CometChatReceiverTextMessageBubble")
        
        let CometChatSenderTextMessageBubble  = UINib.init(nibName: "CometChatSenderTextMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderTextMessageBubble, forCellReuseIdentifier: "CometChatSenderTextMessageBubble")
        
        let CometChatReceiverImageMessageBubble  = UINib.init(nibName: "CometChatReceiverImageMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverImageMessageBubble, forCellReuseIdentifier: "CometChatReceiverImageMessageBubble")
        
        let CometChatSenderImageMessageBubble  = UINib.init(nibName: "CometChatSenderImageMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderImageMessageBubble, forCellReuseIdentifier: "CometChatSenderImageMessageBubble")
        
        let CometChatReceiverVideoMessageBubble  = UINib.init(nibName: "CometChatReceiverVideoMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverVideoMessageBubble, forCellReuseIdentifier: "CometChatReceiverVideoMessageBubble")
        
        let CometChatSenderVideoMessageBubble  = UINib.init(nibName: "CometChatSenderVideoMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderVideoMessageBubble, forCellReuseIdentifier: "CometChatSenderVideoMessageBubble")
        
        let CometChatReceiverFileMessageBubble  = UINib.init(nibName: "CometChatReceiverFileMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverFileMessageBubble, forCellReuseIdentifier: "CometChatReceiverFileMessageBubble")
        
        let CometChatSenderFileMessageBubble  = UINib.init(nibName: "CometChatSenderFileMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderFileMessageBubble, forCellReuseIdentifier: "CometChatSenderFileMessageBubble")
        
        let CometChatReceiverAudioMessageBubble  = UINib.init(nibName: "CometChatReceiverAudioMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverAudioMessageBubble, forCellReuseIdentifier: "CometChatReceiverAudioMessageBubble")
        
        let CometChatSenderAudioMessageBubble  = UINib.init(nibName: "CometChatSenderAudioMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderAudioMessageBubble, forCellReuseIdentifier: "CometChatSenderAudioMessageBubble")
        
        let CometChatActionMessageBubble  = UINib.init(nibName: "CometChatActionMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatActionMessageBubble, forCellReuseIdentifier: "CometChatActionMessageBubble")
        
        let CometChatReceiverLinkPreviewBubble = UINib.init(nibName: "CometChatReceiverLinkPreviewBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverLinkPreviewBubble, forCellReuseIdentifier: "CometChatReceiverLinkPreviewBubble")
        
        let CometChatSenderLinkPreviewBubble = UINib.init(nibName: "CometChatSenderLinkPreviewBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderLinkPreviewBubble, forCellReuseIdentifier: "CometChatSenderLinkPreviewBubble")
        
        let CometChatReceiverReplyMessageBubble = UINib.init(nibName: "CometChatReceiverReplyMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverReplyMessageBubble, forCellReuseIdentifier: "CometChatReceiverReplyMessageBubble")
        
        
        let CometChatSenderReplyMessageBubble = UINib.init(nibName: "CometChatSenderReplyMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderReplyMessageBubble, forCellReuseIdentifier: "CometChatSenderReplyMessageBubble")
        
        let CometChatMessageReceiptItem = UINib.init(nibName: "CometChatMessageReceiptItem", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatMessageReceiptItem, forCellReuseIdentifier: "CometChatMessageReceiptItem")
        
        let CometChatReceiverLocationMessageBubble = UINib.init(nibName: "CometChatReceiverLocationMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverLocationMessageBubble, forCellReuseIdentifier: "CometChatReceiverLocationMessageBubble")
        
        let CometChatSenderLocationMessageBubble = UINib.init(nibName: "CometChatSenderLocationMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderLocationMessageBubble, forCellReuseIdentifier: "CometChatSenderLocationMessageBubble")
        
        let CometChatReceiverPollMessageBubble = UINib.init(nibName: "CometChatReceiverPollMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverPollMessageBubble, forCellReuseIdentifier: "CometChatReceiverPollMessageBubble")
        
        let CometChatSenderPollMessageBubble = UINib.init(nibName: "CometChatSenderPollMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderPollMessageBubble, forCellReuseIdentifier: "CometChatSenderPollMessageBubble")
        
        let CometChatReceiverStickerMessageBubble = UINib.init(nibName: "CometChatReceiverStickerMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverStickerMessageBubble, forCellReuseIdentifier: "CometChatReceiverStickerMessageBubble")
        
        let CometChatSenderStickerMessageBubble = UINib.init(nibName: "CometChatSenderStickerMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderStickerMessageBubble, forCellReuseIdentifier: "CometChatSenderStickerMessageBubble")
        
        let CometChatReceiverCollaborativeMessageBubble  = UINib.init(nibName: "CometChatReceiverCollaborativeMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverCollaborativeMessageBubble, forCellReuseIdentifier: "CometChatReceiverCollaborativeMessageBubble")
        
        let CometChatSenderCollaborativeMessageBubble  = UINib.init(nibName: "CometChatSenderCollaborativeMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderCollaborativeMessageBubble, forCellReuseIdentifier: "CometChatSenderCollaborativeMessageBubble")
    }
}

extension CometChatMessageInformation: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if (section == 0) {
            return "Message"
        }else{
            return "Receipt Information".localized()
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
                        let  deletedCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverTextMessageBubble", for: indexPath) as! CometChatReceiverTextMessageBubble
                        deletedCell.deletedMessage = message
                        deletedCell.receiptStack.isHidden = false
                        deletedCell.indexPath = indexPath
                        return deletedCell
                        
                    }else if message.deletedAt > 0.0 && message.senderUid == LoggedInUser.uid {
                        
                        let deletedCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderTextMessageBubble", for: indexPath) as! CometChatSenderTextMessageBubble
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
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverLinkPreviewBubble", for: indexPath) as! CometChatReceiverLinkPreviewBubble
                                    let linkPreviewMessage = message as? TextMessage
                                    receiverCell.linkPreviewMessage = linkPreviewMessage
                                    receiverCell.indexPath = indexPath
                                    receiverCell.receiptStack.isHidden = false
                                    //receiverCell.linkPreviewDelegate = self
                                    return receiverCell
                                case .reply:
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverReplyMessageBubble", for: indexPath) as! CometChatReceiverReplyMessageBubble
                                    receiverCell.indexPath = indexPath
                                    // receiverCell.delegate = self
                                    receiverCell.receiptStack.isHidden = false
                                    receiverCell.textMessage = textMessage
                                    return receiverCell
                                case .smartReply,.messageTranslation, .profanityFilter, .sentimentAnalysis, .none, .sticker:
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverTextMessageBubble", for: indexPath) as! CometChatReceiverTextMessageBubble
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
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderLinkPreviewBubble", for: indexPath) as! CometChatSenderLinkPreviewBubble
                                    let linkPreviewMessage = message as? TextMessage
                                    senderCell.linkPreviewMessage = linkPreviewMessage
                                    // senderCell.linkPreviewDelegate = self
                                    senderCell.receiptStack.isHidden = false
                                    senderCell.indexPath = indexPath
                                    return senderCell
                                case .reply:
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderReplyMessageBubble", for: indexPath) as! CometChatSenderReplyMessageBubble
                                    senderCell.textMessage = textMessage
                                    senderCell.receiptStack.isHidden = false
                                    senderCell.indexPath = indexPath
                                    return senderCell
                                    
                                case .smartReply,.messageTranslation, .profanityFilter, .sentimentAnalysis, .none:
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderTextMessageBubble", for: indexPath) as! CometChatSenderTextMessageBubble
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
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverImageMessageBubble", for: indexPath) as! CometChatReceiverImageMessageBubble
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
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderStickerMessageBubble", for: indexPath) as! CometChatSenderImageMessageBubble
                                    senderCell.mediaMessage = imageMessage
                                    senderCell.indexPath = indexPath
                                    senderCell.receiptStack.isHidden = false
                                    return senderCell
                                    
                                case .thumbnailGeneration, .imageModeration,.none:
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderImageMessageBubble", for: indexPath) as! CometChatSenderImageMessageBubble
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
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverVideoMessageBubble", for: indexPath) as! CometChatReceiverVideoMessageBubble
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
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderVideoMessageBubble", for: indexPath) as! CometChatSenderVideoMessageBubble
                                    senderCell.mediaMessage = videoMessage
                                    senderCell.indexPath = indexPath
                                    senderCell.receiptStack.isHidden = false
                                    return senderCell
                                }
                            }
                        case .audio where message.senderUid != LoggedInUser.uid:
                            
                            if let audioMessage = message as? MediaMessage {
                                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverAudioMessageBubble", for: indexPath) as! CometChatReceiverAudioMessageBubble
                                receiverCell.audioMessage = audioMessage
                                receiverCell.indexPath = indexPath
                                receiverCell.receiptStack.isHidden = false
                                return receiverCell
                            }
                        case .audio where message.senderUid == LoggedInUser.uid:
                            if let audioMessage = message as? MediaMessage {
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderAudioMessageBubble", for: indexPath) as! CometChatSenderAudioMessageBubble
                                senderCell.audioMessage = audioMessage
                                senderCell.indexPath = indexPath
                                senderCell.receiptStack.isHidden = false
                                return senderCell
                            }
                        case .file where message.senderUid != LoggedInUser.uid:
                            if let fileMessage = message as? MediaMessage {
                                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverFileMessageBubble", for: indexPath) as! CometChatReceiverFileMessageBubble
                                receiverCell.fileMessage = fileMessage
                                receiverCell.indexPath = indexPath
                                receiverCell.receiptStack.isHidden = false
                                return receiverCell
                            }
                        case .file where message.senderUid == LoggedInUser.uid:
                            if let fileMessage = message as? MediaMessage {
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderFileMessageBubble", for: indexPath) as! CometChatSenderFileMessageBubble
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
                    let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                    actionMessageCell.actionMessage = message as? ActionMessage
                    return actionMessageCell
                }else if message.messageCategory == .call {
                    //  CallMessage Cell
                    if let call = message as? Call {
                        let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                        actionMessageCell.call = call
                        return actionMessageCell
                    }else{
                        let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                        actionMessageCell.message.text = "Action Message"
                        return actionMessageCell
                    }
                    
                }else if message.messageCategory == .custom {
                    
                    if let type = (message as? CustomMessage)?.type {
                        if type == "location" {
                            if message.senderUid != LoggedInUser.uid {
                                if let locationMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverLocationMessageBubble", for: indexPath) as! CometChatReceiverLocationMessageBubble
                                    receiverCell.locationMessage = locationMessage
                            
                                    return receiverCell
                                }
                            }else{
                                if let locationMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderLocationMessageBubble", for: indexPath) as! CometChatSenderLocationMessageBubble
                                    senderCell.locationMessage = locationMessage
                                    return senderCell
                                }
                            }
                        }else if type == "extension_poll" {
                            if message.senderUid != LoggedInUser.uid {
                                if let pollMesage = message as? CustomMessage {
                                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverPollMessageBubble", for: indexPath) as! CometChatReceiverPollMessageBubble
                                receiverCell.pollMessage = pollMesage
    
                                return receiverCell
                                }
                            }else{
                                if let pollMesage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderPollMessageBubble", for: indexPath) as! CometChatSenderPollMessageBubble
                                    senderCell.pollMessage = pollMesage
                                    return senderCell
                                }
                            }
                        }else if type == "extension_sticker" {
                            if message.senderUid != LoggedInUser.uid {
                                if let stickerMessage = message as? CustomMessage {
                                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverStickerMessageBubble", for: indexPath) as! CometChatReceiverStickerMessageBubble
                                receiverCell.stickerMessage = stickerMessage
    
                                return receiverCell
                                }
                            }else{
                                if let stickerMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderStickerMessageBubble", for: indexPath) as! CometChatSenderStickerMessageBubble
                                    senderCell.stickerMessage = stickerMessage
                                    return senderCell
                                }
                            }
                        }else if type == "extension_whiteboard" {
                            
                            if message.senderUid != LoggedInUser.uid {
                                if let whiteboardMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverCollaborativeMessageBubble", for: indexPath) as! CometChatReceiverCollaborativeMessageBubble
                                    receiverCell.whiteboardMessage = whiteboardMessage
                                
                                    return receiverCell
                                }
                            }else{
                                if let whiteboardMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderCollaborativeMessageBubble", for: indexPath) as! CometChatSenderCollaborativeMessageBubble
                                   
                                    
                                    senderCell.whiteboardMessage = whiteboardMessage
                                   
                                    return senderCell
                                }
                            }
                        }else if type == "extension_document" {
                            
                            if message.senderUid != LoggedInUser.uid {
                                if let writeboardMessage = message as? CustomMessage {
                                    let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverCollaborativeMessageBubble", for: indexPath) as! CometChatReceiverCollaborativeMessageBubble
                                    receiverCell.indexPath = indexPath
                                    receiverCell.writeboardMessage = writeboardMessage
                                   
                                    return receiverCell
                                }
                            }else{
                                if let writeboardMessage = message as? CustomMessage {
                                    let senderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatSenderCollaborativeMessageBubble", for: indexPath) as! CometChatSenderCollaborativeMessageBubble
                                  
                                    senderCell.writeboardMessage = writeboardMessage
                                   
                                   
                                    return senderCell
                                }
                            }
                        }else{
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                            let customMessage = message as? CustomMessage
                            receiverCell.message.text = "CUSTOM_MESSAGE".localized() +  "\(String(describing: customMessage?.customData))"
                            return receiverCell
                        }
                    }
                }
            }
        }else{
            let receipt = receipts[indexPath.row]
            
            let receiptBubble =  tableView.dequeueReusableCell(withIdentifier: "CometChatMessageReceiptItem", for: indexPath) as! CometChatMessageReceiptItem
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
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderReplyMessageBubble{
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverStickerMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderStickerMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderCollaborativeMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverCollaborativeMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
        },completion: nil)
        tableView.endUpdates()
    }
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderReplyMessageBubble{
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderImageMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderVideoMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverImageMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverVideoMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderFileMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverFileMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderAudioMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverAudioMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverStickerMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderStickerMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderCollaborativeMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverCollaborativeMessageBubble {
                selectedCell.receiptStack.isHidden = true
            }
        },completion: nil)
        tableView.endUpdates()
    }
}


extension CometChatMessageInformation: LocationCellDelegate {
    
 
    
    func didPressedOnLocation(latitude: Double, longitude: Double, title: String) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Open in Apple Maps", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.openMapsForPlace(latitude: latitude, longitude: longitude, title: title)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Open in Google Maps", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.openGoogleMapsForPlace(latitude: String(latitude), longitude: String(longitude))
        }))
        
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.view.tintColor = UIKitSettings.primaryColor
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    func openMapsForPlace(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String) {
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
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
