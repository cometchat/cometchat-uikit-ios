
//  CometChatUserDetail.swift
//  CometChatUIKit
//  Created by Pushpsen Airekar on 20/09/19.
//  Copyright ©  2019 CometChat Inc. All rights reserved.

// MARK: - Importing Frameworks.

import UIKit
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
    
    static let USER_INFO_CELL = 0
    static let SEND_MESSAGE_CELL = 1
    static let ADD_TO_CONTACTS_CELL = 2
    static let BLOCK_USER_CELL = 3
    
    // MARK: - View controller lifecycle methods
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
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
     - Copyright:  ©  2019 CometChat Inc.
     */
    public func set(user: User){
        guard  user != nil else {
            return
        }
        currentUser = user
        CometChat.getUser(UID: user.uid ?? "", onSuccess: { (updatedUser) in
            self.currentUser = updatedUser
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }) { (error) in
            print("unable to fetch user information: \(String(describing: error?.errorDescription))")
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
     - Copyright:  ©  2019 CometChat Inc.
     */
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
    
    
    
    
    // MARK: - Private Instance methods
    
    /**
     This method sets the list of items needs to be display in CometChatUserDetail.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     */
    private func setupItems(){
        settingItems = [CometChatUserDetail.USER_INFO_CELL]
        if currentGroup != nil {
            actionsItems = [CometChatUserDetail.SEND_MESSAGE_CELL, CometChatUserDetail.ADD_TO_CONTACTS_CELL]
        }else{
            actionsItems = [CometChatUserDetail.SEND_MESSAGE_CELL]
        }
        supportItems = [ CometChatUserDetail.BLOCK_USER_CELL]
    }
    
    /**
     This method setup the tableview to load CometChatUserDetail.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
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
     - Copyright:  ©  2019 CometChat Inc.
     */
    private func registerCells(){
        let CometChatUserView  = UINib.init(nibName: "CometChatGroupView", bundle: nil)
        self.tableView.register(CometChatUserView, forCellReuseIdentifier: "groupView")
        
        let NotificationsView  = UINib.init(nibName: "NotificationsView", bundle: nil)
        self.tableView.register(NotificationsView, forCellReuseIdentifier: "notificationsView")
        
        let SupportView  = UINib.init(nibName: "SupportView", bundle: nil)
        self.tableView.register(SupportView, forCellReuseIdentifier: "supportView")
    }
    
    
    /**
     This method setup navigationBar for CometChatUserDetail viewController.
     - Author: CometChat Team
     - Copyright:  ©  2019 CometChat Inc.
     */
    private func setupNavigationBar(){
        
        if navigationController != nil{
            // NavigationBar Appearance
            if #available(iOS 13.0, *) {
                let navBarAppearance = UINavigationBarAppearance()
                navBarAppearance.configureWithOpaqueBackground()
                navBarAppearance.titleTextAttributes = [.font: UIFont (name: "SFProDisplay-Regular", size: 20) as Any]
                navBarAppearance.largeTitleTextAttributes = [.font: UIFont(name: "SFProDisplay-Bold", size: 35) as Any]
                navBarAppearance.shadowColor = .clear
                navigationController?.navigationBar.standardAppearance = navBarAppearance
                navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
                setLargeTitleDisplayMode(.never)
                self.navigationController?.navigationBar.isTranslucent = true
            }
            let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonPressed))
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
        return 3
    }
    
    /// This method specifies height for section in CometChatUserDetail
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
            sectionTitle.text =  "ACTIONS"
        }else if section == 2{
            sectionTitle.text =  "PRIVACY & SUPPORT"
        }
        sectionTitle.font = UIFont(name: "SFProDisplay-Medium", size: 13)
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
                let userInfoCell = tableView.dequeueReusableCell(withIdentifier: "groupView", for: indexPath) as! CometChatGroupView
                userInfoCell.groupAvatar.set(image: currentUser?.avatar ?? "", with: currentUser?.name ?? "")
                userInfoCell.groupName.text = currentUser?.name?.capitalized ?? ""
                userInfoCell.groupDetails.isHidden = false
                switch currentUser!.status {
                case .online: userInfoCell.groupDetails.text = "Online"
                case .offline: userInfoCell.groupDetails.text = "Offline"
                @unknown default: break
                }
                userInfoCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return userInfoCell
            default:break
            }
            
        case 1:
            
            switch actionsItems[safe:indexPath.row] {
            case CometChatUserDetail.SEND_MESSAGE_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = "Send Message"
                supportCell.textLabel?.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
            case CometChatUserDetail.ADD_TO_CONTACTS_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                
                if let groupName = currentGroup?.name {
                    supportCell.textLabel?.text = "Add in \(groupName)"
                }else{
                    supportCell.textLabel?.text = "Add Contact"
                }
                supportCell.textLabel?.textColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            default: break
            }
            
        case 2:
            switch supportItems[safe:indexPath.row] {
            case CometChatUserDetail.BLOCK_USER_CELL:
                
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                
                if currentUser?.blockedByMe == true {
                    supportCell.textLabel?.text = "Unblock User"
                }else {
                    supportCell.textLabel?.text = "Block User"
                }
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
                        
                        self.dismiss(animated: true) {}
                        
                    }
                }) { (error) in
                    DispatchQueue.main.async {
                        if let errorMessage = error?.errorDescription {
                            self.view.makeToast(errorMessage)
                        }
                    }
                    print("Error while adding in group: \(String(describing: error?.errorDescription))")
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
                                self.view.makeToast("\(name) unblocked successfully.")
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                self.view.makeToast(errorMessage)
                            }
                        }
                        print("Error while blocking the user: \(String(describing: error?.errorDescription))")
                    }
                    
                case false:
                    CometChat.blockUsers([(currentUser?.uid ?? "")], onSuccess: { (success) in
                        DispatchQueue.main.async {
                            if let user = self.currentUser, let name = user.name {
                                self.set(user: user)
                                let data:[String: String] = ["name": name]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil, userInfo: data)
                                self.view.makeToast("\(name) blocked successfully.")
                            }
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            if let errorMessage = error?.errorDescription {
                                self.view.makeToast(errorMessage)
                            }
                        }
                        print("Error while blocking the user: \(String(describing: error?.errorDescription))")
                    }
                }
                
            default:break}
        default: break}
    }
}

/*  ----------------------------------------------------------------------------------------- */
