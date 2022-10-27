
//  CometChatUserDetails.swift
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

class CometChatUserDetails: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var settingItems:[Int] = [Int]()
    var actionsItems:[Int] = [Int]()
    var supportItems:[Int] = [Int]()
    var isPresentedFromMessageList: Bool?
    var currentUser: CometChatPro.User?
    var currentGroup: CometChatPro.Group?
    lazy var previewItem = NSURL()
    var quickLook = QLPreviewController()
    
    static let USER_INFO_CELL = 0
    static let SEND_MESSAGE_CELL = 1
    static let VIEW_PROFILE_CELL = 2
    static let ADD_TO_CONTACTS_CELL = 3
    static let BLOCK_USER_CELL = 4
    
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
    public func set(user: CometChatPro.User){
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
     This method specifies the navigation bar title for CometChatUserDetails.
     - Parameters:
     - title: This takes the String to set title for CometChatUserDetails.
     - mode: This specifies the TitleMode such as :
     * .automatic : Automatically use the large out-of-line title based on the state of the previous item in the navigation bar.
     *  .never: Never use a larger title when this item is topmost.
     * .always: Always use a larger title when this item is topmost.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
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
    
    
    
    
    // MARK: - Private Instance methods
    
    /**
     This method sets the list of items needs to be display in CometChatUserDetails.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func setupItems(){
        settingItems = [CometChatUserDetails.USER_INFO_CELL]
        if currentGroup != nil {
            actionsItems = [CometChatUserDetails.SEND_MESSAGE_CELL, CometChatUserDetails.ADD_TO_CONTACTS_CELL]
        }else{
            actionsItems = [CometChatUserDetails.SEND_MESSAGE_CELL]
            
            FeatureRestriction.isViewProfileEnabled { (success) in
                if success == .enabled && self.currentUser?.link != nil {
                    self.actionsItems.append(CometChatUserDetails.VIEW_PROFILE_CELL)
                }
            }
        }
        
        FeatureRestriction.isBlockUserEnabled { (success) in
            switch success {
            case .enabled: self.supportItems = [ CometChatUserDetails.BLOCK_USER_CELL]
            case .disabled: self.supportItems = []
            }
        }
    }
    
    /**
     This method setup the tableview to load CometChatUserDetails.
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
     This method register the cells for CometChatUserDetails.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func registerCells(){
        let CometChatDetailItem  = UINib.init(nibName: "CometChatDetailItem", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatDetailItem, forCellReuseIdentifier: "detailView")
        
        let CometChatNotificationsItem  = UINib.init(nibName: "CometChatNotificationsItem", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatNotificationsItem, forCellReuseIdentifier: "CometChatNotificationsItem")
        
        let CometChatPrivacyAndSupportItem  = UINib.init(nibName: "CometChatPrivacyAndSupportItem", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatPrivacyAndSupportItem, forCellReuseIdentifier: "CometChatPrivacyAndSupportItem")
        
        let CometChatSharedMedia  = UINib.init(nibName: "CometChatSharedMedia", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatSharedMedia, forCellReuseIdentifier: "CometChatSharedMedia")
    }
    
    
    /**
     This method setup navigationBar for CometChatUserDetails viewController.
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
            let closeButton = UIBarButtonItem(title: "CLOSE".localized(), style: .plain, target: self, action: #selector(closeButtonPressed))
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

extension CometChatUserDetails: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of items.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    /// This method specifies height for section in CometChatUserDetails
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
    
    

    
//    / This method specifies the view for header  in CometChatUserDetails
//    / - Parameters:
//    /   - tableView: The table-view object requesting this information.
//    /   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width - 20, height: 25))
        let sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: returnedView.frame.size.width, height: 20))
        if section == 0 {
            sectionTitle.text =  ""
        }else if section == 1{
            sectionTitle.text =  "ACTIONS".localized()
        }else if section == 2{
            sectionTitle.text =  "PRIVACY_&_SUPPORT".localized()
        }else if section == 3{
            sectionTitle.text =  "SHARED_MEDIA".localized()
        }
        sectionTitle.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        if #available(iOS 13.0, *) {
            sectionTitle.textColor = .lightGray
            returnedView.backgroundColor = .systemBackground
        } else {}
        returnedView.addSubview(sectionTitle)
        return returnedView
    }
    
    /// This method specifiesnumber of rows in CometChatUserDetails
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
    
    /// This method specifies the view for user  in CometChatUserDetails
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }else if indexPath.section == 3 {
            var height: CGFloat = 0
            FeatureRestriction.isSharedMediaEnabled { (success) in
                if success == .enabled {
                    height = 320
                }else {
                    height = 0
                }
            }
            return height
        }else {
            return 60
        }
    }
    
    /// This method specifies the view for user  in CometChatUserDetails
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        switch indexPath.section {
        case 0:
            switch settingItems[safe:indexPath.row] {
            case CometChatUserDetails.USER_INFO_CELL:
                let userDetail = tableView.dequeueReusableCell(withIdentifier: "detailView", for: indexPath) as! CometChatDetailItem
                userDetail.user = currentUser
                userDetail.detailViewDelegate = self
                userDetail.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return userDetail
            default:break
            }
        case 1:
            
            switch actionsItems[safe:indexPath.row] {
            case CometChatUserDetails.SEND_MESSAGE_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "CometChatPrivacyAndSupportItem", for: indexPath) as! CometChatPrivacyAndSupportItem
                supportCell.textLabel?.text = "SEND_MESSAGE".localized()
                supportCell.textLabel?.textColor = UIKitSettings.primaryColor
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            case CometChatUserDetails.VIEW_PROFILE_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "CometChatPrivacyAndSupportItem", for: indexPath) as! CometChatPrivacyAndSupportItem
                supportCell.textLabel?.text = "VIEW_PROFILE".localized()
                supportCell.textLabel?.textColor = UIKitSettings.primaryColor
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            case CometChatUserDetails.ADD_TO_CONTACTS_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "CometChatPrivacyAndSupportItem", for: indexPath) as! CometChatPrivacyAndSupportItem
                
                if let groupName = currentGroup?.name {
                    supportCell.textLabel?.text = "ADD_IN".localized() + " \(groupName)"
                }else{
                    supportCell.textLabel?.text = "ADD_CONTACT".localized()
                }
                supportCell.textLabel?.textColor = UIKitSettings.primaryColor
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            default: break
            }
            
        case 2:
            switch supportItems[safe:indexPath.row] {
            case CometChatUserDetails.BLOCK_USER_CELL:
                
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "CometChatPrivacyAndSupportItem", for: indexPath) as! CometChatPrivacyAndSupportItem
                
                if currentUser?.blockedByMe == true {
                    supportCell.textLabel?.text = "UNBLOCK_USER".localized()
                    supportCell.textLabel?.textColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                }else {
                    supportCell.textLabel?.text = "BLOCK_USER".localized()
                    supportCell.textLabel?.textColor = .red
                }
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            default:break
            }
        case 3:
            if let user = currentUser {
                let CometChatSharedMediaItem = tableView.dequeueReusableCell(withIdentifier: "CometChatSharedMedia", for: indexPath) as! CometChatSharedMedia
                CometChatSharedMediaItem.refreshMediaMessages(for: user, type: .user)
                CometChatSharedMediaItem.sharedMediaDelegate = self
                CometChatSharedMediaItem.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return CometChatSharedMediaItem
            }
        default: break
        }
        return UITableViewCell()
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
            case CometChatUserDetails.USER_INFO_CELL: break
            default:break}
            
        case 1:
            switch actionsItems[safe:indexPath.row] {
            case CometChatUserDetails.SEND_MESSAGE_CELL:
                
                if isPresentedFromMessageList == true {
                    self.dismiss(animated: true, completion: nil)
                }else{
                    guard let user = currentUser else { return }
                    let messageList = CometChatMessageList()
                    messageList.set(conversationWith: user, type: .user)
                    navigationController?.pushViewController(messageList, animated: true)
                }
                
            case CometChatUserDetails.VIEW_PROFILE_CELL:
                
                let profileView = CometChatWebView()
                profileView.webViewType = .profile
                profileView.user = currentUser
                self.navigationController?.pushViewController(profileView, animated: true)
                
            case CometChatUserDetails.ADD_TO_CONTACTS_CELL:
                
                CometChat.addMembersToGroup(guid: currentGroup?.guid ?? "", groupMembers: [CometChatPro.GroupMember(UID: currentUser?.uid ?? "", groupMemberScope: .participant)], onSuccess: { (sucess) in
                    DispatchQueue.main.async {
                        
                        let data:[String: String] = ["guid": self.currentGroup?.guid ?? ""]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: data)
                        let message = (self.currentUser?.name ?? "") + " " + "ADDED_SUCCESSFULLY".localized()
                        self.dismiss(animated: true) {}
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        if let error = error {
                            CometChatSnackBoard.showErrorMessage(for: error)
                        }
                    }
                }
            default: break}
        case 2:
            switch supportItems[safe:indexPath.row] {
            case CometChatUserDetails.BLOCK_USER_CELL:
                
                switch  currentUser!.blockedByMe  {
                case true:
                    CometChat.unblockUsers([(currentUser?.uid ?? "")],onSuccess: { (success) in
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didUserUnblocked"), object: nil, userInfo: nil)
                        if let user = self.currentUser, let name = user.name {
                            self.set(user: user)
                           
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let error = error {
                                CometChatSnackBoard.showErrorMessage(for: error)
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
                
            default:break}
        default: break}
    }
    
}



/*  ----------------------------------------------------------------------------------------- */

// MARK: - QuickLook Preview Delegate

extension CometChatUserDetails :QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    
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
            CometChatSnackBoard.show(message: "Downloading...")
            URLSession.shared.downloadTask(with: itemUrl!, completionHandler: { (location, response, error) -> Void in
                guard let tempLocation = location, error == nil else { return }
                do {
                    CometChatSnackBoard.hide()
                    try FileManager.default.moveItem(at: tempLocation, to: destinationUrl)
                    completion(true, destinationUrl)
                } catch let error as NSError {
                    CometChatSnackBoard.hide()
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


extension CometChatUserDetails: SharedMediaDelegate {
    
    
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

extension CometChatUserDetails: DetailViewDelegate {
    
    func didAudioCallButtonPressed(for: AppEntity) {
        if let user = self.currentUser {
            CometChatCallManager().makeCall(call: .audio, to: user)
        }
    }
    
    func didVideoCallButtonPressed(for: AppEntity) {
        if let user = self.currentUser {
            CometChatCallManager().makeCall(call: .video, to: user)
        }
    }

}
