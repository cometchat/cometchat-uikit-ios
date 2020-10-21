
//  CometChatUserDetail.swift
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

class CometChatUserDetail: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var settingItems:[Int] = [Int]()
    var actionsItems:[Int] = [Int]()
    var supportItems:[Int] = [Int]()
    var isPresentedFromMessageList: Bool?
    var currentUser: User?
    var currentGroup: Group?
    lazy var previewItem = NSURL()
    var quickLook = QLPreviewController()
    
    static let USER_INFO_CELL = 0
    static let SEND_MESSAGE_CELL = 1
    static let ADD_TO_CONTACTS_CELL = 2
    static let BLOCK_USER_CELL = 3
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
       
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
            DispatchQueue.main.async {
                if self.tableView != nil {
                    self.tableView.reloadData()
                }
            }
        }) { (error) in
        }
    }
    
    /**
     This method specifies the navigation bar title for CometChatUserDetail.
     - Parameters:
     - title: This takes the String to set title for CometChatUserDetail.
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
     This method sets the list of items needs to be display in CometChatUserDetail.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func setupItems(){
        settingItems = [CometChatUserDetail.USER_INFO_CELL]
        if currentGroup != nil {
            actionsItems = [CometChatUserDetail.SEND_MESSAGE_CELL, CometChatUserDetail.ADD_TO_CONTACTS_CELL]
        }else{
            actionsItems = [CometChatUserDetail.SEND_MESSAGE_CELL]
        }
        if UIKitSettings.blockUser == .enabled {
         supportItems = [ CometChatUserDetail.BLOCK_USER_CELL]
        }else{
            supportItems = []
        }
        
    }
    
    /**
     This method setup the tableview to load CometChatUserDetail.
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
     This method register the cells for CometChatUserDetail.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func registerCells(){
        let CometChatDetailView  = UINib.init(nibName: "CometChatDetailView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatDetailView, forCellReuseIdentifier: "detailView")
        
        let NotificationsView  = UINib.init(nibName: "NotificationsView", bundle: UIKitSettings.bundle)
        self.tableView.register(NotificationsView, forCellReuseIdentifier: "notificationsView")
        
        let SupportView  = UINib.init(nibName: "SupportView", bundle: UIKitSettings.bundle)
        self.tableView.register(SupportView, forCellReuseIdentifier: "supportView")
        
        let SharedMediaView  = UINib.init(nibName: "SharedMediaView", bundle: UIKitSettings.bundle)
        self.tableView.register(SharedMediaView, forCellReuseIdentifier: "sharedMediaView")
    }
    
    
    /**
     This method setup navigationBar for CometChatUserDetail viewController.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func setupNavigationBar(){
        
        if navigationController != nil{
            // NavigationBar Appearance
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont.systemFont(ofSize: 20, weight: .regular) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont.systemFont(ofSize: 35, weight: .bold) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                setLargeTitleDisplayMode(.never)
                self.navigationController?.navigationBar.isTranslucent = true
            }
            let closeButton = UIBarButtonItem(title: NSLocalizedString("CLOSE", bundle: UIKitSettings.bundle, comment: ""), style: .plain, target: self, action: #selector(closeButtonPressed))
            closeButton.tintColor = UIKitSettings.primaryColor
            self.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    @objc func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }  
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods

extension CometChatUserDetail: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of items.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    /// This method specifies height for section in CometChatUserDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0  {
            return 0
        }else{
            if UIKitSettings.blockUser == .disabled && section == 2 {
                return 0
            }else if UIKitSettings.viewShareMedia == .disabled && section == 3 {
                return 0
            }else{
                return 25
            }
        }
    }
    
    /// This method specifies the view for header  in CometChatUserDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 25))
        let sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 20))
        
        if section == 0 {
            sectionTitle.text =  ""
        }else if section == 1{
            sectionTitle.text =  NSLocalizedString("ACTIONS", bundle: UIKitSettings.bundle, comment: "")
        }else if section == 2{
            sectionTitle.text =  NSLocalizedString("PRIVACY_&_SUPPORT", bundle: UIKitSettings.bundle, comment: "")
        }else if section == 3{
            sectionTitle.text =  NSLocalizedString("SHARED_MEDIA", bundle: UIKitSettings.bundle, comment: "")
        }
        sectionTitle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        if #available(iOS 13.0, *) {
            sectionTitle.textColor = .lightGray
            returnedView.backgroundColor = .systemBackground
        } else {}
        returnedView.addSubview(sectionTitle)
        return returnedView
    }
    
    /// This method specifiesnumber of rows in CometChatUserDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return settingItems.count
        case 1: return actionsItems.count
        case 2: return supportItems.count
        case 3: return 1
        default: return 0
        }
    }
    
    /// This method specifies the view for user  in CometChatUserDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }else if indexPath.section == 3{
            if UIKitSettings.viewShareMedia == .enabled {
               return 320
            }else{
            return 0
            }
        }else {
            return 60
        }
    }
    
    /// This method specifies the view for user  in CometChatUserDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell()
        switch indexPath.section {
        case 0:
            switch settingItems[safe:indexPath.row] {
            case CometChatUserDetail.USER_INFO_CELL:
                let userDetail = tableView.dequeueReusableCell(withIdentifier: "detailView", for: indexPath) as! CometChatDetailView
                userDetail.user = currentUser
                userDetail.detailViewDelegate = self
                userDetail.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return userDetail
            default:break
            }
        case 1:
            
            switch actionsItems[safe:indexPath.row] {
            case CometChatUserDetail.SEND_MESSAGE_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = NSLocalizedString("SEND_MESSAGE", bundle: UIKitSettings.bundle, comment: "")
                supportCell.textLabel?.textColor = UIKitSettings.primaryColor
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
            case CometChatUserDetail.ADD_TO_CONTACTS_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                
                if let groupName = currentGroup?.name {
                    supportCell.textLabel?.text = NSLocalizedString("ADD_IN", bundle: UIKitSettings.bundle, comment: "") + " \(groupName)"
                }else{
                    supportCell.textLabel?.text = NSLocalizedString("ADD_CONTACT", bundle: UIKitSettings.bundle, comment: "")
                }
                supportCell.textLabel?.textColor = UIKitSettings.primaryColor
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            default: break
            }
            
        case 2:
            switch supportItems[safe:indexPath.row] {
            case CometChatUserDetail.BLOCK_USER_CELL:
                
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                
                if currentUser?.blockedByMe == true {
                    supportCell.textLabel?.text = NSLocalizedString("UNBLOCK_USER", bundle: UIKitSettings.bundle, comment: "")
                    supportCell.textLabel?.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                }else {
                    supportCell.textLabel?.text = NSLocalizedString("BLOCK_USER", bundle: UIKitSettings.bundle, comment: "")
                    supportCell.textLabel?.textColor = .red
                }
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            default:break
            }
        case 3:
            if let user = currentUser {
                let sharedMediaCell = tableView.dequeueReusableCell(withIdentifier: "sharedMediaView", for: indexPath) as! SharedMediaView
                sharedMediaCell.refreshMediaMessages(for: user, type: .user)
                sharedMediaCell.sharedMediaDelegate = self
                sharedMediaCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return sharedMediaCell
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
        case 0:
            switch settingItems[safe:indexPath.row] {
            case CometChatUserDetail.USER_INFO_CELL: break
            default:break}
            
        case 1:
            switch actionsItems[safe:indexPath.row] {
            case CometChatUserDetail.SEND_MESSAGE_CELL:
                
                if isPresentedFromMessageList == true {
                    self.dismiss(animated: true, completion: nil)
                }else{
                    guard let user = currentUser else { return }
                    let messageList = CometChatMessageList()
                    messageList.set(conversationWith: user, type: .user)
                    navigationController?.pushViewController(messageList, animated: true)
                }
                
            case CometChatUserDetail.ADD_TO_CONTACTS_CELL:
                
                CometChat.addMembersToGroup(guid: currentGroup?.guid ?? "", groupMembers: [GroupMember(UID: currentUser?.uid ?? "", groupMemberScope: .participant)], onSuccess: { (sucess) in
                    DispatchQueue.main.async {
                        
                        let data:[String: String] = ["guid": self.currentGroup?.guid ?? ""]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: data)
                        let message = (self.currentUser?.name ?? "") + NSLocalizedString("ADDED_SUCCESSFULLY", bundle: UIKitSettings.bundle, comment: "")
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: message, duration: .short)
                        snackbar.show()
                        self.dismiss(animated: true) {}
                        
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        if let errorMessage = error?.errorDescription {
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                            snackbar.show()
                        }
                    }
                }
            default: break}
        case 2:
            switch supportItems[safe:indexPath.row] {
            case CometChatUserDetail.BLOCK_USER_CELL:
                
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
                
            default:break}
        default: break}
    }
    
}



/*  ----------------------------------------------------------------------------------------- */

// MARK: - QuickLook Preview Delegate

extension CometChatUserDetail :QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    
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
            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: "Downloading...", duration: .forever)
            snackbar.animationType = .slideFromBottomToTop
            snackbar.show()
            URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    snackbar.dismiss()
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch let error as NSError {
                    snackbar.dismiss()
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


extension CometChatUserDetail: SharedMediaDelegate {
    
    
    func didPhotoSelected(photo: MediaMessage) {
        self.previewMediaMessage(url: photo.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
            if success {
                if let url = fileURL {
                    self.previewItem = url as NSURL
                    self.presentQuickLook()
                }
            }
        })
    }
    
    func didVideoSelected(video: MediaMessage) {
        self.previewMediaMessage(url: video.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
            if success {
                var player = AVPlayer()
                if let videoURL = fileURL,
                    let url = URL(string: videoURL.absoluteString) {
                    player = AVPlayer(url: url)
                }
                DispatchQueue.main.async{
                    let playerViewController = AVPlayerViewController()
                    playerViewController.player = player
                    self.present(playerViewController, animated: true) {
                        playerViewController.player!.play()
                    }
                }
            }
        })
    }
    
    func didDocumentSelected(document: MediaMessage) {
        self.previewMediaMessage(url: document.attachment?.fileUrl ?? "", completion: {(success, fileURL) in
            if success {
                if let url = fileURL {
                    self.previewItem = url as NSURL
                    self.presentQuickLook()
                }
            }
        })
    }
}

/*  ----------------------------------------------------------------------------------------- */

extension CometChatUserDetail: DetailViewDelegate {
    
    func didCallButtonPressed(for: AppEntity) {
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let audioCall: UIAlertAction = UIAlertAction(title: NSLocalizedString("AUDIO_CALL", bundle: UIKitSettings.bundle, comment: ""), style: .default) { action -> Void in
            if let user = self.currentUser {
                CometChatCallManager().makeCall(call: .audio, to: user)
            }
        }
        
        let videoCall: UIAlertAction = UIAlertAction(title: NSLocalizedString("VIDEO_CALL", bundle: UIKitSettings.bundle, comment: ""), style: .default) { action -> Void in
            if let user = self.currentUser {
                CometChatCallManager().makeCall(call: .video, to: user)
            }
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", bundle: UIKitSettings.bundle, comment: ""), style: .cancel) { action -> Void in
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        if UIKitSettings.userAudioCall == .enabled {
              actionSheetController.addAction(audioCall)
        }
        
        if  UIKitSettings.userVideoCall == .enabled {
             actionSheetController.addAction(videoCall)
        }
       
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
