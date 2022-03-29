//
//  CometChatMessageList.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 27/11/21.
//

import UIKit
import CometChatPro


public enum  MessageType : String {
    case text = "text"
    case audio = "audio"
    case video = "video"
    case image = "image"
    case file = "file"
    case poll = "extension_poll"
    case sticker = "extension_sticker"
    case location = "location"
    case meeting = "meeting"
    case callAction = "call"
    case groupAction = "action"
    case collaborativeDocument = "extension_document"
    case collaborativeWhiteboard = "extension_whiteboard"
    
}

@objc @IBDesignable class CometChatMessageList: UIView , NibLoadable {
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var reactionView: CometChatLiveReaction!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Declaration of Variables
    var messageRequest:MessagesRequest?
    var messages: [BaseMessage] = [BaseMessage]()
    var chatMessages: [[BaseMessage]] = [[BaseMessage]]()
    var currentGroup: Group?
    var currentUser: User?
    var selectedMessage: BaseMessage?
    var selectedIndexPath: IndexPath?
    var messageType: [MessageType] = [.text]
    var refreshControl: UIRefreshControl!
    var isHideDeleteMessages: Bool = true
    var isAnimating = false
    var currentReaction: LiveReaction = .heart
    var messageTypes: [String] = [String]()
    var messageCategories: [String] = [String]()
    weak var controller: UIViewController?
    var customViews:[String: UIView ] = [String:UIView]()
    var messagesConfigurations: CometChatMessagesConfiguration?
    var messageHovers:[String: [MessageHover]] = [String: [MessageHover]]()
    var templates: [CometChatMessageTemplate] = [CometChatMessageTemplate]()
    
    
    @discardableResult
    @objc public func set(configuration: CometChatConfiguration) -> CometChatMessageList {
        if let configuration = configuration as? CometChatMessagesConfiguration {
            
        }
        return self
    }
    
    
    @discardableResult
    @objc public func set(user: User) -> CometChatMessageList {
        self.currentUser = user
        self.set(conversationWith: user, type: .user)
        return self
    }
    
    
    @discardableResult
    @objc public func set(group: Group) -> CometChatMessageList {
        self.currentGroup = group
        self.set(conversationWith: group, type: .group)
        return self
    }
    
//    @discardableResult
//    public func set(messageType: [MessageType]) -> CometChatMessageList {
//        self.messageType = messageType
//        return self
//    }
    
    @discardableResult
    @objc public func set(backgroundColor: UIColor) -> CometChatMessageList {
        self.background.backgroundColor = backgroundColor
        return self
    }
    
    @discardableResult
    @objc public func scrollToBottom() -> CometChatMessageList {
        self.tableView?.scrollToBottomRow()
        return self
    }
    
    
    @discardableResult
    @objc public func set(controller: UIViewController) -> CometChatMessageList {
        self.controller = controller
        return self
    }
    
    @discardableResult
    @objc public func set(templates: [CometChatMessageTemplate]) -> CometChatMessageList {
        print("template is: \(templates)")
        self.templates = templates
        if let currentUser = currentUser {
            self.set(conversationWith: currentUser, type: .user)
        }
        if let currentGroup = currentGroup {
            self.set(conversationWith: currentGroup, type: .group)
        }
        return self
    }
    
    
    @discardableResult
    @objc public func setMessageFilter(templates: [CometChatMessageTemplate]?) -> CometChatMessageList {
        if let messageTemplates = templates {
            if !messageTemplates.isEmpty {
            print("messageTemplated: \(messageTemplates)")
            for template in messageTemplates {
                switch template.id {
                case "text", "image", "video", "audio", "file":
                    if !(messageCategories.contains("message")){
                        self.messageCategories.append("message")
                    }
                    if !(messageTypes.contains(template.id)){
                        self.messageTypes.append(template.id)
                    }
                    
                case "groupActions":
                    if !(messageCategories.contains("action")){
                        self.messageCategories.append("action")
                    }
                    if !(messageTypes.contains("groupMember")){
                        self.messageTypes.append("groupMember")
                    }

                case "call":
                    if !(messageCategories.contains("call")){
                        self.messageCategories.append("call")
                    }
                    if !(messageTypes.contains("audio")){
                        self.messageTypes.append("audio")
                    }
                    if !(messageTypes.contains("video")){
                        self.messageTypes.append("video")
                    }
                default:
                    if !(messageCategories.contains("custom")){
                        self.messageCategories.append("custom")
                    }
                    if !(messageTypes.contains(template.id)){
                        self.messageTypes.append(template.id)
                    }
                }
                if let customView = template.customView {
                    self.customViews.append(with: [template.id : customView ])
                }
                if let messageHovers = template.onLongPress {
                    self.messageHovers.append(with: [template.id : messageHovers ])
                }
            }
            }else{
                if !(messageCategories.contains("message")){
                    self.messageCategories.append("message")
                }
                if !(messageTypes.contains("text")){
                    self.messageTypes.append("text")
                }
            }
        }else{
            if !(messageCategories.contains("message")){
                self.messageCategories.append("message")
            }
            if !(messageTypes.contains("text")){
                self.messageTypes.append("text")
            }
        }
        
        return self
    }
    
  
    /**
     This method specifies the entity of user or group which user wants to begin the conversation.
     - Parameters:
     - conversationWith: Spcifies `AppEntity` Object which can take `User` or `Group` Object.
     - type: Spcifies a type of `AppEntity` such as `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatMessages Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc public func set(conversationWith: AppEntity, type: CometChat.ReceiverType){
        self.setMessageFilter(templates: templates)
        switch type {
        case .user:
            guard let user = conversationWith as? User else{ return }
            self.refreshMessageList(forID: user.uid ?? "" , type: .user)
        case .group:
            guard let group = conversationWith as? Group else{ return }
            self.refreshMessageList(forID: group.guid , type: .group)
        @unknown default:
            break
        }
        
    }
    
    
    
    // MARK: - CometChatPro Instance Methods
    
    
    /**
     This method group the new message as per timestamp and append it on UI
     - Parameters:
     - messages: Specifies the group of message containing same timestamp.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessages Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addNewGroupedMessage(messages: [BaseMessage]){
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if messages.isEmpty { strongSelf.tableView?.setEmptyMessage("NO_MESSAGES_FOUND".localize())
            }else{ strongSelf.tableView?.restore() }
        }
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.chatMessages.append(values ?? [])
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.beginUpdates()
                strongSelf.tableView?.insertSections([0], with: .top)
                let lastSection = strongSelf.tableView?.numberOfSections
                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection ?? 0].count - 1, section: lastSection ?? 0)], with: .automatic)
                strongSelf.tableView?.endUpdates()
            }
        }
    }
    
    /**
     This method groups the  messages as per timestamp.
     - Parameters:
     - messages: Specifies the group of message containing same timestamp.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessages Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func groupMessages(messages: [BaseMessage]){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if messages.isEmpty { strongSelf.tableView?.setEmptyMessage("NO_MESSAGES_FOUND".localize())
            }else{ strongSelf.tableView?.restore() }
        }
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        let sortedKeys = groupedMessages.keys.sorted()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.chatMessages.append(values ?? [])
            DispatchQueue.main.async{  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.reloadData()
                strongSelf.refreshControl?.endRefreshing()
            }
        }
    }
    
    /**
     This method groups the  previous messages as per timestamp.
     - Parameters:
     - messages: Specifies the group of message containing same timestamp.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessages Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func groupPreviousMessages(messages: [BaseMessage]){
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        var sortedKeys = groupedMessages.keys.sorted()
        sortedKeys = sortedKeys.reversed()
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            self.chatMessages.insert(values ?? [], at: 0)
            DispatchQueue.main.async{ [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.reloadData()
                strongSelf.refreshControl?.endRefreshing()
            }
        }
    }
    
    /**
     This method fetches the older messages from the server using `MessagesRequest` class.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatMessages Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchPreviousMessages(messageReq:MessagesRequest){
        messageReq.fetchPrevious(onSuccess: {  [weak self] (fetchedMessages) in
            guard let strongSelf = self else { return }
            if fetchedMessages?.count == 0 {
                DispatchQueue.main.async {
                    strongSelf.refreshControl?.endRefreshing()
                }
            }
            guard let messages = fetchedMessages else { return }
            if fetchedMessages?.count != 0 && messages.count == 0 {
                if let request = strongSelf.messageRequest {
                    self?.fetchPreviousMessages(messageReq: request)
                }
            }
            guard let lastMessage = messages.last else { return }
            CometChat.markAsRead(baseMessage: lastMessage)
            var oldMessages = [BaseMessage]()
            for msg in messages{ oldMessages.append(msg) }
            var oldMessageArray =  oldMessages
            oldMessageArray.sort { (obj1, obj2) -> Bool in
                return (obj1.sentAt) < (obj2.sentAt)
            }
            strongSelf.groupPreviousMessages(messages: oldMessageArray)
            
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
                self.refreshControl?.endRefreshing()
            }
        }
    }
    
    
    
    /**
     This method refreshes the  messages  using `MessagesRequest` class.
     - Parameters:
     - forID: This specifies a string value which takes `uid` or `guid`.
     - type: This specifies `ReceiverType` Object which can be `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     - See Also:
     [CometChatMessages Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func refreshMessageList(forID: String, type: CometChat.ReceiverType){
        chatMessages.removeAll()
        messages.removeAll()
        
        print("message categories: \(messageCategories)")
        
        print("message types: \(messageTypes)")
        
        switch type {
        case .user:
            
            if isHideDeleteMessages == true {
                self.messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).set(categories: messageCategories).set(types: messageTypes).hideReplies(hide: true).hideDeletedMessages(hide: true).set(limit: 30).build()
            } else {
                self.messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).set(categories: messageCategories).set(types: messageTypes).set(limit: 30).build()
            }
            
            messageRequest?.fetchPrevious(onSuccess: { [weak self] (fetchedMessages) in
                guard let strongSelf = self else { return }
                guard let messages = fetchedMessages else { return }
                if fetchedMessages?.count != 0 && messages.count == 0 {
                    if let request = strongSelf.messageRequest {
                        self?.fetchPreviousMessages(messageReq: request)
                    }
                }
                strongSelf.groupMessages(messages: messages)
                guard let lastMessage = messages.last else { return }
                CometChat.markAsRead(baseMessage: lastMessage)
                strongSelf.messages.append(contentsOf: messages)
                DispatchQueue.main.async {
                    strongSelf.tableView?.reloadData()
                    strongSelf.scrollToBottom()
                }
               
            }, onError: { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            })
        case .group:
            
            if isHideDeleteMessages {
                self.messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).set(categories: messageCategories).set(types: messageTypes).hideReplies(hide: true).hideDeletedMessages(hide: true).set(limit: 30).build()
            } else {
                self.messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).set(categories: messageCategories).set(types: messageTypes).hideReplies(hide: true).set(limit: 30).build()
            }
            
            messageRequest?.fetchPrevious(onSuccess: {[weak self] (fetchedMessages) in
                guard let strongSelf = self else { return }
                guard let messages = fetchedMessages else { return }
                if fetchedMessages?.count != 0 && messages.count == 0 {
                    if let request = strongSelf.messageRequest {
                        self?.fetchPreviousMessages(messageReq: request)
                    }
                }
                strongSelf.groupMessages(messages: messages)
                guard let lastMessage = messages.last else { return }
                CometChat.markAsRead(baseMessage: lastMessage)
                strongSelf.messages.append(contentsOf: messages)
                DispatchQueue.main.async {
                    strongSelf.tableView?.reloadData()
                    strongSelf.scrollToBottom()
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            })
            @unknown default: break }
    }
    
    @discardableResult
    @objc public func updateMessage(message: BaseMessage) -> CometChatMessageList {
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                
                if let indexpath = strongSelf.chatMessages.indexPath(where: {$0.muid == message.muid}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
                    
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.chatMessages[section][row] = message
                    strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                    strongSelf.tableView?.endUpdates()
                    
                }
            }
        return self
    }
    
    @discardableResult
    @objc public func deleteMessage(message: BaseMessage) -> CometChatMessageList {
        
       
        CometChat.delete(messageId: message.id) { deletedMessage in
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                if let indexpath = strongSelf.chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
                    
                   // if strongSelf.isHideDeleteMessages {
                        strongSelf.tableView.beginUpdates()
                        strongSelf.chatMessages[section].remove(at: row)
                        strongSelf.tableView?.deleteRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView.endUpdates()
//                    }else{
//
//                    }
                }
            }
        } onError: { error in
            
        }
        return self
    }
    
    
    @discardableResult
    @objc public func appendMessage(message: BaseMessage)  -> CometChatMessageList {
        var lastSection = 0
        DispatchQueue.main.async{
            if self.chatMessages.count == 0 {
                lastSection = (self.tableView?.numberOfSections ?? 0)
            }else {
                lastSection = (self.tableView?.numberOfSections ?? 0) - 1
            }
        }
        switch message.receiverType {
        case .user:
            CometChat.markAsRead(baseMessage: message)
            if chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [message])
            }else{
                DispatchQueue.main.async{ [weak self] in
                    if let strongSelf = self {
                        strongSelf.tableView?.beginUpdates()
                        strongSelf.chatMessages[lastSection].append(message)
                        strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .automatic)
                        strongSelf.tableView?.endUpdates()
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
            }
            
            
        case .group:
            CometChat.markAsRead(baseMessage: message)
            if chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [message])
            }else{
                DispatchQueue.main.async{ [weak self] in
                    if let strongSelf = self {
                        
                        strongSelf.tableView?.beginUpdates()
                        strongSelf.chatMessages[lastSection].append(message)
                        strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .automatic)
                        strongSelf.tableView?.endUpdates()
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
            }
        @unknown default: break
        }
        return self
    }
    
    private func clearMessageCache() {
        messages.removeAll()
        chatMessages.removeAll()
    }
    
    private func markMessageAsRead(message: BaseMessage) {
        CometChat.markAsRead(baseMessage: message)
    }
    
    private func markMessageAsDelivered(message: BaseMessage) {
        CometChat.markAsDelivered(baseMessage: message)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        
        Bundle.main.loadNibNamed("CometChatMessageList", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        setupTableView()
        registerCells()
        registerObervers()
        
        print("templates: \(templates)")
    }
    
    fileprivate func registerObervers() {
        CometChat.messagedelegate = self
        CometChatMessageComposer.messageComposerDelegate = self
    }
    
    fileprivate func setupTableView() {
        tableView.separatorStyle = .none
        tableView.setEmptyMessage("LOADING".localize())
        tableView.dataSource = self
        tableView.delegate = self
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadPreviousMessages), for: .valueChanged)
        tableView?.refreshControl = refreshControl        
    }
    
    fileprivate func registerCells() {
        
        // New Combined Cells
        self.registerCellWith(title: "CometChatTextBubble")
        self.registerCellWith(title: "CometChatImageBubble")
        self.registerCellWith(title: "CometChatVideoBubble")
        self.registerCellWith(title: "CometChatFileBubble")
        self.registerCellWith(title: "CometChatAudioBubble")
        self.registerCellWith(title: "CometChatLocationBubble")
        self.registerCellWith(title: "CometChatStickerBubble")
        self.registerCellWith(title: "CometChatWhiteboardBubble")
        self.registerCellWith(title: "CometChatDocumentBubble")
        self.registerCellWith(title: "CometChatMeetingBubble")
        self.registerCellWith(title: "CometChatPollsBubble")
        self.registerCellWith(title: "CometChatCallActionBubble")
        self.registerCellWith(title: "CometChatGroupActionBubble")
        self.registerCellWith(title: "CometChatCustomBubble")
        
    }
    
    private func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: Bundle.main)
        self.tableView.register(cell, forCellReuseIdentifier: title)
    }
    
    @objc func loadPreviousMessages(_ sender: Any) {
        guard let request = messageRequest else {
            return
        }
        self.fetchPreviousMessages(messageReq: request)
    }
}


extension CometChatMessageList: UITableViewDelegate, UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        if chatMessages.isEmpty {
            return 0
        }else {
            return chatMessages.count
        }
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[safe:section]?.first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "d MMM, yyyy"
            let dateString = String().setMessageDateHeader(time: Int(firstMessageInSection.sentAt))
            let label = CometChatMessageDateHeader()
            if dateString == "1 Jan, 1970" {
                label.text = "TODAY".localize()
            }else{
                label.text = dateString
            }
            let containerView = UIView()
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            return containerView
        }
        return nil
    }
    
    public  func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    public  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return chatMessages[safe: section]?.count ?? 0
    }
    
    public  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    public  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let section = indexPath.section as? Int else { return UITableViewCell() }
        
        if let message = chatMessages[safe: section]?[safe: indexPath.row] {
            
            if message.deletedAt > 0.0 {
                
                if let textMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatTextBubble", for: indexPath) as? CometChatTextBubble {
                    textMessageCell.set(messageObject: message)
                    return textMessageCell
                }
                
            }else{
                
                if message.messageCategory == .message {
                    
                    switch message.messageType {
                    case .custom: break
                    case .groupMember:  break
                        
                        
                    case .text:
                        
                        if let textMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatTextBubble", for: indexPath) as? CometChatTextBubble, let message = message as? TextMessage {
                            textMessageCell.set(messageObject: message)
                            textMessageCell.textDelegate = self
                            textMessageCell.indexPath = indexPath
                            return textMessageCell
                        }
                    case .image:
                        
                        if let imageMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatImageBubble", for: indexPath) as? CometChatImageBubble, let message = message as? MediaMessage {
                            imageMessageCell.set(messageObject: message)
                            imageMessageCell.mediaDelegate = self
                            return imageMessageCell
                        }
                        
                        
                    case .file:
                        
                        if let fileMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatFileBubble", for: indexPath) as? CometChatFileBubble, let message = message as? MediaMessage {
                            fileMessageCell.set(messageObject: message)
                             fileMessageCell.mediaDelegate = self
                            return fileMessageCell
                        }
                        
                    case .video:
                        
                        if let videoMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatVideoBubble", for: indexPath) as? CometChatVideoBubble, let message = message as? MediaMessage {
                            videoMessageCell.set(messageObject: message)
                             videoMessageCell.mediaDelegate = self
                            return videoMessageCell
                        }
                    case .audio:
                        
                        if let audioMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatAudioBubble", for: indexPath) as? CometChatAudioBubble, let message = message as? MediaMessage {
                            audioMessageCell.set(messageObject: message)
                             audioMessageCell.mediaDelegate = self
                            return audioMessageCell
                        }
                        
                    @unknown default: fatalError()
                    }
                }else if message.messageCategory == .action {
                 
                    let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatGroupActionBubble", for: indexPath) as! CometChatGroupActionBubble
                    actionMessageCell.set(messageObject: message)
                    return actionMessageCell
                    
                }else if message.messageCategory == .call {
                    
                    if let callMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatCallActionBubble", for: indexPath) as? CometChatCallActionBubble, let message = message as? Call {
                        callMessageCell.set(messageObject: message)
                        return callMessageCell
                    }
                    
                }else if message.messageCategory == .custom {
                    if let type = (message as? CustomMessage)?.type {
                        if type == "location" {
                            
                            if let locationMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatLocationBubble", for: indexPath) as? CometChatLocationBubble, let message = message as? CustomMessage {
                                locationMessageCell.set(messageObject: message)
                                //  locationMessageCell.locationDelegate = self
                                return locationMessageCell
                            }
                            
                        }else if type == "extension_poll" {
                            
                            if let pollsMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatPollsBubble", for: indexPath) as? CometChatPollsBubble , let message = message as? CustomMessage {
                                pollsMessageCell.set(messageObject: message)
                                //  pollsMessageCell.pollDelegate = self
                                return pollsMessageCell
                            }
                            
                        }else if type == "extension_sticker" {
                            
                            if let stickerMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatStickerBubble", for: indexPath) as? CometChatStickerBubble, let message = message as? CustomMessage {
                                stickerMessageCell.set(messageObject: message)
                                //  stickerMessageCell.stickerDelegate = self
                                return stickerMessageCell
                            }
                            
                        }else if type == "extension_whiteboard" {
                            
                            if let whiteboardCell = tableView.dequeueReusableCell(withIdentifier: "CometChatWhiteboardBubble", for: indexPath) as? CometChatWhiteboardBubble, let message = message as? CustomMessage {
                                whiteboardCell.set(messageObject: message)
                                //   whiteboardCell.collaborativeDelegate = self
                                return whiteboardCell
                            }
                            
                        }else if type == "extension_document" {
                            
                            if let documentCell = tableView.dequeueReusableCell(withIdentifier: "CometChatDocumentBubble", for: indexPath) as? CometChatDocumentBubble, let message = message as? CustomMessage {
                                documentCell.set(messageObject: message)
                                //  documentCell.collaborativeDelegate = self
                                return documentCell
                            }
                            
                        }else if type == "meeting" {
                            
                            if let documentCell = tableView.dequeueReusableCell(withIdentifier: "CometChatMeetingBubble", for: indexPath) as? CometChatMeetingBubble, let message = message as? CustomMessage {
                                documentCell.set(messageObject: message)
                                // documentCell.meetingDelegate = self
                                return documentCell
                            }
                            
                        }else{
                            
                            if let  customPlaceholderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatCustomBubble", for: indexPath) as? CometChatCustomBubble, let message = message as? CustomMessage {
                                customPlaceholderCell.set(messageObject: message)
                                customPlaceholderCell.set(templates: templates)
//                                if let customView = customViews[message.type ?? ""] as? UIView {
//                                    customPlaceholderCell.set(customView: customView)
//                                }
                                return customPlaceholderCell
                            }
                        }
                    }else{
                        //  CustomMessage Cell
                        if let  customPlaceholderCell = tableView.dequeueReusableCell(withIdentifier: "CometChatCustomBubble", for: indexPath) as? CometChatCustomBubble, let message = message as? CustomMessage {
                            customPlaceholderCell.set(messageObject: message)
                            customPlaceholderCell.set(templates: templates)
                            
                            
                           // customPlaceholderCell.customMessageDelegate = self
                           return customPlaceholderCell
                        }
                       
                    }
                }
            }
        }
        return UITableViewCell()
    }

}




