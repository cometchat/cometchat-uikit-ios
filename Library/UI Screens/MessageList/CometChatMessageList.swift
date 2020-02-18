
//  CometChatMessageList.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatMessageList: The CometChatMessageList is a view controller with a list of messages for a particular user or group. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.

import UIKit
import WebKit
import AVKit
import AVFoundation
import QuickLook
import AudioToolbox
import CometChatPro

enum MessageMode {
    case edit
    case send
}


enum HideView {
    case blockedView
    case smartRepliesView
    case editMessageView
}

enum CometChatExtension {
    case linkPreview
    case smartReply
    case none
}

/*  ----------------------------------------------------------------------------------------- */

public class CometChatMessageList: UIViewController {
    
    // MARK: - Declaration of Outlets
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var chatView: ChatView!
    @IBOutlet weak var messageActionView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockedView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editViewName: UILabel!
    @IBOutlet weak var editViewMessage: UILabel!
    @IBOutlet weak var blockedMessage: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var forwardButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var smartRepliesView: SmartRepliesView!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet{
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    // MARK: - Declaration of Variables
    
    var currentUser: User?
    var currentGroup: Group?
    var currentEntity: CometChat.ReceiverType?
    var messageRequest:MessagesRequest?
    var memberRequest: GroupMembersRequest?
    var groupMembers: [GroupMember]?
    var messages: [BaseMessage] = [BaseMessage]()
    var filteredMessages:[BaseMessage] = [BaseMessage]()
    var typingIndicator: TypingIndicator?
    var safeArea: UILayoutGuide!
    let modelName = UIDevice.modelName
    var titleView : UIView?
    var buddyStatus: UILabel?
    var isGroupIs : Bool = false
    var refreshControl: UIRefreshControl!
    var membersCount:String?
    var messageMode: MessageMode = .send
    var selectedIndexPath: IndexPath?
    var selectedMessage: BaseMessage?
    lazy var previewItem = NSURL()
    var quickLook = QLPreviewController()
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        setupSuperview()
        setupDelegates()
        setupTableView()
        registerCells()
        setupChatView()
        setupKeyboard()
        self.addObsevers()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        setupDelegates()
        hideSystemBackButton(bool: true)
    }
    
    // MARK: - Public instance methods
    
    
    /**
     This method specifies the entity of user or group which user wants to begin the conversation.
     - Parameters:
     - conversationWith: Spcifies `AppEntity` Object which can take `User` or `Group` Object.
     - type: Spcifies a type of `AppEntity` such as `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func set(conversationWith: AppEntity, type: CometChat.ReceiverType){
        switch type {
        case .user:
            isGroupIs = false
            guard let user = conversationWith as? User else{ return }
            currentUser = user
            currentEntity = .user
            fetchUserInfo(user: user)
            switch (conversationWith as? User)!.status {
            case .online:
                setupNavigationBar(withTitle: user.name?.capitalized ?? "")
                setupNavigationBar(withSubtitle: "online")
                setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "")
            case .offline:
                setupNavigationBar(withTitle: user.name?.capitalized ?? "")
                setupNavigationBar(withSubtitle: "offline")
                setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "")
            @unknown default:break
            }
            self.refreshMessageList(forID: user.uid ?? "" , type: .user)
            
        case .group:
            isGroupIs = true
            guard let group = conversationWith as? Group else{
                return
            }
            currentGroup = group
            currentEntity = .group
            setupNavigationBar(withTitle: group.name?.capitalized ?? "")
            setupNavigationBar(withImage: group.icon ?? "", name: group.name ?? "")
            fetchGroupMembers(group: group)
            self.refreshMessageList(forID: group.guid , type: .group)
            
        @unknown default:
            break
        }
    }
    
    // MARK: - CometChatPro Instance Methods
    
    /**
     This method fetches the older messages from the server using `MessagesRequest` class.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchPreviousMessages(messageReq:MessagesRequest){
        messageReq.fetchPrevious(onSuccess: { (fetchedMessages) in
            if fetchedMessages?.count == 0 {
                DispatchQueue.main.async{
                    self.refreshControl.endRefreshing()
                }
            }
            guard let messages = fetchedMessages?.filter({
                ($0 as? TextMessage  != nil && $0.messageType == .text)  ||
                    ($0 as? MediaMessage != nil && $0.messageType == .image) ||
                    ($0 as? MediaMessage != nil && $0.messageType == .file)  ||
                    ($0 as? ActionMessage != nil && (($0 as? ActionMessage)?.message != "Message is deleted." && ($0 as? ActionMessage)?.message != "Message is edited."))
            }) else {
                return }
            guard let lastMessage = messages.last else { return }
            if self.isGroupIs == true {
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: self.currentGroup?.guid ?? "", receiverType: .group)
            }else{
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: self.currentUser?.uid ?? "", receiverType: .user)
            }
            var oldMessages = [BaseMessage]()
            for msg in messages{ oldMessages.append(msg) }
            let oldMessageArray =  oldMessages
            self.messages.insert(contentsOf: oldMessageArray, at: 0)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.refreshControl.endRefreshing()
            }
        }) { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                    self.view.makeToast(errorMessage)
                }
                self.refreshControl.endRefreshing()
            }
            print("fetchPreviousMessages error: \(String(describing: error?.errorDescription))")
        }
    }
    
    
    /**
     This method refreshes the  messages  using `MessagesRequest` class.
     - Parameters:
     - forID: This specifies a string value which takes `uid` or `guid`.
     - type: This specifies `ReceiverType` Object which can be `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func refreshMessageList(forID: String, type: CometChat.ReceiverType){
        messages.removeAll()
        switch type {
        case .user:
            messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).set(limit: 30).build()
            messageRequest?.fetchPrevious(onSuccess: { (fetchedMessages) in
                guard let messages = fetchedMessages?.filter({
                    ($0 as? TextMessage  != nil && $0.messageType == .text)  ||
                        ($0 as? MediaMessage != nil && $0.messageType == .image) ||
                        ($0 as? MediaMessage != nil && $0.messageType == .file)  ||
                        ($0 as? ActionMessage != nil && (($0 as? ActionMessage)?.message != "Message is deleted." && ($0 as? ActionMessage)?.message != "Message is edited."))
                }) else { return }
                guard let lastMessage = messages.last else {
                    return
                }
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: forID, receiverType: .user)
                self.messages.append(contentsOf: messages)
                self.filteredMessages = messages.filter {$0.sender?.uid == CometChat.getLoggedInUser()?.uid}
                DispatchQueue.main.async {
                    if lastMessage.sender?.uid != CometChat.getLoggedInUser()?.uid {
                        if let lastMessage = lastMessage as? TextMessage {
                            let titles = self.parseSmartRepliesMessages(message: lastMessage)
                            self.smartRepliesView.set(titles: titles)
                            self.hide(view: .smartRepliesView, false)
                        }
                    }else{
                        self.hide(view: .smartRepliesView, true)
                    }
                    self.tableView?.reloadData()
                    self.tableView?.scrollToBottomRow()
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        self.view.makeToast(errorMessage)
                    }
                }
                print("error while fetching messages for user: \(String(describing: error?.errorDescription))")
            })
            typingIndicator = TypingIndicator(receiverID: forID, receiverType: .user)
        case .group:
            messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).set(limit: 30).build()
            messageRequest?.fetchPrevious(onSuccess: { (fetchedMessages) in
                guard let messages = fetchedMessages?.filter({
                    ($0 as? TextMessage  != nil && $0.messageType == .text)  ||
                        ($0 as? MediaMessage != nil && $0.messageType == .image) ||
                        ($0 as? MediaMessage != nil && $0.messageType == .file)  ||
                        ($0 as? ActionMessage != nil && (($0 as? ActionMessage)?.message != "Message is deleted." && ($0 as? ActionMessage)?.message != "Message is edited."))
                }) else { return }
                guard let lastMessage = messages.last else {
                    return
                }
                CometChat.markAsRead(messageId: lastMessage.id, receiverId: forID, receiverType: .group)
                self.messages.append(contentsOf: messages)
                self.filteredMessages = messages.filter {$0.sender?.uid == CometChat.getLoggedInUser()?.uid}
                DispatchQueue.main.async {
                    if lastMessage.sender?.uid != CometChat.getLoggedInUser()?.uid {
                        if let lastMessage = lastMessage as? TextMessage {
                            let titles = self.parseSmartRepliesMessages(message: lastMessage)
                            self.smartRepliesView.set(titles: titles)
                            self.hide(view: .smartRepliesView, false)
                        }
                    }else{
                        self.hide(view: .smartRepliesView, true)
                    }
                    self.tableView?.reloadData()
                    self.tableView?.scrollToBottomRow()
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        self.view.makeToast(errorMessage)
                    }
                }
                print("error while fetching messages for group: \(String(describing: error?.errorDescription))")
            })
            typingIndicator = TypingIndicator(receiverID: forID, receiverType: .group)
        @unknown default:
            break
        }
    }
    
    /**
     This method fetches the  user information for particular user.
     - Parameter user: This specifies a  `User` Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchUserInfo(user: User){
        CometChat.getUser(UID: user.uid ?? "", onSuccess: { (user) in
            if  user?.blockedByMe == true {
                if let name = self.currentUser?.name {
                    DispatchQueue.main.async {
                        self.hide(view: .blockedView, false)
                        self.blockedMessage.text = "You've blocked \(String(describing: name.capitalized))"
                    }
                }
            }
        }) { (error) in
            
            print("error while getUser info: \(String(describing: error?.errorDescription))")
        }
    }
    
    
    /**
     This method fetches list of  group members  for particular group.
     - Parameter group: This specifies a  `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchGroupMembers(group: Group){
        memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: group.guid).set(limit: 100).build()
        memberRequest?.fetchNext(onSuccess: { (groupMember) in
            self.groupMembers = groupMember
            if groupMember.count < 100 {
                self.setupNavigationBar(withTitle: group.name?.capitalized ?? "")
                self.setupNavigationBar(withSubtitle: "\(groupMember.count) Members")
                self.membersCount = "\(groupMember.count) Members"
            }else{
                self.setupNavigationBar(withSubtitle: "100+ Members")
                self.membersCount = "100+ Members"
            }
        }, onError: { (error) in
            print("Group Member list fetching failed with exception:" + error!.errorDescription);
        })
    }
    
    /**
     This method refreshes list of   group members  for particular guid.
     - Parameter guid: This specifies a  `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func refreshGroupMembers(guid: String){
        memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: guid).set(limit: 100).build()
        memberRequest?.fetchNext(onSuccess: { (groupMember) in
            self.groupMembers = groupMember
            if groupMember.count < 100 {
                self.setupNavigationBar(withSubtitle: "\(groupMember.count) Members")
            }else{
                self.setupNavigationBar(withSubtitle: "100+ Members")
            }
        }, onError: { (error) in
            print("Group Member list fetching failed with exception:" + error!.errorDescription);
        })
    }
    
    /**
     This method detects the extension is enabled or not for smart replies and link preview.
     - Parameter message: This specifies `TextMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func didExtensionDetected(message: TextMessage) -> CometChatExtension {
        var detectedExtension: CometChatExtension?
        if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String : Any], let linkArray = linkPreviewDictionary["links"] as? [[String: Any]], let _ = linkArray[safe: 0] {
            
            detectedExtension = .linkPreview
        }else if  let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["smart-reply"] as? [String : Any] {
            
            detectedExtension = .smartReply
        }
        return detectedExtension ?? .none
    }
    
    
    /**
     This method parse the smart replies data from `TextMessage` Object.
     - Parameter message: This specifies `TextMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func parseSmartRepliesMessages(message: TextMessage) -> [String] {
        var replyMessages: [String] = [String]()
        if  let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let smartReply = cometChatExtension["smart-reply"] as? [String : Any] {
            
            print("smartReply: \(smartReply)")
            if let positive = smartReply["reply_positive"] {
                replyMessages.append(positive as! String)
            }
            if let neutral = smartReply["reply_neutral"] {
                replyMessages.append(neutral as! String)
            }
            if let negative = smartReply["reply_negative"] {
                replyMessages.append(negative as! String)
            }
        }
        return replyMessages
    }
    
    
    
    // MARK: - Private instance methods
    
    /**
     This method setup the view to load CometChatMessageList.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupSuperview() {
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatMessageList", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
    }
    
    /**
     This method register the delegate for real time events from CometChatPro SDK.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupDelegates(){
        
        CometChat.messagedelegate = self
        CometChat.userdelegate = self
        CometChat.groupdelegate = self
        documentPicker.delegate = self
        smartRepliesView.smartRepliesDelegate = self
        quickLook.dataSource = self
    }
    
    /**
     This method observers for the notifications of certain events.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addObsevers(){
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserBlocked(_:)), name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserUnblocked(_:)), name: NSNotification.Name(rawValue: "didUserUnblocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupDeleted(_:)), name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
    }
    
    /**
     This method triggers when group is deleted.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didGroupDeleted(_ notification: NSNotification) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     This method triggers when user has been unblocked.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didUserUnblocked(_ notification: NSNotification) {
        DispatchQueue.main.async {
            self.hide(view: .blockedView, true)
        }
    }
    
    /**
     This method triggers when user has been blocked.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didUserBlocked(_ notification: NSNotification) {
        if let name = notification.userInfo?["name"] as? String {
            self.hide(view: .blockedView, false)
            blockedMessage.text = "You've blocked \(String(describing: name.capitalized))"
        }
    }
    
    /**
     This method refreshes group details.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didRefreshGroupDetails(_ notification: NSNotification) {
        if let guid = notification.userInfo?["guid"] as? String {
            self.refreshMessageList(forID: guid, type: .group)
            self.refreshGroupMembers(guid: guid)
        }
    }
    
    /**
     This method hides system defaults back button.
     - Parameter bool: specified `Bool` value.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func hideSystemBackButton(bool: Bool) {
        if self.navigationController != nil {
            if bool == true {
                self.navigationItem.hidesBackButton = true
            }
        }
    }
    
    /**
     This method setup navigationBar title for messageList viewController.
     - Parameter title: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withTitle title: String){
        DispatchQueue.main.async {
            if self.navigationController != nil {
                self.addBackButton()
                self.navigationItem.largeTitleDisplayMode = .never
                self.titleView = UIView(frame: CGRect(x: 0, y: 0, width: (self.navigationController?.navigationBar.bounds.size.width)! - 200, height: 50))
                let buddyName = UILabel(frame: CGRect(x:0,y: 3,width: 200 ,height: 21))
                self.buddyStatus = UILabel(frame: CGRect(x:0,y: (self.titleView?.frame.origin.y ?? 0.0) + 22,width: 200,height: 21))
                self.buddyStatus?.textColor = #colorLiteral(red: 0.2, green: 0.6, blue: 1, alpha: 1)
                self.buddyStatus?.font = UIFont (name: "SFProDisplay-Regular", size: 15)
                self.buddyStatus?.textAlignment = NSTextAlignment.center
                self.navigationItem.titleView = self.titleView
                if #available(iOS 13.0, *) {
                    buddyName.textColor = .label
                    buddyName.font = UIFont (name: "SFProDisplay-Medium", size: 17)
                    buddyName.textAlignment = NSTextAlignment.center
                    buddyName.text = title
                } else {
                    buddyName.textColor = .black
                    buddyName.font = UIFont (name: "SFProDisplay-Medium", size: 17)
                    buddyName.textAlignment = NSTextAlignment.center
                    buddyName.text = title
                }
                self.titleView?.addSubview(buddyName)
                self.titleView?.addSubview(self.buddyStatus!)
                self.titleView?.center = CGPoint(x: 0, y: 0)
                let tapOnTitleView = UITapGestureRecognizer(target: self, action: #selector(self.didPresentDetailView(tapGestureRecognizer:)))
                self.titleView?.isUserInteractionEnabled = true
                self.titleView?.addGestureRecognizer(tapOnTitleView)
            }
        }
    }
    
    
    /**
     This method adds back button in navigation bar.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addBackButton() {
        let backButton = UIButton(type: .custom)
        backButton.setImage(#imageLiteral(resourceName: "back"), for: .normal) // Image can be downloaded from here below link
        backButton.setTitle(" Back", for: .normal)
        backButton.setTitleColor(backButton.tintColor, for: .normal) // You can change the TitleColor
        backButton.addTarget(self, action: #selector(self.didBackButtonPressed(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    /**
     This method triggeres when user pressed back button.
     - Parameter title: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didBackButtonPressed(_ sender: UIButton) {
        switch self.isModal() {
        case true:
            self.dismiss(animated: true, completion: nil)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
        case false:
            let _ = self.navigationController?.popViewController(animated: true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
        }
    }
    
    /**
     This method setup navigationBar subtitle  for messageList viewController.
     - Parameter subtitle: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withSubtitle subtitle: String){
        DispatchQueue.main.async {
            self.buddyStatus?.text = subtitle
        }
    }
    
    /**
     This method setup navigationBar subtitle  for messageList viewController.
     - Parameter URL: This spefies a string value which takes URL and loads the Avatar.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withImage URL: String, name: String){
        DispatchQueue.main.async {
            // Avatar apperance:
            let avatarView = UIView(frame: CGRect(x: -10 , y: 0, width: 40, height: 40))
            avatarView.backgroundColor = UIColor.clear
            avatarView.layer.masksToBounds = true
            avatarView.layer.cornerRadius = 19
            let avatar = Avatar(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            avatar.set(cornerRadius: 19).set(borderColor: .clear).set(backgroundColor: #colorLiteral(red: 0.6274509804, green: 0.7607843137, blue: 1, alpha: 1)).set(image: URL, with: name)
            avatarView.addSubview(avatar)
            let rightBarButton = UIBarButtonItem(customView: avatarView)
            self.navigationItem.rightBarButtonItem = rightBarButton
            let tapOnAvatar = UITapGestureRecognizer(target: self, action: #selector(self.didPresentDetailView(tapGestureRecognizer:)))
            avatarView.isUserInteractionEnabled = true
            avatarView.addGestureRecognizer(tapOnAvatar)
        }
    }
    
    /**
     This method triggers when user taps on AvatarView in Navigation var
     - Parameter tapGestureRecognizer: A concrete subclass of UIGestureRecognizer that looks for single or multiple taps.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didPresentDetailView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let entity = currentEntity else { return }
        switch entity{
        case .user:
            guard let user = currentUser else { return }
            if self.chatView.frame.origin.y != 0 { dismissKeyboard() }
            let userDetailView = CometChatUserDetail()
            let navigationController = UINavigationController(rootViewController: userDetailView)
            userDetailView.set(user: user)
            userDetailView.isPresentedFromMessageList = true
            self.present(navigationController, animated: true, completion: nil)
        case .group:
            guard let group = currentGroup else { return }
            let groupDetailView = CometChatGroupDetail()
            let navigationController = UINavigationController(rootViewController: groupDetailView)
            groupDetailView.set(group: group, with: groupMembers ?? [])
            
            self.present(navigationController, animated: true, completion: nil)
        @unknown default:break
        }
    }
    
    /**
     This method triggers when user long press on Particular message bubble.
     - Parameter tapGestureRecognizer: A concrete subclass of UIGestureRecognizer that looks for single or multiple taps.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView?.indexPathForRow(at: touchPoint) {
                self.selectedIndexPath = indexPath
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightTextMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.textMessage
                    editButton.isHidden = false
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightFileMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.fileMessage
                    editButton.isHidden = true
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightLinkPreviewBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.linkPreviewMessage
                    editButton.isHidden = true
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? RightImageMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.mediaMessage
                    editButton.isHidden = true
                    deleteButton.isHidden = false
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  (tableView?.cellForRow(at: indexPath) as? LeftTextMessageBubble) != nil {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    editButton.isHidden = true
                    deleteButton.isHidden = true
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  (tableView?.cellForRow(at: indexPath) as? LeftImageMessageBubble) != nil {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    editButton.isHidden = true
                    deleteButton.isHidden = true
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  (tableView?.cellForRow(at: indexPath) as? LeftLinkPreviewBubble) != nil {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    editButton.isHidden = true
                    deleteButton.isHidden = true
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  (tableView?.cellForRow(at: indexPath) as? LeftFileMessageBubble) != nil {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    editButton.isHidden = true
                    deleteButton.isHidden = true
                    forwardButton.isHidden = false
                    messageActionView.isHidden = false
                }
                if  (tableView?.cellForRow(at: indexPath) as? ActionMessageBubble) != nil {
                    editButton.isHidden = true
                    deleteButton.isHidden = true
                    forwardButton.isHidden = true
                    messageActionView.isHidden = true
                }
            }
        }
    }
    
    /**
     This method setup the tableview to load CometChatMessageList.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorColor = .clear
        self.addRefreshControl(inTableView: true)
        // Added Long Press
        let longPressOnMessage = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
        tableView?.addGestureRecognizer(longPressOnMessage)
    }
    
    
    /**
     This method register All Types of MessageBubble  cells in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func registerCells(){
        
        let leftTextMessageBubble  = UINib.init(nibName: "LeftTextMessageBubble", bundle: nil)
        self.tableView?.register(leftTextMessageBubble, forCellReuseIdentifier: "leftTextMessageBubble")
        
        let rightTextMessageBubble  = UINib.init(nibName: "RightTextMessageBubble", bundle: nil)
        self.tableView?.register(rightTextMessageBubble, forCellReuseIdentifier: "rightTextMessageBubble")
        
        let leftImageMessageBubble  = UINib.init(nibName: "LeftImageMessageBubble", bundle: nil)
        self.tableView?.register(leftImageMessageBubble, forCellReuseIdentifier: "leftImageMessageBubble")
        
        let rightImageMessageBubble  = UINib.init(nibName: "RightImageMessageBubble", bundle: nil)
        self.tableView?.register(rightImageMessageBubble, forCellReuseIdentifier: "rightImageMessageBubble")
        
        let leftFileMessageBubble  = UINib.init(nibName: "LeftFileMessageBubble", bundle: nil)
        self.tableView?.register(leftFileMessageBubble, forCellReuseIdentifier: "leftFileMessageBubble")
        
        let rightFileMessageBubble  = UINib.init(nibName: "RightFileMessageBubble", bundle: nil)
        self.tableView?.register(rightFileMessageBubble, forCellReuseIdentifier: "rightFileMessageBubble")
        
        let actionMessageBubble  = UINib.init(nibName: "ActionMessageBubble", bundle: nil)
        self.tableView?.register(actionMessageBubble, forCellReuseIdentifier: "actionMessageBubble")
        
        let leftLinkPreviewBubble = UINib.init(nibName: "LeftLinkPreviewBubble", bundle: nil)
        self.tableView?.register(leftLinkPreviewBubble, forCellReuseIdentifier: "leftLinkPreviewBubble")
        
        let rightLinkPreviewBubble = UINib.init(nibName: "RightLinkPreviewBubble", bundle: nil)
        self.tableView?.register(rightLinkPreviewBubble, forCellReuseIdentifier: "rightLinkPreviewBubble")
    }
    
    /**
     This method setup the Chat View where user can type the message or send the media.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupChatView(){
        chatView.internalDelegate = self
        if #available(iOS 12.0, *) {
            if traitCollection.userInterfaceStyle == .dark {
                chatView.sticker.imageView?.image = #imageLiteral(resourceName: "stickerDark")
            }} else { }
        chatView.textView.delegate = self
        textView.delegate = self
    }
    
    /**
     This method will hide or unhide views such as blockedView, smartRepliesView and editMessageView as per user actions
     - Parameters:
     - view: This specified enum of  `HideView` which provides option such as `.blockedView`, `.smartRepliesView`,`.editMessageView`.
     - bool: specifies boolean value to hide or unhide view
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func hide(view: HideView, _ bool: Bool){
        if bool == true {
            switch view {
            case .blockedView:
                self.blockedView.isHidden = true
                self.tableViewBottomConstraint.constant = 0
            case .smartRepliesView:
                self.smartRepliesView.isHidden = true
                self.tableViewBottomConstraint.constant = 0
            case .editMessageView:
                self.editView.isHidden = true
                self.tableViewBottomConstraint.constant = 0
            }
        }else{
            switch view {
            case .blockedView:
                self.blockedView.isHidden = false
                self.tableViewBottomConstraint.constant = 144
            case .smartRepliesView:
                if !smartRepliesView.buttontitles.isEmpty {
                    self.smartRepliesView.isHidden = false
                    self.tableViewBottomConstraint.constant = 66
                    self.tableView?.scrollToBottomRow()
                }
            case .editMessageView:
                self.editView.isHidden = false
                self.tableViewBottomConstraint.constant = 66
            }
        }
    }
    
    /**
     This method add refresh control in tableview by using user will be able to load previous messages.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addRefreshControl(inTableView: Bool){
        if inTableView == true{
            // Added Refresh Control
            refreshControl = UIRefreshControl()
            refreshControl.addTarget(self, action: #selector(loadPreviousMessages), for: .valueChanged)
            tableView?.refreshControl = refreshControl
        }
    }
    
    /**
     This method add pull the list of privous messages when refresh control is triggered.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func loadPreviousMessages(_ sender: Any) {
        guard let request = messageRequest else {
            return
        }
        fetchPreviousMessages(messageReq: request)
    }
    
    
    /**
     This method handles  keyboard  events triggered by the Chat View.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupKeyboard(){
        chatView.textView.layer.cornerRadius = 4.0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView?.addGestureRecognizer(tapGesture)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /**
     This method triggers when keyboard will change its frame.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        if let endFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            var keyboardHeight = UIScreen.main.bounds.height - endFrame.origin.y
            if #available(iOS 11, *) {
                if keyboardHeight > 0 {
                    keyboardHeight = keyboardHeight - view.safeAreaInsets.bottom
                }
            }
            textViewBottomConstraint.constant = keyboardHeight + 8
            view.layoutIfNeeded()
        }
    }
    
    /**
     This method handles  keyboard  events triggered by the Chat View.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /**
     This method triggeres when user pressed the unblock button when the user is blocked.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didUnblockedUserPressed(_ sender: Any) {
        dismissKeyboard()
        if let uid =  currentUser?.uid {
            CometChat.unblockUsers([uid], onSuccess: { (success) in
                DispatchQueue.main.async {
                    self.hide(view: .blockedView, true)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        self.view.makeToast(errorMessage)
                    }
                }
                print("error while unblocking the user: \(String(describing: error?.errorDescription))")
            }
        }
    }
    
    
    /**
     This method triggeres when user pressed delete message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didDeleteMessageButtonPressed(_ sender: Any) {
        
        guard let message = selectedMessage else { return }
        guard let indexPath = selectedIndexPath else { return }
        
        CometChat.delete(messageId: message.id, onSuccess: { (deletedMessage) in
            let textMessage:BaseMessage = (deletedMessage as? ActionMessage)?.actionOn as! BaseMessage
            self.messages[indexPath.row] = textMessage
            DispatchQueue.main.async {
                self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                self.messageActionView.isHidden = true
                self.selectedMessage = nil
                self.selectedIndexPath = nil
            }
        }) { (error) in
            DispatchQueue.main.async {
                self.view.makeToast(error.errorDescription)
                self.messageActionView.isHidden = true}
            self.selectedMessage = nil
            self.selectedIndexPath = nil
            print("unable to delete message: \(error.errorDescription)")
        }
    }
    
    /**
     This method triggeres when user pressed forward message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didForwardMessageButtonPressed(_ sender: Any) {
        
    }
    
    /**
     This method triggeres when user pressed edit message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didEditMessageButtonPressed(_ sender: Any) {
        self.messageMode = .edit
        self.messageActionView.isHidden = true
        self.hide(view: .editMessageView, false)
        
        guard let message = selectedMessage else { return }
        
        if let name = message.sender?.name {
            editViewName.text = name.capitalized
        }
        
        if let message = (message as? TextMessage)?.text {
            editViewMessage.text = message
            textView.text = message
        }
    }
    
    /**
     This method triggeres when user pressed close  button on present on edit view.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didEditCloseButtonPressed(_ sender: Any) {
        self.hide(view: .editMessageView, true)
        self.selectedMessage = nil
        self.selectedIndexPath = nil
        textView.text = nil
    }
    
    
    
    
}
/*  ----------------------------------------------------------------------------------------- */

// MARK: - UIDocumentPickerDelegate 

extension CometChatMessageList: UIDocumentPickerDelegate {
    
    /// This method triggers when we open document menu to send the message of type `File`.
    /// - Parameters:
    ///   - controller: A view controller that provides access to documents or destinations outside your app’s sandbox.
    ///   - urls: A value that identifies the location of a resource, such as an item on a remote server or the path to a local file.
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            var mediaMessage: MediaMessage?
            switch self.isGroupIs {
            case true:
                mediaMessage = MediaMessage(receiverUid: currentGroup?.guid ?? "", fileurl: urls[0].absoluteString,messageType: .file, receiverType: .group)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                if let message = mediaMessage {
                    self.messages.append(message)
                    self.filteredMessages.append(message)
                    DispatchQueue.main.async {
                        self.tableView?.beginUpdates()
                        self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                        self.tableView?.endUpdates()
                        self.tableView?.scrollToBottomRow()
                    }
                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                        if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                            self.messages[row] = message}
                        DispatchQueue.main.async{ self.tableView?.reloadData()}
                    }) { (error) in
                        
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                self.view.makeToast(errorMessage)
                            }
                        }
                        print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                    }
                }
            case false:
                mediaMessage = MediaMessage(receiverUid: currentUser?.uid ?? "", fileurl: urls[0].absoluteString, messageType: .file, receiverType: .user)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                if let message = mediaMessage {
                    self.messages.append(mediaMessage!)
                    self.filteredMessages.append(message)
                    DispatchQueue.main.async {
                        self.tableView?.beginUpdates()
                        self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                        self.tableView?.endUpdates()
                        self.tableView?.scrollToBottomRow()
                    }
                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                        if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                            self.messages[row] = message}
                        DispatchQueue.main.async{ self.tableView?.reloadData()}
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                self.view.makeToast(errorMessage)
                            }
                        }
                        print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                    }
                }
            }
        }
    }
    
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatMessageList: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of messages.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// This method specifiesnumber of rows in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    /// This method specifies the height for row in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    /// This method specifies the height for row in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for message  in CometChatMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell()
        if let message = messages[safe: indexPath.row] {
            if message.messageCategory == .message {
                if message.deletedAt > 0.0 && message.senderUid != CometChat.getLoggedInUser()?.uid {
                    let  deletedCell = tableView.dequeueReusableCell(withIdentifier: "leftTextMessageBubble", for: indexPath) as! LeftTextMessageBubble
                    deletedCell.deletedMessage = message
                    return deletedCell
                    
                }else if message.deletedAt > 0.0 && message.senderUid == CometChat.getLoggedInUser()?.uid {
                    
                    let deletedCell = tableView.dequeueReusableCell(withIdentifier: "rightTextMessageBubble", for: indexPath) as! RightTextMessageBubble
                    deletedCell.deletedMessage = message
                    if  messages[safe:indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                        deletedCell.receiptStack.isHidden = false
                    }else{
                        deletedCell.receiptStack.isHidden = true
                    }
                    return deletedCell
                }else{
                    switch message.messageType {
                    case .text where message.senderUid != CometChat.getLoggedInUser()?.uid:
                        if let textMessage = message as? TextMessage {
                            let isContainsExtension = didExtensionDetected(message: textMessage)
                            switch isContainsExtension {
                            case .linkPreview:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftLinkPreviewBubble", for: indexPath) as! LeftLinkPreviewBubble
                                let linkPreviewMessage = message as? TextMessage
                                receiverCell.linkPreviewMessage = linkPreviewMessage
                                receiverCell.linkPreviewDelegate = self
                                return receiverCell
                            case .smartReply:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftTextMessageBubble", for: indexPath) as! LeftTextMessageBubble
                                receiverCell.textMessage = textMessage
                                return receiverCell
                            case .none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftTextMessageBubble", for: indexPath) as! LeftTextMessageBubble
                                receiverCell.textMessage = textMessage
                                return receiverCell
                            }
                        }
                    case .text where message.senderUid == CometChat.getLoggedInUser()?.uid:
                        if let textMessage = message as? TextMessage {
                            let isContainsExtension = didExtensionDetected(message: textMessage)
                            switch isContainsExtension {
                            case .linkPreview:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightLinkPreviewBubble", for: indexPath) as! RightLinkPreviewBubble
                                let linkPreviewMessage = message as? TextMessage
                                senderCell.linkPreviewMessage = linkPreviewMessage
                                senderCell.linkPreviewDelegate = self
                                if  messages[safe:indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                return senderCell
                            case .smartReply:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightTextMessageBubble", for: indexPath) as! RightTextMessageBubble
                                senderCell.textMessage = textMessage
                                if  messages[safe:indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                return senderCell
                            case .none:
                                let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightTextMessageBubble", for: indexPath) as! RightTextMessageBubble
                                senderCell.textMessage = textMessage
                                if  messages[safe:indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                    senderCell.receiptStack.isHidden = false
                                }else{
                                    senderCell.receiptStack.isHidden = true
                                }
                                return senderCell
                            }
                        }
                    case .image where message.senderUid != CometChat.getLoggedInUser()?.uid:
                        
                        if let imageMessage = message as? MediaMessage {
                            let receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftImageMessageBubble", for: indexPath) as! LeftImageMessageBubble
                            receiverCell.mediaMessage = imageMessage
                            return receiverCell
                        }
                        
                    case .image where message.senderUid == CometChat.getLoggedInUser()?.uid:
                        
                        if let imageMessage = message as? MediaMessage {
                            let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightImageMessageBubble", for: indexPath) as! RightImageMessageBubble
                            senderCell.mediaMessage = imageMessage
                            if  messages[safe:indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                senderCell.receiptStack.isHidden = false
                            }else{
                                senderCell.receiptStack.isHidden = true
                            }
                            return senderCell
                        }
                        
                    case .video:
                        
                        if message is MediaMessage {
                            let  videoMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                            videoMessageCell.message.text = "Video Message"
                            return videoMessageCell
                        }
                    case .audio:
                        
                        if message is MediaMessage {
                            let  audioMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                            audioMessageCell.message.text = "Audio Message"
                            return audioMessageCell
                        }
                    case .file where message.senderUid != CometChat.getLoggedInUser()?.uid:
                        
                        if let fileMessage = message as? MediaMessage {
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "leftFileMessageBubble", for: indexPath) as! LeftFileMessageBubble
                            receiverCell.fileMessage = fileMessage
                            return receiverCell
                        }
                    case .file where message.senderUid == CometChat.getLoggedInUser()?.uid:
                        
                        if let fileMessage = message as? MediaMessage {
                            let senderCell = tableView.dequeueReusableCell(withIdentifier: "rightFileMessageBubble", for: indexPath) as! RightFileMessageBubble
                            senderCell.fileMessage = fileMessage
                            if  messages[safe:indexPath.row] == filteredMessages.last || tableView.isLast(for: indexPath){
                                senderCell.receiptStack.isHidden = false
                            }else{
                                senderCell.receiptStack.isHidden = true
                            }
                            return senderCell
                        }
                    case .custom: break
                    case .groupMember:  break
                    case .image: break
                    case .text: break
                    case .file: break
                    @unknown default: break
                    }
                }
            }else if message.messageCategory == .action {
                //  ActionMessage Cell
                let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                let actionMessage = message as? ActionMessage
                actionMessageCell.message.text = actionMessage?.message
                return actionMessageCell
            }else if message.messageCategory == .call {
                
                //  CallMessage Cell
                let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                let actionMessage = message as? ActionMessage
                actionMessageCell.message.text = actionMessage?.message
                return actionMessageCell
            }else if message.messageCategory == .custom {
                
                //  CustomMessage Cell
                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "actionMessageBubble", for: indexPath) as! ActionMessageBubble
                let customMessage = message as? CustomMessage
                receiverCell.message.text = "custom message: \(String(describing: customMessage?.customData))"
                return receiverCell
            }
        }
        return cell
    }
    
    
    /// This method triggers when particular cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.beginUpdates()
        
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightTextMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftTextMessageBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
                self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                    if success {
                        if let url = fileURL {
                            self.previewItem = url as NSURL
                            self.presentQuickLook()
                        }
                    }
                })
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
                self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                    if success {
                        if let url = fileURL {
                            self.previewItem = url as NSURL
                            self.presentQuickLook()
                        }
                    }
                })
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
                self.previewMediaMessage(url: selectedCell.fileMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                    if success {
                        if let url = fileURL {
                            self.previewItem = url as NSURL
                            self.presentQuickLook()
                        }
                    }
                })
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
                self.previewMediaMessage(url: selectedCell.fileMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                    if success {
                        if let url = fileURL {
                            self.previewItem = url as NSURL
                            self.presentQuickLook()
                        }
                    }
                })
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = false
            }
        },completion: nil)
        tableView.endUpdates()
    }
    
    /// This method triggers when particular cell is deselected by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        tableView.beginUpdates()
        
        if messageActionView.isHidden == false {
            messageActionView.isHidden = true
        }
        
        UIView.animate(withDuration: 1,delay: 0.0, usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1, options: [], animations: {
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightLinkPreviewBubble {
                            selectedCell.receiptStack.isHidden = true
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftLinkPreviewBubble {
                            selectedCell.receiptStack.isHidden = true
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightTextMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                        }
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftTextMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightImageMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftImageMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? RightFileMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? LeftFileMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                        }
        },completion: nil)
        tableView.endUpdates()
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - UITextView Delegate

extension CometChatMessageList : UITextViewDelegate {
    
    
    /// This method triggers when  user stops typing in textView.
    /// - Parameter textView: A scrollable, multiline text region.
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
        }
    }
    
    /// This method triggers when  user starts typing in textView.
    /// - Parameter textView: A scrollable, multiline text region.
    public func textViewDidChange(_ textView: UITextView) {
        guard let indicator = typingIndicator else {
            return
        }
        CometChat.startTyping(indicator: indicator)
    }  
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - QuickLook Preview Delegate

extension CometChatMessageList:QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    
    /**
     This method will open  quick look preview controller.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func presentQuickLook(){
        DispatchQueue.main.async {
            let previewController = QLPreviewController()
            previewController.modalPresentationStyle = .popover
            previewController.dataSource = self
            self.present(previewController, animated: true, completion: nil)
        }
    }
    
    /**
     This method will preview media message under  quick look preview controller.
     - Parameters:
     - url:  this specifies the `url` of Media Message.
     - completion: This handles the completion of method.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func previewMediaMessage(url: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        let itemUrl = URL(string: url)
        let documentsDirectoryURL =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(itemUrl?.lastPathComponent ?? "")
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else {
            URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch let error as NSError {
                    print(error.localizedDescription)
                    completion(false, nil)
                }
            }).resume()
        }
    }
    
    
    /// Invoked when the Quick Look preview controller needs to know the number of preview items to include in the preview navigation list.
    /// - Parameter controller: A specialized view for previewing an item.
    public func numberOfPreviewItems(in controller: QLPreviewController) -> Int { return 1 }
    
    
    /// Invoked when the Quick Look preview controller needs the preview item for a specified index position.
    /// - Parameters:
    ///   - controller: A specialized view for previewing an item.
    ///   - index: The index position, within the preview navigation list, of the item to preview.
    public func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - ChatView Internal Delegate

extension CometChatMessageList : ChatViewInternalDelegate {
    
    /**
     This method triggers when user pressed attachment  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didAttachmentButtonPressed() {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoLibraryAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Photo & Video Library", comment: ""), style: .default) { action -> Void in
            CameraHandler.shared.presentPhotoLibrary(for: self)
            CameraHandler.shared.imagePickedBlock = { (photoURL) in
                var mediaMessage: MediaMessage?
                switch self.isGroupIs {
                case true:
                    mediaMessage = MediaMessage(receiverUid: self.currentGroup?.guid ?? "", fileurl: photoURL, messageType: .image, receiverType: .group)
                    mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    mediaMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                    mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    self.messages.append(mediaMessage!)
                    self.filteredMessages.append(mediaMessage!)
                    DispatchQueue.main.async {
                        self.tableView?.beginUpdates()
                        self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                        self.tableView?.endUpdates()
                        self.tableView?.scrollToBottomRow()
                    }
                    CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                        if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                            self.messages[row] = message}
                        DispatchQueue.main.async{ self.tableView?.reloadData()}
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                self.view.makeToast(errorMessage)
                            }
                        }
                        print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                    }
                    
                case false:
                    mediaMessage = MediaMessage(receiverUid: self.currentUser?.uid ?? "", fileurl: photoURL, messageType: .image, receiverType: .user)
                    mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    mediaMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                    mediaMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    self.messages.append(mediaMessage!)
                    self.filteredMessages.append(mediaMessage!)
                    DispatchQueue.main.async {
                        self.tableView?.beginUpdates()
                        self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                        self.tableView?.endUpdates()
                        self.tableView?.scrollToBottomRow()
                    }
                    CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                        if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                            self.messages[row] = message}
                        DispatchQueue.main.async{ self.tableView?.reloadData()}
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                self.view.makeToast(errorMessage)
                            }
                        }
                        print("sendMediaMessage error: \(String(describing: error?.errorDescription))")
                    }
                }
            }
        }
        
        let documentAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Document", comment: ""), style: .default) { action -> Void in
            
            self.documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
            self.present(self.documentPicker, animated: true, completion: nil)
            
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel) { action -> Void in
        }
        
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(photoLibraryAction)
        actionSheetController.addAction(documentAction)
        actionSheetController.addAction(cancelAction)
        
        // Added ActionSheet support for iPad
        if self.chatView.frame.origin.y != 0 { dismissKeyboard() }
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            if let currentPopoverpresentioncontroller =
                actionSheetController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = self.chatView.attachment
                self.present(actionSheetController, animated: true, completion: nil)
            }
        }else{
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
    
    /**
     This method triggers when user pressed sticker  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didStickerButtonPressed() {
        
        
    }
    
    /**
     This method triggers when user pressed microphone  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didMicrophoneButtonPressed() {
        
    }
    
    
    /**
     This method triggers when user pressed send  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didSendButtonPressed() {
        
        if messageMode == .edit {
            
            guard let textMessage = selectedMessage as? TextMessage else { return }
            guard let indexPath = selectedIndexPath else { return }
            
            if let message:String = chatView?.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                textMessage.text = message
                CometChat.edit(message: textMessage, onSuccess: { (editedMessage) in
                    if let row = self.messages.firstIndex(where: {$0.id == editedMessage.id}) {
                        self.messages[row] = editedMessage
                    }
                    DispatchQueue.main.async{
                        self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                        self.hide(view: .editMessageView, true)
                        self.hide(view: .smartRepliesView, true)
                        self.selectedMessage = nil
                        self.selectedIndexPath = nil
                        self.messageMode = .send
                        self.textView.text = ""
                    }
                }) { (error) in
                    DispatchQueue.main.async{
                        self.hide(view: .editMessageView, true)
                        self.hide(view: .smartRepliesView, true)
                        self.selectedMessage = nil
                        self.selectedIndexPath = nil
                        self.messageMode = .send
                        self.textView.text = ""
                    }
                    print("unable to edit Message: \(error.errorDescription)")
                }
            }
        }else{
            var textMessage: TextMessage?
            let message:String = chatView?.textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if(message.count == 0){
                
            }else{
                
                switch self.isGroupIs {
                case true:
                    textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: message, receiverType: .group)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                    textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    self.messages.append(textMessage!)
                    self.filteredMessages.append(textMessage!)
                    guard let indicator = typingIndicator else {
                        return
                    }
                    CometChat.endTyping(indicator: indicator)
                    DispatchQueue.main.async {
                        self.hide(view: .smartRepliesView, true)
                        self.tableView?.beginUpdates()
                        self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                        self.tableView?.endUpdates()
                        self.tableView?.scrollToBottomRow()
                        self.chatView.textView.text = ""
                    }
                    
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                            self.messages[row] = message
                        }
                        let metadata : [String : Any]? = textMessage?.metaData
                        print("sendTextMessage onSuccess: \(String(describing: metadata))")
                        DispatchQueue.main.async{ self.tableView?.reloadData()
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                self.view.makeToast(errorMessage)
                            }
                        }
                        print("sendTextMessage error: \(String(describing: error?.errorDescription))")
                    }
                case false:
                    textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: message, receiverType: .user)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
                    textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
                    self.messages.append(textMessage!)
                    self.filteredMessages.append(textMessage!)
                    guard let indicator = typingIndicator else {
                        return
                    }
                    CometChat.endTyping(indicator: indicator)
                    DispatchQueue.main.async {
                        self.hide(view: .smartRepliesView, true)
                        self.tableView?.beginUpdates()
                        self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                        self.tableView?.endUpdates()
                        self.tableView?.scrollToBottomRow()
                        self.chatView.textView.text = ""
                    }
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                            self.messages[row] = message
                        }
                        let metadata = message.metaData ?? [:]
                        print("sendTextMessage onSuccess: \(String(describing: metadata))")
                        DispatchQueue.main.async{ self.tableView?.reloadData() }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                self.view.makeToast(errorMessage)
                            }
                        }
                        print("sendTextMessage error: \(String(describing: error?.errorDescription))")
                    }
                }
            }
        }
    }
    
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatMessageDelegate

extension CometChatMessageList : CometChatMessageDelegate {
    
    /**
     This method append new message on UI when new message is received.
     /// - Parameter message: This specified the `BaseMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func appendNewMessage(message: BaseMessage) {
        switch message.receiverType {
        case .user:
            CometChat.markAsRead(messageId: message.id, receiverId: message.senderUid, receiverType: .user)
            self.messages.append(message)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
        case .group:
            CometChat.markAsRead(messageId: message.id, receiverId: message.receiverUid, receiverType: .user)
            self.messages.append(message)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
        @unknown default: break
        }
    }
    
    /**
     This method triggers when real time text message message arrives from CometChat Pro SDK
     - Parameter textMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTextMessageReceived(textMessage: TextMessage) {
        DispatchQueue.main.async{
            //Appending Real time text messages for User.
            if let sender = textMessage.sender?.uid, let currentUser = self.currentUser?.uid {
                if sender == currentUser && textMessage.receiverType == .user {
                    self.appendNewMessage(message: textMessage)
                    let titles = self.parseSmartRepliesMessages(message: textMessage)
                    self.smartRepliesView.set(titles: titles)
                    self.hide(view: .smartRepliesView, false)
                    
                }else if sender == CometChat.getLoggedInUser()?.uid && textMessage.receiverType == .user {
                    self.appendNewMessage(message: textMessage)
                    let titles = self.parseSmartRepliesMessages(message: textMessage)
                    self.smartRepliesView.set(titles: titles)
                    self.hide(view: .smartRepliesView, true)
                }
            }
            
            //Appending Real time text messages for Group.
            if let currentGroup = self.currentGroup?.guid {
                let sender = textMessage.senderUid
                let group = textMessage.receiverUid
                // Receiving real time messages for the group this window is opened for.
                if group == currentGroup && textMessage.receiverType == .group && sender != CometChat.getLoggedInUser()?.uid {
                    self.appendNewMessage(message: textMessage)
                    let titles = self.parseSmartRepliesMessages(message: textMessage)
                    self.smartRepliesView.set(titles: titles)
                    self.hide(view: .smartRepliesView, false)
                }else if sender == CometChat.getLoggedInUser()?.uid && textMessage.receiverType == .group && group == currentGroup {
                    self.appendNewMessage(message: textMessage)
                    let titles = self.parseSmartRepliesMessages(message: textMessage)
                    self.smartRepliesView.set(titles: titles)
                    self.hide(view: .smartRepliesView, true)
                }
            }
        }
    }
    
    /**
     This method triggers when real time media message arrives from CometChat Pro SDK
     - Parameter mediaMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        DispatchQueue.main.async{
            //Appending Real time text messages for User.
            if let sender = mediaMessage.sender?.uid, let currentUser = self.currentUser?.uid {
                if sender == currentUser && mediaMessage.receiverType == .user {
                    self.appendNewMessage(message: mediaMessage)
                    self.hide(view: .smartRepliesView, true)
                    
                }else if sender == CometChat.getLoggedInUser()?.uid && mediaMessage.receiverType == .user {
                    self.appendNewMessage(message: mediaMessage)
                    self.hide(view: .smartRepliesView, true)
                }
            }
            
            //Appending Real time text messages for Group.
            if let currentGroup = self.currentGroup?.guid {
                let sender = mediaMessage.receiverUid
                // Receiving real time messages for the group this window is opened for.
                if sender == currentGroup && mediaMessage.receiverType == .group {
                    self.appendNewMessage(message: mediaMessage)
                    self.hide(view: .smartRepliesView, true)
                }else if sender == CometChat.getLoggedInUser()?.uid && mediaMessage.receiverType == .group {
                    self.hide(view: .smartRepliesView, true)
                }
            }
        }
    }
    
    /**
     This method triggers when receiver reads the message sent by you.
     - Parameter receipt: This Specifies MessageReceipt Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMessagesRead(receipt: MessageReceipt) {
        DispatchQueue.main.async{
            if receipt.sender?.uid == self.currentUser?.uid && receipt.receiverType == .user{
                for msg in self.messages where msg.readAt == 0 {
                    msg.readAt = Double(receipt.timeStamp)
                }
                DispatchQueue.main.async {self.tableView?.reloadData()}
            }else if receipt.receiverId == self.currentGroup?.guid && receipt.receiverType == .group{
                for msg in self.messages where msg.readAt == 0 {
                    msg.readAt = Double(receipt.timeStamp)
                }
                DispatchQueue.main.async {self.tableView?.reloadData()}
            }
        }
    }
    
    /**
     This method triggers when  message sent by you reaches to the receiver.
     - Parameter receipt: This Specifies MessageReceipt Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMessagesDelivered(receipt: MessageReceipt) {
        DispatchQueue.main.async{
            if receipt.sender?.uid == self.currentUser?.uid && receipt.receiverType == .user{
                for msg in self.messages where msg.deliveredAt == 0   {
                    msg.deliveredAt = Double(receipt.timeStamp)
                }
                DispatchQueue.main.async {self.tableView?.reloadData()}
            }else if receipt.receiverId == self.currentGroup?.guid && receipt.receiverType == .group{
                for msg in self.messages where msg.deliveredAt == 0   {
                    msg.deliveredAt = Double(receipt.timeStamp)
                }
                DispatchQueue.main.async {self.tableView?.reloadData()}
            }
        }
    }
    
    /**
     This method triggers when real time event for  start typing received from  CometChat Pro SDK
     - Parameter typingDetails: This specifies TypingIndicator Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTypingStarted(_ typingDetails: TypingIndicator) {
        DispatchQueue.main.async{
            if typingDetails.sender?.uid == self.currentUser?.uid && typingDetails.receiverType == .user{
                DispatchQueue.main.async {
                    self.setupNavigationBar(withSubtitle: "typing...")
                }
            }else if typingDetails.receiverType == .group  && typingDetails.receiverID == self.currentGroup?.guid {
                if let user = typingDetails.sender?.name {
                    DispatchQueue.main.async {
                        self.setupNavigationBar(withSubtitle: "\(String(describing: user)) is typing...")
                    }
                }
                
            }
        }
    }
    
    /**
     This method triggers when real time event for  stop typing received from  CometChat Pro SDK
     - Parameter typingDetails: This specifies TypingIndicator Object.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTypingEnded(_ typingDetails: TypingIndicator) {
        DispatchQueue.main.async{
            if typingDetails.sender?.uid == self.currentUser?.uid && typingDetails.receiverType == .user{
                DispatchQueue.main.async {
                    self.setupNavigationBar(withSubtitle: "online")
                }
            }else if typingDetails.receiverType == .group  && typingDetails.receiverID == self.currentGroup?.guid {
                self.setupNavigationBar(withSubtitle: self.membersCount ?? "")
            }
        }
    }
    
    public func onMessageEdited(message: BaseMessage) {
        if let row = self.messages.firstIndex(where: {$0.id == message.id}) {
            messages[row] = message
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async{
                self.tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        
        if let row = self.messages.firstIndex(where: {$0.id == message.id}) {
            messages[row] = message
            let indexPath = IndexPath(row: row, section: 0)
            DispatchQueue.main.async{
                self.tableView?.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatUserDelegate Delegate

extension CometChatMessageList : CometChatUserDelegate {
    
    /**
     This event triggers when user is Online.
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onUserOnline(user: User) {
        if user.uid == currentUser?.uid{
            if user.status == .online {
                DispatchQueue.main.async {
                    self.setupNavigationBar(withSubtitle: "online")
                }
            }
        }
    }
    
    /**
     This event triggers when user goes Offline..
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onUserOffline(user: User) {
        if user.uid == currentUser?.uid {
            if user.status == .offline {
                DispatchQueue.main.async {
                    self.setupNavigationBar(withSubtitle: "offline")
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatGroupDelegate Delegate


extension CometChatMessageList : CometChatGroupDelegate {
    
    /**
     This method triggers when someone joins group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - joinedUser: Specifies `User` Object
     - joinedGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroupMembers(group: joinedGroup)
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.messages.append(action)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
        }
    }
    
    /**
     This method triggers when someone lefts group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - leftUser: Specifies `User` Object
     - leftGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroupMembers(group: leftGroup)
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.messages.append(action)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
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
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroupMembers(group: kickedFrom)
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.messages.append(action)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
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
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.messages.append(action)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
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
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.messages.append(action)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
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
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.messages.append(action)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
        }
    }
    
    /**
     This method triggers when someone added in  the  group.
     - Parameters:
     - action:  Spcifies `ActionMessage` Object
     - addedBy: Specifies `User` Object
     - addedUser: Specifies `User` Object
     - addedTo: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if action.receiverUid == self.currentGroup?.guid && action.receiverType == .group {
            self.fetchGroupMembers(group: addedTo)
            CometChat.markAsRead(messageId: action.id, receiverId: action.receiverUid, receiverType: .group)
            self.messages.append(action)
            DispatchQueue.main.async{
                self.tableView?.reloadData()
                self.tableView?.scrollToBottomRow()
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Smart Replies Delegate

extension CometChatMessageList : SmartRepliesViewDelegate {
    
    /**
     This method triggers when user pressed particular button in smart replies view.
     - Parameter title: `title` specifies the title of the button.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didSendButtonPressed(title: String) {
        var textMessage: TextMessage?
        switch self.isGroupIs {
        case true:
            textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: title, receiverType: .group)
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
            textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            self.messages.append(textMessage!)
            self.filteredMessages.append(textMessage!)
            self.hide(view: .smartRepliesView, true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            DispatchQueue.main.async {
                self.tableView?.beginUpdates()
                self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                self.tableView?.endUpdates()
                self.tableView?.scrollToBottomRow()
                self.chatView.textView.text = ""
            }
            
            CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                    self.messages[row] = message
                }
                let metadata : [String : Any]? = textMessage?.metaData
                print("sendTextMessage onSuccess: \(String(describing: metadata))")
                DispatchQueue.main.async{ self.tableView?.reloadData()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        self.view.makeToast(errorMessage)
                    }
                }
                print("sendTextMessage error: \(String(describing: error?.errorDescription))")
            }
        case false:
            textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: title, receiverType: .user)
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.sender?.uid = CometChat.getLoggedInUser()?.uid
            textMessage?.senderUid = CometChat.getLoggedInUser()?.uid ?? ""
            self.messages.append(textMessage!)
            self.filteredMessages.append(textMessage!)
            self.hide(view: .smartRepliesView, true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            DispatchQueue.main.async {
                self.tableView?.beginUpdates()
                self.tableView?.insertRows(at: [IndexPath.init(row: self.messages.count-1, section: 0)], with: .right)
                self.tableView?.endUpdates()
                self.tableView?.scrollToBottomRow()
                self.chatView.textView.text = ""
            }
            CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                if let row = self.messages.firstIndex(where: {$0.muid == message.muid}) {
                    self.messages[row] = message
                }
                let metadata : [String : Any]? = textMessage?.metaData
                print("sendTextMessage onSuccess: \(String(describing: metadata))")
                DispatchQueue.main.async{ self.tableView?.reloadData() }
            }) { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        self.view.makeToast(errorMessage)
                    }
                }
                print("sendTextMessage error: \(String(describing: error?.errorDescription))")
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Link Preview Delegate

extension CometChatMessageList: LinkPreviewDelegate {
    
    /**
     This method triggers when user pressed visit button in link preview bubble.
     - Parameters:
     - link: link specifies `link` of the message.
     - sender: specifies the user who is pressing this button.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didVisitButtonPressed(link: String, sender: UIButton) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
    
    /**
     This method triggers when user pressed play button in link preview bubble.
     - Parameters:
     - link: link specifies `link` of the message.
     - sender: specifies the user who is pressing this button.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didPlayButtonPressed(link: String, sender: UIButton) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}

/*  ----------------------------------------------------------------------------------------- */


