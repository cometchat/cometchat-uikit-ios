//
//  CometChatConversations.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 22/12/21.
//  Copyright ©  2022 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.
import UIKit
import CometChatPro

/**
 `CometChatConversationList` is a subclass of `UIView` which internally uses a 0 and reusable cell i.e `CometChatConversationListItem` which forms a list of recent conversations as per the data coming from the server.
 - Author: CometChat Team
 - Copyright:  ©  2022 CometChat Inc.
 */
@IBDesignable public final class CometChatConversationList: UIView , NibLoadable {
    
    // MARK: - Declaration of IBInspectable
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var background: CometChatGradientView!
    @IBOutlet weak var tableView: UITableView!
    
    
    //MARK: - Declaration of Variables
    var conversationRequest: ConversationRequest?
    var conversations: [Conversation] = [Conversation]()
    var filteredConversations: [Conversation] = [Conversation]()
    var activityIndicator:UIActivityIndicatorView?
    lazy var searchedText: String? = ""
    var refreshControl = UIRefreshControl()
    weak var controller: UIViewController?
    var isSearching: Bool = false
    var isDeleteConversationEnabled: Bool = true
    var enableSoundForConversations: Bool = true
    var customSoundForConversations: URL?
    var limit: Int = 30
    var searchKeyword: String = ""
    var conversationType: CometChat.ConversationType = .none
    var userAndGroupTags: Bool = false
    var tags: [String] = [String]()
    var emptyView: UIView?
    var errorView: UIView?
    var hideError: Bool = false
    var errorText: String = ""
    var emptyStateText: String = "NO_CHATS_FOUND".localize()
    var emptyStateTextFont: UIFont = CometChatTheme.typography?.Heading ?? UIFont.systemFont(ofSize: 34, weight: .bold)
    var emptyStateTextColor: UIColor = CometChatTheme.palatte?.accent400 ?? UIColor.gray
    var errorStateTextFont: UIFont?
    var errorStateTextColor: UIColor?
    var configurations: [CometChatConfiguration]?

    
    @discardableResult
    @objc public func set(configurations: [CometChatConfiguration]?) -> CometChatConversationList {
        self.configurations = configurations
        configureConversationList()
        refreshConversations()
        return self
    }

    
    /**
     The` background` is a `UIView` which is present in the backdrop for `CometChatConversationList`.
     - Parameters:
     - background: This method will set the background color for CometChatConversationList, it can take an array of multiple colors for the gradient background.
     - Returns: This method will return `CometChatConversationList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(background: [Any]?) ->  CometChatConversationList {
        if let backgroundColors = background as? [CGColor] {
            if backgroundColors.count == 1 {
                self.background.backgroundColor = UIColor(cgColor: backgroundColors.first ?? UIColor.blue.cgColor)
            }else{
                self.background.set(backgroundColorWithGradient: background)
            }
        }
        return self
    }
    
    /**
     This method will set the instance of the view controller from which the `CometChatConversationList` is presented. This method is mandatory to call when the conversation list is presented.
     - Parameters:
     - controller: This method will set the instance of the view controller from which the `CometChatConversationList` is presented. This method is mandatory to call when the conversation list is presented.
     - Returns: This method will return `CometChatConversationList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    @objc public func set(controller: UIViewController) -> CometChatConversationList {
        self.controller = controller
        return self
    }
    
    /**
     This method will set the conversationType for the `CometChatConversationList` to display as per the user's choice. Users can display users, groups, or both as per the enum value.  When none then it will show both users as well as groups.
     - Parameters:
     - `conversationType`: This method will set the mode for the `CometChatConversationList` to display as per the user's choice. Users can display `users`, `groups`, or `none` as per the enum value.  When `none` then it will show both users as well as groups.
     - Returns: This method will return `CometChatConversationList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func set(conversationType: CometChat.ConversationType) -> CometChatConversationList {
        self.conversationType = conversationType
        return self
    }
    
    /**
     This method will specify the option to show or hide the delete conversation option in ConversationList.
     - Parameters:
     - `deleteConversations`: This method will specify the option to show or hide the delete conversation option in ConversationList.
     - Returns: This method will return `CometChatConversationList`
     - Author: CometChat Team
     - Copyright:  ©  2022 CometChat Inc.
     */
    @discardableResult
    public func show(deleteConversation: Bool) ->  CometChatConversationList {
        self.isDeleteConversationEnabled = deleteConversation
        return self
    }
    
    @discardableResult
    public func set(emptyStateMessage: String) -> CometChatConversationList {
        self.emptyStateText = emptyStateMessage
        return self
    }
    
    @discardableResult
    public func set(errorMessage: String) -> CometChatConversationList {
        self.errorText = errorMessage
        return self
    }
    
    @discardableResult
    public func hide(errorMessage: Bool) -> CometChatConversationList {
        self.hideError = errorMessage
        return self
    }
    
    
    @discardableResult
    @objc public func set(limit: Int) -> CometChatConversationList {
        self.limit = limit
        return self
    }
    
    @discardableResult
    @objc public func set(searchKeyword: String) -> CometChatConversationList {
        self.searchKeyword = searchKeyword
        return self
    }
    

    
    @discardableResult
    @objc public func set(userAndGroupTags: Bool) -> CometChatConversationList {
        self.userAndGroupTags = userAndGroupTags
        return self
    }
    
    
    @discardableResult
    @objc public func set(tags:[String]) -> CometChatConversationList {
        self.tags = tags
        return self
    }
    
    
    @discardableResult
    public func set(emptyView: UIView?) -> CometChatConversationList {
        self.emptyView = emptyView
        return self
    }
    
    @discardableResult
    public func set(errorView: UIView?) -> CometChatConversationList {
        self.errorView = errorView
        return self
    }
    
    
    
    @discardableResult
    public func set(emptyStateTextFont: UIFont) -> CometChatConversationList {
        self.emptyStateTextFont = emptyStateTextFont
        return self
    }
    
    @discardableResult
    public func set(emptyStateTextColor: UIColor) -> CometChatConversationList {
        self.emptyStateTextColor = emptyStateTextColor
        return self
    }
    
    @discardableResult
    public func set(errorStateTextFont: UIFont) -> CometChatConversationList {
        self.errorStateTextFont = errorStateTextFont
        return self
    }
    
    @discardableResult
    public func set(errorStateTextColor: UIColor) -> CometChatConversationList {
        self.errorStateTextColor = errorStateTextColor
        return self
    }
    
    @discardableResult
    public func set(enableSoundForConversations: Bool) -> CometChatConversationList {
        self.enableSoundForConversations = enableSoundForConversations
        return self
    }
    
    @discardableResult
    public func set(customSoundForConversations: URL) -> CometChatConversationList {
        self.customSoundForConversations = customSoundForConversations
        return self
    }
    
    @discardableResult
    public func set(conversationList: [Conversation]) -> CometChatConversationList {
        self.conversations = conversationList
        return self
    }
    
    @discardableResult
    public func insert(conversation: Conversation, at: Int? = 0) -> CometChatConversationList {
        conversation.unreadMessageCount += 1
        self.conversations.insert(conversation, at: at ?? 0)
        self.tableView.reloadData()
        return self
    }
    
    @discardableResult
    public func update(conversation: Conversation) -> CometChatConversationList {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }

            if strongSelf.enableSoundForConversations {
                CometChatSoundManager().play(sound: .incomingMessageFromOther)
            }

            if let message = conversation.lastMessage {
                CometChat.markAsDelivered(baseMessage: message)
            }
            if let row = strongSelf.conversations.firstIndex(where: {$0.conversationId == conversation.conversationId}),   let indexPath = IndexPath(row: row, section: 0) as? IndexPath, let cell = strongSelf.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem {
                
                conversation.unreadMessageCount = cell.unreadCount.getCount + 1
                
                if let textMessage = conversation.lastMessage as? TextMessage, textMessage.sender?.uid != CometChat.getLoggedInUser()?.uid {
                    cell.parseProfanityFilter(forMessage: textMessage)
                    cell.parseMaskedData(forMessage: textMessage)
                    cell.parseSentimentAnalysis(forMessage: textMessage)
                }
                
                strongSelf.conversations[row] = conversation
                strongSelf.tableView?.reloadRows(at: [indexPath], with: .automatic)
            }else{
                if ((conversation.lastMessage as? TextMessage) != nil) {
                    strongSelf.insert(conversation: conversation, at: 0)
                    strongSelf.update(conversation: conversation)
                }else{
                    strongSelf.insert(conversation: conversation, at: 0)
                }
            }
        }
        return self
    }
    
    @discardableResult
    public func update(lastMessage: BaseMessage) -> CometChatConversationList {
        if let conversation =  CometChat.getConversationFromMessage(lastMessage) {
            self.update(conversation: conversation)
        }
        return self
    }
    
    @discardableResult
    public func add(conversation: Conversation) -> CometChatConversationList {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            conversation.unreadMessageCount += 1
            strongSelf.conversations.append(conversation)
            strongSelf.tableView.reloadData()
        }
        return self
    }
   
    @discardableResult
    public func remove(conversation: Conversation) -> CometChatConversationList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if let row = strongSelf.conversations.firstIndex(where: {$0.conversationId == conversation.conversationId}) {
                let indexPath = IndexPath(row: row, section: 0)
                strongSelf.tableView.beginUpdates()
                strongSelf.conversations.remove(at: row)
                strongSelf.tableView?.deleteRows(at: [indexPath], with: .automatic)
                strongSelf.tableView.endUpdates()

            }
        }
        return self
    }
    
    @discardableResult
    public func clearList() -> CometChatConversationList {
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.conversations.removeAll()
            strongSelf.tableView.reloadData()
        }
        return self
    }
    
    
    @discardableResult
    public func size() -> Int {
        return  conversations.count
    }
    

    @discardableResult
    public func set(style: Style) -> CometChatConversationList {
        self.set(background: [style.background?.cgColor ?? UIColor.systemBackground.cgColor])
        self.set(emptyStateTextFont: style.emptyStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(emptyStateTextColor: style.emptyStateTextColor ?? UIColor.gray)
        self.set(errorStateTextFont: style.errorStateTextFont ?? UIFont.systemFont(ofSize: 20, weight: .bold))
        self.set(errorStateTextColor: style.errorStateTextColor ?? UIColor.gray)
        return self
    }
    
   
    
    // MARK: - Instance Methods
    
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
        
        setuptTableView()
        registerCells()
        setupDelegates()
        
        if ((configurations?.isEmpty) != nil) {
            refreshConversations()
        }
    }
    
    
   private func configureConversationList() {
       if let configurations = configurations {
           let currentConfigurations = configurations.filter{ $0 is ConversationListConfiguration }
           if let configuration = currentConfigurations.last as? ConversationListConfiguration {
               set(background: configuration.background)
               set(conversationType: configuration.conversationType)
               show(deleteConversation: configuration.showDeleteConversation)
               set(limit: configuration.limit)
               set(tags: configuration.tags)
               set(userAndGroupTags: configuration.userAndGroupTags)
               hide(errorMessage: configuration.hideError)
               set(emptyView: configuration.emptyView)
               set(errorMessage: configuration.errorText)
               set(emptyStateMessage: configuration.emptyText)
               set(enableSoundForConversations: configuration.enableSoundForConversations)
           }
       }
    }
    
    private  func setupDelegates(){
        CometChat.messagedelegate = self
        CometChat.userdelegate = self
        CometChat.groupdelegate = self
    }
    
    fileprivate func setuptTableView() {
        if #available(iOS 13.0, *) {
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.backgroundColor = .clear
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.registerCells()
        
        if #available(iOS 10.0, *) {
            let refreshControl = UIRefreshControl()
            let title = "REFRESHING".localize()
            refreshControl.attributedTitle = NSAttributedString(string: title)
            refreshControl.addTarget(self,
                                     action: #selector(refreshConversations(sender:)),
                                     for: .valueChanged)
            tableView.refreshControl = refreshControl
        }
    }
    
    @objc private func refreshConversations(sender: UIRefreshControl) {
        self.refreshConversations()
        sender.endRefreshing()
    }
    
    fileprivate func registerCells() {
        self.registerCellWith(title: "CometChatConversationListItem")
    }
    
    private func registerCellWith(title: String){
        let cell = UINib(nibName: title, bundle: CometChatUIKit.bundle)
        self.tableView.register(cell, forCellReuseIdentifier: title)
    }
    
    public func refreshConversations(){
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if let emptyView = strongSelf.emptyView {
                strongSelf.tableView.set(customView: emptyView)
            }else{
                strongSelf.tableView?.setEmptyMessage(strongSelf.emptyStateText , color: strongSelf.emptyStateTextColor, font: strongSelf.emptyStateTextFont)
            }
            strongSelf.activityIndicator?.startAnimating()
            strongSelf.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: strongSelf.tableView.bounds.width, height: CGFloat(44))
            strongSelf.tableView.tableFooterView = strongSelf.activityIndicator
            strongSelf.tableView.tableFooterView = strongSelf.activityIndicator
            strongSelf.tableView.tableFooterView?.isHidden = false
        }
        
        conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: limit).setConversationType(conversationType: conversationType).setTags(tags).withUserAndGroupTags(userAndGroupTags).build()
        
        conversationRequest?.fetchNext(onSuccess: { (fetchedConversations) in
            self.conversations = fetchedConversations
            DispatchQueue.main.async {
               
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.reloadData()
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true}
            if let error = error {
               
                CometChatConversationEvents.emitOnError(conversation: nil, error: error)
               
                if !self.hideError {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    if self.errorText.isEmpty {
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                    }else{
                        confirmDialog.set(messageText: self.errorText)
                    }
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                        // Referesh list
                        strongSelf.refreshConversations()
                    })
                }
            }
        }
    }
    
    private func fetchConversations(){
        activityIndicator?.startAnimating()
        activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: tableView.bounds.width, height: CGFloat(44))
        tableView.tableFooterView = activityIndicator
        tableView.tableFooterView?.isHidden = false
        
        conversationRequest?.fetchNext(onSuccess: { (conversations) in
            
            if conversations.count != 0{
                self.conversations.append(contentsOf: conversations)
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                    self.tableView.reloadData()
                }
            }
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true}
        }) { (error) in
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true}
            if let error = error {
                // ASK: - What is emitOnError ?
                CometChatConversationEvents.emitOnError(conversation: nil, error: error)
                if !self.hideError {
                    let confirmDialog = CometChatDialog()
                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                    if self.errorText.isEmpty {
                        confirmDialog.set(error: CometChatServerError.get(error: error))
                    }else{
                        confirmDialog.set(messageText: self.errorText)
                    }
                    confirmDialog.open(onConfirm: { [weak self] in
                        guard let strongSelf = self else { return }
                        // Referesh list
                        strongSelf.refreshConversations()
                    })
                }
            }
        }
    }
    
    public func filterConversations(forText: String?) {
        if let text = forText {
            self.searchedText = text
            filteredConversations = conversations.filter { (conversation: Conversation) -> Bool in
            
                return (((conversation.conversationWith as? User)?.name?.lowercased().contains(text.lowercased()) ?? false) || ((conversation.conversationWith as? Group)?.name?.lowercased().contains(text.lowercased()) ?? false) || ((conversation.lastMessage as? TextMessage)?.text.lowercased().contains(text.lowercased()) ?? false) || ((conversation.lastMessage as? ActionMessage)?.message?.lowercased().contains(text.lowercased()) ?? false))
                
            }
            self.tableView.reloadData()
        }
    }
}


extension CometChatConversationList: UITableViewDelegate, UITableViewDataSource {
    
    
    /// This method specifies the number of sections to display list of Conversations.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// This method specifiesnumber of rows in CometChatConversationList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if conversations.isEmpty {
            if let emptyView = self.emptyView {
                self.tableView.set(customView: emptyView)
            }else{
                self.tableView?.setEmptyMessage(self.emptyStateText , color: self.emptyStateTextColor, font: self.emptyStateTextFont)
            }
        } else{
            self.tableView.restore()
        }
        if isSearching {
            return filteredConversations.count
        }else{
            return conversations.count
        }
    }
    
    /// This method specifies the height for row in CometChatConversationList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for user  in CometChatConversationList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let conversationListItem = tableView.dequeueReusableCell(withIdentifier: "CometChatConversationListItem", for: indexPath) as? CometChatConversationListItem {
            conversationListItem.set(configurations: configurations)
            conversationListItem.searchedText = searchedText ?? ""
            if isSearching {
                conversationListItem.set(conversation: filteredConversations[safe:indexPath.row])
            } else {
                conversationListItem.set(conversation: conversations[safe:indexPath.row])
            }
            return conversationListItem
        }
        return UITableViewCell()
    }
    
    
    /// This method loads the upcoming groups coming inside the tableview
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let lastSectionIndex = tableView.numberOfSections - 1
        let lastRowIndex = tableView.numberOfRows(inSection: lastSectionIndex) - 1
        if indexPath.section ==  lastSectionIndex && indexPath.row == lastRowIndex {
            self.fetchConversations()
        }
    }
    
    /// This method triggers when particulatr cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let selectedConversation = tableView.cellForRow(at: indexPath) as? CometChatConversationListItem, let conversation = selectedConversation.conversation {
            tableView.deselectRow(at: indexPath, animated: true)
            CometChatConversationEvents.emitOnItemClick(converation: conversation, index: indexPath)
            selectedConversation.unreadCount.removeCount()
            
        }
    }
    
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        guard  let selectedCell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem  else { return nil }
        // ASK: It can be refactor.
        
        let deleteAction =  UIContextualAction(style: .destructive, title: "", handler: { (action,view, completionHandler ) in
            
            if let conversationWith = selectedCell.conversation?.conversationWith, let conversationType = selectedCell.conversation?.conversationType {
                
                
                switch conversationType {
                    
                case .user:
                    
                    let alert = UIAlertController(title: "", message: "DELETE_CONVERSATION_MESSAGE".localize(), preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "DELETE".localize(), style: .destructive, handler: { (action: UIAlertAction!) in
                        
                        CometChat.deleteConversation(conversationWith: (conversationWith as? User)?.uid ?? "" , conversationType: .user) { (conversation) in
                            if let conversation = selectedCell.conversation {
                                CometChatConversationEvents.emitConversationDelete(conversation: conversation)
                            }
                            self.conversations.remove(at: indexPath.row)
                            DispatchQueue.main.async {
                                if !self.conversations.isEmpty{
                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                }
                                self.tableView.reloadData()
                            }
                        } onError: { (error) in
                            if let error = error {
                                // ASK: - What is emitOnError ?
                                CometChatConversationEvents.emitOnError(conversation: selectedCell.conversation, error: error)
                                if !self.hideError {
                                    let confirmDialog = CometChatDialog()
                                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                                    if self.errorText.isEmpty {
                                        confirmDialog.set(error: CometChatServerError.get(error: error))
                                    }else{
                                        confirmDialog.set(messageText: self.errorText)
                                    }
                                    confirmDialog.open(onConfirm: { [weak self] in
                                        guard let strongSelf = self else { return }
                                        // Referesh list
                                        strongSelf.refreshConversations()
                                    })
                                }
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { (action: UIAlertAction!) in
                    }))
                    alert.view.tintColor = CometChatTheme.palatte?.primary
                    self.controller?.present(alert, animated: true, completion: nil)
                    
                    
                case .group:
                    
                    let alert = UIAlertController(title: "", message: "DELETE_CONVERSATION_MESSAGE".localize(), preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "DELETE".localize(), style: .destructive, handler: { (action: UIAlertAction!) in
                        
                        
                        CometChat.deleteConversation(conversationWith: (conversationWith as? Group)?.guid ?? "" , conversationType: .group) { (success) in
                            if let conversation = selectedCell.conversation {
                                CometChatConversationEvents.emitConversationDelete(conversation: conversation)
                            }
                            self.conversations.remove(at: indexPath.row)
                            DispatchQueue.main.async {
                                if !self.conversations.isEmpty{
                                    tableView.deleteRows(at: [indexPath], with: .fade)
                                }
                                self.tableView.reloadData()
                            }
                            
                        } onError: { (error) in
                            if let error = error {
                                // ASK: - What is emitOnError ?
                                CometChatConversationEvents.emitOnError(conversation: selectedCell.conversation, error: error)
                                if !self.hideError {
                                    let confirmDialog = CometChatDialog()
                                    confirmDialog.set(confirmButtonText: "TRY_AGAIN".localize())
                                    confirmDialog.set(cancelButtonText: "CANCEL".localize())
                                    if self.errorText.isEmpty {
                                        confirmDialog.set(error: CometChatServerError.get(error: error))
                                    }else{
                                        confirmDialog.set(messageText: self.errorText)
                                    }
                                    confirmDialog.open(onConfirm: { [weak self] in
                                        guard let strongSelf = self else { return }
                                        // Referesh list
                                        strongSelf.refreshConversations()
                                    })
                                }
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: "CANCEL".localize(), style: .cancel, handler: { (action: UIAlertAction!) in
                    }))
                    alert.view.tintColor = CometChatTheme.palatte?.primary
                    self.controller?.present(alert, animated: true, completion: nil)
                    
                    
                case .none: break
                @unknown default: break
                }
            }
            completionHandler(true)
        })
        
        let image =  UIImage(named: "chats-delete.png", in: CometChatUIKit.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        deleteAction.image = image
        
        if isDeleteConversationEnabled {
            actions.append(deleteAction)
        }
        
        return  UISwipeActionsConfiguration(actions: actions)
    }
}
