//
//  CometChatMessageList.swift
 
//
//  Created by Pushpsen Airekar on 26/12/22.

import UIKit
import Foundation
import CometChatSDK

open class CometChatMessageList: UIView {
    
    // MARK: - UI Components
    lazy var container: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()

    lazy var headerViewContainer: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.isHidden = true
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()

    open lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain).withoutAutoresizingMaskConstraints()
        tableView.alwaysBounceVertical = false
        tableView.backgroundColor = UIColor.clear
        tableView.transform = CGAffineTransform(scaleX: 1, y: -1)
        return tableView
    }()

    lazy var footerViewContainer: UIStackView = {
        let stackView = UIStackView().withoutAutoresizingMaskConstraints()
        stackView.axis = .vertical
        stackView.isHidden = true
        stackView.backgroundColor = UIColor.clear
        return stackView
    }()
    
    public lazy var errorStateView: UIView = {
        // Not making this view's type as StateView because user can replace this with any UIView
        let stateView = UIView().withoutAutoresizingMaskConstraints()
        return stateView
    }()
    
    public lazy var emptyStateView: UIView = {
        // Not making this view's type as StateView because user can replace this with any UIView
        let stateView = StateView(title: emptyTitleText, subtitle: emptySubtitleText, image: style.emptyImage).withoutAutoresizingMaskConstraints()
        return stateView
    }()
    
    public lazy var loadingStateView: UIView = {
        // Not making this view's type as CometChatMessageShimmerView because user can replace this with any UIView
        let loadingShimmer = CometChatMessageShimmerView()
        loadingShimmer.transform = CGAffineTransform(scaleX: 1, y: -1)
        loadingShimmer.backgroundColor = style.backgroundColor
        return loadingShimmer
    }()
    
    lazy var aiScrollContainer: UIScrollView = {
       let s = UIScrollView().withoutAutoresizingMaskConstraints()
       s.alwaysBounceVertical = true
       s.backgroundColor = .clear
       s.showsVerticalScrollIndicator = false
       s.showsHorizontalScrollIndicator = false
       s.keyboardDismissMode = .interactive
       return s
    }()

    lazy var aiContentView: UIView = {
       let v = UIView().withoutAutoresizingMaskConstraints()
       return v
    }()
    
    lazy var aiView: AIAssistantIntroductionView = {
        let view = AIAssistantIntroductionView().withoutAutoresizingMaskConstraints()
        view.isHidden = true
        return view
    }()
    
    
    // MARK: - Disable Customisation
    var isContextMenuActive = false //to prevent multiple touch issue on message bubble
    public var hideHeaderView = false
    public var hideBubbleHeader = false
    public var hideFooterView = false
    public var hideDateSeparator = false
    public var scrollToBottomOnNewMessages: Bool = false
    public var hideReceipts: Bool = false
    public var disableSoundForMessages: Bool = false
    public var hideEmptyView: Bool = true
    public var hideErrorView: Bool = false
    public var hideLoadingView: Bool = false
    public var hideNewMessageIndicator = false {
        didSet {
            messageIndicator?.isHidden = hideNewMessageIndicator
        }
    }
    public var hideSuggestedMessages = false
    var suggestedMessages: [String]?
    var emptyChatAIGreetingView: UIView?
    var streamingSpeed: Int = 0

    /// When `true` and the conversation is with an AI agent, the message list loads the
    /// most recent previous agent conversation thread instead of starting a fresh chat.
    ///
    /// If no previous conversation exists (or the fetch fails) it falls back to the default
    /// behavior: showing the empty state with the AI greeting view and suggested messages.
    ///
    /// Default: `false` — existing integrations keep starting a new agent chat.
    public var loadLastAgentConversation: Bool = false
    /// Tracks whether we've already attempted to load the last agent conversation so the
    /// fetch only runs once per appearance and doesn't re-trigger on every `willMove`.
    private var didAttemptLoadLastAgentConversation = false
    
    //MARK: - Configuration
    public var reactionsConfiguration: ReactionsConfiguration?
    public var reactionListConfiguration: ReactionListConfiguration?
    public var quickReactionsConfiguration: QuickReactionsConfiguration?
    public var messageInformationConfiguration: MessageInformationConfiguration?
    
    //MARK: GLOBEL STYLES
    public static var style = MessageListStyle()
    public static var emojiKeyboardStyle: EmojiKeyboardStyle = CometChatEmojiKeyboard.style
    public static var dateSeparatorStyle = CometChatDate.style
    public static var newMessageIndicatorStyle = CometChatNewMessageIndicator.style
    public static var messageBubbleStyle = CometChatMessageBubble.style
    public static var actionBubbleStyle = CometChatMessageBubble.actionBubbleStyle
    
    //MARK: LOCAL STYLES
    public var style = CometChatMessageList.style
    public var emojiKeyboardStyle: EmojiKeyboardStyle = CometChatMessageList.emojiKeyboardStyle
    public lazy var dateSeparatorStyle = CometChatMessageList.dateSeparatorStyle
    public lazy var newMessageIndicatorStyle = CometChatMessageList.newMessageIndicatorStyle
    public lazy var messageBubbleStyle = CometChatMessageList.messageBubbleStyle {
        didSet {
            viewModel.messageBubbleStyle = messageBubbleStyle
        }
    }
    public lazy var actionBubbleStyle = CometChatMessageBubble.actionBubbleStyle {
        didSet {
            viewModel.actionBubbleStyle = actionBubbleStyle
        }
    }
    public lazy var callActionBubbleStyle = CometChatMessageBubble.callActionBubbleStyle {
        didSet {
            viewModel.callActionBubbleStyle = callActionBubbleStyle
        }
    }
    
    //Date Time Formatter
    public static var dateTimeFormatter: CometChatDateTimeFormatter = CometChatUIKit.dateTimeFormatter
    public lazy var dateTimeFormatter: CometChatDateTimeFormatter = CometChatMessageList.dateTimeFormatter
    
    //MARK: - Call Backs
    var onThreadRepliesClick: ((_ message: BaseMessage, _ template: CometChatMessageTemplate) -> ())?
    var onReactionClick: ((_ reaction: ReactionCount, _ baseMessage: BaseMessage?) -> ())?
    var onReactionListItemClick: ((_ messageReaction: CometChatSDK.Reaction, _ baseMessage: BaseMessage?) -> ())?
    
    var onError: ((_ error: CometChatException) -> Void)?
    var onEmpty: (() -> Void)?
    var onLoad: (([BaseMessage]) -> Void)?
    var newMessageIndicatorCustomView: UIView?
    public var hideAvatar: Bool?
    public var hideGroupActionMessages: Bool = false
    public var hideFlagRemarkFeild: Bool = false
    public var hideReplyInThreadOption: Bool = false{
        didSet{
            viewModel.hideReplyInThreadOption = hideReplyInThreadOption
        }
    }
    public var hideFlagMessageOption: Bool = false{
        didSet{
            viewModel.hideFlagMessageOption = hideFlagMessageOption
        }
    }
    public var hideTranslateMessageOption: Bool = false{
        didSet{
            viewModel.hideTranslateMessageOption = hideTranslateMessageOption
        }
    }
    public var hideEditMessageOption: Bool = false{
        didSet{
            viewModel.hideEditMessageOption = hideEditMessageOption
        }
    }
    public var hideDeleteMessageOption: Bool = false{
        didSet{
            viewModel.hideDeleteMessageOption = hideDeleteMessageOption
        }
    }
    public var hideReactionOption: Bool = false{
        didSet{
            viewModel.hideReactionOption = hideReactionOption
        }
    }
    public var hideMessagePrivatelyOption: Bool = false{
        didSet{
            viewModel.hideMessagePrivatelyOption = hideMessagePrivatelyOption
        }
    }
    public var hideCopyMessageOption: Bool = false{
        didSet{
            viewModel.hideCopyMessageOption = hideCopyMessageOption
        }
    }
    public var hideReplyMessageOption: Bool = false{
        didSet{
            viewModel.hideReplyMessageOption = hideReplyMessageOption
        }
    }
    public var disableSwipeToReply: Bool = false{
        didSet{
            viewModel.disableSwipeToReply = disableSwipeToReply
        }
    }
    public var hideMessageInfoOption: Bool = false{
        didSet{
            viewModel.hideMessageInfoOption = hideMessageInfoOption
        }
    }
    public var hideShareMessageOption: Bool = false{
        didSet{
            viewModel.hideShareMessageOption = hideShareMessageOption
        }
    }

    public var hideModerationStatus: Bool = false
    
    public var showMarkAsUnreadOption: Bool = false {
        didSet {
            viewModel.showMarkAsUnreadOption = showMarkAsUnreadOption
        }
    }
    public var startFromUnreadMessages: Bool = false 
    
    //AI Variables
    public var enableConversationStarters: Bool = false
    public var enableSmartReplies: Bool = false
    public var enableConversationSummary: Bool = false
    var aiConversationStarterView = CometChatAIConversationStarter()
    var aiSmartReplyView = CometChatAISmartReply()
    var aiConversationSummaryView = CometChatAIConversationSummary()
    var smartRepliesKeywords: [String] = []
    var smartRepliesDelayDuration: Int = 10
    var smartRepliesWorkItem: DispatchWorkItem?

    
    public internal(set) var datePattern: ((_ timestamp: Int?) -> String)?
    public internal(set) var timePattern: ((_ timestamp: Int?) -> String)?
    public internal(set) var dateSeparatorPattern: ((_ timestamp: Int?) -> String)?
    
    //MARK: Other Customisation
    public var messageAlignment: MessageListAlignment = .standard
    public var customSoundForMessages: URL?
    public var emptyTitleText = "NO_CONVERSATIONS_YET".localize() {
        didSet {
            (emptyStateView as? StateView)?.title = emptyTitleText
        }
    }
    public var emptySubtitleText = "START_A_NEW_CHAT_OR_INVITE_OTHERS_TO_JOIN_THE_CONVERSATION.".localize() {
        didSet {
            (emptyStateView as? StateView)?.subtitle = emptySubtitleText
        }
    }
    public var errorTitleText = "OOPS!".localize() {
        didSet {
            (errorStateView as? StateView)?.title = emptyTitleText
        }
    }
    public var errorSubtitleText = "LOOKS_LIKE_SOMETHINGS_WENT_WORNG._PLEASE_TRY_AGAIN".localize() {
        didSet {
            (errorStateView as? StateView)?.subtitle = emptySubtitleText
        }
    }

    public var onAIOptionSelected: ((_ option: String) -> Void)?
    
    /// Callback invoked when a previous agent conversation was successfully loaded.
    /// The parameter is the parent message ID of the loaded thread.
    /// Use this to configure the composer's parentMessageId for message continuation.
    public var onLastAgentConversationLoaded: ((_ parentMessageId: Int) -> Void)?

    //MARK: - INTERNAL HELPER VARIABLE
    var newMessageIndicatorScrollOffSet: CGFloat = 150
    var messagesRequestBuilder: MessagesRequest.MessageRequestBuilder? = nil
    public var withParent: Bool?
    var reactionsRequestBuilder: ReactionsRequestBuilder? = nil
    var baseMessage: BaseMessage?
    weak var controller: UIViewController?
    var messageIndicator : CometChatNewMessageIndicator?
    var viewModel = MessageListViewModel()
    var lastContentOffset: CGFloat = 0
    
    var unreadSeparatorMessageId: Int?
    var scrolledToUnread: Bool = false
    var unreadMessageCount: Int = 0
    var scrollRestored = false
    var isScrollToBottomTapped = false  // Flag to keep indicator hidden after tap
    private var isViewActive: Bool = true  // Flag to track if view is still active for updates
    lazy var onTapGesture: UITapGestureRecognizer = {
        let onTapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        onTapGesture.cancelsTouchesInView = false
        return onTapGesture
    }()
    var contextMenuCell: CometChatMessageBubble?
    var contextMenuMessage: BaseMessage?
    
    private let deltaThreshold: CGFloat = 2
    
    var highlightRetryCount: Int = 0
    var pendingHighlightMessageId: Int?
    
    var oldContentHeight: CGFloat = 0
    var oldContentOffset: CGPoint = CGPoint()
    var oldDistanceFromTop : CGFloat = 0
    var newHeight : CGFloat = 0

    var fetchNextAnchorSnapshot: AnchorSnapshot?
    var gotoMessageId: Int = 0
    
    var unreadSeparatorMode: UnreadSeparatorMode?
    
    public var textFormatter: [CometChatTextFormatter] = [CometChatMentionsFormatter()]
    
    public var flagReasonLocalizer: ((String) -> String)?
    
    //MARK: - Life Cycle Function
    public override init(frame: CGRect) {
        super.init(frame: UIScreen.main.bounds)
        buildUI()
        handleThemeModeChange()
        connect()
        setupTableView()
        setupViewModel()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        buildUI()
        connect()
        setupTableView()
        setupViewModel()
    }
    
    open override func willMove(toWindow newWindow: UIWindow?) {
        if newWindow != nil {
            
            // Reload table to show any updates that happened while view was not visible
            // (e.g., thread reply count updates)
            tableView.reloadData()

            if viewModel.user?.isAgentic ?? false{
                hideDateSeparator = true
                viewModel.streamingSpeed = streamingSpeed
                print("[AIAgent] willMove agentic: parentMessage.id=\(viewModel.parentMessage?.id ?? -1), threadedPArentMessageId=\(viewModel.threadedPArentMessageId), loadLastAgentConversation=\(loadLastAgentConversation), didAttempt=\(didAttemptLoadLastAgentConversation), hasFetchedBefore=\(viewModel.hasFetchedMessagesBefore)")
                if viewModel.parentMessage != nil && viewModel.parentMessage?.id ?? 0 > 0{
                    print("[AIAgent] willMove → fetchData (specific thread)")
                    fetchData()
                } else if viewModel.threadedPArentMessageId > 0{
                    if viewModel.hasFetchedMessagesBefore {
                        print("[AIAgent] willMove → fetchData (existing threadedParent)")
                        fetchData()
                    } else {
                        print("[AIAgent] willMove → no-op (threadedParent set but not fetched yet)")
                    }
                } else if loadLastAgentConversation && !didAttemptLoadLastAgentConversation {
                    print("[AIAgent] willMove → loadPreviousAgentConversation()")
                    loadPreviousAgentConversation()
                } else{
                    // Only show the AI greeting view if we don't already have messages loaded
                    // (prevents hiding the table after a message has been sent but before
                    // threadedPArentMessageId is assigned from the success callback).
                    if viewModel.messages.isEmpty && !viewModel.hasFetchedMessagesBefore {
                        print("[AIAgent] willMove → buildAgenticView (new chat / fresh)")
                        buildAgenticView()
                    } else if viewModel.messages.isEmpty {
                        print("[AIAgent] willMove → buildAgenticView (messages empty, previously fetched)")
                        buildAgenticView()
                    } else {
                        print("[AIAgent] willMove → no-op (messages already present, table should be visible)")
                    }
                }
                
                
            }else{
                if !viewModel.hasFetchedMessagesBefore {
                    fetchData()
                } else {
                    // Reload table view to reflect any updates that happened while view was not visible
                    // (e.g., thread reply count updates)
                    tableView.reloadData()
                }
            }
            setupStyle()
        }else{
            smartRepliesWorkItem?.cancel()
            smartRepliesWorkItem = nil
        }
    }
    
    deinit {
        isViewActive = false  // Prevent any pending async operations from updating tableView
        CometChatAIStreamService.shared.cleanupAll()
            disconnect()
        CometChatAIStreamService.shared.isAIBusy = false
    }
    
    // ------ END: life cycle functions ---- //
    
    //MARK: Building and styling UI
    open func buildUI() {
        embed(container)
        
        container.addArrangedSubview(headerViewContainer)
        headerViewContainer.pin(anchors: [.leading, .trailing], to: container, with: 10)
        
        // Add aiScrollView instead of aiView
        container.addArrangedSubview(aiScrollContainer)
        aiScrollContainer.pin(anchors: [.leading, .trailing], to: container, with: 0)
        
        // Place aiView inside aiScrollView
        aiScrollContainer.addSubview(aiView)
        aiView.pin(anchors: [.top, .leading, .trailing, .bottom], to: aiScrollContainer, with: 0)
        aiView.widthAnchor.constraint(equalTo: aiScrollContainer.widthAnchor).isActive = true
        aiView.heightAnchor.constraint(equalTo: aiScrollContainer.heightAnchor).isActive = true
        
        container.addArrangedSubview(tableView)
        tableView.pin(anchors: [.leading, .trailing], to: container, with: 0)
        container.addArrangedSubview(footerViewContainer)
        footerViewContainer.pin(anchors: [.leading, .trailing], to: container, with: 10)
    }
    
    func showBottomSpinner() {
        tableView.isScrollEnabled = false
        let spinner = UIActivityIndicatorView(style: .medium)
        spinner.startAnimating()
        spinner.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: 60)
        tableView.tableHeaderView = spinner   // inverted table → header acts as bottom
    }

    func hideBottomSpinner() {
        tableView.isScrollEnabled = true
        tableView.tableHeaderView = nil
    }
    
    func buildAgenticView(){
        if let view = emptyChatAIGreetingView{
            aiView.removeFromSuperview()
            aiScrollContainer.addSubview(view)
            view.pin(anchors: [.top, .leading, .trailing, .bottom], to: aiScrollContainer, with: 0)
            view.widthAnchor.constraint(equalTo: aiScrollContainer.widthAnchor).isActive = true
            view.heightAnchor.constraint(equalTo: aiScrollContainer.heightAnchor).isActive = true
        }
        showAIView()
    }

    /// Loads the most recent agent conversation thread and falls back to the default
    /// new-chat (AI greeting) experience when no previous conversation is available
    /// or the fetch fails.
    func loadPreviousAgentConversation() {
        didAttemptLoadLastAgentConversation = true
        print("[AIAgent] loadPreviousAgentConversation: showing loading view")
        showLoadingView()
        viewModel.loadLastAgentConversation { [weak self] didLoad, parentId in
            guard let this = self else {
                print("[AIAgent] loadPreviousAgentConversation: self released")
                return
            }
            print("[AIAgent] loadPreviousAgentConversation completed: didLoad=\(didLoad), parentId=\(parentId), isViewActive=\(this.isViewActive)")
            guard this.isViewActive else { return }
            if didLoad {
                print("[AIAgent] loadPreviousAgentConversation → fetchData()")
                // Notify listeners (e.g. composer) about the loaded thread parentMessageId
                // so outgoing messages are correctly threaded.
                var id = [String: Any]()
                if let user = this.viewModel.user {
                    id["uid"] = user.uid
                }
                id["parentMessageId"] = parentId
                CometChatUIEvents.ccActiveChatChanged(id: id, lastMessage: nil, user: this.viewModel.user, group: nil)
                this.onLastAgentConversationLoaded?(parentId)
                this.fetchData()
            } else {
                print("[AIAgent] loadPreviousAgentConversation → fallback buildAgenticView")
                this.removeLoadingView()
                this.buildAgenticView()
            }
        }
    }
    
    func showAIView() {
        tableView.isHidden = true
        aiScrollContainer.isHidden = false
        if let view = emptyChatAIGreetingView{
            view.isHidden = false
        }else{
            aiView.isHidden = false
        }
        aiView.avatarView.setAvatar(avatarUrl: viewModel.user?.avatar ?? "", with: viewModel.user?.name)
        if let user = viewModel.user {
            aiView.avatarView.setAvatar(avatarUrl: user.avatar ?? "", with: user.name)
            let greeting = user.metadata?["greetingMessage"] as? String
            let intro = user.metadata?["introductoryMessage"] as? String
            var suggestions : [String]?
            
            if let suggestedMessages = suggestedMessages{
                suggestions = suggestedMessages
            }else{
                suggestions = user.metadata?["suggestedMessages"] as? [String]
            }
             
            aiView.configure(
                greetingMessage: greeting,
                introductoryMessage: intro,
                suggestedMessages: suggestions,
                hideSuggestedMessages: hideSuggestedMessages
            )
        }
        aiView.onOptionSelected = { [weak self] option in
            guard let this = self else { return }
            this.onAIOptionSelected?(option)
        }
    }

    func showTableView() {
        DispatchQueue.main.async { [weak self] in
            self?.aiScrollContainer.isHidden = true
            
            if let view = self?.emptyChatAIGreetingView{
                view.isHidden = true
            }else{
                self?.aiView.isHidden = true
            }
            self?.tableView.isHidden = false
        }
    }

    
    open func setupStyle() {
        self.backgroundColor = style.backgroundColor
        if let backgroundImage = style.backgroundImage {
            tableView.backgroundView = UIImageView(image: style.backgroundImage)
        }
        tableView.backgroundColor = style.backgroundColor
        tableView.borderWith(width: style.borderWidth)
        tableView.borderColor(color: style.borderColor)
        if let cornerRadius = style.cornerRadius { tableView.roundViewCorners(corner: cornerRadius) }
        
        if let emptyStateView = emptyStateView as? StateView {
            emptyStateView.titleLabel.textColor = style.emptyStateTitleColor
            emptyStateView.subtitleLabel.textColor = style.emptyStateSubtitleColor
            emptyStateView.titleLabel.font = style.emptyStateTitleFont
            emptyStateView.subtitleLabel.font = style.emptyStateSubtitleFont
        }
        
        if let errorStateView = errorStateView as? StateView {
            errorStateView.titleLabel.textColor = style.errorStateTitleColor
            errorStateView.subtitleLabel.textColor = style.errorStateSubtitleColor
            errorStateView.titleLabel.font = style.errorStateTitleFont
            errorStateView.subtitleLabel.font = style.errorStateSubtitleFont
        }
        
        if let loadingStateView = loadingStateView as? CometChatMessageShimmerView {
            loadingStateView.isGroupMode = viewModel.group == nil ? false : true
            loadingStateView.colorGradient1 = style.shimmerGradientColor1
            loadingStateView.colorGradient2 = style.shimmerGradientColor2
        }
        
        if hideHeaderView{
            self.clear(headerView: true)
        }
        if hideFooterView{
            self.clear(footerView: true)
        }
        
    }
    
    private func setupTableView() {
        tableView.backgroundColor = CometChatTheme.backgroundColor02
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        registerCells()
        showNewMessageIndicator()
    }
    
    open func reload() {
        tableView.reloadData()
    }
    
    private func fetchData() {
        print("[AIAgent] fetchData: messages.isEmpty=\(viewModel.messages.isEmpty), parentMessage.id=\(viewModel.parentMessage?.id ?? -1), gotoMessageId=\(gotoMessageId)")
        if viewModel.messages.isEmpty {
            showLoadingView()
        }

        if gotoMessageId != 0 {
            self.goToMessage(withId: gotoMessageId)
        } else {
            let conversationWith: String
            let conversationType: CometChat.ConversationType
            let receiverType: CometChat.ReceiverType
            
            if let user = viewModel.user {
                conversationWith = user.uid ?? ""
                conversationType = .user
                receiverType = .user
            } else if let group = viewModel.group {
                conversationWith = group.guid
                conversationType = .group
                receiverType = .group
            } else {
                return
            }
            
            // Skip unread separator logic for thread views
            let isThreadView = viewModel.parentMessage != nil && (viewModel.parentMessage?.id ?? 0) > 0
            
            if isThreadView {
                // For thread views, just fetch messages without unread separator logic
                viewModel.fetchPreviousMessages()
                return
            }
            
            viewModel.getConversation(conversationWith: conversationWith, conversationType: conversationType) { [weak self] conversation in
                guard let this = self else { return }
                
                // Handle new chat scenario (no existing conversation)
                guard let conversation = conversation else {
                    print("No existing conversation found - treating as new chat")
                    this.viewModel.fetchPreviousMessages()
                    return
                }
                
                if this.startFromUnreadMessages && conversation.unreadMessageCount > 0 && this.gotoMessageId <= 0 {
                    let lastReadMessageId = conversation.lastReadMessageId
                    if lastReadMessageId <= 0 {
                        this.viewModel.fetchPreviousMessages()
                        print("unread message detected with last read message less than equal to 0")
                    } else {
                        this.unreadSeparatorMessageId = lastReadMessageId
                        this.unreadSeparatorMode = .navigateFromConversation
                        this.unreadMessageCount = conversation.unreadMessageCount
                        this.scrolledToUnread = true
                        this.viewModel.goToMessage(messageId: lastReadMessageId)
                        
                        print("unread message detected")
                        print("lastReadMessageId \(lastReadMessageId)")
                    }
                    
                } else {
                    print("unread message not detected")
                    print("conversation count is: \(conversation.unreadMessageCount)")
                    print("conversation last read message id is: \(conversation.lastReadMessageId)")
                    if conversation.unreadMessageCount > 0 {
                        let lastReadMessageId = conversation.lastReadMessageId
                        this.unreadSeparatorMessageId = lastReadMessageId
                        this.unreadSeparatorMode = .navigateFromConversation
                        print("go to message but unread count more than 0")
                    }
                    this.viewModel.fetchPreviousMessages()
                }
                this.viewModel.markConversationAsRead(conversationWith, receiverType)
            }
        }
    }
    
    open func showNewMessageIndicator() {
        if !hideNewMessageIndicator {
            messageIndicator = CometChatNewMessageIndicator().withoutAutoresizingMaskConstraints()
            messageIndicator!.style = newMessageIndicatorStyle
            self.addSubview(messageIndicator!)
            NSLayoutConstraint.activate([
                messageIndicator!.trailingAnchor.pin(equalTo: tableView.trailingAnchor, constant: -8),
                messageIndicator!.bottomAnchor.pin(equalTo: self.tableView.bottomAnchor, constant: -8)
            ])
            
            UIView.transition(with: messageIndicator!, duration: 0.4,
                              options: .transitionCrossDissolve,
                              animations: { [weak self] in
                guard let this = self else { return }
                this.messageIndicator?.reset()
                this.messageIndicator?.isHidden = true
            })
            messageIndicator!.onClick = { [weak self] in
                guard let this = self else { return }
                this.unreadMessageCount = 0
                this.isScrollToBottomTapped = true
                this.messageIndicator?.reset()
                this.messageIndicator?.isHidden = true
                this.fetchBottomMessages()
                this.scrollToBottom()
            }
            
        }
    }
    
   private func fetchBottomMessages() {
        viewModel.hasFetchedMessagesBefore = false
        viewModel.isAllMessagesFetchedInPrevious = false
        
        viewModel.messages.removeAll()
        tableView.reloadData()
        showLoadingView()
        
        gotoMessageId = 0
        if let user = viewModel.user, !user.isAgentic {
            viewModel.set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder()
                .set(uid: user.uid ?? "")
                .hideReplies(hide: true)
                .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
                .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])
                .set(messageID: -1))
        } else if let user = viewModel.user, user.isAgentic, viewModel.threadedPArentMessageId > 0 {
            viewModel.messagesRequestBuilder = MessagesRequest.MessageRequestBuilder()
                .set(uid: user.uid ?? "")
                .setParentMessageId(parentMessageId: viewModel.threadedPArentMessageId)
                .set(withParent: true)
                .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
                .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])
                .set(messageID: -1)
            viewModel.messagesRequest = viewModel.messagesRequestBuilder.build()
            viewModel.isAllMessagesFetchedInNext = true
        } else if let group = viewModel.group {
            viewModel.set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder()
                .set(guid: group.guid)
                .hideReplies(hide: true)
                .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
                .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])
                .set(messageID: -1))
        }
//        fetchData()
       let conversationWith: String
       let conversationType: CometChat.ConversationType
       let receiverType: CometChat.ReceiverType
       
       if let user = viewModel.user {
           conversationWith = user.uid ?? ""
           conversationType = .user
           receiverType = .user
       } else if let group = viewModel.group {
           conversationWith = group.guid
           conversationType = .group
           receiverType = .group
       } else {
           return
       }
       viewModel.fetchPreviousMessages()
       viewModel.markConversationAsRead(conversationWith, receiverType)
    }
    
    //MARK: - State Views
    open func showErrorView() {
        if hideErrorView { return }
        addSubview(errorStateView)
        errorStateView.pin(anchors: [.centerX, .centerY], to: self)
    }
    
    open func removeErrorView() {
        if hideErrorView { return }
        errorStateView.removeFromSuperview()
    }
    
    open func showEmptyView() {
        if hideEmptyView { return }
        addSubview(emptyStateView)
        emptyStateView.pin(anchors: [.centerX, .centerY], to: self)
    }
    
    open func removeEmptyView() {
        if hideEmptyView { return }
        emptyStateView.removeFromSuperview()
    }
    
    open func showLoadingView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            print("[AIAgent] showLoadingView: hideLoadingView=\(self.hideLoadingView), superview=\(self.loadingStateView.superview != nil)")
            if self.hideLoadingView { return }
            if let loadingStateView = self.loadingStateView as? CometChatMessageShimmerView {
                loadingStateView.startShimmer()
            }
            addSubview(self.loadingStateView)
            self.embed(self.loadingStateView)
        }
    }
    
    open func removeLoadingView() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            print("[AIAgent] removeLoadingView: hideLoadingView=\(self.hideLoadingView), wasInView=\(self.loadingStateView.superview != nil)")
            if self.hideLoadingView { return }
            if let loadingStateView = self.loadingStateView as? CometChatMessageShimmerView {
                loadingStateView.stopShimmer()
            }
            self.loadingStateView.removeFromSuperview()
        }
    }
    
    open func showTopSpinner() {
        tableView.tableFooterView = ActivityIndicator.show()
        tableView.tableFooterView?.isHidden = false
    }
    
    open func hideTopSpinner() {
        ActivityIndicator.hide()
        tableView.tableFooterView?.isHidden = true
        if tableView.contentSize.height < tableView.visibleSize.height || (tableView.contentOffset.y < 5 && !tableView.visibleCells.isEmpty) {
            // Avoid beginUpdates/endUpdates here as it can cause data source inconsistency
            // when concurrent message operations are in progress
            ActivityIndicator.activityIndicator.frame = .zero
            tableView.tableFooterView = nil
        }
    }
    
    func getId() -> [String: Any] {
        var id = [String:Any]()
        
        if let user = viewModel.user {
            id["uid"] = user.uid
        }
        if let group = viewModel.group {
            id["guid"] = group.guid
        }
        
        return id
    }
    
    //MARK: - View Model Set up
    open func setupViewModel() {

        viewModel.scrollToMessageId = { [weak self] id, isPagination in
            guard let this = self, this.isViewActive else { return }
            
            if this.startFromUnreadMessages && this.gotoMessageId <= 0 {
                print("check index to scroll")
                if let unreadId = this.unreadSeparatorMessageId,
                   let unreadIndexPath = this.viewModel.indexPathForMessageId(unreadId) {

                    // Separator is always AFTER unread message in inverted table
                    let separatorIndexPath = IndexPath(
                        row: unreadIndexPath.row - 1,
                        section: unreadIndexPath.section
                    )

                    let visibleIndexPaths = this.tableView.indexPathsForVisibleRows ?? []
                    let isSeparatorCellVisible = this.tableView.visibleCells.contains {
                            $0 is UnreadSeparatorCell
                        }
                    
                    // If separator is already visible, or target is at row 0 and visible → just show separator, don't scroll
                    if visibleIndexPaths.contains(separatorIndexPath) || isSeparatorCellVisible {
                        this.startFromUnreadMessages = false
                        this.messageIndicator?.isHidden = this.unreadMessageCount > 0 ? false : true
//                        this.messageIndicator?.setUnreadCount(count: this.unreadMessageCount)
                        this.removeLoadingView()
                        print("unreadSeparatorMessageId is \(unreadId)")
                        print("unreadIndexPath: \(unreadIndexPath)")
                        return
                    }

                    print("Unread separator not visible. Will scroll. section=\(separatorIndexPath.section), row=\(separatorIndexPath.row)")

                    // First scroll to the unread message to ensure it's loaded
                    this.tableView.scrollToRow(
                        at: unreadIndexPath,
                        at: .bottom,
                        animated: false
                    )


                    this.startFromUnreadMessages = false
                    
                    // Position the separator near the top of the visible area
                    // so user sees unread messages below and knows to scroll down
                    DispatchQueue.main.async {
                        guard let rectForUnread = self?.tableView.rectForRow(at: unreadIndexPath) else { return }
                        
                        // In inverted table, we want the separator near the top (which is bottom in normal coordinates)
                        // Calculate offset to position the unread message near the top with some padding
                        let visibleHeight = self?.tableView.bounds.height ?? 0
                        let topPadding: CGFloat = 100 // Padding from top to show some context above separator
                        
                        let targetOffsetY = rectForUnread.origin.y - topPadding
                        let maxOffset = max(0, (self?.tableView.contentSize.height ?? 0) - visibleHeight)
                        let clampedOffset = max(0, min(targetOffsetY, maxOffset))
                        
                        self?.tableView.setContentOffset(CGPoint(x: 0, y: clampedOffset), animated: false)
                        
                        this.messageIndicator?.isHidden = this.unreadMessageCount > 0 ? false : true
                    }
                }
                this.removeLoadingView()
                return
            }
            
            this.oldContentHeight = this.tableView.contentSize.height
            
            this.newHeight = this.tableView.contentSize.height
            this.scrollToMessage(withId: id, isPagination: isPagination) { anchorId in
                                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self, self.isViewActive, self.tableView.window != nil else { return }
                    if let indexPath = self.indexPathForMessageWithId(anchorId) {
                        let rectForAnchor = self.tableView.rectForRow(at: indexPath)
                        let targetOffsetY = (rectForAnchor.origin.y) - (self.oldDistanceFromTop)
                        self.tableView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: false)
                    }
                    
                    print("after fetch next height: \(self.tableView.contentOffset.y), \(self.tableView.contentSize.height)")
                    
                    self.hideBottomSpinner()
                    self.tableView.isScrollEnabled = true
                }
            }
            self?.removeLoadingView()
        }
        
        viewModel.reload = { [weak self]  in
            guard let this = self, this.isViewActive else { return }
            DispatchQueue.main.async {
                guard this.isViewActive, this.tableView.window != nil else {
                    print("[AIAgent] reload: isViewActive=\(this.isViewActive), tableView.window=\(this.tableView.window != nil) — bailing")
                    return
                }
                print("[AIAgent] reload fired: messages.isEmpty=\(this.viewModel.messages.isEmpty), gotoMessageId=\(this.gotoMessageId)")
                
                if this.gotoMessageId <= 0 {
                    this.removeLoadingView()
                }
                
                this.reload()
                                
                if this.viewModel.messages.isEmpty {
                    if let onEmpty = this.onEmpty?(){
                        onEmpty
                    }
                    this.scrollRestored = true
                   if !this.hideEmptyView{
                       if let user = this.viewModel.user, user.isAgentic{
                           this.showAIView()
                       }
                        this.showEmptyView()
                    }
                } else {
                    this.scrollRestored = false
                    this.showTableView()
                    this.removeEmptyView()
                    this.removeErrorView()
                }
                if let onLoad = this.onLoad?(this.viewModel.messages.flatMap { $0.messages }){
                    onLoad
                }
                
                this.hideTopSpinner()
            }
        }
        
        viewModel.updateConversationCount = { [weak self] in
            self?.unreadMessageCount += 1
            self?.messageIndicator?.setUnreadCount(count: self?.unreadMessageCount ?? 0)
        }
        
        viewModel.appendAtIndex = { [weak self] section , row, message, isNewSectionAdded in
            DispatchQueue.main.async {
                guard let this = self, this.isViewActive else { return }
                
                // Additional safety check - ensure tableView is still in a valid state
                guard this.tableView.window != nil else { return }
                
                this.showTableView()
                
                let shouldFilterMessage = this.hideGroupActionMessages &&
                                         message.messageCategory == .action &&
                                         message.receiverType == .group
                
                // If the message should be filtered, don't insert it into the table view
                // but still perform other operations like removing empty views
                if shouldFilterMessage {
                    this.removeEmptyView()
                    this.removeErrorView()
                    return
                }
                
                let wasNextPagination = this.viewModel.isFetchingNext

                var shouldScrollToBottom = false
                if this.scrollToBottomOnNewMessages {
                    shouldScrollToBottom = true
                } else {
                    if this.tableView.contentOffset.y > 300 {
                        if this.unreadMessageCount > 0 {
                            this.messageIndicator?.setUnreadCount(count: this.unreadMessageCount)
                        } else {
                            this.messageIndicator?.reset()
                        }
                        this.messageIndicator?.isHidden = false
                    } else {
                        shouldScrollToBottom = true
                    }
                }
                
                // Use reloadData() for safety - it always works regardless of data source state
                // This prevents the NSInternalInconsistencyException crash that occurs when
                // multiple messages are added rapidly and the data source count doesn't match
                // the expected count during batch updates
                this.tableView.reloadData()
                
                // Removing error/empty view if presented
                this.removeEmptyView()
                this.removeErrorView()
                
                if !wasNextPagination && shouldScrollToBottom {
                    this.scrollToBottom()
                }
                
                // Clean up failed stream messages
                this.viewModel.removeMarkedFailedStreamMessages()
            }
        }
        
        viewModel.deleteBatch = { [weak self] deletions, emptySections in
            guard let self = self, self.isViewActive else { return }
            let table = self.tableView
            
            // Ensure we're on the main thread
            DispatchQueue.main.async { [weak self] in
                guard let self = self, self.isViewActive, table.window != nil else { return }
                
                // Only perform if there are valid operations
                guard !deletions.isEmpty || !emptySections.isEmpty else { return }
                
                // Use reloadData() for safety - it always works regardless of data source state
                table.reloadData()
            }
        }

        
        
        viewModel.updateAtIndex = { [weak self] section , row, message in
            guard let this = self, this.isViewActive else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let this = self, this.isViewActive, this.tableView.window != nil else { return }
                
                // Step 1: Capture current table view state
                let currentSections = this.tableView.numberOfSections
                let dataSourceSections = this.viewModel.messages.count
                
                // Verify section count consistency before any incremental update
                // If they don't match, a concurrent insert changed the data source — reloadRows would crash
                guard currentSections == dataSourceSections else {
                    print("[CometChatMessageList] updateAtIndex: section count mismatch — tableView has \(currentSections) sections, dataSource has \(dataSourceSections). Falling back to reloadData().")
                    this.tableView.reloadData()
                    return
                }
                
                let currentRows = section < currentSections ? this.tableView.numberOfRows(inSection: section) : 0
                
                // Step 2: Validate section exists
                guard section < currentSections else {
                    return // Skip update - will be corrected on next load
                }
                
                // Step 3: Validate row exists
                guard row < currentRows else {
                    return // Skip update - will be corrected on next load
                }
                
                // Step 4: Verify data source consistency
                let dataSourceCount = this.viewModel.messages.count > section ?
                                     this.viewModel.messages[section].messages.count : 0
                
                guard dataSourceCount == currentRows else {
                    // Use reloadData for safety
                    print("[CometChatMessageList] updateAtIndex: row count mismatch in section \(section) — tableView has \(currentRows) rows, dataSource has \(dataSourceCount). Falling back to reloadData().")
                    this.tableView.reloadData()
                    return
                }
                
                let indexPath = IndexPath(row: row, section: section)
                
                // Step 5: Safely reload the specific row
                // Reload regardless of visibility to ensure receipt updates are applied
                UIView.performWithoutAnimation {
                    this.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
        
        // Receipt-only updates - update just the status info view without reloading the entire cell
        // This prevents sticker flickering when read receipts are updated
        viewModel.updateReceiptAtIndex = { [weak self] section, row, message in
            guard let this = self, this.isViewActive else { return }
            
            DispatchQueue.main.async { [weak self] in
                guard let this = self, this.isViewActive, this.tableView.window != nil else { return }
                
                let indexPath = IndexPath(row: row, section: section)
                
                // If cell is visible, update just the status info view for smooth UI
                if this.tableView.indexPathsForVisibleRows?.contains(indexPath) == true,
                   let cell = this.tableView.cellForRow(at: indexPath) as? CometChatMessageBubble {
                    
                    // Update the cell's message reference to ensure consistency
                    cell.set(message: message)
                    
                    // Update only the status info view (receipt) without reloading the entire cell
                    let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
                    let bubbleStyle = isLoggedInUser ? this.messageBubbleStyle.outgoing : this.messageBubbleStyle.incoming
                    let messageTypeStyle = MessageUtils.getSpecificMessageTypeStyle(message: message, from: this.messageBubbleStyle)
                    
                    // Clear and rebuild only the status info view
                    cell.statusInfoView.subviews.forEach { $0.removeFromSuperview() }
                    MessageUtils.buildStatusInfo(
                        from: cell,
                        messageTypeStyle: messageTypeStyle,
                        bubbleStyle: bubbleStyle,
                        message: message,
                        hideReceipt: this.hideReceipts,
                        messageAlignment: this.messageAlignment,
                        timePattern: this.timePattern,
                        dateTimeFormatter: this.dateTimeFormatter,
                        isModerated: false
                    )
                } else {
                    // Cell not visible — no action needed.
                    // The cell will pick up the correct receipt state when dequeued on scroll.
                }
            }
        }
        
        viewModel.deleteAtIndex = { [weak self] section , row, message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                // Use reloadData() for safety - it always works regardless of data source state
                this.tableView.reloadData()
            }
        }
        
        viewModel.newMessageReceived = { [weak self] message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                if (this.viewModel.group != nil && message.receiverUid == this.viewModel.group?.guid && message.receiverType == .group) || (this.viewModel.user != nil && message.senderUid == this.viewModel.user?.uid && message.receiverType == .user) {
                    this.updateAIOnNewMessageReceived(message: message)
                }
                if !this.disableSoundForMessages {
                    CometChatSoundManager().play(sound: .incomingMessage, customSound: this.customSoundForMessages)
                }
            }
        }
        
        viewModel.ccMessageSent = { [weak self] message, status in
            guard let this = self else { return }
            if status == .inProgress {
                this.updateAIOnNewMessageReceived(message: message)
                
                // Clear the "New" separator when user sends their own message
                // This prevents the separator from showing after user interacts with the chat
                if this.unreadSeparatorMessageId != nil {
                    this.unreadSeparatorMessageId = nil
                    this.unreadMessageCount = 0
                    DispatchQueue.main.async {
                        this.tableView.reloadData()
                    }
                }

            }
        }
        
        viewModel.failure = { [weak self] error in
            DispatchQueue.main.async {
                guard let this = self else { return }
                if let onError = this.onError?(error){
                    onError
                }
                this.removeLoadingView()
                this.showErrorView()
            }
        }
        
        viewModel.hideFooterView = { [weak self] hideFooterView  in
            guard let this = self else { return }
            this.clear(footerView: hideFooterView)
        }
        
        viewModel.hideHeaderView = { [weak self] hideHeaderView  in
            guard let this = self else { return }
            this.clear(headerView: hideHeaderView)
        }
        
        viewModel.setFooterView = { [weak self] footerView  in
            guard let this = self else { return }
            if this.hideFooterView == false {
                this.set(footerView: footerView)
            }
        }
        
        viewModel.setHeaderView = { [weak self] headerView  in
            guard let this = self else { return }
            if this.hideReceipts == false {
                this.set(headerView: headerView)
            }
        }
        
        viewModel.onFirstMessageFetch = { [weak self] in
            guard let this = self else { return }
            if this.viewModel.messages.isEmpty {
                if this.enableConversationStarters{
                    this.getConversationStarter()
                }
            }
        }
        
        viewModel.willStartFetchNext = { [weak self] in
            self?.captureAnchorBeforeFetchNext()
        }

        viewModel.didCompleteFetchNextWithMetrics = { [weak self] oldOffsetY, oldContentHeight in
            self?.restoreAnchorAfterFetchNext(oldOffsetY: oldOffsetY, oldContentHeight: oldContentHeight)
        }
        
        viewModel.captureAnchorMessageId = { [weak self] in
            return self?.getTopVisibleMessageId()   // or 5th-from-bottom logic
        }
        
        viewModel.restoreAnchor = { [weak self] messageId in
            guard let self = self else { return }
            // call the no-blink restore
            self.restoreAnchorWithoutBlink(messageId: messageId)
        }

        viewModel.hideBottomSpinner = { [weak self] in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.hideBottomSpinner()
            }
        }
        
    }
    
    open func handleThemeModeChange() {
        if #available(iOS 17.0, *) {
            registerForTraitChanges([UITraitUserInterfaceStyle.self], handler: { (self: Self, previousTraitCollection: UITraitCollection) in
                self.setupStyle()
                self.tableView.reloadData()
            })
        }
    }
    
    open override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        // Check if the user interface style has changed
        if self.traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            self.setupStyle()
            self.tableView.reloadData()
        }
        
        // Handle size class changes for iPad flexible window resizing
        if previousTraitCollection?.horizontalSizeClass != traitCollection.horizontalSizeClass ||
           previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass {
            invalidateIntrinsicContentSize()
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    /// Handle window size transitions for iPad flexible window resizing
    open func handleWindowSizeTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator?) {
        coordinator?.animate(alongsideTransition: { [weak self] _ in
            guard let self = self else { return }
            self.invalidateIntrinsicContentSize()
            self.setNeedsLayout()
            self.layoutIfNeeded()
            self.tableView.reloadData()
        }, completion: nil)
    }
    
    open func addModerationView(
        on cell: CometChatMessageBubble,
        message: BaseMessage,
        bubbleStyle: MessageBubbleStyle
    ) {
        MessageUtils.getModerationView(
            from: cell,
            message: message,
            bubbleStyle: bubbleStyle
        )
    }
    
    open func addAIActionBarView(on cell: CometChatMessageBubble, message: BaseMessage){
        MessageUtils.getAIActionView(message: message, from: cell, onCopyTapped: { message in
            if let message = message as? AIAssistantMessage {
                UIPasteboard.general.string = message.text
            }
        })
    }
    
    open func buildMessageFooterView(
        on cell: CometChatMessageBubble,
        for message: BaseMessage,
        messageTypeStyle: BaseMessageBubbleStyle?,
        bubbleStyle: MessageBubbleStyle,
        isModerated: Bool = false
    ) {
        MessageUtils.buildStatusInfo(
            from: cell,
            messageTypeStyle: messageTypeStyle,
            bubbleStyle: bubbleStyle,
            message: message,
            hideReceipt: hideReceipts,
            messageAlignment: messageAlignment,
            timePattern: timePattern, dateTimeFormatter: dateTimeFormatter, isModerated: isModerated
        )
    }
    
    open func addMessageReplyPreview(forMessage: BaseMessage, toCell: CometChatMessageBubble, isLoggedInUser: Bool, specificMessageTypeStyle: BaseMessageBubbleStyle?, bubbleStyle: MessageBubbleStyle) {
        let mid = forMessage.id

        let preview = CometChatMessagePreview.makePreview(
            for: forMessage,
            isLoggedInUser: isLoggedInUser,
            textFormatters: textFormatter,                  // note singular name used in MessageList
            formattingType: .MESSAGE_BUBBLE,
            style: specificMessageTypeStyle?.messagePreviewStyle ?? bubbleStyle.messagePreviewStyle,
            onPreviewClicked: { [weak self] in
                self?.goToMessage(withId: mid)
            },
            onCrossClicked: nil,
            hideCloseButton: true                           // your code hides closeButton
        )

        toCell.set(replyView: preview)

        // you can still call layoutIfNeeded as before
        preview.setNeedsLayout()
        preview.layoutIfNeeded()
        toCell.contentView.setNeedsLayout()
        toCell.contentView.layoutIfNeeded()
    }
    
    open func addThreadedRepliesView(forMessage: BaseMessage, toCell: CometChatMessageBubble, isLoggedInUser: Bool, specificMessageTypeStyle: BaseMessageBubbleStyle?, bubbleStyle: MessageBubbleStyle) {
        if forMessage.replyCount != 0 && forMessage.deletedBy.isEmpty {
            
            let label = UILabel().withoutAutoresizingMaskConstraints()
            label.font = specificMessageTypeStyle?.threadedIndicatorTextFont ?? bubbleStyle.threadedIndicatorTextFont
            label.textColor = specificMessageTypeStyle?.threadedIndicatorTextColor ?? bubbleStyle.threadedIndicatorTextColor
            label.text = forMessage.replyCount > 1 ? "\(forMessage.replyCount)" + " " + "REPLIES_R".localize() : "ONE_REPLY".localize()
            
            let icon = UIImageView().withoutAutoresizingMaskConstraints()
            icon.pin(anchors: [.height, .width], to: 16)
            icon.contentMode = .scaleAspectFit
            icon.image = style.threadedMessageImage
            icon.tintColor = specificMessageTypeStyle?.threadedIndicatorImageTint ?? bubbleStyle.threadedIndicatorImageTint
            
            let containerView = UIView().withoutAutoresizingMaskConstraints()
            containerView.addSubview(label)
            containerView.addSubview(icon)
            
            NSLayoutConstraint.activate([
                icon.trailingAnchor.pin(equalTo: label.leadingAnchor, constant: -CometChatSpacing.Spacing.s1),
                icon.leadingAnchor.pin(equalTo: containerView.leadingAnchor, constant: CometChatSpacing.Spacing.s1),
                icon.topAnchor.pin(equalTo: containerView.topAnchor, constant: CometChatSpacing.Spacing.s1),
                icon.bottomAnchor.pin(equalTo: containerView.bottomAnchor),
                label.centerYAnchor.pin(equalTo: icon.centerYAnchor, constant: -1),
                label.trailingAnchor.pin(equalTo: containerView.trailingAnchor, constant: -CometChatSpacing.Spacing.s1)
            ])
            
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didViewRepliesTap(sender:)))
            tapGesture.numberOfTapsRequired = 1
            containerView.addGestureRecognizer(tapGesture)
            toCell.set(viewReply: containerView)
        }
    }

    
    fileprivate func registerCells() {
        tableView.register(CometChatMessageBubble.self, forCellReuseIdentifier: CometChatMessageBubble.identifier)
        tableView.register(CometChatStreamBubble.self, forCellReuseIdentifier: "CometChatStreamBubble")
        tableView.register(UnreadSeparatorCell.self, forCellReuseIdentifier: UnreadSeparatorCell.identifier)
    }
    
}

//MARK: - TABLE VIEW FUNCTIONS
extension CometChatMessageList: UITableViewDelegate, UITableViewDataSource {
    
    open func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.messages.count
    }
    
    open func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if hideDateSeparator == true { return nil }
        if let date = viewModel.messages[safe: section]?.messages.last?.sentAt {
            let dateHeader = CometChatDate().withoutAutoresizingMaskConstraints()
            dateHeader.dateTimeFormatter = dateTimeFormatter
            if let time = dateSeparatorPattern?(date) {
                dateHeader.text = time
            }
            else {
                if let datePattern = datePattern?(date){
                    let dateNow = Date(timeIntervalSince1970: Double(date))
                    dateHeader.text = dateNow.reduceTo(customFormate: datePattern)
                }else{
                    dateHeader.set(pattern: .dayDate)
                    dateHeader.set(timestamp: date)
                }
            }
            dateHeader.padding = UIEdgeInsets(top: CometChatSpacing.Padding.p1, left: CometChatSpacing.Padding.p2, bottom: CometChatSpacing.Padding.p1, right: CometChatSpacing.Padding.p2)
            dateHeader.style = dateSeparatorStyle
            
            let view = UIView()
            view.addSubview(dateHeader)
            view.backgroundColor = .clear
            view.transform = CGAffineTransform(scaleX: 1, y: -1)
            dateHeader.pin(anchors: [.centerX, .centerY], to: view)
            
            return view
        }
        return nil
    }
    
    open func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let filteredMessages = viewModel.messages[safe: section]?.messages.filter { message in
            !(hideGroupActionMessages && message.messageCategory == .action && message.receiverType == .group)
        }
        
        var messagesCount = filteredMessages?.count ?? 0
        
        if let unreadId = unreadSeparatorMessageId,
           filteredMessages?.contains(where: { $0.id == unreadId }) ?? false {
            messagesCount += 1
        }
        
        return messagesCount
    }

    /// Returns `true` only when the table view's currently-known section and row
    /// counts exactly match what the data source would report right now.
    ///
    /// `beginUpdates()/endUpdates()` (used for height-only re-measurement, e.g. while
    /// an AI message streams in) re-queries the data source and crashes with
    /// "invalid number of rows in section" if the counts have drifted since the last
    /// reload — which happens when a message arrives or the unread separator toggles
    /// mid-stream. Callers use this guard to fall back to `reloadData()` on drift.
    open func isTableViewConsistentWithDataSource() -> Bool {
        let knownSections = tableView.numberOfSections
        guard knownSections == numberOfSections(in: tableView) else { return false }
        for section in 0..<knownSections {
            if tableView.numberOfRows(inSection: section)
                != self.tableView(tableView, numberOfRowsInSection: section) {
                return false
            }
        }
        return true
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let filteredMessages = viewModel.messages[safe: indexPath.section]?.messages.filter({ message in
                !(hideGroupActionMessages && message.messageCategory == .action && message.receiverType == .group)
            }) else {
                return UITableViewCell()
            }
        
        // Check if we need to show separator in this section
        if let unreadId = unreadSeparatorMessageId,
           let markedIndex = filteredMessages.firstIndex(where: { $0.id == unreadId }) {

            let separatorIndex: Int

            switch unreadSeparatorMode {
            case .markAsUnread:
                separatorIndex = markedIndex + 1

            case .navigateFromConversation:
                separatorIndex = markedIndex

            case .none:
                separatorIndex = markedIndex + 1
            }

            if indexPath.row == separatorIndex {
                let cell = tableView.dequeueReusableCell(
                    withIdentifier: UnreadSeparatorCell.identifier,
                    for: indexPath
                ) as! UnreadSeparatorCell
                
                if let customUnreadView = newMessageIndicatorCustomView{
                    cell.setCustomView(customUnreadView)
                }
                cell.setStyle(style)
                cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
            }

            let adjustedRow = indexPath.row > separatorIndex
                ? indexPath.row - 1
                : indexPath.row

            guard let message = filteredMessages[safe: adjustedRow] else {
                return UITableViewCell()
            }

            return createMessageCell(
                for: message,
                at: indexPath,
                in: tableView,
                filteredMessages: filteredMessages
            )
        }
        
        // No separator - use original indexing
        guard let message = filteredMessages[safe: indexPath.row] else {
            return UITableViewCell()
        }
        
        // Continue with normal message cell creation
        return createMessageCell(for: message, at: indexPath, in: tableView, filteredMessages: filteredMessages)
    }
    
    /// Reconstructs a quoted `BaseMessage` from a raw `quotedMessage` payload for cases where
    /// the SDK doesn't populate `message.quotedMessage` (e.g. agentic AI replies, developer
    /// cards). Dispatches to the appropriate public `fromJSON` parser by category/type, falling
    /// back to a text parse so a preview still renders. Returns nil if it can't be parsed.
    private func resolveQuotedMessage(from raw: [String: Any]) -> BaseMessage? {
        let category = raw["category"] as? String
        let type = raw["type"] as? String

        switch category {
        case MessageCategoryConstants.message:
            switch type {
            case MessageTypeConstants.image, MessageTypeConstants.video,
                 MessageTypeConstants.audio, MessageTypeConstants.file:
                return MediaMessage.mediaMessage(fromJSON: raw).0
            default:
                return TextMessage.textMessage(fromJSON: raw).0
            }
        case MessageCategoryConstants.custom:
            return CustomMessage.customMessage(fromJSON: raw).0
        case MessageCategoryConstants.action:
            return ActionMessage.actionMessage(fromJSON: raw).0
        default:
            // interactive / agentic / card / unknown → best-effort text preview
            return TextMessage.textMessage(fromJSON: raw).0
        }
    }

    private func createMessageCell(for message: BaseMessage, at indexPath: IndexPath, in tableView: UITableView, filteredMessages: [BaseMessage]) -> UITableViewCell {
        let isLoggedInUser = LoggedInUserInformation.isLoggedInUser(uid: message.senderUid)
        var bubbleStyle = isLoggedInUser ? messageBubbleStyle.outgoing : messageBubbleStyle.incoming
        let messageTypeStyle = MessageUtils.getSpecificMessageTypeStyle(message: message, from: messageBubbleStyle)
        
        if let isPlaceholder = message.metaData?["__streaming_placeholder__"] as? Bool,
           let message = message as? StreamMessage,
           let runId = message.metaData?["runId"] as? Int {
            
            if isPlaceholder {
                let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatStreamBubble", for: indexPath) as! CometChatStreamBubble
                cell.runId = runId
                cell.messageObj = message
                cell.avatarView.setAvatar(avatarUrl: viewModel.user?.avatar, with: viewModel.user?.name)
                
                cell.updateUI = { [weak self, weak tableView] in
                    guard
                        let tableView = tableView,
                        tableView.window != nil,
                        tableView.dataSource != nil
                    else { return }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                        guard
                            let this = self,
                            tableView.window != nil,
                            tableView.dataSource != nil
                        else { return }

                        // beginUpdates/endUpdates re-queries numberOfRowsInSection for
                        // every section but reports zero inserts/deletes. If a message
                        // arrived (or the unread separator toggled) since the last reload,
                        // the data-source count will have drifted from the table's cached
                        // count and UIKit throws "invalid number of rows in section". Only
                        // run the height-only update when the table is still in sync;
                        // otherwise fall back to reloadData(), which is always safe.
                        guard this.isTableViewConsistentWithDataSource() else {
                            tableView.reloadData()
                            return
                        }

                        UIView.performWithoutAnimation {
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                    }
                }
                
                cell.runId = runId
                if let showThinking = message.metaData?["__show_thinking__"] as? Bool, showThinking {
                    cell.showThinking()
                } else {
                    cell.completeStreaming(finalText: message.text)
                }
                
                cell.bindToRun(runId: runId)
                cell.contentView.transform = CGAffineTransform(scaleX: 1, y: -1)
                return cell
                
            }
        }
        
        if let template = viewModel.getTemplate(for: message) {
            if let cell = tableView.dequeueReusableCell(withIdentifier: CometChatMessageBubble.identifier , for: indexPath) as? CometChatMessageBubble {
                let isModerated = MessageUtils.isMessageModerationDisapproved(message: message)
                
                cell.transform = CGAffineTransform(scaleX: 1, y: -1) // doing this because our tableView is also transformed
                cell.set(message: message)
                cell.set(replyView: nil)   

                if let user = viewModel.user, user.isAgentic, !isLoggedInUser{
                    bubbleStyle.backgroundColor = .clear
                }
                
                // Apply optional agent bubble background for group AI agent messages
                if message.receiverType == .group,
                   let sender = message.sender, sender.isAgent, !isLoggedInUser {
                    if let agentBg = AgentUIConfiguration.shared.agentBubbleBackgroundColor {
                        bubbleStyle.backgroundColor = agentBg
                    }
                }
                
                // Disable swipe-to-reply for incoming agent messages — agent responses should
                // not be replyable via swipe (ENG-36638). Covers 1:1 agentic chats and group AI
                // agents; the logged-in user's own messages stay swipeable.
                let isIncomingAgentMessage = !isLoggedInUser &&
                    (message.messageCategory == .agentic
                     || (message.sender?.isAnyAgent ?? false)
                     || (viewModel.user?.isAgentic ?? false))
                cell.disableSwipeToReply = disableSwipeToReply || isIncomingAgentMessage
                cell.set(style: bubbleStyle, specificMessageTypeStyle: messageTypeStyle)
                
                // Overriding whole bubble
                if let bubbleView = template.bubbleView?(message, cell.alignment, controller) {
                    cell.set(bubbleView: bubbleView)
                    return cell
                }
                
                cell.onSwipeReplyDetected { message in
                    guard let message = message else { return }
                    CometChatMessageEvents.ccReplyToMessage(message: message, status: .inProgress)
                }
                
                // Handle quoted / reply view
                // Workaround: the SDK does not populate `quotedMessage` for some message
                // categories (e.g. agentic AI replies, developer cards), even though the raw
                // payload carries it. Reconstruct it from `rawMessage` so the reply preview
                // renders. Only runs when `quotedMessage` is nil, so normal messages are
                // unaffected; the parsed value is cached on the message so it parses once.
                if message.quotedMessage == nil,
                   let rawQuoted = message.rawMessage?["quotedMessage"] as? [String: Any] {
                    message.quotedMessage = resolveQuotedMessage(from: rawQuoted)
                }

                if let quotedMessage = message.quotedMessage, message.deletedAt <= 0, !isModerated{
                    if let customReplyView = template.replyView?(message, cell.alignment, controller) {
                        cell.set(replyView: customReplyView)
                    } else if !hideReplyMessageOption{
                        addMessageReplyPreview(forMessage: quotedMessage, toCell: cell, isLoggedInUser: isLoggedInUser, specificMessageTypeStyle: messageTypeStyle, bubbleStyle: bubbleStyle)
                    }
                } else {
                    // No quoted message
                    cell.set(replyView: nil)
                }

                cell.setupSwipeGestures(message: message)
                // For action messages
                if message.messageCategory == .action || message.messageCategory == .call {
                    cell.set(bubbleAlignment: .center)
                    // Clear bottomView to prevent reused cell from showing previous message's moderation view
                    cell.set(bottomView: nil)
                    if let contentView = template.contentView?(message, cell.alignment, controller) {
                        cell.set(contentView: contentView)
                        cell.set(backgroundColor: .clear)
                        if message.messageCategory == .action {
                            cell.set(actionStyle: actionBubbleStyle)
                        } else {
                            cell.set(callActionStyle: callActionBubbleStyle)
                        }
                    }
                    cell.onLongPressGestureRecognized = nil
                    return cell
                }
                
                switch messageAlignment {
                case .standard:
                    if isLoggedInUser {
                        cell.set(bubbleAlignment: .right)
                    } else {
                        cell.set(bubbleAlignment: .left)
                    }
                case .leftAligned:
                    cell.set(bubbleAlignment: .left)
                }
                
                if let headerView = template.headerView?(message, cell.alignment, controller) {
                    cell.set(headerView: headerView)
                } else {
                    if !hideBubbleHeader {
                        let nameLabel = UILabel()
                        nameLabel.numberOfLines = 1
                        nameLabel.text = isLoggedInUser ? "YOU".localize() : message.sender?.name ?? ""
                        nameLabel.font = messageTypeStyle?.headerTextFont ?? bubbleStyle.headerTextFont
                        nameLabel.textColor = messageTypeStyle?.headerTextColor ?? bubbleStyle.headerTextColor
                        
                        // Add agent badge next to the sender name if sender is an AI agent
                        if let sender = message.sender, sender.isAgent, !isLoggedInUser {
                            let headerStack = UIStackView()
                            headerStack.axis = .horizontal
                            headerStack.alignment = .center
                            headerStack.spacing = CometChatSpacing.Spacing.s1
                            headerStack.addArrangedSubview(nameLabel)
                            
                            let agentBadge = CometChatAgentBadge()
                            agentBadge.style = AgentUIConfiguration.shared.agentBadgeStyle
                            headerStack.addArrangedSubview(agentBadge)
                            
                            cell.set(headerView: headerStack)
                        } else {
                            cell.set(headerView: nameLabel)
                        }
                    }
                }
                
                if let contentView = template.contentView?(message, cell.alignment, controller) {
                    cell.set(contentView: contentView)
                }
                

                cell.set(bottomView: nil)

                if isModerated && !hideModerationStatus && message.deletedAt <= 0 {
                    addModerationView(on: cell, message: message, bubbleStyle: messageBubbleStyle.outgoing)
                } else if let bottomView = template.bottomView?(message, cell.alignment, controller) {
                    cell.set(bottomView: bottomView)
                }
                
                // Adding date and read receipt
                if let statusInfoView = template.statusInfoView?(message, cell.alignment, controller) {
                    cell.set(statusInfoView: statusInfoView)
                } else {
                    if let user = viewModel.user, user.isAgentic && cell.alignment == .left{
                        addAIActionBarView(on: cell, message: message)
                    }else{
                        buildMessageFooterView(on: cell, for: message, messageTypeStyle: messageTypeStyle, bubbleStyle: bubbleStyle, isModerated: isModerated)
                    }
                }
                
                let isErrorMessage = message.metaData?["error"] as? Bool == true
                
                if let footerView = template.footerView?(message, cell.alignment, controller) {
                    cell.set(footerView: footerView)
                } else {
                    if message.deletedAt == 0 && !isModerated && !isErrorMessage {
                        buildReactionsView(
                            forMessage: message,
                            cell: cell,
                            alignment: (messageAlignment == .leftAligned ? .left : (isLoggedInUser ? .right : .left)),
                            reactionStlye: messageTypeStyle?.reactionsStyle ?? bubbleStyle.reactionsStyle, template: template
                        )
                    }
                }
                
                if message.deletedAt == 0 && !isModerated && !isErrorMessage {
                    if let user = viewModel.user, user.isAgentic{
                        
                    }else{
                        addThreadedRepliesView(forMessage: message, toCell: cell, isLoggedInUser: isLoggedInUser, specificMessageTypeStyle: messageTypeStyle, bubbleStyle: bubbleStyle)
                    }
                }
                
                // Setting up avatar view
                if let user = message.sender {
                    cell.set(avatarURL: user.avatar, avatarName: user.name)
                    
                    // Setting header view
                    switch message.receiverType {
                    case .user:
                        cell.hide(headerView: true)
                        if cell.alignment == .left {
                            if let hideAvatar = hideAvatar{
                                cell.hide(avatar: hideAvatar)
                            }else{
                                if let user = viewModel.user, user.isAgentic {
                                    cell.hide(avatar: false)
                                }else{
                                    cell.hide(avatar: true)
                                }
                            }
                        }
                    case .group:
                        if cell.alignment == .left {
                            cell.hide(avatar: hideAvatar ?? false)
                            cell.hide(headerView: false)
                        } else {
                            cell.hide(headerView: true)
                        }
                    @unknown default:
                        break
                    }
                }
                
                if message.id > 0 &&  viewModel.user?.isAgentic != true{
                    // Setting up context menu
                    setupContextMenu(for: cell, message: message)
                } else {
                    // Clear long press handler for messages with id <= 0 (including error messages)
                    // This is needed because cells are reused and might have a handler from a previous message
                    cell.onLongPressGestureRecognized = nil
                }
                
                // Also clear long press for RBAC error messages regardless of message id
                // Only apply to actual messages, not action messages (like "user added to group")
                let isRBACError = message.metaData?["rbac_permission_denied"] as? Bool == true && message.messageCategory == .message
                let isError = message.metaData?["error"] as? Bool == true && message.messageCategory == .message
                if isRBACError || isError {
                    cell.onLongPressGestureRecognized = nil
                }
                
                return cell
            }
        } else {
            // Building not supported bubble
            if let cell = tableView.dequeueReusableCell(withIdentifier: CometChatMessageBubble.identifier , for: indexPath) as? CometChatMessageBubble {
                
                //doing this because our tableView is also transformed
                cell.transform = CGAffineTransform(scaleX: 1, y: -1)
                
                //Setting message alignment
                switch messageAlignment {
                case .standard:
                    if isLoggedInUser {
                        cell.set(bubbleAlignment: .right)
                        cell.set(style: bubbleStyle, specificMessageTypeStyle: messageBubbleStyle.outgoing.deleteBubbleStyle)
                    } else {
                        cell.set(bubbleAlignment: .left)
                        cell.set(style: bubbleStyle, specificMessageTypeStyle: messageBubbleStyle.incoming.deleteBubbleStyle)
                    }
                case .leftAligned:
                    cell.set(bubbleAlignment: .left)
                }
                
                //Setting up header
                if !hideBubbleHeader {
                    let nameLabel = UILabel()
                    nameLabel.numberOfLines = 1
                    nameLabel.text = isLoggedInUser ? "YOU".localize() : message.sender?.name ?? ""
                    nameLabel.font = messageTypeStyle?.headerTextFont ?? bubbleStyle.headerTextFont
                    nameLabel.textColor = messageTypeStyle?.headerTextColor ?? bubbleStyle.headerTextColor
                    
                    cell.set(headerView: nameLabel)
                }

                //Setting up footer view
                buildMessageFooterView(on: cell, for: message, messageTypeStyle: messageTypeStyle, bubbleStyle: bubbleStyle)
                
                //setting up avatar view
                if let user = message.sender {
                    cell.set(avatarURL: user.avatar, avatarName: user.name)
                    
                    //setting header View
                    switch message.receiverType {
                    case .user:
                        cell.hide(headerView: true)
                        if cell.alignment == .left {
                            cell.hide(avatar: hideAvatar ?? true)
                        }
                    case .group:
                        if cell.alignment == .left {
                            cell.hide(avatar: hideAvatar ?? false)
                            cell.hide(headerView: false)
                        } else {
                            cell.hide(headerView: true)
                        }
                    @unknown default:
                        break
                    }
                }
                
                let noSupportedBubble = CometChatDeleteBubble()
                noSupportedBubble.messageText = "MESSAGE_TYPE_NOT_SUPPORTED".localize()
                cell.set(contentView: noSupportedBubble)
                return cell
            }
        }
        
        return UITableViewCell()
    }

    
    public  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// For inverted table: section 0, row 0 is visual BOTTOM.
    /// We consider "near bottom" when any of rows 0...4 of section 0 are visible.
    private func isNearBottomForNextPagination() -> Bool {
        guard let visible = tableView.indexPathsForVisibleRows else { return false }

        // Look only at section 0 (newest side)
        let minRowInFirstSection = visible
            .filter { $0.section == 0 }
            .map { $0.row }
            .min()

        if let minRow = minRowInFirstSection {
            // If row 0..4 is visible, we are near visual bottom -> fetch NEXT
            return minRow <= 30
        }
        return false
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // Only prevent overscroll if alwaysBounceVertical is false
        if !tableView.alwaysBounceVertical && scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.height
        
        let delta = offsetY - lastContentOffset
        let isScrollingUp = delta > deltaThreshold  // scrolling up (towards older messages)
        let isScrollingDown = delta < -deltaThreshold  // scrolling down (towards newer messages)
        
//        if (scrollView.isDragging || scrollView.isDecelerating) && offsetY > lastContentOffset && offsetY >= 400 {
//            self.messageIndicator?.isHidden = false
//        }
        
        if isScrollingUp,
           !viewModel.isAllMessagesFetchedInPrevious,
           offsetY + visibleHeight >= (contentHeight * 0.70),
           !viewModel.isUIUpdating {
            showTopSpinner()
            viewModel.fetchPreviousMessages()
        }
        
        if isScrollingDown,
           !viewModel.isAllMessagesFetchedInNext,
           offsetY <= 80,
           !viewModel.isFetchingNext {
            
            // Capture the current scroll position before fetching new data
            oldContentHeight = tableView.contentSize.height
            oldContentOffset = tableView.contentOffset
            oldDistanceFromTop = oldContentOffset.y
            
            viewModel.fetchNextMessagesForPagination()
        }
        
        let shouldHide = shouldHideMessageIndicator(
            scrollView: scrollView,
            offsetY: offsetY
        )

        let isAtBottom = offsetY <= 80
        
        if shouldHide || isAtBottom {
            messageIndicator?.reset()
            messageIndicator?.isHidden = true
        } else {
            if unreadMessageCount > 0 && unreadSeparatorMode != .navigateFromConversation {
                messageIndicator?.setUnreadCount(count: unreadMessageCount)
            } else {
                messageIndicator?.reset()
            }
            messageIndicator?.isHidden = false
        }

        
        lastContentOffset = offsetY
    }

    func indexPathForMessageWithId(_ anchorId: Int) -> IndexPath? {
        // Find the message with the anchorId in the data source
        for (sectionIndex, section) in viewModel.messages.enumerated() {
            for (rowIndex, message) in section.messages.enumerated() {
                if message.id == anchorId {
                    return IndexPath(row: rowIndex, section: sectionIndex)
                }
            }
        }
        return nil  // Return nil if not found
    }

    private func shouldHideMessageIndicator(
        scrollView: UIScrollView,
        offsetY: CGFloat
    ) -> Bool {

        // 1. Always hide if scroll-to-bottom was tapped (until user scrolls up)
        if isScrollToBottomTapped {
            let isAtBottom = offsetY <= 80
            if isAtBottom {
                return true
            } else {
                // User scrolled up, reset the flag
                isScrollToBottomTapped = false
            }
        }

        // 2. Never hide during unread navigation
        if startFromUnreadMessages {
            return false
        }

        // 3. Never hide during gotoMessage jump
        if gotoMessageId > 0 {
            return false
        }

        // 4. Never hide during restoration
        if scrollRestored {
            return false
        }

        // 5. Hide when at bottom (regardless of pagination state)
        let isAtBottom = offsetY <= 80
        
        if isAtBottom {
            return true
        }

        return false
    }

    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {

    }
    
    open func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return hideDateSeparator == false ? 40 : 0
    }
    
    public  func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    open func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {}
    
    open func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {}
    
    open func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return nil
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) { }
    
    public func shouldLoadMoreData(scrollView: UIScrollView) -> Bool {
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.size.height
        let offsetY = scrollView.contentOffset.y
        
        // Calculate the threshold for 65% of the content height
        let threshold = contentHeight * 0.70
        
        // Check if the user has scrolled 60% or more of the content
        return offsetY + visibleHeight >= threshold
    }
    
    func visibleIndexPath(forMessageId id: Int) -> IndexPath? {
        for (sectionIndex, sectionTuple) in viewModel.messages.enumerated() {

            if let rowIndex = sectionTuple.messages.firstIndex(where: { $0.id == id }) {
                return IndexPath(row: rowIndex, section: sectionIndex)
            }
        }
        return nil
    }

 /// Returns the table-view IndexPath for a given message ID, accounting for:
 /// 1. hideGroupActionMessages filtering (action messages removed from display)
 /// 2. Unread separator row insertion (+1 offset for messages after separator)
 /// Use this instead of viewModel.indexPathForMessageId when passing to UIKit table-view APIs.
    func tableViewIndexPath(forMessageId id: Int) -> IndexPath? {
        for (sectionIndex, sectionTuple) in viewModel.messages.enumerated() {
            // Apply the same filter as cellForRowAt
            let filteredMessages = sectionTuple.messages.filter { message in
                !(hideGroupActionMessages && message.messageCategory == .action && message.receiverType == .group)
            }
            guard let filteredRow = filteredMessages.firstIndex(where: { $0.id == id }) else {
                continue
            }
            // Account for unread separator offset
            var adjustedRow = filteredRow
            if let unreadId = unreadSeparatorMessageId,
               let markedIndex = filteredMessages.firstIndex(where: { $0.id == unreadId }) {
                let separatorIndex: Int
                switch unreadSeparatorMode {
                case .markAsUnread:
                    separatorIndex = markedIndex + 1
                case .navigateFromConversation:
                    separatorIndex = markedIndex
                case .none:
                    separatorIndex = markedIndex + 1
                }
                // If the target row is at or after the separator position, shift by +1
                if filteredRow >= separatorIndex {
                    adjustedRow = filteredRow + 1
                }
            }
            return IndexPath(row: adjustedRow, section: sectionIndex)
        }
        return nil
    }
    
}

//Exposing Scroll Events
extension CometChatMessageList {
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {  }
    
    // called on start of dragging (may require some time and or distance to move)
    open func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastContentOffset = scrollView.contentOffset.y
    }
    
    // called on finger up if the user dragged. velocity is in points/millisecond. targetContentOffset may be changed to adjust where the scroll view comes to rest
    open func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) { }
    
    // called on finger up if the user dragged. decelerate is true if it will continue moving afterwards
    open func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) { }
    
    // called when scroll view grinds to a halt
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {}

    // called when setContentOffset/scrollRectVisible:animated: finishes. not called if not animating
    open func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {}

    // return a view that will be scaled. if delegate returns nil, nothing happens
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? { return nil }

    // called before the scroll view begins zooming its content
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {}

    // scale between minimum and maximum. called after any 'bounce' animations
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {}

    // return a yes if you want to scroll to the top. if not defined, assumes YES
    open func scrollViewShouldScrollToTop(_ scrollView: UIScrollView) -> Bool { return true }

    // called when scrolling animation finished. may be called immediately if already at top
    open func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {}
    
    /* Also see -[UIScrollView adjustedContentInsetDidChange]
     */
    open func scrollViewDidChangeAdjustedContentInset(_ scrollView: UIScrollView) {}
}


extension CometChatMessageList {
    
    internal func configureMessageInformation(configuration: MessageInformationConfiguration, messageInformation: CometChatMessageInformation) {
        //TODO: FIX THIS
    }
    
    @objc func didViewRepliesTap(sender: UITapGestureRecognizer) {
        controller?.view.endEditing(true)
        guard let indexPath = self.tableView.indexPathForRow(at: sender.location(in: self.tableView)), let message = viewModel.messages[safe: indexPath.section]?.messages[safe: indexPath.row], let template = viewModel.getTemplate(for: message) else {
            print("Error: indexPath)")
            return
        }
        self.onThreadRepliesClick?(message, template)
    }
}

//MARK: Message Options
extension CometChatMessageList: CometChatMessageOptionDelegate {
    
    func onItemClick(messageOption: CometChatMessageOption, forMessage: BaseMessage?, indexPath: IndexPath?) {
        if let message = forMessage {
            switch messageOption.id {
            case MessageOptionConstants.markMessageAsUnread:
                viewModel.markMessageAsUnread(message, completion: { conversation in
                    DispatchQueue.main.async { [weak self] in
                        self?.unreadSeparatorMessageId = message.id
                        self?.unreadSeparatorMode = .markAsUnread
                        self?.unreadMessageCount = conversation.unreadMessageCount
                        if conversation.unreadMessageCount > 0{
                            self?.messageIndicator?.setUnreadCount(count: conversation.unreadMessageCount)
                        }
                        print("message marked as unread is \(message.id)")
                        
                        self?.reload()
                    }
                }, failure: {
                    DispatchQueue.main.async {
                        self.controller?.showAlert(message: "Something went wrong. Please try again later.")
                    }
                })
            case MessageOptionConstants.replyMessage :
                if messageOption.onItemClick == nil {
                    CometChatMessageEvents.ccReplyToMessage(message: message, status: .inProgress)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.editMessage :
                if messageOption.onItemClick == nil {
                    if let forMessage = forMessage {
                        CometChatMessageEvents.ccMessageEdited(message: forMessage, status: .inProgress)
                    }
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.reportMessage :
                let vc = CometChatFlagMessage()
                vc.modalPresentationStyle = .overFullScreen
                vc.messageId = forMessage?.id
                vc.flagReasonLocalizer = flagReasonLocalizer
                vc.hideFlagRemarkFeild = hideFlagRemarkFeild
                controller?.present(vc, animated: false)

            case MessageOptionConstants.deleteMessage :
                if messageOption.onItemClick == nil {
                    
                    // Presenting Delete message action
                    let actionSheetController: UIAlertController = UIAlertController(title: nil, message: "DELETE_MESSAGE_SUBTITLE".localize(), preferredStyle: .alert)
                    
                    // create an action
                    let firstAction: UIAlertAction = UIAlertAction(title: ConversationConstants.delete, style: .destructive) { [weak self] action -> Void in
                        DispatchQueue.main.async {
                            guard let strongSelf = self else { return }
                            strongSelf.delete(message: message)
                        }
                    }
                    
                    let cancelAction: UIAlertAction = UIAlertAction(title: ConversationConstants.cancel, style: .cancel) { action -> Void in }
                    actionSheetController.addAction(firstAction)
                    actionSheetController.addAction(cancelAction)
                    controller?.present(actionSheetController, animated: true)
                    
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.shareMessage :
                if messageOption.onItemClick == nil {
                    didMessageSharePressed(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.copyMessage :
                if messageOption.onItemClick == nil {
                    didCopyPressed(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.messagePrivately :
                if messageOption.onItemClick == nil {
                    if let user = message.sender {
                        DispatchQueue.main.async {
                            CometChatUIEvents.openChat(user: user, group: nil)
                        }
                    }
                    
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            case MessageOptionConstants.forwardMessage: break
            case MessageOptionConstants.replyInThread :
                if let baseMessage = forMessage, let template = viewModel.getTemplate(for: message) {
                    self.onThreadRepliesClick?(baseMessage, template)
                }
            case MessageOptionConstants.messageInformation :
                if messageOption.onItemClick == nil {
                    didMessageInformationClicked(message: message)
                } else {
                    if let forMessage = forMessage {
                        messageOption.onItemClick?(forMessage)
                    }
                }
            default:
                if let forMessage = forMessage {
                    messageOption.onItemClick?(forMessage)
                }
            }
        }
    }
    
    private func didCopyPressed(message: BaseMessage?) {
        if let message = message as? TextMessage {
            let textFormatter = viewModel.textFormatters
            let formattedText = MessageUtils.processTextFormatter(message: message, textFormatter: textFormatter, formattingType: .MESSAGE_BUBBLE)
            UIPasteboard.general.string = formattedText.string
        }
    }
    
    private func didMessageSharePressed(message: BaseMessage?) {
        if let message = message {
            if message.messageType == .text {
                
                if let message = (message as? TextMessage) {
                    let textFormatter = viewModel.textFormatters
                    let formattedText = MessageUtils.processTextFormatter(message: message, textFormatter: textFormatter, formattingType: .MESSAGE_BUBBLE)
                    copyMedia(formattedText.string)
                }
                
            } else if message.messageType == .audio ||  message.messageType == .file ||  message.messageType == .image || message.messageType == .video {
                
                if let fileUrlString = (message as? MediaMessage)?.attachment?.fileUrl, let fileUrl = URL(string: fileUrlString) {
                    downloadMediaMessage(url: fileUrl, completion: { [weak self] fileLocation in
                        guard let this = self else { return }
                        if let fileLocation = fileLocation {
                            this.copyMedia(fileLocation)
                        }
                    })
                }
            }
        }
    }
    
    func copyMedia(_ item: Any) {
        DispatchQueue.main.async { [weak self] in
            guard let this = self else { return }
            let activityViewController = UIActivityViewController(activityItems: [item], applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = this
            activityViewController.excludedActivityTypes = [.airDrop]
            this.controller?.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    func downloadMediaMessage(url: URL, completion: @escaping (_ fileLocation: URL?) -> Void){
        
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(destinationUrl)
        } else {
            URLSession.shared.downloadTask(with: url, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(destinationUrl)
                } catch _ as NSError {
                    completion(nil)
                }
            }).resume()
        }
    }
}

//Keyboard Management
extension CometChatMessageList {
    func addKeyboardDismissGesture() {
        self.addGestureRecognizer(onTapGesture)
    }
    
    @objc func dismissKeyboard() {
        self.endEditing(true)
        controller?.view.endEditing(true)
    }
    
    func removeKeyboardDismissGesture() {
        self.removeGestureRecognizer(onTapGesture)
    }

    func performAfterNextLayout(_ block: @escaping () -> Void) {
        DispatchQueue.main.async {
            self.tableView.layoutIfNeeded()   // Finish current layout
            DispatchQueue.main.async {        // Wait for next runloop
                self.tableView.layoutIfNeeded()
                block()
            }
        }
    }

}
