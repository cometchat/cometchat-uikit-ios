//  CometChatGroupDetail.swift
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

class CometChatGroupDetail: UIViewController {
    
    // MARK: - Declaration of Variables
    
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var settingsItems:[Int] = [Int]()
    var supportItems:[Int] = [Int]()
    var members:[GroupMember] = [GroupMember]()
    var administrators:[GroupMember] = [GroupMember]()
    var moderators:[GroupMember] = [GroupMember]()
    var bannedMembers:[GroupMember] = [GroupMember]()
    var bannedMemberRequest: BannedGroupMembersRequest?
    var memberRequest: GroupMembersRequest?
    var currentGroup: Group?
    lazy var previewItem = NSURL()
    var quickLook = QLPreviewController()
    
    static let GROUP_INFO_CELL = 0
    static let ADMINISTRATOR_CELL = 1
    static let MODERATORS_CELL = 2
    static let ADD_MEMBER_CELL = 3
    static let BANNED_MEMBER_CELL = 4
    static let MEMBERS_CELL = 5
    static let DELETE_AND_EXIT_CELL = 6
    static let EXIT_CELL = 7
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
      
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupNavigationBar()
        self.setupItems()
        self.addObsevers()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.addObsevers()
    }
    
    // MARK: - Public Instance methods
    
    /**
     This method specifies the **Group** Object to along wih Group Members to present details in it.
     - Parameter group: This specifies `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func set(group: Group){
        currentGroup = group
        self.getGroup(group: group)
        if members.isEmpty {
            if currentGroup?.scope == .admin || currentGroup?.scope == .moderator {
                self.fetchBannedMembers(for: group)
            }
            self.fetchGroupMembers(group: group)
        }
    }
    
    /**
     This method specifies the navigation bar title for CometChatGroupDetail.
     - Parameters:
     - title: This takes the String to set title for CometChatGroupDetail.
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
     This method observers for the notifications of certain events.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func addObsevers(){
        CometChat.groupdelegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /**
     This method sets the list of items needs to be display in CometChatGroupDetail.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func setupItems(){
        settingsItems.removeAll()
        supportItems.removeAll()
        
        if currentGroup?.scope == .admin || currentGroup?.owner == LoggedInUser.uid || currentGroup?.scope == .moderator {
            if currentGroup?.scope == .moderator {
               if UIKitSettings.joinOrLeaveGroup == .enabled {
                    supportItems = [CometChatGroupDetail.EXIT_CELL]
                }
                settingsItems = [CometChatGroupDetail.GROUP_INFO_CELL]
                if UIKitSettings.allowPromoteDemoteMembers == .enabled {
                    settingsItems.append(CometChatGroupDetail.MODERATORS_CELL)
                }
                if UIKitSettings.allowKickBanMembers == .enabled {
                    settingsItems.append(CometChatGroupDetail.BANNED_MEMBER_CELL)
                }
            }else {
                settingsItems = [CometChatGroupDetail.GROUP_INFO_CELL]
                if UIKitSettings.allowPromoteDemoteMembers == .enabled {
                    settingsItems.append(CometChatGroupDetail.ADMINISTRATOR_CELL)
                    settingsItems.append(CometChatGroupDetail.MODERATORS_CELL)
                }
                
                if UIKitSettings.joinOrLeaveGroup == .enabled {
                    supportItems = [CometChatGroupDetail.EXIT_CELL]
                }
                
                if UIKitSettings.allowDeleteGroup == .enabled {
                    supportItems = [CometChatGroupDetail.DELETE_AND_EXIT_CELL]
                }
            }
        }else{
            settingsItems = [CometChatGroupDetail.GROUP_INFO_CELL]
            if UIKitSettings.joinOrLeaveGroup == .enabled {
                supportItems = [CometChatGroupDetail.EXIT_CELL]
            }
        }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
        
    }
    
    /**
     This method setup the tableview to load CometChatGroupDetail.
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
     This method register the cells for CometChatGroupDetail.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    private func registerCells(){
        let CometChatDetailView  = UINib.init(nibName: "CometChatDetailView", bundle: UIKitSettings.bundle)
        self.tableView.register(CometChatDetailView, forCellReuseIdentifier: "detailView")
        
        let NotificationsView  = UINib.init(nibName: "NotificationsView", bundle: UIKitSettings.bundle)
        self.tableView.register(NotificationsView, forCellReuseIdentifier: "notificationsView")
        
        let AdministratorView  = UINib.init(nibName: "AdministratorView", bundle: UIKitSettings.bundle)
        self.tableView.register(AdministratorView, forCellReuseIdentifier: "administratorView")
        
        let AddMemberView  = UINib.init(nibName: "AddMemberView", bundle: UIKitSettings.bundle)
        self.tableView.register(AddMemberView, forCellReuseIdentifier: "addMemberView")
        
        let MembersView  = UINib.init(nibName: "MembersView", bundle: UIKitSettings.bundle)
        self.tableView.register(MembersView, forCellReuseIdentifier: "membersView")
        
        let SupportView  = UINib.init(nibName: "SupportView", bundle: UIKitSettings.bundle)
        self.tableView.register(SupportView, forCellReuseIdentifier: "supportView")
        
        let SharedMediaView  = UINib.init(nibName: "SharedMediaView", bundle: UIKitSettings.bundle)
        self.tableView.register(SharedMediaView, forCellReuseIdentifier: "sharedMediaView")
        
    }
    
    
    
    
    private func getGroup(group: Group){
        CometChat.getGroup(GUID: group.guid, onSuccess: { (group) in
            self.currentGroup = group
            self.setupItems()
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
     This method fetches  the **Group Members**  for particular group.
     - Parameter group: This specifies `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func fetchGroupMembers(group: Group){
        memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: group.guid).set(limit: 100).build()
        memberRequest?.fetchNext(onSuccess: { (groupMember) in
            self.members = groupMember
            self.administrators = groupMember.filter {$0.scope == .admin}
            self.moderators = groupMember.filter {$0.scope == .moderator}
            DispatchQueue.main.async {self.tableView.reloadData() }
        }, onError: { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
            }
        })
    }
    
    private func fetchBannedMembers(for group: Group){
        bannedMemberRequest = BannedGroupMembersRequest.BannedGroupMembersRequestBuilder(guid: currentGroup?.guid ?? "").set(limit: 100).build()
        bannedMemberRequest?.fetchNext(onSuccess: { (groupMembers) in
            self.bannedMembers = groupMembers
            DispatchQueue.main.async { self.tableView.reloadData() }
        }, onError: { (error) in
            DispatchQueue.main.async {
                if let errorMessage = error?.errorDescription {
                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                    snackbar.show()
                }
            }
         })
    }
    
    
    /**
     This method refreshes te group details when triggered.
     - Parameter group: This specifies `Group` Object.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc func didRefreshGroupDetails(_ notification: NSNotification) {
        if let group = currentGroup {
            self.fetchBannedMembers(for: group)
            self.getGroup(group: group)
        }
        if let guid = notification.userInfo?["guid"] as? String {
            memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: guid).set(limit: 100).build()
            memberRequest?.fetchNext(onSuccess: { (groupMember) in
                self.members = groupMember
                self.administrators = groupMember.filter {$0.scope == .admin}
                self.moderators = groupMember.filter {$0.scope == .moderator}
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }, onError: { (error) in
                DispatchQueue.main.async {
                    if let errorMessage = error?.errorDescription {
                        let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                        snackbar.show()
                    }
                }
            })
        }
    }
    
    /**
     This method setup navigationBar for CometChatGroupDetail viewController.
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
                self.navigationController?.navigationBar.isTranslucent = true
            }
            let closeButton = UIBarButtonItem(title: NSLocalizedString("CLOSE", bundle: UIKitSettings.bundle, comment: ""), style: .plain, target: self, action: #selector(closeButtonPressed))
            closeButton.tintColor = UIKitSettings.primaryColor
            self.navigationItem.rightBarButtonItem = closeButton
        }
    }
    
    /**
     This method triggers when user clicks on close button.
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    @objc func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
    }
}


/*  ----------------------------------------------------------------------------------------- */

// MARK: - Table view Methods


extension CometChatGroupDetail: UITableViewDelegate , UITableViewDataSource {
    
    /// This method specifies the number of sections to display list of items.
    /// - Parameter tableView: An object representing the table view requesting this information.
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    /// This method specifies height for section in CometChatGroupDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 2 {
            return 0
        }else{
            if UIKitSettings.joinOrLeaveGroup == .disabled && section == 3 {
               return 0
            }else if UIKitSettings.viewGroupMembers == .disabled && section == 1 {
               return 0
            }else if UIKitSettings.viewShareMedia == .disabled && section == 4 {
               return 0
            }else{
               return 30
            }
        }
    }
    
    /// This method specifies the view for header  in CometChatGroupDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let returnedView = UIView(frame: CGRect(x: 5, y: 5, width: view.frame.size.width, height: 25))
        let sectionTitle = UILabel(frame: CGRect(x: 10, y: 2, width: view.frame.size.width, height: 20))
        if section == 0 {
            sectionTitle.text =  ""
        }else if section == 1{
            sectionTitle.text =  NSLocalizedString("MEMBERS_", bundle: UIKitSettings.bundle, comment: "")
        }else if section == 2{
            sectionTitle.text =  ""
        }else if section == 3{
            sectionTitle.text =  NSLocalizedString("PRIVACY_&_SUPPORT", bundle: UIKitSettings.bundle, comment: "")
        }else if section == 4{
            sectionTitle.text =  NSLocalizedString("SHARED_MEDIA", bundle: UIKitSettings.bundle, comment: "")
        }
        sectionTitle.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        if #available(iOS 13.0, *) {
            sectionTitle.textColor = .lightGray
            returnedView.backgroundColor = .clear
        } else {}
        returnedView.addSubview(sectionTitle)
        return returnedView
    }
    
    /// This method specifiesnumber of rows in CometChatGroupDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return settingsItems.count
        case 1:
            if UIKitSettings.allowAddMembers == .enabled {
                return 1
            }else {
               return 0
            }
        case 2:
            if UIKitSettings.viewGroupMembers == .enabled {
                 return members.count
            }else {
               return 0
            }
        case 3: return supportItems.count
        case 4:
            if UIKitSettings.viewShareMedia == .enabled { return 1 } else { return 0 }
        default: return 0
        }
    }
    
    /// This method specifies the view for user  in CometChatGroupDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }else if currentGroup?.owner == LoggedInUser.uid && indexPath.section == 1 {
            return 60
        }else if currentGroup?.scope != .admin && indexPath.section == 1 {
            return 0
        }else if indexPath.section == 4 {
            return 320
        }else{
            return 60
        }
    }
    
    /// This method specifies the view for user  in CometChatGroupDetail
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - section: An index number identifying a section of tableView .
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:UITableViewCell = UITableViewCell()
        switch indexPath.section {
        case 0:
            switch settingsItems[safe:indexPath.row] {
            case CometChatGroupDetail.GROUP_INFO_CELL:
                let groupDetail = tableView.dequeueReusableCell(withIdentifier: "detailView", for: indexPath) as! CometChatDetailView
                groupDetail.group = currentGroup
                groupDetail.detailViewDelegate = self
                groupDetail.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                
                if let memberCount = currentGroup?.membersCount {
                    if memberCount == 1 {
                        groupDetail.detail.text = "1 Member"
                    }else{
                        groupDetail.detail.text =  "\(memberCount)" +  NSLocalizedString("MEMBERS", bundle: UIKitSettings.bundle, comment: "")
                    }
                }
                return groupDetail
            
            case CometChatGroupDetail.ADMINISTRATOR_CELL:
                let administratorCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
                administratorCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                administratorCell.title.text = "Administrators"
                return administratorCell
                
            case CometChatGroupDetail.MODERATORS_CELL:
                let administratorCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
                administratorCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                administratorCell.title.text = "Moderators"
                return administratorCell
                
            case CometChatGroupDetail.BANNED_MEMBER_CELL:
                let administratorCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
                administratorCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                administratorCell.title.text = "Banned Members"
                return administratorCell
            default:break
            }
            
        case 1:
            let addMemberCell = tableView.dequeueReusableCell(withIdentifier: "addMemberView",for: indexPath) as! AddMemberView
            addMemberCell.textLabel?.textColor = UIKitSettings.primaryColor
            addMemberCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            return addMemberCell
            
        case 2:
            
            if let member = members[safe: indexPath.row] {
                let membersCell = tableView.dequeueReusableCell(withIdentifier: "membersView", for: indexPath) as! MembersView
                membersCell.member = member
                if member.uid == currentGroup?.owner {
                    membersCell.scope.text = NSLocalizedString("Owner", bundle: UIKitSettings.bundle, comment: "")
                }
                membersCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return membersCell
            }
        case 3:
            switch supportItems[safe:indexPath.row] {
            case CometChatGroupDetail.DELETE_AND_EXIT_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = NSLocalizedString("DELETE_&_EXIT", bundle: UIKitSettings.bundle, comment: "")
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            case CometChatGroupDetail.EXIT_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = NSLocalizedString("LEAVE_GROUP", bundle: UIKitSettings.bundle, comment: "")
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
            default:break
            }
        case 4:
            if let group = currentGroup {
                let sharedMediaCell = tableView.dequeueReusableCell(withIdentifier: "sharedMediaView", for: indexPath) as! SharedMediaView
                sharedMediaCell.refreshMediaMessages(for: group, type: .group)
                sharedMediaCell.sharedMediaDelegate = self
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
            switch settingsItems[safe:indexPath.row] {
            case CometChatGroupDetail.GROUP_INFO_CELL: break
            case CometChatGroupDetail.ADMINISTRATOR_CELL:
                let addAdmins = CometChatAddAdministrators()
                addAdmins.mode = .fetchAdministrators
                guard let group = currentGroup else { return }
                addAdmins.set(group: group)
                let navigationController: UINavigationController = UINavigationController(rootViewController: addAdmins)
                self.present(navigationController, animated: true, completion: nil)
                
            case CometChatGroupDetail.MODERATORS_CELL:
                let addModerators = CometChatAddModerators()
                addModerators.mode = .fetchModerators
                guard let group = currentGroup else { return }
                addModerators.set(group: group)
                let navigationController: UINavigationController = UINavigationController(rootViewController: addModerators)
                self.present(navigationController, animated: true, completion: nil)
                
            case CometChatGroupDetail.BANNED_MEMBER_CELL:
                let bannedMembers = CometChatBannedMembers()
                guard let group = currentGroup else { return }
                bannedMembers.set(group: group)
                let navigationController: UINavigationController = UINavigationController(rootViewController: bannedMembers)
                self.present(navigationController, animated: true, completion: nil)
                
            default:break }
        case 1:
            let addMembers = CometChatAddMembers()
            guard let group = currentGroup else { return }
            addMembers.set(group: group)
            let navigationController: UINavigationController = UINavigationController(rootViewController: addMembers)
            self.present(navigationController, animated: true, completion: nil)
        case 2:
            if #available(iOS 13.0, *) {
                
            }else{
                if  let selectedCell = tableView.cellForRow(at: indexPath) as? MembersView  {
                    let memberName = (tableView.cellForRow(at: indexPath) as? MembersView)?.member?.name ?? ""
                    let groupName = self.currentGroup?.name ?? ""
                    let alert = UIAlertController(title: nil, message: "Perform an action to remove or ban \(memberName) from \(groupName).", preferredStyle: .actionSheet)
                    alert.addAction(UIAlertAction(title: "Remove Member", style: .default, handler: { action in
                        CometChat.kickGroupMember(UID: selectedCell.member?.uid ?? "", GUID: self.currentGroup?.guid ?? "", onSuccess: { (success) in
                            DispatchQueue.main.async {
                                if let group = self.currentGroup {
                                    let data:[String: String] = ["guid": group.guid]
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: data)
                                }
                                let message = (selectedCell.member?.name ?? "") + NSLocalizedString("REMOVED_SUCCESSFULLY", bundle: UIKitSettings.bundle, comment: "")
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: message, duration: .short)
                                snackbar.show()
                            }
                        }) { (error) in
                            DispatchQueue.main.async {
                                if let errorMessage = error?.errorDescription {
                                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                                    snackbar.show()
                                }
                            }
                        }
                    }))
                    alert.addAction(UIAlertAction(title: NSLocalizedString("BAN_MEMBER", bundle: UIKitSettings.bundle, comment: ""), style: .default, handler: { action in
                        CometChat.banGroupMember(UID: selectedCell.member?.uid ?? "", GUID: self.currentGroup?.guid ?? "", onSuccess: { (success) in
                            DispatchQueue.main.async {
                                if let group = self.currentGroup {
                                    let data:[String: String] = ["guid": group.guid]
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: data)
                                }
                                let message = (selectedCell.member?.name ?? "") + NSLocalizedString("BANNED_SUCCESSFULLY", bundle: UIKitSettings.bundle, comment: "")
                                let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: message, duration: .short)
                                snackbar.show()
                            }
                        }) { (error) in
                            DispatchQueue.main.async {
                                if let errorMessage = error?.errorDescription {
                                    let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: errorMessage, duration: .short)
                                    snackbar.show()
                                }
                            }
                        }
                    }))
                    alert.view.tintColor = UIKitSettings.primaryColor
                    alert.addAction(UIAlertAction(title: NSLocalizedString("CANCEL", bundle: UIKitSettings.bundle, comment: ""), style: .cancel, handler: { action in
                    }))
                    if UIKitSettings.allowKickBanMembers == .enabled {
                        if LoggedInUser.uid == self.currentGroup?.owner || self.currentGroup?.scope == .admin || self.currentGroup?.scope == .moderator {
                            if selectedCell.member?.scope == .participant || selectedCell.member?.scope == .moderator {
                                self.present(alert, animated: true)
                            }else if LoggedInUser.uid == self.currentGroup?.owner && selectedCell.member?.scope == .admin && selectedCell.member?.uid != LoggedInUser.uid {
                                self.present(alert, animated: true)
                            }
                        }
                    }
                }
            }
            
        case 3:
            switch supportItems[safe:indexPath.row] {
            case CometChatGroupDetail.DELETE_AND_EXIT_CELL:
                
                if let guid = currentGroup?.guid {
                    CometChat.deleteGroup(GUID: guid, onSuccess: { (success) in
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil, userInfo: nil)
                            }
                            let message = (self.currentGroup?.name ?? "") + NSLocalizedString(
                                "DELETED_SUCCESSFULLY", bundle: UIKitSettings.bundle, comment: "")
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: message, duration: .short)
                            snackbar.show()
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
                
            case CometChatGroupDetail.EXIT_CELL:
                
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
            default:break }
        default: break
        }
    }
    
    /// This method triggers the `UIMenu` when user holds on TableView cell.
    /// - Parameters:
    ///   - tableView: The table-view object requesting this information.
    ///   - indexPath: specifies current index for TableViewCell.
    ///   - point: A structure that contains a point in a two-dimensional coordinate system.
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
   
    
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? MembersView  {
                let removeMember = UIAction(title: NSLocalizedString("REMOVE_MEMBER", bundle: UIKitSettings.bundle, comment: ""), image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                    
                    CometChat.kickGroupMember(UID: selectedCell.member?.uid ?? "", GUID: self.currentGroup?.guid ?? "", onSuccess: { (success) in
                        DispatchQueue.main.async {
                            if let group = self.currentGroup {
                                let data:[String: String] = ["guid": group.guid ]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: data)
                            }
                            let message = (selectedCell.member?.name ?? "") + NSLocalizedString("REMOVED_SUCCESSFULLY", bundle: UIKitSettings.bundle, comment: "")
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: message, duration: .short)
                            snackbar.show()
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
                
                let banMember = UIAction(title: NSLocalizedString("BAN_MEMBER", bundle: UIKitSettings.bundle, comment: ""), image: UIImage(systemName: "exclamationmark.octagon.fill"), attributes: .destructive){ action in
                    
                    CometChat.banGroupMember(UID: selectedCell.member?.uid ?? "", GUID: self.currentGroup?.guid ?? "", onSuccess: { (success) in
                        DispatchQueue.main.async {
                            if let group = self.currentGroup {
                                let data:[String: String] = ["guid": group.guid ]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: data)
                            }
                            let message = (selectedCell.member?.name ?? "") + NSLocalizedString("BANNED_SUCCESSFULLY", bundle: UIKitSettings.bundle, comment: "")
                            let snackbar: CometChatSnackbar = CometChatSnackbar.init(message: message, duration: .short)
                            snackbar.show()
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
                
                let memberName = (tableView.cellForRow(at: indexPath) as? MembersView)?.member?.name ?? ""
                let groupName = self.currentGroup?.name ?? ""
                
                 if UIKitSettings.allowKickBanMembers == .enabled {
                if LoggedInUser.uid == self.currentGroup?.owner || self.currentGroup?.scope == .admin ||  self.currentGroup?.scope == .moderator {
                    if selectedCell.member?.scope == .participant ||  selectedCell.member?.scope == .moderator {
                        return UIMenu(title:  "Perform an action to remove or ban \(memberName) from \(groupName)." , children: [removeMember, banMember])
                    }else if LoggedInUser.uid == self.currentGroup?.owner && selectedCell.member?.scope == .admin && selectedCell.member?.uid != LoggedInUser.uid || selectedCell.member?.scope == .moderator {
                        return UIMenu(title:  "Perform an action to remove or ban \(memberName) from \(groupName)." , children: [removeMember, banMember])
                    }
                }
                }
            }
            return UIMenu(title: "")
        })
    }
}

/*  ----------------------------------------------------------------------------------------- */


// MARK: - CometChatGroupDelegate Delegate

extension CometChatGroupDetail: CometChatGroupDelegate {
    
    /**
     This method triggers when someone joins group.
     - Parameters
     - action: Spcifies `ActionMessage` Object
     - joinedUser: Specifies `User` Object
     - joinedGroup: Specifies `Group` Object
     - Author: CometChat Team
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if let group = currentGroup {
            if group == joinedGroup {
                fetchGroupMembers(group: group)
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
     - Copyright:  ©  2020 CometChat Inc.
     
     */
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if let group = currentGroup {
            if group == leftGroup {
                getGroup(group: group)
                fetchGroupMembers(group: group)
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
     - Copyright:  ©  2020 CometChat Inc.
     
     */
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if let group = currentGroup {
            if group == kickedFrom {
                getGroup(group: group)
                fetchGroupMembers(group: group)
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
     - Copyright:  ©  2020 CometChat Inc.
     - See Also:
     [CometChatMessageList Documentation](https://prodocs.cometchat.com/docs/ios-ui-screens#section-4-comet-chat-message-list)
     */
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if let group = currentGroup {
            if group == bannedFrom {
                getGroup(group: group)
                fetchGroupMembers(group: group)
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
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if let group = currentGroup {
            if group == unbannedFrom {
                getGroup(group: group)
                fetchGroupMembers(group: group)
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
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if let group = currentGroup {
            if group == group {
                getGroup(group: group)
                fetchGroupMembers(group: group)
                
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
     - Copyright:  ©  2020 CometChat Inc.
     */
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if let group = currentGroup {
            if group == group {
                getGroup(group: group)
                fetchGroupMembers(group: group)
            }
        }
    }
}

/*  ----------------------------------------------------------------------------------------- */

// MARK: - QuickLook Preview Delegate

extension CometChatGroupDetail: QLPreviewControllerDataSource, QLPreviewControllerDelegate {
    
    
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


extension CometChatGroupDetail: SharedMediaDelegate {
    
    
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

extension CometChatGroupDetail: DetailViewDelegate {
    
    func didCallButtonPressed(for: AppEntity) {
        
        let actionSheetController: UIAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let audioCall: UIAlertAction = UIAlertAction(title: NSLocalizedString("AUDIO_CALL", bundle: UIKitSettings.bundle, comment: ""), style: .default) { action -> Void in
            if let group = self.currentGroup {
                CometChatCallManager().makeCall(call: .audio, to: group)
            }
        }
        
        let videoCall: UIAlertAction = UIAlertAction(title: NSLocalizedString("VIDEO_CALL", bundle: UIKitSettings.bundle, comment: ""), style: .default) { action -> Void in
            
            if let group = self.currentGroup {
                CometChatCallManager().makeCall(call: .video, to: group)
            }
        }
        
        let cancelAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("CANCEL", bundle: UIKitSettings.bundle, comment: ""), style: .cancel) { action -> Void in
        }
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        if UIKitSettings.groupAudioCall == .enabled {
            actionSheetController.addAction(audioCall)
        }
       
        if UIKitSettings.groupVideoCall == .enabled {
            actionSheetController.addAction(videoCall)
        }
        
        actionSheetController.addAction(cancelAction)
        actionSheetController.view.tintColor = UIKitSettings.primaryColor
        // Added ActionSheet support for iPad
          actionSheetController.view.tintColor = UIKitSettings.primaryColor
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
