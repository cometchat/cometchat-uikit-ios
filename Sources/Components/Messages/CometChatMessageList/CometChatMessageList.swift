//
//  CometChatMessageList.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 27/11/21.
//

import UIKit
import CometChatPro


@objc @IBDesignable class CometChatMessageList: UIView  {
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var reactionView: CometChatLiveReaction!
    @IBOutlet weak var smartReplies: CometChatSmartReplies!
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
    var isAnimating = false
    var currentReaction: LiveReaction = .heart
    weak var controller: UIViewController?
    var customViews: [String: ((_ message: BaseMessage) -> (UIView))?] = [:]
    var messagesConfigurations: MessageListConfiguration?
    var messageOptions:[String: [CometChatMessageOption]] = [String: [CometChatMessageOption]]()
    var messagetTypeTemplates: [CometChatMessageTemplate] = [CometChatMessageTemplate]()
    var limit: Int = 20
    var searchKeyword: String = ""
    var status: CometChat.UserStatus = .offline
    var friendsOnly: Bool = false
    var onlyUnreadMessages: Bool = false
    var hideMessagesFromBlockedUsers: Bool = false
    var hideDeletedMessages: Bool = false
    var hideThreadReplies: Bool = false
    var scrollToBottomOnNewMessage: Bool = true
    var showEmojiInLargerSize: Bool = true
    var hideError: Bool = false
    var roles: [String] = [String]()
    var tags: [String] = [String]()
    var uids: [String] = [String]()
    var messageTypes: [String] = [String]()
    var messageCategories: [String] = [String]()
    var emptyView: UIView?
    var errorView: UIView?
    var errorStateText: String = ""
    var emptyStateText: String = "NO_MESSAGES_FOUND".localize()
    var emptyStateTextFont: UIFont = UIFont.systemFont(ofSize: 34, weight: .bold)
    var emptyStateTextColor: UIColor = UIColor.gray
    var errorStateTextFont: UIFont?
    var errorStateTextColor: UIColor?
    var messageListAlignment: UIKitConstants.MessageListAlignmentConstants = .standard
    var messageBubbleConfiguration: MessageBubbleConfiguration?
    var excludedMessageOptions: [CometChatMessageOption]?
    var enableSoundForMessages: Bool = true
    var customIncomingMessageSound: URL?
    var configuration: CometChatConfiguration?
    var configurations: [CometChatConfiguration]?
    
    
    @discardableResult
    @objc public func set(configuration: CometChatConfiguration) -> Self {
        self.configuration = configuration
        return self
    }
    
    @discardableResult
    public func set(configurations: [CometChatConfiguration]) ->  Self {
        self.configurations = configurations
        configureMessageList()
        return self
    }
    
    @discardableResult
    @objc public func set(limit: Int) -> Self {
        self.limit = limit
        return self
    }
    
    @discardableResult
    public func show(onlyUnreadMessages: Bool) -> Self {
        self.onlyUnreadMessages = onlyUnreadMessages
        return self
    }
    
    @discardableResult
    public func hide(messagesFromBlockedUsers: Bool) -> Self {
        self.hideMessagesFromBlockedUsers = messagesFromBlockedUsers
        return self
    }
    @discardableResult
    public func hide(deletedMessages: Bool) -> Self {
        self.hideDeletedMessages = deletedMessages
        return self
    }
    @discardableResult
    public func hide(threadedReplies: Bool) -> Self {
        self.hideThreadReplies = threadedReplies
        return self
    }
    @discardableResult
    public func hide(error: Bool) -> Self {
        self.hideError = error
        return self
    }
    @discardableResult
    public func set(tags: [String]) -> Self {
        self.tags = tags
        return self
    }
    @discardableResult
    public func set(excludeMessageTypes: [CometChatMessageTemplate]) -> Self {
        let currentExcludeMessageTypes:[String] = excludeMessageTypes.map { $0.type }
        self.messageTypes = Array(Set(messageTypes).subtracting(currentExcludeMessageTypes))
        return self
    }
    @discardableResult
    public func set(emptyText: String) -> Self {
        self.emptyStateText = emptyText
        return self
    }
    
    @discardableResult
    public func set(errorText: String) -> Self {
        self.errorStateText = errorText
        return self
    }
    
    @discardableResult
    public func set(emptyStateTextFont: UIFont) -> Self {
        self.emptyStateTextFont = emptyStateTextFont
        return self
    }
    
    @discardableResult
    public func set(errorStateTextFont: UIFont) -> Self {
        self.errorStateTextFont = errorStateTextFont
        return self
    }
    
    @discardableResult
    public func set(emptyStateTextColor: UIColor) -> Self {
        self.emptyStateTextColor = emptyStateTextColor
        return self
    }
    
    @discardableResult
    public func set(errorStateTextColor: UIColor) -> Self {
        self.errorStateTextColor = errorStateTextColor
        return self
    }
    
    @discardableResult
    public func set(emptyView: UIView?) -> Self {
        self.emptyView = emptyView
        return self
    }
    
    @discardableResult
    public func scrollToBottomOnNewMessage(bool: Bool) -> Self {
        self.scrollToBottomOnNewMessage = bool
        return self
    }
    @discardableResult
    public func showEmojiInLargerSize(bool: Bool) -> Self {
        self.showEmojiInLargerSize = bool
        return self
    }
    
    @discardableResult
    public func set(messageBubbleConfiguration: MessageBubbleConfiguration?) -> Self {
        self.messageBubbleConfiguration = messageBubbleConfiguration
        return self
    }
    @discardableResult
    public func set(excludedMessageOptions: [CometChatMessageOption]) -> Self {
        self.excludedMessageOptions = excludedMessageOptions
        return self
    }
    @discardableResult
    public func set(messageListAlignment: UIKitConstants.MessageListAlignmentConstants) -> Self {
        self.messageListAlignment = messageListAlignment
        return self
    }
    
    @discardableResult
    @objc public func enableSoundForMessages(bool: Bool) -> Self {
        self.enableSoundForMessages = bool
        return self
    }
    
    @discardableResult
    @objc public func set(customIncomingMessageSound: URL) -> Self {
        self.customIncomingMessageSound = customIncomingMessageSound
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
    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatUserList`.
     - Parameters:
     - background: This method will set the background color for CometChatUserList, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatUserList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [Any]?) ->  CometChatMessageList {
        if let backgroundColors = background as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: background)
            }
        }
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
      @objc public func translate(message: BaseMessage) -> Self {
        var textMessage: TextMessage?
        if let message = message as? TextMessage {
          textMessage = message
          let systemLanguage = Locale.preferredLanguages.first?.replacingOccurrences(of: "-US", with: "")
            CometChat.callExtension(slug: ExtensionConstants.messageTranslation, type: .post, endPoint: "v2/translate", body: ["msgId": message.id ,"languages": [systemLanguage], "text": message.text] as [String : Any], onSuccess: { (response) in
            DispatchQueue.main.async {
              if let response = response, let originalLanguage = response["language_original"] as? String {
                if originalLanguage == systemLanguage {
                  let confirmDialog = CometChatDialog()
                  confirmDialog.set(messageText: "NO_TRANSLATION_AVAILABLE".localize())
                  confirmDialog.set(confirmButtonText: "OK".localize())
                  confirmDialog.open(onConfirm: {})
                }else{
                  if let translatedLanguages = response["translations"] as? [[String:Any]] {
                    for tranlates in translatedLanguages {
                      print("tranlates: \(tranlates)")
                      if let languageTranslated = tranlates["language_translated"] as? String, let messageTranslated = tranlates["message_translated"] as? String {
                        textMessage?.metaData?.append(with: ["translated-message": messageTranslated])
                        if languageTranslated == systemLanguage {
                          if let textMessage = textMessage {
                            self.update(message: textMessage)
                          }
                        }else{
                          let confirmDialog = CometChatDialog()
                          confirmDialog.set(messageText: "NO_TRANSLATION_AVAILABLE".localize())
                          confirmDialog.set(confirmButtonText: "OK".localize())
                          confirmDialog.open(onConfirm: {})
                        }
                      }
                    }
                  }
                }
              }
            }
          }) { (error) in
              if let error = error {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                confirmDialog.set(error: CometChatServerError.get(error: error))
                confirmDialog.open(onConfirm: { [weak self] in
                  guard let strongSelf = self else { return }
                  // Referesh list
                  strongSelf.reloadInputViews()
                })
              }
          }
        }
        return self
      }

    @discardableResult
      @objc public func set(templates: [CometChatMessageTemplate]) -> CometChatMessageList {
        print("template is: \(templates)")
        self.messagetTypeTemplates = templates
        if let currentUser = currentUser {
          self.set(conversationWith: currentUser, type: .user)
        }
        if let currentGroup = currentGroup {
          self.set(conversationWith: currentGroup, type: .group)
        }
        return self
      }
    
    
    @discardableResult
      @objc public func set(messageTypes: [CometChatMessageTemplate]?) -> CometChatMessageList {
        if let messageTemplates = messageTypes {
          if !messageTemplates.isEmpty {

            for template in messageTemplates {
              switch template.type {
              case UIKitConstants.MessageTypeConstants.text, UIKitConstants.MessageTypeConstants.image, UIKitConstants.MessageTypeConstants.video, UIKitConstants.MessageTypeConstants.audio, UIKitConstants.MessageTypeConstants.file:
                  if !(messageCategories.contains(UIKitConstants.MessageCategoryConstants.message)){
                  self.messageCategories.append(UIKitConstants.MessageCategoryConstants.message)
                }
                if !(self.messageTypes.contains(template.type)){
                  self.messageTypes.append(template.type)
                }
              case "groupActions":
                if !(messageCategories.contains(UIKitConstants.MessageCategoryConstants.action)){
                  self.messageCategories.append(UIKitConstants.MessageCategoryConstants.action)
                }
                if !(self.messageTypes.contains("groupMember")){
                  self.messageTypes.append("groupMember")
                }
              case UIKitConstants.MessageCategoryConstants.call:
                if !(messageCategories.contains(UIKitConstants.MessageCategoryConstants.call)){
                  self.messageCategories.append(UIKitConstants.MessageCategoryConstants.call)
                }
                if !(self.messageTypes.contains(UIKitConstants.MessageTypeConstants.audio)){
                  self.messageTypes.append(UIKitConstants.MessageTypeConstants.audio)
                }
                if !(self.messageTypes.contains(UIKitConstants.MessageTypeConstants.video)){
                  self.messageTypes.append(UIKitConstants.MessageTypeConstants.video)
                }
              default:
                if !(messageCategories.contains(UIKitConstants.MessageCategoryConstants.custom)){
                  self.messageCategories.append(UIKitConstants.MessageCategoryConstants.custom)
                }
                if !(self.messageTypes.contains(template.type)){
                  self.messageTypes.append(template.type)
                }
              }
               if let customView = template.customView {
                self.customViews.append(with: [template.type : customView])
               }
                if let messageOptions = template.options {
                  
                    if let excludedMessageOptions = excludedMessageOptions {
                        let currentExcludedOptions = Array(Set(messageOptions).subtracting(excludedMessageOptions ?? []))
                        self.messageOptions.append(with: [template.type : currentExcludedOptions])
                    }else{
                        self.messageOptions.append(with: [template.type : messageOptions])
                    }
                }
            }
          }else{
              self.messageCategories =
                                    [UIKitConstants.MessageCategoryConstants.message,               UIKitConstants.MessageCategoryConstants.custom,
                                        UIKitConstants.MessageCategoryConstants.call,
                                        UIKitConstants.MessageCategoryConstants.action]
              
              self.messageTypes = [UIKitConstants.MessageTypeConstants.text,
                                   UIKitConstants.MessageTypeConstants.image,
                                   UIKitConstants.MessageTypeConstants.text,
                                   UIKitConstants.MessageTypeConstants.audio,
                                   UIKitConstants.MessageTypeConstants.file,
                                   UIKitConstants.MessageTypeConstants.groupMember,
                                   UIKitConstants.MessageTypeConstants.poll,
                                   UIKitConstants.MessageTypeConstants.whiteboard,
                                   UIKitConstants.MessageTypeConstants.document,
                                   UIKitConstants.MessageTypeConstants.sticker,
                                   UIKitConstants.MessageTypeConstants.meeting ]
                          
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
        configureMessageList()
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
            if messages.isEmpty {
                if let emptyView = strongSelf.emptyView {
                    strongSelf.tableView.set(customView: emptyView)
                }else{
                    strongSelf.tableView?.setEmptyMessage(strongSelf.emptyStateText ?? "", color: strongSelf.emptyStateTextColor, font: strongSelf.emptyStateTextFont)
                }
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
            if messages.isEmpty {
                if let emptyView = strongSelf.emptyView {
                    strongSelf.tableView.set(customView: emptyView)
                }else{
                    strongSelf.tableView?.setEmptyMessage(strongSelf.emptyStateText ?? "", color: strongSelf.emptyStateTextColor, font: strongSelf.emptyStateTextFont)
                }
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
            if let error = error ,  !self.hideError {
                let confirmDialog = CometChatDialog()
                confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                confirmDialog.set(cancelButtonText: "CANCEL".localize())
                if self.errorStateText.isEmpty {
                    confirmDialog.set(error: CometChatServerError.get(error: error))
                }else{
                    confirmDialog.set(messageText: self.errorStateText)
                }
                confirmDialog.open(onConfirm: { [weak self] in
                    guard let strongSelf = self else { return }
                    // Referesh list
                    strongSelf.tableView.reloadData()
                })
            }
            self.refreshControl?.endRefreshing()
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
        

        switch type {        case .user:
            
            self.messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).set(categories: messageCategories).set(types: messageTypes).hideReplies(hide: true).hideDeletedMessages(hide: hideDeletedMessages).set(unread: onlyUnreadMessages).hideMessagesFromBlockedUsers(hideMessagesFromBlockedUsers).setTags(tags).set(limit: limit).build()
            
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
                    
                    if let currentUser = strongSelf.currentUser , let textMessage = lastMessage as? TextMessage {
                        strongSelf.smartReplies.backgroundColor = CometChatTheme.palatte?.background ?? .systemBackground
                        strongSelf.smartReplies.set(message: textMessage)
                            .set(user: currentUser)
                    }else{
                        strongSelf.smartReplies.isHidden = true
                    }
                    
                    strongSelf.tableView?.reloadData()
                    strongSelf.scrollToBottom()
                }
                
            }, onError: { (error) in
                if let error = error , !self.hideError {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    if self.errorStateText.isEmpty {
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                    }else{
                        confirmDialog.set(messageText: self.errorStateText)
                    }
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                        // Referesh list
                        strongSelf.tableView.reloadData()
                    })
                }
            })
        case .group:
            
            self.messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).set(categories: messageCategories).set(types: messageTypes).hideReplies(hide: true).hideDeletedMessages(hide: hideDeletedMessages).set(unread: onlyUnreadMessages).hideMessagesFromBlockedUsers(hideMessagesFromBlockedUsers).setTags(tags).set(limit: limit).build()
            
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
                    
                    if let currentGroup = strongSelf.currentGroup , let textMessage = lastMessage as? TextMessage {
                        strongSelf.smartReplies.set(message: textMessage)
                            .set(group: currentGroup)
                    }else{
                        strongSelf.smartReplies.isHidden = true
                    }
                    strongSelf.tableView?.reloadData()
                    strongSelf.scrollToBottom()
                }
            }, onError: { (error) in
                if let error = error , !self.hideError {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    if self.errorStateText.isEmpty {
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                    }else{
                        confirmDialog.set(messageText: self.errorStateText)
                    }
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                        // Referesh list
                        strongSelf.tableView.reloadData()
                    })
                }
            })
            @unknown default: break }
    }
    
    @discardableResult
    @objc public func update(message: BaseMessage) -> CometChatMessageList {
        
        if let indexpath = self.chatMessages.indexPath(where: { (!$0.muid.isEmpty && $0.muid == message.muid) || ($0.id == message.id)}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.beginUpdates()
                strongSelf.chatMessages[section][row] = message
                strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                strongSelf.tableView?.endUpdates()
            }
        }
        return self
    }
    
    @discardableResult
    @objc public func delete(message: BaseMessage) -> CometChatMessageList {
        CometChat.delete(messageId: message.id) { deletedMessage in
            
            print(type(of: deletedMessage))
            
            if let baseMessage = (deletedMessage as? ActionMessage)?.actionOn as? BaseMessage {
                DispatchQueue.main.async {
                    CometChatMessageEvents.emitOnMessageDelete(message: baseMessage, status: .success)
                }
            }
        } onError: { error in
            DispatchQueue.main.async {
                CometChatMessageEvents.emitOnError(message: message, error: error)
            }
        }
        return self
    }
    
    @discardableResult
    @objc public func remove(message: BaseMessage) -> CometChatMessageList {
        
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if let indexpath = strongSelf.chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int {
                strongSelf.tableView.beginUpdates()
                strongSelf.chatMessages[section].remove(at: row)
                strongSelf.tableView?.deleteRows(at: [indexpath], with: .automatic)
                strongSelf.tableView.endUpdates()
            }
        }
        return self
    }
    
    
    
    @discardableResult
    @objc public func add(message: BaseMessage)  -> CometChatMessageList {
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
                        if strongSelf.scrollToBottomOnNewMessage {
                            strongSelf.tableView?.scrollToBottomRow()
                        }
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
                        if strongSelf.scrollToBottomOnNewMessage {
                            strongSelf.tableView?.scrollToBottomRow()
                        }
                    }
                }
            }
        @unknown default: break
        }
        return self
    }
    
    public func startLiveReaction(image: UIImage) {
        if self.isAnimating == false {
            self.reactionView.image1 = image
            self.reactionView.isHidden = false
            
            self.isAnimating = true
            
            Timer.scheduledTimer(withTimeInterval: 0.15, repeats: true) { timer in
                self.reactionView.sendReaction()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    timer.invalidate()
                    self.reactionView.stopReaction()
                })
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                self.isAnimating = false
            })
            
            if !self.reactionView.isAnimating {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0, execute: {
                    self.reactionView.isHidden = true
                })
            }
        }
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
        
        let loadedNib = Bundle.module.loadNibNamed(String(describing: type(of: self)), owner: self, options: nil)
        if let contentView = loadedNib?.first as? UIView  {
            contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            contentView.frame = bounds
            addSubview(contentView)
        }
        setupTableView()
        registerCells()
        
        
        print("user: \(currentUser)")
        
        registerObervers()
    }
    
    fileprivate func configureMessageList() {
        
        if let configurations = configurations {
            if let messageListConfiguration = configurations.filter({ $0 is MessageListConfiguration}).last as? MessageListConfiguration {
                
                set(limit: messageListConfiguration.limit)
                show(onlyUnreadMessages: messageListConfiguration.onlyUnreadMessages)
                hide(messagesFromBlockedUsers: messageListConfiguration.hideMessagesFromBlockedUsers)
                hide(threadedReplies: messageListConfiguration.hideThreadReplies)
                hide(deletedMessages: messageListConfiguration.hideDeletedMessages)
                hide(error: messageListConfiguration.hideError)
                set(tags: messageListConfiguration.tags ?? [])
                set(messageTypes: messageListConfiguration.messageTypes ?? [])
                set(excludeMessageTypes: messageListConfiguration.excludeMessageTypes ?? [])
                set(emptyText: messageListConfiguration.emptyText ?? "")
                set(errorText: messageListConfiguration.errorText ?? "")
                set(emptyView: messageListConfiguration.emptyView)
                scrollToBottomOnNewMessage(bool: messageListConfiguration.scrollToBottomOnNewMessage)
                showEmojiInLargerSize(bool: messageListConfiguration.showEmojiInLargerSize)
                set(messageBubbleConfiguration: messageListConfiguration.messageBubbleConfiguration)
                set(excludedMessageOptions: messageListConfiguration.excludedMessageOptions ?? [])
                enableSoundForMessages(bool: messageListConfiguration.enableSoundForMessages)
                set(messageListAlignment: messageListConfiguration.messageAlignment)
                
            }
        }else{
            set(messageTypes: messagetTypeTemplates)
        }
    }
    
    fileprivate func registerObervers() {
        CometChatEmojiKeyboard.emojiKeyboardDelegate = self
        CometChat.messagedelegate = self
        CometChat.groupdelegate = self
    }
    
    fileprivate func setupTableView() {
        self.set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])

        tableView.separatorStyle = .none
       // tableView.setEmptyMessage("LOADING".localize(), color: emptyStateTextColor, font: emptyStateTextFont)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = .clear
        refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(loadPreviousMessages), for: .valueChanged)
        tableView?.refreshControl = refreshControl
                //self.tableView.conte.set(background: [CometChatTheme.palatte?.background?.cgColor ?? UIColor.systemBackground.cgColor])
    }
    
    fileprivate func registerCells() {
        
        // New Combined Cells
        self.registerCellWith(title: "CometChatMessageBubble")
        self.registerCellWith(title: "CometChatTextAutoSizeBubble")
        self.registerCellWith(title: "CometChatGroupActionBubble")
        
    }
    
    private func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
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
            containerView.backgroundColor = .clear
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
        return chatMessages[safe: section]?.count ?? 0
    }
    
    public  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    public  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let section = indexPath.section as? Int else { return UITableViewCell() }
        guard let message = chatMessages[safe: section]?[safe: indexPath.row] else { print("No message found."); return UITableViewCell() }
        
          if message.messageCategory == .action, let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatGroupActionBubble", for: indexPath) as? CometChatGroupActionBubble {
              /// Action bubble
              cell.set(messageObject: message)
              return cell
          } else if let message = message as? TextMessage, message.deletedAt == 0, let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatTextAutoSizeBubble", for: indexPath) as? CometChatTextAutoSizeBubble {
              /// Text message
              if let configurations = configurations {
                cell.set(configurations: configurations)
                cell.customViews = self.customViews
                cell.set(allMessageOptions: messageOptions)
              }
              if let controller = controller {
                cell.set(controller: controller)
              }
              cell.set(messageAlignment: messageListAlignment)
              print("messageOptions: \(messageOptions)")
              cell.set(messageObject: message)
              return cell
            }  else if let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatMessageBubble", for: indexPath) as? CometChatMessageBubble {
                /// Messsage bubble.
                if let configurations = configurations {
                  cell.set(configurations: configurations)
                  cell.customViews = self.customViews
                  cell.set(allMessageOptions: messageOptions)
                }
                if let controller = controller {
                  cell.set(controller: controller)
                }
                cell.set(messageAlignment: messageListAlignment)
                print("messageOptions: \(messageOptions)")
                cell.set(messageObject: message)
                return cell
              }
        return UITableViewCell()
      }
}

extension CometChatMessageList: CometChatEmojiKeyboardDelegate {
    func onEmojiClick(emoji: CometChatEmoji, message: BaseMessage?) {
        guard let message = message else { return }

        CometChat.callExtension(slug: ExtensionConstants.reactions, type: .post, endPoint: "v1/react", body: ["msgId":message.id, "emoji":emoji.emoji], onSuccess: { (success) in
            print("Success: \(success)")
        }) { (error) in
            print(error)
        }
    }

}


extension CometChatMessageList: CometChatGroupDelegate {
    
    func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if action.receiverUid == currentGroup?.guid {
            self.add(message: action)
        }
    }
    
    func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if action.receiverUid == currentGroup?.guid {
            self.add(message: action)
        }
    }
    
    func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if action.receiverUid == currentGroup?.guid {
            self.add(message: action)
        }
    }
    
    func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if action.receiverUid == currentGroup?.guid {
            self.add(message: action)
        }
    }
    
    func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if action.receiverUid == currentGroup?.guid {
            self.add(message: action)
        }
    }
    
    func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if action.receiverUid == currentGroup?.guid {
            self.add(message: action)
        }
    }
    
    func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if action.receiverUid == currentGroup?.guid {
            self.add(message: action)
        }
    }
    
}

