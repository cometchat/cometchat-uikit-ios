//
//  CometChatListView.swift
//  CometChatUIKit
//
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

public protocol ConversationListDelegate {
    func didSelectConversationAtIndexPath(conversation: Conversation, indexPath: IndexPath)
}


public class CometChatConversationList: UIViewController {
    
    var conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: 100).setConversationType(conversationType: .none).build()
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var conversations: [Conversation] = [Conversation]()
    var filteredConversations: [Conversation] = [Conversation]()
    var delegate : ConversationListDelegate?
    var storedVariable: String?
    var activityIndicator:UIActivityIndicatorView?
    var searchedText: String = ""
    var searchController:UISearchController = UISearchController(searchResultsController: nil)
    
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupDelegates()
        self.refreshConversations()
        self.setupNavigationBar()
       self.setupSearchBar()
        print(#function)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
             self.setupDelegates()
             refreshConversations()
         }
    
    
    public func setupDelegates(){
        CometChat.messagedelegate = self
        CometChat.userdelegate = self
        CometChat.groupdelegate = self
    }
       
    
    func setupTableView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
            activityIndicator = UIActivityIndicatorView(style: .medium)
        } else {}
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
        let CometChatConversationView  = UINib.init(nibName: "CometChatConversationView", bundle: nil)
        self.tableView.register(CometChatConversationView, forCellReuseIdentifier: "conversationView")
    }
    
   private func setupNavigationBar(){
        if navigationController != nil{
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
            navBarAppearance.titleTextAttributes = [.font: UIFont (name: "SFProDisplay-Regular", size: 20) as Any]
            navBarAppearance.largeTitleTextAttributes = [.font: UIFont(name: "SFProDisplay-Bold", size: 35) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                self.navigationController?.navigationBar.isTranslucent = true
                
            }
        }
    }
    
    @objc public func set(title : String, mode: UINavigationItem.LargeTitleDisplayMode){
       if navigationController != nil{
                  navigationItem.title = NSLocalizedString(title, comment: "")
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
    
    func setupSearchBar(){
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
                    }
                }
                tableView.tableHeaderView = searchController.searchBar
            }
            
        } else {}
    }
    
    // MARK: - Private instance methods
       func searchBarIsEmpty() -> Bool {
           return searchController.searchBar.text?.isEmpty ?? true
       }
       
       func isSearching() -> Bool {
           let searchBarScopeIsFiltering = searchController.searchBar.selectedScopeButtonIndex != 0
           return searchController.isActive && (!searchBarIsEmpty() || searchBarScopeIsFiltering)
       }
   
    
    internal func refreshConversations(){
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
            self.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44))
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView?.isHidden = false
        }
       
        conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: 30).setConversationType(conversationType: .none).build()
        
        conversationRequest.fetchNext(onSuccess: { (fetchedConversations) in
            print("fetchedConversations onSuccess: \(fetchedConversations)")
            
            var newConversations: [Conversation] =  [Conversation]()
            
            for conversation in fetchedConversations {
                
                if conversation.lastMessage == nil {
                    
                }else{
                    newConversations.append(conversation)
                }
            }
             self.conversations = newConversations
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.tableView.tableFooterView?.isHidden = true
                    self.tableView.reloadData()
                }
        }) { (error) in
            print("refreshConversations error:\(String(describing: error?.errorDescription))")
        }
    }
}

extension CometChatConversationList: UITableViewDelegate , UITableViewDataSource {
     
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 0.5))
        return returnedView
    }
    
    // MARK: - Table view data source
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
    if isSearching(){
        return filteredConversations.count
    }else{
        return conversations.count
    }
    }
    
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationView", for: indexPath) as! CometChatConversationView
         var conversation: Conversation?
          cell.searchedText = searchedText
         if isSearching() {
               conversation = filteredConversations[indexPath.row]
              
           } else {
               conversation = conversations[indexPath.row]
           }
    
    print(" con user: \(String(describing: (conversation?.conversationWith as? User)?.stringValue()))")
        cell.conversation = conversation
        return cell
    }
    
   public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let selectedConversation = tableView.cellForRow(at: indexPath) as? CometChatConversationView else{
            return
        }
    

    
       switch selectedConversation.conversation.conversationType {
         case .user:
             let convo1: CometChatMessageList = CometChatMessageList()
             convo1.set(conversationWith: ((selectedConversation.conversation.conversationWith as? User)!), type: .user)
             convo1.hidesBottomBarWhenPushed = true
             navigationController?.pushViewController(convo1, animated: true)
         case .group:
            let convo1: CometChatMessageList = CometChatMessageList()
             convo1.set(conversationWith: ((selectedConversation.conversation.conversationWith as? Group)!), type: .group)
               convo1.hidesBottomBarWhenPushed = true
               navigationController?.pushViewController(convo1, animated: true)
             
         case .none: break
         @unknown default: break
         }
    
        delegate?.didSelectConversationAtIndexPath(conversation: selectedConversation.conversation!, indexPath: indexPath)
    }
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// MARK: - UISearchResultsUpdating Delegate
extension CometChatConversationList : UISearchBarDelegate, UISearchResultsUpdating {
    
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

extension CometChatConversationList : CometChatMessageDelegate {
    
   public func onTextMessageReceived(textMessage: TextMessage) {
        refreshConversations()
    }
    
   public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        refreshConversations()
    }
    
   public func onTypingStarted(_ typingDetails: TypingIndicator) {
        if let row = self.conversations.firstIndex(where: {($0.conversationWith as? User)?.uid == typingDetails.sender?.uid && $0.conversationType.rawValue == typingDetails.receiverType.rawValue }) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView {
                    if cell.message.isHidden == false{
                                       cell.typing.isHidden = false
                                       cell.message.isHidden = true
                                   }
                                   cell.reloadInputViews()
                }
            }
        }
        
        if let row = self.conversations.firstIndex(where: {($0.conversationWith as? Group)?.guid == typingDetails.receiverID && $0.conversationType.rawValue == typingDetails.receiverType.rawValue}) {
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async {
                if let cell = self.tableView.cellForRow(at: indexPath) as? CometChatConversationView {
                    let user = typingDetails.sender?.name
                    cell.typing.text = user! + " is typing..."
                    if cell.message.isHidden == false{
                        cell.typing.isHidden = false
                        cell.message.isHidden = true
                    }
                    cell.reloadInputViews()
                }
            }
        }
    }
    
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
                }}
        }
    }
    
}

extension CometChatConversationList : CometChatUserDelegate {
    
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

extension CometChatConversationList : CometChatGroupDelegate {
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
         refreshConversations()
    }
    
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
         refreshConversations()
    }
    
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
         refreshConversations()
    }
    
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
         refreshConversations()
    }
    
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
         refreshConversations()
    }
    
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
         refreshConversations()
    }
    
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
         refreshConversations()
    } 
}

