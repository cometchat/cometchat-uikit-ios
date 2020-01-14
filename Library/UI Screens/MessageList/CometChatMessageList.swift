
//  CometChatListView.swift
//  CometChatUIKit

// Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.


import UIKit
import CometChatPro

public class CometChatMessageList: UIViewController, UIDocumentPickerDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var chatView: ChatView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
     @IBOutlet weak var blockedView: UIView!
    @IBOutlet weak var blockedMessage: UILabel!
    
    var safeArea: UILayoutGuide!
    let modelName = UIDevice.modelName
    var messageRequest:MessagesRequest?
    var memberRequest: GroupMembersRequest?
    var messages: [BaseMessage] = [BaseMessage]()
    var titleView : UIView?
    var buddyStatus: UILabel?
    var filteredMessages:[BaseMessage] = [BaseMessage]()
    var isGroupIs : Bool = false
    var typingIndicator: TypingIndicator?
    var refreshControl: UIRefreshControl!
    var membersCount:String?
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    var currentUser: User?
    var currentGroup: Group?
    var groupMembers: [GroupMember]?
    var currentEntity: CometChat.ReceiverType?
    
    override public func loadView() {
        super.loadView()
        setupSuperview()
        setupDelegates()
        setupTableView()
        registerCells()
        setupChatView()
        setupKeyboard()
        self.addObsevers()
    }

    
    public override func viewWillAppear(_ animated: Bool) {
        setupDelegates()
    }
    
    internal func setupSuperview() {
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatMessageList", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    internal func setupDelegates(){
        CometChat.messagedelegate = self
        CometChat.userdelegate = self
        CometChat.groupdelegate = self
    }
    
    
    internal func setupTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorColor = .clear
        documentPicker.delegate = self
        // Added Refresh Control
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), for: .valueChanged)
        tableView?.refreshControl = refreshControl
    }
    
    internal func setupNavigationBar(withTitle title: String){
        DispatchQueue.main.async {
            if self.navigationController != nil {
                //TitleView Apperance
                self.navigationItem.largeTitleDisplayMode = .never
                self.titleView = UIView(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.bounds.size.width)! - 200, height: 50))
                let buddyName = UILabel(frame: CGRect(x:0,y: 3,width: 200 ,height: 21))
                self.buddyStatus = UILabel(frame: CGRect(x:0,y: (self.titleView?.frame.origin.y ?? 0.0) + 22,width: 200,height: 21))
                self.buddyStatus?.textColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
                self.buddyStatus?.font = UIFont (name: "SFProDisplay-Regular", size: 15)
                self.buddyStatus?.textAlignment = NSTextAlignment.center
                self.navigationItem.titleView = self.titleView
                if #available(iOS 13.0, *) {
                    buddyName.textColor = .label
                    buddyName.font = UIFont (name: "SFProDisplay-Medium", size: 17)
                    buddyName.textAlignment = NSTextAlignment.center
                    buddyName.text = title
                } else {}
                self.titleView?.addSubview(buddyName)
                self.titleView?.addSubview(self.buddyStatus!)
                self.titleView?.center = CGPoint(x: 0, y: 0)
                let tapOnTitleView = UITapGestureRecognizer(target: self, action: #selector(self.didPresentDetailView(tapGestureRecognizer:)))
                self.titleView?.isUserInteractionEnabled = true
                self.titleView?.addGestureRecognizer(tapOnTitleView)
            }
        }
    }
    
    internal func setupNavigationBar(withSubtitle subtitle: String){
        DispatchQueue.main.async {
            self.buddyStatus?.text = subtitle
        }
    }
    
    internal func setupNavigationBar(withImage URL: String){
        DispatchQueue.main.async {
            // Avtar apperance:
            let avtarView = UIView(frame: CGRect(x: -10 , y: 0, width: 40, height: 40))
            avtarView.backgroundColor = UIColor.clear
            avtarView.layer.masksToBounds = true
            avtarView.layer.cornerRadius = 19
            let avtar = Avtar(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            avtar.set(cornerRadius: 19).set(borderColor: .clear).set(image: URL)
            avtarView.addSubview(avtar)
            let rightBarButton = UIBarButtonItem(customView: avtarView)
            self.navigationItem.rightBarButtonItem = rightBarButton
            let tapOnAvtar = UITapGestureRecognizer(target: self, action: #selector(self.didPresentDetailView(tapGestureRecognizer:)))
            avtarView.isUserInteractionEnabled = true
            avtarView.addGestureRecognizer(tapOnAvtar)
        }
    }
    
    
    @objc func didPresentDetailView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        
        guard let entity = currentEntity else {
            return
        }
        switch entity{
        case .user:
            guard let user = currentUser else {
                return
            }
            
            let userDetailView = CometChatUserDetail()
            let navigationController = UINavigationController(rootViewController: userDetailView)
            userDetailView.set(user: user)
            self.present(navigationController, animated: true, completion: nil)
            
        case .group:
            guard let group = currentGroup else {
                return
            }
            let groupDetailView = CometChatGroupDetail()
            let navigationController = UINavigationController(rootViewController: groupDetailView)
            groupDetailView.set(group: group, with: groupMembers ?? [])
            self.present(navigationController, animated: true, completion: nil)
        @unknown default:break
        }
    }
    
    internal func registerCells(){
        
        let leftTextMessageBubble  = UINib.init(nibName: "LeftTextMessageBubble", bundle: nil)
        self.tableView?.register(leftTextMessageBubble, forCellReuseIdentifier: "leftTextMessageBubble")
        
        let rightTextMessageBubble  = UINib.init(nibName: "RightTextMessageBubble", bundle: nil)
        self.tableView?.register(rightTextMessageBubble, forCellReuseIdentifier: "rightTextMessageBubble")
        
        let leftImageMessageBubble  = UINib.init(nibName: "LeftImageMessageBubble", bundle: nil)
        self.tableView?.register(leftImageMessageBubble, forCellReuseIdentifier: "leftImageMessageBubble")
        
        let rightImageMessageBubble  = UINib.init(nibName: "RightImageMessageBubble", bundle: nil)
        self.tableView?.register(rightImageMessageBubble, forCellReuseIdentifier: "rightImageMessageBubble")
        
        let leftFileMessageBubble  = UINib.init(nibName: "LeftFileMessageBubble", bundle: nil)
        self.tableView?.register(leftFileMessageBubble, forCellReuseIdentifier: "leftFileMessageBubble")
        
        let rightFileMessageBubble  = UINib.init(nibName: "RightFileMessageBubble", bundle: nil)
        self.tableView?.register(rightFileMessageBubble, forCellReuseIdentifier: "rightFileMessageBubble")
        
        let actionMessageBubble  = UINib.init(nibName: "ActionMessageBubble", bundle: nil)
        self.tableView?.register(actionMessageBubble, forCellReuseIdentifier: "actionMessageBubble")
    }
    
    internal func setupChatView(){
        chatView.internalDelegate = self
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                chatView.sticker.imageView?.image = #imageLiteral(resourceName: "stickerDark")
            }
        } else { }
        chatView.textView.delegate = self
        textView.delegate = self
    }
    
    
    public func set(conversationWith: AppEntity, type: CometChat.ReceiverType){
       switch type {
            case .user:
            isGroupIs = false
            guard let user = conversationWith as? User else{
                return
            }
            currentUser = user
            currentEntity = .user
            fetchUserInfo(user: user)
            switch (conversationWith as? User)!.status {
            case .online:
                setupNavigationBar(withTitle: user.name?.capitalized ?? "")
                setupNavigationBar(withSubtitle: "online")
                setupNavigationBar(withImage: user.avatar ?? "")
            case .offline:
                setupNavigationBar(withTitle: user.name?.capitalized ?? "")
                setupNavigationBar(withSubtitle: "offline")
                setupNavigationBar(withImage: user.avatar ?? "")
            @unknown default:break
            }
            
            messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: currentUser?.uid ?? "").set(limit: 30).build()
            messageRequest?.fetchPrevious(onSuccess: { (fetchedMessages) in
                guard  let messages = fetchedMessages  else{
                    return
                }
                guard let lastMessage = messages.last else {
                    return
                }
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: self.currentUser?.uid ?? "", receiverType: .user)
                self.messages.append(contentsOf: messages)
                self.filteredMessages = messages.filter {$0.sender?.uid == CometChat.getLoggedInUser()?.uid}
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }, onError: { (error) in
                print("error while fetching messages for user: \(String(describing: error?.errorDescription))")
            })
            typingIndicator = TypingIndicator(receiverID: currentUser?.uid ?? "", receiverType: .user)
        case .group:
            isGroupIs = true
            guard let group = conversationWith as? Group else{
                return
            }
            currentGroup = group
            currentEntity = .group
            setupNavigationBar(withTitle: group.name?.capitalized ?? "")
            setupNavigationBar(withImage: group.icon ?? "")
            fetchGroupMembers(group: group)
            isGroupIs = true
            messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: currentGroup?.guid ?? "").set(limit: 30).build()
            messageRequest?.fetchPrevious(onSuccess: { (fetchedMessages) in
                 guard  let messages = fetchedMessages  else {
                                   return
                  }
                guard let lastMessage = messages.last else {
                    return
                }
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: self.currentGroup?.guid ?? "", receiverType: .group)
                self.messages.append(contentsOf: messages)
                self.filteredMessages = messages.filter {$0.sender?.uid == CometChat.getLoggedInUser()?.uid}
                DispatchQueue.main.async {
                    self.tableView?.reloadData()
                }
            }, onError: { (error) in
                print("error while fetching messages for group: \(String(describing: error?.errorDescription))")
            })
            typingIndicator = TypingIndicator(receiverID: currentGroup?.guid ?? "", receiverType: .group)
        @unknown default:
            break
        }
    }
    
    @objc func refresh(_ sender: Any) {
        guard let request = messageRequest else {
            return
        }
        fetchPreviousMessages(messageReq: request)
    }
    
    private func fetchPreviousMessages(messageReq:MessagesRequest){
        messageReq.fetchPrevious(onSuccess: { (messages) in
            guard let messages = messages else{
                return
            }
            guard let lastMessage = messages.last else {
                return
            }
            if self.isGroupIs == true {
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: self.currentGroup?.guid ?? "", receiverType: .group)
            }else{
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: self.currentUser?.uid ?? "", receiverType: .user)
            }
            var oldMessages = [BaseMessage]()
            for msg in messages{
                oldMessages.append(msg)
            }
            let oldMessageArray =  oldMessages
            self.messages.insert(contentsOf: oldMessageArray, at: 0)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.refreshControl.endRefreshing()
            }
        }) { (error) in
            DispatchQueue.main.async{
                self.refreshControl.endRefreshing()
            }
            print("fetchPreviousMessages error: \(String(describing: error?.errorDescription))")
        }
    }
    
    
    fileprivate func refreshMessageList(forID: String, type: CometChat.ReceiverType){
          
        messages.removeAll()
        switch type {
               case .user:
               messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).set(limit: 30).build()
               messageRequest?.fetchPrevious(onSuccess: { (fetchedMessages) in
                   guard  let messages = fetchedMessages  else{
                       return
                   }
                   guard let lastMessage = messages.last else {
                       return
                   }
                   CometChat.markAsRead(messageId: lastMessage.id, receiverId: forID, receiverType: .user)
                   self.messages.append(contentsOf: messages)
                   self.filteredMessages = messages.filter {$0.sender?.uid == CometChat.getLoggedInUser()?.uid}
                   DispatchQueue.main.async {
                       self.tableView?.reloadData()
                   }
               }, onError: { (error) in
                   print("error while fetching messages for user: \(String(describing: error?.errorDescription))")
               })
               typingIndicator = TypingIndicator(receiverID: forID, receiverType: .user)
           case .group:
               messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).set(limit: 30).build()
               messageRequest?.fetchPrevious(onSuccess: { (fetchedMessages) in
                    guard  let messages = fetchedMessages  else {
                                      return
                     }
                   guard let lastMessage = messages.last else {
                       return
                   }
                   CometChat.markAsRead(messageId: lastMessage.id, receiverId: forID, receiverType: .group)
                   self.messages.append(contentsOf: messages)
                   self.filteredMessages = messages.filter {$0.sender?.uid == CometChat.getLoggedInUser()?.uid}
                   DispatchQueue.main.async {
                       self.tableView?.reloadData()
                   }
               }, onError: { (error) in
                   print("error while fetching messages for group: \(String(describing: error?.errorDescription))")
               })
               typingIndicator = TypingIndicator(receiverID: forID, receiverType: .group)
           @unknown default:
               break
           }
       }
    
    private func fetchUserInfo(user: User){
         CometChat.getUser(UID: user.uid ?? "", onSuccess: { (user) in
              if  user?.blockedByMe == true {
                  if let name = self.currentUser?.name {
                      DispatchQueue.main.async {
                           self.blockedView.isHidden = false
                           self.blockedMessage.text = "You've blocked \(String(describing: name.capitalized))"
                      }
                  }
              }
          }) { (error) in
              print("error while getUser info: \(String(describing: error?.errorDescription))")
          }
    }
    
    
    private func fetchGroupMembers(group: Group){
        
        memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: group.guid).set(limit: 100).build()
        memberRequest?.fetchNext(onSuccess: { (groupMember) in
            self.groupMembers = groupMember
            if groupMember.count < 100 {
                self.setupNavigationBar(withTitle: group.name?.capitalized ?? "")
                self.setupNavigationBar(withSubtitle: "\(groupMember.count) Members")
                self.membersCount = "\(groupMember.count) Members"
            }else{
                self.setupNavigationBar(withSubtitle: "100+ Members")
                self.membersCount = "100+ Members"
            }
        }, onError: { (error) in
            print("Group Member list fetching failed with exception:" + error!.errorDescription);
        })
    }
    
    private func refreshGroupMembers(guid: String){
        
         memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: guid).set(limit: 100).build()
                 memberRequest?.fetchNext(onSuccess: { (groupMember) in
                     self.groupMembers = groupMember
                     if groupMember.count < 100 {
                         self.setupNavigationBar(withSubtitle: "\(groupMember.count) Members")
                     }else{
                         self.setupNavigationBar(withSubtitle: "100+ Members")
                     }
                 }, onError: { (error) in
                     print("Group Member list fetching failed with exception:" + error!.errorDescription);
           })
    }
    
    
    private func addObsevers(){
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil)
         NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserBlocked(_:)), name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
         NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupDeleted(_:)), name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
    }
    
    @objc func didGroupDeleted(_ notification: NSNotification) {
           
           self.navigationController?.popToRootViewController(animated: true)
           
     }
    
    @objc func didUserBlocked(_ notification: NSNotification) {
        if let name = notification.userInfo?["name"] as? String {
        blockedView.isHidden = false
        blockedMessage.text = "You've blocked \(String(describing: name.capitalized))"
        }
    }
    
    @objc func didRefreshGroupDetails(_ notification: NSNotification) {
        if let guid = notification.userInfo?["guid"] as? String {
            self.refreshMessageList(forID: guid, type: .group)
            self.refreshGroupMembers(guid: guid)
        }
    }
    
    
    private func setupKeyboard(){
        
        /*** Customize GrowingTextView ***/
        chatView.textView.layer.cornerRadius = 4.0
        
        // *** Listen to keyboard show / hide ***
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        // *** Hide keyboard when tapping outside ***
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapGestureHandler))
        tapGesture.cancelsTouchesInView = false
        tableView?.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
        }
    }
    
    
    @objc func tapGestureHandler() {
        view.endEditing(true)
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @IBAction func didUnblockedUserPressed(_ sender: Any) {
        
        dismissKeyboard()
        if let uid =  currentUser?.uid {
            CometChat.unblockUsers([uid], onSuccess: { (success) in
                DispatchQueue.main.async {
                    self.blockedView.isHidden = true
                }
            }) { (error) in
                print("error while unblocking the user: \(String(describing: error?.errorDescription))")
            }
        }
    }
    
    
    
    
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            var mediaMessage: MediaMessage?
            switch self.isGroupIs {
            case true:
                mediaMessage = MediaMessage(receiverUid: currentGroup?.guid ?? "", fileurl: urls[0].absoluteString,messageType: .file, receiverType: .group)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                self.messages.append(mediaMessage!)
                self.filteredMessages.append(mediaMessage!)
                DispatchQueue.main.async {
                    self.tableView?.beginUpdates()
                    self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                    self.tableView?.endUpdates()
                    self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
                CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                    if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                        self.messages[row] = message}
                    DispatchQueue.main.async{ self.tableView?.reloadData()}
                }) { (error) in
                    print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                }
                
            case false:
                
                mediaMessage = MediaMessage(receiverUid: currentUser?.uid ?? "", fileurl: urls[0].absoluteString, messageType: .file, receiverType: .user)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                self.messages.append(mediaMessage!)
                self.filteredMessages.append(mediaMessage!)
                DispatchQueue.main.async {
                    self.tableView?.beginUpdates()
                    self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                    self.tableView?.endUpdates()
                    self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
                CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                    if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                        self.messages[row] = message}
                    DispatchQueue.main.async{ self.tableView?.reloadData()}
                }) { (error) in
                    print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                }
            }
        }
    }
}



extension CometChatMessageList: UITableViewDelegate , UITableViewDataSource {
    
    // MARK: - Table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let selectedRows = tableView.indexPathsForSelectedRows, selectedRows.contains(indexPath) {
            return UITableView.automaticDimension
        } else {
            return UITableView.automaticDimension
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell()
        let  message = messages[indexPath.row]
        
        if message.messageCategory == .message {
            switch message.messageType {
            case .text where message.senderUid != CometChat.getLoggedInUser()?.uid:
                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftTextMessageBubble", for: indexPath) as! LeftTextMessageBubble
                 let textMessage = message as? TextMessage
                receiverCell.textMessage = textMessage
                return receiverCell
                
            case .text where message.senderUid == CometChat.getLoggedInUser()?.uid:
                
                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightTextMessageBubble", for: indexPath) as! RightTextMessageBubble
                let textMessage = message as? TextMessage
                senderCell.textMessage = textMessage
                
                if  messages[indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                    senderCell.timeStamp.isHidden = false
                    senderCell.heightConstraint.constant = 18
                }else{
                    senderCell.timeStamp.isHidden = true
                    senderCell.heightConstraint.constant = 0
                }
                return senderCell
            case .image where message.senderUid != CometChat.getLoggedInUser()?.uid:
                
                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftImageMessageBubble", for: indexPath) as! LeftImageMessageBubble
                let mediaMessage = message as? MediaMessage
                receiverCell.mediaMessage = mediaMessage
                return receiverCell
                
            case .image where message.senderUid == CometChat.getLoggedInUser()?.uid:
                
                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightImageMessageBubble", for: indexPath) as! RightImageMessageBubble
                let mediaMessage = message as? MediaMessage
                senderCell.mediaMessage = mediaMessage
                
                if  messages[indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                    senderCell.timeStamp.isHidden = false
                    senderCell.heightConstraint.constant = 18
                }else{
                    senderCell.timeStamp.isHidden = true
                    senderCell.heightConstraint.constant = 0
                }
                return senderCell
                
            case .video:
                
                let  videoMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                      videoMessageCell.message.text = "Video Message"
                      return videoMessageCell
                
            case .audio:
                
                let  audioMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                      audioMessageCell.message.text = "Audio Message"
                       return audioMessageCell
                
            case .file where message.senderUid != CometChat.getLoggedInUser()?.uid:
                
                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftFileMessageBubble", for: indexPath) as! LeftFileMessageBubble
                let fileMessage = message as? MediaMessage
                receiverCell.fileMessage = fileMessage
                return receiverCell
                
            case .file where message.senderUid == CometChat.getLoggedInUser()?.uid:
                
                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightFileMessageBubble", for: indexPath) as! RightFileMessageBubble
                senderCell.sizeToFit()
                let fileMessage = message as? MediaMessage
                senderCell.fileMessage = fileMessage
                
                if  messages[indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                    senderCell.timeStamp.isHidden = false
                    senderCell.heightConstraint.constant = 18
                }else{
                    senderCell.timeStamp.isHidden = true
                    senderCell.heightConstraint.constant = 0
                }
                return senderCell
            case .custom:
                let  customMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                     customMessageCell.message.text = "Custom Message"
                     return customMessageCell
                
            case .groupMember:  break
            case .image: break
            case .text: break
            case .file: break
            @unknown default: break
            }
        }else if message.messageCategory == .action {
            let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
            let actionMessage = message as? ActionMessage
            actionMessageCell.message.text = actionMessage?.message
            return actionMessageCell
        }else if message.messageCategory == .call {
            let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
            let actionMessage = message as? ActionMessage
            actionMessageCell.message.text = actionMessage?.message
            return actionMessageCell
        }else if message.messageCategory == .custom {
            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
            let customMessage = message as? CustomMessage
            receiverCell.message.text = "custom message: \(String(describing: customMessage?.customData))"
            return receiverCell
        }
        return cell
    }
    
    @available(iOS 13.0, *)
    public func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
          return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
              
                  let removeMember = UIAction(title: "Remove Member", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                      
                  
                      
                  }
                
                  return UIMenu(title: "" , children: [removeMember])
          })
          
      }
    
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.beginUpdates()
        UIView.animate(withDuration: 0.5) {
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightTextMessageBubble {
                selectedCell.timeStamp.isHidden = false
                selectedCell.heightConstraint.constant = 18
            }
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftTextMessageBubble {
                selectedCell.timeStamp.isHidden = false
                selectedCell.heightConstraint.constant = 18
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightImageMessageBubble {
                
                selectedCell.timeStamp.isHidden = false
                selectedCell.heightConstraint.constant = 18
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftImageMessageBubble {
                selectedCell.timeStamp.isHidden = false
                selectedCell.heightConstraint.constant = 18
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightFileMessageBubble {
                selectedCell.timeStamp.isHidden = false
                selectedCell.heightConstraint.constant = 18
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftFileMessageBubble {
                selectedCell.timeStamp.isHidden = false
                selectedCell.heightConstraint.constant = 18
            }
        }
        tableView.endUpdates()
    }
    
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        UIView.animate(withDuration: 0.5) {
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightTextMessageBubble {
                selectedCell.timeStamp.isHidden = true
                selectedCell.heightConstraint.constant = 0
                selectedCell.sizeToFit()
            }
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftTextMessageBubble {
                selectedCell.timeStamp.isHidden = true
                selectedCell.heightConstraint.constant = 0
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightImageMessageBubble {
                selectedCell.timeStamp.isHidden = true
                selectedCell.heightConstraint.constant = 0
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftImageMessageBubble {
                selectedCell.timeStamp.isHidden = true
                selectedCell.heightConstraint.constant = 0
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightFileMessageBubble {
                selectedCell.timeStamp.isHidden = true
                selectedCell.heightConstraint.constant = 0
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftFileMessageBubble {
                selectedCell.timeStamp.isHidden = true
                selectedCell.heightConstraint.constant = 0
            }
        }
        tableView.endUpdates()
    }
    
}

extension CometChatMessageList : UITextViewDelegate {
    
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
        }
    }
    
    public func textViewDidChange(_ textView: UITextView) {
        guard let indicator = typingIndicator else {
            return
        }
        CometChat.startTyping(indicator: indicator)
    }  
}

extension CometChatMessageList : ChatViewInternalDelegate {
    
    func didAttachmentButtonPressed() {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Photo & Video Library", comment: ""), style: .default) { action -> Void in
            CameraHandler.shared.presentPhotoLibrary(for: self)
            CameraHandler.shared.imagePickedBlock = { (photoURL) in
                var mediaMessage: MediaMessage?
                switch self.isGroupIs {
                case true:
                    mediaMessage = MediaMessage(receiverUid: self.currentGroup?.guid ?? "", fileurl: photoURL, messageType: .image, receiverType: .group)
                    mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    mediaMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                    mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    self.messages.append(mediaMessage!)
                    self.filteredMessages.append(mediaMessage!)
                    DispatchQueue.main.async {
                        self.tableView?.beginUpdates()
                        self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                        self.tableView?.endUpdates()
                        self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                    CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                        if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                            self.messages[row] = message}
                        DispatchQueue.main.async{ self.tableView?.reloadData()}
                    }) { (error) in
                        print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                    }
                    
                case false:
                    mediaMessage = MediaMessage(receiverUid: self.currentUser?.uid ?? "", fileurl: photoURL, messageType: .image, receiverType: .user)
                    mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    mediaMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                    mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    self.messages.append(mediaMessage!)
                    self.filteredMessages.append(mediaMessage!)
                    DispatchQueue.main.async {
                        self.tableView?.beginUpdates()
                        self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                        self.tableView?.endUpdates()
                        self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    }
                    CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                        if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                            self.messages[row] = message}
                        DispatchQueue.main.async{ self.tableView?.reloadData()}
                    }) { (error) in
                        print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                    }
                    
                    let group = Group(guid: "1111", name: "1111", groupType: .public, password: nil, icon: photoURL , description: "")
                    
                    CometChat.createGroup(group: group, onSuccess: { (group) in
                        
                        print("createGroup onSuccess: \(group.stringValue())")
                        
                    }) { (error) in
                        
                        print("createGroup error: \(error?.errorDescription)")
                    }
                }
            }
        }
        
        let documentAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Document", comment: ""), style: .default) { action -> Void in
            
            self.documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(self.documentPicker, animated: true, completion: nil)
            
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action -> Void in
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(photoLibraryAction)
        actionSheetController.addAction(documentAction)
        actionSheetController.addAction(cancelAction)
        
        // Added ActionSheet support for iPad
        if self.view.frame.origin.y != 0 {
            dismissKeyboard()
            
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
                
                if let currentPopoverpresentioncontroller = actionSheetController.popoverPresentationController{
                    currentPopoverpresentioncontroller.sourceView = self.view
                    currentPopoverpresentioncontroller.sourceRect = (self as AnyObject).bounds
                    self.present(actionSheetController, animated: true, completion: nil)
                }
            }else{
                self.present(actionSheetController, animated: true, completion: nil)
            }
        }else{
            if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
                if let currentPopoverpresentioncontroller = actionSheetController.popoverPresentationController{
                    currentPopoverpresentioncontroller.sourceView = self.view
                    currentPopoverpresentioncontroller.sourceRect = (self as AnyObject).bounds
                    self.present(actionSheetController, animated: true, completion: nil)
                }
            }else{
                self.present(actionSheetController, animated: true, completion: nil)
            }
        }
    }
    
    func didStickerButtonPressed() {
        
    }
    
    func didMicrophoneButtonPressed() {
        
    }
    
    
    
    func didSendButtonPressed() {
        var textMessage: TextMessage?
        let message:String = chatView?.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        if(message.count == 0){
            
        }else{
            
            switch self.isGroupIs {
            case true:
                textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: message, receiverType: .group)
                textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                textMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                self.messages.append(textMessage!)
                self.filteredMessages.append(textMessage!)
                guard let indicator = typingIndicator else {
                    return
                }
                CometChat.endTyping(indicator: indicator)
                DispatchQueue.main.async {
                    self.tableView?.beginUpdates()
                    self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                    self.tableView?.endUpdates()
                    self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    self.chatView.textView.text = ""
                }
                
                CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                    if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                        self.messages[row] = message
                    }
                    DispatchQueue.main.async{ self.tableView?.reloadData()
                    }
                }) { (error) in
                    print("sendTextMessage error: \(String(describing: error?.errorDescription))")
                }
            case false:
                textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: message, receiverType: .user)
                textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                textMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                self.messages.append(textMessage!)
                self.filteredMessages.append(textMessage!)
                guard let indicator = typingIndicator else {
                    return
                }
                CometChat.endTyping(indicator: indicator)
                DispatchQueue.main.async {
                    self.tableView?.beginUpdates()
                    self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                    self.tableView?.endUpdates()
                    self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                    self.chatView.textView.text = ""
                }
                CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                    if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                        self.messages[row] = message
                    }
                    DispatchQueue.main.async{ self.tableView?.reloadData()
                    }
                }) { (error) in
                    print("sendTextMessage error: \(String(describing: error?.errorDescription))")
                }
            }
        }
    }
}



extension CometChatMessageList : CometChatMessageDelegate {
    
    public func onTextMessageReceived(textMessage: TextMessage) {
        DispatchQueue.main.async{
            if textMessage.sender?.uid == self.currentUser?.uid && textMessage.receiverType == .user {
                CometChat.markAsRead(messageId: textMessage.id, receiverId: textMessage.senderUid, receiverType: .user)
                self.messages.append(textMessage)
                DispatchQueue.main.async{
                    self.tableView?.reloadData()
                    self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }else if textMessage.receiverUid == self.currentGroup?.guid && textMessage.receiverType == .group {
                CometChat.markAsRead(messageId: textMessage.id, receiverId: textMessage.receiverUid, receiverType: .group)
                self.messages.append(textMessage)
                DispatchQueue.main.async{
                    self.tableView?.reloadData()
                    self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }
        }
    }
    
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        DispatchQueue.main.async{
            if mediaMessage.sender?.uid == self.currentUser?.uid && mediaMessage.receiverType == .user{
                CometChat.markAsRead(messageId: mediaMessage.id, receiverId: mediaMessage.senderUid, receiverType: .user)
                self.messages.append(mediaMessage)
                DispatchQueue.main.async{
                    self.tableView?.reloadData()
                    self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }else if mediaMessage.receiverUid == self.currentGroup?.guid && mediaMessage.receiverType == .group {
                CometChat.markAsRead(messageId: mediaMessage.id, receiverId: mediaMessage.receiverUid, receiverType: .group)
                self.messages.append(mediaMessage)
                DispatchQueue.main.async{
                    self.tableView?.reloadData()
                    self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
                }
            }
        }
    }
    
    public func onMessagesRead(receipt: MessageReceipt) {
        DispatchQueue.main.async{
            if receipt.sender?.uid == self.currentUser?.uid && receipt.receiverType == .user{
                for msg in self.messages where msg.readAt == 0 {
                    msg.readAt = Double(receipt.timeStamp)
                }
                DispatchQueue.main.async {self.tableView?.reloadData()}
            }else if receipt.receiverId == self.currentGroup?.guid && receipt.receiverType == .group{
                for msg in self.messages where msg.readAt == 0 {
                    msg.readAt = Double(receipt.timeStamp)
                }
                DispatchQueue.main.async {self.tableView?.reloadData()}
            }
        }
    }
    
    public func onMessagesDelivered(receipt: MessageReceipt) {
        DispatchQueue.main.async{
            if receipt.sender?.uid == self.currentUser?.uid && receipt.receiverType == .user{
                for msg in self.messages where msg.deliveredAt == 0   {
                    msg.deliveredAt = Double(receipt.timeStamp)
                }
                DispatchQueue.main.async {self.tableView?.reloadData()}
            }else if receipt.receiverId == self.currentGroup?.guid && receipt.receiverType == .group{
                for msg in self.messages where msg.deliveredAt == 0   {
                    msg.deliveredAt = Double(receipt.timeStamp)
                }
                DispatchQueue.main.async {self.tableView?.reloadData()}
            }
        }
    }
    
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
        DispatchQueue.main.async{
            if typingDetails.sender?.uid == self.currentUser?.uid && typingDetails.receiverType == .user{
                DispatchQueue.main.async {
                    self.setupNavigationBar(withSubtitle: "typing...")
                }
            }else if typingDetails.receiverType == .group  && typingDetails.receiverID == self.currentGroup?.guid {
                if let user = typingDetails.sender?.name {
                    DispatchQueue.main.async {
                        self.setupNavigationBar(withSubtitle: "\(String(describing: user)) is typing...")
                    }
                }
                
            }
        }
    }
    
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
        DispatchQueue.main.async{
            if typingDetails.sender?.uid == self.currentUser?.uid && typingDetails.receiverType == .user{
                DispatchQueue.main.async {
                    self.setupNavigationBar(withSubtitle: "online")
                }
            }else if typingDetails.receiverType == .group  && typingDetails.receiverID == self.currentGroup?.guid {
                self.setupNavigationBar(withSubtitle: self.membersCount ?? "")
            }
        }
    }
}

extension CometChatMessageList : CometChatUserDelegate {
    
    // This event triggers when user is Online.
    public func onUserOnline(user: User) {
        if user.uid == currentUser?.uid{
            if user.status == .online {
                DispatchQueue.main.async {
                    self.setupNavigationBar(withSubtitle: "online")
                }
            }
        }
    }
    
    // This event triggers when user is Offline.
    public func onUserOffline(user: User) {
        if user.uid == currentUser?.uid {
            if user.status == .offline {
                DispatchQueue.main.async {
                    self.setupNavigationBar(withSubtitle: "offline")
                }
            }
        }
    }
}


extension CometChatMessageList : CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroupMembers(group: joinedGroup)
                       CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
                       self.messages.append(action)
                       DispatchQueue.main.async{
                           self.tableView?.reloadData()
                           self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
              }
        }
    }
    
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
             self.fetchGroupMembers(group: leftGroup)
                       CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
                       self.messages.append(action)
                       DispatchQueue.main.async{
                           self.tableView?.reloadData()
                           self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
              }
        }
    }
    
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
             self.fetchGroupMembers(group: kickedFrom)
                       CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
                       self.messages.append(action)
                       DispatchQueue.main.async{
                           self.tableView?.reloadData()
                           self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
              }
        }
    }
    
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
                       CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
                       self.messages.append(action)
                       DispatchQueue.main.async{
                           self.tableView?.reloadData()
                           self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
              }
        }
    }
    
    
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
                       CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
                       self.messages.append(action)
                       DispatchQueue.main.async{
                           self.tableView?.reloadData()
                           self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
              }
        }
    }
    
    
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
                       CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
                       self.messages.append(action)
                       DispatchQueue.main.async{
                           self.tableView?.reloadData()
                           self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
              }
        }
    }
    
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
              self.fetchGroupMembers(group: addedTo)
                       CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
                       self.messages.append(action)
                       DispatchQueue.main.async{
                           self.tableView?.reloadData()
                           self.tableView?.scrollToRow(at: IndexPath.init(row: self.messages.count-1, section: 0), at: UITableView.ScrollPosition.bottom, animated: true)
              }
        }
    }
}




