
//  CometChatCallDetail.swift
//  CometChatUIKit
//  Created by CometChat Inc. on 20/09/19.
//  Copyright ©  2020 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
import QuickLook
import AVKit
import AVFoundation
import CometChatPro

/*  ----------------------------------------------------------------------------------------- */

class CometChatCallDetail: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var settingItems:[Int] = [Int]()
    var actionsItems:[Int] = [Int]()
    var supportItems:[Int] = [Int]()
    var isPresentedFromMessageList: Bool?
    var currentUser: User?
    var currentGroup: Group?
    var callsRequest: MessagesRequest?
    var calls = [Call]()
    static let CALL_INFO_CELL = 0
    static let SEND_MESSAGE_CELL = 1
    static let CALL_LOG_CELL = 2
    static let BLOCK_USER_CELL = 3
    static let LEAVE_GROUP_CELL = 4
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
       // UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupNavigationBar()
        self.setupItems()
    }
    
    // MARK: - Public Instance methods
    /**
     This method specifies the **User** Object to present details for it.
     - Parameter group: This specifies `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func set(user: User){
        currentUser = user
        CometChat.getUser(UID: user.uid ?? "", onSuccess: { (updatedUser) in
            self.currentUser = updatedUser
            DispatchQueue.main.async { [weak self] in
                if self?.tableView != nil {
                    self?.tableView.reloadData()
                }
            }
        }) { (error) in
          
        }
        self.fetchCalls(forEntity: user)
    }
    
    /**
       This method specifies the **Group** Object to present details for it.
       - Parameter group: This specifies `Group` Object.
       - Author: CometChat Team
       - Copyright:  ©  2020 CometChat Inc.
       */
    public func set(group: Group){
        guard  group != nil else {
            return
        }
        currentGroup = group
        CometChat.getGroup(GUID: group.guid , onSuccess: { (updatedGroup) in
            self.currentGroup = updatedGroup
            DispatchQueue.main.async { [weak self] in
                if self?.tableView != nil {
                    self?.tableView.reloadData()
                }
            }
        }) { (error) in
        
        }
        fetchCalls(forEntity: group)
    }
    
    /**
     This method fetch call messages for entity.
     - Parameter group: This specifies `AppEntity` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func fetchCalls(forEntity: AppEntity) {
        if let user = forEntity as? User {
            callsRequest = MessagesRequest.MessageRequestBuilder().set(limit: 10).hideMessagesFromBlockedUsers(true).set(uid: user.uid ?? "").set(categories: ["call"]).build()
        }
        if let group = forEntity as? Group {
            callsRequest = MessagesRequest.MessageRequestBuilder().set(limit: 10).hideMessagesFromBlockedUsers(true).set(guid: group.guid ).set(categories: ["call"]).build()
        }
        callsRequest?.fetchPrevious(onSuccess: { (fetchedCalls) in
            if fetchedCalls?.count == 0 {
                DispatchQueue.main.async { [weak self] in
                    let indexPath = IndexPath(row: 0, section: 1)
                    if let progressIndicator = self?.tableView.cellForRow(at: indexPath) as? ProgressIndicatorView {
                        progressIndicator.activityIndicator.isHidden = true
                        progressIndicator.LoadingLabel.isHidden = false
                        progressIndicator.LoadingLabel.text = "No History Found."
                    }
                }
            }else{
                guard let filteredCalls = fetchedCalls?.filter({
                    ($0 as? Call != nil && ($0 as? Call)?.callStatus == .initiated)  ||
                        ($0 as? Call != nil && ($0 as? Call)?.callStatus == .unanswered)
                }) else { return }
                self.calls = (filteredCalls as? [Call])?.reversed() ?? []
                DispatchQueue.main.async { [weak self] in
                    self?.tableView.reloadData()
                }
            }
        }, onError: { (error) in
            DispatchQueue.main.async {
                let indexPath = IndexPath(row: 0, section: 1)
                if let progressIndicator = self.tableView.cellForRow(at: indexPath) as? ProgressIndicatorView {
                    progressIndicator.activityIndicator.isHidden = true
                    progressIndicator.LoadingLabel.isHidden = false
                    progressIndicator.LoadingLabel.text = "Unable to fetch History."
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
                if let errorMessage = error?.errorDescription {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
            }
           
        })
    }
    
    /**
     This method specifies the navigation bar title for CometChatCallDetail.
     - Parameters:
     - title: This takes the String to set title for CometChatCallDetail.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
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
    
    
    
    // MARK: - Private Instance methods
    
    /**
     This method sets the list of items needs to be display in CometChatCallDetail.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func setupItems(){
        settingItems = [CometChatCallDetail.CALL_INFO_CELL]
        if currentUser != nil {
            actionsItems = [CometChatCallDetail.SEND_MESSAGE_CELL]
            supportItems = [ CometChatCallDetail.BLOCK_USER_CELL]
        }else if currentGroup != nil {
            actionsItems = [CometChatCallDetail.SEND_MESSAGE_CELL]
            supportItems = [CometChatCallDetail.LEAVE_GROUP_CELL]
        }
    }
    
    /**
     This method setup the tableview to load CometChatCallDetail.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func setupTableView() {
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemBackground
        } else {}
        tableView = UITableView()
        self.view.addSubview(self.tableView)
        self.tableView.translatesAutoresizingMaskIntoConstraints = false
        self.tableView.topAnchor.constraint(equalTo: self.safeArea.topAnchor).isActive = true
        self.tableView.leftAnchor.constraint(equalTo: self.view.leftAnchor).isActive = true
        self.tableView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        self.tableView.rightAnchor.constraint(equalTo: self.view.rightAnchor).isActive = true
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView(frame: .zero)
        self.registerCells()
    }
    
    /**
     This method register the cells for CometChatCallDetail.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func registerCells(){
        
        let CometChatDetailView  = UINib.init(nibName: "CometChatDetailView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatDetailView, forCellReuseIdentifier: "detailView")
        
        let CometChatCallDetailLogView  = UINib.init(nibName: "CometChatCallDetailLogView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatCallDetailLogView, forCellReuseIdentifier: "detailLogView")
        
        let NotificationsView  = UINib.init(nibName: "NotificationsView", bundle: UIKitSettings.bundle)
        self.tableView.register(NotificationsView, forCellReuseIdentifier: "notificationsView")
        
        let SupportView  = UINib.init(nibName: "SupportView", bundle: UIKitSettings.bundle)
        self.tableView.register(SupportView, forCellReuseIdentifier: "supportView")
        
        let ProgressIndicatorView  = UINib.init(nibName: "ProgressIndicatorView", bundle: UIKitSettings.bundle)
        self.tableView.register(ProgressIndicatorView, forCellReuseIdentifier: "progressIndicatorView")
        
    }
    
    
    /**
     This method setup navigationBar for CometChatCallDetail viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func setupNavigationBar(){
        if navigationController != nil{
            // NavigationBar Appearance
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font:UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                setLargeTitleDisplayMode(.never)
                self.navigationController?.navigationBar.isTranslucent = true
            }
            self.navigationController?.navigationBar.tintColor = UIKitSettings.primaryColor
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatCallDetail: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of items.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    /// This method specifies height for section in CometChatCallDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0  {
            return 0
        }else{
            return 25
        }
    }
    
    /// This method specifies the view for header  in CometChatCallDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        let sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 20))
        if section == 0 {
            sectionTitle.text =  ""
        }else if section == 1{
            sectionTitle.text =  NSLocalizedString("HISTORY", bundle: UIKitSettings.bundle, comment: "")
        }else if section == 2{
            sectionTitle.text =  NSLocalizedString("ACTIONS", bundle: UIKitSettings.bundle, comment: "")
        }else if section == 3{
            sectionTitle.text =  NSLocalizedString("PRIVACY_&_SUPPORT", bundle: UIKitSettings.bundle, comment: "")
        }
        sectionTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        if #available(iOS 13.0, *) {
            sectionTitle.textColor = .lightGray
            returnedView.backgroundColor = .systemBackground
        } else {}
        returnedView.addSubview(sectionTitle)
        return returnedView
    }
    
    /// This method specifiesnumber of rows in CometChatCallDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return settingItems.count
        case 1: if calls.isEmpty { return 1 } else { return calls.count }
        case 2: return actionsItems.count
        case 3: return supportItems.count
        default: return 0
        }
    }
    
    /// This method specifies the view for user  in CometChatCallDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 && indexPath.row == 0 { return 100
        }else if indexPath.section == 1 {
            if calls.isEmpty { return 80 } else { return 40 }
        }else { return 60 }
    }
    
    /// This method specifies the view for user  in CometChatCallDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell()
        switch indexPath.section {
        case 0:
            switch settingItems[safe:indexPath.row] {
            case CometChatCallDetail.CALL_INFO_CELL:
                if currentUser != nil {
                    let userDetail = tableView.dequeueReusableCell(withIdentifier: "detailView", for: indexPath) as! CometChatDetailView
                    userDetail.detailViewDelegate = self
                    userDetail.user = currentUser
                    userDetail.call.isHidden = false
                    userDetail.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                    return userDetail
                }else if currentGroup != nil {
                    let groupDetail = tableView.dequeueReusableCell(withIdentifier: "detailView", for: indexPath) as! CometChatDetailView
                    groupDetail.group = currentGroup
                    groupDetail.detailViewDelegate = self
                    groupDetail.call.isHidden = false
                    groupDetail.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                    groupDetail.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                    return groupDetail
                }
            default:break
            }
        case 1:
            if calls.isEmpty {
                let progressIndicatorView = tableView.dequeueReusableCell(withIdentifier: "progressIndicatorView", for: indexPath) as! ProgressIndicatorView
                
                return progressIndicatorView
            }else{
                let call = calls[safe: indexPath.row]
                let detailLogCell = tableView.dequeueReusableCell(withIdentifier: "detailLogView", for: indexPath) as! CometChatCallDetailLogView
                detailLogCell.call = call
                return detailLogCell
            }
        case 2:
            switch actionsItems[safe:indexPath.row] {
            case CometChatCallDetail.SEND_MESSAGE_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = NSLocalizedString("SEND_MESSAGE", bundle: UIKitSettings.bundle, comment: "")
                supportCell.textLabel?.textColor = UIKitSettings.primaryColor
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
            default: break
            }
            
        case 3:
            switch supportItems[safe:indexPath.row] {
            case CometChatCallDetail.BLOCK_USER_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                if currentUser?.blockedByMe == true {
                    supportCell.textLabel?.text = NSLocalizedString("UNBLOCK_USER", bundle: UIKitSettings.bundle, comment: "")
                    supportCell.textLabel?.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                }else if currentUser?.blockedByMe == false {
                    supportCell.textLabel?.text = NSLocalizedString("BLOCK_USER", bundle: UIKitSettings.bundle, comment: "")
                    supportCell.textLabel?.textColor = .red
                }
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            case CometChatCallDetail.LEAVE_GROUP_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = NSLocalizedString("LEAVE_GROUP", bundle: UIKitSettings.bundle, comment: "")
                supportCell.textLabel?.textColor = .red
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
            default:break
            }
        default: break
        }
        return cell
    }
    
    /// This method triggers when particular cell is clicked by the user .
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0: break
        case 1: break
        case 2:
            switch actionsItems[safe:indexPath.row] {
            case CometChatCallDetail.SEND_MESSAGE_CELL:
                if isPresentedFromMessageList == true {
                    self.dismiss(animated: true, completion: nil)
                }else{
                    if currentUser != nil {
                        guard let user = currentUser else { return }
                        let messageList = CometChatMessageList()
                        messageList.set(conversationWith: user, type: .user)
                        messageList.hidesBottomBarWhenPushed = true
                        navigationController?.pushViewController(messageList, animated: true)
                    }else if currentGroup != nil {
                        guard let group = currentGroup else { return }
                        let messageList = CometChatMessageList()
                        messageList.hidesBottomBarWhenPushed = true
                        messageList.set(conversationWith: group, type: .group)
                        navigationController?.pushViewController(messageList, animated: true)
                    }
                }
            case .none: break
            case .some(_):  break
            }
        case 3:
            switch supportItems[safe:indexPath.row] {
            case CometChatCallDetail.BLOCK_USER_CELL:
                switch  currentUser!.blockedByMe  {
                case true:
                    CometChat.unblockUsers([(currentUser?.uid ?? "")],onSuccess: { (success) in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didUserUnblocked"), object: nil, userInfo: nil)
                        if let user = self.currentUser, let name = user.name {
                            self.set(user: user)
                            DispatchQueue.main.async {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: name + NSLocalizedString("UNBLOCKED_SUCCESSFULLY", bundle: UIKitSettings.bundle, comment: ""), duration: .short)
                                snackbar.show()
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                                snackbar.show()
                            }
                        }
                    }
                case false:
                    CometChat.blockUsers([(currentUser?.uid ?? "")], onSuccess: { (success) in
                        DispatchQueue.main.async {
                            if let user = self.currentUser, let name = user.name {
                                self.set(user: user)
                                let data:[String: String] = ["name": name]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil, userInfo: data)
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: name +  NSLocalizedString("BLOCKED_SUCCESSFULLY", bundle: UIKitSettings.bundle, comment: ""), duration: .short)
                                snackbar.show()
                            }
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
                
            case CometChatCallDetail.LEAVE_GROUP_CELL:
                if let guid = currentGroup?.guid {
                    CometChat.leaveGroup(GUID: guid, onSuccess: { (success) in
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil, userInfo: nil)
                                let message =  NSLocalizedString("YOU_LEFT_FROM", bundle: UIKitSettings.bundle, comment: "") +  (self.currentGroup?.name ?? "") + "."
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: message, duration: .short)
                                snackbar.show()
                            }
                            
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
            default:break}
        default: break}
    }
    
    
    
    /// This method triggers when user holds on detailCell in CometChatCallDetail
    /// - Parameters:
    ///   - tableView: A view that presents data using rows arranged in a single column.
    ///   - indexPath: A list of indexes that together represent the path to a specific location in a tree of nested arrays.
    ///   - point: A structure that contains a point in a two-dimensional coordinate system.
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            if  let selectedCell = (tableView.cellForRow(at: indexPath) as? CometChatDetailView){
                let audioCall = UIAction(title: NSLocalizedString("AUDIO_CALL", bundle: UIKitSettings.bundle, comment: ""), image: UIImage(named: "audioCall", in: UIKitSettings.bundle, compatibleWith: nil)) { action in
                    if let user = selectedCell.user {
                        CometChatCallManager().makeCall(call: .audio, to: user)
                    }
                    if let group = selectedCell.group {
                        CometChatCallManager().makeCall(call: .audio, to: group)
                    }
                }
                
                let videoCall = UIAction(title: NSLocalizedString("VIDEO_CALL", bundle: UIKitSettings.bundle, comment: ""), image: UIImage(named: "videoCall", in: UIKitSettings.bundle, compatibleWith: nil)) { action in
                    if let user = selectedCell.user {
                        CometChatCallManager().makeCall(call: .video, to: user)
                    }
                    if let group = selectedCell.group {
                        CometChatCallManager().makeCall(call: .video, to: group)
                    }
                }
                return UIMenu(title: "", children: [audioCall,videoCall])
            }
            return UIMenu(title: "")
        })
    }
}


/*  ----------------------------------------------------------------------------------------- */

// MARK: - DetailViewDelegate methods

extension CometChatCallDetail : DetailViewDelegate {
    
    
    /// This method triggers when user pressed on Call Button in CometChatDetailView
    /// - Parameter for: This specifies `AppEntity` Object
    func didCallButtonPressed(for: AppEntity) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let audioCall: UIAlertAction = UIAlertAction(title: NSLocalizedString("AUDIO_CALL", bundle: UIKitSettings.bundle, comment: ""), style: .default) { action -> Void in
            if let user = self.currentUser {
                CometChatCallManager().makeCall(call: .audio, to: user)
            }
            if let group = self.currentGroup {
                CometChatCallManager().makeCall(call: .audio, to: group)
            }
        }
        
        let videoCall: UIAlertAction = UIAlertAction(title: NSLocalizedString("VIDEO_CALL", bundle: UIKitSettings.bundle, comment: ""), style: .default) { action -> Void in
            if let user = self.currentUser {
                CometChatCallManager().makeCall(call: .video, to: user)
            }
            
            if let group = self.currentGroup {
                CometChatCallManager().makeCall(call: .video, to: group)
            }
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", bundle: UIKitSettings.bundle, comment: ""), style: .cancel) { action -> Void in
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        actionSheetController.addAction(audioCall)
        actionSheetController.addAction(videoCall)
        actionSheetController.addAction(cancelAction)
         actionSheetController.view.tintColor = UIKitSettings.primaryColor
        // Added ActionSheet support for iPad
        if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.pad ){
            if let currentPopoverpresentioncontroller =
                actionSheetController.popoverPresentationController{
                currentPopoverpresentioncontroller.sourceView = self.view
                self.present(actionSheetController, animated: true, completion: nil)
            }
        }else{
            self.present(actionSheetController, animated: true, completion: nil)
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */
