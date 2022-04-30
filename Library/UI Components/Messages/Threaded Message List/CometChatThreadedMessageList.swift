
//  CometChatThreadedMessageList.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

/* >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
 
 CometChatThreadedMessageList: The CometChatThreadedMessageList is a view controller with a list of messages for a particular user or group. The view controller has all the necessary delegates and methods.
 
 >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>  */

// MARK: - Importing Frameworks.
import MapKit
import UIKit
import WebKit
import AVKit
import AVFoundation
import QuickLook
import AudioToolbox
import MessageUI
import SafariServices
import CometChatPro


 protocol ThreadDelegate: NSObject {
    func startThread(forMessage: BaseMessage, indexPath: IndexPath)
    func didReplyAdded(forMessage: BaseMessage, text: String, indexPath: IndexPath)
}



/*  ----------------------------------------------------------------------------------------- */

public class CometChatThreadedMessageList: UIViewController, AVAudioRecorderDelegate, AVAudioPlayerDelegate, UIGestureRecognizerDelegate {
    
    struct MessageActionsGroup: RowPresentable {
        let string: String = "MessageActionsGroup"
        let rowVC: PanModalPresentable.LayoutType = MessageActions()
    }
    
    enum AudioRecodingState {
        case ready
        case recording
        case recorded
        case playing
        case paused
        
        var buttonImage: UIImage {
            switch self {
            case .ready, .recording:
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "pause.fill") ?? UIImage(named: "play", in: UIKitSettings.bundle, compatibleWith: nil)!
                } else {}
            case .recorded, .paused:
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "play.fill") ?? UIImage(named: "play", in: UIKitSettings.bundle, compatibleWith: nil)!
                } else {}
            case .playing:
                if #available(iOS 13.0, *) {
                    return UIImage(systemName: "pause.fill") ?? UIImage(named: "play", in: UIKitSettings.bundle, compatibleWith: nil)!
                } else {}
            }
            return UIImage(named: "microphone", in: UIKitSettings.bundle, compatibleWith: nil)  ?? UIImage(named: "play", in: UIKitSettings.bundle, compatibleWith: nil)!
        }
        
        var audioVisualizationMode: AudioVisualizationView.AudioVisualizationMode {
            switch self {
            case .ready, .recording:
                return .write
            case .paused, .playing, .recorded:
                return .read
            }
        }
    }
    
    // MARK: - Declaration of Outlets
    
    @IBOutlet weak var replyCountView: UIView!
    @IBOutlet weak var threadedMessageFileType: UILabel!
    @IBOutlet weak var threadedMessageFileName: UILabel!
    @IBOutlet weak var threadedFileMessageView: UIView!
    @IBOutlet weak var threadedTextMessageView: UIView!
    @IBOutlet weak var threadedReplyCount: UILabel!
    @IBOutlet weak var threadedMessageText: UILabel!
    @IBOutlet weak var threadedMessageTime: UILabel!
    @IBOutlet weak var threadedMessageUserName: UILabel!
    @IBOutlet weak var threadedMessageAvatar: CometChatAvatar!
    @IBOutlet weak var threadedView: UIView!
    @IBOutlet weak var send: UIButton!
    @IBOutlet weak var reactionView: CometChatLiveReaction!
    @IBOutlet weak var reaction: UIButton!
    @IBOutlet weak var microhone: UIButton!
    @IBOutlet weak var audioNotePauseButton: UIButton!
    @IBOutlet weak var audioNoteSendButton: UIButton!
    @IBOutlet weak var audioNoteDeleteButton: UIButton!
    @IBOutlet weak var audioNoteActionView: UIView!
    @IBOutlet weak var audioNoteTimer: UILabel!
    @IBOutlet weak var audioNoteView: UIView!
    @IBOutlet private var audioVisualizationView: AudioVisualizationView!
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var messageComposer: CometChatMessageComposer!
    @IBOutlet weak var textView: GrowingTextView!
    @IBOutlet weak var textViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var blockedView: UIView!
    @IBOutlet weak var editView: UIView!
    @IBOutlet weak var editViewName: UILabel!
    @IBOutlet weak var editViewMessage: UILabel!
    @IBOutlet weak var blockedMessage: UILabel!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var reactionButtonSpace: NSLayoutConstraint!
     @IBOutlet weak var reactionButtonWidth: NSLayoutConstraint!
     @IBOutlet weak var inputBarBottomSpace: NSLayoutConstraint!
     @IBOutlet weak var inputBarHeight: NSLayoutConstraint!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var smartRepliesView: CometChatSmartRepliesPreview!
    @IBOutlet weak var tableViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var collectionLayout: UICollectionViewFlowLayout! {
        didSet{
            collectionLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
        }
    }
    
    // MARK: - Declaration of Variables
    
    var currentUser: User?
    var currentGroup: Group?
    var currentMessage: BaseMessage?
    var currentReaction: LiveReaction = .thumbsup
    var currentEntity: CometChat.ReceiverType?
    var messageRequest:MessagesRequest?
    var memberRequest: GroupMembersRequest?
    var chatMessages: [[BaseMessage]] = [[BaseMessage]]()
    var filteredMessages:[BaseMessage] = [BaseMessage]()
    var selectedMessages:[BaseMessage] = [BaseMessage]()
    var typingIndicator: TypingIndicator?
    var safeArea: UILayoutGuide!
    let modelName = UIDevice.modelName
    var titleView : UIView?
    var buddyStatus: UILabel?
    var isGroupIs : Bool = false
    var refreshControl: UIRefreshControl!
    var membersCount:String?
    var totalHour = Int()
    var totalMinut = Int()
    var totalSecond = 0
    var timer:Timer?
    var isTimerRunning = false
    var messageMode: MessageMode = .send
    var selectedIndexPath: IndexPath?
    var selectedMessage: BaseMessage?
    lazy var previewItem = NSURL()
    var quickLook = QLPreviewController()
    var soundRecorder : AVAudioRecorder!
    var soundPlayer : AVAudioPlayer!
    var isAudioPaused : Bool = false
    private let viewModel = ViewModel()
    var audioURL:URL?
    var fileName : String?
    var getCount: Int = 0
    var indexPath: IndexPath?
    private var chronometer: Chronometer?
    var curentLocation: CLLocation?
    var isAnimating: Bool = true
    let locationManager = CLLocationManager()
    
    private var currentState: AudioRecodingState = .ready {
        didSet {
            self.audioNotePauseButton.setImage(self.currentState.buttonImage, for: .normal)
            self.audioVisualizationView.audioVisualizationMode = self.currentState.audioVisualizationMode
        }
    }
    
    
    
    let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.data","public.content","public.audiovisual-content","public.movie","public.audiovisual-content","public.video","public.audio","public.data","public.zip-archive","com.pkware.zip-archive","public.composite-content","public.text"], in: UIDocumentPickerMode.import)
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        setupSuperview()
        setupDelegates()
        setupTableView()
        registerCells()
        configureGrowingTextView()
        setupKeyboard()
        setupRecorder()
        self.addObsevers()
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        if let message = currentMessage {
            setupThreadedView(forMessage: message)
        }
        hideSystemBackButton(bool: true)
        locationManager.distanceFilter = kCLDistanceFilterNone
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        setupDelegates()
        locationAuthStatus()
        hideSystemBackButton(bool: true)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didThreadOpened"), object: nil, userInfo: nil)
    }
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Public instance methods
    
    
    /**
     This method specifies the entity of user or group which user wants to begin the conversation.
     - Parameters:
     - conversationWith: Spcifies `AppEntity` Object which can take `User` or `Group` Object.
     - type: Spcifies a type of `AppEntity` such as `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    /**
     This method specifies the entity of user or group which user wants to begin the conversation.
     - Parameters:
     - conversationWith: Spcifies `AppEntity` Object which can take `User` or `Group` Object.
     - type: Spcifies a type of `AppEntity` such as `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc public func set(threadFor message: BaseMessage, conversationWith: AppEntity, type: CometChat.ReceiverType){
        
        switch type {
        case .user:
            isGroupIs = false
            guard let user = conversationWith as? User else{ return }
            currentUser = user
            currentEntity = .user
            currentMessage = message
            fetchUserInfo(user: user)
            
            switch (conversationWith as? User)!.status {
            case .online:
                setupNavigationBar(withTitle: "Thread")
                setupNavigationBar(withSubtitle: user.name?.capitalized ?? "")
            //                setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "", bool: true)
            case .offline:
                setupNavigationBar(withTitle: "Thread")
                setupNavigationBar(withSubtitle: user.name?.capitalized ?? "")
            //                setupNavigationBar(withImage: user.avatar ?? "", name: user.name ?? "", bool: true)
            @unknown default:break
            }
            self.fetchThread(forID: user.uid ?? "", messageID: message.id, type: .user, scrollToBottom: true)
            
        case .group:
            isGroupIs = true
            guard let group = conversationWith as? Group else{
                return
            }
            currentGroup = group
            currentEntity = .group
            currentMessage = message
            setupNavigationBar(withTitle: "Thread")
            setupNavigationBar(withTitle: group.name?.capitalized ?? "")
            setupNavigationBar(withSubtitle:group.name?.capitalized ?? "")
            
            //setupNavigationBar(withImage: group.icon ?? "", name: group.name ?? "", bool: true)
            fetchGroup(group: group.guid)
            self.fetchThread(forID: group.guid, messageID: message.id, type: .group, scrollToBottom: true)
            
        @unknown default:
            break
        }
    }
    
    
    private func setupThreadedView(forMessage: BaseMessage) {
        
        if let name = forMessage.sender?.name {
            
            threadedMessageUserName.text = name
            if let url = forMessage.sender?.avatar  {
                threadedMessageAvatar.set(image: url, with: name)
            }
            threadedMessageTime.text = String().setMessageTime(time: forMessage.sentAt)
            
            switch forMessage.messageCategory {
            
            case .message:
                switch forMessage.messageType {
                case .text:
                    threadedTextMessageView.isHidden = false
                    threadedMessageText.text = (forMessage as? TextMessage)?.text
                case .image:
                    threadedFileMessageView.isHidden = false
                    threadedMessageFileName.text = "Image Message"
                    threadedMessageFileType.text = "🎆 Image"
                case .video:
                    threadedFileMessageView.isHidden = false
                    threadedMessageFileName.text = "Video Message"
                    threadedMessageFileType.text = "📹 Video"
                case .audio:
                    threadedFileMessageView.isHidden = false
                    threadedMessageFileName.text = "Audio Message"
                    threadedMessageFileType.text = "🎵 Audio"
                case .file:
                    threadedFileMessageView.isHidden = false
                    threadedMessageFileName.text = "File Message"
                    threadedMessageFileType.text = "📁 File"
                case .custom:  break
                case .groupMember: break
                @unknown default: break
                }
            case .action: break
            case .call: break
            case .custom:
                if let customMessage = forMessage as? CustomMessage {
                    if customMessage.type == "location" {
                        threadedFileMessageView.isHidden = false
                        threadedMessageFileName.text = "Location Message"
                        threadedMessageFileType.text = "📍 Location"
                    }else if customMessage.type == "extension_poll" {
                        threadedFileMessageView.isHidden = false
                        threadedMessageFileName.text = "Poll Message"
                        threadedMessageFileType.text = "📊 Poll"
                    }else if customMessage.type == "extension_sticker" {
                        threadedFileMessageView.isHidden = false
                        threadedMessageFileName.text = "Sticker"
                        threadedMessageFileType.text = "💟 Sticker"
                    }else if customMessage.type == "meeting" {
                        threadedFileMessageView.isHidden = false
                        threadedMessageFileName.text = "Group call"
                        threadedMessageFileType.text = "📞 Group call"
                    }else if customMessage.type == "extension_whiteboard" {
                        threadedFileMessageView.isHidden = false
                        threadedMessageFileName.text = "Collaborative Whiteboard"
                        threadedMessageFileType.text = "📝 Whiteboard"
                    }else if customMessage.type == "extension_document" {
                        threadedFileMessageView.isHidden = false
                        threadedMessageFileName.text = "Collaborative Document"
                        threadedMessageFileType.text = "📃 Document"
                    }
                }
            @unknown default: break
            }
            
            if forMessage.replyCount == 0 {
                set(replyCount: 0)
            }else{
                set(replyCount: forMessage.replyCount)
            }
           
        }
    }
    
    private func set(replyCount: Int) {
        threadedReplyCount.isHidden = false
        self.getCount = replyCount
        if replyCount == 0 {
            threadedReplyCount.text = "NO_REPLIES".localized()
        }else if replyCount == 1 {
            threadedReplyCount.text = "ONE_REPLY".localized()
        }else{
            threadedReplyCount.text = String(replyCount) + " " +  "REPLIES".localized()
        }
        if let message = currentMessage, let indexpath = indexPath {
             CometChatThreadedMessageList.threadDelegate?.didReplyAdded(forMessage: message, text: threadedReplyCount.text ?? "", indexPath: indexpath)
        }
    }
    
    @objc public func incrementCount() {
        let currentCount = self.getCount + 1
        self.set(replyCount: currentCount)
    }
    
    @IBAction func didForwardMessagePressed(_ sender: Any) {
        if let message = currentMessage {
            let forwardMessageList = CometChatForwardMessageList()
            forwardMessageList.set(message: message)
            navigationController?.pushViewController(forwardMessageList, animated: true)
            self.didPreformCancel()
        }
    }
    
    @IBAction func didMoreButtonPressed(_ sender: Any) {
        self.selectedMessage = currentMessage
        let group: RowPresentable = MessageActionsGroup()
        if currentMessage?.sender?.uid == LoggedInUser.uid {
            (group.rowVC as? MessageActions)?.set(actions: [.reply,.forward,.share, .delete])
        }else{
            (group.rowVC as? MessageActions)?.set(actions: [.reply,.forward,.share])
        }
        presentPanModal(group.rowVC)
    }
    
    // MARK: - CometChatPro Instance Methods
    
    private func addNewGroupedMessage(messages: [BaseMessage]){
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            if messages.isEmpty { strongSelf.tableView?.setEmptyMessage("NO_MESSAGES_FOUND".localized())
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
                strongSelf.hide(view: .smartRepliesView, true)
                strongSelf.tableView?.insertSections([0], with: .top)
                let lastSection = strongSelf.tableView?.numberOfSections
                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection ?? 0].count - 1, section: lastSection ?? 0)], with: .automatic)
                
                strongSelf.tableView?.endUpdates()
                strongSelf.tableView?.scrollToBottomRow()
                strongSelf.textView.text = ""
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
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func groupMessages(messages: [BaseMessage]){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if messages.isEmpty { strongSelf.tableView?.setEmptyMessage("NO_MESSAGES_FOUND".localized())
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
                strongSelf.refreshControl.endRefreshing()
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
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
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
                strongSelf.refreshControl.endRefreshing()
            }
        }
    }
    
    
    
    
    
    /**
     This method fetches the older messages from the server using `MessagesRequest` class.
     - Parameter inTableView: This spesifies `Bool` value
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchPreviousMessages(messageReq:MessagesRequest){
        messageReq.fetchPrevious(onSuccess: {  [weak self] (fetchedMessages) in
            guard let strongSelf = self else { return }
            if fetchedMessages?.count == 0 {
                DispatchQueue.main.async {
                    strongSelf.refreshControl.endRefreshing()
                }
            }
            guard let messages = fetchedMessages else { return }
            if fetchedMessages?.count != 0 && messages.count == 0 {
                if let request = strongSelf.messageRequest {
                    self?.fetchPreviousMessages(messageReq: request)
                }
            }
            guard let lastMessage = messages.last else { return }
            if strongSelf.isGroupIs == true {
                CometChat.markAsRead(baseMessage: lastMessage)
            }else{
                CometChat.markAsRead(baseMessage: lastMessage)
            }
            var oldMessages = [BaseMessage]()
            for msg in messages{ oldMessages.append(msg) }
            var oldMessageArray =  oldMessages
            oldMessageArray.sort { (obj1, obj2) -> Bool in
                return (obj1.sentAt) < (obj2.sentAt)
            }
            strongSelf.groupPreviousMessages(messages: oldMessageArray)
            
        }) { (error) in
            DispatchQueue.main.async {
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
             
                self.refreshControl.endRefreshing()
            }
        }
    }
    
    
    /**
     This method refreshes the  messages  using `MessagesRequest` class.
     - Parameters:
     - forID: This specifies a string value which takes `uid` or `guid`.
     - type: This specifies `ReceiverType` Object which can be `.user` or `.group`.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func fetchThread(forID: String, messageID: Int, type: CometChat.ReceiverType, scrollToBottom: Bool){
        chatMessages.removeAll()
      
        switch type {
        case .user:
            FeatureRestriction.isHideDeletedMessagesEnabled { (success) in
                switch success {
                case .enabled:
                    self.messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).hideReplies(hide: true).hideDeletedMessages(hide: true).setParentMessageId(parentMessageId: messageID).set(limit: 30).set(categories: MessageFilter.fetchMessageCategoriesForUser()).set(types: MessageFilter.fetchMessageTypesForUser()).build()
                case .disabled:
                    self.messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).hideReplies(hide: true).setParentMessageId(parentMessageId: messageID).set(limit: 30).set(categories: MessageFilter.fetchMessageCategoriesForUser()).set(types: MessageFilter.fetchMessageTypesForUser()).build()
                }
            }
            messageRequest = MessagesRequest.MessageRequestBuilder().set(uid: forID).hideReplies(hide: true).setParentMessageId(parentMessageId: messageID).set(limit: 30).set(categories: MessageFilter.fetchMessageCategoriesForUser()).set(types: MessageFilter.fetchMessageTypesForUser()).build()
            messageRequest?.fetchPrevious(onSuccess: { [weak self] (fetchedMessages) in
                guard let strongSelf = self else { return }
                guard let messages = fetchedMessages else { return }
               if fetchedMessages?.count != 0 && messages.count == 0 {
                    if let request = strongSelf.messageRequest {
                        self?.fetchPreviousMessages(messageReq: request)
                    }
                }
                strongSelf.groupMessages(messages: messages)
                guard let lastMessage = messages.last else {
                    return
                }
                CometChat.markAsRead(baseMessage: lastMessage)
                strongSelf.filteredMessages = messages.filter {$0.sender?.uid == LoggedInUser.uid}
                DispatchQueue.main.async {
                    if lastMessage.sender?.uid != LoggedInUser.uid {
                        if let lastMessage = lastMessage as? TextMessage {
                            let titles = strongSelf.parseSmartRepliesMessages(message: lastMessage)
                            strongSelf.smartRepliesView.set(titles: titles)
                            strongSelf.hide(view: .smartRepliesView, false)
                        }
                    }else{
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                    strongSelf.tableView?.reloadData()
                    if scrollToBottom == true{
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
                }, onError: { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
            })
            typingIndicator = TypingIndicator(receiverID: forID, receiverType: .user)
        case .group:
            FeatureRestriction.isHideDeletedMessagesEnabled { (success) in
                switch success {
                case .enabled:
                   self.messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).hideReplies(hide: true).hideDeletedMessages(hide: true).setParentMessageId(parentMessageId: messageID).set(limit: 30).set(categories: MessageFilter.fetchMessageCategoriesForGroups()).set(types: MessageFilter.fetchMessageTypesForGroup()).build()
                case .disabled:
                    self.messageRequest = MessagesRequest.MessageRequestBuilder().set(guid: forID).hideReplies(hide: true).setParentMessageId(parentMessageId: messageID).set(limit: 30).set(categories: MessageFilter.fetchMessageCategoriesForGroups()).set(types: MessageFilter.fetchMessageTypesForGroup()).build()
                }
            }
           
            messageRequest?.fetchPrevious(onSuccess: {[weak self] (fetchedMessages) in
                guard let strongSelf = self else { return }
                guard let messages = fetchedMessages else { return }
                if fetchedMessages?.count != 0 && messages.count == 0 {
                    if let request = strongSelf.messageRequest {
                        self?.fetchPreviousMessages(messageReq: request)
                    }
                }
                strongSelf.groupMessages(messages: messages)
                guard let lastMessage = messages.last else {
                    return
                }
                CometChat.markAsRead(baseMessage: lastMessage)
                strongSelf.filteredMessages = messages.filter {$0.sender?.uid == LoggedInUser.uid }
                DispatchQueue.main.async {
                    if lastMessage.sender?.uid != LoggedInUser.uid {
                        if let lastMessage = lastMessage as? TextMessage {
                            let titles = strongSelf.parseSmartRepliesMessages(message: lastMessage)
                            strongSelf.smartRepliesView.set(titles: titles)
                            strongSelf.hide(view: .smartRepliesView, false)
                        }
                    }else{
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                    strongSelf.tableView?.reloadData()
                    if scrollToBottom == true{
                        strongSelf.tableView?.scrollToBottomRow()
                    }
                }
                }, onError: { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
                    
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
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchUserInfo(user: User){
        CometChat.getUser(UID: user.uid ?? "", onSuccess: { [weak self] (user) in
            guard let strongSelf = self else { return }
            if  user?.blockedByMe == true {
                if let name = strongSelf.currentUser?.name {
                    DispatchQueue.main.async {
                        strongSelf.hide(view: .blockedView, false)
                        strongSelf.blockedMessage.text = "YOU'VE_BLOCKED".localized() + " \(String(describing: name.capitalized))"
                    }
                }
            }
        }) { (error) in
           
        }
    }
    
    
    /**
     This method fetches list of  group members  for particular group.
     - Parameter group: This specifies a  `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func fetchGroup(group: String){
        CometChat.getGroup(GUID: group, onSuccess: { [weak self] (group) in
            guard let strongSelf = self else { return }
            strongSelf.setupNavigationBar(withTitle: "Thread")
            strongSelf.setupNavigationBar(withSubtitle: group.name?.capitalized ?? "")
        }) { (error) in
          
        }
    }
    
    /**
     This method detects the extension is enabled or not for smart replies and link preview.
     - Parameter message: This specifies `TextMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func didExtensionDetected(message: BaseMessage) -> CometChatExtension {
        var detectedExtension: CometChatExtension?
       
        if let metaData = message.metaData {
            if  metaData["reply-message"] as? [String : Any] != nil {
                detectedExtension = .reply
            }else{
                detectedExtension = .none
            }
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let linkPreviewDictionary = cometChatExtension["link-preview"] as? [String : Any], let linkArray = linkPreviewDictionary["links"] as? [[String: Any]], let _ = linkArray[safe: 0] {
            
            detectedExtension = .linkPreview
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["smart-reply"] as? [String : Any] {
            
            detectedExtension = .smartReply
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["message-translation"] as? [String : Any] {
            
            detectedExtension = .messageTranslation
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["thumbnail-generation"] as? [String : Any] {
            
            detectedExtension = .thumbnailGeneration
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["image-moderation"] as? [String : Any] {
            
            detectedExtension = .imageModeration
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["profanity-filter"] as? [String : Any] {
            
            detectedExtension = .profanityFilter
            
        }else if let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let _ = cometChatExtension["sentiment-analysis"] as? [String : Any] {
            
            detectedExtension = .profanityFilter
        }
        
        return detectedExtension ?? .none
    }
    
    
    /**
     This method parse the smart replies data from `TextMessage` Object.
     - Parameter message: This specifies `TextMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func parseSmartRepliesMessages(message: TextMessage) -> [String] {
        var replyMessages: [String] = [String]()
        if  let metaData = message.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let smartReply = cometChatExtension["smart-reply"] as? [String : Any] {
            
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
     This method setup the view to load CometChatThreadedMessageList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupSuperview() {
        //        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: "CometChatThreadedMessageList", bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.view  = view
        replyCountView.layer.borderWidth = 1
        if #available(iOS 13.0, *) {
            replyCountView.layer.borderColor = UIColor.systemFill.cgColor
        } else {
            replyCountView.layer.borderColor = UIColor.lightGray.cgColor
        }
        replyCountView.clipsToBounds = true
    }
    
    /**
     This method register the delegate for real time events from CometChatPro SDK.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupDelegates(){
        CometChat.messagedelegate = self
        CometChat.userdelegate = self
        documentPicker.delegate = self
        MessageActions.actionsDelegate = self
        smartRepliesView.smartRepliesDelegate = self
        CometChatMessageReactions.cometChatMessageReactionsDelegate = self
        quickLook.dataSource = self
    }
    
    
    func setupRecorder(){
        self.viewModel.askAudioRecordingPermission()
        self.viewModel.audioMeteringLevelUpdate = { [weak self] meteringLevel in
            guard let strongSelf = self, strongSelf.audioVisualizationView.audioVisualizationMode == .write else {
                return
            }
            strongSelf.audioVisualizationView.add(meteringLevel: meteringLevel)
        }
        self.viewModel.audioDidFinish = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.currentState = .recorded
            strongSelf.audioVisualizationView.stop()
        }
    }
    
    /**
     This method observers for the notifications of certain events.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addObsevers(){
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserBlocked(_:)), name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didUserUnblocked(_:)), name: NSNotification.Name(rawValue: "didUserUnblocked"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didGroupDeleted(_:)), name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
    }
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didUserUnblocked"), object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    /**
     This method triggers when group is deleted.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didGroupDeleted(_ notification: NSNotification) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    /**
     This method triggers when user has been unblocked.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didUserUnblocked(_ notification: NSNotification) {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.hide(view: .blockedView, true)
        }
    }
    
    /**
     This method triggers when user has been blocked.
     - Parameter notification: An object containing information broadcast to registered observers
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didUserBlocked(_ notification: NSNotification) {
        if let name = notification.userInfo?["name"] as? String {
            self.hide(view: .blockedView, false)
            blockedMessage.text =
                "YOU'VE_BLOCKED".localized() + " \(String(describing: name.capitalized))"
        }
    }
    
    
    
    /**
     This method hides system defaults back button.
     - Parameter bool: specified `Bool` value.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
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
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withTitle title: String){
        DispatchQueue.main.async {  [weak self] in
            guard let strongSelf = self else { return }
            if strongSelf.navigationController != nil {
                strongSelf.addBackButton(bool: true)
                strongSelf.navigationItem.largeTitleDisplayMode = .never
                strongSelf.titleView = UIView(frame: CGRect(x: 0, y: 0, width: (strongSelf.navigationController?.navigationBar.bounds.size.width)! - 200, height: 50))
                let buddyName = UILabel(frame: CGRect(x:0,y: 3,width: 200 ,height: 21))
                strongSelf.buddyStatus = UILabel(frame: CGRect(x:0,y: (strongSelf.titleView?.frame.origin.y ?? 0.0) + 22,width: 200,height: 21))
                
                if #available(iOS 13.0, *) {
                    strongSelf.buddyStatus?.textColor = .label
                    strongSelf.buddyStatus?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                    strongSelf.buddyStatus?.textAlignment = NSTextAlignment.center
                    strongSelf.navigationItem.titleView = strongSelf.titleView
                    buddyName.textColor = .label
                    buddyName.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                    buddyName.textAlignment = NSTextAlignment.center
                    buddyName.text = title
                } else {
                    strongSelf.buddyStatus?.textColor = .black
                    strongSelf.buddyStatus?.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                    strongSelf.buddyStatus?.textAlignment = NSTextAlignment.center
                    strongSelf.navigationItem.titleView = strongSelf.titleView
                    buddyName.textColor = .black
                    buddyName.font = UIFont.systemFont(ofSize: 17, weight: .regular)
                    buddyName.textAlignment = NSTextAlignment.center
                    buddyName.text = title
                }
                strongSelf.titleView?.addSubview(buddyName)
                strongSelf.titleView?.addSubview(strongSelf.buddyStatus!)
                strongSelf.titleView?.center = CGPoint(x: 0, y: 0)
                let tapOnTitleView = UITapGestureRecognizer(target: strongSelf, action: #selector(strongSelf.didPresentDetailView(tapGestureRecognizer:)))
                strongSelf.titleView?.isUserInteractionEnabled = true
                strongSelf.titleView?.addGestureRecognizer(tapOnTitleView)
            }
        }
    }
    
    
    /**
     This method adds back button in navigation bar.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func addBackButton(bool: Bool) {
        let backButton = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            let edit = UIImage(named: "messages-back.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
             backButton.setImage(edit, for: .normal)
            backButton.tintColor = UIKitSettings.primaryColor
        } else {}
        backButton.tintColor = UIKitSettings.primaryColor
        backButton.setTitleColor(backButton.tintColor, for: .normal) // You can change the TitleColor
        backButton.addTarget(self, action: #selector(self.didBackButtonPressed(_:)), for: .touchUpInside)
        self.navigationItem.leftBarButtonItem = nil
        if bool == true {
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }else{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
    }
    
    /**
     This method triggeres when user pressed back button.
     - Parameter title: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didBackButtonPressed(_ sender: UIButton) {
        textView.resignFirstResponder()
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        tableView = nil
        tableView?.removeFromSuperview()
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
    
    @IBAction func didCancelButtonPressed(_ sender: UIButton) {
        self.didPreformCancel()
    }
    
    @IBAction func didAudioNoteDeletePressed(_ sender: UIButton) {
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        do {
            try self.viewModel.resetRecording()
            self.audioVisualizationView.reset()
            self.currentState = .ready
        } catch {
            self.showAlert(with: error)
        }
        
        UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
            AudioServicesPlayAlertSound(SystemSoundID(1519))
            self.audioNoteView.isHidden = true
            self.audioNoteActionView.isHidden = true
            if #available(iOS 13.0, *) {
                self.audioNotePauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            self.isAudioPaused = false
        })
    }
    
    @IBAction func didAudioNoteSendPressed(_ sender: Any) {
        if currentState == .playing {
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        }
        if let url = self.viewModel.currentAudioRecord?.audioFilePathLocal?.absoluteURL {
            let newURL = "file://" + url.absoluteString
            self.sendMedia(withURL: newURL, type: .audio)
            UIView.transition(with: view, duration: 0.5, options: .transitionCrossDissolve, animations: {
                AudioServicesPlayAlertSound(SystemSoundID(1519))
                self.audioNoteView.isHidden = true
                self.audioNoteActionView.isHidden = true
            })
            if #available(iOS 13.0, *) {
                audioNotePauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
            } else {
                // Fallback on earlier versions
            }
            self.isAudioPaused = false
        }
    }
    
    
    @IBAction func didAudioNotePausePressed(_ sender: UIButton) {
        switch self.currentState {
        case .recording:
            self.chronometer?.stop()
            self.chronometer = nil
            self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
            self.audioVisualizationView.audioVisualizationMode = .read
            
            do {
                try self.viewModel.stopRecording()
                self.currentState = .recorded
            } catch {
                self.currentState = .ready
                self.showAlert(with: error)
            }
        case .recorded, .paused:
            do {
                let duration = try self.viewModel.startPlaying()
                self.currentState = .playing
                self.audioVisualizationView.meteringLevels = self.viewModel.currentAudioRecord!.meteringLevels
                self.audioVisualizationView.play(for: duration)
            } catch {
                self.showAlert(with: error)
            }
        case .playing:
            do {
                try self.viewModel.pausePlaying()
                self.currentState = .paused
                self.audioVisualizationView.pause()
            } catch {
                self.showAlert(with: error)
            }
        default:
            break
        }
    }
    
    
    private func didPreformCancel(){
        self.selectedMessages.removeAll()
        self.selectedMessage = nil
        self.selectedIndexPath = nil
        self.tableView?.isEditing = false
        self.tableView?.reloadData()
        addBackButton(bool: true)
    }
    
    /**
     This method setup navigationBar subtitle  for messageList viewController.
     - Parameter subtitle: Specifies a String value for title to be displayed.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupNavigationBar(withSubtitle subtitle: String){
        DispatchQueue.main.async {
            self.buddyStatus?.text = subtitle
        }
    }
    
    
    
    @IBAction func didCopyButtonPressed(_ sender: UIButton) {
        if selectedMessages.isEmpty {
            DispatchQueue.main.async {
                CometChatSnackBoard.display(message: "SELECT_A_MESSGE".localized(), mode: .info, duration: .short)
            }
        }else{
            var messages = [String]()
            for message in selectedMessages {
                let name = message.sender?.name?.capitalized ?? ""
                let time = String().setMessageTime(time: Int(message.sentAt))
                var messageText = ""
                switch message.messageType {
                case .text: messageText = (message as? TextMessage)?.text ?? ""
                case .image: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                case .video: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                case .file: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                case .custom: messageText = "CUSTOM_MESSAGE".localized()
                case .audio: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                case .groupMember: break
                @unknown default: break
                }
                let message = name + "[\(time)]" + ": " + messageText
                messages.append(message)
            }
            UIPasteboard.general.string = messages.joined(separator: "\n\n")
            DispatchQueue.main.async {
                CometChatSnackBoard.display(message: "TEXT_COPIED".localized(), mode: .success, duration: .short)
                self.didPreformCancel()
            }
        }
    }
    /**
     This method triggers when user taps on AvatarView in Navigation var
     - Parameter tapGestureRecognizer: A concrete subclass of UIGestureRecognizer that looks for single or multiple taps.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didPresentDetailView(tapGestureRecognizer: UITapGestureRecognizer)
    {
        guard let entity = currentEntity else { return }
        switch entity{
        case .user:
            guard let user = currentUser else { return }
            if self.messageComposer.frame.origin.y != 0 { dismissKeyboard() }
            let userDetailView = CometChatUserDetails()
            let navigationController = UINavigationController(rootViewController: userDetailView)
            userDetailView.set(user: user)
            userDetailView.isPresentedFromMessageList = true
            self.present(navigationController, animated: true, completion: nil)
        case .group:
            guard let group = currentGroup else { return }
            let groupDetailView = CometChatGroupDetail()
            let navigationController = UINavigationController(rootViewController: groupDetailView)
            groupDetailView.set(group: group)
            self.present(navigationController, animated: true, completion: nil)
        @unknown default:break
        }
    }
    
    
    
    
    /**
     This method triggers when user long press on Particular message bubble.
     - Parameter tapGestureRecognizer: A concrete subclass of UIGestureRecognizer that looks for single or multiple taps.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didLongPressedOnMessage(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView?.indexPathForRow(at: touchPoint) {
                self.selectedIndexPath = indexPath
                self.addBackButton(bool: false)
                var actions: [MessageAction] = []
                
                let group: RowPresentable = MessageActionsGroup()
                
                FeatureRestriction.isReactionsEnabled { (success) in
                    if success == .enabled {
                        actions.append(.reaction)
                    }
                }
             
              
                FeatureRestriction.isMessageRepliesEnabled { (success) in
                    if success == .enabled {
                        actions.append(.reply)
                    }
                }
                
                FeatureRestriction.isShareCopyForwardMessageEnabled { (success) in
                    if success == .enabled {
                        actions.append(.copy)
                        actions.append(.forward)
                        actions.append(.share)
                    }
                }
              
                FeatureRestriction.isMessageInPrivateEnabled { (success) in
                    if success == .enabled {
                        actions.append(.messageInPrivate)
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    
                    self.selectedMessage = selectedCell.textMessageInThread

                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                        
                        if selectedCell.textMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isEditMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.edit)
                                }
                            }
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
            
                        }else{
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                        }
                    }else{
                        
                        if selectedCell.textMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isEditMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.edit)
                                }
                            }
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                        
                        }else{}
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.textMessageInThread
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                        
                        if selectedCell.textMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isEditMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.edit)
                                }
                            }
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                           
                        }else{
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                           
                        }
                    }else{
                     
                        if selectedCell.textMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isEditMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.edit)
                                }
                            }
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                          
                        }
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverLocationMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.locationMessage
                    FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                        switch success {
                        case .enabled:
                            if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                                
                                FeatureRestriction.isDeleteMessageEnabled { (success) in
                                    if success == .enabled {
                                        actions.append(.delete)
                                    }
                                }
                        
                            }
                        case .disabled:break }
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverPollMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.pollMessage
                    FeatureRestriction.isDeleteMemberMessageEnabled { (success) in
                        switch success {
                        case .enabled:
                            if self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {

                                FeatureRestriction.isDeleteMessageEnabled { (success) in
                                    if success == .enabled {
                                        actions.append(.delete)
                                    }
                                }
                              
                            }
                        case .disabled: break
                    
                        }
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverImageMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.mediaMessageInThread
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
            
                        if selectedCell.mediaMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                            
                        }else{}
                    }else{
                        let group: RowPresentable = MessageActionsGroup()
                        if selectedCell.mediaMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                    
                        }else{ }
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverVideoMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.mediaMessageInThread
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                       
                        if selectedCell.mediaMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                           
                        }else{
                           
                        }
                    }else{
                       
                        if selectedCell.mediaMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                          
                        }else{}
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.linkPreviewMessageInThread
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                       
                        if selectedCell.linkPreviewMessageInThread?.sender?.uid == LoggedInUser.uid {
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                         
                        }else{ }
                    }else{
                       
                        if selectedCell.linkPreviewMessageInThread?.sender?.uid == LoggedInUser.uid {
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                           
                        }else{
                            
                        }
                    }
                }
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverFileMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.fileMessageInThread
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                       
                        if selectedCell.fileMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                           
                        }else{ }
                    }else{
                        
                        if selectedCell.fileMessageInThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                          
                        }else{}
                    }
                }
                
                if  let selectedCell = tableView?.cellForRow(at: indexPath) as? CometChatReceiverAudioMessageBubble {
                    AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                    self.selectedMessage = selectedCell.audioMessageinThread
                    if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
            
                        if selectedCell.audioMessageinThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                           
                        }else{}
                    }else{
                        let group: RowPresentable = MessageActionsGroup()
                        if selectedCell.audioMessageinThread?.sender?.uid == LoggedInUser.uid {
                            
                            FeatureRestriction.isDeleteMessageEnabled { (success) in
                                if success == .enabled {
                                    actions.append(.delete)
                                }
                            }
                          
                        }else{}
                    }
                }
                
                (group.rowVC as? MessageActions)?.set(actions: actions)
                presentPanModal(group.rowVC)
            }
        }
    }
    
    /**
     This method triggers when user pressed microphone  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func didLongPressedOnMicrophone(sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            self.audioNoteView.isHidden = false
            self.audioNoteActionView.isHidden = false
            if self.currentState == .ready {
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.viewModel.startRecording { [weak self] soundRecord, error in
                    if let error = error {
                        self?.showAlert(with: error)
                        return
                    }
                    self?.audioNoteDeleteButton.tintColor = .systemGray
                    self?.currentState = .recording
                    self?.chronometer = Chronometer()
                    self?.chronometer?.start()
                    self?.startTimer()
                }
            }
        }else if sender.state == .ended {
            switch self.currentState {
            case .recording:
                AudioServicesPlayAlertSound(SystemSoundID(kSystemSoundID_Vibrate))
                self.chronometer?.stop()
                self.chronometer = nil
                self.audioNoteDeleteButton.tintColor = .systemRed
                self.viewModel.currentAudioRecord!.meteringLevels = self.audioVisualizationView.scaleSoundDataToFitScreen()
                self.audioVisualizationView.audioVisualizationMode = .read
                do {
                    try self.viewModel.stopRecording()
                    self.currentState = .recorded
                } catch {
                    self.currentState = .ready
                    self.showAlert(with: error)
                }
            case .recorded, .paused:
                do {
                    self.totalSecond = 0
                    self.timer?.invalidate()
                    self.audioNoteDeleteButton.tintColor = UIColor.systemGray
                    let duration = try self.viewModel.startPlaying()
                    self.currentState = .playing
                    self.audioVisualizationView.meteringLevels = self.viewModel.currentAudioRecord!.meteringLevels
                    self.audioVisualizationView.play(for: duration)
                } catch {
                    self.showAlert(with: error)
                }
            case .playing:
                do {
                    self.totalSecond = 0
                    self.timer?.invalidate()
                    self.audioNoteDeleteButton.tintColor = UIColor.systemGray
                    try self.viewModel.pausePlaying()
                    self.currentState = .paused
                    self.audioVisualizationView.pause()
                } catch {
                    self.showAlert(with: error)
                }
            default:
                break
            }
        }
    }
    
    func startTimer(){
        self.audioNoteTimer.text = ""
        timer?.invalidate()
        self.totalSecond = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(countdown), userInfo: nil, repeats: true)
    }
    
    @objc func countdown() {
        var hours: Int
        var minutes: Int
        var seconds: Int
        hours = totalSecond / 3600
        minutes = totalSecond / 60
        seconds = totalSecond % 60
        totalSecond = totalSecond + 1
        if currentState == .recording{
            audioNoteTimer.text = "\(hours):\(minutes):\(seconds)"
        }
    }
    /**
     This method setup the tableview to load CometChatThreadedMessageList.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupTableView() {
        self.tableView?.delegate = self
        self.tableView?.dataSource = self
        self.tableView?.separatorColor = .clear
        self.addRefreshControl(inTableView: true)
        //         Added Long Press
        let longPressOnMessage = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMessage))
        tableView?.addGestureRecognizer(longPressOnMessage)
        
        
        let longPressOnMicrophone = UILongPressGestureRecognizer(target: self, action: #selector(didLongPressedOnMicrophone))
        microhone.addGestureRecognizer(longPressOnMicrophone)
        microhone.isUserInteractionEnabled = true
    }
    
    
    /**
     This method register All Types of MessageBubble  cells in tableView.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func registerCells(){
        
        let CometChatReceiverTextMessageBubble  = UINib.init(nibName: "CometChatReceiverTextMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverTextMessageBubble, forCellReuseIdentifier: "CometChatReceiverTextMessageBubble")
        
        let CometChatSenderTextMessageBubble  = UINib.init(nibName: "CometChatSenderTextMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderTextMessageBubble, forCellReuseIdentifier: "CometChatSenderTextMessageBubble")
        
        let CometChatReceiverImageMessageBubble  = UINib.init(nibName: "CometChatReceiverImageMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverImageMessageBubble, forCellReuseIdentifier: "CometChatReceiverImageMessageBubble")
        
        let CometChatSenderImageMessageBubble  = UINib.init(nibName: "CometChatSenderImageMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderImageMessageBubble, forCellReuseIdentifier: "CometChatSenderImageMessageBubble")
        
        let CometChatReceiverVideoMessageBubble  = UINib.init(nibName: "CometChatReceiverVideoMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverVideoMessageBubble, forCellReuseIdentifier: "CometChatReceiverVideoMessageBubble")
        
        let CometChatSenderVideoMessageBubble  = UINib.init(nibName: "CometChatSenderVideoMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderVideoMessageBubble, forCellReuseIdentifier: "CometChatSenderVideoMessageBubble")
        
        let CometChatReceiverFileMessageBubble  = UINib.init(nibName: "CometChatReceiverFileMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverFileMessageBubble, forCellReuseIdentifier: "CometChatReceiverFileMessageBubble")
        
        let CometChatSenderFileMessageBubble  = UINib.init(nibName: "CometChatSenderFileMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderFileMessageBubble, forCellReuseIdentifier: "CometChatSenderFileMessageBubble")
        
        let CometChatReceiverAudioMessageBubble  = UINib.init(nibName: "CometChatReceiverAudioMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverAudioMessageBubble, forCellReuseIdentifier: "CometChatReceiverAudioMessageBubble")
        
        let CometChatSenderAudioMessageBubble  = UINib.init(nibName: "CometChatSenderAudioMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderAudioMessageBubble, forCellReuseIdentifier: "CometChatSenderAudioMessageBubble")
        
        let CometChatActionMessageBubble  = UINib.init(nibName: "CometChatActionMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatActionMessageBubble, forCellReuseIdentifier: "CometChatActionMessageBubble")
        
        let CometChatReceiverLinkPreviewBubble = UINib.init(nibName: "CometChatReceiverLinkPreviewBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverLinkPreviewBubble, forCellReuseIdentifier: "CometChatReceiverLinkPreviewBubble")
        
        let CometChatSenderLinkPreviewBubble = UINib.init(nibName: "CometChatSenderLinkPreviewBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderLinkPreviewBubble, forCellReuseIdentifier: "CometChatSenderLinkPreviewBubble")
        
        let CometChatReceiverReplyMessageBubble = UINib.init(nibName: "CometChatReceiverReplyMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverReplyMessageBubble, forCellReuseIdentifier: "CometChatReceiverReplyMessageBubble")
        
        
        let CometChatSenderReplyMessageBubble = UINib.init(nibName: "CometChatSenderReplyMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderReplyMessageBubble, forCellReuseIdentifier: "CometChatSenderReplyMessageBubble")
        
        let CometChatReceiverLocationMessageBubble = UINib.init(nibName: "CometChatReceiverLocationMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverLocationMessageBubble, forCellReuseIdentifier: "CometChatReceiverLocationMessageBubble")
        
        let CometChatSenderLocationMessageBubble = UINib.init(nibName: "CometChatSenderLocationMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderLocationMessageBubble, forCellReuseIdentifier: "CometChatSenderLocationMessageBubble")
        
        let CometChatReceiverPollMessageBubble = UINib.init(nibName: "CometChatReceiverPollMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverPollMessageBubble, forCellReuseIdentifier: "CometChatReceiverPollMessageBubble")
        
        let CometChatSenderPollMessageBubble = UINib.init(nibName: "CometChatSenderPollMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderPollMessageBubble, forCellReuseIdentifier: "CometChatSenderPollMessageBubble")
        
        let CometChatReceiverStickerMessageBubble  = UINib.init(nibName: "CometChatReceiverStickerMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverStickerMessageBubble, forCellReuseIdentifier: "CometChatReceiverStickerMessageBubble")
        
        let CometChatSenderStickerMessageBubble  = UINib.init(nibName: "CometChatSenderStickerMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderStickerMessageBubble, forCellReuseIdentifier: "CometChatSenderStickerMessageBubble")
        
        let CometChatReceiverCollaborativeMessageBubble  = UINib.init(nibName: "CometChatReceiverCollaborativeMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatReceiverCollaborativeMessageBubble, forCellReuseIdentifier: "CometChatReceiverCollaborativeMessageBubble")
        
        let CometChatSenderCollaborativeMessageBubble  = UINib.init(nibName: "CometChatSenderCollaborativeMessageBubble", bundle: UIKitSettings.bundle)
        self.tableView?.register(CometChatSenderCollaborativeMessageBubble, forCellReuseIdentifier: "CometChatSenderCollaborativeMessageBubble")
    }
    
    /**
     This method setup the Chat View where user can type the message or send the media.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func configureGrowingTextView(){
        
        messageComposer.internalDelegate = self
        textView.delegate = self
        reaction.isHidden = true
        reactionView.isHidden = true
        send.isHidden = true
        
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.placeholder = NSAttributedString(string: "TYPE_A_MESSAGE".localized(), attributes: [.foregroundColor: UIColor.lightGray, .font:  UIFont.systemFont(ofSize: 17) as Any])
        textView.maxNumberOfLines = 5
        textView.delegate = self
        
        if #available(iOS 13.0, *) {
            let sendImage = UIImage(named: "send-message-filled.png", in: UIKitSettings.bundle, compatibleWith: nil)?.withRenderingMode(.alwaysTemplate)
            send.setImage(sendImage, for: .normal)
            send.tintColor = UIKitSettings.primaryColor
        } else {}
        
        reactionButtonSpace.constant = 0
        reactionButtonWidth.constant = 0
        
        FeatureRestriction.isEmojisEnabled { (success) in
            if success == .disabled {
                self.textView.keyboardType = .asciiCapable
            }
        }
        
        FeatureRestriction.isGroupChatEnabled { (success) in
            switch success {
            case .enabled:
                self.messageComposer.isHidden = false
            case .disabled:
                self.messageComposer.isHidden = true
            }
        }
    }
    
    /**
     This method will hide or unhide views such as blockedView, smartRepliesView and editMessageView as per user actions
     - Parameters:
     - view: This specified enum of  `HideView` which provides option such as `.blockedView`, `.smartRepliesView`,`.editMessageView`.
     - bool: specifies boolean value to hide or unhide view
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
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
                self.tableViewBottomConstraint.constant = 110
            case .smartRepliesView:
                FeatureRestriction.isSmartRepliesEnabled { (success) in
                    switch success {
                    case .enabled:
                        if !self.smartRepliesView.buttontitles.isEmpty {
                            self.smartRepliesView.isHidden = false
                            self.tableViewBottomConstraint.constant = 66
                            self.tableView?.scrollToBottomRow()
                        }
                    case .disabled:
                        self.smartRepliesView.isHidden = true
                        self.tableViewBottomConstraint.constant = 0
                    }
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
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
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
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
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
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func setupKeyboard(){
        textView.layer.cornerRadius = 4.0
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillChangeFrame), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        tableView?.addGestureRecognizer(tapGesture)
    }
    
    
    
    /**
     This method triggers when keyboard will change its frame.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
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
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /**
     This method triggeres when user pressed the unblock button when the user is blocked.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
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
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
    
    
    
    /**
     This method triggeres when user pressed close  button on present on edit view.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    @IBAction func didEditCloseButtonPressed(_ sender: Any) {
        self.hide(view: .editMessageView, true)
        self.didPreformCancel()
        textView.text = nil
    }
    
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    
}
/*  ----------------------------------------------------------------------------------------- */

// MARK: - UIDocumentPickerDelegate 

extension CometChatThreadedMessageList: UIDocumentPickerDelegate {
    
    /// This method triggers when we open document menu to send the message of type `File`.
    /// - Parameters:
    ///   - controller: A view controller that provides access to documents or destinations outside your app’s sandbox.
    ///   - urls: A value that identifies the location of a resource, such as an item on a remote server or the path to a local file.
    public func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        if controller.documentPickerMode == UIDocumentPickerMode.import {
            // This is what it should be
            var mediaMessage: MediaMessage?
            var lastSection = 0
            if chatMessages.count == 0 {
                lastSection = (self.tableView?.numberOfSections ?? 0)
            }else {
                lastSection = (self.tableView?.numberOfSections ?? 0) - 1
            }
            CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
            switch self.isGroupIs {
            case true:
                mediaMessage = MediaMessage(receiverUid: currentGroup?.guid ?? "", fileurl: urls[0].absoluteString,messageType: .file, receiverType: .group)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = LoggedInUser.uid
                mediaMessage?.senderUid = LoggedInUser.uid
                mediaMessage?.metaData = ["fileURL":urls[0].absoluteString]
                mediaMessage?.parentMessageId = currentMessage?.id ?? 0
                if let message = mediaMessage {
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [mediaMessage!])
                        self.filteredMessages.append(mediaMessage!)
                        self.incrementCount()
                    }else{
                        self.chatMessages[lastSection].append(message)
                        self.filteredMessages.append(message)
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.incrementCount()
                        }
                    }
                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                        }
                        DispatchQueue.main.async{ [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.reloadData()}
                    }) { (error) in
                        
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                    }
                }
            case false:
                mediaMessage = MediaMessage(receiverUid: currentUser?.uid ?? "", fileurl: urls[0].absoluteString, messageType: .file, receiverType: .user)
                mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                mediaMessage?.sender?.uid = LoggedInUser.uid
                mediaMessage?.senderUid = LoggedInUser.uid
                mediaMessage?.metaData = ["fileURL":urls[0].absoluteString]
                mediaMessage?.parentMessageId = currentMessage?.id ?? 0
                if let message = mediaMessage {
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [mediaMessage!])
                        self.filteredMessages.append(mediaMessage!)
                        self.incrementCount()
                    }else{
                        self.chatMessages[lastSection].append(message)
                        self.filteredMessages.append(message)
                        DispatchQueue.main.async { [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.incrementCount()
                        }
                    }
                    CometChat.sendMediaMessage(message: message, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                        }
                        DispatchQueue.main.async{ [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.tableView?.reloadData()}
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatThreadedMessageList: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of messages.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        if chatMessages.isEmpty {
            return 0
        }else {
            return chatMessages.count
        }
    }
    
    
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let firstMessageInSection = chatMessages[section].first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            let dateString = String().setMessageDateHeader(time: Int(firstMessageInSection.sentAt))
            let label = CometChatMessageDateHeader()
            if dateString == "1 Jan, 1970" {
                label.text = "TODAY".localized()
            }else{
                label.text = dateString
            }
            let containerView = UIView()
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            return containerView
        }
        return nil
    }
    
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    /// This method specifiesnumber of rows in CometChatThreadedMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chatMessages[section].count
    }
    
    /// This method specifies the height for row in CometChatThreadedMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return UITableView.automaticDimension
    }
    
    
    /// This method specifies the height for row in CometChatThreadedMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    /// This method specifies the view for message  in CometChatThreadedMessageList
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView.
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let message = chatMessages[indexPath.section][safe: indexPath.row] {
            
            
            if message.deletedAt > 0.0 {
                let  deletedCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverTextMessageBubble", for: indexPath) as! CometChatReceiverTextMessageBubble
                deletedCell.deletedMessage = message
                deletedCell.indexPath = indexPath
                return deletedCell
                
            }else{
            
            if message.messageCategory == .message {
               
                    switch message.messageType {
                    case .text:
                        if let textMessage = message as? TextMessage {
                            let isContainsExtension = didExtensionDetected(message: textMessage)
                            switch isContainsExtension {
                            case .linkPreview:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverLinkPreviewBubble", for: indexPath) as! CometChatReceiverLinkPreviewBubble
                                let linkPreviewMessage = message as? TextMessage
                                receiverCell.linkPreviewMessageInThread = linkPreviewMessage
                                receiverCell.linkPreviewDelegate = self
                                receiverCell.hyperlinkdelegate = self
                                return receiverCell
                            case .reply:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverReplyMessageBubble", for: indexPath) as! CometChatReceiverReplyMessageBubble
                                receiverCell.indexPath = indexPath
                                receiverCell.delegate = self
                                receiverCell.hyperlinkdelegate = self
                                receiverCell.textMessageInThread = textMessage
                                return receiverCell
                            case .smartReply,.messageTranslation, .profanityFilter, .sentimentAnalysis, .none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverTextMessageBubble", for: indexPath) as! CometChatReceiverTextMessageBubble
                                receiverCell.indexPath = indexPath
                                receiverCell.delegate = self
                                receiverCell.hyperlinkdelegate = self
                                receiverCell.textMessageInThread = textMessage
                                return receiverCell
                            case .thumbnailGeneration:break
                            case .imageModeration:break
                            case .sticker:break
                            }
                        }
                    case .image:
                        
                        if let imageMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: imageMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .reply, .sticker: break
                          
                            case .thumbnailGeneration, .imageModeration,.none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverImageMessageBubble", for: indexPath) as! CometChatReceiverImageMessageBubble
                                receiverCell.mediaMessageInThread = imageMessage
                                return receiverCell
                            }
                        }
                        
                    case .video:
                        if let videoMessage = message as? MediaMessage {
                            let isContainsExtension = didExtensionDetected(message: videoMessage)
                            switch isContainsExtension {
                            case .linkPreview, .smartReply, .messageTranslation, .profanityFilter,.sentimentAnalysis, .imageModeration, .reply, .sticker: break
                            case .thumbnailGeneration,.none:
                                let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverVideoMessageBubble", for: indexPath) as! CometChatReceiverVideoMessageBubble
                                receiverCell.mediaMessageInThread = videoMessage
                                return receiverCell
                            }
                        }
                        
                    case .audio:
                        
                        if let audioMessage = message as? MediaMessage {
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverAudioMessageBubble", for: indexPath) as! CometChatReceiverAudioMessageBubble
                            receiverCell.audioMessageinThread = audioMessage
                            return receiverCell
                        }
                        
                    case .file:
                        if let fileMessage = message as? MediaMessage {
                            let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverFileMessageBubble", for: indexPath) as! CometChatReceiverFileMessageBubble
                            receiverCell.fileMessageInThread = fileMessage
                            return receiverCell
                        }
                        
                    case .custom: break
                    case .groupMember:  break
                    @unknown default: break
                    }
              
            }else if message.messageCategory == .action {
                //  ActionMessage Cell
                let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                actionMessageCell.actionMessage = message as? ActionMessage
                return actionMessageCell
            }else if message.messageCategory == .call {
                //  CallMessage Cell
               if let call = message as? Call {
                    let  actionMessageCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                    actionMessageCell.call = call
                    return actionMessageCell
                }
            }else if message.messageCategory == .custom {
                if let type = (message as? CustomMessage)?.type {
                    if type == "location" {
                        if let locationMessage = message as? CustomMessage {
                            let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverLocationMessageBubble", for: indexPath) as! CometChatReceiverLocationMessageBubble
                            receiverCell.locationMessage = locationMessage
                            receiverCell.locationDelegate = self
                            return receiverCell
                        }
                    }else if type == "extension_poll" {
                        if let pollMesage = message as? CustomMessage {
                        let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverPollMessageBubble", for: indexPath) as! CometChatReceiverPollMessageBubble
                        receiverCell.pollMessage = pollMesage
                        receiverCell.pollDelegate = self
                        return receiverCell
                        }
                        
                    }else if type == "extension_sticker" {
                        
                        if let stickerMessage = message as? CustomMessage {
                        let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverStickerMessageBubble", for: indexPath) as! CometChatReceiverStickerMessageBubble
                        receiverCell.stickerMessageInThread = stickerMessage
                        return receiverCell
                        }
                        
                    }else if type == "extension_whiteboard" {
                        
                        if let whiteboardMessage = message as? CustomMessage {
                            let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverCollaborativeMessageBubble", for: indexPath) as! CometChatReceiverCollaborativeMessageBubble
                            receiverCell.whiteboardMessage = whiteboardMessage
                            receiverCell.collaborativeDelegate = self
                            receiverCell.indexPath = indexPath
                            return receiverCell
                        }
                        
                    }else if type == "extension_document" {
                        
                        if let writeboardMessage = message as? CustomMessage {
                            let receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatReceiverCollaborativeMessageBubble", for: indexPath) as! CometChatReceiverCollaborativeMessageBubble
                            receiverCell.indexPath = indexPath
                            receiverCell.writeboardMessage = writeboardMessage
                            receiverCell.collaborativeDelegate = self
                            return receiverCell
                        }
                    }else{
                        let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                        let customMessage = message as? CustomMessage
                        receiverCell.message.text = "CUSTOM_MESSAGE".localized() +  "\(String(describing: customMessage?.customData))"
                        return receiverCell
                    }
                }
                //  CustomMessage Cell
                let  receiverCell = tableView.dequeueReusableCell(withIdentifier: "CometChatActionMessageBubble", for: indexPath) as! CometChatActionMessageBubble
                let customMessage = message as? CustomMessage
                receiverCell.message.text = "CUSTOM_MESSAGE".localized() +  "\(String(describing: customMessage?.customData))"
                return receiverCell
            }
        }
        }
        return UITableViewCell()
    }
    
    
    
    
    /// This method triggers when particular cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.beginUpdates()
        
        UIView.animate(withDuration: 1, delay: 0.0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble, let message =  selectedCell.textMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble, let message = selectedCell.textMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble, let message = selectedCell.textMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderReplyMessageBubble, let message = selectedCell.textMessage {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true && selectedCell.textMessage != nil {
                    if !self.selectedMessages.contains(message) {
                        self.selectedMessages.append(message)
                    }
                }
            }
            
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            var player = AVPlayer()
                            if let videoURL = fileURL,
                                let url = URL(string: videoURL.absoluteString) {
                                player = AVPlayer(url: url)
                            }
                            DispatchQueue.main.async{[weak self] in
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                self?.present(playerViewController, animated: true) {
                                    playerViewController.player!.play()
                                }
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverImageMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverVideoMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.mediaMessage) {
                        self.selectedMessages.append(selectedCell.mediaMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.mediaMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            var player = AVPlayer()
                            if let videoURL = fileURL,
                                let url = URL(string: videoURL.absoluteString) {
                                player = AVPlayer(url: url)
                            }
                            DispatchQueue.main.async{ [weak self] in
                                let playerViewController = AVPlayerViewController()
                                playerViewController.player = player
                                self?.present(playerViewController, animated: true) {
                                    playerViewController.player!.play()
                                }
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.fileMessage) {
                        self.selectedMessages.append(selectedCell.fileMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.fileMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverFileMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.fileMessage) {
                        self.selectedMessages.append(selectedCell.fileMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.fileMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.audioMessage) {
                        self.selectedMessages.append(selectedCell.audioMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.audioMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverAudioMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.audioMessage) {
                        self.selectedMessages.append(selectedCell.audioMessage)
                    }
                }else{
                    self.previewMediaMessage(url: selectedCell.audioMessage?.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
                        if success {
                            if let url = fileURL {
                                self.previewItem = url as NSURL
                                self.presentQuickLook()
                            }
                        }
                    })
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                        self.selectedMessages.append(selectedCell.linkPreviewMessage)
                    }
                }
                selectedCell.receiptStack.isHidden = false
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderLinkPreviewBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                        self.selectedMessages.append(selectedCell.linkPreviewMessage)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLocationMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.locationMessage) {
                        self.selectedMessages.append(selectedCell.locationMessage)
                    }
                }
            }
            
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverPollMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.pollMessage) {
                        self.selectedMessages.append(selectedCell.pollMessage)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverStickerMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.stickerMessage) {
                        self.selectedMessages.append(selectedCell.stickerMessage)
                    }
                }
            }
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderStickerMessageBubble {
                selectedCell.receiptStack.isHidden = false
                if tableView.isEditing == true{
                    if !self.selectedMessages.contains(selectedCell.stickerMessage) {
                        self.selectedMessages.append(selectedCell.stickerMessage)
                    }
                }
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
        
        UIView.animate(withDuration: 1,delay: 0.0, usingSpringWithDamping: 0.9,
                       initialSpringVelocity: 1, options: [], animations: {
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderLinkPreviewBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.linkPreviewMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLinkPreviewBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.linkPreviewMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.linkPreviewMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                            
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderTextMessageBubble, let message =  selectedCell.textMessage {
                            selectedCell.receiptStack.isHidden = true
                            if selectedCell.textMessage != nil && self.selectedMessages.contains(message) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                            
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderStickerMessageBubble, let message =  selectedCell.stickerMessage {
                            selectedCell.receiptStack.isHidden = true
                            if selectedCell.stickerMessage != nil && self.selectedMessages.contains(message) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                            
                        }
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble, let message =  selectedCell.textMessage {
                            selectedCell.receiptStack.isHidden = true
                            if selectedCell.textMessage != nil && self.selectedMessages.contains(message) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverStickerMessageBubble, let message =  selectedCell.stickerMessage {
                            selectedCell.receiptStack.isHidden = true
                            if selectedCell.stickerMessage != nil && self.selectedMessages.contains(message) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == message.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderImageMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderVideoMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverImageMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverVideoMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.mediaMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.mediaMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverLocationMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.locationMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.locationMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverPollMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.pollMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.pollMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderFileMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.fileMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.fileMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverFileMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.fileMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.fileMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatSenderAudioMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.audioMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.audioMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
                        
                        if  let selectedCell = tableView.cellForRow(at: indexPath) as? CometChatReceiverAudioMessageBubble {
                            selectedCell.receiptStack.isHidden = true
                            if self.selectedMessages.contains(selectedCell.audioMessage) {
                                if let index = self.selectedMessages.firstIndex(where: { $0.id == selectedCell.audioMessage.id }) {
                                    self.selectedMessages.remove(at: index)
                                }
                            }
                        }
        },completion: nil)
     
        tableView.endUpdates()
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - UITextView Delegate

extension CometChatThreadedMessageList : UITextViewDelegate {
    
    
    /// This method triggers when  user stops typing in textView.
    /// - Parameter textView: A scrollable, multiline text region.
    public func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            FeatureRestriction.isVoiceNotesEnabled { (success) in
                switch success {
                case .enabled: self.microhone.isHidden = false
                case .disabled: self.microhone.isHidden = true
                }
            }
        }
    }
    
    /// This method triggers when  user starts typing in textView.
    /// - Parameter textView: A scrollable, multiline text region.
    public func textViewDidChange(_ textView: UITextView) {
        guard let indicator = typingIndicator else {
            return
        }
        if textView.text?.count == 0 {
            FeatureRestriction.isTypingIndicatorsEnabled { (success) in
                if success == .enabled {
                    CometChat.startTyping(indicator: indicator)
                }
            }
            FeatureRestriction.isVoiceNotesEnabled { (success) in
                switch success {
                case .enabled: self.microhone.isHidden = false
                case .disabled: self.microhone.isHidden = true
                }
            }
        }else{
            CometChat.endTyping(indicator: indicator)
            microhone.isHidden = true
        }
        FeatureRestriction.isTypingIndicatorsEnabled { (success) in
            if success == .enabled {
                CometChat.startTyping(indicator: indicator)
            }
        }
    }  
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - QuickLook Preview Delegate

extension CometChatThreadedMessageList:QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    
    /**
     This method will open  quick look preview controller.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func presentQuickLook(){
        DispatchQueue.main.async { [weak self] in
            let previewController = QLPreviewController()
            previewController.modalPresentationStyle = .popover
            previewController.dataSource = self
            previewController.navigationController?.title = ""
            self?.present(previewController, animated: true, completion: nil)
        }
    }
    
    /**
     This method will preview media message under  quick look preview controller.
     - Parameters:
     - url:  this specifies the `url` of Media Message.
     - completion: This handles the completion of method.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func previewMediaMessage(url: String, completion: @escaping (_ success: Bool,_ fileLocation: URL?) -> Void){
        let itemUrl = URL(string: url)
        let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationUrl = documentsDirectoryURL.appendingPathComponent(itemUrl?.lastPathComponent ?? "")
        if FileManager.default.fileExists(atPath: destinationUrl.path) {
            completion(true, destinationUrl)
        } else {
            CometChatSnackBoard.show(message: "Downloading...")
            URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    CometChatSnackBoard.hide()
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch let error as NSError {
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

// MARK: - CometChatMessageComposer Internal Delegate

extension CometChatThreadedMessageList : CometChatMessageComposerInternalDelegate {
    
    
    public func didReactionButtonPressed() {}
    
    public func didMicrophoneButtonPressed(with: UILongPressGestureRecognizer) {
        
    }
    
    /**
     This method triggers when user pressed attachment  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didAttachmentButtonPressed() {
        let group: RowPresentable = MessageActionsGroup()
        var actions = [MessageAction]()
        
        FeatureRestriction.isPhotosVideosEnabled { (success) in
            if success == .enabled {
                actions.append(.takeAPhoto)
                actions.append(.photoAndVideoLibrary)
            }
        }
        
        FeatureRestriction.isFilesEnabled { (success) in
            if success == .enabled {
                actions.append(.document)
            }
        }
        
        FeatureRestriction.isLocationSharingEnabled{ (success) in
            if success == .enabled {
                actions.append(.shareLocation)
            }
        }
        
        
        FeatureRestriction.isCollaborativeWhiteBoardEnabled { (success) in
            if success == .enabled {
                actions.append(.whiteboard)
            }
        }
        
        FeatureRestriction.isCollaborativeDocumentEnabled { (success) in
            if success == .enabled {
                actions.append(.writeboard)
            }
        }
       
        (group.rowVC as? MessageActions)?.set(actions: actions)
        presentPanModal(group.rowVC)
    }
    
    private func sendMedia(withURL: String, type: CometChat.MessageType){
        var lastSection = 0
        if chatMessages.count == 0 {
            lastSection = (self.tableView?.numberOfSections ?? 0)
        }else {
            lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        }
        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
        var mediaMessage: MediaMessage?
        switch self.isGroupIs {
        case true:
            mediaMessage = MediaMessage(receiverUid: self.currentGroup?.guid ?? "", fileurl: withURL, messageType: type, receiverType: .group)
            mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            mediaMessage?.sender?.uid = LoggedInUser.uid
            mediaMessage?.senderUid = LoggedInUser.uid
            mediaMessage?.metaData = ["fileURL":withURL]
            mediaMessage?.parentMessageId = currentMessage?.id ?? 0
            if self.chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [mediaMessage!])
                self.filteredMessages.append(mediaMessage!)
                self.incrementCount()
            }else{
                self.chatMessages[lastSection].append(mediaMessage!)
                self.filteredMessages.append(mediaMessage!)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                    strongSelf.tableView?.endUpdates()
                    strongSelf.tableView?.scrollToBottomRow()
                    strongSelf.incrementCount()
                }
            }
            CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{ [weak self] in
                    guard let strongSelf = self else { return }
                    if message.messageType == .audio || message.messageType == .file {
                        do {
                            try strongSelf.viewModel.resetRecording()
                            strongSelf.audioVisualizationView.reset()
                            strongSelf.currentState = .ready
                        } catch {
                            strongSelf.showAlert(with: error)
                        }
                    }
                    strongSelf.tableView?.reloadData()}
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        case false:
            mediaMessage = MediaMessage(receiverUid: self.currentUser?.uid ?? "", fileurl: withURL, messageType: type, receiverType: .user)
            mediaMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            mediaMessage?.sender?.uid = LoggedInUser.uid
            mediaMessage?.senderUid = LoggedInUser.uid
            mediaMessage?.metaData = ["fileURL":withURL]
            mediaMessage?.parentMessageId = currentMessage?.id ?? 0
            if self.chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [mediaMessage!])
                self.filteredMessages.append(mediaMessage!)
            }else{
                self.chatMessages[lastSection].append(mediaMessage!)
                self.filteredMessages.append(mediaMessage!)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                    strongSelf.tableView?.endUpdates()
                    strongSelf.tableView?.scrollToBottomRow()
                    strongSelf.incrementCount()
                }
            }
            CometChat.sendMediaMessage(message: mediaMessage!, onSuccess: { (message) in
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{  [weak self] in
                    guard let strongSelf = self else { return }
                    if message.messageType == .audio || message.messageType == .file {
                        do {
                            try strongSelf.viewModel.resetRecording()
                            strongSelf.audioVisualizationView.reset()
                            strongSelf.currentState = .ready
                        } catch {
                            strongSelf.showAlert(with: error)
                        }
                    }
                    strongSelf.tableView?.reloadData()}
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
    
    private func sendStickerInthread(withURL: String){
        var lastSection = 0
        if chatMessages.count == 0 {
            lastSection = (self.tableView?.numberOfSections ?? 0)
        }else {
            lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        }
        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
        var stickerMessage: CustomMessage?
        switch self.isGroupIs {
        case true:
            stickerMessage = CustomMessage(receiverUid: self.currentGroup?.guid ?? "", receiverType: .group, customData: ["sticker_url": withURL], type: "extension_sticker")
            stickerMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            stickerMessage?.sender?.uid = LoggedInUser.uid
            stickerMessage?.senderUid = LoggedInUser.uid
            stickerMessage?.parentMessageId = currentMessage?.id ?? 0
            stickerMessage?.metaData = ["incrementUnreadCount":true]
            if self.chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [stickerMessage!])
                self.filteredMessages.append(stickerMessage!)
                self.incrementCount()
            }else{
                self.chatMessages[lastSection].append(stickerMessage!)
                self.filteredMessages.append(stickerMessage!)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableViewBottomConstraint.constant = 300
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                    strongSelf.tableView?.endUpdates()
                    strongSelf.tableView?.scrollToBottomRow()
                }
            }
            if let stickerMessage = stickerMessage {
                CometChat.sendCustomMessage(message: stickerMessage, onSuccess: { (message) in
                    if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                        self.chatMessages[lastSection][row] = message
                    }
                    DispatchQueue.main.async{ [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableView?.reloadData()}
                }) { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
                }
            }
        case false:
            stickerMessage = CustomMessage(receiverUid: self.currentUser?.uid ?? "", receiverType: .user, customData: ["sticker_url": withURL], type: "extension_sticker")
            stickerMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            stickerMessage?.sender?.uid = LoggedInUser.uid
            stickerMessage?.senderUid = LoggedInUser.uid
            stickerMessage?.parentMessageId = currentMessage?.id ?? 0
            stickerMessage?.metaData = ["incrementUnreadCount":true]
           
            if self.chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [stickerMessage!])
                self.filteredMessages.append(stickerMessage!)
            }else{
                self.chatMessages[lastSection].append(stickerMessage!)
                self.filteredMessages.append(stickerMessage!)
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableViewBottomConstraint.constant = 300
                    strongSelf.tableView?.beginUpdates()
                    strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                    strongSelf.tableView?.endUpdates()
                    strongSelf.tableView?.scrollToBottomRow()
                }
            }
            if let stickerMessage = stickerMessage {
                CometChat.sendCustomMessage(message: stickerMessage, onSuccess: { (message) in
                    if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                        self.chatMessages[lastSection][row] = message
                    }
                    DispatchQueue.main.async{  [weak self] in
                        guard let strongSelf = self else { return }
                         strongSelf.tableView?.reloadData()}
                }) { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
                }
            }
        }
    }
    
    
    
    
    /**
     This method triggers when user pressed sticker  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didStickerButtonPressed() {
        
        
    }
    
    
    
    /**
     This method triggers when user pressed send  button in Chat View.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didSendButtonPressed() {
        var lastSection = 0
        if chatMessages.count == 0 {
            lastSection = (self.tableView?.numberOfSections ?? 0)
        }else {
            lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        }
        if messageMode == .edit {
            guard let textMessage = selectedMessage as? TextMessage else { return }
            guard let indexPath = selectedIndexPath else { return }
            CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
            if let message:String = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) {
                textMessage.text = message
                CometChat.edit(message: textMessage, onSuccess: { (editedMessage) in
                    if let row = self.chatMessages[indexPath.section].firstIndex(where: {$0.id == editedMessage.id}) {
                        self.chatMessages[indexPath.section][row] = editedMessage
                    }
                    DispatchQueue.main.async{  [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableView?.reloadRows(at: [indexPath], with: .automatic)
                        strongSelf.hide(view: .editMessageView, true)
                        strongSelf.hide(view: .smartRepliesView, true)
                        strongSelf.didPreformCancel()
                        strongSelf.messageMode = .send
                        strongSelf.textView.text = ""
                    }
                }) { (error) in
                    DispatchQueue.main.async{ [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.hide(view: .editMessageView, true)
                        strongSelf.hide(view: .smartRepliesView, true)
                        strongSelf.didPreformCancel()
                        strongSelf.messageMode = .send
                        strongSelf.textView.text = ""
                        if let error = error as? CometChatException{
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
                }
            }
        }else if messageMode == .reply {
            var textMessage: TextMessage?
            let message:String = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if(message.count == 0){
                
            }else{
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                switch self.isGroupIs {
                case true:
                    textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: message, receiverType: .group)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = LoggedInUser.uid
                    textMessage?.senderUid = LoggedInUser.uid
                    textMessage?.metaData = ["reply-message": selectedMessage?.rawMessage ]
                    textMessage?.parentMessageId = currentMessage?.id ?? 0
                    
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [textMessage!])
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        self.incrementCount()
                    }else{
                        self.chatMessages[lastSection].append(textMessage!)
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        DispatchQueue.main.async {[weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.hide(view: .editMessageView, true)
                            strongSelf.hide(view: .smartRepliesView, true)
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.textView.text = ""
                            strongSelf.incrementCount()
                        }
                    }
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                            DispatchQueue.main.async{ [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.reloadData()
                                strongSelf.didPreformCancel()
                                strongSelf.messageMode = .send
                                strongSelf.textView.text = ""
                                textMessage = nil
                            }
                        }
                        textMessage = nil
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                    }
                case false:
                    textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: message, receiverType: .user)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = LoggedInUser.uid
                    textMessage?.senderUid = LoggedInUser.uid
                    textMessage?.metaData = ["reply-message": selectedMessage?.rawMessage ]
                    
                    textMessage?.parentMessageId = currentMessage?.id ?? 0
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [textMessage!])
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        self.incrementCount()
                    }else{
                        self.chatMessages[lastSection].append(textMessage!)
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        DispatchQueue.main.async {  [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.hide(view: .editMessageView, true)
                            strongSelf.hide(view: .smartRepliesView, true)
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.textView.text = ""
                            strongSelf.incrementCount()
                        }
                    }
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                            DispatchQueue.main.async{ [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.reloadData()
                                strongSelf.didPreformCancel()
                                strongSelf.messageMode = .send
                                strongSelf.textView.text = ""
                                textMessage = nil
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                    }
                }
            }
        }else{
            var textMessage: TextMessage?
            let message:String = textView.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if(message.count == 0){
                
            }else{
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                switch self.isGroupIs {
                case true:
                    textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: message, receiverType: .group)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = LoggedInUser.uid
                    textMessage?.senderUid = LoggedInUser.uid
                    textMessage?.parentMessageId = currentMessage?.id ?? 0
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [textMessage!])
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        self.incrementCount()
                    }else{
                        self.chatMessages[lastSection].append(textMessage!)
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        DispatchQueue.main.async {[weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.hide(view: .smartRepliesView, true)
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.textView.text = ""
                            strongSelf.incrementCount()
                        }
                    }
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                            DispatchQueue.main.async{ [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.reloadData()
                                textMessage = nil
                            }
                        }
                        textMessage = nil
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                    }
                case false:
                    textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: message, receiverType: .user)
                    textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
                    textMessage?.sender?.uid = LoggedInUser.uid
                    textMessage?.senderUid = LoggedInUser.uid
                    textMessage?.parentMessageId = currentMessage?.id ?? 0
                    if chatMessages.count == 0 {
                        self.addNewGroupedMessage(messages: [textMessage!])
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        self.incrementCount()
                    }else{
                        self.chatMessages[lastSection].append(textMessage!)
                        self.filteredMessages.append(textMessage!)
                        guard let indicator = typingIndicator else {
                            return
                        }
                        CometChat.endTyping(indicator: indicator)
                        DispatchQueue.main.async {  [weak self] in
                            guard let strongSelf = self else { return }
                            strongSelf.hide(view: .smartRepliesView, true)
                            strongSelf.tableView?.beginUpdates()
                            strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                            strongSelf.tableView?.endUpdates()
                            strongSelf.tableView?.scrollToBottomRow()
                            strongSelf.textView.text = ""
                            strongSelf.incrementCount()
                        }
                    }
                    CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                        if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                            self.chatMessages[lastSection][row] = message
                            DispatchQueue.main.async{ [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.tableView?.reloadData()
                                textMessage = nil
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
                            }
                        }
                     }
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatMessageDelegate

extension CometChatThreadedMessageList : CometChatMessageDelegate {
    
    /**
     This method append new message on UI when new message is received.
     /// - Parameter message: This specified the `BaseMessage` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    private func appendNewMessage(message: BaseMessage) {
        DispatchQueue.main.async{ CometChatSoundManager().play(sound: .incomingMessage, bool: true)}
        switch message.receiverType {
        case .user:
            CometChat.markAsRead(baseMessage: message)
            if chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [message])
                self.incrementCount()
            }else{
                DispatchQueue.main.async{ [weak self] in
                    if let strongSelf = self, let lastSection = strongSelf.tableView?.numberOfSections {
                        strongSelf.chatMessages[lastSection - 1].append(message)
                        strongSelf.tableView?.reloadData()
                        strongSelf.tableView?.scrollToBottomRow()
                        strongSelf.incrementCount()
                    }
                }
            }
            
        case .group:
            CometChat.markAsRead(baseMessage: message)
            if chatMessages.count == 0 {
                self.addNewGroupedMessage(messages: [message])
                self.incrementCount()
            }else{
                DispatchQueue.main.async{ [weak self] in
                    if let strongSelf = self, let lastSection = strongSelf.tableView?.numberOfSections {
                        strongSelf.chatMessages[lastSection - 1].append(message)
                        strongSelf.tableView?.reloadData()
                        strongSelf.tableView?.scrollToBottomRow()
                        strongSelf.incrementCount()
                    }
                }
            }
        @unknown default: break
        }
    }
    
    /**
     This method triggers when real time text message message arrives from CometChat Pro SDK
     - Parameter textMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onTextMessageReceived(textMessage: TextMessage) {
        
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            //Appending Real time text messages for User.
            if strongSelf.currentMessage?.id == textMessage.parentMessageId {
                
                if let sender = textMessage.sender?.uid, let currentUser = strongSelf.currentUser?.uid {
                    if sender == currentUser && textMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: textMessage)
                        let titles = strongSelf.parseSmartRepliesMessages(message: textMessage)
                        strongSelf.smartRepliesView.set(titles: titles)
                        strongSelf.hide(view: .smartRepliesView, false)
                        
                    }else if sender == LoggedInUser.uid && textMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: textMessage)
                        let titles = strongSelf.parseSmartRepliesMessages(message: textMessage)
                        strongSelf.smartRepliesView.set(titles: titles)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }else{
                    CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true)
                }
                
                //Appending Real time text messages for Group.
                if let currentGroup = strongSelf.currentGroup?.guid {
                    let sender = textMessage.senderUid
                    let group = textMessage.receiverUid
                    // Receiving real time messages for the group this window is opened for.
                    if group == currentGroup && textMessage.receiverType == .group && sender != LoggedInUser.uid {
                        strongSelf.appendNewMessage(message: textMessage)
                        let titles = strongSelf.parseSmartRepliesMessages(message: textMessage)
                        strongSelf.smartRepliesView.set(titles: titles)
                        strongSelf.hide(view: .smartRepliesView, false)
                    }else if sender == LoggedInUser.uid && textMessage.receiverType == .group && group == currentGroup {
                        strongSelf.appendNewMessage(message: textMessage)
                        let titles = strongSelf.parseSmartRepliesMessages(message: textMessage)
                        strongSelf.smartRepliesView.set(titles: titles)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }else{
                    CometChatSoundManager().play(sound: .incomingMessageForOther, bool: true)
                }
            }
        }
    }
    
    /**
     This method triggers when real time media message arrives from CometChat Pro SDK
     - Parameter mediaMessage: This Specifies TextMessage Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMediaMessageReceived(mediaMessage: MediaMessage) {
        
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            //Appending Real time text messages for User.
            if strongSelf.currentMessage?.id == mediaMessage.parentMessageId {
                if let sender = mediaMessage.sender?.uid, let currentUser = strongSelf.currentUser?.uid {
                    if sender == currentUser && mediaMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: mediaMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                        
                    }else if sender == LoggedInUser.uid && mediaMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: mediaMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }
                
                //Appending Real time text messages for Group.
                if let currentGroup = strongSelf.currentGroup?.guid {
                    let sender = mediaMessage.receiverUid
                    // Receiving real time messages for the group this window is opened for.
                    if sender == currentGroup && mediaMessage.receiverType == .group {
                        strongSelf.appendNewMessage(message: mediaMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }else if sender == LoggedInUser.uid && mediaMessage.receiverType == .group {
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }
            }
            
        }
    }
    
    public func onCustomMessageReceived(customMessage: CustomMessage) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            //Appending Real time text messages for User.
            if strongSelf.currentMessage?.id == customMessage.parentMessageId {
                if let sender = customMessage.sender?.uid, let currentUser = strongSelf.currentUser?.uid {
                    if sender == currentUser && customMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: customMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                        
                    }else if sender == LoggedInUser.uid && customMessage.receiverType == .user {
                        strongSelf.appendNewMessage(message: customMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }
                
                //Appending Real time text messages for Group.
                if let currentGroup = strongSelf.currentGroup?.guid {
                    let sender = customMessage.receiverUid
                    // Receiving real time messages for the group this window is opened for.
                    if sender == currentGroup && customMessage.receiverType == .group {
                        strongSelf.appendNewMessage(message: customMessage)
                        strongSelf.hide(view: .smartRepliesView, true)
                    }else if sender == LoggedInUser.uid && customMessage.receiverType == .group {
                        strongSelf.hide(view: .smartRepliesView, true)
                    }
                }
            }
        }
    }
    
    /**
     This method triggers when receiver reads the message sent by you.
     - Parameter receipt: This Specifies MessageReceipt Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMessagesRead(receipt: MessageReceipt) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            if receipt.sender?.uid == strongSelf.currentUser?.uid && receipt.receiverType == .user{
                for messages in strongSelf.chatMessages {
                    for message in messages where message.readAt == 0 {
                        message.readAt = Double(receipt.timeStamp)
                    }
                }
                DispatchQueue.main.async {strongSelf.tableView?.reloadData()}
            }else if receipt.receiverId == strongSelf.currentGroup?.guid && receipt.receiverType == .group{
                for messages in strongSelf.chatMessages {
                    for message in messages where message.readAt == 0 {
                        message.readAt = Double(receipt.timeStamp)
                    }
                }
                DispatchQueue.main.async {strongSelf.tableView?.reloadData()}
            }
        }
    }
    
    /**
     This method triggers when  message sent by you reaches to the receiver.
     - Parameter receipt: This Specifies MessageReceipt Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onMessagesDelivered(receipt: MessageReceipt) {
        DispatchQueue.main.async{ [weak self] in
            guard let strongSelf = self else { return }
            if receipt.sender?.uid == strongSelf.currentUser?.uid && receipt.receiverType == .user{
                for messages in strongSelf.chatMessages {
                    for message in messages where message.deliveredAt == 0 {
                        message.deliveredAt = Double(receipt.timeStamp)
                    }
                }
                DispatchQueue.main.async {strongSelf.tableView?.reloadData()}
            }else if receipt.receiverId == strongSelf.currentGroup?.guid && receipt.receiverType == .group{
                for messages in strongSelf.chatMessages {
                    for message in messages where message.deliveredAt == 0 {
                        message.deliveredAt = Double(receipt.timeStamp)
                    }
                }
                DispatchQueue.main.async {strongSelf.tableView?.reloadData()}
            }
        }
    }
    
    
    
    public func onMessageEdited(message: BaseMessage) {
        
        if let indexpath = chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int{
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.beginUpdates()
                strongSelf.chatMessages[section][row] = message
                strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                strongSelf.tableView?.endUpdates()
            }
        }
    }
    
    public func onMessageDeleted(message: BaseMessage) {
        
        FeatureRestriction.isHideDeletedMessagesEnabled { (success) in
            switch success {
            
            case .enabled:
                
                if let indexpath = self.chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int{
                    DispatchQueue.main.async {  [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.chatMessages[indexpath.section].remove(at: indexpath.row)
                        strongSelf.tableView?.deleteRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.reloadData()
                    }
                }
      
            case .disabled:
                if let indexpath = self.chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int{
                    DispatchQueue.main.async {  [weak self] in
                        guard let strongSelf = self else { return }
                        strongSelf.tableView?.beginUpdates()
                        strongSelf.chatMessages[section][row] = message
                        strongSelf.tableView?.reloadRows(at: [indexpath], with: .automatic)
                        strongSelf.tableView?.endUpdates()
                    }
                }
            }
        }
    }
    
    
    
}
/*  ----------------------------------------------------------------------------------------- */

// MARK: - CometChatUserDelegate Delegate

extension CometChatThreadedMessageList : CometChatUserDelegate {
    
    /**
     This event triggers when user is Online.
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onUserOnline(user: User) {
        if user.uid == currentUser?.uid{
            if user.status == .online {
                DispatchQueue.main.async { [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.setupNavigationBar(withSubtitle: "ONLINE".localized())
                }
            }
        }
    }
    
    /**
     This event triggers when user goes Offline..
     - Parameter user: This specifies `User` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onUserOffline(user: User) {
        if user.uid == currentUser?.uid {
            if user.status == .offline {
                DispatchQueue.main.async {  [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.setupNavigationBar(withSubtitle: "OFFLINE".localized())
                }
            }
        }
    }
}



// MARK: - Smart Replies Delegate

extension CometChatThreadedMessageList : CometChatSmartRepliesPreviewDelegate {
    
    /**
     This method triggers when user pressed particular button in smart replies view.
     - Parameter title: `title` specifies the title of the button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didSendButtonPressed(title: String) {
        var textMessage: TextMessage?
        let lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
        switch self.isGroupIs {
        case true:
            textMessage = TextMessage(receiverUid: currentGroup?.guid ?? "", text: title, receiverType: .group)
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.sender?.uid = LoggedInUser.uid
            textMessage?.senderUid = LoggedInUser.uid
            textMessage?.parentMessageId = currentMessage?.id ?? 0
            self.chatMessages[lastSection].append(textMessage!)
            self.filteredMessages.append(textMessage!)
            self.hide(view: .smartRepliesView, true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            DispatchQueue.main.async {  [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.beginUpdates()
                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                strongSelf.tableView?.endUpdates()
                strongSelf.tableView?.scrollToBottomRow()
                strongSelf.textView.text = ""
                strongSelf.incrementCount()
            }
            
            CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{  [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.reloadData()
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        case false:
            textMessage = TextMessage(receiverUid: currentUser?.uid ?? "", text: title, receiverType: .user)
            textMessage?.muid = "\(Int(Date().timeIntervalSince1970 * 1000))"
            textMessage?.sender?.uid = LoggedInUser.uid
            textMessage?.senderUid = LoggedInUser.uid
            textMessage?.parentMessageId = currentMessage?.id ?? 0
            self.chatMessages[lastSection].append(textMessage!)
            self.filteredMessages.append(textMessage!)
            self.hide(view: .smartRepliesView, true)
            guard let indicator = typingIndicator else {
                return
            }
            CometChat.endTyping(indicator: indicator)
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.tableView?.beginUpdates()
                strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                strongSelf.tableView?.endUpdates()
                strongSelf.tableView?.scrollToBottomRow()
                strongSelf.textView.text = ""
                strongSelf.incrementCount()
            }
            CometChat.sendTextMessage(message: textMessage!, onSuccess: { (message) in
                CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                if let row = self.chatMessages[lastSection].firstIndex(where: {$0.muid == message.muid}) {
                    self.chatMessages[lastSection][row] = message
                }
                DispatchQueue.main.async{ [weak self] in
                    guard let strongSelf = self else { return }
                    strongSelf.tableView?.reloadData() }
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Link Preview Delegate

extension CometChatThreadedMessageList: LinkPreviewDelegate {
    
    /**
     This method triggers when user pressed visit button in link preview bubble.
     - Parameters:
     - link: link specifies `link` of the message.
     - sender: specifies the user who is pressing this button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
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
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func didPlayButtonPressed(link: String, sender: UIButton) {
        guard let url = URL(string: link) else { return }
        UIApplication.shared.open(url)
    }
}

/*  ----------------------------------------------------------------------------------------- */


extension CometChatThreadedMessageList: CometChatReceiverTextMessageBubbleDelegate {
    
    
    func didTapOnSentimentAnalysisViewForLeftBubble(indexPath: IndexPath) {
        if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatReceiverTextMessageBubble {
            let alert = UIAlertController(title: "", message: "Are you sure want to view this message?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "VIEW".localized(), style: .default, handler: { (action: UIAlertAction!) in
                self.tableView?.beginUpdates()
                cell.message.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                cell.sentimentAnalysisView.isHidden = true
                cell.spaceConstraint.constant = 0
                cell.widthconstraint.constant = 0
                if let message = cell.textMessage {
                    cell.parseProfanityFilter(forMessage: message)
                    if #available(iOS 13.0, *) {
                        cell.message.textColor = .label
                    } else {
                        cell.message.textColor = .black
                    }
                }
                self.tableView?.endUpdates()
            }))
            alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            alert.view.tintColor = UIKitSettings.primaryColor
            present(alert, animated: true, completion: nil)
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */



extension CometChatThreadedMessageList: CometChatReceiverReplyMessageBubbleDelegate {
    
    func didTapOnSentimentAnalysisViewForLeftReplyBubble(indexPath: IndexPath) {
        if let cell = self.tableView?.cellForRow(at: indexPath) as? CometChatReceiverReplyMessageBubble {
            let alert = UIAlertController(title: "", message: "Are you sure want to view this message?", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { (action: UIAlertAction!) in
                self.tableView?.beginUpdates()
                cell.message.font = UIFont.systemFont(ofSize: 13, weight: .regular)
                cell.sentimentAnalysisView.isHidden = true
                cell.spaceConstraint.constant = 0
                cell.widthconstraint.constant = 0
                if let message = cell.textMessage {
                    cell.parseProfanityFilter(forMessage: message)
                    if #available(iOS 13.0, *) {
                        cell.message.textColor = .label
                    } else {
                        cell.message.textColor = .black
                    }
                }
                self.tableView?.endUpdates()
            }))
            alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: { (action: UIAlertAction!) in
            }))
            alert.view.tintColor = UIKitSettings.primaryColor
            present(alert, animated: true, completion: nil)
        }
    }
    
}

extension CometChatThreadedMessageList {
     static var threadDelegate: ThreadDelegate?
}


extension CometChatThreadedMessageList : MessageActionsDelegate {
    
    func didVideoCallPressed() {}
    
    func didAudioCallPressed() {}
    
    func didMessageTranslatePressed() {}
    
    
    func didReplyInPrivatePressed() {
       
        if let message = selectedMessage, let user = message.sender {
            let messageList = CometChatMessageList()
            messageList.set(conversationWith: user, type: .user)
            messageList.isMessageInPrivateEnabled = true
            messageList.selectedMessage = message
            messageList.messageMode = .reply
            messageList.isMessageInPrivateEnabled = true
            self.navigationController?.pushViewController(messageList, animated: true)
        }
        
    }
    
    func didMessageInPrivatePressed() {
        if let message = selectedMessage, let user = message.sender {
            let messageList = CometChatMessageList()
            messageList.set(conversationWith: user, type: .user)
            messageList.isMessageInPrivateEnabled = true
            self.navigationController?.pushViewController(messageList, animated: true)
        }
    }
    
    func didCollaborativeWriteboardPressed() {
        
        if let uid = currentUser?.uid {
            CometChat.callExtension(slug: "document", type: .post, endPoint: "v1/create", body: ["receiver":uid,"receiverType":"user"], onSuccess: { (response) in
                
            }) { (error) in
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
        
        if let guid = currentGroup?.guid {
            CometChat.callExtension(slug: "document", type: .post, endPoint: "v1/create", body: ["receiver":guid,"receiverType":"group"], onSuccess: { (response) in
                
            }) { (error) in
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
    
    func didCollaborativeWhiteboardPressed() {
        if let uid = currentUser?.uid {
            CometChat.callExtension(slug: "whiteboard", type: .post, endPoint: "v1/create", body: ["receiver":uid,"receiverType":"user"], onSuccess: { (response) in
                
            }) { (error) in
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
        
        
        
        if let guid = currentGroup?.guid {
            CometChat.callExtension(slug: "whiteboard", type: .post, endPoint: "v1/create", body: ["receiver":guid,"receiverType":"group"], onSuccess: { (response) in
                
            }) { (error) in
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
    
    
    func didReactionPressed() {
        
    }
    
    func didStickerPressed() {
        
       DispatchQueue.main.async {
            let stickerView = CometChatStickerKeyboard()
            stickerView.modalPresentationStyle = .custom
            self.present(stickerView, animated: true, completion: nil)
        }
    }
    
    func takeAPhotoPressed() {
        CameraHandler.shared.presentCamera(for: self)
        CameraHandler.shared.imagePickedBlock = {(photoURL) in
            self.sendMedia(withURL: photoURL, type: .image)
        }
    }
    
    func copyPressed() {
        if let message = selectedMessage {
            var messageText = ""
            switch message.messageType {
            case .text: messageText = (message as? TextMessage)?.text ?? ""
            case .image: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
            case .video: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
            case .file: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
            case .custom: messageText = "CUSTOM_MESSAGE".localized()
            case .audio: messageText = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
            case .groupMember: break
            @unknown default:break
            }
            UIPasteboard.general.string = messageText
            DispatchQueue.main.async {
                CometChatSnackBoard.display(message: "TEXT_COPIED".localized(), mode: .success, duration: .short)
                self.didPreformCancel()
            }
        }
    }
    
    func photoAndVideoLibraryPressed() {
        CameraHandler.shared.presentPhotoLibrary(for: self)
        CameraHandler.shared.imagePickedBlock = {(photoURL) in
            self.sendMedia(withURL: photoURL, type: .image)
        }
        CameraHandler.shared.videoPickedBlock = {(videoURL) in
            self.sendMedia(withURL: videoURL, type: .video)
        }
    }
    
    func documentPressed() {
        self.documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(self.documentPicker, animated: true, completion: nil)
    }
    
    func shareLocationPressed() {
        let lastSection = (self.tableView?.numberOfSections ?? 0) - 1
        
        switch self.isGroupIs {
        case true:
            let name = (CometChat.getLoggedInUser()?.name ?? "") + "S_LOCATION".localized()
            
            let alert = UIAlertController(title: name , message: "SHARE_LOCATION_CONFIRMATION_MESSAGE".localized(), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "SHARE".localized(), style: .default, handler: { action in
                
                if let location = self.curentLocation {
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        let pushtitle = (CometChat.getLoggedInUser()?.name ?? "") + "HAS_SHARED_LOCATION".localized()
                        let locationData = ["name": name,"latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude] as [String : Any]
                       
                        
                        guard let group = strongSelf.currentGroup else { return  }
                        let locationMessage = CustomMessage(receiverUid: group.guid , receiverType: .group, customData: locationData, type: "location")
                        locationMessage.metaData = ["pushNotification": pushtitle, "incrementUnreadCount":true]
                        locationMessage.parentMessageId = strongSelf.currentMessage?.id ?? 0
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: nil, message: "SENDING_LOCATION".localized(), preferredStyle: .alert)
                            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                            loadingIndicator.hidesWhenStopped = true
                            loadingIndicator.style = UIActivityIndicatorView.Style.gray
                            loadingIndicator.startAnimating()
                            alert.view.addSubview(loadingIndicator)
                            strongSelf.present(alert, animated: true, completion: nil)
                        }
                        CometChat.sendCustomMessage(message: locationMessage, onSuccess: { (message) in
                            DispatchQueue.main.async { [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.dismiss(animated: true, completion: nil)
                                CometChatSnackBoard.display(message: "LOCATION_SENT_SUCCESSFULLY".localized(), mode: .success, duration: .short)
                                
                                if strongSelf.chatMessages.count == 0 {
                                    strongSelf.addNewGroupedMessage(messages: [message])
                                    strongSelf.filteredMessages.append(message)
                                    strongSelf.incrementCount()
                                }else{
                                    strongSelf.chatMessages[lastSection].append(message)
                                    strongSelf.filteredMessages.append(message)
                                    strongSelf.tableView?.beginUpdates()
                                    strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                                    strongSelf.tableView?.endUpdates()
                                    strongSelf.tableView?.scrollToBottomRow()
                                    CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                                }
                            }
                        }) { (error) in
                            DispatchQueue.main.async {
                                CometChatSnackBoard.display(message: "UNABLE_TO_SEND_LOCATON_MESSAGE".localized(), mode: .error, duration: .short)
                            }
                        }
                    }
                }
            }))
            alert.view.tintColor = UIKitSettings.primaryColor
            alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: { action in
                
            }))
            self.present(alert, animated: true)
        case false:
            let name = (CometChat.getLoggedInUser()?.name ?? "") + "S_LOCATION".localized()
            
            let alert = UIAlertController(title: name , message: "SHARE_LOCATION_CONFIRMATION_MESSAGE".localized(), preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "SHARE".localized(), style: .default, handler: { action in
                
                if let location = self.curentLocation {
                    DispatchQueue.main.async { [weak self] in
                        guard let strongSelf = self else { return }
                        let pushtitle = (CometChat.getLoggedInUser()?.name ?? "") + "HAS_SHARED_LOCATION".localized()
                        let locationData = ["name": name,"latitude": location.coordinate.latitude, "longitude": location.coordinate.longitude] as [String : Any]
                        
                        guard let user = strongSelf.currentUser else { return  }
                        let locationMessage = CustomMessage(receiverUid: user.uid ?? "", receiverType: .user, customData: locationData, type: "location")
                        locationMessage.metaData = ["pushNotification": pushtitle, "incrementUnreadCount":true]
                        locationMessage.parentMessageId = strongSelf.currentMessage?.id ?? 0
                        DispatchQueue.main.async {
                            let alert = UIAlertController(title: nil, message: "SENDING_LOCATION".localized(), preferredStyle: .alert)
                            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
                            loadingIndicator.hidesWhenStopped = true
                            loadingIndicator.style = UIActivityIndicatorView.Style.gray
                            loadingIndicator.startAnimating()
                            alert.view.addSubview(loadingIndicator)
                            strongSelf.present(alert, animated: true, completion: nil)
                        }
                        CometChat.sendCustomMessage(message: locationMessage, onSuccess: { (message) in
                            DispatchQueue.main.async { [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.dismiss(animated: true, completion: nil)
                        
                                CometChatSnackBoard.display(message: "LOCATION_SENT_SUCCESSFULLY".localized(), mode: .success, duration: .short)
                                if strongSelf.chatMessages.count == 0 {
                                    strongSelf.addNewGroupedMessage(messages: [message])
                                    strongSelf.filteredMessages.append(message)
                                }else{
                                    strongSelf.chatMessages[lastSection].append(message)
                                    strongSelf.filteredMessages.append(message)
                                    strongSelf.tableView?.beginUpdates()
                                    strongSelf.tableView?.insertRows(at: [IndexPath.init(row: strongSelf.chatMessages[lastSection].count - 1, section: lastSection)], with: .right)
                                    strongSelf.tableView?.endUpdates()
                                    strongSelf.tableView?.scrollToBottomRow()
                                    CometChatSoundManager().play(sound: .outgoingMessage, bool: true)
                                }
                            }
                        }) { (error) in
                            DispatchQueue.main.async {
                            
                                CometChatSnackBoard.display(message: "UNABLE_TO_SEND_LOCATON_MESSAGE".localized(), mode: .error, duration: .short)
                            }
                        }
                    }
                }
            }))
            alert.view.tintColor = UIKitSettings.primaryColor
            alert.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: { action in
                
            }))
            alert.view.tintColor = UIKitSettings.primaryColor
            self.present(alert, animated: true)
        }
    }
    
    func createAPollPressed() {
        DispatchQueue.main.async {
            let createAPoll = CometChatCreatePoll()
            createAPoll.set(title: "CREATE_A_POLL".localized(), mode: .automatic)
            if let user = self.currentUser {
                createAPoll.user = user
            }
            if let group = self.currentGroup {
                createAPoll.group = group
            }
            let navigationController = UINavigationController(rootViewController: createAPoll)
            self.present(navigationController, animated: true, completion: nil)
        }
    }
    
    func didMessageInfoPressed() {
        if let message = selectedMessage {
            let cometChatMessageInformation = CometChatMessageInformation()
            cometChatMessageInformation.set(message: message)
            cometChatMessageInformation.title = "MESSAGE_INFORMATION".localized()
            self.navigationController?.pushViewController(cometChatMessageInformation, animated: true)
        }
    }
    
    func didStartThreadPressed() {
        
    }
    
    /**
     This method triggeres when user pressed edit message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didEditPressed() {
        self.messageMode = .edit
        self.hide(view: .editMessageView, false)
        guard let message = selectedMessage else { return }
        editViewName.text = "EDIT_MESSAGE".localized()
        
        if let message = (message as? TextMessage)?.text {
            editViewMessage.text = message
            textView.text = message
        }
    }
    
    /**
     This method triggeres when user pressed delete message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didDeletePressed() {
        guard let message = selectedMessage else { return }
        
        if message.id == self.currentMessage?.id  {
            CometChat.delete(messageId: message.id, onSuccess: { (deletedMessage) in
                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didThreadDeleted"), object: nil, userInfo: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error as? CometChatException{
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                    self.didPreformCancel()
                }
            }
        }else{
            guard let indexPath = selectedIndexPath else { return }
            CometChat.delete(messageId: message.id, onSuccess: { (deletedMessage) in
                FeatureRestriction.isHideDeletedMessagesEnabled { (success) in
                    switch success {
                    
                    case .enabled:
                                           
                        if let indexpath = self.chatMessages.indexPath(where: {$0.id == message.id}), let section = indexpath.section as? Int, let row = indexpath.row as? Int{
                            DispatchQueue.main.async {  [weak self] in
                                guard let strongSelf = self else { return }
                                strongSelf.chatMessages[indexpath.section].remove(at: indexpath.row)
                                strongSelf.tableView?.deleteRows(at: [indexpath], with: .automatic)
                                strongSelf.tableView?.reloadData()
                                strongSelf.didPreformCancel()
                            }
                        }
                      
                    case .disabled:
                        let textMessage:BaseMessage = (deletedMessage as? ActionMessage)?.actionOn as! BaseMessage
                        if let row = self.chatMessages[indexPath.section].firstIndex(where: {$0.id == textMessage.id}) {
                            self.chatMessages[indexPath.section][row] = textMessage
                        }
                        DispatchQueue.main.async {
                            self.tableView?.reloadRows(at: [indexPath], with: .automatic)
                            self.didPreformCancel()
                        }
                    }
                }
            }) { (error) in
                DispatchQueue.main.async {
                    if let error = error as? CometChatException{
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                    self.didPreformCancel()
                }
            }
        }
    }
    
    func didReplyPressed() {
        self.messageMode = .reply
        self.hide(view: .editMessageView, false)
        guard let message = selectedMessage else { return }
        if let name = message.sender?.name {
            editViewName.text = name.capitalized
        }
        switch message.messageType {
        case .text: editViewMessage.text = (message as? TextMessage)?.text
        case .image: editViewMessage.text = "MESSAGE_IMAGE".localized()
        case .video: editViewMessage.text = "MESSAGE_VIDEO".localized()
        case .audio: editViewMessage.text = "MESSAGE_AUDIO".localized()
        case .file: editViewMessage.text = "MESSAGE_FILE".localized()
        case .custom: break
        case .groupMember: break
        @unknown default: break }
    }
    
    func didSharePressed() {
        if let message = selectedMessage {
            var textToShare = ""
            if message.messageType == .text {
                if message.receiverType == .user{
                    textToShare = (message as? TextMessage)?.text ?? ""
                }else{
                    if let name = (message as? TextMessage)?.sender?.name , let text = (message as? TextMessage)?.text {
                        textToShare = name + " : " + text
                    }
                }
            }else if message.messageType == .audio ||  message.messageType == .file ||  message.messageType == .image || message.messageType == .video {
                
                if message.receiverType == .user{
                    textToShare = (message as? MediaMessage)?.attachment?.fileUrl ?? ""
                }else{
                    if let name = (message as? MediaMessage)?.sender?.name, let url =  (message as? MediaMessage)?.attachment?.fileUrl {
                        textToShare = name + " : " +  url
                    }
                }
            }
            let sendItems = [ textToShare]
            let activityViewController = UIActivityViewController(activityItems: sendItems, applicationActivities: nil)
            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
            activityViewController.excludedActivityTypes = [.airDrop]
            self.present(activityViewController, animated: true, completion: nil)
            self.didPreformCancel()
        }
    }
    
    /**
     This method triggeres when user pressed forward message button.
     - Parameter notification: A container for information broadcast through a notification center to all registered observers.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatThreadedMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    func didForwardPressed() {
        if let message = selectedMessage {
            let forwardMessageList = CometChatForwardMessageList()
            forwardMessageList.set(message: message)
            navigationController?.pushViewController(forwardMessageList, animated: true)
            self.didPreformCancel()
        }
    }
    
    
}


extension CometChatThreadedMessageList : LocationCellDelegate, CLLocationManagerDelegate {
    
    func locationAuthStatus() {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            curentLocation = locationManager.location
        } else {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let location = locations.last else {
            return
        }
        self.curentLocation = location
        
    }
    
    func didPressedOnLocation(latitude: Double, longitude: Double, title: String) {
        
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "OPEN_IN_APPLE_MAPS".localized(), style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.openMapsForPlace(latitude: latitude, longitude: longitude, title: title)
        }))
        
        actionSheet.addAction(UIAlertAction(title: "OPEN_IN_GOOGLE_MAPS".localized(), style: .default, handler: { (alert:UIAlertAction!) -> Void in
            
            self.openGoogleMapsForPlace(latitude: String(latitude), longitude: String(longitude))
        }))
        
        actionSheet.addAction(UIAlertAction(title: "CANCEL".localized(), style: .cancel, handler: nil))
        actionSheet.view.tintColor = UIKitSettings.primaryColor
        self.present(actionSheet, animated: true, completion: nil)
    }
    
    
    
    func openMapsForPlace(latitude: CLLocationDegrees, longitude: CLLocationDegrees, title: String) {

        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(latitude, longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = title
        mapItem.openInMaps(launchOptions: options)
    }
    
    func openGoogleMapsForPlace(latitude: String, longitude: String) {
        
        if (UIApplication.shared.canOpenURL(URL(string:"comgooglemaps://")!)) {
          UIApplication.shared.openURL(URL(string:
            "comgooglemaps://?center=\(latitude),\(longitude)&zoom=14&views=traffic")!)
        } else {
        }
    }
}


extension CometChatThreadedMessageList: PollExtensionDelegate {
    
    
    func voteForPoll(pollID: String, with option: String, cell: UITableViewCell) {
     
        
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: "VOTING".localized(), preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
        }
        
        CometChat.callExtension(slug:  "polls", type: .post, endPoint: "v2/vote", body: ["vote":option,"id":pollID], onSuccess: { (response) in
            
            DispatchQueue.main.async {
                self.tableView?.beginUpdates()
                if let cell = cell as? CometChatReceiverPollMessageBubble {
                    cell.option1Tick.isHidden = true
                    cell.option2Tick.isHidden = true
                    cell.option3Tick.isHidden = true
                    cell.option4Tick.isHidden = true
                    cell.option5Tick.isHidden = true
                    switch option {
                    case "1": cell.option1Tick.isHidden = false
                    case "2": cell.option2Tick.isHidden = false
                    case "3": cell.option3Tick.isHidden = false
                    case "4": cell.option4Tick.isHidden = false
                    case "5": cell.option5Tick.isHidden = false
                    default:break
                    }
                }
                self.tableView?.endUpdates()
                self.dismiss(animated: true, completion: nil)
            }
        }) { (error) in
                DispatchQueue.main.async {
                    if let error = error {
                        CometChatSnackBoard.showErrorMessage(for: error)
                    }
                }
        }
        
    }
}


extension CometChatThreadedMessageList: GrowingTextViewDelegate {
    public func growingTextView(_ growingTextView: GrowingTextView, willChangeHeight height: CGFloat, difference: CGFloat) {
       
        inputBarHeight.constant = height
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
    
    public func growingTextView(_ growingTextView: GrowingTextView, didChangeHeight height: CGFloat, difference: CGFloat) {
      
    }
    
    
    public func growingTextViewDidChange(_ growingTextView: GrowingTextView) {
        guard let indicator = typingIndicator else {
            return
        }
        if growingTextView.text?.count == 0 {
            CometChat.startTyping(indicator: indicator)
            reactionButtonSpace.constant = 0
            reactionButtonWidth.constant = 0
            microhone.isHidden = false
            send.isHidden = true
            self.view.layoutIfNeeded()
            
        }else{
            microhone.isHidden = true
            send.isHidden = false
            reactionButtonSpace.constant = 0
            reactionButtonWidth.constant = 0
            self.view.layoutIfNeeded()
        }
        CometChat.startTyping(indicator: indicator)
    }
    
    public func growingTextViewDidBeginEditing(_ growingTextView: GrowingTextView) {
    }
    
    
    public func growingTextViewDidEndEditing(_ growingTextView: GrowingTextView) {
        guard let indicator = typingIndicator else {
            return
        }
        CometChat.endTyping(indicator: indicator)
        microhone.isHidden = false
        send.isHidden = true
        reactionButtonSpace.constant = 0
        reactionButtonWidth.constant = 0
    }
}

extension CometChatThreadedMessageList : HyperLinkDelegate, MFMailComposeViewControllerDelegate {
    
    func didTapOnURL(url: String) {
        guard let url = URL(string: url) else { return }
        let sfvc = SFSafariViewController(url: url)
        self.present(sfvc, animated: true, completion: nil)
    }
    
    func didTapOnPhoneNumber(number: String) {
        if let number = number.components(separatedBy: CharacterSet.decimalDigits.inverted)
            .joined() as? String {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let url = URL(string: "tel://\(number)")!
                UIApplication.shared.open(url, options: [:])
            }
        }
    }
    
    func didTapOnEmail(email: String) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([email])
            self.present(mail, animated: true, completion: nil)
        } else {
            showAlert(title: "WARNING".localized(), msg: "MAIL_APP_NOT_FOUND_MESSAGE".localized())
        }
    }
    
    public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
}

extension CometChatThreadedMessageList: StickerViewDelegate {
    
    func didClosePressed() {
        DispatchQueue.main.async {
            self.tableViewBottomConstraint.constant = 0
        }
    }
    
    
    func didStickerSelected(sticker: CometChatSticker) {
     
        if let url = sticker.url {
            DispatchQueue.main.async {
                self.sendStickerInthread(withURL: url)
            }
        }
    }
    
    func didStickerSetSelected(stickerSet: CometChatStickerSet) {
      
    }

    
}

extension CometChatThreadedMessageList: CometChatMessageReactionsDelegate {
    
    func didReactionPressed(reaction: CometChatMessageReaction) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: nil, message: "ADDING_REACTION".localized(), preferredStyle: .alert)
            let loadingIndicator = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
            loadingIndicator.hidesWhenStopped = true
            loadingIndicator.style = UIActivityIndicatorView.Style.gray
            loadingIndicator.startAnimating()
            alert.view.addSubview(loadingIndicator)
            self.present(alert, animated: true, completion: nil)
        }
        if reaction.messageId == 0 {
            if let message = selectedMessage {
                CometChat.callExtension(slug: "reactions", type: .post, endPoint: "v1/react", body: ["msgId":message.id, "emoji":reaction.title], onSuccess: { (success) in
                    DispatchQueue.main.async {
                        self.dismiss(animated: true, completion: nil)
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
                }
            }
        }else{
            CometChat.callExtension(slug: "reactions", type: .post, endPoint: "v1/react", body: ["msgId":reaction.messageId, "emoji": reaction.title], onSuccess: { (success) in
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }) { (error) in
                if let error = error {
                    CometChatSnackBoard.showErrorMessage(for: error)
                }
            }
        }
    }
    
    func didNewReactionPressed() {
        
    }
    
    func didlongPressOnCometChatMessageReactions(reactions: [CometChatMessageReaction]) {
        let cometChatMessageReactors = CometChatMessageReactors()
        let navigationController = UINavigationController(rootViewController: cometChatMessageReactors)
        navigationController.title = "REACTIONS".localized()
        cometChatMessageReactors.reactors = reactions
        self.present(navigationController, animated: true, completion: nil)
    }

}

extension CometChatThreadedMessageList: CollaborativeDelegate {
    
    func didJoinPressed(forMessage: CustomMessage) {
        

        if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let collaborativeDictionary = cometChatExtension["whiteboard"] as? [String : Any], let collaborativeURL =  collaborativeDictionary["board_url"] as? String {
            
            let collaborativeView = CometChatWebView()
            collaborativeView.webViewType = .whiteboard
            collaborativeView.url = collaborativeURL
            self.navigationController?.pushViewController(collaborativeView, animated: true)
            
        }else if let metaData = forMessage.metaData , let injected = metaData["@injected"] as? [String : Any], let cometChatExtension =  injected["extensions"] as? [String : Any], let collaborativeDictionary = cometChatExtension["document"] as? [String : Any], let collaborativeURL =  collaborativeDictionary["document_url"] as? String {
            
            let collaborativeView = CometChatWebView()
            collaborativeView.webViewType = .writeboard
            collaborativeView.url = collaborativeURL
            self.navigationController?.pushViewController(collaborativeView, animated: true)
        
        }
    }
}
