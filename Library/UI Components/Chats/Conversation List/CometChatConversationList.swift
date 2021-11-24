
//  CometChatConversationList.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatConversationList: CometChatConversationList is a view controller with a list of recent conversations. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

// MARK: - Declaring Protocol.

public protocol ConversationListDelegate : AnyObject{
    /**
     This method triggers when user taps perticular conversation in CometChatConversationList
     - Parameters:
     - conversation: Specifies the `conversation` Object for selected cell.
     - indexPath: Specifies the indexpath for selected conversation.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    func didSelectConversationAtIndexPath(conversation: Conversation, indexPath: IndexPath)
}

/*  ----------------------------------------------------------------------------------------- */

public final class CometChatConversationList: UIViewController {
    
    // MARK: - Declaration of Variables
    var conversationRequest: ConversationRequest?
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var conversations: [Conversation] = [Conversation]()
    var filteredConversations: [Conversation] = [Conversation]()
    weak var conversationlistdelegate : ConversationListDelegate?
    var activityIndicator:UIActivityIndicatorView?
    lazy var searchedText: String? = ""
    var refreshControl = UIRefreshControl()
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
      
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupDelegates()
        self.refreshConversations()
        self.setupNavigationBar()
        self.setupSearchBar()
        self.addObservers()
    }
    
    
    fileprivate func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(appMovedToForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    fileprivate func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    @objc func appMovedToForeground() {
        if !CometChat.backgroundTaskEnabled() {
            self.refreshConversations()
        }
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        self.setupDelegates()
        refreshConversations()
    }
    
    deinit {
    }
    
    
    // MARK: - Public instance methods
    
    /**
     This method specifies the navigation bar title for CometChatConversationList.
     - Parameters:
     - title: This takes the String to set title for CometChatConversationList.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
        if navigationController != nil{
            navigationItem.title = title.localized()
            navigationItem.largeTitleDisplayMode = mode
            switch mode {
            case .automatic:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .always:
                navigationController?.navigationBar.prefersLargeTitles = true
            case .never:
                navigationController?.navigationBar.prefersLargeTitles = false
            @unknown default:break }
        }
    }
    
    
    
    // MARK: - Private instance methods
    
    /**
     This method fetches the list of recent Converversations from  Server using **ConversationRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    private func refreshConversations(){
        DispatchQueue.main.async {
            self.tableView.setEmptyMessage("".localized())
            self.activityIndicator?.startAnimating()
            self.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44))
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView?.isHidden = false
        }

        if UIKitSettings.chatListMode == .user {
            conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: 15).setConversationType(conversationType: .user).build()
        }else if UIKitSettings.chatListMode == .group {
            conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: 15).setConversationType(conversationType: .group).build()
        }else if UIKitSettings.chatListMode == .both {
            conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: 15).setConversationType(conversationType: .none).build()
        }
       
        conversationRequest?.fetchNext(onSuccess: { (fetchedConversations) in
            
            var newConversations: [Conversation] =  [Conversation]()
            self.conversations = fetchedConversations
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.reloadData()
            }
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
    

    
    /**
       This method fetches the list of groups from  Server using **GroupRequest** Class.
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       - See Also:
      [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
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
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
    
    /**
     This method register the delegate for real time events from CometChatPro SDK.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    private  func setupDelegates(){
        CometChat.connectiondelegate = self
        CometChat.messagedelegate = self
        CometChat.userdelegate = self
        CometChat.groupdelegate = self
    }
    
    /**
     This method setup the tableview to load CometChatConversationList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    private func setupTableView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {
            activityIndicator = UIActivityIndicatorView(style: .gray)
        }
        tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.safeArea.topAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.registerCells()
        
        if #available(iOS 10.0, *) {
          let refreshControl = UIRefreshControl()
          let title = "REFRESHING".localized()
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
    
    /**
     This method register 'CometChatConversationListItem' cell in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func registerCells(){
      
        let CometChatConversationListItem  =  UINib(nibName: "CometChatConversationListItem", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatConversationListItem, forCellReuseIdentifier: "CometChatConversationListItem")
    }
    
    /**
     This method setup navigationBar for conversationList viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    private func setupNavigationBar(){
        if navigationController != nil{
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
            }
            
            FeatureRestriction.isStartConversationEnabled { ( success) in
                if success == .enabled {
                    self.addStartConversation(true)
                }
            }
        }
    }
    
    private func addStartConversation(_ inNavigationBar: Bool){
        if inNavigationBar == true {
            let createGroupImage = UIImage(named: "chats-create.png", in: UIKitSettings.bundle, compatibleWith: nil)
            let createGroupButton = UIBarButtonItem(image: createGroupImage, style: .plain, target: self, action: #selector(didStartConversationPressed))
            createGroupButton.tintColor = UIKitSettings.primaryColor
            self.navigationItem.rightBarButtonItem = createGroupButton
        }
    }
    
    @objc func didStartConversationPressed(){
        let startConversation = CometChatStartConversation()
        let navigationController: UINavigationController = UINavigationController(rootViewController: startConversation)
        startConversation.set(title: "SELECT_USER".localized(), mode: .automatic)
        navigationController.modalPresentationStyle = .fullScreen
        self.present(navigationController, animated: true, completion: nil)
        
    }
    
    
    /**
     This method setup the search bar for conversationList viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    private func setupSearchBar(){
        // SearchBar Apperance
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        definesPresentationContext = true
        searchController.searchBar.delegate = self
        if #available(iOS 13.0, *) {
            searchController.searchBar.barTintColor = .systemBackground
        } else {}
        if #available(iOS 11.0, *) {
            if navigationController != nil{
                FeatureRestriction.isChatSearchEnabled { (success) in
                    if success == .enabled {
                        self.navigationItem.searchController = self.searchController
                    }
                }
            }else{
                if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                    if #available(iOS 13.0, *) {textfield.textColor = .label } else {}
                    if let backgroundview = textfield.subviews.first{
                        backgroundview.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
                        backgroundview.layer.cornerRadius = 10
                        backgroundview.clipsToBounds = true
                    }}
                FeatureRestriction.isChatSearchEnabled { (success) in
                    if success == .enabled {
                        self.tableView.tableHeaderView = self.searchController.searchBar
                    }
                }
            }} else {}
       
    }
    
    /**
     This method returns true if  search bar is empty.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    private func searchBarIsEmpty() -> Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    /**
     This method returns true if  search bar is in active state.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    private func isSearching() -> Bool {
        let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
        return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatConversationList: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies height for section in CometChatConversationList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    /// This method specifies the view for header  in CometChatConversationList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 0.5))
        return returnedView
    }
    
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
            self.tableView.setEmptyMessage("NO_CHATS_FOUND".localized())
        } else{
            self.tableView.restore()
        }
        if isSearching(){
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "CometChatConversationListItem", for: indexPath) as! CometChatConversationListItem
        var conversation: Conversation?
        cell.searchedText = searchedText ?? ""
        if isSearching() {
            conversation = filteredConversations[safe:indexPath.row]
            
        } else {
            conversation = conversations[safe:indexPath.row]
        }
        cell.conversation = conversation
        return cell
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
        
        
        if let selectedConversation = tableView.cellForRow(at: indexPath) as? CometChatConversationListItem, let conversation = selectedConversation.conversation ,let user = conversation.conversationWith as? User  {
            
            selectedConversation.unreadBadgeCount.removeCount()
            let messageList: CometChatMessageList = CometChatMessageList()
            messageList.set(conversationWith: user, type: .user)
            messageList.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(messageList, animated: true)
            
            conversationlistdelegate?.didSelectConversationAtIndexPath(conversation: conversation, indexPath: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
            
        }else if let selectedConversation = tableView.cellForRow(at: indexPath) as? CometChatConversationListItem, let conversation = selectedConversation.conversation ,let group = conversation.conversationWith as? Group  {
            
            selectedConversation.unreadBadgeCount.removeCount()
            let messageList: CometChatMessageList = CometChatMessageList()
            messageList.set(conversationWith: group, type: .group)
            messageList.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(messageList, animated: true)
            
            conversationlistdelegate?.didSelectConversationAtIndexPath(conversation: conversation, indexPath: indexPath)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        var actions = [UIContextualAction]()
        guard  let selectedCell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem  else { return nil }
        
        let deleteAction =  UIContextualAction(style: .destructive, title: "", handler: { (action,view, completionHandler ) in
            
            if let conversationWith = selectedCell.conversation?.conversationWith, let conversationType = selectedCell.conversation?.conversationType {
                
                switch conversationType {
               
               
                case .user:
                    
                    CometChat.deleteConversation(conversationWith: (conversationWith as? User)?.uid ?? "" , conversationType: .user) { (success) in
                        self.conversations.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            if !self.conversations.isEmpty{
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                            self.tableView.reloadData()
                        }
                    } onError: { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                    }

                case .group:
                    
                    CometChat.deleteConversation(conversationWith: (conversationWith as? Group)?.guid ?? "" , conversationType: .group) { (success) in
                        self.conversations.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            if !self.conversations.isEmpty{
                                tableView.deleteRows(at: [indexPath], with: .fade)
                            }
                        }
                    } onError: { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }

                    }

                case .none: break
                @unknown default: break
                }
            }
            completionHandler(true)
        })
        
        let image =  UIImage(named: "chats-delete.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
        deleteAction.image = image
        
         FeatureRestriction.isclearConversationEnabled(completion: { success in
            if success == .enabled {
                actions.append(deleteAction)
            }
        })
       
        return  UISwipeActionsConfiguration(actions: actions)
    }
    
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - UISearchResultsUpdating Delegate

extension CometChatConversationList : UISearchBarDelegate, UISearchResultsUpdating {
    
    /**
     This method update the list of conversations as per string provided in search bar
     - Parameter searchController: The UISearchController object used as the search bar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func updateSearchResults(for searchController: UISearchController) {
        
        if let text = searchController.searchBar.text {
            filteredConversations = conversations.filter { (conversation: Conversation) -> Bool in
                // If dataItem matches the searchText, return true to include it
                self.searchedText = text
                return (((conversation.conversationWith as? User)?.name?.lowercased().contains(text.lowercased()) ?? false) || ((conversation.conversationWith as? Group)?.name?.lowercased().contains(text.lowercased()) ?? false) || ((conversation.lastMessage as? TextMessage)?.text.lowercased().contains(text.lowercased()) ?? false) || ((conversation.lastMessage as? ActionMessage)?.message?.lowercased().contains(text.lowercased()) ?? false))
                
            }
            self.tableView.reloadData()
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatMessageDelegate Delegate

extension CometChatConversationList : CometChatMessageDelegate {
    
    /**
     This method triggers when real time text message message arrives from CometChat Pro SDK
     - Parameter textMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onTextMessageReceived(textMessage: TextMessage) {
        CometChat.markAsDelivered(baseMessage: textMessage)
        switch  UIKitSettings.chatListMode {
       
        case .user:
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == textMessage.sender?.uid && $0.conversationType.rawValue == textMessage.receiverType.rawValue }) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem,  (cell.conversation?.conversationWith as? User)?.uid == textMessage.sender?.uid {
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            cell.parseProfanityFilter(forMessage: textMessage)
                            cell.parseMaskedData(forMessage: textMessage)
                            cell.parseSentimentAnalysis(forMessage: textMessage)
                            cell.unreadBadgeCount.incrementCount()
                            self.tableView.endUpdates()
                        }
                    }
                }
            }else {
                refreshConversations()
            }
        case .group:
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            if let row = self.conversations.firstIndex(where: {($0.conversationWith as? Group)?.guid == textMessage.receiverUid && $0.conversationType.rawValue == textMessage.receiverType.rawValue }) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem, (cell.conversation?.conversationWith as? Group)?.guid == textMessage.receiverUid {
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            cell.parseProfanityFilter(forMessage: textMessage)
                            cell.parseMaskedData(forMessage: textMessage)
                            cell.parseSentimentAnalysis(forMessage: textMessage)
                            cell.unreadBadgeCount.incrementCount()
                            self.tableView.endUpdates()
                        }
                    }
                }
            }else {
                refreshConversations()
            }
        case .both:
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == textMessage.sender?.uid && $0.conversationType.rawValue == textMessage.receiverType.rawValue }) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem,  (cell.conversation?.conversationWith as? User)?.uid == textMessage.sender?.uid {
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            cell.parseProfanityFilter(forMessage: textMessage)
                            cell.parseMaskedData(forMessage: textMessage)
                            cell.parseSentimentAnalysis(forMessage: textMessage)
                            cell.unreadBadgeCount.incrementCount()
                            self.tableView.endUpdates()
                        }
                    }
                }
            }else if let row = self.conversations.firstIndex(where: {($0.conversationWith as? Group)?.guid == textMessage.receiverUid && $0.conversationType.rawValue == textMessage.receiverType.rawValue }) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem, (cell.conversation?.conversationWith as? Group)?.guid == textMessage.receiverUid {
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            cell.parseProfanityFilter(forMessage: textMessage)
                            cell.parseMaskedData(forMessage: textMessage)
                            cell.parseSentimentAnalysis(forMessage: textMessage)
                            cell.unreadBadgeCount.incrementCount()
                            self.tableView.endUpdates()
                        }
                    }
                }
            }else {
                refreshConversations()
            }
        }
    }
    
    /**
     This method triggers when real time media message arrives from CometChat Pro SDK
     - Parameter mediaMessage: This Specifies MediaMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        CometChat.markAsDelivered(baseMessage: mediaMessage)
        switch UIKitSettings.chatListMode {
       
        case .user:
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == mediaMessage.sender?.uid && $0.conversationType.rawValue == mediaMessage.receiverType.rawValue }) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem,  (cell.conversation?.conversationWith as? User)?.uid == mediaMessage.sender?.uid {
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            switch mediaMessage.messageType {
                            case .text: break
                            case .image: cell.message.text = "MESSAGE_IMAGE".localized()
                            case .video: cell.message.text = "MESSAGE_VIDEO".localized()
                            case .audio: cell.message.text = "MESSAGE_AUDIO".localized()
                            case .file: cell.message.text =  "MESSAGE_FILE".localized()
                            case .custom: break
                            case .groupMember: break
                            @unknown default: break
                            }
                            cell.unreadBadgeCount.incrementCount()
                            self.tableView.endUpdates()
                        }
                    }
                }
            }else {
                refreshConversations()
            }
        case .group:
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            if let row = self.conversations.firstIndex(where: {($0.conversationWith as? Group)?.guid == mediaMessage.receiverUid && $0.conversationType.rawValue == mediaMessage.receiverType.rawValue }) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem, (cell.conversation?.conversationWith as? Group)?.guid == mediaMessage.receiverUid {
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            if let senderName = mediaMessage.sender?.name {
                                switch mediaMessage.messageType {
                                case .text: break
                                case .image:  cell.message.text = senderName + ": " + "MESSAGE_IMAGE".localized()
                                case .video:  cell.message.text = senderName + ": " + "MESSAGE_VIDEO".localized()
                                case .audio:  cell.message.text = senderName + ": " + "MESSAGE_AUDIO".localized()
                                case .file:   cell.message.text = senderName + ": " + "MESSAGE_FILE".localized()
                                case .custom: break
                                case .groupMember: break
                                @unknown default: break
                                }
                            }
                            
                            cell.unreadBadgeCount.incrementCount()
                            self.tableView.endUpdates()
                        }
                    }
                }
            }else {
                refreshConversations()
            }
        case .both:
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == mediaMessage.sender?.uid && $0.conversationType.rawValue == mediaMessage.receiverType.rawValue }) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem,  (cell.conversation?.conversationWith as? User)?.uid == mediaMessage.sender?.uid {
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            switch mediaMessage.messageType {
                            case .text: break
                            case .image: cell.message.text = "MESSAGE_IMAGE".localized()
                            case .video: cell.message.text = "MESSAGE_VIDEO".localized()
                            case .audio: cell.message.text = "MESSAGE_AUDIO".localized()
                            case .file: cell.message.text =  "MESSAGE_FILE".localized()
                            case .custom: break
                            case .groupMember: break
                            @unknown default: break
                            }
                            cell.unreadBadgeCount.incrementCount()
                            self.tableView.endUpdates()
                        }
                    }
                }
            }else if let row = self.conversations.firstIndex(where: {($0.conversationWith as? Group)?.guid == mediaMessage.receiverUid && $0.conversationType.rawValue == mediaMessage.receiverType.rawValue }) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem, (cell.conversation?.conversationWith as? Group)?.guid == mediaMessage.receiverUid {
                        DispatchQueue.main.async {
                            self.tableView.beginUpdates()
                            if let senderName = mediaMessage.sender?.name {
                                switch mediaMessage.messageType {
                                case .text: break
                                case .image:  cell.message.text = senderName + ": " + "MESSAGE_IMAGE".localized()
                                case .video:  cell.message.text = senderName + ": " + "MESSAGE_VIDEO".localized()
                                case .audio:  cell.message.text = senderName + ": " + "MESSAGE_AUDIO".localized()
                                case .file:   cell.message.text = senderName + ": " + "MESSAGE_FILE".localized()
                                case .custom: break
                                case .groupMember: break
                                @unknown default: break
                                }
                            }
                            
                            cell.unreadBadgeCount.incrementCount()
                            self.tableView.endUpdates()
                        }
                    }
                }
            }else {
                refreshConversations()
            }
        }
    }
    
    /**
     This method triggers when real time media message arrives from CometChat Pro SDK
     - Parameter mediaMessage: This Specifies MediaMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onCustomMessageReceived(customMessage: CustomMessage) {
        CometChat.markAsDelivered(baseMessage: customMessage)
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
    }
    
    /**
     This method triggers when real time event for  start typing received from  CometChat Pro SDK
     - Parameter typingDetails: This specifies TypingIndicator Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
        
        if let typingMetaData = typingDetails.metadata, let _ = typingMetaData["type"] as? String ,let _ = typingMetaData["reaction"] as? String {
            
        }else{
            
            if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == typingDetails.sender?.uid && $0.conversationType.rawValue == typingDetails.receiverType.rawValue }) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem,  (cell.conversation?.conversationWith as? User)?.uid == typingDetails.sender?.uid {
                        if cell.message.isHidden == false {
                            cell.typing.isHidden = false
                            cell.message.isHidden = true
                        }
                        cell.reloadInputViews()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem,  (cell.conversation?.conversationWith as? User)?.uid == typingDetails.sender?.uid {
                        if cell.typing.isHidden == false {
                            cell.typing.isHidden = true
                            cell.message.isHidden = false
                        }
                        cell.reloadInputViews()
                    }
                }
            }
            if let row = self.conversations.firstIndex(where: {($0.conversationWith as? Group)?.guid == typingDetails.receiverID && $0.conversationType.rawValue == typingDetails.receiverType.rawValue}) {
                let indexPath = IndexPath(row: row, section: 0)
                DispatchQueue.main.async {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem, (cell.conversation?.conversationWith as? Group)?.guid == typingDetails.receiverID {
                        let user = typingDetails.sender?.name
                        cell.typing.text = user! + " " + "IS_TYPING".localized()
                        if cell.message.isHidden == false{
                            cell.typing.isHidden = false
                            cell.message.isHidden = true
                        }
                        cell.reloadInputViews()
                    }
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem, (cell.conversation?.conversationWith as? Group)?.guid == typingDetails.receiverID {
                        let user = typingDetails.sender?.name
                        cell.typing.text = user! + " " + "IS_TYPING".localized()
                        if cell.typing.isHidden == false{
                            cell.typing.isHidden = true
                            cell.message.isHidden = false
                        }
                        cell.reloadInputViews()
                    }
                }
            }
        }
    }
    
    /**
     This method triggers when real time event for  stop typing received from  CometChat Pro SDK
     - Parameter typingDetails: This specifies TypingIndicator Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
        if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == typingDetails.sender?.uid && $0.conversationType.rawValue == typingDetails.receiverType.rawValue}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem {
                    if cell.typing.isHidden == false{
                        cell.message.isHidden = false
                        cell.typing.isHidden = true
                    }
                    cell.reloadInputViews()
                }
            }
        }
        if let row = self.conversations.firstIndex(where: {($0.conversationWith as? Group)?.guid == typingDetails.receiverID && $0.conversationType.rawValue == typingDetails.receiverType.rawValue}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem {
                    if cell.typing.isHidden == false{
                        cell.message.isHidden = false
                        cell.typing.isHidden = true
                    }
                    cell.reloadInputViews()
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatUserDelegate Delegate

extension CometChatConversationList : CometChatUserDelegate {
    /**
     This method triggers users comes online from user list.
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onUserOnline(user: User) {
        if UIKitSettings.chatListMode == .user || UIKitSettings.chatListMode == .both {
        if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == user.uid}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem {
                    cell.status.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.8039215686, blue: 0.1960784314, alpha: 1)
                    cell.reloadInputViews()
                }
            }
        }
        }
    }
    
    /**
     This method triggers users goes offline from user list.
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onUserOffline(user: User) {
        if UIKitSettings.chatListMode == .user || UIKitSettings.chatListMode == .both {
        if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == user.uid}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationListItem {
                    cell.status.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                    cell.reloadInputViews()
                }
            }
        }
    }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatGroupDelegate Delegate

extension CometChatConversationList : CometChatGroupDelegate {
    
    /**
     This method triggers when someone joins group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - joinedUser: Specifies `User` Object
     - joinedGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if UIKitSettings.chatListMode == .group || UIKitSettings.chatListMode == .both {
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            refreshConversations()
        }
    }
    
    /**
     This method triggers when someone lefts group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - leftUser: Specifies `User` Object
     - leftGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if UIKitSettings.chatListMode == .group || UIKitSettings.chatListMode == .both {
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            refreshConversations()
        }
    }
    
    /**
     This method triggers when someone kicked from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - kickedUser: Specifies `User` Object
     - kickedBy: Specifies `User` Object
     - kickedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if UIKitSettings.chatListMode == .group || UIKitSettings.chatListMode == .both {
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            refreshConversations()
        }
    }
    
    /**
     This method triggers when someone banned from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - bannedUser: Specifies `User` Object
     - bannedBy: Specifies `User` Object
     - bannedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if UIKitSettings.chatListMode == .group || UIKitSettings.chatListMode == .both {
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            refreshConversations()
        }
    }
    
    /**
     This method triggers when someone unbanned from the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - unbannedUser: Specifies `User` Object
     - unbannedBy: Specifies `User` Object
     - unbannedFrom: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if UIKitSettings.chatListMode == .group || UIKitSettings.chatListMode == .both {
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            refreshConversations()
        }
    }
    
    /**
     This method triggers when someone's scope changed  in the  group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - scopeChangeduser: Specifies `User` Object
     - scopeChangedBy: Specifies `User` Object
     - scopeChangedTo: Specifies `User` Object
     - scopeChangedFrom:  Specifies  description for scope changed
     - group: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if UIKitSettings.chatListMode == .group || UIKitSettings.chatListMode == .both {
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            refreshConversations()
        }
    }
    
    
    /// This method triggers when someone added in  the  group.
    /// - Parameters:
    ///   - action:  Spcifies `ActionMessage` Object
    ///   - addedBy: Specifies `User` Object
    ///   - addedUser: Specifies `User` Object
    ///   - addedTo: Specifies `Group` Object
    ///- Author: CometChat Team
    ///- Copyright:  ©  2020 CometChat Inc.
    ///- See Also:
    ///[CometChatConversationList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
   
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        CometChat.markAsDelivered(baseMessage: action)
        if UIKitSettings.chatListMode == .group || UIKitSettings.chatListMode == .both {
            DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
            refreshConversations()
        }
    } 
}

/*  ----------------------------------------------------------------------------------------- */

extension CometChatConversationList: CometChatConnectionDelegate {
    
    public func connecting() {
        if UIKitSettings.connectionIndicator == .enabled {
            DispatchQueue.main.async {
                CometChatSnackBoard.show(message: "Connecting...")
            }
        }
    }
    
    public func connected() {
        if UIKitSettings.connectionIndicator == .enabled {
            DispatchQueue.main.async {
                CometChatSnackBoard.show(message: "Connected", mode: .success, duration: .forever)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                CometChatSnackBoard.hide()
                self.refreshConversations()
            }
        }
    }
    
    public func disconnected() {
        if UIKitSettings.connectionIndicator == .enabled {
            DispatchQueue.main.async {
                CometChatSnackBoard.show(message: "Disconnected", mode: .error, duration: .forever)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                CometChatSnackBoard.hide()
            }
        }
    }
}
