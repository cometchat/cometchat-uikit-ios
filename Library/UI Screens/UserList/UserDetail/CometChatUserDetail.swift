//
//  CometChatUserDetail.swift
//  ios-chat-uikit-app
//
//  Created by Pushpsen Airekar on 30/12/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class CometChatUserDetail: UIViewController {
    
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var settingItems:[Int] = [Int]()
    var actionsItems:[Int] = [Int]()
    var supportItems:[Int] = [Int]()
    var currentUser: User?
    var currentGroup: Group?
    
    static let USER_INFO_CELL = 0
    static let NOTIFICATION_CELL = 1
    static let SEND_MESSAGE_CELL = 2
    static let ADD_TO_CONTACTS_CELL = 3
    static let CLEAR_CHAT_CELL = 4
    static let BLOCK_USER_CELL = 5
    static let REPORT_CELL = 6
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
        view.backgroundColor = .white
        safeArea = view.layoutMarginsGuide
        self.setupTableView()
        self.setupNavigationBar()
        self.setupItems()
    }
    
    private func setupItems(){
        settingItems = [CometChatUserDetail.USER_INFO_CELL, CometChatUserDetail.NOTIFICATION_CELL]
        actionsItems = [CometChatUserDetail.SEND_MESSAGE_CELL, CometChatUserDetail.ADD_TO_CONTACTS_CELL]
        supportItems = [CometChatUserDetail.CLEAR_CHAT_CELL, CometChatUserDetail.BLOCK_USER_CELL, CometChatUserDetail.REPORT_CELL]
    }
    
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
        
        let CometChatUserView  = UINib.init(nibName: "CometChatGroupView", bundle: nil)
        self.tableView.register(CometChatUserView, forCellReuseIdentifier: "groupView")
        
        let NotificationsView  = UINib.init(nibName: "NotificationsView", bundle: nil)
        self.tableView.register(NotificationsView, forCellReuseIdentifier: "notificationsView")
        
        let SupportView  = UINib.init(nibName: "SupportView", bundle: nil)
        self.tableView.register(SupportView, forCellReuseIdentifier: "supportView")
        
    }
    
    public func set(user: User){
        guard  user != nil else {
            return
        }
        currentUser = user
    }
    
    
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
                
                let closeButton = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(closeButtonPressed))
                self.navigationItem.rightBarButtonItem = closeButton
            }
        }
    }
    
    @objc func closeButtonPressed(){
        self.dismiss(animated: true, completion: nil)
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
    
}


extension CometChatUserDetail: UITableViewDelegate , UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0  {
            return 0
        }else{
            return 25
        }
    }
    
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
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        switch section {
        case 0: return settingItems.count
        case 1: return actionsItems.count
        case 2: return supportItems.count
        default: return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }else {
            return 60
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = UITableViewCell()
        switch indexPath.section {
        case 0:
            switch settingItems[indexPath.row] {
            case CometChatUserDetail.USER_INFO_CELL:
                let userInfoCell = tableView.dequeueReusableCell(withIdentifier: "groupView", for: indexPath) as! CometChatGroupView
                userInfoCell.groupAvtar.set(image: currentUser?.avatar ?? "")
                userInfoCell.groupName.text = currentUser?.name?.capitalized ?? ""
                userInfoCell.groupDetails.isHidden = false
                switch currentUser!.status {
                case .online: userInfoCell.groupDetails.text = "Online"
                case .offline: userInfoCell.groupDetails.text = "Offline"
                @unknown default: break
                }
                userInfoCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return userInfoCell
            case CometChatUserDetail.NOTIFICATION_CELL:
                let notificationsCell = tableView.dequeueReusableCell(withIdentifier: "notificationsView", for: indexPath) as! NotificationsView
                notificationsCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return notificationsCell
            default:break
            }
            
        case 1:
            
            switch actionsItems[indexPath.row] {
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
            switch supportItems[indexPath.row] {
            case CometChatUserDetail.CLEAR_CHAT_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = "Clear Chat"
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            case CometChatUserDetail.BLOCK_USER_CELL:
                
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = "Block User"
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            case CometChatUserDetail.REPORT_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = "Report"
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
            default:break
            }
        default: break
        }
        
        
        return cell
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            switch settingItems[indexPath.row] {
            case CometChatUserDetail.USER_INFO_CELL: break
            case CometChatUserDetail.NOTIFICATION_CELL: break
            default:break}
            
        case 1:
            switch actionsItems[indexPath.row] {
            case CometChatUserDetail.SEND_MESSAGE_CELL:
                guard let user = currentUser else { return }
                let messageList = CometChatMessageList()
                messageList.set(conversationWith: user, type: .user)
                navigationController?.pushViewController(messageList, animated: true)
                
            case CometChatUserDetail.ADD_TO_CONTACTS_CELL:
                
                
                CometChat.addMembersToGroup(guid: currentGroup?.guid ?? "", groupMembers: [GroupMember(UID: currentUser?.uid ?? "", groupMemberScope: .participant)], onSuccess: { (sucess) in
                    DispatchQueue.main.async {
                        
                        let data:[String: String] = ["guid": self.currentGroup?.guid ?? ""]
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: data)
                        
                        self.dismiss(animated: true) {}
                        
                    }
                }) { (error) in
                    print("Error while adding in group: \(String(describing: error?.errorDescription))")
                }
                
                
                
            default: break}
        case 2:
            switch supportItems[indexPath.row] {
            case CometChatUserDetail.CLEAR_CHAT_CELL:break
            case CometChatUserDetail.BLOCK_USER_CELL:
                
                CometChat.blockUsers([(currentUser?.uid ?? "")], onSuccess: { (success) in
                    DispatchQueue.main.async {
                        if let name = self.currentUser?.name {
                            let data:[String: String] = ["name": name]
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didUserBlocked"), object: nil, userInfo: data)
                            self.view.makeToast("\(name) blocked successfully.")
                        }
                    }
                }) { (error) in
                     print("Error while blocking the user: \(String(describing: error?.errorDescription))")
                }
                
            case CometChatUserDetail.REPORT_CELL:break
            default:break
            }
        default: break
        }
        
        
    }
}

