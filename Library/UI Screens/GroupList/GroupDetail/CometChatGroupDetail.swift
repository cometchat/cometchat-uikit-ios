//
//  CometChatUserDetail.swift
//  ios-chat-uikit-app
//
//  Created by Pushpsen Airekar on 30/12/19.
//  Copyright © 2019 Pushpsen Airekar. All rights reserved.
//

import UIKit
import CometChatPro

class CometChatGroupDetail: UIViewController {
    
    var tableView: UITableView! = nil
    var safeArea: UILayoutGuide!
    var settingsItems:[Int] = [Int]()
    var supportItems:[Int] = [Int]()
    var viewMoreItems:[Int] = [Int]()
    var members:[GroupMember] = [GroupMember]()
    var administrators:[GroupMember] = [GroupMember]()
    var memberRequest: GroupMembersRequest?
    var currentGroup: Group?
    
    
    static let GROUP_INFO_CELL = 0
    static let NOTIFICATION_CELL = 1
    static let ADMINISTRATOR_CELL = 2
    static let ADD_MEMBER_CELL = 3
    static let MEMBERS_CELL = 4
    static let VIEW_MORE_CELL = 5
    static let DELETE_AND_EXIT_CELL = 6
    static let EXIT_CELL = 7
    static let REPORT_CELL = 8
    
    
    override public func loadView() {
        super.loadView()
        UIFont.loadAllFonts(bundleIdentifierString: Bundle.main.bundleIdentifier ?? "")
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
    
    
    private func addObsevers(){
        CometChat.groupdelegate = self
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil)
        NotificationCenter.default.addObserver(self, selector:#selector(self.didRefreshGroupDetails(_:)), name: NSNotification.Name(rawValue: "didRefreshMembers"), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupItems(){
        settingsItems.removeAll()
        supportItems.removeAll()
        viewMoreItems.removeAll()
        
        if currentGroup?.scope == .admin || currentGroup?.owner == CometChat.getLoggedInUser()?.uid {
            settingsItems = [CometChatGroupDetail.GROUP_INFO_CELL, CometChatGroupDetail.NOTIFICATION_CELL, CometChatGroupDetail.ADMINISTRATOR_CELL]
            supportItems = [CometChatGroupDetail.DELETE_AND_EXIT_CELL,CometChatGroupDetail.EXIT_CELL, CometChatGroupDetail.REPORT_CELL]
        }else{
            settingsItems = [CometChatGroupDetail.GROUP_INFO_CELL, CometChatGroupDetail.NOTIFICATION_CELL]
            supportItems = [CometChatGroupDetail.EXIT_CELL, CometChatGroupDetail.REPORT_CELL]
        }
        viewMoreItems = [CometChatGroupDetail.VIEW_MORE_CELL]
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }

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
        
        let AdministratorView  = UINib.init(nibName: "AdministratorView", bundle: nil)
        self.tableView.register(AdministratorView, forCellReuseIdentifier: "administratorView")
        
        let AddMemberView  = UINib.init(nibName: "AddMemberView", bundle: nil)
        self.tableView.register(AddMemberView, forCellReuseIdentifier: "addMemberView")
        
        let MembersView  = UINib.init(nibName: "MembersView", bundle: nil)
        self.tableView.register(MembersView, forCellReuseIdentifier: "membersView")
        
        let SupportView  = UINib.init(nibName: "SupportView", bundle: nil)
        self.tableView.register(SupportView, forCellReuseIdentifier: "supportView")
        
        let ViewMoreView  = UINib.init(nibName: "ViewMoreView", bundle: nil)
        self.tableView.register(ViewMoreView, forCellReuseIdentifier: "viewMoreView")
        
        
    }
    
    
    public func set(group: Group, with members: [GroupMember]){
        
        guard  group != nil else {
            return
        }
        currentGroup = group
        self.getGroup(group: group)
        self.members = members
        administrators = members.filter {$0.scope == .admin}
        if members.isEmpty {
            self.fetchGroupMembers(group: group)
        }
    }
    
    private func getGroup(group: Group){
        CometChat.getGroup(GUID: group.guid, onSuccess: { (group) in
            self.currentGroup = group
            self.setupItems()
        }) { (error) in
            print("error in fetching group info: \(String(describing: error?.errorDescription))")
        }
    }
    
    public func fetchGroupMembers(group: Group){
        memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: group.guid).set(limit: 10).build()
        memberRequest?.fetchNext(onSuccess: { (groupMember) in
            self.members = groupMember
            self.administrators = groupMember.filter {$0.scope == .admin}
            DispatchQueue.main.async {self.tableView.reloadData() }
        }, onError: { (error) in
            print("Group Member list fetching failed with exception:" + error!.errorDescription);
        })
    }
    
    
    @objc func didRefreshGroupDetails(_ notification: NSNotification) {
        if let guid = notification.userInfo?["guid"] as? String {
            members.removeAll()
            memberRequest = GroupMembersRequest.GroupMembersRequestBuilder(guid: guid).set(limit: 100).build()
            memberRequest?.fetchNext(onSuccess: { (groupMember) in
                self.members = groupMember
                self.administrators = groupMember.filter {$0.scope == .admin}
                
                DispatchQueue.global(qos: .userInitiated).async {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }, onError: { (error) in
                print("Group Member list fetching failed with exception:" + error!.errorDescription);
            })
        }
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


extension CometChatGroupDetail: UITableViewDelegate , UITableViewDataSource {
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 || section == 2 || section == 3 {
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
            sectionTitle.text =  "MEMBERS"
        }else if section == 2{
            sectionTitle.text =  ""
        }else if section == 3{
            sectionTitle.text =  ""
        }else if section == 4{
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
        case 0: return settingsItems.count
        case 1: return 1
        case 2: return members.count
        case 3: return viewMoreItems.count
        case 4:return supportItems.count
        default: return 0
        }
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if  indexPath.section == 0 && indexPath.row == 0 {
            return 100
        }else if members.count < 10 && indexPath.section == 3 {
            return 0
        }else if currentGroup?.owner == CometChat.getLoggedInUser()?.uid && indexPath.section == 1 {
            return 60
        }else if currentGroup?.scope != .admin && indexPath.section == 1 {
            return 0
        }else{
            return 60
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell:UITableViewCell = UITableViewCell()
        
        switch indexPath.section {
        case 0:
            switch settingsItems[indexPath.row] {
            case CometChatGroupDetail.GROUP_INFO_CELL:
                let groupInfoCell = tableView.dequeueReusableCell(withIdentifier: "groupView", for: indexPath) as! CometChatGroupView
                groupInfoCell.groupAvtar.set(image: "")
                groupInfoCell.groupName.text = currentGroup?.name?.capitalized ?? ""
                if members.count < 100 {
                    groupInfoCell.groupDetails.text = "\(members.count) Members"
                }else{
                    groupInfoCell.groupDetails.text =  "100+ Members"
                }
                groupInfoCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return groupInfoCell
            case CometChatGroupDetail.NOTIFICATION_CELL:
                let notificationsCell = tableView.dequeueReusableCell(withIdentifier: "notificationsView", for: indexPath) as! NotificationsView
                notificationsCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return notificationsCell
                
            case CometChatGroupDetail.ADMINISTRATOR_CELL:
                
                let administratorCell = tableView.dequeueReusableCell(withIdentifier: "administratorView", for: indexPath) as! AdministratorView
                administratorCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                administratorCell.adminCount.text = "\(administrators.count)"
                return administratorCell
            default:break
            }
            
        case 1:
            let addMemberCell = tableView.dequeueReusableCell(withIdentifier: "addMemberView",for: indexPath) as! AddMemberView
            addMemberCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            return addMemberCell
            
        case 2:
            let member = members[indexPath.row]
            let membersCell = tableView.dequeueReusableCell(withIdentifier: "membersView", for: indexPath) as! MembersView
            membersCell.member = member
            if member.uid == currentGroup?.owner {
                membersCell.scope.text = "Owner"
            }
            membersCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            return membersCell
            
        case 3:
            
            let viewMoreCell = tableView.dequeueReusableCell(withIdentifier: "viewMoreView", for: indexPath) as! ViewMoreView
            viewMoreCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
            return viewMoreCell
            
        case 4:
            switch supportItems[indexPath.row] {
            case CometChatGroupDetail.DELETE_AND_EXIT_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = "Delete & Exit"
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
                
            case CometChatGroupDetail.EXIT_CELL:
                let supportCell = tableView.dequeueReusableCell(withIdentifier: "supportView", for: indexPath) as! SupportView
                supportCell.textLabel?.text = "Leave Group"
                supportCell.separatorInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
                return supportCell
            case CometChatGroupDetail.REPORT_CELL:
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
            switch settingsItems[indexPath.row] {
            case CometChatGroupDetail.GROUP_INFO_CELL: break
            case CometChatGroupDetail.NOTIFICATION_CELL: break
            case CometChatGroupDetail.ADMINISTRATOR_CELL:
                let addAdmins = CometChatAddAdministrators()
                addAdmins.mode = .fetchAdministrators
                guard let group = currentGroup else { return }
                addAdmins.set(group: group)
                let navigationController: UINavigationController = UINavigationController(rootViewController: addAdmins)
                self.present(navigationController, animated: true, completion: nil)
                
                
            default:break }
        case 1:
            let addMembers = CometChatAddMembers()
            guard let group = currentGroup else { return }
            addMembers.set(group: group)
            let navigationController: UINavigationController = UINavigationController(rootViewController: addMembers)
            self.present(navigationController, animated: true, completion: nil)
        case 2: break
        // Members here
        case 3 : break
        case 4:
            switch supportItems[indexPath.row] {
            case CometChatGroupDetail.DELETE_AND_EXIT_CELL:
                
                if let guid = currentGroup?.guid {
                    CometChat.deleteGroup(GUID: guid, onSuccess: { (success) in
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil, userInfo: nil)
                            }
                            self.view.makeToast(success)
                        }
                    }) { (error) in
                        print("error while deleting the group:\(String(describing: error?.errorDescription))")
                        DispatchQueue.main.async {self.view.makeToast(error?.errorDescription)}
                    }
                }
                
            case CometChatGroupDetail.EXIT_CELL:
                
                if let guid = currentGroup?.guid {
                    
                    CometChat.leaveGroup(GUID: guid, onSuccess: { (success) in
                        
                        DispatchQueue.main.async {
                            self.dismiss(animated: true) {
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "didGroupDeleted"), object: nil, userInfo: nil)
                            }
                            self.view.makeToast(success)
                        }
                    }) { (error) in
                        print("error while leaving the group:\(String(describing: error?.errorDescription))")
                        DispatchQueue.main.async {self.view.makeToast(error?.errorDescription)}
                    }
                }
                
            case CometChatGroupDetail.REPORT_CELL: break
            default:break }
        default: break
        }
        if  let selectedCell = tableView.cellForRow(at: indexPath) as? ViewMoreView {
            selectedCell.activityIndicator.startAnimating()
            memberRequest?.fetchNext(onSuccess: { (groupMember) in
                if groupMember.isEmpty { self.viewMoreItems.removeAll()}
                DispatchQueue.main.async {selectedCell.activityIndicator.stopAnimating()}
                self.members.append(contentsOf: groupMember)
                self.administrators = groupMember.filter {$0.scope == .admin}
                DispatchQueue.main.async {self.tableView.reloadData() }
            }, onError: { (error) in
                DispatchQueue.main.async {selectedCell.activityIndicator.stopAnimating()}
                print("Group Member list fetching failed with exception:" + error!.errorDescription);
            })
        }
    }
    
    
    @available(iOS 13.0, *)
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { suggestedActions in
            
            if  let selectedCell = tableView.cellForRow(at: indexPath) as? MembersView  {
                let removeMember = UIAction(title: "Remove Member", image: UIImage(systemName: "trash"), attributes: .destructive) { action in
                    
                    CometChat.kickGroupMember(UID: selectedCell.member.uid ?? "", GUID: self.currentGroup?.guid ?? "", onSuccess: { (success) in
                        DispatchQueue.main.async {
                            if let group = self.currentGroup {
                                let data:[String: String] = ["guid": group.guid ]
                                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "refreshGroupDetails"), object: nil, userInfo: data)
                            }
                            
                            self.view.makeToast(success)
                        }
                    }) { (error) in
                        DispatchQueue.main.async {
                            self.view.makeToast(error?.errorDescription)
                        }
                    }
                    
                }
                let memberName = (tableView.cellForRow(at: indexPath) as? MembersView)?.member.name ?? ""
                let groupName = self.currentGroup?.name ?? ""
                
                if CometChat.getLoggedInUser()?.uid == self.currentGroup?.owner || self.currentGroup?.scope == .admin {
                    
                    if selectedCell.member.scope == .participant {
                        return UIMenu(title: "⚠️ Remove \(memberName) from \(groupName) group?" , children: [removeMember])
                    }else if CometChat.getLoggedInUser()?.uid == self.currentGroup?.owner && selectedCell.member.scope == .admin && selectedCell.member.uid != CometChat.getLoggedInUser()?.uid{
                        return UIMenu(title: "⚠️ Remove \(memberName) from \(groupName) group?" , children: [removeMember])
                    }
                }
            }
            return UIMenu(title: "")
        })
        
    }
}

extension CometChatGroupDetail: CometChatGroupDelegate {
    
    public func onGroupMemberJoined(action: ActionMessage, joinedUser: User, joinedGroup: Group) {
        if let group = currentGroup {
            if group == joinedGroup {
                fetchGroupMembers(group: group)
            }
        }
    }
    
    public func onGroupMemberLeft(action: ActionMessage, leftUser: User, leftGroup: Group) {
        if let group = currentGroup {
            if group == leftGroup {
                getGroup(group: group)
                fetchGroupMembers(group: group)
            }
        }
    }
    
    public func onGroupMemberKicked(action: ActionMessage, kickedUser: User, kickedBy: User, kickedFrom: Group) {
        if let group = currentGroup {
            if group == kickedFrom {
                getGroup(group: group)
                fetchGroupMembers(group: group)
            }
        }
    }
    
    public func onGroupMemberBanned(action: ActionMessage, bannedUser: User, bannedBy: User, bannedFrom: Group) {
        if let group = currentGroup {
            if group == bannedFrom {
                 getGroup(group: group)
                fetchGroupMembers(group: group)
            }
        }
    }
    
    public func onGroupMemberUnbanned(action: ActionMessage, unbannedUser: User, unbannedBy: User, unbannedFrom: Group) {
        if let group = currentGroup {
            if group == unbannedFrom {
                 getGroup(group: group)
                fetchGroupMembers(group: group)
            }
        }
    }
    
    public func onGroupMemberScopeChanged(action: ActionMessage, scopeChangeduser: User, scopeChangedBy: User, scopeChangedTo: String, scopeChangedFrom: String, group: Group) {
        if let group = currentGroup {
            if group == group {
                getGroup(group: group)
                fetchGroupMembers(group: group)
                
            }
        }
    }
    
    public func onMemberAddedToGroup(action: ActionMessage, addedBy: User, addedUser: User, addedTo: Group) {
        if let group = currentGroup {
            if group == group {
                 getGroup(group: group)
                fetchGroupMembers(group: group)
            }
        }
    }
}
