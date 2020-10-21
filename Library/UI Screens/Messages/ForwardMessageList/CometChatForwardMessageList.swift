
//  CometChatForwardMessageList.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.


/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatForwardMessageList: CometChatForwardMessageList is a view controller with a list of recent conversations. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>> */

// MARK: - Importing Frameworks.

import UIKit
import CometChatPro

// MARK: - Declaring Protocol.

public protocol ForwardMessageListDelegate : AnyObject{
    /**
     This method triggers when user taps perticular conversation in CometChatForwardMessageList
     - Parameters:
     - conversation: Specifies the `conversation` Object for selected cell.
     - indexPath: Specifies the indexpath for selected conversation.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    func didSelectConversationAtIndexPath(conversation: Conversation, indexPath: IndexPath)
}

/*  ----------------------------------------------------------------------------------------- */

public class CometChatForwardMessageList: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: 15).setConversationType(conversationType: .none).build()
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var conversations: [Conversation] = [Conversation]()
    var filteredConversations: [Conversation] = [Conversation]()
    weak var delegate : ForwardMessageListDelegate?
    var message: BaseMessage?
    var activityIndicator:UIActivityIndicatorView?
    var selectedConversations:[Conversation] = [Conversation]()
    
    
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupDelegates()
        self.refreshConversations()
        self.setupNavigationBar()
        self.addForwardButton(bool: true)
        set(title: NSLocalizedString("FORWARD_MESSAGE", bundle: UIKitSettings.bundle, comment: ""), mode: .always)
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        self.setupDelegates()
        refreshConversations()
    }
    
    
    // MARK: - Public instance methods
    
    /**
     This method specifies the navigation bar title for CometChatForwardMessageList.
     - Parameters:
     - title: This takes the String to set title for CometChatForwardMessageList.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
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
    
    
    @objc public func set(message: BaseMessage){
        
        self.message = message
        
    }
    
    
    
    // MARK: - Private instance methods
    
    /**
     This method fetches the list of recent Converversations from  Server using **ConversationRequest** Class.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    private func refreshConversations(){
        DispatchQueue.main.async {
            self.activityIndicator?.startAnimating()
            self.activityIndicator?.frame = CGRect(x: CGFloat(0), y: CGFloat(0), width: self.tableView.bounds.width, height: CGFloat(44))
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView = self.activityIndicator
            self.tableView.tableFooterView?.isHidden = false
        }
        conversationRequest = ConversationRequest.ConversationRequestBuilder(limit: 30).setConversationType(conversationType: .none).build()
        conversationRequest.fetchNext(onSuccess: { (fetchedConversations) in
            var newConversations: [Conversation] =  [Conversation]()
            for conversation in fetchedConversations {
                if conversation.lastMessage == nil { }else{
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
     This method register the delegate for real time events from CometChatPro SDK.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    private  func setupDelegates(){
        CometChat.messagedelegate = self
        CometChat.userdelegate = self
        CometChat.groupdelegate = self
    }
    
    /**
     This method setup the tableview to load CometChatForwardMessageList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
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
        self.tableView.allowsMultipleSelection = true
        self.tableView.allowsMultipleSelectionDuringEditing = true
        tableView.isEditing = true
        self.registerCells()
    }
    
    /**
     This method register 'CometChatConversationView' cell in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatUserList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-1-comet-chat-user-list)
     */
    private func registerCells(){
        let CometChatConversationView  = UINib.init(nibName: "CometChatConversationView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatConversationView, forCellReuseIdentifier: "conversationView")
    }
    
    /**
     This method setup navigationBar for conversationList viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
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
            }}
    }
    
    
    
    private func addForwardButton(bool: Bool){
        if bool == true {
            let forward = UIBarButtonItem(title: NSLocalizedString(
            "FORWARD", bundle: UIKitSettings.bundle, comment: ""), style: .done, target: self, action: #selector(self.didForwardButtonPressed))
            forward.tintColor = UIKitSettings.primaryColor
            self.navigationItem.rightBarButtonItem = forward
            self.navigationController?.navigationBar.tintColor = UIKitSettings.primaryColor
        }
    }
    
    @objc func didForwardButtonPressed() {
        if selectedConversations.count <= 5 {
            CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
            if let message = message {
                for conversation in selectedConversations {
                    switch conversation.conversationType {
                    case .user:
                        switch message.messageCategory {
                        case .message:
                            switch message.messageType {
                            case .text:
                                if let message = message as? TextMessage {
                                    message.receiverUid = (conversation.conversationWith as? User)?.uid ?? ""
                                    message.receiverType = .user
                                    CometChat.sendTextMessage(message: message, onSuccess: { (message) in
                                        DispatchQueue.main.async {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    }) { (error) in
                                        DispatchQueue.main.async {
                                            if let name = (conversation.conversationWith as? User)?.name {
                                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("UNABLE_TO_FORWARD" , bundle: UIKitSettings.bundle, comment: "") + name, duration: .short)
                                                snackbar.show()
                                            }
                                        }
                                    }
                                }
                            case .image, .video , .audio, .file:
                                if let message = message as? MediaMessage {
                                    CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                                    let message = MediaMessage(receiverUid: (conversation.conversationWith as? User)?.uid ?? "", fileurl: message.attachment?.fileUrl ?? "", messageType: message.messageType, receiverType: message.receiverType)
                                    message.receiverType = .user
                                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                                        DispatchQueue.main.async {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    }) { (error) in
                                        DispatchQueue.main.async {
                                            if let name = (conversation.conversationWith as? User)?.name {
                                               let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("UNABLE_TO_FORWARD" , bundle: UIKitSettings.bundle, comment: "") + name, duration: .short)
                                               snackbar.show()
                                            }
                                        }
                                    }
                                }
                            case .custom: break
                            case .groupMember:break
                            @unknown default: break
                            }
                        case .action: break
                        case .call: break
                        case .custom: break
                        @unknown default: break }
                        
                    case .group:
                        switch message.messageCategory {
                        case .message:
                            switch message.messageType {
                            case .text:
                                if let message = message as? TextMessage {
                                    message.receiverUid = (conversation.conversationWith as? Group)?.guid ?? ""
                                    message.receiverType = .group
                                    CometChat.sendTextMessage(message: message, onSuccess: { (message) in
                                        DispatchQueue.main.async {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    }) { (error) in
                                        DispatchQueue.main.async {
                                            if let name = (conversation.conversationWith as? Group)?.name {
                                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("UNABLE_TO_FORWARD" , bundle: UIKitSettings.bundle, comment: "") + name, duration: .short)
                                                snackbar.show()
                                            }
                                        }
                                    }
                                }
                            case .image, .video , .audio, .file:
                                if let message = message as? MediaMessage {
                                    let message = MediaMessage(receiverUid: (conversation.conversationWith as? Group)?.guid ?? "", fileurl: message.attachment?.fileUrl ?? "", messageType: message.messageType, receiverType: message.receiverType)
                                    message.receiverType = .group
                                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                                      DispatchQueue.main.async {
                                            self.navigationController?.popToRootViewController(animated: true)
                                        }
                                    }) { (error) in
                                        DispatchQueue.main.async {
                                            if let name = (conversation.conversationWith as? Group)?.name {
                                               let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("UNABLE_TO_FORWARD" , bundle: UIKitSettings.bundle, comment: "") + name, duration: .short)
                                                                                             snackbar.show()
                                            }
                                        }
                                    }
                                }
                            case .custom: break
                            case .groupMember:break
                            @unknown default: break
                            }
                        case .action: break
                        case .call: break
                        case .custom: break
                        @unknown default: break }
                    case .none: break
                    @unknown default: break
                    }
                }
            }
        }else{
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: NSLocalizedString("FORWARD_TO_5_AT_A_TIME", bundle: UIKitSettings.bundle, comment: ""), duration: .short)
            snackbar.show()
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatForwardMessageList: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies height for section in CometChatForwardMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    /// This method specifies the view for header  in CometChatForwardMessageList
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
    
    /// This method specifiesnumber of rows in CometChatForwardMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return conversations.count
        
    }
    
    /// This method specifies the height for row in CometChatForwardMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    /// This method specifies the view for user  in CometChatForwardMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "conversationView", for: indexPath) as! CometChatConversationView
        let  conversation = conversations[safe:indexPath.row]
        cell.conversation = conversation
        return cell
    }
    
    /// This method triggers when particulatr cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let selectedConversation = tableView.cellForRow(at: indexPath) as? CometChatConversationView else{
            return
        }
        guard let conversation = selectedConversation.conversation else{
            return
        }
        
        if tableView.isEditing == true{
            if !selectedConversations.contains(conversation) {
                       selectedConversations.append(conversation)
            
        }
    }
    }
    
    
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        
        guard let selectedConversation = tableView.cellForRow(at: indexPath) as? CometChatConversationView else{
            return
        }
        guard let conversation = selectedConversation.conversation else{
                   return
               }
        if selectedConversations.contains(conversation) {
            if let index = selectedConversations.firstIndex(where: { $0.conversationId == conversation.conversationId }) {
                selectedConversations.remove(at: index)
            }
        }
    }
}



/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatMessageDelegate Delegate

extension CometChatForwardMessageList : CometChatMessageDelegate {
    
    /**
     This method triggers when real time text message message arrives from CometChat Pro SDK
     - Parameter textMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onTextMessageReceived(textMessage: TextMessage) {
        refreshConversations()
    }
    
    /**
     This method triggers when real time media message arrives from CometChat Pro SDK
     - Parameter mediaMessage: This Specifies MediaMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        refreshConversations()
    }
    
    /**
     This method triggers when real time event for  start typing received from  CometChat Pro SDK
     - Parameter typingDetails: This specifies TypingIndicator Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
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
                    cell.typing.text = user! + NSLocalizedString("IS_TYPING", bundle: UIKitSettings.bundle, comment: "")
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
                    cell.typing.text = user! + NSLocalizedString("IS_TYPING", bundle: UIKitSettings.bundle, comment: "")
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
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
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

extension CometChatForwardMessageList : CometChatUserDelegate {
    /**
     This method triggers users comes online from user list.
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
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
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
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

extension CometChatForwardMessageList : CometChatGroupDelegate {
    
    /**
     This method triggers when someone joins group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - joinedUser: Specifies `User` Object
     - joinedGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
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
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
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
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
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
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
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
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
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
     [CometChatForwardMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-3-comet-chat-conversation-list)
     */
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        refreshConversations()
    }
    
    
    /// This method triggers when someone added in  the  group.
    /// - Parameters:
    ///   - action:  Spcifies `ActionMessage` Object
    ///   - addedBy: Specifies `User` Object
    ///   - addedUser: Specifies `User` Object
    ///   - addedTo: Specifies `Group` Object
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        refreshConversations()
    }
}

/*  ----------------------------------------------------------------------------------------- */
