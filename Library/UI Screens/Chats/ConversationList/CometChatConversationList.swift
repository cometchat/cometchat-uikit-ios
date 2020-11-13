
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

public class CometChatConversationList: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: 100).setConversationType(conversationType: .none).build()
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var conversations: [Conversation] = [Conversation]()
    var filteredConversations: [Conversation] = [Conversation]()
    weak var delegate : ConversationListDelegate?
    var storedVariable: String?
    var activityIndicator:UIActivityIndicatorView?
    var searchedText: String = ""
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
            navigationItem.title = NSLocalizedString(title, bundle: UIKitSettings.bundle, comment: "")
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
            self.tableView.setEmptyMessage(NSLocalizedString("", bundle: UIKitSettings.bundle, comment: ""))
            self.activityIndicator?.startAnimating()
            self.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44))
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView?.isHidden = false
        }
        conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: 15).setConversationType(conversationType: .none).build()
        conversationRequest.fetchNext(onSuccess: { (fetchedConversations) in
    
            var newConversations: [Conversation] =  [Conversation]()
            for conversation in fetchedConversations {
                if conversation.lastMessage == nil { } else {
                    newConversations.append(conversation) }
            }
            self.conversations = newConversations
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                self.tableView.tableFooterView?.isHidden = true
                self.tableView.reloadData()
            }
        }) { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                   let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                   snackbar.show()
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
           conversationRequest.fetchNext(onSuccess: { (conversations) in
               print("fetchConversations onSuccess: \(conversations)")
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
                   if let errorMessage = error?.errorDescription {
                       let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                       snackbar.show()
                   }
               }
               print("fetchConversations error:\(String(describing: error?.errorDescription))")
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
          let title = NSLocalizedString("REFRESHING", bundle: UIKitSettings.bundle, comment: "")
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
     This method register 'CometChatConversationView' cell in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func registerCells(){
      
        let CometChatConversationView  =  UINib(nibName: "CometChatConversationView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatConversationView, forCellReuseIdentifier: "conversationView")
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
        }
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
                navigationItem.searchController = searchController
            }else{
                if let textfield = searchController.searchBar.value(forKey: "searchField") as? UITextField {
                    if #available(iOS 13.0, *) {textfield.textColor = .label } else {}
                    if let backgroundview = textfield.subviews.first{
                        backgroundview.backgroundColor = UIColor.init(white: 1, alpha: 0.5)
                        backgroundview.layer.cornerRadius = 10
                        backgroundview.clipsToBounds = true
                    }}
                tableView.tableHeaderView = searchController.searchBar
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
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0.5))
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
            self.tableView.setEmptyMessage(NSLocalizedString("No Chats Found.", bundle: UIKitSettings.bundle, comment: ""))
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
        return 70
    }
    
    /// This method specifies the view for user  in CometChatConversationList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationView", for: indexPath) as! CometChatConversationView
        var conversation: Conversation?
        cell.searchedText = searchedText
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
        tableView.deselectRow(at: indexPath, animated: true)
        guard let selectedConversation = tableView.cellForRow(at: indexPath) as? CometChatConversationView else{
            return
        }
        switch selectedConversation.conversation?.conversationType {
        case .user:
            let convo1: CometChatMessageList = CometChatMessageList()
            convo1.set(conversationWith: ((selectedConversation.conversation?.conversationWith as? User)!), type: .user)
            convo1.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(convo1, animated: true)
        case .group:
            let convo1: CometChatMessageList = CometChatMessageList()
            convo1.set(conversationWith: ((selectedConversation.conversation?.conversationWith as? Group)!), type: .group)
            convo1.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(convo1, animated: true)
            
        case .none: break
        case .some(.none): break 
        @unknown default: break
        }
        delegate?.didSelectConversationAtIndexPath(conversation: selectedConversation.conversation!, indexPath: indexPath)
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
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
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
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
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
        if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == typingDetails.sender?.uid && $0.conversationType.rawValue == typingDetails.receiverType.rawValue }) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView,  (cell.conversation?.conversationWith as? User)?.uid == typingDetails.sender?.uid {
                    if cell.message.isHidden == false {
                        cell.typing.isHidden = false
                        cell.message.isHidden = true
                    }
                    cell.reloadInputViews()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView,  (cell.conversation?.conversationWith as? User)?.uid == typingDetails.sender?.uid {
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
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView, (cell.conversation?.conversationWith as? Group)?.guid == typingDetails.receiverID {
                    let user = typingDetails.sender?.name
                    cell.typing.text = user! + " " + NSLocalizedString("IS_TYPING", bundle: UIKitSettings.bundle, comment: "")
                    if cell.message.isHidden == false{
                        cell.typing.isHidden = false
                        cell.message.isHidden = true
                    }
                    cell.reloadInputViews()
                }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView, (cell.conversation?.conversationWith as? Group)?.guid == typingDetails.receiverID {
                    let user = typingDetails.sender?.name
                    cell.typing.text = user! + " " + NSLocalizedString("IS_TYPING", bundle: UIKitSettings.bundle, comment: "")
                    if cell.typing.isHidden == false{
                        cell.typing.isHidden = true
                        cell.message.isHidden = false
                    }
                    cell.reloadInputViews()
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
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView {
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
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView {
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
        if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == user.uid}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView {
                    cell.status.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.8039215686, blue: 0.1960784314, alpha: 1)
                    cell.reloadInputViews()
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
        if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == user.uid}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView {
                    cell.status.backgroundColor = #colorLiteral(red: 0.9529411793, green: 0.6862745285, blue: 0.1333333403, alpha: 1)
                    cell.reloadInputViews()
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
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
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
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
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
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
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
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
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
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
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
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
    }
    
    
    /// This method triggers when someone added in  the  group.
    /// - Parameters:
    ///   - action:  Spcifies `ActionMessage` Object
    ///   - addedBy: Specifies `User` Object
    ///   - addedUser: Specifies `User` Object
    ///   - addedTo: Specifies `Group` Object
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        DispatchQueue.main.async { CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true) }
        refreshConversations()
    } 
}

/*  ----------------------------------------------------------------------------------------- */
