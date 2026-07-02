//
//  MessageListViewModel.swift
 
//
//  Created by Pushpsen Airekar on 01/12/22.
//

import Foundation
import CometChatSDK


protocol MessageListViewModelProtocol {
    var user: CometChatSDK.User? { get set }
    var group: CometChatSDK.Group? { get set }
    var parentMessage: CometChatSDK.BaseMessage? { get set }
    var selectedMessages: [CometChatSDK.BaseMessage] { get set }
    var messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder { get set }
    var messages: [(date: Date, messages: [BaseMessage])] { get set }
    var reload: (() -> Void)? { get set }
    var streamingSpeed: Int? { get set }
    var newMessageReceived: ((_ message: BaseMessage) -> Void)? { get set }
    var appendAtIndex: ((_ section: Int, _ row: Int, _ baseMessage: BaseMessage, _ isNewSectionAdded: Bool) -> Void)? { get set }
    var updateAtIndex: ((Int, Int, BaseMessage) -> Void)? { get set }
    var updateReceiptAtIndex: ((Int, Int, BaseMessage) -> Void)? { get set }
    var deleteAtIndex: ((Int, Int, BaseMessage) -> Void)? { get set }
    var failure: ((CometChatSDK.CometChatException) -> Void)? { get set }
    func fetchNextMessages()
    func fetchPreviousMessages(completion: (() -> Void)?)
    func fetchUnreadMessageCount()
}

open class MessageListViewModel: NSObject, MessageListViewModelProtocol {
    
    var scrollToMessageId: ((Int, Bool) -> Void)?

    private var gotoMessageId: Int = 0
    private var gotoMessage: BaseMessage?
    private var hasMorePreviousMessages: Bool = true
    private var hasMoreNewMessages: Bool = true

    
    var threadedPArentMessageId: Int = 0
    var deleteBatch: (([(section: Int, row: Int, msg: BaseMessage)], [Int]) -> Void)?

    var group: CometChatSDK.Group?
    var user: CometChatSDK.User?
    var parentMessage: CometChatSDK.BaseMessage?
    var quotedMessage: CometChatSDK.BaseMessage?
    var messages: [(date: Date, messages: [CometChatSDK.BaseMessage])] = []
    var selectedMessages: [CometChatSDK.BaseMessage] = []
    var messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder
    var messageActionRequestBuilder = MessagesRequest.MessageRequestBuilder().build()
    var messageNextRequestBuilder = MessagesRequest.MessageRequestBuilder().build()
    var messagesRequest: MessagesRequest?
    var messagesNextRequest: MessagesRequest?
    var messagesNextRequestPagination: MessagesRequest?
    private var filterMessagesRequest: MessagesRequest?
    var reload: (() -> Void)?
    var hideBottomSpinner: (() -> Void)?
    var pushTableView: (() -> Void)?
    var onFirstMessageFetch: (() -> Void)?
    var newMessageReceived: ((_ message: BaseMessage) -> Void)?
    var ccMessageSent: ((_ message: BaseMessage, _ status: MessageStatus) -> Void)?
    var appendAtIndex: ((_ section: Int, _ row: Int, _ baseMessage: BaseMessage, _ isNewSectionAdded: Bool) -> Void)?

    var updateAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var updateReceiptAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var updateConversationCount: (() -> Void)?
    var deleteAtIndex: ((Int, Int, BaseMessage) -> Void)?
    var hideHeaderView: ((Bool) -> Void)?
    var hideFooterView: ((Bool) -> Void)?
    var setHeaderView: ((UIView) -> Void)?
    var setFooterView: ((UIView) -> Void)?
    var appendMessagesAtTop: ((Int, Int) -> Void)?
    var failure: ((CometChatSDK.CometChatException) -> Void)?
    var unReadMessageCount: Int?
    private var disableReceipt: Bool = false
    private var disableReaction: Bool = false
    var currentRandomDate = Date().timeIntervalSinceReferenceDate
    var isAllMessagesFetchedInPrevious = false
    var isAllMessagesFetchedInNext = false
    var cellHeight = [IndexPath: CGFloat]()
    
    // In MessageListViewModel
    var isFetchingNext = false

    var isUIUpdating: Bool = false
    var templates = [String: CometChatMessageTemplate]()
    var hideDeletedMessages: Bool = false
    var hasFetchedMessagesBefore = false
    var additionalConfiguration = AdditionalConfiguration()

    var placeholder: StreamMessage?
    var streamPlaceholderRunId: Int?
    var isThinkingHidden = false
    
    var currentConversation: Conversation?
    
    var messageBubbleStyle = CometChatMessageBubble.style {
        didSet {
            additionalConfiguration.messageBubbleStyle = messageBubbleStyle
        }
    }
    var actionBubbleStyle = CometChatMessageBubble.actionBubbleStyle {
        didSet {
            additionalConfiguration.actionBubbleStyle = actionBubbleStyle
        }
    }
    var callActionBubbleStyle = CometChatMessageBubble.callActionBubbleStyle {
        didSet {
            additionalConfiguration.callActionBubbleStyle = callActionBubbleStyle
        }
    }
    
    var textFormatters = ChatConfigurator.getDataSource().getTextFormatters() {
        didSet {
            additionalConfiguration.textFormatter = textFormatters
        }
    }
    
    public var hideReplyInThreadOption: Bool = false{
        didSet{
            additionalConfiguration.hideReplyInThreadOption = hideReplyInThreadOption
        }
    }
    public var hideFlagMessageOption: Bool = false{
        didSet{
            additionalConfiguration.hideFlagMessageOption = hideFlagMessageOption
        }
    }
    public var hideTranslateMessageOption: Bool = false{
        didSet{
            additionalConfiguration.hideTranslateMessageOption = hideTranslateMessageOption
        }
    }
    public var hideEditMessageOption: Bool = false{
        didSet{
            additionalConfiguration.hideEditMessageOption = hideEditMessageOption
        }
    }
    public var hideDeleteMessageOption: Bool = false{
        didSet{
            additionalConfiguration.hideDeleteMessageOption = hideDeleteMessageOption
        }
    }
    public var hideReactionOption: Bool = false{
        didSet{
            additionalConfiguration.hideReactionOption = hideReactionOption
        }
    }
    public var hideMessagePrivatelyOption: Bool = false{
        didSet{
            additionalConfiguration.hideMessagePrivatelyOption = hideMessagePrivatelyOption
        }
    }
    public var hideCopyMessageOption: Bool = false{
        didSet{
            additionalConfiguration.hideCopyMessageOption = hideCopyMessageOption
        }
    }
    public var hideReplyMessageOption: Bool = false{
        didSet{
            additionalConfiguration.hideReplyMessageOption = hideReplyMessageOption
        }
    }
    public var disableSwipeToReply: Bool = false
    
    public var hideMessageInfoOption: Bool = false{
        didSet{
            additionalConfiguration.hideMessageInfoOption = hideMessageInfoOption
        }
    }
    public var hideShareMessageOption: Bool = false{
        didSet{
            additionalConfiguration.hideShareMessageOption = hideShareMessageOption
        }
    }
    
    /// Sets streaming delay in milliseconds (e.g. 100 = smooth, 200 = slow)
    public var streamingSpeed: Int? {
        didSet { setupStreamingSpeedIfNeeded() }
    }
    
    private var pendingAIMessages: [Int: AIAssistantMessage] = [:]
    
    public var showMarkAsUnreadOption: Bool = true{
        didSet{
            additionalConfiguration.showMarkAsUnreadOption = showMarkAsUnreadOption
        }
    }
    
    
    public override init() {
        messagesRequestBuilder = MessagesRequest.MessageRequestBuilder()
        isUIUpdating = true
        messages = []
        super.init()
        setUpDefaultTemplate()
        
        // Clean up stream state for agentic users when needed
        if let user = user, user.isAgentic && parentMessage?.id == 0 {
            isUIUpdating = false
            messages.removeAll()
            CometChatAIStreamService.shared.isAIBusy = false // cleanup: not busy
            CometChatAIStreamService.shared.cleanupAll()     // cleanup: all stream state
            return
        }
    }
    
    func set(group: Group, messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder?, parentMessage: BaseMessage? = nil) {
        self.group = group
        self.parentMessage = parentMessage
        self.messagesRequestBuilder = messagesRequestBuilder?.set(guid: group.guid).setParentMessageId(parentMessageId: parentMessage?.id ?? 0) ?? MessagesRequest.MessageRequestBuilder()
            .set(guid: group.guid)
            .hideReplies(hide: true)
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
            .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])
        self.messagesRequest = self.messagesRequestBuilder.build()
        self.fetchUnreadMessageCount()
    }
        
    func set(user: User, messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder?, parentMessage: BaseMessage? = nil, withParent: Bool = false) {
        self.user = user
        self.parentMessage = parentMessage
        var builder = messagesRequestBuilder?
            .set(uid: user.uid ?? "")
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
            .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])
        ?? MessagesRequest.MessageRequestBuilder()
            .set(uid: user.uid ?? "")
            .hideReplies(hide: true)
            .setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
            .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])

        if withParent {
            builder = builder.set(withParent: true)
        }
        self.messagesRequestBuilder = builder
        self.messagesRequest = self.messagesRequestBuilder.build()
        self.fetchUnreadMessageCount()
    }
    
    func set(messagesRequestBuilder: CometChatSDK.MessagesRequest.MessageRequestBuilder) {
        if let user = user {
            self.messagesRequestBuilder = messagesRequestBuilder.set(uid: user.uid ?? "").setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            self.messagesRequest = self.messagesRequestBuilder.build()
        } else if let group = group {
            self.messagesRequestBuilder = messagesRequestBuilder.set(guid: group.guid).setParentMessageId(parentMessageId: parentMessage?.id ?? 0)
            self.messagesRequest = self.messagesRequestBuilder.build()
        }
    }
    
    func isMessageAlreadyLoaded(_ id: Int) -> Bool {
        return messages
            .flatMap { $0.messages }
            .contains(where: { $0.id == id })
    }
    
    // MARK: - Mark as unread flow
    
    func getConversation(conversationWith: String, conversationType: CometChat.ConversationType, completion: @escaping(Conversation?) -> ()) {
        CometChat.getConversation(
            conversationWith: conversationWith,
            conversationType: conversationType,
            onSuccess: { [weak self] conversation in
                guard let this = self else { return }
                this.currentConversation = conversation
                completion(conversation)
            },
            onError: { error in
                print("Error fetching conversation: \(error?.errorDescription ?? "")")
                completion(nil)
            }
        )
    }
    
    func markConversationAsRead(_ conversationWith: String, _ conversationType: CometChat.ReceiverType) {
        CometChat.markConversationAsRead(
            conversationWithId: conversationWith,
            receiverType: conversationType
        ) { message in
            print(message)
            if let currentConversation = self.currentConversation {
                currentConversation.unreadMessageCount = 0
                currentConversation.lastReadMessageId = 0
                CometChatConversationEvents.ccUpdateConversation(conversation: currentConversation)
            }
        } onError: { error in
            print("Error marking conversation as read: \(error.errorDescription)")
        }
    }
    
    func markMessageAsUnread(_ message: BaseMessage, completion: @escaping(Conversation) -> (), failure: @escaping() -> ()) {
        CometChat.markMessageAsUnread(baseMessage: message) { conversation in
            CometChatConversationEvents.ccUpdateConversation(conversation: conversation)
            completion(conversation)
        } onError: { error in
            print(error?.errorDescription ?? "")
            failure()
        }
    }
    
    // MARK: - Load Last Agent Conversation

    /// Attempts to load the most recent agent conversation thread for the current
    /// AI agent user.
    ///
    /// Agent chats are modelled as threads: the first user message of a session becomes
    /// the thread parent and every later turn is a reply to it. To find the latest
    /// session we fetch the top-level (session-starter) messages with `hideReplies: true`,
    /// pick the most recent one, and then reconfigure the request builder to load that
    /// thread (`parentMessageId`, `hideReplies: false`, `withParent: true`).
    ///
    /// - Parameter didLoad: Invoked with `(true, parentMessageId)` when a previous
    ///   conversation was found and the view model has been configured to load it.
    ///   Invoked with `(false, 0)` when the user is not an agent, no previous
    ///   conversation exists, or the fetch fails — the caller should then fall back to
    ///   starting a new agent chat.
    /// Retained reference for the last-agent-conversation request to prevent premature deallocation.
    private var lastAgentConversationRequest: MessagesRequest?
    
    func loadLastAgentConversation(didLoad: @escaping (Bool, Int) -> Void) {
        guard let user = user, user.isAgentic, let uid = user.uid else {
            print("[AIAgent] VM.loadLastAgentConversation skipped - user is not an agent (user=\(String(describing: self.user)), isAgentic=\(self.user?.isAgentic ?? false))")
            didLoad(false, 0)
            return
        }

        print("[AIAgent] VM.loadLastAgentConversation: fetching parent messages for uid=\(uid)")

        lastAgentConversationRequest = MessagesRequest.MessageRequestBuilder()
            .set(uid: uid)
            .hideReplies(hide: true)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
            .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])
            .set(limit: 30)
            .build()

        lastAgentConversationRequest?.fetchPrevious(onSuccess: { [weak self] fetchedMessages in
            guard let this = self else {
                print("[AIAgent] VM.loadLastAgentConversation: self released during fetchPrevious")
                return
            }
            this.lastAgentConversationRequest = nil

            print("[AIAgent] VM.loadLastAgentConversation: fetched \(fetchedMessages?.count ?? 0) parent candidates")

            // Only true session starters (parentMessageId == 0) qualify as conversations.
            let sessionStarters = (fetchedMessages ?? []).filter { $0.parentMessageId == 0 }

            print("[AIAgent] VM.loadLastAgentConversation: \(sessionStarters.count) session starters after filter; ids=\(sessionStarters.map { $0.id })")

            guard let latest = sessionStarters.max(by: { $0.id < $1.id }) else {
                print("[AIAgent] VM.loadLastAgentConversation - no previous conversation found")
                DispatchQueue.main.async { didLoad(false, 0) }
                return
            }

            print("[AIAgent] VM.loadLastAgentConversation: picked latest parent id=\(latest.id), configuring builder with withParent: true")
            this.configureForExistingAgentConversation(parentMessage: latest)
            DispatchQueue.main.async { didLoad(true, latest.id) }
        }, onError: { [weak self] error in
            self?.lastAgentConversationRequest = nil
            print("[AIAgent] VM.loadLastAgentConversation failed: \(error?.errorDescription ?? "unknown error")")
            DispatchQueue.main.async { didLoad(false, 0) }
        })
    }

    /// Reconfigures the view model so the next fetch loads the full thread for an existing
    /// agent conversation.
    ///
    /// `setParentMessageId` alone fetches only the thread *replies* (the AI responses and
    /// later turns) and excludes the root message, which is why the very first user message
    /// would be missing. `set(withParent: true)` includes that parent message in the results.
    ///
    /// We use `set(messageID: -1)` to anchor at the latest messages (bottom of thread) and
    /// paginate backwards, so the user sees the most recent conversation turn first.
    func configureForExistingAgentConversation(parentMessage: BaseMessage) {
        guard let user = user else { return }
        self.parentMessage = parentMessage
        self.threadedPArentMessageId = parentMessage.id
        self.messagesRequestBuilder = MessagesRequest.MessageRequestBuilder()
            .set(uid: user.uid ?? "")
            .setParentMessageId(parentMessageId: parentMessage.id)
            .set(withParent: true)
            .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
            .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])
            .set(messageID: -1)
        self.messagesRequest = self.messagesRequestBuilder.build()
        // Reset pagination flags so the freshly configured thread is fetched cleanly.
        self.isAllMessagesFetchedInPrevious = false
        // We're anchored at the latest message (messageID: -1), so there are no newer
        // messages to paginate forward into.
        self.isAllMessagesFetchedInNext = true
        self.hasFetchedMessagesBefore = false
    }

    // MARK: - Go To Message 

    func goToMessage(messageId: Int) {
        guard messageId != 0 else { return }

        gotoMessageId = messageId

        CometChat.getMessageDetails(messageId) { [weak self] message in
            guard let this = self else { return }
            this.gotoMessage = message
            this.fetchSurroundingMessages(goToMessage: message)
        } onError: { [weak self] error in
            guard let this = self, let error = error else { return }
            this.failure?(error)
        }
    }


    private func fetchSurroundingMessages(goToMessage: BaseMessage) {

        messagesRequest = messagesRequestBuilder.set(messageID: goToMessage.id).build()

        fetchPreviousMessages()
    }


    private func fetchNewerMessages(
        anchorMessage: BaseMessage,
        olderMessages: [BaseMessage],
        anchoredRequest: MessagesRequest
    ) {
        
        MessagesListBuilder.fetchNextMessages(messageRequest: anchoredRequest) { [weak self] result in
            guard let this = self else { return }

            switch result {
            case .success(let newerRaw):

                print(newerRaw.forEach({ message in
                    print(message.id)
                }))
                this.prepareProcessedMessageWindow(
                    olderRaw: olderMessages,
                    goToMessage: anchorMessage,
                    newerRaw: newerRaw
                )

            case .failure(let error):
                this.failure?(error)
            }
        }
    }


    private func prepareProcessedMessageWindow(
        olderRaw: [BaseMessage],
        goToMessage: BaseMessage,
        newerRaw: [BaseMessage]
    ) {
        var fullSnapshot: [BaseMessage] = []
        fullSnapshot.append(contentsOf: olderRaw)
        fullSnapshot.append(goToMessage)
        fullSnapshot.append(contentsOf: newerRaw)
        
        let fullList = filteredNonAIToolMessages(fullSnapshot)

        self.processMessageList(fullList) { [weak self] processedSnapshot in
            guard let this = self else { return }

            // 🚨 IMPORTANT: reset current list for GoTo window
            this.messages.removeAll()
            this.isAllMessagesFetchedInPrevious = false
            this.isAllMessagesFetchedInNext = false

            // group into: [(date, messages[])]
            this.groupMessages(messages: processedSnapshot)

            // After grouping, update pagination anchors
            this.finalizeGoToPaginationState(anchorMessageId: goToMessage.id)
            

            // Scroll to the target message
            if let _ = this.indexPathForMessageId(goToMessage.id) {
                DispatchQueue.main.async {
                    this.scrollToMessageId?(goToMessage.id, false)
                }
            } else {
                print("⚠️ Could not find goToMessage.id in grouped messages")
            }
        }
    }
    
    func indexPathForMessageId(_ id: Int) -> IndexPath? {
        for (sectionIndex, section) in messages.enumerated() {
            if let rowIndex = section.messages.firstIndex(where: { $0.id == id }) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }
    
    private func finalizeGoToPaginationState(anchorMessageId: Int) {

        // 1. Clear GoTo flags
        self.gotoMessageId = 0
        self.gotoMessage = nil

        // 2. Reset pagination COMPLETE state
        self.isAllMessagesFetchedInPrevious = false
        self.isAllMessagesFetchedInNext = false

        // 3. Reset request builders to align with the new window
        if let oldest = messages.last?.messages.last {
            // Oldest = bottom-most
            self.messagesRequestBuilder = self.messagesRequestBuilder
                .set(messageID: oldest.id)

            self.messagesRequest = self.messagesRequestBuilder.build()
        }

        if let newest = messages.first?.messages.first {
            self.messagesNextRequest = self.messagesRequestBuilder
                .set(messageID: newest.id)
                .build()
        }
    }

    
    private func filteredNonAIToolMessages(_ list: [BaseMessage]) -> [BaseMessage] {
        return list.filter {
            let name = String(describing: type(of: $0))
            return !(name.contains("AIToolArgumentMessage") || name.contains("AIToolResultMessage"))
        }
    }
    
    func sendActiveChatChangeEvent() {
        
        onFirstMessageFetch?()
        
        var id = [String:Any]()
        if let user = user {
            id["uid"] = user.uid
        }
        if let group = group {
            id["guid"] = group.guid
        }
        if parentMessage?.id != 0 {
            id["parentMessageId"] = parentMessage?.id
        }
        if let unReadMessageCount = unReadMessageCount{
            id["unReadMessageCount"] = unReadMessageCount
        }
        
        CometChatUIEvents.ccActiveChatChanged(id: id, lastMessage: messages.last?.messages.last, user: user, group: group)
    }

    func fetchNextMessages() {
        guard let messagesRequest = messagesRequest else { return }
        MessagesListBuilder.fetchNextMessages(messageRequest: messagesRequest) { [weak self] result in
            guard let this = self else { return }
            switch result {
            case .success(let fetchedMessages):
                if fetchedMessages.count > 0 {
                    this.processMessageList(fetchedMessages, {fetchedMessages_ in
                        this.groupMessages(messages: fetchedMessages_)
                    })
                }
            case .failure(let error):
                this.failure?(error)
            }
        }
    }
    
    func setUpDefaultTemplate() {
        additionalConfiguration.textFormatter = self.textFormatters
        additionalConfiguration.messageBubbleStyle = messageBubbleStyle
        additionalConfiguration.actionBubbleStyle = actionBubbleStyle
        additionalConfiguration.callActionBubbleStyle = callActionBubbleStyle
        
        let messageTypes =  ChatConfigurator.getDataSource().getAllMessageTemplates(additionalConfiguration: additionalConfiguration)
        messageTypes.forEach { template in
            templates["\(template.category)_\(template.type)"] = template
        }
    }
    
    func fetchPreviousMessages(completion: (() -> Void)? = nil) {
        guard let messagesRequest = messagesRequest else {
            print("[AIAgent] VM.fetchPreviousMessages: messagesRequest is nil — bailing")
            return
        }
        if isAllMessagesFetchedInPrevious == true {
            print("[AIAgent] VM.fetchPreviousMessages: isAllMessagesFetchedInPrevious=true — bailing")
            return
        }
        isUIUpdating = true
        hasFetchedMessagesBefore = true
        print("[AIAgent] VM.fetchPreviousMessages: starting fetchPrevious; parentMessage.id=\(parentMessage?.id ?? -1), threadedPArentMessageId=\(threadedPArentMessageId)")
        MessagesListBuilder.fetchPreviousMessages(messageRequest: messagesRequest) { [weak self] result in
            guard let this = self else { return }
            this.isUIUpdating = false
            switch result {
            case .success(let fetchedMessages):
                print("[AIAgent] VM.fetchPreviousMessages success: \(fetchedMessages.count) messages")
                
                if let gotoMessage = this.gotoMessage{
                    if fetchedMessages.isEmpty {
                        this.isAllMessagesFetchedInPrevious = true
                    }

                    this.messagesNextRequest = this.messagesRequestBuilder.set(messageID: this.gotoMessage?.id ?? 0).build()
                    this.fetchNewerMessages(
                        anchorMessage: gotoMessage,
                        olderMessages: fetchedMessages,
                        anchoredRequest: this.messagesNextRequest!
                    )
                    return
                }
                
                let fetchedMessages = fetchedMessages.filter { message in
                    let messageType = String(describing: type(of: message))
                    return !(messageType.contains("AIToolArgumentMessage") || messageType.contains("AIToolResultMessage"))
                }

                // Drop messages that are already loaded on screen. Pagination pages are normally
                // disjoint, but loading a previous agent conversation uses `set(withParent: true)`,
                // which makes the SDK re-include the thread parent (the first message) on every
                // page. Without this guard, scrolling up then back would re-append that first message.
                let dedupedMessages = fetchedMessages.filter { !this.isMessageAlreadyLoaded($0.id) }
                print("[AIAgent] VM.fetchPreviousMessages: deduped \(dedupedMessages.count) messages (before dedup: \(fetchedMessages.count))")

                if dedupedMessages.isEmpty {
                    print("[AIAgent] VM.fetchPreviousMessages: dedupedMessages empty → marking all fetched, calling appendMessagesAtTop")
                    this.isAllMessagesFetchedInPrevious = true
                    this.appendMessagesAtTop?(0, 0)
                }
                this.processMessageList(dedupedMessages, {fetchedMessages_ in
                    print("[AIAgent] VM.fetchPreviousMessages: processMessageList → groupMessages with \(fetchedMessages_.count)")
                    this.groupMessages(messages: fetchedMessages_)
                })
                self?.sendActiveChatChangeEvent()
                completion?()
            case .failure(let error):
                print("[AIAgent] VM.fetchPreviousMessages failure: \(error.errorDescription)")
                this.failure?(error)
                completion?()
            }
        }
    }
    
    func fetchMissedMessages() {
        if let id = messages.first?.messages.first?.id {
            if let user = self.user, let _ = user.uid {
                messageNextRequestBuilder = messagesRequestBuilder.set(messageID: id).build()
            } else if let _ = self.group {
                messageNextRequestBuilder = messagesRequestBuilder.set(messageID: id).build()
            }
            fetchNextMessagesFromLastMessage()
        }
    }
    
    func fetchUnreadMessageCount() {
        if let uid = user?.uid {
            CometChat.getUnreadMessageCountForUser(uid) { [weak self] countDic in
                guard let this = self else { return }
                this.unReadMessageCount = countDic[uid] as? Int
            } onError: { [weak self] error in
                guard let this = self, let error = error else { return }
                this.failure?(error)
            }
            return
        }
        
        if let guid = group?.guid {
            CometChat.getUnreadMessageCountForGroup(guid) { [weak self] countDic in
                guard let this = self else { return }
                this.unReadMessageCount = countDic[guid] as? Int
            } onError: { [weak self] error in
                guard let this = self, let error = error else { return }
                this.failure?(error)
            }
            return
        }
    }
    
    var captureAnchorMessageId: (() -> Int?)?
    var restoreAnchor: ((Int) -> Void)?

    
    // Callbacks the VC will assign
    /// Called by VM to get VC's current metrics before starting fetch.
    /// Must return (oldOffsetY, oldContentHeight)
    var captureScrollMetrics: (() -> (oldOffsetY: CGFloat, oldContentHeight: CGFloat))?

    /// Called by VM to tell VC that fetch finished and VM updated its messages.
    /// VM passes the previously captured metrics back to VC for restoration.
    var didCompleteFetchNextWithMetrics: ((_ oldOffsetY: CGFloat, _ oldContentHeight: CGFloat) -> Void)?

    // OPTIONAL: called just before starting the network fetch (VC can show spinner / disable)
    var willStartFetchNext: (() -> Void)?

    // Modify fetchNextMessagesForPagination to use the above:
    func fetchNextMessagesForPagination(completion: ((Int) -> ())? = nil) {
        if isAllMessagesFetchedInNext {
            print("[AIAgent] fetchNextMessagesForPagination: BLOCKED by isAllMessagesFetchedInNext=true")
            return
        }
        if isFetchingNext { return }
        
        isFetchingNext = true
        print("[AIAgent] fetchNextMessagesForPagination: STARTING (isAllMessagesFetchedInNext was false)")
        
        let anchorMessageId = messages.first?.messages.first
        
        // Build request (existing logic)
        guard let newest = messages.first?.messages.first else {
            isFetchingNext = false
            return
        }
        if let user = user {
            self.messagesNextRequestPagination = self.messagesRequestBuilder
                .set(uid: user.uid ?? "")
                .set(messageID: newest.id)
                .build()
        } else if let group = group {
            self.messagesNextRequestPagination = self.messagesRequestBuilder
                .set(guid: group.guid)
                .set(messageID: newest.id)
                .build()
        }
        guard let request = messagesNextRequestPagination else { return }
        
        let oldMetrics = captureScrollMetrics?() ?? (oldOffsetY: CGFloat(0), oldContentHeight: CGFloat(0))
        
        willStartFetchNext?()
        
        MessagesListBuilder.fetchNextMessages(messageRequest: request) { [weak self] result in
            guard let this = self else { return }
            
            switch result {
            case .success(let fetched):
                if fetched.isEmpty {
                    this.isFetchingNext = false
                    this.isAllMessagesFetchedInNext = true
                    DispatchQueue.main.async {
                        this.hideBottomSpinner?()
                    }
                    return
                }
                
                this.processMessageList(fetched) { processed in
                    this.groupMessages(messages: processed, atBottom: true)
                    
                    DispatchQueue.main.async {
                        this.isFetchingNext = false
                        
                        this.didCompleteFetchNextWithMetrics?(oldMetrics.oldOffsetY, oldMetrics.oldContentHeight)
                        
                        if let id = anchorMessageId {
                            self?.scrollToMessageId?(id.id, true)
                        }
                        completion?(anchorMessageId?.id ?? 0)
                    }
                }
                
            case .failure(let error):
                this.isFetchingNext = false
                DispatchQueue.main.async {
                    this.failure?(error)
                }
            }
        }
    }

    func messageAt(indexPath: IndexPath) -> BaseMessage? {
        guard messages.indices.contains(indexPath.section) else { return nil }
        let sectionMessages = messages[indexPath.section].messages
        guard sectionMessages.indices.contains(indexPath.row) else { return nil }
        return sectionMessages[indexPath.row]
    }

    
    func fetchNextMessagesFromLastMessage() {
            MessagesListBuilder.fetchNextMessages(messageRequest: messageNextRequestBuilder) { [weak self] result in
                guard let this = self else { return }
                switch result {
                case .success(let fetchedMessages):
                    if fetchedMessages.count > 0 {
                        this.processMessageList(fetchedMessages, { fetchedMessages_ in
                            
                            var missedMessagesWithoutActions = [BaseMessage]()
                            for message in fetchedMessages_ {
                                if message as? ActionMessage == nil {
                                    missedMessagesWithoutActions.append(message)
                                }
                            }
                            
                            this.groupMessages(messages: missedMessagesWithoutActions, atBottom: true)
                            if this.messages.first?.messages.first?.id != fetchedMessages.last?.id {
                                this.fetchNextMessagesFromLastMessage()
                            }
                        })
                    } else {
                        DispatchQueue.main.async { [weak self] in
                            self?.sendActiveChatChangeEvent()
                        }
                    }
                case .failure(let error):
                    this.failure?(error)
                }
            }
    }
    
    func updateUserAndGroup() {
        if let user = user {
            CometChat.getUser(UID: user.uid ?? "") { [weak self] user in
                guard let this = self else { return }
                this.user = user
            } onError: { _ in   }
        } else if let group = group {
            CometChat.getGroup(GUID: group.guid) { [weak self] group in
                guard let this = self else { return }
                this.group = group
            } onError: { _ in   }
        }
    }
    
    func fetchActionMessages(_ success: @escaping (Bool) -> ()) {
        if let id = messages.last?.messages.last?.id {
            let messageActionRequest = MessagesRequest.MessageRequestBuilder().set(messageID: id)
                .set(categories: ["action"]).set(types: ["message"])
            if let user = self.user, let uid = user.uid {
                messageActionRequestBuilder = messageActionRequest.set(uid: uid).build()
            } else if let group = self.group {
                messageActionRequestBuilder = messageActionRequest.set(guid: group.guid).build()
            }
            MessagesListBuilder.fetchNextMessages(messageRequest: messageActionRequestBuilder) { [weak self] result in
                guard let this = self else { return }
                switch result {
                case .success(let fetchedMessages):
                    this.groupActionMessages(messages: fetchedMessages, withRefresh: true)
                    success(true)
                case .failure(let error):
                    this.failure?(error)
                    success(true)
                }
            }
        }
    }
    
    private func groupMessages(messages: [BaseMessage], atBottom: Bool = false) {
        
        print("[AIAgent] VM.groupMessages: called with \(messages.count) messages, atBottom=\(atBottom)")
        if let lastMessage = messages.last{
            if lastMessage.deliveredAt == 0.0 {
                self.markAsDelivered(message: lastMessage)
            }
            if lastMessage.readAt == 0.0 {
                self.markAsRead(message: lastMessage)
            }
        }
        
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }

        let _ = groupedMessages.map { (date: Date, messages: [BaseMessage]) in
            var messages = messages
            messages.reverse()
            if let index = self.messages.firstIndex(where: {$0.date == date}) {
                if atBottom == false {
                    self.messages[index].messages.append(contentsOf: messages)
                } else {
                    self.messages[index].messages.insert(contentsOf: messages, at: 0)
                }
            } else {
                self.messages.append((date: date, messages: messages))
            }
        }
        self.messages = self.messages.sorted(by: { $0.date.compare($1.date) == .orderedDescending})
        
        print("[AIAgent] VM.groupMessages: total grouped sections=\(self.messages.count), total messages=\(self.messages.flatMap{$0.messages}.count) → calling reload")
        self.reload?()

    }
        
    private func groupActionMessages(messages: [BaseMessage], withRefresh: Bool) {
        let groupedMessages = Dictionary(grouping: messages) { (element) -> Date in
            let date = Date(timeIntervalSince1970: TimeInterval(element.sentAt))
            return date.reduceToMonthDayYear()
        }
        for baseMessage in messages {
            if let actionMessage = baseMessage as? ActionMessage,
               let actionOnMessage = actionMessage.actionOn as? BaseMessage {
                let _ = groupedMessages.map { (date: Date, messages: [BaseMessage]) in
                    if let index = self.messages.firstIndex(where: {$0.date == date}) {
                        if let index_ = self.messages[index].messages.firstIndex(where: {$0.id == actionOnMessage.id}) {
                            self.messages[index].messages[index_] = actionOnMessage
                        }
                    }
                }
            }
        }
        self.reload?()
    }
    
    private func processMessageList(_ messageList:[BaseMessage], _ messages: @escaping ([BaseMessage]) -> ()) {
        var messagesList = [BaseMessage]()
        for message in messageList {
            if let message_ = message as? InteractiveMessage, message_.messageCategory == .interactive {
                if message_.type == MessageTypeConstants.form {
                    let formMessage = FormMessage.toFormMessage(message_)
                    messagesList.append(formMessage)
                } else if message_.type == MessageTypeConstants.card {
                    let cardMessage = CardMessage.toCardMessage(message_)
                    messagesList.append(cardMessage)
                } else if message_.type == MessageTypeConstants.scheduler {
                    let schedulerMessage = SchedulerMessage.toSchedulerMessage(message_)
                    messagesList.append(schedulerMessage)
                } else {
                    let customMessage = CustomInteractiveMessage.toCustomInteractiveMessage(message_)
                    messagesList.append(customMessage)
                }
                
            } else {
                messagesList.append(message)
            }
        }
        messages(messagesList)
    }
    
    // MARK:- connect message listener
    public func connect() {
        CometChatUIEvents.addListener("message-list-event-listener\(currentRandomDate)", self as CometChatUIEventListener)
        CometChat.addConnectionListener("messages-connection-sdk-listener\(currentRandomDate)", self)
        CometChat.addCallListener("message-list-call-sdk-listner-\(currentRandomDate)", self)
        CometChatCallEvents.addListener("message-list-call-event-listner-\(currentRandomDate)", self)
        CometChatMessageEvents.addListener("event-listener-\(currentRandomDate)", self)
        CometChat.addGroupListener("message-list-groups-sdk-listner-\(currentRandomDate)", self)
        CometChatGroupEvents.addListener("message-list-groups-events-listener-\(currentRandomDate)", self)
        CometChat.addAIAssistantListener("message-list-ai-events-listener-\(currentRandomDate)", self)
    }
    
    // MARK:- disconnect message listener
    public func disconnect() {
        CometChatUIEvents.removeListener("message-list-event-listener\(currentRandomDate)")
        CometChat.removeConnectionListener("messages-connection-sdk-listener\(currentRandomDate)")
        CometChat.removeCallListener("message-list-call-sdk-listner-\(currentRandomDate)")
        CometChatMessageEvents.removeListener("event-listener-\(currentRandomDate)")
        CometChatCallEvents.removeListener("message-list-call-event-listner-\(currentRandomDate)")
        CometChat.removeGroupListener("message-list-groups-sdk-listner-\(currentRandomDate)")
        CometChatGroupEvents.removeListener("message-list-groups-events-listener-\(currentRandomDate)")
        CometChat.removeAIAssistantListener("message-list-ai-events-listener-\(currentRandomDate)")
    }
    
    func checkThreadedMessageBelongsToThisConversation(message: BaseMessage) -> Bool {
        if (parentMessage == nil && message.parentMessageId == 0) {
            return true
        }
        if parentMessage?.id == message.parentMessageId || quotedMessage?.id == message.parentMessageId {
            return true
        }
        if threadedPArentMessageId == message.parentMessageId && user?.isAgentic == true {
            return true
        }
        return false
    }
    
    func ifThreadedMessageUpdateCount(message: BaseMessage) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            if message.parentMessageId > 0 && this.parentMessage == nil {
                for (sectionIndex, messageData) in this.messages.enumerated() {
                    let (date, messages) = messageData
                    for (rowIndex, baseMessage) in messages.enumerated() {
                        if baseMessage.id == message.parentMessageId {
                            baseMessage.replyCount = (baseMessage.replyCount + 1)
                            this.updateAtIndex?(sectionIndex, rowIndex, baseMessage)
                            if !LoggedInUserInformation.isLoggedInUser(uid: message.sender?.uid ?? ""){
                                this.updateConversationCount?()
                            }
                            return
                        }
                    }
                }
            }
        }
    }
    
    func isReactionOfThisList(receipt: ReactionEvent) -> Bool {
        if let parentMessage = parentMessage, receipt.parentMessageId != 0 {
            if (receipt.parentMessageId == parentMessage.id) {
                return true
            } else {
                return false
            }
        } else {
            if let user = user {
                if (receipt.receiverType == CometChat.ReceiverType.user && (receipt.receiverId == user.uid || receipt.reaction?.reactedBy?.uid == user.uid)) {
                    return true
                }
            } else if let group = group {
                if (receipt.receiverType == CometChat.ReceiverType.group && (receipt.receiverId == group.guid)) {
                    return true
                }
            }
        }
        return false
    }
    
    func updateReaction(reactionEvent: ReactionEvent, updateType: CometChat.ReactionAction) {
        guard let reaction = reactionEvent.reaction else { return }
        if isReactionOfThisList(receipt: reactionEvent) {
            for (index, (_, message)) in messages.enumerated() {
                if let messageIndex = message.firstIndex(where: { $0.id == reaction.messageId }) {
                    let reactedMessage = message[messageIndex]
                    let updatedMessage = CometChat.updateMessageWithReactionInfo(baseMessage: reactedMessage, messageReaction: reaction, action: updateType)
                    self.messages[index].messages[messageIndex] = updatedMessage
                    self.updateAtIndex?(index, messageIndex, updatedMessage)
                    return
                }
            }
        }
    }
    
    func getTemplate(for message: BaseMessage) -> CometChatMessageTemplate? {
        return templates["\(MessageUtils.getDefaultMessageCategories(message: message))_\(MessageUtils.getDefaultMessageTypes(message: message))"]
    }
    
    func isMessageForThisUser(message: BaseMessage) -> Bool {
        switch message.receiverType {
        case .user:
            if (CometChat.getLoggedInUser()?.uid == message.sender?.uid && message.receiverUid == self.user?.uid)  || (CometChat.getLoggedInUser()?.uid != message.sender?.uid && message.sender?.uid == self.user?.uid) {
                return true
            } else {
                return false
            }
        case .group:
            if message.receiverUid == self.group?.guid {
                return true
            } else {
                return false
            }
        @unknown default:
            return false
        }
    }
}

extension MessageListViewModel {
    
    @discardableResult
    public func add(message: BaseMessage) -> Self {
        
        if parentMessage != nil, message.messageCategory == .action {
            return self
        }
        
        guard let loggedInUser = CometChat.getLoggedInUser() else { return self }
        if getTemplate(for: message) == nil { return self } ///Checking if template exists
        
        if isMessageForThisUser(message: message){
            markAsRead(message: message)
            markAsDelivered(message: message)
            if !LoggedInUserInformation.isLoggedInUser(uid: message.sender?.uid ?? ""){
                updateConversationCount?()
            }
        }
        
        
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            if (message.receiverType == .user) && ((CometChat.getLoggedInUser()?.uid == message.sender?.uid && message.receiverUid == this.user?.uid)  || (CometChat.getLoggedInUser()?.uid != message.sender?.uid && message.sender?.uid == this.user?.uid))
                ||
               (message.receiverType == .group) && message.receiverUid == this.group?.guid {
                
                if let lastMessage = this.messages.first?.messages.last, String().compareDates(newTimeInterval: Double(message.muid) ?? 0.0, currentTimeInterval: Double(lastMessage.muid) ?? 0.0)  || Calendar.current.isDateInToday(Date(timeIntervalSince1970: TimeInterval(lastMessage.sentAt))) {
                    this.messages[0].messages.insert(message, at: 0)
                    this.appendAtIndex?(0, 0, message, false)
                } else {
                    this.messages.insert((date: Date(timeIntervalSince1970: TimeInterval( Double(message.muid) ?? 0.0)), messages: [message]), at: 0)
                    this.appendAtIndex?(0, 0, message, true)
                }
                
            }
        }
        return self
    }
    
    @discardableResult
    public func update(message: BaseMessage) -> Self {
        processMessageList([message]) { [weak self] messages in
            guard let this = self else { return }
            guard var newMessage = messages.first else { return }

            if let section = this.messages.firstIndex(where: { (date: Date, messages: [BaseMessage]) in
                if let muid = Double(newMessage.muid), muid != 0.0 {
                    if date.timeIntervalSince1970 == 0.0 {
                        return true
                    } else {
                        return String().compareDates(newTimeInterval: muid,
                                                     currentTimeInterval: date.timeIntervalSince1970)
                    }
                   
                } else {
                    return String().compareDates(newTimeInterval: Double(newMessage.sentAt),
                                                 currentTimeInterval: date.timeIntervalSince1970)
                }
            }),
            let row = this.messages[section].messages.firstIndex(where: {
                if newMessage.muid != "" {
                    return $0.muid == newMessage.muid
                } else {
                    return $0.id == newMessage.id
                }
            }) {

                let oldMessage = this.messages[section].messages[row]

                if newMessage.quotedMessage == nil, let oldQuoted = oldMessage.quotedMessage {
                    newMessage.quotedMessage = oldQuoted
                }

                this.messages[section].messages[row] = newMessage

                this.updateAtIndex?(section, row, newMessage)
            }
        }
        return self
    }
    
    @discardableResult
    public func update(receipt: MessageReceipt) -> Self {
        if !disableReceipt {
            let loggedInUid = CometChat.getLoggedInUser()?.uid
            
            //Checking For User
            if receipt.receiverType == .user && receipt.sender?.uid == self.user?.uid {
                for (section, currentMessages) in messages.enumerated() {
                    for (row, message) in currentMessages.messages.enumerated() {
                        if message.senderUid == loggedInUid {
                            // Check if this receipt applies to this message
                            let isMatchingMessage = String(message.id) == receipt.messageId || message.id <= Int(receipt.messageId) ?? 0
                            
                            if receipt.receiptType == .read && message.readAt == 0.0 && isMatchingMessage {
                                DispatchQueue.main.async { [weak self] in
                                    guard let this = self else { return }
                                    // Update receipt value on main thread to avoid race conditions
                                    message.readAt = Double(receipt.timeStamp)
                                    this.messages[section].messages[row] = message
                                    // Use updateReceiptAtIndex if available, fallback to updateAtIndex for backward compatibility
                                    if let receiptUpdate = this.updateReceiptAtIndex {
                                        receiptUpdate(section, row, message)
                                    } else {
                                        this.updateAtIndex?(section, row, message)
                                    }
                                }
                            } else if receipt.receiptType == .delivered && message.deliveredAt == 0.0 && isMatchingMessage {
                                DispatchQueue.main.async { [weak self] in
                                    guard let this = self else { return }
                                    // Update receipt value on main thread to avoid race conditions
                                    message.deliveredAt = Double(receipt.timeStamp)
                                    this.messages[section].messages[row] = message
                                    // Use updateReceiptAtIndex if available, fallback to updateAtIndex for backward compatibility
                                    if let receiptUpdate = this.updateReceiptAtIndex {
                                        receiptUpdate(section, row, message)
                                    } else {
                                        this.updateAtIndex?(section, row, message)
                                    }
                                }
                            } else if String(message.id) == receipt.messageId {
                                // Ensure receipt values are up to date even if already set
                                DispatchQueue.main.async { [weak self] in
                                    guard let this = self else { return }
                                    // Update receipt values if the incoming receipt has newer data
                                    if receipt.receiptType == .read && message.readAt == 0.0 {
                                        message.readAt = Double(receipt.timeStamp)
                                    } else if receipt.receiptType == .delivered && message.deliveredAt == 0.0 {
                                        message.deliveredAt = Double(receipt.timeStamp)
                                    }
                                    this.messages[section].messages[row] = message
                                    // Use updateReceiptAtIndex if available, fallback to updateAtIndex for backward compatibility
                                    if let receiptUpdate = this.updateReceiptAtIndex {
                                        receiptUpdate(section, row, message)
                                    } else {
                                        this.updateAtIndex?(section, row, message)
                                    }
                                }
                            }
                        }
                    }
                }
            } else if receipt.receiverType == .group && receipt.receiverId == group?.guid {
                
                //Checking For Group
                for (section, currentMessages) in messages.enumerated() {
                    for (row, message) in currentMessages.messages.enumerated() {
                        
                        if receipt.receiptType == .readByAll && message.readAt == 0.0 {
                            DispatchQueue.main.async { [weak self] in
                                guard let this = self else { return }
                                // Update receipt value on main thread to avoid race conditions
                                message.readAt = Double(receipt.timeStamp)
                                this.messages[section].messages[row] = message
                                // Use updateReceiptAtIndex if available, fallback to updateAtIndex for backward compatibility
                                if let receiptUpdate = this.updateReceiptAtIndex {
                                    receiptUpdate(section, row, message)
                                } else {
                                    this.updateAtIndex?(section, row, message)
                                }
                            }
                        } else if receipt.receiptType == .deliveredToAll && message.deliveredAt == 0.0 {
                            DispatchQueue.main.async { [weak self] in
                                guard let this = self else { return }
                                // Update receipt value on main thread to avoid race conditions
                                message.deliveredAt = Double(receipt.timeStamp)
                                this.messages[section].messages[row] = message
                                // Use updateReceiptAtIndex if available, fallback to updateAtIndex for backward compatibility
                                if let receiptUpdate = this.updateReceiptAtIndex {
                                    receiptUpdate(section, row, message)
                                } else {
                                    this.updateAtIndex?(section, row, message)
                                }
                            }
                        } else if String(message.id) == receipt.messageId {
                            // Ensure receipt values are up to date even if already set
                            DispatchQueue.main.async { [weak self] in
                                guard let this = self else { return }
                                // Update receipt values if the incoming receipt has newer data
                                if receipt.receiptType == .readByAll && message.readAt == 0.0 {
                                    message.readAt = Double(receipt.timeStamp)
                                } else if receipt.receiptType == .deliveredToAll && message.deliveredAt == 0.0 {
                                    message.deliveredAt = Double(receipt.timeStamp)
                                }
                                this.messages[section].messages[row] = message
                                // Use updateReceiptAtIndex if available, fallback to updateAtIndex for backward compatibility
                                if let receiptUpdate = this.updateReceiptAtIndex {
                                    receiptUpdate(section, row, message)
                                } else {
                                    this.updateAtIndex?(section, row, message)
                                }
                            }
                        }
                        
                    }
                }
            }
        }
        return self
    }
    
    func getIndexPath(for message: BaseMessage) -> IndexPath? {
        if let section = messages.firstIndex(where: { (date: Date, messages: [BaseMessage]) in
            if let muid = Double(message.muid), muid != 0.0 {
                if date.timeIntervalSince1970 == 0.0 {
                    return true
                } else {
                    return String().compareDates(newTimeInterval:  muid, currentTimeInterval:  date.timeIntervalSince1970) ? true : false
                }
                
            } else {
                return String().compareDates(newTimeInterval: Double(message.sentAt), currentTimeInterval: date.timeIntervalSince1970) ? true : false
            }
        }), let row = messages[section].messages.firstIndex(where: {
            if message.muid != "" {
                return $0.muid == message.muid
                
            } else {
                return $0.id == message.id
            }
        }) {
            return IndexPath(row: row, section: section)
        }
        return nil
    }

    
    
    @discardableResult
    public func remove(message: BaseMessage) -> Self {
        if let section = messages.firstIndex(where: { (date: Date, messages: [BaseMessage]) in
            return String().compareDates(newTimeInterval: date.timeIntervalSince1970, currentTimeInterval: Double(message.sentAt)) ? true : false
        }), let row = messages[section].messages.firstIndex(where: { $0.id == message.id || $0.muid == message.muid}) {
            messages[section].messages.remove(at: row)
            self.deleteAtIndex?(section, row, message)
        }
        return self
    }
    
    @discardableResult
    public func delete(message: BaseMessage) -> Self {
        CometChat.deleteMessage(message.id) { message in
            CometChatMessageEvents.onMessageDeleted(message: message)
        } onError: { [weak self] error in
            guard let this = self else { return }
            this.failure?(error)
        }
        return self
    }
    
    @discardableResult
    public func copy(message: BaseMessage) -> Self {
        if let message = message as? TextMessage {
            UIPasteboard.general.string = message.text
        }
        return self
    }
    
    @discardableResult
    public func clearList() -> Self {
        self.messages.removeAll()
        return self
    }
    
    @discardableResult
    public func markAsRead(message: BaseMessage) -> Self {
        if !disableReceipt && message.readAt == 0 {
            if (
                (message.receiverType == .group && message.receiverUid == group?.guid && (message.sender?.uid != CometChat.getLoggedInUser()?.uid)) ||
                (message.receiverType == .user && (message.sender?.uid != CometChat.getLoggedInUser()?.uid))
            ) {
                CometChat.markAsRead(baseMessage: message)
                message.readAt = Double(NSDate().timeIntervalSince1970)
                CometChatMessageEvents.ccMessageRead(message: message)
            }
        }
        return self
    }
    
    @discardableResult
    public func markAsDelivered(message: BaseMessage) -> Self {
        if !disableReceipt && message.deliveredAt == 0 {
            CometChat.markAsDelivered(baseMessage: message)
        }
        return self
    }
    
    @discardableResult
    public func disable(receipt: Bool) -> Self {
        self.disableReceipt = receipt
        return self
    }
    
    @discardableResult
    public func disable(reactions: Bool) -> Self {
        self.disableReaction = reactions
        return self
    }
}

extension MessageListViewModel: CometChatMessageEventListener {
    
    public func onFormMessageReceived(message: FormMessage) {
        
        if self.getTemplate(for: message) == nil { return }
        ifThreadedMessageUpdateCount(message: message)
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.newMessageReceived?(message)
            self.add(message: message)
        }
    }
    
    public func onSchedulerMessageReceived(message: SchedulerMessage) {
        
        if self.getTemplate(for: message) == nil { return }
        ifThreadedMessageUpdateCount(message: message)
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.newMessageReceived?(message)
            self.add(message: message)
        }
    }
    
    public func onCustomInteractiveMessageReceived(message: CustomInteractiveMessage) {
        
        if self.getTemplate(for: message) == nil { return }
        ifThreadedMessageUpdateCount(message: message)
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.newMessageReceived?(message)
            self.add(message: message)
        }
    }
    
    public func onCardMessageReceived(message: CardMessage) {
        
        if self.getTemplate(for: message) == nil { return }
        ifThreadedMessageUpdateCount(message: message)
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.newMessageReceived?(message)
            self.add(message: message)
        }
    }
    
    public func onNewCardMessageReceived(cardMessage: BaseMessage) {
        
        if self.getTemplate(for: cardMessage) == nil { return }
        ifThreadedMessageUpdateCount(message: cardMessage)
        if checkThreadedMessageBelongsToThisConversation(message: cardMessage) {
            self.newMessageReceived?(cardMessage)
            self.add(message: cardMessage)
        }
    }
    
    
    public func onTextMessageReceived(textMessage: TextMessage) {
        
        if self.getTemplate(for: textMessage) == nil { return }
        ifThreadedMessageUpdateCount(message: textMessage)
        if checkThreadedMessageBelongsToThisConversation(message: textMessage) {
            self.newMessageReceived?(textMessage)
            self.add(message: textMessage)
        }
    }
    
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        
        if self.getTemplate(for: mediaMessage) == nil { return }
        ifThreadedMessageUpdateCount(message: mediaMessage)
        if checkThreadedMessageBelongsToThisConversation(message: mediaMessage) {
            self.newMessageReceived?(mediaMessage)
            self.add(message: mediaMessage)
        }
    }
    
    public func onCustomMessageReceived(customMessage: CustomMessage) {
                
        if self.getTemplate(for: customMessage) == nil { return }
        ifThreadedMessageUpdateCount(message: customMessage)
        if checkThreadedMessageBelongsToThisConversation(message: customMessage) {
            self.newMessageReceived?(customMessage)
            self.add(message: customMessage)
        }
    }
    
    public func onMessagesDelivered(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func onMessagesRead(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func onMessagesReadByAll(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func onMessagesDeliveredToAll(receipt: MessageReceipt) {
        update(receipt: receipt)
    }
    
    public func ccMessageRead(message: CometChatSDK.BaseMessage) {
        self.update(message: message)
    }
    
    public func ccMessageDeleted(message: BaseMessage) {
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            if hideDeletedMessages {
                remove(message: message)
            } else {
                update(message: message)
            }
        }
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            if hideDeletedMessages {
                remove(message: message)
            } else {
                update(message: message)
            }
        }
    }
    
    public func ccReplyToMessage(message: BaseMessage, status: MessageStatus) {
        if status == .inProgress {
            quotedMessage = message
        } else if status == .error || status == .success {
            quotedMessage = nil
        }
    }
    
    public func ccMessageSent(message: CometChatSDK.BaseMessage, status: MessageStatus) {
        ccMessageSent?(message, status)
        
        if status == .success {
            ifThreadedMessageUpdateCount(message: message)
        }
        
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            switch status {
            case .inProgress:
                if user?.isAgentic == true {
                    markFailedStreamBubblesForRemoval()
                }
                add(message: message)
                if user?.isAgentic ?? false, message is TextMessage {
                    CometChatAIStreamService.shared.isAIBusy = true
                }
            case .success, .error:
                if (user?.isAgentic ?? false && threadedPArentMessageId <= 0 && !messages.isEmpty) {
                    threadedPArentMessageId = message.id
                    self.messagesRequestBuilder = messagesRequestBuilder.set(uid: user?.uid ?? "").setParentMessageId(parentMessageId: threadedPArentMessageId)
                    self.messagesRequest = self.messagesRequestBuilder.build()
                }
                if let message = message as? TextMessage, threadedPArentMessageId > 0, user?.isAgentic ?? false, status != .error {
                    startStreaming(runId: message.id, assistant: user!)
                }
            }
            update(message: message)
        }
    }
    
    public func removeMarkedFailedStreamMessages() {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            var deletions: [(section: Int, row: Int, msg: BaseMessage)] = []
            var emptySections: [Int] = []
            
            for section in this.messages.indices.reversed() {
                for row in this.messages[section].messages.indices.reversed() {
                    let msg = this.messages[section].messages[row]
                    if msg.metaData?["__remove_stream_error__"] as? Bool == true {
                        deletions.append((section, row, msg))
                        this.messages[section].messages.remove(at: row)
                    }
                }
                if this.messages[section].messages.isEmpty {
                    emptySections.append(section)
                }
            }
            
            // Remove empty sections from data source
            for section in emptySections.sorted(by: >) {
                if section < this.messages.count {
                    this.messages.remove(at: section)
                }
            }
            
            // Perform table updates cleanly
            this.deleteBatch?(deletions, emptySections)
        }
    }

    
    private func markFailedStreamBubblesForRemoval() {
        for section in messages.indices {
            for row in messages[section].messages.indices {
                if let streamMessage = messages[section].messages[row] as? StreamMessage,
                   streamMessage.metaData?["__stream_error__"] as? Bool == true {
                    messages[section].messages[row].metaData?["__remove_stream_error__"] = true
                }
            }
        }
    }
    
    public func ccMessageEdited(message: BaseMessage, status: MessageStatus) {
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            if status == .success{
                self.update(message: message)
            }
        }
    }
    
    public func onMessageModerated(message: BaseMessage) {
        if MessageUtils.isMessageModerationDisapproved(message: message) {
            for (index, (_, messages)) in messages.enumerated() {
                if let messageIndex = messages.firstIndex(where: { $0.id == message.id }) {
                    self.messages[index].messages[messageIndex] = message
                    self.updateAtIndex?(index, messageIndex, message)
                    return
                }
            }
        }
    }

    
    public func onMessageEdited(message: BaseMessage) {
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            self.update(message: message)
        }
    }

    public func onMessageReactionAdded(reactionEvent: ReactionEvent) {
        if !disableReaction {
            updateReaction(reactionEvent: reactionEvent, updateType: .REACTION_ADDED)
        }
    }
    
    public func onMessageReactionRemoved(reactionEvent: ReactionEvent) {
        if !disableReaction {
            updateReaction(reactionEvent: reactionEvent, updateType: .REACTION_REMOVED)
        }
    }
    
}


extension MessageListViewModel: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: CometChatSDK.ActionMessage, joinedUser: CometChatSDK.User, joinedGroup: CometChatSDK.Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onGroupMemberLeft(action: CometChatSDK.ActionMessage, leftUser: CometChatSDK.User, leftGroup: CometChatSDK.Group) {
        /*
         close detail
         */
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onGroupMemberKicked(action: CometChatSDK.ActionMessage, kickedUser: CometChatSDK.User, kickedBy: CometChatSDK.User, kickedFrom: CometChatSDK.Group) {
        /*
         // append to list.
         */
        self.newMessageReceived?(action)
        self.add(message: action)
        
    }
    
    public func onGroupMemberBanned(action: CometChatSDK.ActionMessage, bannedUser: CometChatSDK.User, bannedBy: CometChatSDK.User, bannedFrom: CometChatSDK.Group) {
        /*
         Append to the list.
         */
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onGroupMemberUnbanned(action: CometChatSDK.ActionMessage, unbannedUser: CometChatSDK.User, unbannedBy: CometChatSDK.User, unbannedFrom: CometChatSDK.Group) {
        /*
         Do Nothing.
         */
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onGroupMemberScopeChanged(action: CometChatSDK.ActionMessage, scopeChangeduser: CometChatSDK.User, scopeChangedBy: CometChatSDK.User, scopeChangedTo: String, scopeChangedFrom: String, group: CometChatSDK.Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func onMemberAddedToGroup(action: CometChatSDK.ActionMessage, addedBy: CometChatSDK.User, addedUser: CometChatSDK.User, addedTo: CometChatSDK.Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
}



extension MessageListViewModel: CometChatGroupEventListener { 
    
    public func ccGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func ccGroupMemberAdded(messages: [ActionMessage], usersAdded: [User], groupAddedIn: Group, addedBy: User) {
        if groupAddedIn.guid == group?.guid {
            messages.forEach { messages in
                self.newMessageReceived?(messages)
                self.add(message: messages)
            }
        }
    }
    
    public func ccGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func ccGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        self.newMessageReceived?(action)
        self.add(message: action)
    }
    
    public func ccGroupMemberScopeChanged(action: ActionMessage, updatedUser: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if group.guid == self.group?.guid {
            if (CometChat.getLoggedInUser()?.uid == updatedUser.uid) {
                if let newScope = CometChat.GroupMemberScopeType.from(string: scopeChangedFrom) {
                    self.group?.scope = newScope
                }
            }
            self.newMessageReceived?(action)
            self.add(message: action)
        }
    }
    
}

extension MessageListViewModel: CometChatCallDelegate {
    public func onIncomingCallReceived(incomingCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let incomingCall = incomingCall {
            self.add(message: incomingCall)
        }
    }
    
    public func onOutgoingCallAccepted(acceptedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let acceptedCall = acceptedCall {
            self.add(message: acceptedCall)
        }
    }
    
    public func onOutgoingCallRejected(rejectedCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let rejectedCall = rejectedCall {
            self.add(message: rejectedCall)
        }
    }
    
    public func onIncomingCallCancelled(canceledCall: CometChatSDK.Call?, error: CometChatSDK.CometChatException?) {
        if let canceledCall = canceledCall {
            self.add(message: canceledCall)
        }
    }
    
    public func onCallEndedMessageReceived(endedCall: Call?, error: CometChatException?) {
        if let endedCall = endedCall {
            self.add(message: endedCall)
        }
    }
    
}

extension MessageListViewModel:  CometChatCallEventListener {
    
    public func ccOutgoingCall(call: Call) {
        self.add(message: call)
    }

    public func ccCallAccepted(call: Call) {
        self.add(message: call)
    }

    public func ccCallRejected(call: Call) {
        self.add(message: call)
    }

    public func ccCallEnded(call: Call) {
        if let _ =   (call.callReceiver as? User) {
            self.add(message: call)
        }
    }
    
}


extension MessageListViewModel: CometChatUIEventListener {
    
    public func showPanel(id: [String : Any]?, alignment: UIAlignment, view: UIView?) {
        if !isForThisView(id: id) { return }
        if let view = view {
            switch alignment {
            case .messageListTop:
                setHeaderView?(view)
            case .messageListBottom:
                setFooterView?(view)
            case .composerTop, .composerBottom: break
            }
        }
    }
    
    public func hidePanel(id: [String : Any]?, alignment: UIAlignment) {
        if !isForThisView(id: id) { return }
        switch alignment {
        case .messageListTop:
            hideHeaderView?(true)
        case .messageListBottom:
            hideFooterView?(true)
        case .composerTop, .composerBottom:
            hideFooterView?(true)
        }
    }
    
    fileprivate func isForThisView(id: [String:Any]?) -> Bool {
        guard let id = id , !id.isEmpty else { return false }
        if (id["uid"] != nil && id["uid"] as? String ==
            self.user?.uid) || (id["guid"] != nil && id["guid"] as? String ==
                                      self.group?.guid) {
            
            if (id["parentMessageId"] != nil &&
                id["parentMessageId"] as? Int == self.parentMessage?.id) {
                return true
            }else if(id["parentMessageId"] == nil && self.parentMessage == nil ){
                return true;
            }
        }
        return false
    }
}

extension MessageListViewModel: AIAssistantEventsDelegate, QueueCompletionCallback {
    
    // MARK: - AI Assistant Message Handling
    
    public func onAIAssistantMessageReceived(message: AIAssistantMessage) {
        isThinkingHidden = false
        let runId = message.runId
        guard runId > 0 else { return }
        
        guard self.getTemplate(for: message) != nil else { return }
        
        ifThreadedMessageUpdateCount(message: message)
        
        if checkThreadedMessageBelongsToThisConversation(message: message) {
            
            CometChatAIStreamService.shared.aiAssistantMessages[runId] = message
            CometChatAIStreamService.shared.setQueueCompletionCallback(runId: runId, callback: self)
        }
    }
    
    public func onAIAssistantEventReceived(_ event: AIAssistantBaseEvent) {
        let runId = event.id
        
        CometChatAIStreamService.shared.handleIncomingEvent(runId: runId, event: event)
        if CometChatAIStreamService.shared.runExists(runId: runId) {
            processNextEvent(runId: runId, event: event)
        }
    }
    
    private func processNextEvent(runId: Int, event: AIAssistantBaseEvent) {
        guard runId == event.id else { return }
        
        let delay = CometChatAIStreamService.shared.streamProcessingDelay
        DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(Int(delay))) {
            switch event {
            case let run as AIAssistantRunStartedEvent:
                self.handleRunStarted(run)
            case let run as AIAssistantRunFinishedEvent:
                self.handleRunFinished(run)
            case let toolEnd as AIAssistantToolEndedEvent:
                self.handleToolCallEnd(toolEnd)
            default:
                break // Other events handled separately
            }
        }
    }
    
    
    // MARK: - Run Lifecycle
    
    private func handleRunStarted(_ event: AIAssistantRunStartedEvent) {
        print("🚀 Run Started | runId: \(event.runId)")

    }
    
    private func handleRunFinished(_ event: AIAssistantRunFinishedEvent) {
        let runId = event.runId
        print("✅ Run Finished | runId: \(runId)")
    }
    
    private func handleToolCallEnd(_ event: AIAssistantToolEndedEvent) {
        let runId = event.runId
        if let messageId = CometChatAIStreamService.shared.getMessageIdForRun(runId: runId) {
            print("🛠️ Tool Ended | runId: \(runId) for messageId: \(messageId)")
        }
    }
    
    
    // MARK: - Queue Completion
    public func onQueueCompleted(_ aiAssistantMessage: CometChatSDK.AIAssistantMessage?, _ aiToolResultMessage: CometChatSDK.AIToolResultMessage?, _ aiToolArgumentMessage: CometChatSDK.AIToolArgumentMessage?) {
        CometChatAIStreamService.shared.isAIBusy = false
        guard let assistantMessage = aiAssistantMessage else { return }
        
        let runId = assistantMessage.runId
        pendingAIMessages.removeValue(forKey: runId)
        completeStreaming(runId: runId, finalMessage: assistantMessage)
        CometChatAIStreamService.shared.clearBuffer(runId: runId)
    }
    
    
    // MARK: - Streaming Lifecycle
    
    func startStreaming(runId: Int, assistant: CometChatSDK.User, parentMessageId: Int? = nil) {
        guard !hasStreamPlaceholder(for: runId) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            
            self?.placeholder = StreamMessage(
                receiverUid: CometChatUIKit.getLoggedInUser()?.uid ?? "",
                receiverType: .user,
                text: "",
                runId: runId,
                threadId: ""
            )
            
            self?.placeholder?.runId = runId
            self?.placeholder?.muid = "stream_placeholder_\(runId)"
            self?.placeholder?.parentMessageId = parentMessageId ?? 0
            self?.placeholder?.sender = assistant
            self?.placeholder?.metaData = [
                "__streaming_placeholder__": true,
                "__show_thinking__": true,
                "runId": runId
            ]
            
            this.add(message: (self?.placeholder)!)
        }
    }
    
    // MARK: - Stream Completion / Failure
    func completeStreaming(runId: Int, finalMessage: CometChatSDK.BaseMessage) {

        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }

            // Ensure thinking is off
            if let final = finalMessage as? StreamMessage {
                final.metaData?["__show_thinking__"] = false
            }

            // Replace placeholder
            for (sectionIndex, group) in this.messages.enumerated() {
                if let rowIndex = group.messages.firstIndex(where: {
                    $0.metaData?["runId"] as? Int == runId &&
                    $0.metaData?["__streaming_placeholder__"] as? Bool == true
                }) {
                    this.messages[sectionIndex].messages[rowIndex] = finalMessage
                    this.updateAtIndex?(sectionIndex, rowIndex, finalMessage)
                    return
                }
            }

            // Fallback
            this.add(message: finalMessage)
        }
    }

    
    func failStreaming(runId: Int, error: Error) {
        
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            for (sectionIndex, group) in this.messages.enumerated() {
                if let rowIndex = group.messages.firstIndex(where: {
                    $0.metaData?["runId"] as? Int == runId &&
                    $0.metaData?["__streaming_placeholder__"] as? Bool == true
                }), let placeholder = group.messages[rowIndex] as? StreamMessage {
                    
                    placeholder.metaData?["__streaming_error__"] = error.localizedDescription
                    placeholder.text = "Error: \(error.localizedDescription)"
                    
                    this.messages[sectionIndex].messages[rowIndex] = placeholder
                    this.updateAtIndex?(sectionIndex, rowIndex, placeholder)
                    break
                }
            }
        }
    }
    
    
    // MARK: - Utilities & Cleanup
    private func hasStreamPlaceholder(for runId: Int) -> Bool {
        return messages.contains { group in
            group.messages.contains {
                ($0.metaData?["runId"] as? Int == runId) &&
                ($0.metaData?["__streaming_placeholder__"] as? Bool == true)
            }
        }
    }
    
    public func setupStreamingSpeedIfNeeded() {
        guard let user = user, user.isAgentic, let speed = streamingSpeed else { return }
        // Lowered min delay to make streaming a bit faster
        let delay = max(0.01, min(Double(speed) / 1000.0, 0.5))
        CometChatAIStreamService.shared.streamProcessingDelay = delay
    }
    
    public func cleanupPendingMessages() {
        pendingAIMessages.removeAll()
    }
    
    public func cleanup() {
        CometChatAIStreamService.shared.isAIBusy = false
        CometChatAIStreamService.shared.cleanupAll()
        pendingAIMessages.removeAll()
    }
}


// MARK: - Connection Listener

extension MessageListViewModel: CometChatConnectionDelegate {
    
    public func connected() {
        if let user = user, user.isAgentic {
            CometChatStreamCallBackEvents.ccStreamCompleted(true)
            CometChatAIStreamService.shared.onConnected()
        }else{
            updateUserAndGroup()
            fetchActionMessages { success in
                if success { self.fetchMissedMessages() }
            }
        }
    }
    
    public func disconnected() {
        if let user = user, user.isAgentic {
            CometChatStreamCallBackEvents.ccStreamInterrupted(true)
            CometChatAIStreamService.shared.onDisconnected()
            placeholder?.metaData?["__stream_error__"] = true
        }
    }
    
    public func connecting() { }

    public func onConnectionError(_ error: CometChatException) {
        if let user = user, user.isAgentic {
            CometChatStreamCallBackEvents.ccStreamInterrupted(true)
            CometChatAIStreamService.shared.onConnectionError(error)
        }
    }
    
    private func handleInterruptedRuns() {
        for index in messages.indices {
            messages[index].messages.removeAll { $0 is StreamMessage }
        }

        DispatchQueue.main.async { [weak self] in
            self?.reload?()
        }
    }


}
