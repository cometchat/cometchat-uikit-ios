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
            
            if viewModel.user?.isAgentic ?? false{
                hideDateSeparator = true
                viewModel.streamingSpeed = streamingSpeed
                if viewModel.parentMessage != nil && viewModel.parentMessage?.id ?? 0 > 0{
                    fetchData()
                } else if viewModel.threadedPArentMessageId > 0{
                    if viewModel.hasFetchedMessagesBefore {
                        fetchData()
                    }
                } else{
                    buildAgenticView()
                }
                
                
            }else{
                if !viewModel.hasFetchedMessagesBefore {
                    fetchData()
                }
            }
            setupStyle()
        }else{
            smartRepliesWorkItem?.cancel()
            smartRepliesWorkItem = nil
        }
    }
    
    deinit {
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
        if viewModel.messages.isEmpty {
            showLoadingView()
        }

        if gotoMessageId != 0 {
            self.goToMessage(withId: gotoMessageId)
        } else {
            viewModel.fetchPreviousMessages()
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
        gotoMessageId = 0
        if let user = viewModel.user, !user.isAgentic {
            viewModel.set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder()
                .set(uid: user.uid ?? "")
                .hideReplies(hide: true)
                .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
                .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])
                .set(messageID: -1))
        } else if let group = viewModel.group {
            viewModel.set(messagesRequestBuilder: MessagesRequest.MessageRequestBuilder()
                .set(guid: group.guid)
                .hideReplies(hide: true)
                .set(types: ChatConfigurator.getDataSource().getAllMessageTypes() ?? [])
                .set(categories: ChatConfigurator.getDataSource().getAllMessageCategories() ?? [])
                .set(messageID: -1))
        }
        fetchData()
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
            tableView.beginUpdates()
            ActivityIndicator.activityIndicator.frame = .zero
            tableView.endUpdates()
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
            guard let this = self else { return }
            
            this.oldContentHeight = this.tableView.contentSize.height
            
            this.newHeight = this.tableView.contentSize.height
            this.scrollToMessage(withId: id, isPagination: isPagination) { anchorId in
                                
                DispatchQueue.main.async {
                    if let indexPath = self?.indexPathForMessageWithId(anchorId) {
                        let rectForAnchor = self?.tableView.rectForRow(at: indexPath)
                        let targetOffsetY = (rectForAnchor?.origin.y ?? 0) - (self?.oldDistanceFromTop ?? 0)
                        self?.tableView.setContentOffset(CGPoint(x: 0, y: targetOffsetY), animated: false)
                    }
                    
                    print("after fetch next height: \(self?.tableView.contentOffset.y ?? 0), \(self?.tableView.contentSize.height ?? 0)")
                    
                    self?.hideBottomSpinner()
                    self?.tableView.isScrollEnabled = true
                }
            }
        }
        
        viewModel.reload = { [weak self]  in
            guard let this = self else { return }
            DispatchQueue.main.async {
                this.removeLoadingView()
                this.reload()
                                
                if this.viewModel.messages.isEmpty {
                    if let onEmpty = this.onEmpty?(){
                        onEmpty
                    }
                   if !this.hideEmptyView{
                       if let user = this.viewModel.user, user.isAgentic{
                           this.showAIView()
                       }
                        this.showEmptyView()
                    }
                } else {
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
        
        viewModel.appendAtIndex = { [weak self] section , row, message, isNewSectionAdded in
            DispatchQueue.main.async {
                guard let this = self else { return }
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
                
                // Calculate the actual row index after filtering
                var actualRow = row
                guard let messages = this.viewModel.messages[safe: section]?.messages else {
                    this.tableView.reloadData()
                    this.removeEmptyView()
                    this.removeErrorView()
                    return
                }
                
                let filteredMessages = messages.filter { msg in
                    !(this.hideGroupActionMessages && msg.messageCategory == .action && msg.receiverType == .group)
                }
                
                if let messageIndex = filteredMessages.firstIndex(where: { $0.muid == message.muid }) {
                    actualRow = messageIndex
                } else {
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
                        this.messageIndicator?.incrementCount()
                        this.messageIndicator?.isHidden = false
                    } else {
                        shouldScrollToBottom = true
                    }
                }
                
                this.viewModel.removeMarkedFailedStreamMessages()
                
                // VALIDATION: Check current state
                let currentSectionCount = this.tableView.numberOfSections
                let currentRowCount = section < currentSectionCount ? this.tableView.numberOfRows(inSection: section) : 0
                let expectedRowCountAfterInsert = isNewSectionAdded ? filteredMessages.count : currentRowCount + 1
                
                // If data source doesn't match expectations, reload
                if filteredMessages.count != expectedRowCountAfterInsert {
                    this.tableView.reloadData()
                    this.removeEmptyView()
                    this.removeErrorView()
                    if shouldScrollToBottom {
                        this.scrollToBottom()
                    }
                    return
                }
                
                // Validate section exists or should be created
                if isNewSectionAdded && section < currentSectionCount {
                    // Section already exists, reload instead
                    this.tableView.reloadData()
                    this.removeEmptyView()
                    this.removeErrorView()
                    if shouldScrollToBottom {
                        this.scrollToBottom()
                    }
                    return
                }
                
                if !isNewSectionAdded && section >= currentSectionCount {
                    // Section doesn't exist, reload instead
                    this.tableView.reloadData()
                    this.removeEmptyView()
                    this.removeErrorView()
                    if shouldScrollToBottom {
                        this.scrollToBottom()
                    }
                    return
                }
                
                // Final validation right before batch update
                let recheckSectionCount = this.tableView.numberOfSections
                let recheckRowCount = section < recheckSectionCount ? this.tableView.numberOfRows(inSection: section) : 0
                
                // Double-check consistency one more time
                let isStillConsistent = isNewSectionAdded ?
                    (section == recheckSectionCount && recheckRowCount == 0) :
                    (section < recheckSectionCount && filteredMessages.count == recheckRowCount + 1)
                
                guard isStillConsistent else {
                    this.tableView.reloadData()
                    this.removeEmptyView()
                    this.removeErrorView()
                    if shouldScrollToBottom {
                        this.scrollToBottom()
                    }
                    return
                }
                
                // Safe to perform batch update
                this.tableView.performBatchUpdates({
                    if isNewSectionAdded {
                        this.tableView.insertSections([section], with: .top)
                    }
                    this.tableView.insertRows(at: [IndexPath(row: actualRow, section: section)], with: .top)
                }, completion: { success in
                    if !success {
                        // Defer a reload to fix any inconsistency
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            this.tableView.reloadData()
                        }
                    }
                    
                    // Removing error/empty view if presented
                    this.removeEmptyView()
                    this.removeErrorView()
                    
                    if !wasNextPagination && shouldScrollToBottom {
                        this.scrollToBottom()
                    }
                })
            }
        }
        
        viewModel.deleteBatch = { [weak self] deletions, emptySections in
            guard let self = self else { return }
            let table = self.tableView
            
            // Ensure we're on the main thread
            DispatchQueue.main.async {
                // Validate table view state before performing updates
                let currentSections = table.numberOfSections
                
                // Filter out invalid deletions
                let validDeletions = deletions.filter { section, row, msg in
                    guard section < currentSections else {
                        return false
                    }
                    let rowsInSection = table.numberOfRows(inSection: section)
                    guard row < rowsInSection else {
                        return false
                    }
                    return true
                }
                
                // Filter out invalid empty sections
                let validEmptySections = emptySections.filter { section in
                    guard section < currentSections else {
                        return false
                    }
                    return true
                }
                
                // Only perform batch updates if there are valid operations
                guard !validDeletions.isEmpty || !validEmptySections.isEmpty else { return }
                
                table.performBatchUpdates({
                    // Delete rows first
                    if !validDeletions.isEmpty {
                        let indexPaths = validDeletions.map { IndexPath(row: $0.row, section: $0.section) }
                        table.deleteRows(at: indexPaths, with: .fade)
                    }
                    
                    // Then delete empty sections
                    if !validEmptySections.isEmpty {
                        table.deleteSections(IndexSet(validEmptySections), with: .fade)
                    }
                }, completion: { finished in
                    if !finished {
                        print("Batch update did not complete successfully")
                    }
                })
            }
        }

        
        
        viewModel.updateAtIndex = { [weak self] section , row, message in
            guard let this = self else { return }
            
            DispatchQueue.main.async {
                // Step 1: Capture current table view state
                let currentSections = this.tableView.numberOfSections
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
                    // Schedule a deferred section reload to fix the inconsistency
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        if section < this.tableView.numberOfSections {
                            this.tableView.reloadSections(IndexSet(integer: section), with: .none)
                        }
                    }
                    return
                }
                
                let indexPath = IndexPath(row: row, section: section)
                
                // Step 5: Only update visible cells (performance optimization)
                guard this.tableView.indexPathsForVisibleRows?.contains(indexPath) == true else {
                    return
                }
                
                // Step 6: Safely reload the specific row for receipt updates
                UIView.performWithoutAnimation {
                    this.tableView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
        
        viewModel.deleteAtIndex = { [weak self] section , row, message in
            guard let this = self else { return }
            DispatchQueue.main.async {
                // Capture current state
                let currentSections = this.tableView.numberOfSections
                let currentRows = section < currentSections ? this.tableView.numberOfRows(inSection: section) : 0
                
                // Validate section
                guard section < currentSections else { return }
                
                let deleteRow = row - 1
                
                // Validate row
                guard deleteRow >= 0 && deleteRow < currentRows else { return }
                
                // Verify data source will be consistent after delete
                let dataSourceCount = this.viewModel.messages.count > section ?
                                     this.viewModel.messages[section].messages.count : 0
                
                let expectedCountAfterDelete = currentRows - 1
                guard dataSourceCount == expectedCountAfterDelete else {
                    // Use section reload as fallback
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                        if section < this.tableView.numberOfSections {
                            this.tableView.reloadSections(IndexSet(integer: section), with: .automatic)
                        }
                    }
                    return
                }
                
                // Safe delete
                UIView.performWithoutAnimation {
                    this.tableView.deleteRows(at: [IndexPath(row: deleteRow, section: section)], with: .automatic)
                }
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
        
        return filteredMessages?.count ?? 0
    }

    open func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let filteredMessages = viewModel.messages[safe: indexPath.section]?.messages.filter({ message in
                !(hideGroupActionMessages && message.messageCategory == .action && message.receiverType == .group)
            }), let message = filteredMessages[safe: indexPath.row] else {
                return UITableViewCell()
            }
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
                
                cell.updateUI = { [weak tableView] in
                    guard
                        let tableView = tableView,
                        tableView.window != nil,
                        tableView.dataSource != nil
                    else { return }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.03) {
                        guard
                            tableView.window != nil,
                            tableView.dataSource != nil
                        else { return }

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
                cell.disableSwipeToReply = disableSwipeToReply
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
                        
                        cell.set(headerView: nameLabel)
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
                
                if let footerView = template.footerView?(message, cell.alignment, controller) {
                    cell.set(footerView: footerView)
                } else {
                    if message.deletedAt == 0 && !isModerated {
                        buildReactionsView(
                            forMessage: message,
                            cell: cell,
                            alignment: (messageAlignment == .leftAligned ? .left : (isLoggedInUser ? .right : .left)),
                            reactionStlye: messageTypeStyle?.reactionsStyle ?? bubbleStyle.reactionsStyle, template: template
                        )
                    }
                }
                
                if message.deletedAt == 0 && !isModerated{
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
        
        if scrollView.contentOffset.y < 0 {
            scrollView.contentOffset = CGPoint(x: 0, y: 0)
        }
        
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let visibleHeight = scrollView.frame.height
        
        let delta = offsetY - lastContentOffset
        let isScrollingUp = delta > deltaThreshold  // scrolling up (towards older messages)
        let isScrollingDown = delta < -deltaThreshold  // scrolling down (towards newer messages)
        
        if (scrollView.isDragging || scrollView.isDecelerating) && offsetY > lastContentOffset && offsetY >= 400 {
            self.messageIndicator?.isHidden = false
        }
        
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
        
        if offsetY <= 50 {
            self.messageIndicator?.reset()
            self.messageIndicator?.isHidden = true
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

    
    open func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let messageIndicator = self.messageIndicator else { return }
        if indexPath.section == 0 && indexPath.row == 0  {
            self.messageIndicator?.reset()
            self.messageIndicator?.isHidden = true
        }
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
